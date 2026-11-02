--[[ ======================================================================
    AURA LUXE v3  |  Mobile-first Roblox UI Library (Delta / Codex / Arceus)
    - Rounded window (header corners fixed), touch-sized controls
    - Themes, HSV color picker, multi-dropdown, keybind modes, key system
    - Config slots + AutoSave/AutoLoad, stacking notifications, watermark
    - Full cleanup (no leaked connections), re-execute safe
    ====================================================================== ]]

local cloneref = cloneref or function(o) return o end
local function Svc(n)
    local ok, s = pcall(function() return cloneref(game:GetService(n)) end)
    return ok and s or game:GetService(n)
end

local UIS         = Svc("UserInputService")
local TweenService= Svc("TweenService")
local RunService  = Svc("RunService")
local CoreGui     = Svc("CoreGui")
local Players     = Svc("Players")
local HttpService = Svc("HttpService")
local TextService = Svc("TextService")
local Workspace   = Svc("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ======================= Themes =======================
local Themes = {
    Dark = {
        Background = Color3.fromRGB(14, 16, 23), Header = Color3.fromRGB(20, 23, 33),
        Sidebar = Color3.fromRGB(11, 13, 19), Card = Color3.fromRGB(22, 26, 38),
        CardHover = Color3.fromRGB(31, 36, 52), Stroke = Color3.fromRGB(40, 46, 66),
        Accent = Color3.fromRGB(99, 102, 241), Accent2 = Color3.fromRGB(139, 92, 246),
        Text = Color3.fromRGB(244, 247, 252), SubText = Color3.fromRGB(148, 163, 184),
        Success = Color3.fromRGB(52, 211, 153), Danger = Color3.fromRGB(239, 68, 68),
        Warn = Color3.fromRGB(245, 158, 11), SwitchOff = Color3.fromRGB(44, 50, 70),
    },
    Ocean = {
        Background = Color3.fromRGB(9, 16, 25), Header = Color3.fromRGB(14, 24, 37),
        Sidebar = Color3.fromRGB(7, 13, 21), Card = Color3.fromRGB(16, 28, 43),
        CardHover = Color3.fromRGB(23, 40, 60), Stroke = Color3.fromRGB(30, 52, 76),
        Accent = Color3.fromRGB(14, 165, 233), Accent2 = Color3.fromRGB(20, 184, 166),
        SwitchOff = Color3.fromRGB(34, 56, 80),
    },
    Rose = {
        Background = Color3.fromRGB(20, 13, 17), Header = Color3.fromRGB(30, 19, 25),
        Sidebar = Color3.fromRGB(16, 10, 14), Card = Color3.fromRGB(36, 22, 29),
        CardHover = Color3.fromRGB(50, 30, 40), Stroke = Color3.fromRGB(66, 40, 52),
        Accent = Color3.fromRGB(244, 63, 94), Accent2 = Color3.fromRGB(251, 146, 60),
        SwitchOff = Color3.fromRGB(70, 44, 56),
    },
    Emerald = {
        Background = Color3.fromRGB(10, 18, 16), Header = Color3.fromRGB(15, 28, 24),
        Sidebar = Color3.fromRGB(8, 14, 13), Card = Color3.fromRGB(18, 32, 28),
        CardHover = Color3.fromRGB(25, 45, 39), Stroke = Color3.fromRGB(34, 60, 52),
        Accent = Color3.fromRGB(16, 185, 129), Accent2 = Color3.fromRGB(132, 204, 22),
        SwitchOff = Color3.fromRGB(38, 66, 58),
    },
    Light = {
        Background = Color3.fromRGB(240, 242, 247), Header = Color3.fromRGB(255, 255, 255),
        Sidebar = Color3.fromRGB(228, 232, 240), Card = Color3.fromRGB(255, 255, 255),
        CardHover = Color3.fromRGB(236, 240, 247), Stroke = Color3.fromRGB(212, 218, 230),
        Accent = Color3.fromRGB(79, 70, 229), Accent2 = Color3.fromRGB(147, 51, 234),
        Text = Color3.fromRGB(20, 24, 35), SubText = Color3.fromRGB(100, 112, 134),
        SwitchOff = Color3.fromRGB(200, 206, 220),
    },
}

local T = {}                      -- active theme
local Bound, Hooks = {}, {}       -- themed instances / repaint callbacks
for k, v in pairs(Themes.Dark) do T[k] = v end

local FONT, FONTB = Enum.Font.GothamMedium, Enum.Font.GothamBold

local Lib = { Version = "3.0", Flags = {}, Registry = {}, NoSave = {}, Themes = Themes, _wins = {} }

-- ======================= Helpers =======================
local function Th(inst, prop, key) inst[prop] = T[key]; Bound[#Bound + 1] = { inst, prop, key } end
local function Hook(fn) Hooks[#Hooks + 1] = fn; return fn end

local function Tw(o, p, t, s, d)
    if not t or t <= 0 then for k, v in pairs(p) do o[k] = v end return end
    local tw = TweenService:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out), p)
    tw:Play()
    return tw
end

local function Corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = p; return c end
local function Stroke(p, key, th)
    local s = Instance.new("UIStroke"); s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Th(s, "Color", key or "Stroke"); s.Parent = p; return s
end
local function Pad(p, l, t, r, b)
    local u = Instance.new("UIPadding"); u.PaddingLeft = UDim.new(0, l); u.PaddingTop = UDim.new(0, t)
    u.PaddingRight = UDim.new(0, r); u.PaddingBottom = UDim.new(0, b); u.Parent = p; return u
end

-- Arabic detection (basic + supplement + presentation forms)
local function IsArabic(s)
    if typeof(s) ~= "string" then return false end
    return s:find("[\216-\219\221]") ~= nil or s:find("\239[\173-\187]") ~= nil
end
local function Align(s) return IsArabic(s) and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left end

local function Safe(cb, ...)
    if typeof(cb) ~= "function" then return end
    local ok, err = pcall(cb, ...)
    if not ok then warn("[AuraLuxe] callback error: " .. tostring(err)) end
end

local function IsPointer(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function IsMove(i)
    return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local function Measure(text, size, width)
    local ok, v = pcall(function() return TextService:GetTextSize(text, size, FONT, Vector2.new(width, 10000)) end)
    if ok and v then return v.Y end
    return size + 2
end

local function Label(parent, text, size, key, font, x)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1; l.Text = text or ""; l.TextSize = size or 13
    l.Font = font or FONT; Th(l, "TextColor3", key or "Text")
    l.TextXAlignment = x or Align(text); l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = parent; return l
end

local function SafeParent()
    local ok, p = pcall(function() return (gethui and gethui()) or CoreGui end)
    if ok and p then return p end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function ApplyTheme(src, anim)
    src = type(src) == "table" and src or Themes[src]
    if not src then return false end
    for k, v in pairs(Themes.Dark) do T[k] = src[k] or v end
    for _, b in ipairs(Bound) do
        if b[1].Parent then Tw(b[1], { [b[2]] = T[b[3]] }, anim == false and 0 or 0.25) end
    end
    for _, h in ipairs(Hooks) do pcall(h) end
    return true
end

-- ======================= Config encode/decode =======================
local function Encode(v)
    if typeof(v) == "Color3" then return { __t = "C3", R = v.R, G = v.G, B = v.B } end
    if typeof(v) == "EnumItem" then return v.Name end
    if type(v) == "table" then local o = {}; for k, x in pairs(v) do o[k] = Encode(x) end return o end
    return v
end
local function Decode(v)
    if type(v) == "table" then
        if v.__t == "C3" then return Color3.new(v.R, v.G, v.B) end
        local o = {}; for k, x in pairs(v) do o[k] = Decode(x) end return o
    end
    return v
end

-- ======================= Key system =======================
local function KeyGate(ks, parent)
    local keys = type(ks.Key) == "table" and ks.Key or { ks.Key }
    local file = ks.SaveKey and (ks.FileName or "AuraLuxe/key.txt")
    local function valid(k) for _, v in ipairs(keys) do if k == v then return true end end return false end
    if file and isfile and readfile then
        local ok, s = pcall(function() return isfile(file) and readfile(file) end)
        if ok and s and valid(s) then return true end
    end
    local g = Instance.new("ScreenGui"); g.ResetOnSpawn = false; g.IgnoreGuiInset = true
    g.DisplayOrder = 10000; g.Parent = parent
    local F = Instance.new("Frame"); F.AnchorPoint = Vector2.new(.5, .5); F.Position = UDim2.fromScale(.5, .5)
    F.Size = UDim2.fromOffset(320, 190); F.BorderSizePixel = 0; Th(F, "BackgroundColor3", "Background")
    F.Parent = g; Corner(F, 14); Stroke(F, "Accent", 1.5)
    local t = Label(F, ks.Title or "Key System", 16, "Text", FONTB); t.Position = UDim2.fromOffset(16, 12); t.Size = UDim2.new(1, -32, 0, 22)
    local n = Label(F, ks.Note or "Enter your key to continue.", 12, "SubText"); n.Position = UDim2.fromOffset(16, 36); n.Size = UDim2.new(1, -32, 0, 18)
    local box = Instance.new("TextBox"); box.Position = UDim2.fromOffset(16, 66); box.Size = UDim2.new(1, -32, 0, 38)
    box.PlaceholderText = "Key..."; box.Text = ""; box.TextSize = 14; box.Font = FONT; box.ClearTextOnFocus = false
    Th(box, "BackgroundColor3", "Card"); Th(box, "TextColor3", "Text"); Th(box, "PlaceholderColor3", "SubText")
    box.Parent = F; Corner(box, 8); Stroke(box, "Stroke", 1)
    local btn = Instance.new("TextButton"); btn.Position = UDim2.fromOffset(16, 118); btn.Size = UDim2.new(1, -32, 0, 40)
    btn.Text = "Submit"; btn.TextSize = 14; btn.Font = FONTB; btn.AutoButtonColor = true
    Th(btn, "BackgroundColor3", "Accent"); btn.TextColor3 = Color3.new(1, 1, 1); btn.Parent = F; Corner(btn, 8)
    local st = Label(F, "", 11, "Danger"); st.Position = UDim2.fromOffset(16, 162); st.Size = UDim2.new(1, -32, 0, 16)
    local result
    btn.Activated:Connect(function()
        if valid(box.Text) then
            result = true
            if file and writefile then pcall(function()
                if makefolder and isfolder and not isfolder("AuraLuxe") then makefolder("AuraLuxe") end
                writefile(file, box.Text)
            end) end
        else st.Text = "Invalid key" end
    end)
    while result == nil and g.Parent do task.wait(0.1) end
    g:Destroy()
    return result == true
end

-- ======================= Window =======================
function Lib:GetFlag(n) return self.Flags[n] end
function Lib:SetFlag(n, v) if self.Registry[n] then self.Registry[n](v) else self.Flags[n] = v end end
function Lib:Notify(cfg) local w = self._wins[#self._wins]; if w then return w:Notify(cfg) end end
function Lib:Destroy() for i = #self._wins, 1, -1 do self._wins[i]:Destroy() end end
function Lib:SetTheme(n) return ApplyTheme(n) end

function Lib:CreateWindow(cfg)
    cfg = cfg or {}
    pcall(function() local g = getgenv(); if g.__AuraLuxe then g.__AuraLuxe:Destroy() end end)

    if type(cfg.Theme) == "table" or Themes[cfg.Theme or "Dark"] then ApplyTheme(cfg.Theme or "Dark", false) end
    Lib.Flags, Lib.Registry, Lib.NoSave = {}, {}, {}

    local Parent = SafeParent()
    if cfg.KeySystem and not KeyGate(cfg.KeySystem, Parent) then return nil end

    local Title = cfg.Title or cfg.Name or "AURA LUXE"
    local Subtitle = cfg.Subtitle or "v" .. Lib.Version
    local W, H = 520, 320
    if type(cfg.Size) == "table" then W, H = cfg.Size[1] or W, cfg.Size[2] or H end
    local PAGE_W = W - 152 - 8
    local CS = cfg.ConfigurationSaving or {}
    local Win = { Visible = true, Elements = {}, Tabs = {}, Current = nil, Alive = true, _loading = false }
    local conns = {}
    local function Conn(sig, fn) local c = sig:Connect(fn); conns[#conns + 1] = c; return c end

    -- ScreenGui
    local Gui = Instance.new("ScreenGui")
    Gui.Name = HttpService:GenerateGUID(false):sub(1, 12)
    Gui.ResetOnSpawn = false; Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.IgnoreGuiInset = true; Gui.DisplayOrder = 2147483000
    if syn and syn.protect_gui then pcall(syn.protect_gui, Gui) end
    Gui.Parent = Parent
    Win.Gui = Gui
    pcall(function() getgenv().__AuraLuxe = Win end)

    local function Fit()
        local cam = Workspace.CurrentCamera
        local a = cam and cam.ViewportSize or Gui.AbsoluteSize
        if a.X <= 0 then return 1 end
        return math.clamp(math.min(a.X * 0.94 / W, a.Y * 0.9 / H), 0.5, 1) * (cfg.Scale or 1)
    end

    -- ---------- Main frame ----------
    local Main = Instance.new("Frame")
    Main.Name = "Main"; Main.AnchorPoint = Vector2.new(.5, .5); Main.Position = UDim2.fromScale(.5, .5)
    Main.Size = UDim2.fromOffset(W, H); Main.BorderSizePixel = 0; Main.Visible = false
    Th(Main, "BackgroundColor3", "Background"); Main.Parent = Gui
    Corner(Main, 14)
    local MS = Instance.new("UIScale"); MS.Scale = 0.01; MS.Parent = Main
    local MStroke = Instance.new("UIStroke"); MStroke.Thickness = 1.5; MStroke.Color = Color3.new(1, 1, 1)
    MStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; MStroke.Parent = Main
    local SG = Instance.new("UIGradient"); SG.Rotation = 45; SG.Parent = MStroke
    Hook(function()
        SG.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(.5, T.Accent2), ColorSequenceKeypoint.new(1, T.Stroke) })
    end)()

    -- ---------- Header (rounded top!) ----------
    local Header = Instance.new("Frame")
    Header.Name = "Header"; Header.Size = UDim2.new(1, 0, 0, 46); Header.BorderSizePixel = 0
    Th(Header, "BackgroundColor3", "Header"); Header.Parent = Main
    Corner(Header, 14)
    local HPatch = Instance.new("Frame")     -- squares only the bottom edge of the header
    HPatch.Size = UDim2.new(1, 0, 0, 14); HPatch.Position = UDim2.new(0, 0, 1, -14); HPatch.BorderSizePixel = 0
    Th(HPatch, "BackgroundColor3", "Header"); HPatch.Parent = Header
    local HLine = Instance.new("Frame")
    HLine.Size = UDim2.new(1, 0, 0, 1); HLine.Position = UDim2.new(0, 0, 1, -1); HLine.BorderSizePixel = 0
    Th(HLine, "BackgroundColor3", "Stroke"); HLine.Parent = Header

    local TL = Label(Header, Title, 15, "Text", FONTB); TL.Position = UDim2.fromOffset(16, 5); TL.Size = UDim2.fromOffset(190, 20)
    local SL = Label(Header, Subtitle, 11, "Accent"); SL.Position = UDim2.fromOffset(16, 25); SL.Size = UDim2.fromOffset(190, 14)

    local function HBtn(txt, x)
        local b = Instance.new("TextButton"); b.AnchorPoint = Vector2.new(1, .5); b.Position = UDim2.new(1, x, .5, 0)
        b.Size = UDim2.fromOffset(30, 30); b.Text = txt; b.TextSize = 14; b.Font = FONTB; b.AutoButtonColor = false
        Th(b, "BackgroundColor3", "Card"); Th(b, "TextColor3", "SubText"); b.Parent = Header; Corner(b, 8)
        b.MouseEnter:Connect(function() Tw(b, { BackgroundColor3 = T.CardHover }, .12) end)
        b.MouseLeave:Connect(function() Tw(b, { BackgroundColor3 = T.Card }, .12) end)
        return b
    end
    local CloseBtn, HideBtn = HBtn("✕", -10), HBtn("–", -46)

    -- search
    local SBox = Instance.new("Frame"); SBox.AnchorPoint = Vector2.new(1, .5); SBox.Position = UDim2.new(1, -84, .5, 0)
    SBox.Size = UDim2.fromOffset(130, 30); SBox.BorderSizePixel = 0; Th(SBox, "BackgroundColor3", "Card")
    SBox.Parent = Header; Corner(SBox, 8); Stroke(SBox, "Stroke", 1)
    local Search = Instance.new("TextBox"); Search.BackgroundTransparency = 1; Search.Size = UDim2.new(1, -16, 1, 0)
    Search.Position = UDim2.fromOffset(8, 0); Search.PlaceholderText = "Search..."; Search.Text = ""; Search.TextSize = 12
    Search.Font = FONT; Search.ClearTextOnFocus = false; Search.TextXAlignment = Enum.TextXAlignment.Left
    Th(Search, "TextColor3", "Text"); Th(Search, "PlaceholderColor3", "SubText"); Search.Parent = SBox
    Conn(Search:GetPropertyChangedSignal("Text"), function()
        local q = string.lower(Search.Text):match("^%s*(.-)%s*$")
        for _, e in ipairs(Win.Elements) do
            if e.Frame.Parent then e.Frame.Visible = (q == "") or (e.Key:find(q, 1, true) ~= nil) end
        end
    end)

    -- ---------- Sidebar / content ----------
    local Sidebar = Instance.new("Frame"); Sidebar.Position = UDim2.fromOffset(8, 54); Sidebar.Size = UDim2.new(0, 128, 1, -62)
    Sidebar.BorderSizePixel = 0; Th(Sidebar, "BackgroundColor3", "Sidebar"); Sidebar.Parent = Main; Corner(Sidebar, 10)
    local TabScroll = Instance.new("ScrollingFrame"); TabScroll.BackgroundTransparency = 1; TabScroll.BorderSizePixel = 0
    TabScroll.Size = UDim2.fromScale(1, 1); TabScroll.ScrollBarThickness = 0; TabScroll.CanvasSize = UDim2.new()
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; TabScroll.Parent = Sidebar
    Pad(TabScroll, 6, 6, 6, 6)
    local TL2 = Instance.new("UIListLayout"); TL2.Padding = UDim.new(0, 4); TL2.SortOrder = Enum.SortOrder.LayoutOrder; TL2.Parent = TabScroll

    local Content = Instance.new("Frame"); Content.BackgroundTransparency = 1
    Content.Position = UDim2.fromOffset(144, 54); Content.Size = UDim2.new(1, -152, 1, -62); Content.Parent = Main

    -- ---------- Dragging (rounded, scale-safe, click-vs-drag aware) ----------
    local function MakeDraggable(handle, target)
        local st = { moved = false }
        local dragging, startPos, startCenter = false, nil, nil
        Conn(handle.InputBegan, function(i)
            if IsPointer(i) then
                dragging, st.moved = true, false
                startPos = i.Position
                startCenter = target.AbsolutePosition + target.AbsoluteSize / 2
            end
        end)
        Conn(UIS.InputChanged, function(i)
            if dragging and IsMove(i) then
                local d = i.Position - startPos
                if d.Magnitude > 6 then st.moved = true end
                if st.moved then
                    local vp = Gui.AbsoluteSize
                    local cx = math.clamp(startCenter.X + d.X, 30, math.max(30, vp.X - 30))
                    local cy = math.clamp(startCenter.Y + d.Y, 24, math.max(24, vp.Y - 24))
                    target.Position = UDim2.fromOffset(cx, cy)
                end
            end
        end)
        Conn(UIS.InputEnded, function(i) if IsPointer(i) then dragging = false end end)
        return st
    end
    MakeDraggable(Header, Main)

    -- generic pointer drag for sliders / pickers (locks page scrolling while dragging)
    local function PointerDrag(frame, page, fn)
        local active = false
        Conn(frame.InputBegan, function(i)
            if IsPointer(i) then active = true; page.ScrollingEnabled = false; fn(i.Position) end
        end)
        Conn(UIS.InputChanged, function(i) if active and IsMove(i) then fn(i.Position) end end)
        Conn(UIS.InputEnded, function(i)
            if active and IsPointer(i) then active = false; page.ScrollingEnabled = true end
        end)
    end

    -- ---------- Visibility ----------
    function Win:SetVisible(v)
        Win.Visible = v
        if v then
            Main.Visible = true
            Tw(MS, { Scale = Fit() }, .3, Enum.EasingStyle.Back)
        else
            Tw(MS, { Scale = 0.01 }, .18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(.2, function() if not Win.Visible and Main.Parent then Main.Visible = false end end)
        end
    end
    function Win:Toggle() Win:SetVisible(not Win.Visible) end
    HideBtn.Activated:Connect(function() Win:SetVisible(false) end)
    CloseBtn.Activated:Connect(function() Win:Destroy() end)

    local function Rescale() if Win.Visible and Main.Visible then MS.Scale = Fit() end end
    if Workspace.CurrentCamera then Conn(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), Rescale) end
    Conn(Gui:GetPropertyChangedSignal("AbsoluteSize"), Rescale)

    -- toggle keybind (PC) + floating button (mobile)
    local tk = cfg.ToggleUIKeybind or "RightShift"
    if typeof(tk) == "EnumItem" then tk = tk.Name end
    Conn(UIS.InputBegan, function(i, gpe)
        if not gpe and i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name == tk then Win:Toggle() end
    end)
    local showBtn = cfg.ShowToggle
    if showBtn == nil then showBtn = UIS.TouchEnabled end
    local MT = Instance.new("TextButton")
    MT.AnchorPoint = Vector2.new(.5, .5); MT.Position = UDim2.fromOffset(38, 110); MT.Size = UDim2.fromOffset(46, 46)
    MT.Text = cfg.ShowText or "⚡"; MT.TextSize = 20; MT.Font = FONTB; MT.AutoButtonColor = false; MT.Visible = false
    Th(MT, "BackgroundColor3", "Card"); Th(MT, "TextColor3", "Accent"); MT.Parent = Gui
    Corner(MT, 23); Stroke(MT, "Accent", 1.5)
    local mtDrag = MakeDraggable(MT, MT)
    MT.Activated:Connect(function() if not mtDrag.moved then Win:Toggle() end end)

    -- ---------- Notifications ----------
    local Holder = Instance.new("Frame"); Holder.BackgroundTransparency = 1; Holder.AnchorPoint = Vector2.new(1, 1)
    Holder.Position = UDim2.new(1, -12, 1, -12); Holder.Size = UDim2.new(0, 270, 1, -24); Holder.Parent = Gui
    local HL = Instance.new("UIListLayout"); HL.VerticalAlignment = Enum.VerticalAlignment.Bottom
    HL.HorizontalAlignment = Enum.HorizontalAlignment.Right; HL.Padding = UDim.new(0, 8); HL.SortOrder = Enum.SortOrder.LayoutOrder; HL.Parent = Holder
    local nOrder = 0
    function Win:Notify(n)
        n = type(n) == "table" and n or { Content = tostring(n) }
        nOrder += 1
        local key = ({ Success = "Success", Error = "Danger", Warning = "Warn" })[n.Type] or "Accent"
        local Wrap = Instance.new("Frame"); Wrap.BackgroundTransparency = 1; Wrap.Size = UDim2.new(1, 0, 0, 0)
        Wrap.AutomaticSize = Enum.AutomaticSize.Y; Wrap.LayoutOrder = nOrder; Wrap.Parent = Holder
        local Card = Instance.new("CanvasGroup"); Card.Size = UDim2.new(1, 0, 0, 0); Card.AutomaticSize = Enum.AutomaticSize.Y
        Card.Position = UDim2.fromOffset(40, 0); Card.GroupTransparency = 1; Card.BorderSizePixel = 0
        Th(Card, "BackgroundColor3", "Card"); Card.Parent = Wrap; Corner(Card, 10); Stroke(Card, key, 1.3)
        Pad(Card, 12, 10, 12, 10)
        local L = Instance.new("UIListLayout"); L.Padding = UDim.new(0, 3); L.SortOrder = Enum.SortOrder.LayoutOrder; L.Parent = Card
        local function TL_(txt, size, k, f, o)
            local l = Label(Card, txt, size, k, f); l.TextWrapped = true; l.TextTruncate = Enum.TextTruncate.None
            l.Size = UDim2.new(1, 0, 0, 0); l.AutomaticSize = Enum.AutomaticSize.Y; l.LayoutOrder = o; return l
        end
        TL_(n.Title or "Notification", 13, "Text", FONTB, 1)
        if n.Content and n.Content ~= "" then TL_(n.Content, 12, "SubText", FONT, 2) end
        Tw(Card, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 }, .3, Enum.EasingStyle.Back)
        task.delay(n.Duration or 3, function()
            if not Card.Parent then return end
            Tw(Card, { Position = UDim2.fromOffset(40, 0), GroupTransparency = 1 }, .25)
            task.wait(.28); Wrap:Destroy()
        end)
    end

    -- ---------- Config ----------
    local function CfgPath(slot)
        local folder = CS.FolderName or "AuraLuxe"
        slot = (tostring(slot or CS.FileName or "Auto"):gsub("[^%w_%-]", ""))
        if slot == "" then slot = "Auto" end
        return folder, folder .. "/" .. slot .. ".json"
    end
    function Win:SaveConfig(slot, silent)
        if not writefile then if not silent then Win:Notify({ Title = "Config", Content = "writefile not supported", Type = "Error" }) end return false end
        local folder, path = CfgPath(slot)
        pcall(function() if makefolder and isfolder and not isfolder(folder) then makefolder(folder) end end)
        local data = {}
        for k, v in pairs(Lib.Flags) do if not Lib.NoSave[k] then data[k] = Encode(v) end end
        local ok = pcall(function() writefile(path, HttpService:JSONEncode(data)) end)
        if not silent then Win:Notify({ Title = ok and "Config Saved" or "Config Error", Content = path, Type = ok and "Success" or "Error" }) end
        return ok
    end
    function Win:LoadConfig(slot, silent)
        local _, path = CfgPath(slot)
        if not (readfile and isfile and isfile(path)) then
            if not silent then Win:Notify({ Title = "Config", Content = "Not found: " .. path, Type = "Warning" }) end
            return false
        end
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if not ok or type(data) ~= "table" then return false end
        Win._loading = true
        for k, v in pairs(data) do
            v = Decode(v)
            if Lib.Registry[k] then pcall(Lib.Registry[k], v) else Lib.Flags[k] = v end
        end
        Win._loading = false
        if not silent then Win:Notify({ Title = "Config Loaded", Content = path, Type = "Success" }) end
        return true
    end
    function Win:DeleteConfig(slot)
        local _, path = CfgPath(slot)
        local ok = pcall(function() delfile(path) end)
        Win:Notify({ Title = ok and "Config Deleted" or "Config", Content = path, Type = ok and "Success" or "Warning" })
    end
    local saveTok = 0
    local function SetFlag(flag, v, noSave)
        Lib.Flags[flag] = v
        if noSave or Win._loading or not (CS.Enabled and CS.AutoSave ~= false) then return end
        saveTok += 1; local t = saveTok
        task.delay(1.5, function() if t == saveTok and Win.Alive then Win:SaveConfig(CS.FileName or "Auto", true) end end)
    end

    function Win:SetTheme(n) return ApplyTheme(n) end

    -- ---------- Watermark ----------
    function Win:CreateWatermark(text)
        text = text or Title
        local F = Instance.new("Frame"); F.AnchorPoint = Vector2.new(1, 0); F.Position = UDim2.new(1, -12, 0, 10)
        F.Size = UDim2.fromOffset(0, 26); F.AutomaticSize = Enum.AutomaticSize.X; F.BorderSizePixel = 0
        Th(F, "BackgroundColor3", "Card"); F.Parent = Gui; Corner(F, 8); Stroke(F, "Stroke", 1); Pad(F, 10, 0, 10, 0)
        local L = Label(F, text, 11, "Text", FONTB); L.Size = UDim2.new(0, 0, 1, 0); L.AutomaticSize = Enum.AutomaticSize.X
        L.TextTruncate = Enum.TextTruncate.None
        local frames, last, ping = 0, os.clock(), 0
        Conn(RunService.Heartbeat, function()
            frames += 1
            local now = os.clock()
            if now - last >= 1 then
                local fps = math.round(frames / (now - last)); frames = 0; last = now
                pcall(function() ping = math.round(Svc("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                L.Text = string.format("%s  |  FPS %d  |  %dms", text, fps, ping)
            end
        end)
        return { SetVisible = function(_, v) F.Visible = v end, SetText = function(_, t) text = t end }
    end

    -- ---------- Tabs ----------
    local tabCount = 0
    function Win:CreateTab(name, icon)
        tabCount += 1
        local Tab = {}
        local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1, 0, 0, 36); Btn.Text = ""; Btn.AutoButtonColor = false
        Btn.BackgroundTransparency = 1; Btn.BorderSizePixel = 0; Btn.LayoutOrder = tabCount; Btn.Parent = TabScroll; Corner(Btn, 8)
        local Bar = Instance.new("Frame"); Bar.AnchorPoint = Vector2.new(0, .5); Bar.Position = UDim2.new(0, 3, .5, 0)
        Bar.Size = UDim2.fromOffset(3, 16); Bar.BorderSizePixel = 0; Bar.BackgroundTransparency = 1
        Th(Bar, "BackgroundColor3", "Accent"); Bar.Parent = Btn; Corner(Bar, 2)
        local tx = 14
        if icon then
            local I = Instance.new("ImageLabel"); I.BackgroundTransparency = 1; I.Size = UDim2.fromOffset(18, 18)
            I.AnchorPoint = Vector2.new(0, .5); I.Position = UDim2.new(0, 12, .5, 0)
            I.Image = type(icon) == "number" and ("rbxassetid://" .. icon) or tostring(icon); I.Parent = Btn
            Th(I, "ImageColor3", "SubText"); tx = 36
        end
        local TLb = Label(Btn, name, 13, "SubText", FONT); TLb.Position = UDim2.fromOffset(tx, 0); TLb.Size = UDim2.new(1, -(tx + 8), 1, 0)

        local Page = Instance.new("ScrollingFrame"); Page.Name = tostring(name); Page.BackgroundTransparency = 1; Page.BorderSizePixel = 0
        Page.Size = UDim2.fromScale(1, 1); Page.ScrollBarThickness = 3; Page.CanvasSize = UDim2.new()
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y; Page.Visible = false; Page.ScrollingDirection = Enum.ScrollingDirection.Y
        Th(Page, "ScrollBarImageColor3", "Stroke"); Page.Parent = Content
        Pad(Page, 0, 2, 6, 8)
        local PL = Instance.new("UIListLayout"); PL.Padding = UDim.new(0, 6); PL.SortOrder = Enum.SortOrder.LayoutOrder; PL.Parent = Page

        -- smooth wheel scroll (PC)
        local tgt = 0
        Conn(Page.InputChanged, function(i)
            if i.UserInputType == Enum.UserInputType.MouseWheel then
                local mx = math.max(0, Page.AbsoluteCanvasSize.Y - Page.AbsoluteWindowSize.Y)
                tgt = math.clamp((tgt == 0 and Page.CanvasPosition.Y or tgt) - i.Position.Z * 60, 0, mx)
                Tw(Page, { CanvasPosition = Vector2.new(0, tgt) }, .18)
            end
        end)

        local obj = { Btn = Btn, Bar = Bar, Label = TLb, Page = Page }
        local function Paint(active)
            Tw(Btn, { BackgroundTransparency = active and 0 or 1, BackgroundColor3 = T.Card }, .2)
            Tw(Bar, { BackgroundTransparency = active and 0 or 1 }, .2)
            Tw(TLb, { TextColor3 = active and T.Text or T.SubText }, .2)
        end
        obj.Paint = Paint
        Hook(function() Paint(Win.Current == obj) end)
        function Tab:Select()
            if Win.Current == obj then return end
            local old = Win.Current
            Win.Current = obj
            if old then old.Page.Visible = false; old.Paint(false) end
            Page.Visible = true; Paint(true)
        end
        Btn.Activated:Connect(function() Tab:Select() end)
        if not Win.Current then Tab:Select() end

        -- ===== element base =====
        local order = 0
        local function Base(c, o)
            o = o or {}
            order += 1
            local nm = c.Name or "Element"
            local desc = c.Desc or c.Description
            local hasDesc = desc ~= nil and desc ~= ""
            local rightW, extra = o.rightW or 0, o.extra or 0
            local textW = PAGE_W - 24 - rightW
            local h, dh = 38, 0
            if hasDesc then dh = Measure(desc, 11, textW); h = 26 + dh + 8 end
            h += extra
            local stack = hasDesc or extra > 0
            local F = Instance.new(o.clickable and "TextButton" or "Frame")
            F.Name = nm; F.Size = UDim2.new(1, 0, 0, h); F.BorderSizePixel = 0; F.LayoutOrder = order
            Th(F, "BackgroundColor3", "Card")
            if o.clickable then F.Text = ""; F.AutoButtonColor = false end
            F.Parent = Page; Corner(F, 8); Stroke(F, "Stroke", 1)
            local L = Label(F, nm, 13, "Text", FONT)
            L.Position = UDim2.fromOffset(12, stack and 6 or 0)
            L.Size = stack and UDim2.new(1, -(24 + rightW), 0, 18) or UDim2.new(1, -(24 + rightW), 1, 0)
            local D
            if hasDesc then
                D = Label(F, desc, 11, "SubText", FONT); D.TextWrapped = true; D.TextTruncate = Enum.TextTruncate.None
                D.TextYAlignment = Enum.TextYAlignment.Top; D.Position = UDim2.fromOffset(12, 26)
                D.Size = UDim2.new(1, -(24 + rightW), 0, dh)
            end
            Win.Elements[#Win.Elements + 1] = { Frame = F, Key = string.lower(nm .. " " .. (desc or "")) }
            if o.clickable then
                F.MouseEnter:Connect(function() Tw(F, { BackgroundColor3 = T.CardHover }, .12) end)
                F.MouseLeave:Connect(function() Tw(F, { BackgroundColor3 = T.Card }, .12) end)
            end
            return F, L, D
        end
        local function Reg(flag, ctrl, c)
            Lib.Registry[flag] = function(v) ctrl:Set(v) end
            if c.NoSave then Lib.NoSave[flag] = true end
        end

        -- ===== Section / Label / Paragraph / Divider =====
        function Tab:CreateSection(text)
            order += 1
            local F = Instance.new("Frame"); F.BackgroundTransparency = 1; F.Size = UDim2.new(1, 0, 0, 26); F.LayoutOrder = order; F.Parent = Page
            local L = Label(F, text or "SECTION", 12, "Accent", FONTB); L.Position = UDim2.fromOffset(4, 0); L.Size = UDim2.new(1, -8, 0, 22)
            local ln = Instance.new("Frame"); ln.Size = UDim2.new(1, 0, 0, 1); ln.Position = UDim2.new(0, 0, 1, -2); ln.BorderSizePixel = 0
            Th(ln, "BackgroundColor3", "Stroke"); ln.Parent = F
            return { Set = function(_, t) L.Text = t; L.TextXAlignment = Align(t) end }
        end
        function Tab:CreateDivider()
            order += 1
            local ln = Instance.new("Frame"); ln.Size = UDim2.new(1, 0, 0, 1); ln.BorderSizePixel = 0; ln.LayoutOrder = order
            Th(ln, "BackgroundColor3", "Stroke"); ln.Parent = Page
        end
        function Tab:CreateLabel(text)
            order += 1
            local L = Label(Page, text or "", 12, "SubText", FONT); L.TextWrapped = true; L.TextTruncate = Enum.TextTruncate.None
            L.Size = UDim2.new(1, -8, 0, 0); L.AutomaticSize = Enum.AutomaticSize.Y; L.LayoutOrder = order
            Win.Elements[#Win.Elements + 1] = { Frame = L, Key = string.lower(text or "") }
            return { Set = function(_, t) L.Text = t; L.TextXAlignment = Align(t) end }
        end
        function Tab:CreateParagraph(c)
            c = c or {}; order += 1
            local F = Instance.new("Frame"); F.Size = UDim2.new(1, 0, 0, 0); F.AutomaticSize = Enum.AutomaticSize.Y
            F.BorderSizePixel = 0; F.LayoutOrder = order; Th(F, "BackgroundColor3", "Card"); F.Parent = Page
            Corner(F, 8); Stroke(F, "Stroke", 1); Pad(F, 12, 10, 12, 10)
            local ly = Instance.new("UIListLayout"); ly.Padding = UDim.new(0, 3); ly.SortOrder = Enum.SortOrder.LayoutOrder; ly.Parent = F
            local function mk(t, sz, k, f, o)
                local l = Label(F, t, sz, k, f); l.TextWrapped = true; l.TextTruncate = Enum.TextTruncate.None
                l.Size = UDim2.new(1, 0, 0, 0); l.AutomaticSize = Enum.AutomaticSize.Y; l.LayoutOrder = o; return l
            end
            local a, b = mk(c.Title or "", 13, "Text", FONTB, 1), mk(c.Content or "", 12, "SubText", FONT, 2)
            Win.Elements[#Win.Elements + 1] = { Frame = F, Key = string.lower((c.Title or "") .. " " .. (c.Content or "")) }
            return { Set = function(_, d) a.Text = d.Title or a.Text; b.Text = d.Content or b.Text
                a.TextXAlignment = Align(a.Text); b.TextXAlignment = Align(b.Text) end }
        end

        -- ===== Button =====
        function Tab:CreateButton(c)
            c = c or {}
            local F, L = Base(c, { clickable = true, rightW = 20 })
            local A = Label(F, ">", 14, "SubText", FONTB, Enum.TextXAlignment.Center); A.AnchorPoint = Vector2.new(1, .5)
            A.Position = UDim2.new(1, -8, .5, 0); A.Size = UDim2.fromOffset(16, 20)
            F.Activated:Connect(function()
                Tw(F, { BackgroundColor3 = T.Accent }, .08)
                task.delay(.1, function() Tw(F, { BackgroundColor3 = T.Card }, .25) end)
                task.spawn(Safe, c.Callback)
            end)
            return { Set = function(_, t) L.Text = t; L.TextXAlignment = Align(t) end, Fire = function() task.spawn(Safe, c.Callback) end }
        end

        -- ===== Toggle =====
        function Tab:CreateToggle(c)
            c = c or {}
            local flag = c.Flag or c.Name or "Toggle"
            local F = Base(c, { clickable = true, rightW = 56 })
            local Sw = Instance.new("Frame"); Sw.AnchorPoint = Vector2.new(1, .5); Sw.Position = UDim2.new(1, -12, .5, 0)
            Sw.Size = UDim2.fromOffset(42, 22); Sw.BorderSizePixel = 0; Sw.Parent = F; Corner(Sw, 11)
            local Kn = Instance.new("Frame"); Kn.AnchorPoint = Vector2.new(0, .5); Kn.Size = UDim2.fromOffset(16, 16)
            Kn.BorderSizePixel = 0; Kn.BackgroundColor3 = Color3.new(1, 1, 1); Kn.Parent = Sw; Corner(Kn, 8)
            local state = c.Default == true
            local function Paint(anim)
                local d = anim and .18 or 0
                Tw(Sw, { BackgroundColor3 = state and T.Accent or T.SwitchOff }, d)
                Tw(Kn, { Position = state and UDim2.new(1, -19, .5, 0) or UDim2.new(0, 3, .5, 0) }, d)
            end
            Paint(false); Hook(function() Paint(false) end)
            SetFlag(flag, state, true)
            local ctrl = {}
            function ctrl:Set(v, silent)
                state = v == true; Paint(true); SetFlag(flag, state)
                if not silent then task.spawn(Safe, c.Callback, state) end
            end
            function ctrl:Get() return state end
            F.Activated:Connect(function() ctrl:Set(not state) end)
            Reg(flag, ctrl, c)
            return ctrl
        end

        -- ===== Slider =====
        function Tab:CreateSlider(c)
            c = c or {}
            local flag = c.Flag or c.Name or "Slider"
            local min, max = c.Min or 0, c.Max or 100
            if max <= min then max = min + 1 end
            local inc = c.Increment or 1
            local suffix = c.Suffix or ""
            local dec = #((tostring(inc):match("%.(%d+)")) or "")
            local F = Base(c, { rightW = 76, extra = 16 })
            local function Fmt(v) return (dec > 0 and string.format("%." .. dec .. "f", v) or tostring(v)) .. suffix end
            local value = math.clamp(c.Default or min, min, max)
            local VL = Label(F, Fmt(value), 12, "Accent", FONTB, Enum.TextXAlignment.Right)
            VL.AnchorPoint = Vector2.new(1, 0); VL.Position = UDim2.new(1, -12, 0, 6); VL.Size = UDim2.fromOffset(70, 18)
            local Hit = Instance.new("TextButton"); Hit.BackgroundTransparency = 1; Hit.Text = ""; Hit.AutoButtonColor = false
            Hit.AnchorPoint = Vector2.new(0, 1); Hit.Position = UDim2.new(0, 12, 1, -4); Hit.Size = UDim2.new(1, -24, 0, 26); Hit.Parent = F
            local Bar = Instance.new("Frame"); Bar.AnchorPoint = Vector2.new(0, .5); Bar.Position = UDim2.fromScale(0, .5)
            Bar.Size = UDim2.new(1, 0, 0, 8); Bar.BorderSizePixel = 0; Th(Bar, "BackgroundColor3", "SwitchOff"); Bar.Parent = Hit; Corner(Bar, 4)
            local Fill = Instance.new("Frame"); Fill.BorderSizePixel = 0; Th(Fill, "BackgroundColor3", "Accent"); Fill.Parent = Bar; Corner(Fill, 4)
            local Kn = Instance.new("Frame"); Kn.AnchorPoint = Vector2.new(.5, .5); Kn.Position = UDim2.fromScale(1, .5)
            Kn.Size = UDim2.fromOffset(16, 16); Kn.BorderSizePixel = 0; Kn.BackgroundColor3 = Color3.new(1, 1, 1); Kn.Parent = Fill
            Corner(Kn, 8); Stroke(Kn, "Accent", 2)
            local function Visual(anim)
                VL.Text = Fmt(value)
                Tw(Fill, { Size = UDim2.new((value - min) / (max - min), 0, 1, 0) }, anim and .15 or 0)
            end
            Visual(false); SetFlag(flag, value, true)
            local function Norm(v)
                v = min + math.floor((v - min) / inc + .5) * inc
                v = math.clamp(v, min, max)
                return tonumber(string.format("%." .. dec .. "f", v)) or v
            end
            local ctrl = {}
            function ctrl:Set(v, silent)
                v = Norm(tonumber(v) or min)
                local changed = v ~= value
                value = v; Visual(true); SetFlag(flag, value)
                if changed and not silent then task.spawn(Safe, c.Callback, value) end
            end
            function ctrl:Get() return value end
            PointerDrag(Hit, Page, function(pos)
                local a = math.clamp((pos.X - Hit.AbsolutePosition.X) / math.max(1, Hit.AbsoluteSize.X), 0, 1)
                local v = Norm(min + (max - min) * a)
                if v ~= value then
                    value = v; Visual(false); SetFlag(flag, value)
                    task.spawn(Safe, c.Callback, value)
                end
            end)
            Reg(flag, ctrl, c)
            return ctrl
        end

        -- ===== Input =====
        function Tab:CreateInput(c)
            c = c or {}
            local flag = c.Flag or c.Name or "Input"
            local F = Base(c, { rightW = 160 })
            local TB = Instance.new("TextBox"); TB.AnchorPoint = Vector2.new(1, .5); TB.Position = UDim2.new(1, -8, .5, 0)
            TB.Size = UDim2.fromOffset(148, 26); TB.BorderSizePixel = 0; TB.Text = c.Default or ""; TB.TextSize = 12; TB.Font = FONT
            TB.PlaceholderText = c.Placeholder or "Enter..."; TB.ClearTextOnFocus = false; TB.TextTruncate = Enum.TextTruncate.AtEnd
            Th(TB, "BackgroundColor3", "Sidebar"); Th(TB, "TextColor3", "Text"); Th(TB, "PlaceholderColor3", "SubText")
            TB.Parent = F; Corner(TB, 6); Stroke(TB, "Stroke", 1)
            SetFlag(flag, TB.Text, true)
            local ctrl = {}
            function ctrl:Set(t, silent)
                t = tostring(t); TB.Text = t; SetFlag(flag, t)
                if not silent then task.spawn(Safe, c.Callback, t) end
            end
            function ctrl:Get() return TB.Text end
            Conn(TB.FocusLost, function()
                local t = TB.Text
                if c.NumbersOnly then t = tostring(tonumber(t) or ""); TB.Text = t end
                SetFlag(flag, t); task.spawn(Safe, c.Callback, t)
                if c.RemoveTextAfterFocusLost then TB.Text = "" end
            end)
            Reg(flag, ctrl, c)
            return ctrl
        end

        -- ===== Dropdown (single / multi / refresh) =====
        function Tab:CreateDropdown(c)
            c = c or {}
            order += 1
            local nm = c.Name or "Dropdown"
            local flag = c.Flag or nm
            local options = c.Options or {}
            local multi = c.Multi == true
            local selected, current = {}, nil
            if multi then for _, v in ipairs(type(c.Default) == "table" and c.Default or {}) do selected[v] = true end
            else current = c.Default or options[1] end

            local Cont = Instance.new("Frame"); Cont.Name = nm; Cont.Size = UDim2.new(1, 0, 0, 38); Cont.ClipsDescendants = true
            Cont.BorderSizePixel = 0; Cont.LayoutOrder = order; Th(Cont, "BackgroundColor3", "Card"); Cont.Parent = Page
            Corner(Cont, 8); Stroke(Cont, "Stroke", 1)
            Win.Elements[#Win.Elements + 1] = { Frame = Cont, Key = string.lower(nm) }
            local Head = Instance.new("TextButton"); Head.BackgroundTransparency = 1; Head.Text = ""; Head.Size = UDim2.new(1, 0, 0, 38); Head.Parent = Cont
            local NL = Label(Head, nm, 13, "Text", FONT); NL.Position = UDim2.fromOffset(12, 0); NL.Size = UDim2.new(.5, -12, 1, 0)
            local VL = Label(Head, "", 12, "Accent", FONTB, Enum.TextXAlignment.Right); VL.AnchorPoint = Vector2.new(1, .5)
            VL.Position = UDim2.new(1, -30, .5, 0); VL.Size = UDim2.new(.5, -40, 1, 0)
            local Ar = Label(Head, "▼", 10, "SubText", FONT, Enum.TextXAlignment.Center); Ar.AnchorPoint = Vector2.new(1, .5)
            Ar.Position = UDim2.new(1, -8, .5, 0); Ar.Size = UDim2.fromOffset(18, 18)
            local List = Instance.new("ScrollingFrame"); List.BackgroundTransparency = 1; List.BorderSizePixel = 0
            List.Position = UDim2.fromOffset(8, 42); List.ScrollBarThickness = 2; List.CanvasSize = UDim2.new()
            List.AutomaticCanvasSize = Enum.AutomaticSize.Y; Th(List, "ScrollBarImageColor3", "Accent"); List.Parent = Cont
            local LL = Instance.new("UIListLayout"); LL.Padding = UDim.new(0, 3); LL.SortOrder = Enum.SortOrder.LayoutOrder; LL.Parent = List

            local open, btns = false, {}
            local function ListH() return math.min(#options, 5) * 31 end
            local function OpenH() return 38 + 4 + ListH() + 8 end
            local function Resize() List.Size = UDim2.new(1, -16, 0, ListH()); if open then Tw(Cont, { Size = UDim2.new(1, 0, 0, OpenH()) }, .2) end end
            local function Display()
                if multi then
                    local t = {}; for _, o in ipairs(options) do if selected[o] then t[#t + 1] = tostring(o) end end
                    VL.Text = #t > 0 and table.concat(t, ", ") or "None"
                else VL.Text = current ~= nil and tostring(current) or "None" end
            end
            local function Value()
                if multi then local t = {}; for _, o in ipairs(options) do if selected[o] then t[#t + 1] = o end end return t end
                return current
            end
            local function PaintOpts()
                for o, b in pairs(btns) do
                    local on = multi and selected[o] or (not multi and current == o)
                    Tw(b, { BackgroundColor3 = on and T.Accent or T.Sidebar, TextColor3 = on and Color3.new(1, 1, 1) or T.SubText }, .15)
                end
            end
            local ctrl = {}
            local function Fire(silent)
                SetFlag(flag, Value()); Display(); PaintOpts()
                if not silent then task.spawn(Safe, c.Callback, Value()) end
            end
            local function Build()
                for _, ch in ipairs(List:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
                btns = {}
                for i, o in ipairs(options) do
                    local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 28); b.BorderSizePixel = 0; b.LayoutOrder = i
                    b.AutoButtonColor = false; b.Text = tostring(o); b.TextSize = 12; b.Font = FONT
                    b.TextXAlignment = Align(tostring(o)); Pad(b, 10, 0, 10, 0)
                    b.BackgroundColor3 = T.Sidebar; b.TextColor3 = T.SubText; b.Parent = List; Corner(b, 6)
                    btns[o] = b
                    b.Activated:Connect(function()
                        if multi then selected[o] = not selected[o] or nil
                        else current = o; open = false; Ar.Text = "▼"; Tw(Cont, { Size = UDim2.new(1, 0, 0, 38) }, .2) end
                        Fire(false)
                    end)
                end
                Resize(); Display(); PaintOpts()
            end
            Build(); Hook(PaintOpts)
            SetFlag(flag, Value(), true)
            Head.Activated:Connect(function()
                open = not open; Ar.Text = open and "▲" or "▼"
                Tw(Cont, { Size = UDim2.new(1, 0, 0, open and OpenH() or 38) }, .2)
            end)
            function ctrl:Set(v, silent)
                if multi then
                    selected = {}; for _, x in ipairs(type(v) == "table" and v or { v }) do selected[x] = true end
                else current = v end
                Fire(silent)
            end
            function ctrl:Get() return Value() end
            function ctrl:Refresh(newOpts, keep)
                options = newOpts or {}
                if keep then
                    if multi then for k in pairs(selected) do if not table.find(options, k) then selected[k] = nil end end
                    elseif not table.find(options, current) then current = options[1] end
                else selected = {}; current = options[1] end
                Build(); SetFlag(flag, Value())
            end
            Reg(flag, ctrl, c)
            return ctrl
        end

        -- ===== Keybind (Toggle / Hold) =====
        function Tab:CreateKeybind(c)
            c = c or {}
            local flag = c.Flag or c.Name or "Keybind"
            local touch = UIS.TouchEnabled
            local F = Base(c, { rightW = touch and 150 or 124 })
            local def = c.Default or "E"
            local key = typeof(def) == "EnumItem" and def.Name or tostring(def)
            local mode = c.Mode == "Hold" and "Hold" or "Toggle"
            local listening, holding, on = false, false, false

            local function SmallBtn(txt, w, x)
                local b = Instance.new("TextButton"); b.AnchorPoint = Vector2.new(1, .5); b.Position = UDim2.new(1, x, .5, 0)
                b.Size = UDim2.fromOffset(w, 26); b.Text = txt; b.TextSize = 11; b.Font = FONTB; b.AutoButtonColor = false
                b.BorderSizePixel = 0; Th(b, "BackgroundColor3", "Sidebar"); Th(b, "TextColor3", "Accent"); b.Parent = F; Corner(b, 6)
                return b
            end
            local KB = SmallBtn(key, 60, -8)
            local MB = SmallBtn(mode == "Toggle" and "TG" or "HD", 32, -74)
            if touch then
                local RB = SmallBtn("▶", 28, -112)
                RB.Activated:Connect(function() on = not on; task.spawn(Safe, c.Callback, on, key) end)
            end
            SetFlag(flag, { Key = key, Mode = mode }, true)
            local function Store() SetFlag(flag, { Key = key, Mode = mode }) end
            MB.Activated:Connect(function()
                mode = mode == "Toggle" and "Hold" or "Toggle"; MB.Text = mode == "Toggle" and "TG" or "HD"; Store()
                Win:Notify({ Title = "Keybind", Content = (c.Name or "Keybind") .. ": " .. mode, Duration = 1.5 })
            end)
            KB.Activated:Connect(function() listening = true; KB.Text = "..." end)
            Conn(UIS.InputBegan, function(i, gpe)
                if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if listening then
                    listening = false
                    if i.KeyCode == Enum.KeyCode.Escape then -- cancel
                    elseif i.KeyCode == Enum.KeyCode.Backspace then key = "None"
                    else key = i.KeyCode.Name end
                    KB.Text = key; Store(); return
                end
                if gpe or key == "None" or i.KeyCode.Name ~= key then return end
                if mode == "Toggle" then on = not on; task.spawn(Safe, c.Callback, on, key)
                elseif not holding then holding = true; task.spawn(Safe, c.Callback, true, key) end
            end)
            Conn(UIS.InputEnded, function(i)
                if mode == "Hold" and holding and i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name == key then
                    holding = false; task.spawn(Safe, c.Callback, false, key)
                end
            end)
            local ctrl = {}
            function ctrl:Set(v)
                if type(v) == "table" then key = tostring(v.Key or key); mode = v.Mode == "Hold" and "Hold" or "Toggle"
                else key = typeof(v) == "EnumItem" and v.Name or tostring(v) end
                KB.Text = key; MB.Text = mode == "Toggle" and "TG" or "HD"; Store()
            end
            function ctrl:Get() return key, mode end
            Reg(flag, ctrl, c)
            return ctrl
        end

        -- ===== Color picker (HSV) =====
        function Tab:CreateColorPicker(c)
            c = c or {}
            order += 1
            local nm = c.Name or "Color"
            local flag = c.Flag or nm
            local color = c.Default or T.Accent
            local h, s, v = color:ToHSV()
            local open = false
            local Cont = Instance.new("Frame"); Cont.Name = nm; Cont.Size = UDim2.new(1, 0, 0, 38); Cont.ClipsDescendants = true
            Cont.BorderSizePixel = 0; Cont.LayoutOrder = order; Th(Cont, "BackgroundColor3", "Card"); Cont.Parent = Page
            Corner(Cont, 8); Stroke(Cont, "Stroke", 1)
            Win.Elements[#Win.Elements + 1] = { Frame = Cont, Key = string.lower(nm) }
            local Head = Instance.new("TextButton"); Head.BackgroundTransparency = 1; Head.Text = ""; Head.Size = UDim2.new(1, 0, 0, 38); Head.Parent = Cont
            local NL = Label(Head, nm, 13, "Text", FONT); NL.Position = UDim2.fromOffset(12, 0); NL.Size = UDim2.new(1, -110, 1, 0)
            local Hex = Label(Head, "", 11, "SubText", FONT, Enum.TextXAlignment.Right); Hex.AnchorPoint = Vector2.new(1, .5)
            Hex.Position = UDim2.new(1, -46, .5, 0); Hex.Size = UDim2.fromOffset(60, 18)
            local Prev = Instance.new("Frame"); Prev.AnchorPoint = Vector2.new(1, .5); Prev.Position = UDim2.new(1, -10, .5, 0)
            Prev.Size = UDim2.fromOffset(30, 20); Prev.BorderSizePixel = 0; Prev.Parent = Head; Corner(Prev, 6); Stroke(Prev, "Stroke", 1)

            local SV = Instance.new("Frame"); SV.Position = UDim2.fromOffset(10, 44); SV.Size = UDim2.new(1, -20, 0, 90)
            SV.BorderSizePixel = 0; SV.ClipsDescendants = true; SV.Parent = Cont; Corner(SV, 6)
            local White = Instance.new("Frame"); White.Size = UDim2.fromScale(1, 1); White.BorderSizePixel = 0
            White.BackgroundColor3 = Color3.new(1, 1, 1); White.Parent = SV
            local g1 = Instance.new("UIGradient"); g1.Transparency = NumberSequence.new(0, 1); g1.Parent = White
            local Black = Instance.new("Frame"); Black.Size = UDim2.fromScale(1, 1); Black.BorderSizePixel = 0
            Black.BackgroundColor3 = Color3.new(0, 0, 0); Black.Parent = SV
            local g2 = Instance.new("UIGradient"); g2.Rotation = 90; g2.Transparency = NumberSequence.new(1, 0); g2.Parent = Black
            local SVC = Instance.new("Frame"); SVC.AnchorPoint = Vector2.new(.5, .5); SVC.Size = UDim2.fromOffset(12, 12)
            SVC.BackgroundTransparency = 1; SVC.Parent = SV; Corner(SVC, 6)
            local cs = Instance.new("UIStroke"); cs.Color = Color3.new(1, 1, 1); cs.Thickness = 2; cs.Parent = SVC

            local HB = Instance.new("Frame"); HB.Position = UDim2.fromOffset(10, 142); HB.Size = UDim2.new(1, -20, 0, 14)
            HB.BorderSizePixel = 0; HB.BackgroundColor3 = Color3.new(1, 1, 1); HB.Parent = Cont; Corner(HB, 7)
            local hg = Instance.new("UIGradient"); hg.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(.167, Color3.fromHSV(.167, 1, 1)),
                ColorSequenceKeypoint.new(.333, Color3.fromHSV(.333, 1, 1)), ColorSequenceKeypoint.new(.5, Color3.fromHSV(.5, 1, 1)),
                ColorSequenceKeypoint.new(.667, Color3.fromHSV(.667, 1, 1)), ColorSequenceKeypoint.new(.833, Color3.fromHSV(.833, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)) }); hg.Parent = HB
            local HC = Instance.new("Frame"); HC.AnchorPoint = Vector2.new(.5, .5); HC.Size = UDim2.fromOffset(6, 20)
            HC.BackgroundColor3 = Color3.new(1, 1, 1); HC.BorderSizePixel = 0; HC.Parent = HB; Corner(HC, 3)
            local hs = Instance.new("UIStroke"); hs.Color = Color3.new(0, 0, 0); hs.Transparency = .5; hs.Parent = HC

            local function Visual()
                color = Color3.fromHSV(h, s, v)
                Prev.BackgroundColor3 = color; SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                SVC.Position = UDim2.fromScale(s, 1 - v); HC.Position = UDim2.fromScale(h, .5)
                Hex.Text = "#" .. color:ToHex():upper()
            end
            Visual(); SetFlag(flag, color, true)
            local function Fire(silent) Visual(); SetFlag(flag, color); if not silent then task.spawn(Safe, c.Callback, color) end end
            PointerDrag(SV, Page, function(p)
                s = math.clamp((p.X - SV.AbsolutePosition.X) / math.max(1, SV.AbsoluteSize.X), 0, 1)
                v = 1 - math.clamp((p.Y - SV.AbsolutePosition.Y) / math.max(1, SV.AbsoluteSize.Y), 0, 1); Fire(false)
            end)
            PointerDrag(HB, Page, function(p)
                h = math.clamp((p.X - HB.AbsolutePosition.X) / math.max(1, HB.AbsoluteSize.X), 0, 1); Fire(false)
            end)
            Head.Activated:Connect(function() open = not open; Tw(Cont, { Size = UDim2.new(1, 0, 0, open and 168 or 38) }, .2) end)
            local ctrl = {}
            function ctrl:Set(col, silent)
                if typeof(col) ~= "Color3" then return end
                h, s, v = col:ToHSV(); Fire(silent)
            end
            function ctrl:Get() return color end
            Reg(flag, ctrl, c)
            return ctrl
        end

        -- ===== Ready-made settings block =====
        function Tab:CreateConfigSection()
            Tab:CreateSection("Settings  |  الإعدادات")
            local slot = "Slot1"
            Tab:CreateDropdown({ Name = "Config Slot | الحافظة", Options = { "Slot1", "Slot2", "Slot3" }, Default = "Slot1",
                NoSave = true, Callback = function(x) slot = x end })
            Tab:CreateButton({ Name = "Save Config | حفظ", Desc = "Save current settings to the selected slot.", Callback = function() Win:SaveConfig(slot) end })
            Tab:CreateButton({ Name = "Load Config | استرجاع", Desc = "Load settings from the selected slot.", Callback = function() Win:LoadConfig(slot) end })
            Tab:CreateButton({ Name = "Delete Config | حذف", Callback = function() Win:DeleteConfig(slot) end })
            local names = {}; for k in pairs(Themes) do names[#names + 1] = k end; table.sort(names)
            Tab:CreateDropdown({ Name = "Theme | المظهر", Options = names, Default = cfg.Theme or "Dark", NoSave = false,
                Flag = "__Theme", Callback = function(x) Win:SetTheme(x) end })
            Tab:CreateButton({ Name = "Destroy UI | إغلاق", Callback = function() Win:Destroy() end })
        end

        Win.Tabs[#Win.Tabs + 1] = Tab
        return Tab
    end

    -- ---------- Loader ----------
    local Loader = Instance.new("CanvasGroup"); Loader.AnchorPoint = Vector2.new(.5, .5); Loader.Position = UDim2.fromScale(.5, .5)
    Loader.Size = UDim2.fromOffset(280, 92); Loader.BorderSizePixel = 0; Th(Loader, "BackgroundColor3", "Background"); Loader.Parent = Gui
    Corner(Loader, 14); Stroke(Loader, "Accent", 1.5)
    local lt = Label(Loader, cfg.LoadingTitle or Title, 16, "Text", FONTB, Enum.TextXAlignment.Center); lt.Position = UDim2.fromOffset(10, 14); lt.Size = UDim2.new(1, -20, 0, 22)
    local ls = Label(Loader, cfg.LoadingSubtitle or "Loading...", 11, "SubText", FONT, Enum.TextXAlignment.Center); ls.Position = UDim2.fromOffset(10, 38); ls.Size = UDim2.new(1, -20, 0, 16)
    local Track = Instance.new("Frame"); Track.Position = UDim2.fromOffset(20, 66); Track.Size = UDim2.new(1, -40, 0, 6); Track.BorderSizePixel = 0
    Th(Track, "BackgroundColor3", "SwitchOff"); Track.Parent = Loader; Corner(Track, 3)
    local LF = Instance.new("Frame"); LF.Size = UDim2.fromScale(0, 1); LF.BorderSizePixel = 0; Th(LF, "BackgroundColor3", "Accent"); LF.Parent = Track; Corner(LF, 3)
    Tw(LF, { Size = UDim2.fromScale(1, 1) }, .7, Enum.EasingStyle.Quad)

    local finished = false
    function Win:Ready()
        if finished or not Win.Alive then return end
        finished = true
        Tw(Loader, { GroupTransparency = 1 }, .25)
        task.delay(.28, function() Loader:Destroy() end)
        if showBtn then MT.Visible = true end
        Win:SetVisible(true)
        if CS.Enabled and CS.AutoLoad ~= false then Win:LoadConfig(CS.FileName or "Auto", true) end
    end
    task.delay(.85, function() Win:Ready() end)

    function Win:Destroy()
        if not Win.Alive then return end
        Win.Alive = false
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        for i, w in ipairs(Lib._wins) do if w == Win then table.remove(Lib._wins, i) break end end
        Bound, Hooks = {}, {}
        pcall(function() Gui:Destroy() end)
        pcall(function() local g = getgenv(); if g.__AuraLuxe == Win then g.__AuraLuxe = nil end end)
    end

    Lib._wins[#Lib._wins + 1] = Win
    return Win
end

return Lib

--[[ ---------------------------- EXAMPLE ----------------------------
local Aura = loadstring(game:HttpGet("YOUR_RAW_URL"))()
local Win = Aura:CreateWindow({
    Title = "My Hub", Subtitle = "v1.0", Theme = "Dark", ToggleUIKeybind = "RightShift",
    ConfigurationSaving = { Enabled = true, FolderName = "MyHub", FileName = "Auto" }, -- autosave + autoload
    -- KeySystem = { Key = {"abc123"}, SaveKey = true, Note = "Get key from our server" },
})
local Main = Win:CreateTab("Main")
Main:CreateSection("Player")
Main:CreateToggle({ Name = "Speed", Desc = "Boost walk speed", Callback = function(on) end })
Main:CreateSlider({ Name = "WalkSpeed", Min = 16, Max = 200, Default = 16, Suffix = " st", Callback = function(v) end })
Main:CreateDropdown({ Name = "Targets", Options = {"A","B","C"}, Multi = true, Callback = function(list) end })
Main:CreateColorPicker({ Name = "ESP Color", Default = Color3.fromRGB(255,0,0), Callback = function(c) end })
Main:CreateKeybind({ Name = "Fly", Default = "F", Mode = "Toggle", Callback = function(on) end })
Win:CreateTab("Settings"):CreateConfigSection()
Win:CreateWatermark("My Hub")
Win:Notify({ Title = "Loaded", Content = "Welcome!", Type = "Success" })
------------------------------------------------------------------- ]]
