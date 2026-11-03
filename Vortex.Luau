--[[ ======================================================================
    AURA LUXE v4.2  |  Apex Mobile Edition (Delta / Codex / Arceus 2026)
    - Full Original Feature-Set Restored (HSV Picker, Keybinds, KeyGate, Configs)
    - 99% Screen Blur + High-Speed Blinking Neon White Loader
    - Stepped Loading: 30% (0.5s) -> 30% (0.4s) -> 40% (0.6s) with "" targets
    - 0.54334s Drop Animation (Top to Center) at Maximum Refresh Rate
    - Compact Sizing + Near-Sharp Corners (3px) + Seamless Borders
    - Anti-Jump Relative Drag Engine (Touch & Mouse Certified)
    - NEW: DynamicLabel, PlayerCard, PlayerList, SubTabs, ProgressBar,
           TextArea, ImageButton, CustomFrame, Multi/Search Dropdown,
           Resizable Window, Suffix/Increment Sliders, Image/Type Notifications,
           Unified API (Set, Get, SetVisible, Destroy, SetText, SetImage).
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
local Lighting    = Svc("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ======================= Themes =======================
local Themes = {
    Dark = {
        Background = Color3.fromRGB(12, 12, 15), Header = Color3.fromRGB(16, 16, 20),
        Sidebar = Color3.fromRGB(10, 10, 13), Card = Color3.fromRGB(18, 18, 22),
        CardHover = Color3.fromRGB(24, 24, 30), Stroke = Color3.fromRGB(14, 14, 18),
        Accent = Color3.fromRGB(99, 102, 241), Accent2 = Color3.fromRGB(139, 92, 246),
        Text = Color3.fromRGB(245, 245, 248), SubText = Color3.fromRGB(135, 140, 150),
        Success = Color3.fromRGB(52, 211, 153), Danger = Color3.fromRGB(239, 68, 68),
        Warn = Color3.fromRGB(245, 158, 11), SwitchOff = Color3.fromRGB(30, 30, 36),
    },
    Ocean = {
        Background = Color3.fromRGB(8, 14, 22), Header = Color3.fromRGB(12, 20, 32),
        Sidebar = Color3.fromRGB(6, 11, 18), Card = Color3.fromRGB(14, 24, 38),
        CardHover = Color3.fromRGB(20, 34, 52), Stroke = Color3.fromRGB(10, 16, 26),
        Accent = Color3.fromRGB(14, 165, 233), Accent2 = Color3.fromRGB(20, 184, 166),
        Text = Color3.fromRGB(240, 248, 255), SubText = Color3.fromRGB(130, 150, 175),
        Success = Color3.fromRGB(52, 211, 153), Danger = Color3.fromRGB(239, 68, 68),
        Warn = Color3.fromRGB(245, 158, 11), SwitchOff = Color3.fromRGB(26, 42, 64),
    },
    Rose = {
        Background = Color3.fromRGB(18, 12, 15), Header = Color3.fromRGB(26, 16, 21),
        Sidebar = Color3.fromRGB(14, 9, 12), Card = Color3.fromRGB(30, 18, 24),
        CardHover = Color3.fromRGB(42, 24, 34), Stroke = Color3.fromRGB(20, 13, 17),
        Accent = Color3.fromRGB(244, 63, 94), Accent2 = Color3.fromRGB(251, 146, 60),
        Text = Color3.fromRGB(255, 242, 245), SubText = Color3.fromRGB(175, 135, 145),
        Success = Color3.fromRGB(52, 211, 153), Danger = Color3.fromRGB(239, 68, 68),
        Warn = Color3.fromRGB(245, 158, 11), SwitchOff = Color3.fromRGB(55, 34, 44),
    },
    Emerald = {
        Background = Color3.fromRGB(9, 16, 14), Header = Color3.fromRGB(13, 24, 20),
        Sidebar = Color3.fromRGB(7, 12, 11), Card = Color3.fromRGB(16, 28, 24),
        CardHover = Color3.fromRGB(22, 38, 32), Stroke = Color3.fromRGB(11, 18, 16),
        Accent = Color3.fromRGB(16, 185, 129), Accent2 = Color3.fromRGB(132, 204, 22),
        Text = Color3.fromRGB(240, 253, 245), SubText = Color3.fromRGB(130, 160, 145),
        Success = Color3.fromRGB(52, 211, 153), Danger = Color3.fromRGB(239, 68, 68),
        Warn = Color3.fromRGB(245, 158, 11), SwitchOff = Color3.fromRGB(30, 50, 44),
    },
    Onyx = {
        Background = Color3.fromRGB(8, 8, 10), Header = Color3.fromRGB(12, 12, 14),
        Sidebar = Color3.fromRGB(6, 6, 8), Card = Color3.fromRGB(15, 15, 18),
        CardHover = Color3.fromRGB(22, 22, 26), Stroke = Color3.fromRGB(10, 10, 12),
        Accent = Color3.fromRGB(255, 255, 255), Accent2 = Color3.fromRGB(180, 180, 190),
        Text = Color3.fromRGB(255, 255, 255), SubText = Color3.fromRGB(130, 130, 135),
        Success = Color3.fromRGB(50, 200, 120), Danger = Color3.fromRGB(230, 60, 60),
        Warn = Color3.fromRGB(240, 160, 20), SwitchOff = Color3.fromRGB(25, 25, 30),
    },
    Light = {
        Background = Color3.fromRGB(240, 242, 247), Header = Color3.fromRGB(255, 255, 255),
        Sidebar = Color3.fromRGB(228, 232, 240), Card = Color3.fromRGB(255, 255, 255),
        CardHover = Color3.fromRGB(236, 240, 247), Stroke = Color3.fromRGB(220, 224, 232),
        Accent = Color3.fromRGB(79, 70, 229), Accent2 = Color3.fromRGB(147, 51, 234),
        Text = Color3.fromRGB(20, 24, 35), SubText = Color3.fromRGB(100, 112, 134),
        Success = Color3.fromRGB(16, 185, 129), Danger = Color3.fromRGB(239, 68, 68),
        Warn = Color3.fromRGB(245, 158, 11), SwitchOff = Color3.fromRGB(200, 206, 220),
    }
}

local T = {}
local Bound, Hooks = {}, {}
for k, v in pairs(Themes.Dark) do T[k] = v end

local FONT, FONTB = Enum.Font.GothamMedium, Enum.Font.GothamBold
local Lib = { Version = "4.2", Flags = {}, Registry = {}, NoSave = {}, Themes = Themes, _wins = {} }

-- ======================= Core Helpers =======================
local function Th(inst, prop, key) inst[prop] = T[key]; Bound[#Bound + 1] = { inst, prop, key } end
local function Hook(fn) Hooks[#Hooks + 1] = fn; return fn end

local function Tw(o, p, t, s, d)
    if not t or t <= 0 then for k, v in pairs(p) do o[k] = v end return end
    local tw = TweenService:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out), p)
    tw:Play()
    return tw
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 3)
    c.Parent = p
    return c
end

local function Stroke(p, key, th)
    local s = Instance.new("UIStroke")
    s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Th(s, "Color", key or "Stroke")
    s.Parent = p
    return s
end

local function Pad(p, l, t, r, b)
    local u = Instance.new("UIPadding")
    u.PaddingLeft = UDim.new(0, l); u.PaddingTop = UDim.new(0, t)
    u.PaddingRight = UDim.new(0, r); u.PaddingBottom = UDim.new(0, b)
    u.Parent = p
    return u
end

local function IsArabic(s)
    if typeof(s) ~= "string" then return false end
    return s:find("[\216-\219\221]") ~= nil or s:find("\239[\173-\187]") ~= nil
end
local function Align(s) return IsArabic(s) and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left end

local function Safe(cb, ...)
    if typeof(cb) ~= "function" then return end
    local ok, err = pcall(cb, ...)
    if not ok then warn("[AuraLuxe] Error: " .. tostring(err)) end
end

local function IsPointer(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function IsMove(i)
    return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local function Label(parent, text, size, key, font, x)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1; l.Text = text or ""; l.TextSize = size or 11
    l.Font = font or FONT; Th(l, "TextColor3", key or "Text")
    l.TextXAlignment = x or Align(text); l.TextTruncate = Enum.TextTruncate.AtEnd
    l.RichText = true
    l.Parent = parent
    return l
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
        if b[1].Parent then Tw(b[1], { [b[2]] = T[b[3]] }, anim == false and 0 or 0.2) end
    end
    for _, h in ipairs(Hooks) do pcall(h) end
    return true
end

-- ======================= Config Handlers =======================
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

-- ======================= KeyGate System =======================
local function KeyGate(ks, parent)
    local keys = type(ks.Key) == "table" and ks.Key or { ks.Key }
    local file = ks.SaveKey and (ks.FileName or "AuraLuxe/key.txt")
    local function valid(k)
        for _, v in ipairs(keys) do if tostring(k) == tostring(v) then return true end end
        return false
    end
    if file and isfile and readfile then
        local ok, s = pcall(function() return isfile(file) and readfile(file) end)
        if ok and s and valid(s) then return true end
    end

    local g = Instance.new("ScreenGui"); g.ResetOnSpawn = false; g.IgnoreGuiInset = true
    g.DisplayOrder = 10000; g.Parent = parent

    local F = Instance.new("Frame"); F.AnchorPoint = Vector2.new(.5, .5); F.Position = UDim2.fromScale(.5, .5)
    F.Size = UDim2.fromOffset(300, 175); F.BorderSizePixel = 0; Th(F, "BackgroundColor3", "Background")
    F.Parent = g; Corner(F, 3); Stroke(F, "Stroke", 1)

    local t = Label(F, ks.Title or "Key Verification", 13, "Text", FONTB)
    t.Position = UDim2.fromOffset(12, 10); t.Size = UDim2.new(1, -24, 0, 18)

    local n = Label(F, ks.Note or "Enter valid key to proceed.", 10, "SubText")
    n.Position = UDim2.fromOffset(12, 30); n.Size = UDim2.new(1, -24, 0, 16)

    local box = Instance.new("TextBox")
    box.Position = UDim2.fromOffset(12, 54); box.Size = UDim2.new(1, -24, 0, 30)
    box.PlaceholderText = "Paste key..."; box.Text = ""; box.TextSize = 11; box.Font = FONT
    box.ClearTextOnFocus = false
    Th(box, "BackgroundColor3", "Card"); Th(box, "TextColor3", "Text"); Th(box, "PlaceholderColor3", "SubText")
    box.Parent = F; Corner(box, 3); Stroke(box, "Stroke", 1); Pad(box, 8, 0, 8, 0)

    local btn = Instance.new("TextButton")
    btn.Position = UDim2.fromOffset(12, 94); btn.Size = UDim2.new(1, -24, 0, 32)
    btn.Text = "Unlock"; btn.TextSize = 12; btn.Font = FONTB; btn.AutoButtonColor = false
    Th(btn, "BackgroundColor3", "Accent"); btn.TextColor3 = Color3.new(1, 1, 1); btn.Parent = F; Corner(btn, 3)

    local st = Label(F, "", 10, "Danger", FONT, Enum.TextXAlignment.Center)
    st.Position = UDim2.fromOffset(12, 136); st.Size = UDim2.new(1, -24, 0, 16)

    local result
    btn.Activated:Connect(function()
        if valid(box.Text) then
            result = true
            if file and writefile then pcall(function()
                if makefolder and not isfolder("AuraLuxe") then makefolder("AuraLuxe") end
                writefile(file, box.Text)
            end) end
        else
            st.Text = "Invalid key, try again."
        end
    end)

    while result == nil and g.Parent do task.wait(0.1) end
    g:Destroy()
    return result == true
end

-- ======================= Main Window =======================
function Lib:GetFlag(n) return self.Flags[n] end
function Lib:SetFlag(n, v) if self.Registry[n] then self.Registry[n](v) else self.Flags[n] = v end end
function Lib:Notify(cfg) local w = self._wins[#self._wins]; if w then return w:Notify(cfg) end end
function Lib:Destroy() for i = #self._wins, 1, -1 do self._wins[i]:Destroy() end end
function Lib:SetTheme(n) return ApplyTheme(n) end

function Lib:CreateWindow(cfg)
    cfg = cfg or {}
    pcall(function() local g = getgenv(); if g.__AuraLuxe then g.__AuraLuxe:Destroy() end end)

    if cfg.Theme then ApplyTheme(cfg.Theme, false) end
    Lib.Flags, Lib.Registry, Lib.NoSave = {}, {}, {}

    local Parent = SafeParent()
    if cfg.KeySystem and not KeyGate(cfg.KeySystem, Parent) then return nil end

    local Title = cfg.Title or "AURA LUXE"
    local Subtitle = cfg.Subtitle or "Apex v4.2"
    local W, H = 500, 305
    if type(cfg.Size) == "table" then W, H = cfg.Size[1] or W, cfg.Size[2] or H end
    local PAGE_W = W - 140 - 8
    local CS = cfg.ConfigurationSaving or {}
    local Win = { Visible = true, Elements = {}, Tabs = {}, Current = nil, Alive = true, _loading = false }
    local conns = {}
    local function Conn(sig, fn) local c = sig:Connect(fn); conns[#conns + 1] = c; return c end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "Aura_" .. HttpService:GenerateGUID(false):sub(1, 8)
    Gui.ResetOnSpawn = false; Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.IgnoreGuiInset = true; Gui.DisplayOrder = 2147483000
    if syn and syn.protect_gui then pcall(syn.protect_gui, Gui) end
    Gui.Parent = Parent
    Win.Gui = Gui
    pcall(function() getgenv().__AuraLuxe = Win end)

    -- Responsive UIScale Engine
    local function Fit()
        local cam = Workspace.CurrentCamera
        local a = cam and cam.ViewportSize or Gui.AbsoluteSize
        if a.X <= 0 then return 1 end
        return math.clamp(math.min(a.X * 0.94 / W, a.Y * 0.9 / H), 0.52, 1) * (cfg.Scale or 1)
    end

    -- ========== Screen Blur (99%) + Dimmer ==========
    local Blur = Instance.new("BlurEffect")
    Blur.Name = "Aura_Blur"; Blur.Size = 56; Blur.Parent = Lighting

    local Dimmer = Instance.new("Frame")
    Dimmer.Size = UDim2.fromScale(1, 1); Dimmer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Dimmer.BackgroundTransparency = 0.35; Dimmer.BorderSizePixel = 0; Dimmer.ZIndex = 1000; Dimmer.Parent = Gui

    -- ========== Neon White Stepped Loader ==========
    local LoadHolder = Instance.new("Frame")
    LoadHolder.AnchorPoint = Vector2.new(.5, .5); LoadHolder.Position = UDim2.fromScale(.5, .5)
    LoadHolder.Size = UDim2.fromOffset(320, 85); LoadHolder.BackgroundTransparency = 1; LoadHolder.ZIndex = 1001; LoadHolder.Parent = Gui

    local NeonLoading = Instance.new("TextLabel")
    NeonLoading.Size = UDim2.new(1, 0, 0, 32); NeonLoading.BackgroundTransparency = 1
    NeonLoading.Font = FONTB; NeonLoading.TextSize = 22; NeonLoading.TextColor3 = Color3.fromRGB(255, 255, 255)
    NeonLoading.RichText = true; NeonLoading.Text = '<stroke color="#FFFFFF" thickness="1.2">Loading</stroke>'
    NeonLoading.Parent = LoadHolder

    local StageLabel = Instance.new("TextLabel")
    StageLabel.Position = UDim2.fromOffset(0, 36); StageLabel.Size = UDim2.new(1, 0, 0, 20)
    StageLabel.BackgroundTransparency = 1; StageLabel.Font = FONT; StageLabel.TextSize = 13
    StageLabel.TextColor3 = Color3.fromRGB(215, 220, 235); StageLabel.RichText = true
    StageLabel.Text = 'Initializing ""'; StageLabel.Parent = LoadHolder

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Position = UDim2.fromOffset(36, 66); ProgressBar.Size = UDim2.new(1, -72, 0, 3)
    ProgressBar.BorderSizePixel = 0; ProgressBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30); ProgressBar.Parent = LoadHolder
    Corner(ProgressBar, 2)

    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size = UDim2.fromScale(0, 1); ProgressFill.BorderSizePixel = 0
    ProgressFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ProgressFill.Parent = ProgressBar; Corner(ProgressFill, 2)

    local dotsRunning = true
    task.spawn(function()
        local dots = {"", ".", "..", "..."}
        local dIdx = 1
        while dotsRunning and Gui.Parent do
            NeonLoading.Text = string.format('<stroke color="#FFFFFF" thickness="1.2">Loading%s</stroke>', dots[dIdx])
            dIdx = (dIdx % #dots) + 1
            task.wait(0.07)
        end
    end)

    -- ========== Main Window Frame ==========
    local Main = Instance.new("Frame")
    Main.Name = "Main"; Main.AnchorPoint = Vector2.new(.5, .5)
    Main.Position = UDim2.new(0.5, 0, -0.6, 0)
    Main.Size = UDim2.fromOffset(W, H); Main.BorderSizePixel = 0; Main.Visible = false
    Th(Main, "BackgroundColor3", "Background"); Main.Parent = Gui
    Corner(Main, 3)
    Stroke(Main, "Stroke", 1)

    local MS = Instance.new("UIScale"); MS.Scale = Fit(); MS.Parent = Main

    local function Rescale() if MS and Main.Parent then MS.Scale = Fit() end end
    if Workspace.CurrentCamera then Conn(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), Rescale) end
    Conn(Gui:GetPropertyChangedSignal("AbsoluteSize"), Rescale)

    local Header = Instance.new("Frame")
    Header.Name = "Header"; Header.Size = UDim2.new(1, 0, 0, 36); Header.BorderSizePixel = 0
    Th(Header, "BackgroundColor3", "Header"); Header.Parent = Main; Corner(Header, 3)

    local HPatch = Instance.new("Frame")
    HPatch.Size = UDim2.new(1, 0, 0, 8); HPatch.Position = UDim2.new(0, 0, 1, -8); HPatch.BorderSizePixel = 0
    Th(HPatch, "BackgroundColor3", "Header"); HPatch.Parent = Header

    local TL = Label(Header, Title, 12, "Text", FONTB)
    TL.Position = UDim2.fromOffset(10, 0); TL.Size = UDim2.fromOffset(160, 36)

    local function HBtn(txt, x)
        local b = Instance.new("TextButton")
        b.AnchorPoint = Vector2.new(1, .5); b.Position = UDim2.new(1, x, .5, 0)
        b.Size = UDim2.fromOffset(24, 24); b.Text = txt; b.TextSize = 12; b.Font = FONTB
        b.AutoButtonColor = false; Th(b, "BackgroundColor3", "Card"); Th(b, "TextColor3", "SubText")
        b.Parent = Header; Corner(b, 3); Stroke(b, "Stroke", 1)
        return b
    end
    local CloseBtn, HideBtn = HBtn("✕", -6), HBtn("–", -34)

    local SearchBox = Instance.new("TextBox")
    SearchBox.AnchorPoint = Vector2.new(1, .5); SearchBox.Position = UDim2.new(1, -64, .5, 0)
    SearchBox.Size = UDim2.fromOffset(100, 22); SearchBox.PlaceholderText = "Search..."; SearchBox.Text = ""
    SearchBox.TextSize = 10; SearchBox.Font = FONT; SearchBox.ClearTextOnFocus = false
    Th(SearchBox, "BackgroundColor3", "Card"); Th(SearchBox, "TextColor3", "Text"); Th(SearchBox, "PlaceholderColor3", "SubText")
    SearchBox.Parent = Header; Corner(SearchBox, 3); Stroke(SearchBox, "Stroke", 1); Pad(SearchBox, 6, 0, 6, 0)

    Conn(SearchBox:GetPropertyChangedSignal("Text"), function()
        local q = string.lower(SearchBox.Text):match("^%s*(.-)%s*$")
        for _, e in ipairs(Win.Elements) do
            if e.Frame and e.Frame.Parent then e.Frame.Visible = (q == "") or (e.Key:find(q, 1, true) ~= nil) end
        end
    end)

    -- Sidebar & Content
    local Sidebar = Instance.new("Frame")
    Sidebar.Position = UDim2.fromOffset(6, 42); Sidebar.Size = UDim2.new(0, 118, 1, -48)
    Sidebar.BorderSizePixel = 0; Th(Sidebar, "BackgroundColor3", "Sidebar"); Sidebar.Parent = Main; Corner(Sidebar, 3)

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.BackgroundTransparency = 1; TabScroll.BorderSizePixel = 0; TabScroll.Size = UDim2.fromScale(1, 1)
    TabScroll.ScrollBarThickness = 0; TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; TabScroll.Parent = Sidebar
    Pad(TabScroll, 4, 4, 4, 4)
    local TL2 = Instance.new("UIListLayout"); TL2.Padding = UDim.new(0, 3); TL2.SortOrder = Enum.SortOrder.LayoutOrder; TL2.Parent = TabScroll

    local Content = Instance.new("Frame")
    Content.BackgroundTransparency = 1; Content.Position = UDim2.fromOffset(130, 42)
    Content.Size = UDim2.new(1, -136, 1, -48); Content.Parent = Main

    -- ==================== Anti-Jump Drag Engine ====================
    local function MakeDraggable(handle, target)
        local dragInfo = { moved = false }
        local dragging = false
        local startMouse, startPos = nil, nil

        Conn(handle.InputBegan, function(i)
            if IsPointer(i) then
                dragging = true
                dragInfo.moved = false
                startMouse = i.Position
                startPos = target.Position
            end
        end)

        Conn(UIS.InputChanged, function(i)
            if dragging and IsMove(i) then
                local delta = i.Position - startMouse
                if delta.Magnitude > 4 then dragInfo.moved = true end
                if dragInfo.moved then
                    target.Position = UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                end
            end
        end)

        Conn(UIS.InputEnded, function(i)
            if IsPointer(i) then dragging = false end
        end)
        return dragInfo
    end

    MakeDraggable(Header, Main)

    -- ==================== Resizable Window Handle ====================
    if cfg.Resizable == true then
        local ResizeHandle = Instance.new("TextButton")
        ResizeHandle.AnchorPoint = Vector2.new(1, 1)
        ResizeHandle.Position = UDim2.new(1, 0, 1, 0)
        ResizeHandle.Size = UDim2.fromOffset(18, 18)
        ResizeHandle.Text = "⇲"
        ResizeHandle.TextSize = 11
        ResizeHandle.Font = FONTB
        ResizeHandle.AutoButtonColor = false
        ResizeHandle.BackgroundTransparency = 1
        Th(ResizeHandle, "TextColor3", "SubText")
        ResizeHandle.Parent = Main

        local resizing = false
        local startMouse, startSize = nil, nil
        Conn(ResizeHandle.InputBegan, function(i)
            if IsPointer(i) then
                resizing = true
                startMouse = i.Position
                startSize = Main.AbsoluteSize
            end
        end)

        Conn(UIS.InputChanged, function(i)
            if resizing and IsMove(i) then
                local delta = i.Position - startMouse
                local s = MS.Scale or 1
                local nw = math.clamp((startSize.X + delta.X) / s, 340, 950)
                local nh = math.clamp((startSize.Y + delta.Y) / s, 220, 700)
                Main.Size = UDim2.fromOffset(nw, nh)
            end
        end)

        Conn(UIS.InputEnded, function(i)
            if IsPointer(i) then resizing = false end
        end)
    end

    local function PointerDrag(frame, page, fn)
        local active = false
        Conn(frame.InputBegan, function(i)
            if IsPointer(i) then active = true; if page then page.ScrollingEnabled = false end; fn(i.Position) end
        end)
        Conn(UIS.InputChanged, function(i) if active and IsMove(i) then fn(i.Position) end end)
        Conn(UIS.InputEnded, function(i)
            if active and IsPointer(i) then active = false; if page then page.ScrollingEnabled = true end end
        end)
    end

    -- Floating Action Button (FAB)
    local FAB = Instance.new("TextButton")
    FAB.Name = "AuraFAB"; FAB.AnchorPoint = Vector2.new(.5, .5); FAB.Position = UDim2.fromOffset(38, 100)
    FAB.Size = UDim2.fromOffset(36, 36); FAB.Text = cfg.ShowText or "⚡"; FAB.TextSize = 16; FAB.Font = FONTB
    FAB.AutoButtonColor = false; FAB.Visible = false
    Th(FAB, "BackgroundColor3", "Card"); Th(FAB, "TextColor3", "Accent")
    FAB.Parent = Gui; Corner(FAB, 18); Stroke(FAB, "Stroke", 1)

    local fabDrag = MakeDraggable(FAB, FAB)
    FAB.Activated:Connect(function() if not fabDrag.moved then Win:Toggle() end end)

    -- Dropdown Animation (Top to Center in 0.54334s)
    function Win:SetVisible(v)
        Win.Visible = v
        if v then
            Main.Visible = true
            MS.Scale = Fit()
            Main.Position = UDim2.new(0.5, 0, -0.6, 0)
            Tw(Main, { Position = UDim2.fromScale(0.5, 0.5) }, 0.54334, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        else
            Tw(Main, { Position = UDim2.new(0.5, 0, -0.6, 0) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.delay(0.31, function() if not Win.Visible and Main.Parent then Main.Visible = false end end)
        end
    end
    function Win:Toggle() Win:SetVisible(not Win.Visible) end
    HideBtn.Activated:Connect(function() Win:SetVisible(false) end)
    CloseBtn.Activated:Connect(function() Win:Destroy() end)

    -- Keybind (PC)
    local tk = cfg.ToggleUIKeybind or "RightShift"
    if typeof(tk) == "EnumItem" then tk = tk.Name end
    Conn(UIS.InputBegan, function(i, gpe)
        if not gpe and i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name == tk then Win:Toggle() end
    end)

    -- ==================== Notifications with Types & Images ====================
    local Holder = Instance.new("Frame"); Holder.BackgroundTransparency = 1; Holder.AnchorPoint = Vector2.new(1, 1)
    Holder.Position = UDim2.new(1, -10, 1, -10); Holder.Size = UDim2.new(0, 240, 1, -20); Holder.Parent = Gui
    local HL = Instance.new("UIListLayout"); HL.VerticalAlignment = Enum.VerticalAlignment.Bottom
    HL.HorizontalAlignment = Enum.HorizontalAlignment.Right; HL.Padding = UDim.new(0, 6); HL.SortOrder = Enum.SortOrder.LayoutOrder; HL.Parent = Holder
    local nOrder = 0

    function Win:Notify(n)
        n = type(n) == "table" and n or { Content = tostring(n) }
        nOrder = nOrder + 1

        local typeColors = {
            Success = T.Success,
            Error   = T.Danger,
            Warning = T.Warn,
            Info    = T.Accent
        }
        local accentCol = typeColors[n.Type] or T.Accent

        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 0); Card.AutomaticSize = Enum.AutomaticSize.Y
        Card.Position = UDim2.fromOffset(40, 0); Card.BorderSizePixel = 0
        Th(Card, "BackgroundColor3", "Card"); Card.Parent = Holder
        Corner(Card, 3)

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Thickness = 1
        cardStroke.Color = accentCol
        cardStroke.Parent = Card
        Pad(Card, 8, 6, 8, 6)

        local leftOffset = 0
        if n.Image and n.Image ~= "" then
            local Icon = Instance.new("ImageLabel")
            Icon.Position = UDim2.fromOffset(0, 2); Icon.Size = UDim2.fromOffset(24, 24)
            Icon.BackgroundTransparency = 1; Icon.Image = n.Image; Icon.Parent = Card; Corner(Icon, 3)
            leftOffset = 30
        end

        local t = Label(Card, n.Title or (n.Type or "Alert"), 11, "Text", FONTB)
        t.Position = UDim2.fromOffset(leftOffset, 0); t.Size = UDim2.new(1, -leftOffset, 0, 14)
        t.TextColor3 = accentCol

        if n.Content then
            local c = Label(Card, n.Content, 10, "SubText", FONT)
            c.Position = UDim2.fromOffset(leftOffset, 16)
            c.Size = UDim2.new(1, -leftOffset, 0, 0); c.AutomaticSize = Enum.AutomaticSize.Y; c.TextWrapped = true
        end

        Tw(Card, { Position = UDim2.fromOffset(0, 0) }, 0.25)
        task.delay(n.Duration or 3, function()
            if Card and Card.Parent then
                Tw(Card, { Position = UDim2.fromOffset(40, 0) }, 0.2)
                task.wait(0.22); Card:Destroy()
            end
        end)
    end

    -- Config Engine
    local function CfgPath(slot)
        local folder = CS.FolderName or "AuraLuxe"
        slot = (tostring(slot or CS.FileName or "Auto"):gsub("[^%w_%-]", ""))
        return folder, folder .. "/" .. (slot == "" and "Auto" or slot) .. ".json"
    end
    function Win:SaveConfig(slot, silent)
        if not writefile then return false end
        local folder, path = CfgPath(slot)
        pcall(function() if makefolder and not isfolder(folder) then makefolder(folder) end end)
        local d = {}; for k, v in pairs(Lib.Flags) do if not Lib.NoSave[k] then d[k] = Encode(v) end end
        local ok = pcall(function() writefile(path, HttpService:JSONEncode(d)) end)
        if not silent then Win:Notify({ Title = ok and "Config Saved" or "Error", Content = path, Duration = 2, Type = ok and "Success" or "Error" }) end
        return ok
    end
    function Win:LoadConfig(slot, silent)
        local _, path = CfgPath(slot)
        if not (readfile and isfile and isfile(path)) then return false end
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if ok and type(d) == "table" then
            Win._loading = true
            for k, v in pairs(d) do
                v = Decode(v)
                if Lib.Registry[k] then pcall(Lib.Registry[k], v) else Lib.Flags[k] = v end
            end
            Win._loading = false
            if not silent then Win:Notify({ Title = "Config Loaded", Content = path, Duration = 2, Type = "Success" }) end
            return true
        end
        return false
    end
    function Win:DeleteConfig(slot)
        local _, path = CfgPath(slot)
        local ok = pcall(function() delfile(path) end)
        Win:Notify({ Title = ok and "Deleted" or "Notice", Content = path, Duration = 2, Type = "Warning" })
    end
    local function SetFlag(flag, v, noSave)
        if not flag or noSave then return end
        Lib.Flags[flag] = v
        if Win._loading or not (CS.Enabled and CS.AutoSave ~= false) then return end
        task.delay(1.2, function() if Win.Alive then Win:SaveConfig(CS.FileName or "Auto", true) end end)
    end

    -- Watermark
    function Win:CreateWatermark(custom)
        local F = Instance.new("Frame")
        F.AnchorPoint = Vector2.new(1, 0); F.Position = UDim2.new(1, -8, 0, 8)
        F.Size = UDim2.fromOffset(0, 22); F.AutomaticSize = Enum.AutomaticSize.X; F.BorderSizePixel = 0
        Th(F, "BackgroundColor3", "Card"); F.Parent = Gui; Corner(F, 3); Stroke(F, "Stroke", 1); Pad(F, 8, 0, 8, 0)
        local L = Label(F, custom or Title, 10, "Text", FONTB)
        L.Size = UDim2.new(0, 0, 1, 0); L.AutomaticSize = Enum.AutomaticSize.X
        local frames, last = 0, os.clock()
        Conn(RunService.Heartbeat, function()
            frames = frames + 1
            local now = os.clock()
            if now - last >= 1 then
                local fps = math.round(frames / (now - last))
                frames = 0; last = now
                local ping = 0
                pcall(function() ping = math.round(Svc("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                L.Text = string.format("%s  |  %d FPS  |  %dms", custom or Title, fps, ping)
            end
        end)
        return { SetText = function(_, t) custom = t end }
    end

    -- ==================== Tabs & Element Generation Engine ====================
    local tabCount = 0
    function Win:CreateTab(name, icon)
        tabCount = tabCount + 1
        local Tab = {}
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 26); Btn.Text = ""; Btn.AutoButtonColor = false
        Btn.BackgroundTransparency = 1; Btn.LayoutOrder = tabCount; Btn.Parent = TabScroll; Corner(Btn, 3)

        local TLb = Label(Btn, name, 11, "SubText", FONT)
        TLb.Position = UDim2.fromOffset(8, 0); TLb.Size = UDim2.new(1, -16, 1, 0)

        local Page = Instance.new("ScrollingFrame")
        Page.BackgroundTransparency = 1; Page.BorderSizePixel = 0; Page.Size = UDim2.fromScale(1, 1)
        Page.ScrollBarThickness = 2; Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = false; Page.ScrollingDirection = Enum.ScrollingDirection.Y
        Th(Page, "ScrollBarImageColor3", "Stroke"); Page.Parent = Content; Pad(Page, 0, 2, 4, 4)
        local PL = Instance.new("UIListLayout"); PL.Padding = UDim.new(0, 4); PL.SortOrder = Enum.SortOrder.LayoutOrder; PL.Parent = Page

        local tgt = 0
        Conn(Page.InputChanged, function(i)
            if i.UserInputType == Enum.UserInputType.MouseWheel then
                local mx = math.max(0, Page.AbsoluteCanvasSize.Y - Page.AbsoluteWindowSize.Y)
                tgt = math.clamp((tgt == 0 and Page.CanvasPosition.Y or tgt) - i.Position.Z * 55, 0, mx)
                Tw(Page, { CanvasPosition = Vector2.new(0, tgt) }, 0.16)
            end
        end)

        local function Paint(act)
            Tw(Btn, { BackgroundTransparency = act and 0 or 1, BackgroundColor3 = T.Card }, 0.15)
            Tw(TLb, { TextColor3 = act and T.Text or T.SubText }, 0.15)
        end
        local obj = { Btn = Btn, Label = TLb, Page = Page, Paint = Paint }

        function Tab:Select()
            if SearchBox then SearchBox.Text = "" end
            if Win.Current == obj then return end
            if Win.Current then Win.Current.Page.Visible = false; Win.Current.Paint(false) end
            Win.Current = obj
            Page.Visible = true; Paint(true)
        end
        Btn.Activated:Connect(function() Tab:Select() end)
        if not Win.Current then Tab:Select() end

        -- Central Element Factory Function
        local function BuildControls(targetParent, targetWidth, targetObj, isCol)
            local order = 0

            local function Base(c, rightW, extraH)
                order = order + 1
                local hasDesc = (c.Desc and c.Desc ~= "")
                local h = 28 + (extraH or 0)
                local effRightW = (rightW or 0) + (hasDesc and 20 or 0)

                local F = Instance.new("Frame")
                F.Size = UDim2.new(1, 0, 0, h); F.BorderSizePixel = 0; F.LayoutOrder = order
                Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent; Corner(F, 3); Stroke(F, "Stroke", 1)

                local L = Label(F, c.Name or "Control", 11, "Text", FONT)
                L.Position = UDim2.fromOffset(8, 0)
                L.Size = UDim2.new(1, -(16 + effRightW), 1, 0)

                if hasDesc then
                    local infoBtn = Instance.new("TextButton")
                    infoBtn.AnchorPoint = Vector2.new(1, .5)
                    infoBtn.Position = UDim2.new(1, -(rightW or 0) - 4, .5, 0)
                    infoBtn.Size = UDim2.fromOffset(15, 15)
                    infoBtn.Text = "?"
                    infoBtn.TextSize = 10
                    infoBtn.Font = FONTB
                    infoBtn.AutoButtonColor = false
                    Th(infoBtn, "BackgroundColor3", "Sidebar")
                    Th(infoBtn, "TextColor3", "SubText")
                    infoBtn.Parent = F; Corner(infoBtn, 8); Stroke(infoBtn, "Stroke", 1)

                    infoBtn.Activated:Connect(function()
                        Win:Notify({
                            Title = c.Name or "Information",
                            Content = c.Desc,
                            Type = "Info",
                            Duration = 3
                        })
                    end)
                end

                Win.Elements[#Win.Elements + 1] = { Frame = F, Key = string.lower((c.Name or "") .. " " .. (c.Desc or "")) }
                return F, L
            end

            -- Sections & Layout Utilities
            function targetObj:CreateSection(text)
                order = order + 1
                local F = Instance.new("Frame"); F.BackgroundTransparency = 1; F.Size = UDim2.new(1, 0, 0, 20); F.LayoutOrder = order; F.Parent = targetParent
                local L = Label(F, text or "SECTION", 10, "Accent", FONTB); L.Position = UDim2.fromOffset(4, 0); L.Size = UDim2.new(1, -8, 0, 16)
                local ln = Instance.new("Frame"); ln.Size = UDim2.new(1, 0, 0, 1); ln.Position = UDim2.new(0, 0, 1, -1); ln.BorderSizePixel = 0
                Th(ln, "BackgroundColor3", "Stroke"); ln.Parent = F
                return {
                    Set = function(_, t) L.Text = tostring(t) end,
                    SetText = function(_, t) L.Text = tostring(t) end,
                    Get = function() return L.Text end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
            end

            function targetObj:CreateDivider()
                order = order + 1
                local ln = Instance.new("Frame"); ln.Size = UDim2.new(1, 0, 0, 1); ln.BorderSizePixel = 0; ln.LayoutOrder = order
                Th(ln, "BackgroundColor3", "Stroke"); ln.Parent = targetParent
                return {
                    SetVisible = function(_, v) ln.Visible = v end,
                    Destroy = function(_) if ln and ln.Parent then ln:Destroy() end end
                }
            end

            function targetObj:CreateLabel(text)
                order = order + 1
                local L = Label(targetParent, text or "", 10, "SubText", FONT); L.TextWrapped = true
                L.Size = UDim2.new(1, -6, 0, 0); L.AutomaticSize = Enum.AutomaticSize.Y; L.LayoutOrder = order
                Win.Elements[#Win.Elements + 1] = { Frame = L, Key = string.lower(text or "") }
                return {
                    Set = function(_, t) L.Text = tostring(t) end,
                    SetText = function(_, t) L.Text = tostring(t) end,
                    Get = function() return L.Text end,
                    SetVisible = function(_, v) L.Visible = v end,
                    Destroy = function(_) if L and L.Parent then L:Destroy() end end
                }
            end

            function targetObj:CreateParagraph(c)
                c = c or {}; order = order + 1
                local F = Instance.new("Frame"); F.Size = UDim2.new(1, 0, 0, 0); F.AutomaticSize = Enum.AutomaticSize.Y
                F.BorderSizePixel = 0; F.LayoutOrder = order; Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent
                Corner(F, 3); Stroke(F, "Stroke", 1); Pad(F, 8, 6, 8, 6)
                local ly = Instance.new("UIListLayout"); ly.Padding = UDim.new(0, 2); ly.SortOrder = Enum.SortOrder.LayoutOrder; ly.Parent = F
                local a = Label(F, c.Title or "", 11, "Text", FONTB); a.Size = UDim2.new(1, 0, 0, 14)
                local b = Label(F, c.Content or "", 10, "SubText", FONT)
                b.Size = UDim2.new(1, 0, 0, 0); b.AutomaticSize = Enum.AutomaticSize.Y; b.TextWrapped = true
                Win.Elements[#Win.Elements + 1] = { Frame = F, Key = string.lower((c.Title or "") .. " " .. (c.Content or "")) }
                return {
                    Set = function(_, d)
                        if type(d) == "table" then
                            a.Text = d.Title or a.Text
                            b.Text = d.Content or b.Text
                        else
                            b.Text = tostring(d)
                        end
                    end,
                    SetText = function(_, t) b.Text = tostring(t) end,
                    Get = function() return { Title = a.Text, Content = b.Text } end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
            end

            -- ==================== Section 1: Dynamic Elements ====================
            function targetObj:CreateDynamicLabel(c)
                c = c or {}
                order = order + 1
                local name = c.Name or ""
                local getText = c.GetText or function() return "" end
                local interval = math.clamp(tonumber(c.Interval) or 1, 0.1, 86400)

                local F = Instance.new("Frame")
                F.Size = UDim2.new(1, 0, 0, 28); F.BorderSizePixel = 0; F.LayoutOrder = order
                Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent; Corner(F, 3); Stroke(F, "Stroke", 1)

                local TitleL = Label(F, name, 11, "Text", FONT)
                TitleL.Position = UDim2.fromOffset(8, 0); TitleL.Size = UDim2.new(0.48, -8, 1, 0)

                local ValL = Label(F, "", 10, "Accent", FONTB, Enum.TextXAlignment.Right)
                ValL.AnchorPoint = Vector2.new(1, .5); ValL.Position = UDim2.new(1, -8, .5, 0); ValL.Size = UDim2.new(0.5, -8, 1, 0)

                local alive = true
                local function Refresh()
                    if not alive or not F.Parent then return end
                    local ok, txt = pcall(getText)
                    if ok and txt ~= nil then ValL.Text = tostring(txt) end
                end
                Refresh()

                task.spawn(function()
                    while alive and Win.Alive and F.Parent do
                        task.wait(interval)
                        if alive and Win.Alive and F.Parent then
                            Refresh()
                        end
                    end
                end)

                local ctrl = {
                    Refresh = Refresh,
                    SetInterval = function(_, n) interval = math.clamp(tonumber(n) or 1, 0.1, 86400) end,
                    SetText = function(_, t) ValL.Text = tostring(t) end,
                    Set = function(_, t) ValL.Text = tostring(t) end,
                    Get = function() return ValL.Text end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_)
                        alive = false
                        if F and F.Parent then F:Destroy() end
                    end
                }
                Win.Elements[#Win.Elements + 1] = { Frame = F, Key = string.lower(name) }
                return ctrl
            end

            -- ==================== Section 2: Images & Avatars ====================
            function targetObj:CreateImage(c)
                c = c or {}
                order = order + 1
                local imgId = c.Image or ""
                local size = c.Size or UDim2.new(1, 0, 0, 110)
                local cornerR = c.CornerRadius or 3
                local clickable = c.Clickable == true

                local F = Instance.new("Frame")
                F.Size = size; F.BorderSizePixel = 0; F.LayoutOrder = order
                Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent; Corner(F, cornerR); Stroke(F, "Stroke", 1)
                F.ClipsDescendants = true

                local Img = Instance.new("ImageLabel")
                Img.Size = UDim2.fromScale(1, 1); Img.BackgroundTransparency = 1
                Img.ScaleType = Enum.ScaleType.Fit; Img.Image = imgId; Img.Parent = F
                Corner(Img, cornerR)

                if clickable then
                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.fromScale(1, 1); Btn.BackgroundTransparency = 1; Btn.Text = ""
                    Btn.Parent = F
                    Btn.Activated:Connect(function() Safe(c.Callback) end)
                end

                return {
                    SetImage = function(_, id) Img.Image = tostring(id) end,
                    Set = function(_, id) Img.Image = tostring(id) end,
                    Get = function() return Img.Image end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
            end

            function targetObj:CreatePlayerCard(c)
                c = c or {}
                order = order + 1
                local plr = c.Player or LocalPlayer
                local clickable = c.Clickable == true

                local F = Instance.new("Frame")
                F.Size = UDim2.new(1, 0, 0, 48); F.BorderSizePixel = 0; F.LayoutOrder = order
                Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent; Corner(F, 3); Stroke(F, "Stroke", 1)

                local thumb = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=150&h=150"
                local Avatar = Instance.new("ImageLabel")
                Avatar.Position = UDim2.fromOffset(6, 6); Avatar.Size = UDim2.fromOffset(36, 36)
                Avatar.BackgroundTransparency = 1; Avatar.Image = thumb; Avatar.Parent = F
                Corner(Avatar, 18); Stroke(Avatar, "Stroke", 1)

                local NameL = Label(F, plr.DisplayName or plr.Name, 11, "Text", FONTB)
                NameL.Position = UDim2.fromOffset(48, 5); NameL.Size = UDim2.new(1, -54, 0, 14)

                local SubL = Label(F, "@" .. plr.Name, 9, "SubText", FONT)
                SubL.Position = UDim2.fromOffset(48, 18); SubL.Size = UDim2.new(1, -54, 0, 12)

                local StatsL = Label(F, "HP: -- | Dist: --", 9, "Accent", FONT)
                StatsL.Position = UDim2.fromOffset(48, 30); StatsL.Size = UDim2.new(1, -54, 0, 13)

                if clickable then
                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.fromScale(1, 1); Btn.BackgroundTransparency = 1; Btn.Text = ""
                    Btn.Parent = F
                    Btn.Activated:Connect(function()
                        Tw(F, { BackgroundColor3 = T.CardHover }, 0.08)
                        task.delay(0.1, function() if F and F.Parent then Tw(F, { BackgroundColor3 = T.Card }, 0.15) end end)
                        Safe(c.Callback, plr)
                    end)
                end

                local alive = true
                local function UpdateStats()
                    if not plr or not plr.Parent then
                        StatsL.Text = "Left Server"
                        return
                    end
                    local char = plr.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))

                    local hpStr = "--"
                    if hum then
                        hpStr = string.format("%d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
                    end

                    local distStr = "--"
                    local myChar = LocalPlayer.Character
                    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
                    if root and myRoot then
                        local d = math.floor((root.Position - myRoot.Position).Magnitude)
                        distStr = d .. "m"
                    end
                    StatsL.Text = string.format("HP: %s | Dist: %s", hpStr, distStr)
                end
                UpdateStats()

                task.spawn(function()
                    while alive and Win.Alive and F.Parent do
                        task.wait(0.5)
                        if alive and Win.Alive and F.Parent then
                            UpdateStats()
                        end
                    end
                end)

                local ctrl = {
                    GetPlayer = function() return plr end,
                    Get = function() return plr end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_)
                        alive = false
                        if F and F.Parent then F:Destroy() end
                    end
                }
                Win.Elements[#Win.Elements + 1] = { Frame = F, Key = string.lower(plr.Name .. " " .. plr.DisplayName) }
                return ctrl
            end

            -- ==================== Section 3: Advanced Lists ====================
            function targetObj:CreatePlayerList(c)
                c = c or {}
                order = order + 1
                local searchable = c.Searchable == true
                local refreshInterval = math.clamp(tonumber(c.RefreshInterval) or 2, 0.5, 60)
                local callback = c.Callback or function() end
                local selectedPlayer = nil

                local totalH = searchable and 180 or 150
                local F = Instance.new("Frame")
                F.Size = UDim2.new(1, 0, 0, totalH); F.BorderSizePixel = 0; F.LayoutOrder = order
                Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent; Corner(F, 3); Stroke(F, "Stroke", 1)
                F.ClipsDescendants = true

                local topOffset = 6
                local searchFilter = ""

                local TitleHeader = Label(F, c.Name or "Player Directory", 11, "Text", FONTB)
                TitleHeader.Position = UDim2.fromOffset(8, topOffset); TitleHeader.Size = UDim2.new(1, -16, 0, 16)
                topOffset = topOffset + 20

                local ListScroll = Instance.new("ScrollingFrame")
                local DLL = Instance.new("UIListLayout"); DLL.Padding = UDim.new(0, 3); DLL.Parent = ListScroll

                if searchable then
                    local SBox = Instance.new("TextBox")
                    SBox.Position = UDim2.fromOffset(8, topOffset); SBox.Size = UDim2.new(1, -16, 0, 22)
                    SBox.PlaceholderText = "Search player name..."; SBox.Text = ""; SBox.TextSize = 10; SBox.Font = FONT
                    SBox.ClearTextOnFocus = false
                    Th(SBox, "BackgroundColor3", "Sidebar"); Th(SBox, "TextColor3", "Text"); Th(SBox, "PlaceholderColor3", "SubText")
                    SBox.Parent = F; Corner(SBox, 3); Stroke(SBox, "Stroke", 1); Pad(SBox, 6, 0, 6, 0)
                    topOffset = topOffset + 26

                    SBox:GetPropertyChangedSignal("Text"):Connect(function()
                        searchFilter = string.lower(SBox.Text):match("^%s*(.-)%s*$")
                        for _, row in ipairs(ListScroll:GetChildren()) do
                            if row:IsA("Frame") and row:FindFirstChild("PlayerKey") then
                                row.Visible = (searchFilter == "") or (row.PlayerKey.Value:find(searchFilter, 1, true) ~= nil)
                            end
                        end
                    end)
                end

                ListScroll.Position = UDim2.fromOffset(6, topOffset)
                ListScroll.Size = UDim2.new(1, -12, 1, -topOffset - 6)
                ListScroll.BackgroundTransparency = 1; ListScroll.BorderSizePixel = 0; ListScroll.ScrollBarThickness = 2
                ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                Th(ListScroll, "ScrollBarImageColor3", "Stroke"); ListScroll.Parent = F
                Pad(ListScroll, 2, 2, 2, 2)

                local alive = true
                local function BuildList()
                    if not alive or not F.Parent then return end
                    for _, ch in ipairs(ListScroll:GetChildren()) do
                        if ch:IsA("Frame") then ch:Destroy() end
                    end

                    for _, p in ipairs(Players:GetPlayers()) do
                        local pRow = Instance.new("Frame")
                        pRow.Size = UDim2.new(1, 0, 0, 28); pRow.BorderSizePixel = 0
                        Th(pRow, "BackgroundColor3", "Sidebar"); pRow.Parent = ListScroll; Corner(pRow, 2)

                        local keyVal = Instance.new("StringValue")
                        keyVal.Name = "PlayerKey"
                        keyVal.Value = string.lower(p.Name .. " " .. p.DisplayName)
                        keyVal.Parent = pRow

                        pRow.Visible = (searchFilter == "") or (keyVal.Value:find(searchFilter, 1, true) ~= nil)

                        local pThumb = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=100&h=100"
                        local pImg = Instance.new("ImageLabel")
                        pImg.Position = UDim2.fromOffset(4, 3); pImg.Size = UDim2.fromOffset(22, 22)
                        pImg.BackgroundTransparency = 1; pImg.Image = pThumb; pImg.Parent = pRow; Corner(pImg, 11)

                        local pLbl = Label(pRow, p.DisplayName .. " (@" .. p.Name .. ")", 10, "Text", FONT)
                        pLbl.Position = UDim2.fromOffset(32, 0); pLbl.Size = UDim2.new(1, -86, 1, 0)

                        local sBtn = Instance.new("TextButton")
                        sBtn.AnchorPoint = Vector2.new(1, .5); sBtn.Position = UDim2.new(1, -4, .5, 0)
                        sBtn.Size = UDim2.fromOffset(46, 20); sBtn.Text = (selectedPlayer == p) and "Selected" or "Select"
                        sBtn.TextSize = 9; sBtn.Font = FONTB; sBtn.AutoButtonColor = false
                        Th(sBtn, "BackgroundColor3", (selectedPlayer == p) and "Accent" or "Card")
                        sBtn.TextColor3 = Color3.new(1, 1, 1); sBtn.Parent = pRow; Corner(sBtn, 2)

                        sBtn.Activated:Connect(function()
                            selectedPlayer = p
                            for _, r in ipairs(ListScroll:GetChildren()) do
                                if r:IsA("Frame") and r:FindFirstChildOfClass("TextButton") then
                                    local b = r:FindFirstChildOfClass("TextButton")
                                    b.Text = "Select"
                                    Th(b, "BackgroundColor3", "Card")
                                end
                            end
                            sBtn.Text = "Selected"
                            Th(sBtn, "BackgroundColor3", "Accent")
                            Safe(callback, p)
                        end)
                    end
                end
                BuildList()

                task.spawn(function()
                    while alive and Win.Alive and F.Parent do
                        task.wait(refreshInterval)
                        if alive and Win.Alive and F.Parent then
                            BuildList()
                        end
                    end
                end)

                local ctrl = {
                    Refresh = BuildList,
                    GetSelected = function() return selectedPlayer end,
                    Get = function() return selectedPlayer end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_)
                        alive = false
                        if F and F.Parent then F:Destroy() end
                    end
                }
                Win.Elements[#Win.Elements + 1] = { Frame = F, Key = string.lower(c.Name or "player directory") }
                return ctrl
            end

            -- ==================== Section 4: SubTabs ====================
            function targetObj:CreateSubTabs(c)
                c = c or {}
                order = order + 1
                local tabNames = c.Tabs or { "Sub1", "Sub2" }

                local F = Instance.new("Frame")
                F.Size = UDim2.new(1, 0, 0, 0); F.AutomaticSize = Enum.AutomaticSize.Y
                F.BackgroundTransparency = 1; F.BorderSizePixel = 0; F.LayoutOrder = order
                F.Parent = targetParent

                local MainLayout = Instance.new("UIListLayout")
                MainLayout.Padding = UDim.new(0, 4); MainLayout.SortOrder = Enum.SortOrder.LayoutOrder; MainLayout.Parent = F

                local BarHolder = Instance.new("Frame")
                BarHolder.Size = UDim2.new(1, 0, 0, 26); BarHolder.BorderSizePixel = 0
                Th(BarHolder, "BackgroundColor3", "Sidebar"); BarHolder.Parent = F; Corner(BarHolder, 3)
                local BarLayout = Instance.new("UIListLayout")
                BarLayout.FillDirection = Enum.FillDirection.Horizontal; BarLayout.Padding = UDim.new(0, 3); BarLayout.Parent = BarHolder
                Pad(BarHolder, 3, 2, 3, 2)

                local SubTabObjs = {}
                local pages = {}
                local buttons = {}
                local activeIdx = 1

                for idx, name in ipairs(tabNames) do
                    local sBtn = Instance.new("TextButton")
                    sBtn.Size = UDim2.new(1 / #tabNames, -((#tabNames - 1) * 3) / #tabNames, 1, 0)
                    sBtn.Text = tostring(name); sBtn.TextSize = 10; sBtn.Font = FONT; sBtn.AutoButtonColor = false
                    Th(sBtn, "BackgroundColor3", idx == 1 and "Card" or "Sidebar")
                    Th(sBtn, "TextColor3", idx == 1 and "Text" or "SubText")
                    sBtn.Parent = BarHolder; Corner(sBtn, 3)
                    buttons[idx] = sBtn

                    local SubPage = Instance.new("Frame")
                    SubPage.BackgroundTransparency = 1; SubPage.Size = UDim2.new(1, 0, 0, 0)
                    SubPage.AutomaticSize = Enum.AutomaticSize.Y; SubPage.BorderSizePixel = 0
                    SubPage.Visible = (idx == 1); SubPage.Parent = F
                    local SPL = Instance.new("UIListLayout"); SPL.Padding = UDim.new(0, 4); SPL.SortOrder = Enum.SortOrder.LayoutOrder; SPL.Parent = SubPage
                    pages[idx] = SubPage

                    local subBuilder = {}
                    BuildControls(SubPage, targetWidth, subBuilder, isCol)
                    SubTabObjs[idx] = subBuilder
                    SubTabObjs[name] = subBuilder

                    sBtn.Activated:Connect(function()
                        if activeIdx == idx then return end
                        activeIdx = idx
                        for i, b in ipairs(buttons) do
                            local act = (i == activeIdx)
                            Tw(b, { BackgroundColor3 = act and T.Card or T.Sidebar, TextColor3 = act and T.Text or T.SubText }, 0.15)
                            pages[i].Visible = act
                        end
                    end)
                end

                SubTabObjs.SetVisible = function(_, v) F.Visible = v end
                SubTabObjs.Destroy = function(_) if F and F.Parent then F:Destroy() end end
                return SubTabObjs
            end

            -- ==================== Section 5: New Useful Controls ====================
            function targetObj:CreateProgressBar(c)
                c = c or {}
                order = order + 1
                local min, max = c.Min or 0, c.Max or 100
                local val = math.clamp(c.Default or min, min, max)

                local F = Instance.new("Frame")
                F.Size = UDim2.new(1, 0, 0, 32); F.BorderSizePixel = 0; F.LayoutOrder = order
                Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent; Corner(F, 3); Stroke(F, "Stroke", 1)

                local L = Label(F, c.Name or "Progress", 11, "Text", FONT)
                L.Position = UDim2.fromOffset(8, 3); L.Size = UDim2.new(0.65, -8, 0, 14)

                local PctL = Label(F, "", 10, "Accent", FONTB, Enum.TextXAlignment.Right)
                PctL.AnchorPoint = Vector2.new(1, 0); PctL.Position = UDim2.new(1, -8, 0, 3); PctL.Size = UDim2.new(0.3, 0, 0, 14)

                local Bar = Instance.new("Frame")
                Bar.Position = UDim2.fromOffset(8, 20); Bar.Size = UDim2.new(1, -16, 0, 6)
                Bar.BorderSizePixel = 0; Th(Bar, "BackgroundColor3", "SwitchOff"); Bar.Parent = F; Corner(Bar, 3)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.fromScale(0, 1); Fill.BorderSizePixel = 0
                Th(Fill, "BackgroundColor3", "Accent"); Fill.Parent = Bar; Corner(Fill, 3)

                local function UpdateVisual()
                    local pct = math.clamp((val - min) / math.max(max - min, 0.0001), 0, 1)
                    Tw(Fill, { Size = UDim2.fromScale(pct, 1) }, 0.15)
                    PctL.Text = string.format("%d%%", math.floor(pct * 100))
                end
                UpdateVisual()

                local ctrl = {
                    Set = function(_, v)
                        val = math.clamp(tonumber(v) or min, min, max)
                        UpdateVisual()
                    end,
                    Get = function() return val end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
                Win.Elements[#Win.Elements + 1] = { Frame = F, Key = string.lower(c.Name or "progressbar") }
                return ctrl
            end

            function targetObj:CreateTextArea(c)
                c = c or {}
                order = order + 1
                local flag = c.Flag or c.Name or ("TextArea_" .. order)
                local lines = math.clamp(tonumber(c.Lines) or 4, 2, 20)
                local boxH = math.max(50, lines * 16)
                local totalH = boxH + (c.Name and 24 or 8)

                local F = Instance.new("Frame")
                F.Size = UDim2.new(1, 0, 0, totalH); F.BorderSizePixel = 0; F.LayoutOrder = order
                Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent; Corner(F, 3); Stroke(F, "Stroke", 1)

                local yOff = 4
                if c.Name then
                    local L = Label(F, c.Name, 11, "Text", FONT)
                    L.Position = UDim2.fromOffset(8, 4); L.Size = UDim2.new(1, -16, 0, 16)
                    yOff = 22
                end

                local Box = Instance.new("TextBox")
                Box.Position = UDim2.fromOffset(6, yOff); Box.Size = UDim2.new(1, -12, 0, boxH)
                Box.Text = c.Default or ""; Box.TextSize = 10; Box.Font = FONT
                Box.PlaceholderText = c.Placeholder or "Type here..."; Box.ClearTextOnFocus = false
                Box.TextYAlignment = Enum.TextYAlignment.Top; Box.TextXAlignment = Enum.TextXAlignment.Left
                Box.MultiLine = true; Box.TextWrapped = true
                Th(Box, "BackgroundColor3", "Sidebar"); Th(Box, "TextColor3", "Text"); Th(Box, "PlaceholderColor3", "SubText")
                Box.Parent = F; Corner(Box, 3); Stroke(Box, "Stroke", 1); Pad(Box, 6, 6, 6, 6)

                Box.FocusLost:Connect(function(enterPressed)
                    SetFlag(flag, Box.Text, c.NoSave)
                    Safe(c.Callback, Box.Text, enterPressed)
                end)

                local ctrl = {
                    Set = function(_, t)
                        Box.Text = tostring(t)
                        SetFlag(flag, Box.Text, c.NoSave)
                    end,
                    SetText = function(_, t)
                        Box.Text = tostring(t)
                        SetFlag(flag, Box.Text, c.NoSave)
                    end,
                    Get = function() return Box.Text end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
                Lib.Registry[flag] = function(v) ctrl:Set(v) end
                Win.Elements[#Win.Elements + 1] = { Frame = F, Key = string.lower(c.Name or "textarea") }
                return ctrl
            end

            function targetObj:CreateImageButton(c)
                c = c or {}
                order = order + 1
                local hasDesc = (c.Desc and c.Desc ~= "")
                local h = 28
                local effRightW = 24 + (hasDesc and 20 or 0)

                local F = Instance.new("Frame")
                F.Size = UDim2.new(1, 0, 0, h); F.BorderSizePixel = 0; F.LayoutOrder = order
                Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent; Corner(F, 3); Stroke(F, "Stroke", 1)

                local Img = Instance.new("ImageLabel")
                Img.Position = UDim2.fromOffset(6, (h - 18) / 2); Img.Size = UDim2.fromOffset(18, 18)
                Img.BackgroundTransparency = 1; Img.Image = c.Image or ""; Img.Parent = F; Corner(Img, 2)

                local L = Label(F, c.Name or "Button", 11, "Text", FONT)
                L.Position = UDim2.fromOffset(28, 0); L.Size = UDim2.new(1, -(28 + effRightW), 1, 0)

                if hasDesc then
                    local infoBtn = Instance.new("TextButton")
                    infoBtn.AnchorPoint = Vector2.new(1, .5); infoBtn.Position = UDim2.new(1, -28, .5, 0)
                    infoBtn.Size = UDim2.fromOffset(15, 15); infoBtn.Text = "?"; infoBtn.TextSize = 10; infoBtn.Font = FONTB
                    infoBtn.AutoButtonColor = false; Th(infoBtn, "BackgroundColor3", "Sidebar"); Th(infoBtn, "TextColor3", "SubText")
                    infoBtn.Parent = F; Corner(infoBtn, 8); Stroke(infoBtn, "Stroke", 1)
                    infoBtn.Activated:Connect(function()
                        Win:Notify({ Title = c.Name or "Information", Content = c.Desc, Type = "Info", Duration = 3 })
                    end)
                end

                local Arr = Label(F, "›", 14, "SubText", FONTB, Enum.TextXAlignment.Center)
                Arr.AnchorPoint = Vector2.new(1, .5); Arr.Position = UDim2.new(1, -6, .5, 0); Arr.Size = UDim2.fromOffset(14, 14)

                local b = Instance.new("TextButton")
                b.Size = UDim2.fromScale(1, 1); b.BackgroundTransparency = 1; b.Text = ""; b.Parent = F
                b.Activated:Connect(function()
                    Tw(F, { BackgroundColor3 = T.CardHover }, 0.08)
                    task.delay(0.1, function() if F and F.Parent then Tw(F, { BackgroundColor3 = T.Card }, 0.15) end end)
                    Safe(c.Callback)
                end)

                local ctrl = {
                    Set = function(_, t) L.Text = tostring(t) end,
                    SetText = function(_, t) L.Text = tostring(t) end,
                    SetImage = function(_, id) Img.Image = tostring(id) end,
                    Get = function() return L.Text end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end,
                    Fire = function() Safe(c.Callback) end
                }
                Win.Elements[#Win.Elements + 1] = { Frame = F, Key = string.lower((c.Name or "") .. " " .. (c.Desc or "")) }
                return ctrl
            end

            function targetObj:CreateCustomFrame(c)
                c = c or {}
                order = order + 1
                local h = tonumber(c.Height) or 100

                local F = Instance.new("Frame")
                F.Size = UDim2.new(1, 0, 0, h); F.BorderSizePixel = 0; F.LayoutOrder = order
                Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent; Corner(F, 3); Stroke(F, "Stroke", 1)
                F.ClipsDescendants = true

                return {
                    Frame = F,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
            end

            -- ==================== Standard Core Controls ====================
            function targetObj:CreateButton(c)
                local F, L = Base(c, 24)
                local b = Instance.new("TextButton")
                b.Size = UDim2.fromScale(1, 1); b.BackgroundTransparency = 1; b.Text = ""; b.Parent = F
                local Arr = Label(F, "›", 14, "SubText", FONTB, Enum.TextXAlignment.Center)
                Arr.AnchorPoint = Vector2.new(1, .5); Arr.Position = UDim2.new(1, -6, .5, 0); Arr.Size = UDim2.fromOffset(14, 14)

                b.Activated:Connect(function()
                    Tw(F, { BackgroundColor3 = T.CardHover }, 0.08)
                    task.delay(0.1, function() if F and F.Parent then Tw(F, { BackgroundColor3 = T.Card }, 0.15) end end)
                    Safe(c.Callback)
                end)
                return {
                    Set = function(_, t) L.Text = tostring(t) end,
                    SetText = function(_, t) L.Text = tostring(t) end,
                    Get = function() return L.Text end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end,
                    Fire = function() Safe(c.Callback) end
                }
            end

            function targetObj:CreateToggle(c)
                local flag = c.Flag or c.Name or "Toggle"
                local F = Base(c, 36)
                local Sw = Instance.new("Frame")
                Sw.AnchorPoint = Vector2.new(1, .5); Sw.Position = UDim2.new(1, -6, .5, 0)
                Sw.Size = UDim2.fromOffset(28, 15); Sw.BorderSizePixel = 0; Sw.Parent = F; Corner(Sw, 8)

                local Kn = Instance.new("Frame")
                Kn.AnchorPoint = Vector2.new(0, .5); Kn.Size = UDim2.fromOffset(11, 11)
                Kn.BorderSizePixel = 0; Kn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Kn.Parent = Sw; Corner(Kn, 6)

                local state = c.Default == true
                local function PaintSw(an)
                    Tw(Sw, { BackgroundColor3 = state and T.Accent or T.SwitchOff }, an and 0.14 or 0)
                    Tw(Kn, { Position = state and UDim2.new(1, -13, .5, 0) or UDim2.new(0, 2, .5, 0) }, an and 0.14 or 0)
                end
                PaintSw(false)

                local b = Instance.new("TextButton")
                b.Size = UDim2.fromScale(1, 1); b.BackgroundTransparency = 1; b.Text = ""; b.Parent = F
                b.Activated:Connect(function()
                    state = not state
                    PaintSw(true); SetFlag(flag, state, c.NoSave)
                    Safe(c.Callback, state)
                end)
                local ctrl = {
                    Set = function(_, v, silent)
                        state = v == true; PaintSw(true); SetFlag(flag, state, c.NoSave)
                        if not silent then Safe(c.Callback, state) end
                    end,
                    Get = function() return state end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
                Lib.Registry[flag] = function(v) ctrl:Set(v) end
                return ctrl
            end

            function targetObj:CreateSlider(c)
                local flag = c.Flag or c.Name or "Slider"
                local min, max = c.Min or 0, c.Max or 100
                local inc = c.Increment or 1
                local suffix = c.Suffix or ""
                local val = math.clamp(c.Default or min, min, max)
                local F = Base(c, 52)

                local function FormatVal(v)
                    if inc >= 1 then
                        return string.format("%d", math.floor(v + 0.5)) .. suffix
                    else
                        local s = tostring(inc)
                        local dec = #s - (s:find("%.") or #s)
                        return string.format("%." .. dec .. "f", v) .. suffix
                    end
                end

                local VL = Label(F, FormatVal(val), 10, "Accent", FONTB, Enum.TextXAlignment.Right)
                VL.AnchorPoint = Vector2.new(1, .5); VL.Position = UDim2.new(1, -6, .5, 0); VL.Size = UDim2.fromOffset(48, 16)

                local Bar = Instance.new("Frame")
                Bar.AnchorPoint = Vector2.new(0, 1); Bar.Position = UDim2.new(0, 8, 1, -3)
                Bar.Size = UDim2.new(1, -16, 0, 3); Bar.BorderSizePixel = 0
                Th(Bar, "BackgroundColor3", "SwitchOff"); Bar.Parent = F; Corner(Bar, 2)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((val - min) / math.max(max - min, 0.0001), 0, 1, 0); Fill.BorderSizePixel = 0
                Th(Fill, "BackgroundColor3", "Accent"); Fill.Parent = Bar; Corner(Fill, 2)

                local function Update(pos)
                    local a = math.clamp((pos.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local n = min + math.floor(((max - min) * a) / inc + .5) * inc
                    val = math.clamp(n, min, max)
                    VL.Text = FormatVal(val)
                    Fill.Size = UDim2.new((val - min) / math.max(max - min, 0.0001), 0, 1, 0)
                    SetFlag(flag, val, c.NoSave)
                    Safe(c.Callback, val)
                end

                PointerDrag(Bar, Page, Update)
                local ctrl = {
                    Set = function(_, v, silent)
                        val = math.clamp(tonumber(v) or min, min, max)
                        Fill.Size = UDim2.new((val - min) / math.max(max - min, 0.0001), 0, 1, 0)
                        VL.Text = FormatVal(val)
                        SetFlag(flag, val, c.NoSave)
                        if not silent then Safe(c.Callback, val) end
                    end,
                    Get = function() return val end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
                Lib.Registry[flag] = function(v) ctrl:Set(v) end
                return ctrl
            end

            function targetObj:CreateInput(c)
                local flag = c.Flag or c.Name or "Input"
                local inW = isCol and math.clamp(targetWidth * 0.45, 60, 95) or 105
                local F = Base(c, inW + 10)
                local box = Instance.new("TextBox")
                box.AnchorPoint = Vector2.new(1, .5); box.Position = UDim2.new(1, -6, .5, 0)
                box.Size = UDim2.fromOffset(inW, 20); box.Text = c.Default or ""; box.TextSize = 10; box.Font = FONT
                box.PlaceholderText = c.Placeholder or "Type..."; box.ClearTextOnFocus = false
                Th(box, "BackgroundColor3", "Sidebar"); Th(box, "TextColor3", "Text"); Th(box, "PlaceholderColor3", "SubText")
                box.Parent = F; Corner(box, 3); Stroke(box, "Stroke", 1); Pad(box, 6, 0, 6, 0)

                box.FocusLost:Connect(function(enterPressed)
                    local t = box.Text
                    if c.NumbersOnly then t = tostring(tonumber(t) or "") box.Text = t end
                    SetFlag(flag, t, c.NoSave)
                    Safe(c.Callback, t, enterPressed)
                end)
                local ctrl = {
                    Set = function(_, t) box.Text = tostring(t); SetFlag(flag, box.Text, c.NoSave) end,
                    SetText = function(_, t) box.Text = tostring(t); SetFlag(flag, box.Text, c.NoSave) end,
                    Get = function() return box.Text end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
                Lib.Registry[flag] = function(v) ctrl:Set(v) end
                return ctrl
            end

            function targetObj:CreateDropdown(c)
                order = order + 1
                local flag = c.Flag or c.Name or "Dropdown"
                local options = c.Options or {}
                local multi = c.Multi == true
                local searchable = c.Searchable == true
                local selected, current = {}, nil

                if multi then
                    for _, v in ipairs(type(c.Default) == "table" and c.Default or (c.Default and {c.Default} or {})) do
                        selected[v] = true
                    end
                else
                    current = c.Default or options[1] or ""
                end

                local F = Instance.new("Frame")
                F.Size = UDim2.new(1, 0, 0, 28); F.BorderSizePixel = 0; F.LayoutOrder = order
                Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent; Corner(F, 3); Stroke(F, "Stroke", 1); F.ClipsDescendants = true

                local Head = Instance.new("TextButton")
                Head.Size = UDim2.new(1, 0, 0, 28); Head.BackgroundTransparency = 1; Head.Text = ""; Head.Parent = F

                local L = Label(Head, c.Name or "Dropdown", 11, "Text", FONT)
                L.Position = UDim2.fromOffset(8, 0); L.Size = UDim2.new(.48, -8, 1, 0)

                local Sel = Label(Head, "", 10, "Accent", FONTB, Enum.TextXAlignment.Right)
                Sel.AnchorPoint = Vector2.new(1, .5); Sel.Position = UDim2.new(1, -22, .5, 0); Sel.Size = UDim2.new(.46, 0, 1, 0)

                local Arr = Label(Head, "▼", 8, "SubText", FONT, Enum.TextXAlignment.Center)
                Arr.AnchorPoint = Vector2.new(1, .5); Arr.Position = UDim2.new(1, -6, .5, 0); Arr.Size = UDim2.fromOffset(12, 12)

                local contentY = 30
                local filterText = ""
                local SBox = nil

                if searchable then
                    SBox = Instance.new("TextBox")
                    SBox.Position = UDim2.fromOffset(6, contentY); SBox.Size = UDim2.new(1, -12, 0, 20)
                    SBox.PlaceholderText = "Search options..."; SBox.Text = ""; SBox.TextSize = 10; SBox.Font = FONT
                    SBox.ClearTextOnFocus = false
                    Th(SBox, "BackgroundColor3", "Sidebar"); Th(SBox, "TextColor3", "Text"); Th(SBox, "PlaceholderColor3", "SubText")
                    SBox.Parent = F; Corner(SBox, 2); Stroke(SBox, "Stroke", 1); Pad(SBox, 4, 0, 4, 0)
                    contentY = contentY + 24
                end

                local listH = 80
                local DList = Instance.new("ScrollingFrame")
                DList.Position = UDim2.fromOffset(6, contentY)
                DList.Size = UDim2.new(1, -12, 0, listH)
                DList.BackgroundTransparency = 1; DList.BorderSizePixel = 0; DList.ScrollBarThickness = 2
                DList.ScrollingDirection = Enum.ScrollingDirection.Y; DList.Parent = F
                local DLL = Instance.new("UIListLayout"); DLL.Padding = UDim.new(0, 2); DLL.Parent = DList

                local open = false
                local openH = contentY + listH + 6

                local function Val()
                    if multi then
                        local t = {}
                        for _, o in ipairs(options) do if selected[o] then t[#t+1] = o end end
                        return t
                    end
                    return current
                end

                local function Display()
                    if multi then
                        local t = Val()
                        Sel.Text = #t > 0 and table.concat(t, ", ") or "None"
                    else
                        Sel.Text = current ~= nil and tostring(current) or "None"
                    end
                end

                local function RebuildOptions()
                    for _, ch in ipairs(DList:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
                    for _, opt in ipairs(options) do
                        local optStr = tostring(opt)
                        local match = (filterText == "") or (string.find(string.lower(optStr), filterText, 1, true) ~= nil)
                        if match then
                            local isSel = multi and (selected[opt] == true) or (current == opt)
                            local b = Instance.new("TextButton")
                            b.Size = UDim2.new(1, 0, 0, 22); b.Text = (multi and (isSel and "✓ " or "   ") or "") .. optStr
                            b.TextSize = 10; b.Font = isSel and FONTB or FONT; b.AutoButtonColor = false
                            b.TextXAlignment = Enum.TextXAlignment.Left
                            Pad(b, 6, 0, 6, 0)
                            Th(b, "BackgroundColor3", isSel and "CardHover" or "Sidebar")
                            Th(b, "TextColor3", isSel and "Accent" or "SubText")
                            b.Parent = DList; Corner(b, 2)

                            b.Activated:Connect(function()
                                if multi then
                                    selected[opt] = not selected[opt] or nil
                                else
                                    current = opt
                                    open = false
                                    Arr.Text = "▼"
                                    Tw(F, { Size = UDim2.new(1, 0, 0, 28) }, 0.15)
                                end
                                Display()
                                RebuildOptions()
                                SetFlag(flag, Val(), c.NoSave)
                                Safe(c.Callback, Val())
                            end)
                        end
                    end
                    Display()
                end

                if SBox then
                    SBox:GetPropertyChangedSignal("Text"):Connect(function()
                        filterText = string.lower(SBox.Text):match("^%s*(.-)%s*$")
                        RebuildOptions()
                    end)
                end

                RebuildOptions()

                Head.Activated:Connect(function()
                    open = not open
                    Arr.Text = open and "▲" or "▼"
                    Tw(F, { Size = UDim2.new(1, 0, 0, open and openH or 28) }, 0.2)
                end)

                local ctrl = {
                    Set = function(_, v)
                        if multi then
                            selected = {}
                            for _, x in ipairs(type(v) == "table" and v or {v}) do selected[x] = true end
                        else
                            current = v
                        end
                        Display()
                        RebuildOptions()
                        SetFlag(flag, Val(), c.NoSave)
                    end,
                    Refresh = function(_, opts)
                        options = opts or {}
                        RebuildOptions()
                    end,
                    Get = function() return Val() end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
                Lib.Registry[flag] = function(v) ctrl:Set(v) end
                Win.Elements[#Win.Elements + 1] = { Frame = F, Key = string.lower(c.Name or "dropdown") }
                return ctrl
            end

            function targetObj:CreateKeybind(c)
                local flag = c.Flag or c.Name or "Keybind"
                local def = c.Default or "E"
                local key = typeof(def) == "EnumItem" and def.Name or tostring(def)
                local mode = c.Mode == "Hold" and "Hold" or "Toggle"
                local isListening, isHolding, active = false, false, false

                local F = Base(c, 115)
                local function SBtn(txt, w, xPos)
                    local b = Instance.new("TextButton")
                    b.AnchorPoint = Vector2.new(1, .5); b.Position = UDim2.new(1, xPos, .5, 0)
                    b.Size = UDim2.fromOffset(w, 20); b.Text = txt; b.TextSize = 10; b.Font = FONTB
                    b.AutoButtonColor = false; Th(b, "BackgroundColor3", "Sidebar"); Th(b, "TextColor3", "Accent")
                    b.Parent = F; Corner(b, 3); Stroke(b, "Stroke", 1)
                    return b
                end

                local KB = SBtn(key, 46, -6)
                local MB = SBtn(mode == "Toggle" and "TG" or "HD", 26, -56)
                local Trig = SBtn("▶", 22, -86)

                Trig.Activated:Connect(function()
                    active = not active
                    Safe(c.Callback, active, key)
                end)

                MB.Activated:Connect(function()
                    mode = mode == "Toggle" and "Hold" or "Toggle"
                    MB.Text = mode == "Toggle" and "TG" or "HD"
                    SetFlag(flag, { Key = key, Mode = mode }, c.NoSave)
                end)

                KB.Activated:Connect(function()
                    isListening = true; KB.Text = "..."
                end)

                Conn(UIS.InputBegan, function(i, gpe)
                    if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if isListening then
                        isListening = false
                        key = (i.KeyCode ~= Enum.KeyCode.Escape) and i.KeyCode.Name or "None"
                        KB.Text = key
                        SetFlag(flag, { Key = key, Mode = mode }, c.NoSave)
                        return
                    end
                    if gpe or key == "None" or i.KeyCode.Name ~= key then return end
                    if mode == "Toggle" then
                        active = not active; Safe(c.Callback, active, key)
                    elseif not isHolding then
                        isHolding = true; Safe(c.Callback, true, key)
                    end
                end)

                Conn(UIS.InputEnded, function(i)
                    if mode == "Hold" and isHolding and i.KeyCode.Name == key then
                        isHolding = false; Safe(c.Callback, false, key)
                    end
                end)

                local ctrl = {
                    Set = function(_, d)
                        if type(d) == "table" then key = d.Key or key; mode = d.Mode or mode else key = tostring(d) end
                        KB.Text = key; MB.Text = mode == "Toggle" and "TG" or "HD"; SetFlag(flag, { Key = key, Mode = mode }, c.NoSave)
                    end,
                    Get = function() return key, mode end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
                Lib.Registry[flag] = function(v) ctrl:Set(v) end
                return ctrl
            end

            function targetObj:CreateColorPicker(c)
                order = order + 1
                local flag = c.Flag or c.Name or "ColorPicker"
                local col = c.Default or T.Accent
                local h, s, v = col:ToHSV()
                local open = false

                local F = Instance.new("Frame")
                F.Size = UDim2.new(1, 0, 0, 28); F.BorderSizePixel = 0; F.LayoutOrder = order
                Th(F, "BackgroundColor3", "Card"); F.Parent = targetParent; Corner(F, 3); Stroke(F, "Stroke", 1); F.ClipsDescendants = true

                local Head = Instance.new("TextButton")
                Head.Size = UDim2.new(1, 0, 0, 28); Head.BackgroundTransparency = 1; Head.Text = ""; Head.Parent = F

                local L = Label(Head, c.Name or "Color", 11, "Text", FONT)
                L.Position = UDim2.fromOffset(8, 0); L.Size = UDim2.new(.5, -8, 1, 0)

                local Hex = Label(Head, "#" .. col:ToHex():upper(), 10, "SubText", FONT, Enum.TextXAlignment.Right)
                Hex.AnchorPoint = Vector2.new(1, .5); Hex.Position = UDim2.new(1, -34, .5, 0); Hex.Size = UDim2.fromOffset(50, 16)

                local Prev = Instance.new("Frame")
                Prev.AnchorPoint = Vector2.new(1, .5); Prev.Position = UDim2.new(1, -6, .5, 0)
                Prev.Size = UDim2.fromOffset(22, 16); Prev.BorderSizePixel = 0
                Prev.BackgroundColor3 = col; Prev.Parent = Head; Corner(Prev, 2); Stroke(Prev, "Stroke", 1)

                local SV = Instance.new("Frame")
                SV.Position = UDim2.fromOffset(8, 32); SV.Size = UDim2.new(1, -16, 0, 70)
                SV.BorderSizePixel = 0; SV.ClipsDescendants = true; SV.Parent = F; Corner(SV, 2)

                local White = Instance.new("Frame"); White.Size = UDim2.fromScale(1, 1); White.BorderSizePixel = 0
                White.BackgroundColor3 = Color3.new(1, 1, 1); White.Parent = SV
                local wG = Instance.new("UIGradient"); wG.Transparency = NumberSequence.new(0, 1); wG.Parent = White

                local Black = Instance.new("Frame"); Black.Size = UDim2.fromScale(1, 1); Black.BorderSizePixel = 0
                Black.BackgroundColor3 = Color3.new(0, 0, 0); Black.Parent = SV
                local bG = Instance.new("UIGradient"); bG.Rotation = 90; bG.Transparency = NumberSequence.new(1, 0); bG.Parent = Black

                local Pin = Instance.new("Frame"); Pin.AnchorPoint = Vector2.new(.5, .5); Pin.Size = UDim2.fromOffset(8, 8)
                Pin.BackgroundTransparency = 1; Pin.Parent = SV; Corner(Pin, 4); Stroke(Pin, "Text", 1.5)

                local HB = Instance.new("Frame")
                HB.Position = UDim2.fromOffset(8, 108); HB.Size = UDim2.new(1, -16, 0, 10)
                HB.BorderSizePixel = 0; HB.BackgroundColor3 = Color3.new(1, 1, 1); HB.Parent = F; Corner(HB, 2)

                local hg = Instance.new("UIGradient")
                hg.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                    ColorSequenceKeypoint.new(.167, Color3.fromHSV(.167, 1, 1)),
                    ColorSequenceKeypoint.new(.333, Color3.fromHSV(.333, 1, 1)),
                    ColorSequenceKeypoint.new(.5, Color3.fromHSV(.5, 1, 1)),
                    ColorSequenceKeypoint.new(.667, Color3.fromHSV(.667, 1, 1)),
                    ColorSequenceKeypoint.new(.833, Color3.fromHSV(.833, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
                }); hg.Parent = HB

                local HPin = Instance.new("Frame"); HPin.AnchorPoint = Vector2.new(.5, .5); HPin.Size = UDim2.fromOffset(4, 14)
                HPin.BackgroundColor3 = Color3.new(1, 1, 1); HPin.BorderSizePixel = 0; HPin.Parent = HB; Corner(HPin, 2)

                local function Redraw()
                    col = Color3.fromHSV(h, s, v)
                    Prev.BackgroundColor3 = col; SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    Pin.Position = UDim2.fromScale(s, 1 - v); HPin.Position = UDim2.fromScale(h, .5)
                    Hex.Text = "#" .. col:ToHex():upper()
                end
                Redraw()

                PointerDrag(SV, Page, function(p)
                    s = math.clamp((p.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((p.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y, 0, 1)
                    Redraw(); SetFlag(flag, col, c.NoSave); Safe(c.Callback, col)
                end)

                PointerDrag(HB, Page, function(p)
                    h = math.clamp((p.X - HB.AbsolutePosition.X) / HB.AbsoluteSize.X, 0, 1)
                    Redraw(); SetFlag(flag, col, c.NoSave); Safe(c.Callback, col)
                end)

                Head.Activated:Connect(function()
                    open = not open
                    Tw(F, { Size = UDim2.new(1, 0, 0, open and 126 or 28) }, 0.2)
                end)

                local ctrl = {
                    Set = function(_, clr)
                        if typeof(clr) == "Color3" then h, s, v = clr:ToHSV() Redraw(); SetFlag(flag, col, c.NoSave) end
                    end,
                    Get = function() return col end,
                    SetVisible = function(_, v) F.Visible = v end,
                    Destroy = function(_) if F and F.Parent then F:Destroy() end end
                }
                Lib.Registry[flag] = function(v) ctrl:Set(v) end
                return ctrl
            end

            function targetObj:CreateConfigSection()
                targetObj:CreateSection("Settings & Configs")
                local slot = "Slot1"
                targetObj:CreateDropdown({
                    Name = "Config Slot", Options = { "Slot1", "Slot2", "Slot3" }, Default = "Slot1",
                    NoSave = true, Callback = function(x) slot = x end
                })
                targetObj:CreateButton({ Name = "Save Profile", Callback = function() Win:SaveConfig(slot) end })
                targetObj:CreateButton({ Name = "Load Profile", Callback = function() Win:LoadConfig(slot) end })
                targetObj:CreateButton({ Name = "Delete Profile", Callback = function() Win:DeleteConfig(slot) end })
                local thms = {}; for k in pairs(Themes) do thms[#thms + 1] = k end; table.sort(thms)
                targetObj:CreateDropdown({
                    Name = "Theme", Options = thms, Default = cfg.Theme or "Dark",
                    Flag = "__Theme", Callback = function(x) Win:SetTheme(x) end
                })
                targetObj:CreateButton({ Name = "Destroy Interface", Callback = function() Win:Destroy() end })
            end
        end

        BuildControls(Page, PAGE_W, Tab, false)

        -- Multi-Column Layout (supports Cols.Col1 and Cols[1])
        function Tab:CreateColumnLayout(cols)
            cols = math.max(1, tonumber(cols) or 2)
            local Container = Instance.new("Frame")
            Container.BackgroundTransparency = 1; Container.Size = UDim2.new(1, 0, 0, 0)
            Container.AutomaticSize = Enum.AutomaticSize.Y; Container.BorderSizePixel = 0; Container.Parent = Page
            local Row = Instance.new("UIListLayout")
            Row.FillDirection = Enum.FillDirection.Horizontal; Row.Padding = UDim.new(0, 4); Row.Parent = Container

            local singleW = math.floor((PAGE_W - ((cols - 1) * 4)) / cols)
            local ColList = {}
            for i = 1, cols do
                local ColF = Instance.new("Frame")
                ColF.BackgroundTransparency = 1; ColF.Size = UDim2.new(1 / cols, -((cols - 1) * 4) / cols, 0, 0)
                ColF.AutomaticSize = Enum.AutomaticSize.Y; ColF.BorderSizePixel = 0; ColF.Parent = Container
                local CL = Instance.new("UIListLayout"); CL.Padding = UDim.new(0, 4); CL.Parent = ColF
                local ColObj = {}
                BuildControls(ColF, singleW, ColObj, true)
                ColList[i] = ColObj
                ColList["Col" .. i] = ColObj
            end
            return ColList
        end

        Win.Tabs[#Win.Tabs + 1] = Tab
        return Tab
    end

    -- ==================== Stepped Loader: 30% (0.5s) | 30% (0.4s) | 40% (0.6s) ====================
    task.spawn(function()
        StageLabel.Text = 'Loading "Core Engine"'
        Tw(ProgressFill, { Size = UDim2.fromScale(0.30, 1) }, 0.5, Enum.EasingStyle.Linear)
        task.wait(0.5)

        StageLabel.Text = 'Loading "Tabs & Layouts"'
        Tw(ProgressFill, { Size = UDim2.fromScale(0.60, 1) }, 0.4, Enum.EasingStyle.Linear)
        task.wait(0.4)

        StageLabel.Text = 'Loading "Button\'s & Controls"'
        Tw(ProgressFill, { Size = UDim2.fromScale(1.00, 1) }, 0.6, Enum.EasingStyle.Linear)
        task.wait(0.6)

        dotsRunning = false
        StageLabel.Text = 'Ready ""'

        Tw(LoadHolder, { BackgroundTransparency = 1 }, 0.15)
        Tw(Dimmer, { BackgroundTransparency = 1 }, 0.25)
        Tw(Blur, { Size = 0 }, 0.25)
        task.wait(0.25)

        Blur:Destroy()
        Dimmer:Destroy()
        LoadHolder:Destroy()

        FAB.Visible = true
        Win:SetVisible(true)
        if CS.Enabled and CS.AutoLoad ~= false then Win:LoadConfig(CS.FileName or "Auto", true) end
    end)

    function Win:Destroy()
        if not Win.Alive then return end
        Win.Alive = false
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        pcall(function() if Blur and Blur.Parent then Blur:Destroy() end end)
        pcall(function() Gui:Destroy() end)
        pcall(function() getgenv().__AuraLuxe = nil end)
    end

    Lib._wins[#Lib._wins + 1] = Win
    return Win
end

return Lib
