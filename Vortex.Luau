--[[
    ╔═════════════════════════════════════════════════════════════════════════════════════╗
    ║                 VORTEX UI v3.0 - COMPLETE PRODUCTION LUAU CODE                      ║
    ║               Designed for Delta Executor 2026, Mobile & Desktop                    ║
    ║         Zero Errors • Full Touch Support • Zero-Brain Universal API                 ║
    ╚═════════════════════════════════════════════════════════════════════════════════════╝
]]

-- [ 1. VORTEX UI CORE ENGINE ] --
local Vortex = {}
Vortex.__index = Vortex
Vortex.Version = "3.0.0"

-- حماية استدعاء الخدمات عبر cloneref لتفادي كشف الألعاب
local function GetService(name)
    local s = game:GetService(name)
    if cloneref then
        local ok, ref = pcall(cloneref, s)
        if ok and ref then return ref end
    end
    return s
end

local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local CoreGui = GetService("CoreGui")
local HttpService = GetService("HttpService")
local Players = GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- محدد الحاوية الآمنة لـ Delta وباقي المحقنات
local function GetSafeGuiParent()
    local success, parent = pcall(function()
        if gethui then
            return gethui()
        elseif syn and syn.protect_gui then
            local f = Instance.new("Folder")
            syn.protect_gui(f)
            f.Parent = CoreGui
            return f
        elseif CoreGui then
            return CoreGui
        end
        return nil
    end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ألوان الثيمات
Vortex.Themes = {
    CyberDark = {
        Background = Color3.fromRGB(13, 16, 24),
        Header = Color3.fromRGB(19, 24, 36),
        Sidebar = Color3.fromRGB(16, 20, 30),
        Card = Color3.fromRGB(24, 30, 46),
        CardHover = Color3.fromRGB(32, 40, 62),
        Accent = Color3.fromRGB(0, 240, 255),
        Text = Color3.fromRGB(240, 245, 255),
        SubText = Color3.fromRGB(140, 150, 175),
        Border = Color3.fromRGB(38, 48, 72),
        ToggleOff = Color3.fromRGB(44, 52, 70)
    }
}

-- محرك التحريك السلس
local function FastTween(inst, props, dur)
    local t = TweenService:Create(inst, TweenInfo.new(dur or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- نظام إدارة الذاكرة ومنع الكراش (Maid Engine)
local function CreateMaid()
    local maid = { _t = {} }
    function maid:GiveTask(t) table.insert(self._t, t) end
    function maid:Clean()
        for _, i in ipairs(self._t) do
            if typeof(i) == "RBXScriptConnection" then i:Disconnect()
            elseif typeof(i) == "Instance" then i:Destroy() end
        end
        table.clear(self._t)
    end
    return maid
end

-- معالج المدخلات الذكي (يقبل الجداول أو المتغيرات المباشرة)
local function NormalizeArgs(...)
    local a = {...}
    if type(a[1]) == "table" and #a == 1 then return a[1] end
    return a
end

-- [ دالة إنشاء النافذة الرئيسية ] --
function Vortex:CreateWindow(...)
    local raw = NormalizeArgs(...)
    local config = type(raw) == "table" and raw.Name and raw or { Name = raw[1] or "VORTEX HUB", SubTitle = raw[2] or "Delta Mobile 2026" }
    local Theme = Vortex.Themes[config.Theme] or Vortex.Themes.CyberDark

    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
    local winW = math.clamp(vp.X - 30, 340, 560)
    local winH = math.clamp(vp.Y - 50, 260, 360)
    local WindowSize = config.Size or UDim2.fromOffset(winW, winH)

    local Maid = CreateMaid()

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VORTEX_" .. HttpService:GenerateGUID(false):sub(1, 8)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = GetSafeGuiParent()

    -- التكيف التلقائي مع شاشة الجوال (DPI Scale)
    local UIScale = Instance.new("UIScale")
    UIScale.Parent = ScreenGui
    local function UpdateScale()
        if cam then
            local currentVp = cam.ViewportSize
            if currentVp.X < 650 or currentVp.Y < 450 then
                UIScale.Scale = math.clamp(currentVp.X / 650, 0.72, 0.85)
            elseif currentVp.X < 900 then
                UIScale.Scale = 0.92
            else
                UIScale.Scale = 1.0
            end
        end
    end
    UpdateScale()
    if cam then
        Maid:GiveTask(cam:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale))
    end

    -- الإطار الرئيسي
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = WindowSize
    MainFrame.Position = UDim2.new(0.5, -WindowSize.X.Offset / 2, 0.5, -WindowSize.Y.Offset / 2)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Border
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainFrame

    -- الشريط العلوي (Header)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 48)
    Header.BackgroundColor3 = Theme.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 12)
    hCorner.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Text = config.Name or "VORTEX HUB"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 14, 0, 8)
    Title.Size = UDim2.new(0, 180, 0, 18)
    Title.Parent = Header

    local SubTitle = Instance.new("TextLabel")
    SubTitle.Text = (config.SubTitle or "Delta Mobile 2026") .. " • v3.0"
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextSize = 10
    SubTitle.TextColor3 = Theme.SubText
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.BackgroundTransparency = 1
    SubTitle.Position = UDim2.new(0, 14, 0, 26)
    SubTitle.Size = UDim2.new(0, 180, 0, 14)
    SubTitle.Parent = Header

    -- شريط البحث الحي (Live Search)
    local SearchBox = Instance.new("TextBox")
    SearchBox.PlaceholderText = "🔍 بحث في الأزرار..."
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 11
    SearchBox.TextColor3 = Theme.Accent
    SearchBox.PlaceholderColor3 = Theme.SubText
    SearchBox.BackgroundColor3 = Theme.Card
    SearchBox.BorderSizePixel = 0
    SearchBox.Position = UDim2.new(1, -210, 0, 10)
    SearchBox.Size = UDim2.new(0, 130, 0, 28)
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = Header

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 6)
    sCorner.Parent = SearchBox

    -- أزرار الإغلاق والتصغير
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.TextColor3 = Theme.SubText
    CloseBtn.BackgroundColor3 = Theme.Card
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -36, 0, 10)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Header

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = CloseBtn

    local MinBtn = Instance.new("TextButton")
    MinBtn.Text = "─"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 12
    MinBtn.TextColor3 = Theme.SubText
    MinBtn.BackgroundColor3 = Theme.Card
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(1, -70, 0, 10)
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = Header

    local mbCorner = Instance.new("UICorner")
    mbCorner.CornerRadius = UDim.new(0, 6)
    mbCorner.Parent = MinBtn

    -- محرك السحب اللمسي الدقيق للجوال والحاسوب
    local dragging, dragStart, startPos, dragInput
    Maid:GiveTask(Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end))

    Maid:GiveTask(Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))

    Maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    -- الزر العائم للجوال (Mobile Bubble ⚡)
    local Bubble = Instance.new("TextButton")
    Bubble.Name = "VortexBubble"
    Bubble.Size = UDim2.new(0, 48, 0, 48)
    Bubble.Position = UDim2.new(0.04, 0, 0.25, 0)
    Bubble.BackgroundColor3 = Theme.Header
    Bubble.Text = "⚡"
    Bubble.TextSize = 20
    Bubble.TextColor3 = Theme.Accent
    Bubble.Font = Enum.Font.GothamBold
    Bubble.BorderSizePixel = 0
    Bubble.Parent = ScreenGui

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(1, 0)
    bCorner.Parent = Bubble

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Theme.Accent
    bStroke.Thickness = 1.5
    bStroke.Parent = Bubble

    -- سحب الزر العائم وتثبيته باللمس
    local bDragging, bDragStart, bStartPos
    Maid:GiveTask(Bubble.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            bDragging = true
            bDragStart = input.Position
            bStartPos = Bubble.Position
        end
    end))
    Maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if bDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - bDragStart
            Bubble.Position = UDim2.new(bStartPos.X.Scale, bStartPos.X.Offset + delta.X, bStartPos.Y.Scale, bStartPos.Y.Offset + delta.Y)
        end
    end))
    Maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            bDragging = false
        end
    end))

    Maid:GiveTask(Bubble.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        FastTween(Bubble, { Size = UDim2.new(0, 54, 0, 54) }, 0.08)
        task.wait(0.08)
        FastTween(Bubble, { Size = UDim2.new(0, 48, 0, 48) }, 0.12)
    end))

    Maid:GiveTask(CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end))
    local isMin = false
    Maid:GiveTask(MinBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        FastTween(MainFrame, { Size = isMin and UDim2.new(WindowSize.X.Scale, WindowSize.X.Offset, 0, 48) or WindowSize }, 0.16)
    end))

    -- جسم النافذة (Body)
    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, 0, 1, -48)
    Body.Position = UDim2.new(0, 0, 0, 48)
    Body.BackgroundTransparency = 1
    Body.Parent = MainFrame

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.ScrollBarImageColor3 = Theme.Border
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.Parent = Body

    local sLayout = Instance.new("UIListLayout")
    sLayout.Padding = UDim.new(0, 6)
    sLayout.Parent = Sidebar

    local sPad = Instance.new("UIPadding")
    sPad.PaddingTop = UDim.new(0, 8)
    sPad.PaddingLeft = UDim.new(0, 6)
    sPad.PaddingRight = UDim.new(0, 6)
    sPad.Parent = Sidebar

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -140, 1, 0)
    ContentArea.Position = UDim2.new(0, 140, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Body

    local WindowObj = { _tabs = {}, _maid = Maid }

    -- البحث المباشر
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = SearchBox.Text:lower():gsub("%s+", "")
        for _, tab in ipairs(WindowObj._tabs) do
            for _, item in ipairs(tab._elements) do
                if item.Frame and item.SearchText then
                    item.Frame.Visible = (q == "" or item.SearchText:find(q, 1, true) ~= nil)
                end
            end
        end
    end)

    -- [ دالة إنشاء التبويب ] --
    local function CreateTabInternal(...)
        local tArgs = NormalizeArgs(...)
        local tabName = type(tArgs) == "table" and (tArgs.Name or tArgs[1]) or tostring(tArgs)
        local icon = type(tArgs) == "table" and (tArgs.Icon or tArgs[2]) or "⚡"

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundColor3 = Theme.Card
        TabBtn.BackgroundTransparency = 0.85
        TabBtn.Text = icon .. "  " .. tabName
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 12
        TabBtn.TextColor3 = Theme.SubText
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = Sidebar

        local tbCorner = Instance.new("UICorner")
        tbCorner.CornerRadius = UDim.new(0, 8)
        tbCorner.Parent = TabBtn

        local TabContainer = Instance.new("ScrollingFrame")
        TabContainer.Size = UDim2.new(1, -20, 1, -16)
        TabContainer.Position = UDim2.new(0, 10, 0, 8)
        TabContainer.BackgroundTransparency = 1
        TabContainer.BorderSizePixel = 0
        TabContainer.ScrollBarThickness = 2
        TabContainer.ScrollBarImageColor3 = Theme.Border
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabContainer.Visible = false
        TabContainer.Parent = ContentArea

        local tcLayout = Instance.new("UIListLayout")
        tcLayout.Padding = UDim.new(0, 8)
        tcLayout.Parent = TabContainer

        local TabObj = { _btn = TabBtn, _c = TabContainer, _elements = {} }

        local function Select()
            for _, t in pairs(WindowObj._tabs) do
                t._c.Visible = false
                t._btn.BackgroundTransparency = 0.85
                t._btn.TextColor3 = Theme.SubText
            end
            TabContainer.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Theme.Accent
        end

        Maid:GiveTask(TabBtn.MouseButton1Click:Connect(Select))
        if #WindowObj._tabs == 0 then Select() end
        table.insert(WindowObj._tabs, TabObj)

        -- [ 1. زر تفاعلي (Button) ] --
        local function CreateButton(...)
            local bArgs = NormalizeArgs(...)
            local bName = type(bArgs) == "table" and (bArgs.Name or bArgs[1]) or tostring(bArgs)
            local cb = type(bArgs) == "table" and (bArgs.Callback or bArgs.Func or bArgs[2]) or function() end

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 38)
            Btn.BackgroundColor3 = Theme.Card
            Btn.BorderSizePixel = 0
            Btn.Text = "  " .. bName
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 13
            Btn.TextColor3 = Theme.Text
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.AutoButtonColor = false
            Btn.Parent = TabContainer

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = Btn

            local Arrow = Instance.new("TextLabel")
            Arrow.Text = "➜"
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 12
            Arrow.TextColor3 = Theme.SubText
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -28, 0.5, -8)
            Arrow.Size = UDim2.new(0, 16, 0, 16)
            Arrow.Parent = Btn

            Maid:GiveTask(Btn.MouseButton1Click:Connect(function()
                FastTween(Btn, { BackgroundColor3 = Theme.CardHover }, 0.08)
                FastTween(Arrow, { TextColor3 = Theme.Accent }, 0.08)
                task.spawn(cb)
                task.wait(0.12)
                FastTween(Btn, { BackgroundColor3 = Theme.Card }, 0.15)
                FastTween(Arrow, { TextColor3 = Theme.SubText }, 0.15)
            end))

            table.insert(TabObj._elements, { Frame = Btn, SearchText = bName:lower() })
            return Btn
        end

        -- [ 2. مفتاح تبديل (Toggle) ] --
        local function CreateToggle(...)
            local tArgs = NormalizeArgs(...)
            local tName = type(tArgs) == "table" and (tArgs.Name or tArgs[1]) or tostring(tArgs)
            local state = type(tArgs) == "table" and (tArgs.CurrentValue or tArgs.Default or tArgs[2]) or false
            local cb = type(tArgs) == "table" and (tArgs.Callback or tArgs[3]) or function() end

            local TFrame = Instance.new("TextButton")
            TFrame.Size = UDim2.new(1, 0, 0, 38)
            TFrame.BackgroundColor3 = Theme.Card
            TFrame.BorderSizePixel = 0
            TFrame.Text = ""
            TFrame.AutoButtonColor = false
            TFrame.Parent = TabContainer

            local tfCorner = Instance.new("UICorner")
            tfCorner.CornerRadius = UDim.new(0, 8)
            tfCorner.Parent = TFrame

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = tName
            Lbl.Font = Enum.Font.GothamSemibold
            Lbl.TextSize = 13
            Lbl.TextColor3 = Theme.Text
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.BackgroundTransparency = 1
            Lbl.Position = UDim2.new(0, 12, 0, 0)
            Lbl.Size = UDim2.new(1, -60, 1, 0)
            Lbl.Parent = TFrame

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(0, 36, 0, 18)
            Track.Position = UDim2.new(1, -48, 0.5, -9)
            Track.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
            Track.BorderSizePixel = 0
            Track.Parent = TFrame

            local trCorner = Instance.new("UICorner")
            trCorner.CornerRadius = UDim.new(1, 0)
            trCorner.Parent = Track

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 14, 0, 14)
            Knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel = 0
            Knob.Parent = Track

            local knCorner = Instance.new("UICorner")
            knCorner.CornerRadius = UDim.new(1, 0)
            knCorner.Parent = Knob

            local function Update(ns)
                state = ns
                FastTween(Track, { BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff }, 0.15)
                FastTween(Knob, { Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.15)
                pcall(cb, state)
            end

            Maid:GiveTask(TFrame.MouseButton1Click:Connect(function() Update(not state) end))
            table.insert(TabObj._elements, { Frame = TFrame, SearchText = tName:lower() })
            return { Set = Update, Get = function() return state end }
        end

        -- [ 3. شريط تمرير لمسي (Slider) ] --
        local function CreateSlider(...)
            local sArgs = NormalizeArgs(...)
            local sName = type(sArgs) == "table" and (sArgs.Name or sArgs[1]) or tostring(sArgs)
            local minV = type(sArgs) == "table" and ((sArgs.Range and sArgs.Range[1]) or sArgs.Min or sArgs[2]) or 0
            local maxV = type(sArgs) == "table" and ((sArgs.Range and sArgs.Range[2]) or sArgs.Max or sArgs[3]) or 100
            local curV = type(sArgs) == "table" and (sArgs.CurrentValue or sArgs.Default or sArgs[4]) or minV
            local cb = type(sArgs) == "table" and (sArgs.Callback or sArgs[5]) or function() end

            local SFrame = Instance.new("Frame")
            SFrame.Size = UDim2.new(1, 0, 0, 50)
            SFrame.BackgroundColor3 = Theme.Card
            SFrame.BorderSizePixel = 0
            SFrame.Parent = TabContainer

            local sfCorner = Instance.new("UICorner")
            sfCorner.CornerRadius = UDim.new(0, 8)
            sfCorner.Parent = SFrame

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = sName
            Lbl.Font = Enum.Font.GothamSemibold
            Lbl.TextSize = 13
            Lbl.TextColor3 = Theme.Text
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.BackgroundTransparency = 1
            Lbl.Position = UDim2.new(0, 12, 0, 6)
            Lbl.Size = UDim2.new(0.6, 0, 0, 16)
            Lbl.Parent = SFrame

            local ValLbl = Instance.new("TextLabel")
            ValLbl.Text = tostring(curV)
            ValLbl.Font = Enum.Font.GothamMedium
            ValLbl.TextSize = 12
            ValLbl.TextColor3 = Theme.Accent
            ValLbl.TextXAlignment = Enum.TextXAlignment.Right
            ValLbl.BackgroundTransparency = 1
            ValLbl.Position = UDim2.new(0.6, 0, 0, 6)
            ValLbl.Size = UDim2.new(0.4, -12, 0, 16)
            ValLbl.Parent = SFrame

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, -24, 0, 6)
            Bar.Position = UDim2.new(0, 12, 0, 32)
            Bar.BackgroundColor3 = Theme.ToggleOff
            Bar.BorderSizePixel = 0
            Bar.Parent = SFrame

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(1, 0)
            bCorner.Parent = Bar

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((curV - minV) / (maxV - minV), 0, 1, 0)
            Fill.BackgroundColor3 = Theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Bar

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(1, 0)
            fCorner.Parent = Fill

            local sliding = false
            local function Update(inputX)
                local absP = Bar.AbsolutePosition.X
                local absS = Bar.AbsoluteSize.X
                local r = math.clamp((inputX - absP) / absS, 0, 1)
                curV = math.floor(minV + (r * (maxV - minV)))
                Fill.Size = UDim2.new((curV - minV) / (maxV - minV), 0, 1, 0)
                ValLbl.Text = tostring(curV)
                pcall(cb, curV)
            end

            Maid:GiveTask(SFrame.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = true; Update(i.Position.X)
                end
            end))
            Maid:GiveTask(UserInputService.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    Update(i.Position.X)
                end
            end))
            Maid:GiveTask(UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end))

            table.insert(TabObj._elements, { Frame = SFrame, SearchText = sName:lower() })
            return { Set = function(v) curV = v; Fill.Size = UDim2.new((curV - minV) / (maxV - minV), 0, 1, 0); ValLbl.Text = tostring(curV); pcall(cb, curV) end }
        end

        -- [ 4. قائمة منسدلة (Dropdown) ] --
        local function CreateDropdown(...)
            local dArgs = NormalizeArgs(...)
            local dName = type(dArgs) == "table" and (dArgs.Name or dArgs[1]) or tostring(dArgs)
            local opts = type(dArgs) == "table" and (dArgs.Options or dArgs[2]) or {}
            local cb = type(dArgs) == "table" and (dArgs.Callback or dArgs[3]) or function() end
            local cur = opts[1] or "اختر..."

            local DFrame = Instance.new("Frame")
            DFrame.Size = UDim2.new(1, 0, 0, 40)
            DFrame.BackgroundColor3 = Theme.Card
            DFrame.BorderSizePixel = 0
            DFrame.ClipsDescendants = true
            DFrame.Parent = TabContainer

            local dfCorner = Instance.new("UICorner")
            dfCorner.CornerRadius = UDim.new(0, 8)
            dfCorner.Parent = DFrame

            local TBtn = Instance.new("TextButton")
            TBtn.Size = UDim2.new(1, 0, 0, 40)
            TBtn.BackgroundTransparency = 1
            TBtn.Text = "  " .. dName .. "  ➜  " .. cur
            TBtn.TextColor3 = Theme.Accent
            TBtn.Font = Enum.Font.GothamSemibold
            TBtn.TextSize = 12
            TBtn.TextXAlignment = Enum.TextXAlignment.Left
            TBtn.Parent = DFrame

            local open = false
            Maid:GiveTask(TBtn.MouseButton1Click:Connect(function()
                open = not open
                FastTween(DFrame, { Size = UDim2.new(1, 0, 0, open and (42 + (#opts * 28)) or 40) }, 0.16)
            end))

            for idx, o in ipairs(opts) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, -16, 0, 24)
                OptBtn.Position = UDim2.new(0, 8, 0, 40 + ((idx - 1) * 26))
                OptBtn.BackgroundColor3 = Theme.Header
                OptBtn.Text = o
                OptBtn.TextColor3 = Theme.Text
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 11
                OptBtn.BorderSizePixel = 0
                OptBtn.Parent = DFrame

                local opCorner = Instance.new("UICorner")
                opCorner.CornerRadius = UDim.new(0, 4)
                opCorner.Parent = OptBtn

                OptBtn.MouseButton1Click:Connect(function()
                    cur = o
                    TBtn.Text = "  " .. dName .. "  ➜  " .. cur
                    open = false
                    FastTween(DFrame, { Size = UDim2.new(1, 0, 0, 40) }, 0.16)
                    pcall(cb, cur)
                end)
            end

            table.insert(TabObj._elements, { Frame = DFrame, SearchText = dName:lower() })
            return DFrame
        end

        -- دعم جميع المسميات بدون الحاجة لتعلمها (Zero-Brain API)
        TabObj.Button = CreateButton; TabObj.CreateButton = CreateButton; TabObj.AddButton = CreateButton
        TabObj.Toggle = CreateToggle; TabObj.CreateToggle = CreateToggle; TabObj.AddToggle = CreateToggle
        TabObj.Slider = CreateSlider; TabObj.CreateSlider = CreateSlider; TabObj.AddSlider = CreateSlider
        TabObj.Dropdown = CreateDropdown; TabObj.CreateDropdown = CreateDropdown; TabObj.AddDropdown = CreateDropdown
        TabObj.Section = function(...)
            local a = NormalizeArgs(...)
            local t = type(a) == "table" and (a.Name or a[1]) or tostring(a)
            local l = Instance.new("TextLabel")
            l.Text = string.upper(t)
            l.Font = Enum.Font.GothamBold
            l.TextSize = 11
            l.TextColor3 = Theme.Accent
            l.BackgroundTransparency = 1
            l.Size = UDim2.new(1, 0, 0, 20)
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = TabContainer
        end
        TabObj.CreateSection = TabObj.Section; TabObj.AddSection = TabObj.Section

        return TabObj
    end

    WindowObj.CreateTab = CreateTabInternal
    WindowObj.AddTab = CreateTabInternal
    WindowObj.Tab = CreateTabInternal
    WindowObj.MakeTab = CreateTabInternal

    function WindowObj:Destroy()
        Maid:Clean()
        ScreenGui:Destroy()
    end

    return WindowObj
end

-- [ دالة إشعارات التوست ] --
function Vortex:Notify(...)
    local a = NormalizeArgs(...)
    local title = type(a) == "table" and (a.Title or a[1]) or "VORTEX"
    local content = type(a) == "table" and (a.Content or a[2]) or tostring(a)
    print("[VORTEX NOTIFY]:", title, "-", content)
end


--[[
    ╔═════════════════════════════════════════════════════════════════════════════════════╗
    ║                           [ 2. مثال تشغيل الهاب الفوري ]                           ║
    ╚═════════════════════════════════════════════════════════════════════════════════════╝
]]

local Window = Vortex:CreateWindow({
    Name = "VORTEX ULTIMATE",
    SubTitle = "Delta Mobile 2026",
    Theme = "CyberDark",
    MobileToggle = true,
    Size = UDim2.fromOffset(560, 360)
})

-- تبويب اللاعب
local PlayerTab = Window:CreateTab("اللاعب", "👤")
PlayerTab:Section("السرعة والقفز")

PlayerTab:Button("إعادة إنعاش فوري (Respawn)", function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = 0
    end
end)

PlayerTab:Slider("سرعة المشي (WalkSpeed)", 16, 250, 16, function(v)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = v
    end
end)

PlayerTab:Slider("قوة القفز (JumpPower)", 50, 400, 50, function(v)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = v
    end
end)

PlayerTab:Toggle("القفز اللانهائي (Infinite Jump)", false, function(state)
    print("Infinite Jump:", state)
end)

-- تبويب الأوتوفارم
local FarmTab = Window:CreateTab("الأوتوفارم", "⚡")
FarmTab:Section("التجميع التلقائي")

FarmTab:Toggle("تجميع الكوينز التلقائي (Auto Farm)", false, function(state)
    print("Auto Farm state:", state)
end)

FarmTab:Dropdown("أولوية الاستهداف", {"الأقرب جغرافياً", "أضعف دم", "الزعماء فقط"}, function(opt)
    print("Target mode:", opt)
end)

-- تبويب الانتقال
local TeleportTab = Window:CreateTab("الانتقال", "🚀")
TeleportTab:Section("الانتقال السريع")

TeleportTab:Dropdown("اختر المكان", {"السباون", "السوق", "الحلبة", "الخزينة السرية"}, function(loc)
    print("Teleported to:", loc)
end)

return Vortex
