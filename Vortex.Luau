-- [[ ====================================================================
--    AURA LUXE UI LIBRARY (PRO MOBILE EDITION)
--    Optimized for Delta, Codex & Mobile Executors
--    Maximum Z-Index / IgnoreGuiInset / Full gethui Integration
--    ==================================================================== ]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- محدد الحاوية الآمنة لـ gethui
local function GetSafeParent()
    local success, result = pcall(function()
        if gethui then
            return gethui()
        end
        return CoreGui
    end)
    if success and result then
        return result
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local SafeParent = GetSafeParent()

local AuraLib = {
    Flags = {},
    CurrentScreenGui = nil,
    Theme = {
        Background = Color3.fromRGB(15, 17, 24),
        Sidebar = Color3.fromRGB(12, 14, 20),
        Card = Color3.fromRGB(22, 26, 38),
        CardHover = Color3.fromRGB(28, 33, 48),
        Stroke = Color3.fromRGB(36, 42, 60),
        Accent = Color3.fromRGB(99, 102, 241),
        AccentGradient = Color3.fromRGB(139, 92, 246),
        TextPrimary = Color3.fromRGB(248, 250, 252),
        TextSecondary = Color3.fromRGB(148, 163, 184),
        Success = Color3.fromRGB(52, 211, 153),
        Danger = Color3.fromRGB(239, 68, 68),
        Font = Enum.Font.GothamMedium,
        FontBold = Enum.Font.GothamBold
    }
}

function AuraLib:GetFlag(name)
    return self.Flags[name]
end

local function Tween(obj, props, time, style, dir)
    local tweenInfo = TweenInfo.new(time or 0.22, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, tweenInfo, props)
    t:Play()
    return t
end

-- نظام سحب لمسي محسّن يدعم شاشات الهواتف دون تجميد
local function MakeDraggable(dragHandle, targetFrame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function AuraLib:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "AURA LUXE"
    local Subtitle = config.Subtitle or "Mobile Edition"

    local Window = { CurrentTab = nil }

    -- تمويه الإضاءة
    local Blur = Instance.new("BlurEffect")
    Blur.Name = "AuraLoadingBlur"
    Blur.Size = 56
    pcall(function()
        Blur.Parent = Lighting
    end)

    -- الشاشة الرئيسية مع فرض الظهور فوق واجهات روبلوكس
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AuraLuxeUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 2147483647
    ScreenGui.Parent = SafeParent
    AuraLib.CurrentScreenGui = ScreenGui

    ScreenGui.Destroying:Connect(function()
        pcall(function()
            if Blur then Blur:Destroy() end
        end)
    end)

    -- شاشة التحميل (Loader Overlay)
    local LoaderFrame = Instance.new("Frame")
    LoaderFrame.Name = "LoaderFrame"
    LoaderFrame.Size = UDim2.new(1, 0, 1, 0)
    LoaderFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
    LoaderFrame.BackgroundTransparency = 0.35
    LoaderFrame.BorderSizePixel = 0
    LoaderFrame.ZIndex = 1000
    LoaderFrame.Parent = ScreenGui

    local LoaderLabel = Instance.new("TextLabel")
    LoaderLabel.Size = UDim2.new(1, 0, 0, 50)
    LoaderLabel.Position = UDim2.new(0, 0, 0.5, -25)
    LoaderLabel.BackgroundTransparency = 1
    LoaderLabel.Text = 'Initialize. "Engine"'
    LoaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoaderLabel.TextSize = 20
    LoaderLabel.Font = AuraLib.Theme.FontBold
    LoaderLabel.ZIndex = 1001
    LoaderLabel.Parent = LoaderFrame

    local NeonStroke = Instance.new("UIStroke", LoaderLabel)
    NeonStroke.Color = Color3.fromRGB(255, 255, 255)
    NeonStroke.Thickness = 1.8
    NeonStroke.Transparency = 0.25

    local isLoading = true
    local currentTask = "Engine"
    task.spawn(function()
        local dotStates = {".", "..", "..."}
        local i = 1
        while isLoading do
            LoaderLabel.Text = 'Initialize' .. dotStates[i] .. ' "' .. currentTask .. '"'
            i = (i % #dotStates) + 1
            task.wait(0.08)
        end
    end)

    local function StepLoad(taskName)
        currentTask = taskName
        task.wait(0.02)
    end

    -- زر عائم آمن لموضع أزرار روبلوكس
    local MobileToggle = Instance.new("TextButton")
    MobileToggle.Name = "MobileToggle"
    MobileToggle.Size = UDim2.new(0, 42, 0, 42)
    MobileToggle.Position = UDim2.new(0, 20, 0, 65)
    MobileToggle.BackgroundColor3 = AuraLib.Theme.Card
    MobileToggle.Text = "⚡"
    MobileToggle.TextColor3 = AuraLib.Theme.Accent
    MobileToggle.TextSize = 18
    MobileToggle.Font = AuraLib.Theme.FontBold
    MobileToggle.Visible = false
    MobileToggle.ZIndex = 500
    MobileToggle.Parent = ScreenGui

    Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(1, 0)
    local ToggleStroke = Instance.new("UIStroke", MobileToggle)
    ToggleStroke.Color = AuraLib.Theme.Accent
    ToggleStroke.Thickness = 1.4
    MakeDraggable(MobileToggle, MobileToggle)

    -- الإطار الرئيسي
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 480, 0, 270)
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -135)
    MainFrame.BackgroundColor3 = AuraLib.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.ZIndex = 10
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = AuraLib.Theme.Stroke
    MainStroke.Thickness = 1.2

    -- شريط العنوان
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 11
    Header.Parent = MainFrame
    MakeDraggable(Header, MainFrame)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 0, 20)
    TitleLabel.Position = UDim2.new(0, 14, 0, 6)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = AuraLib.Theme.TextPrimary
    TitleLabel.TextSize = 14
    TitleLabel.Font = AuraLib.Theme.FontBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 12
    TitleLabel.Parent = Header

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0, 200, 0, 12)
    SubLabel.Position = UDim2.new(0, 14, 0, 24)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = Subtitle
    SubLabel.TextColor3 = AuraLib.Theme.Accent
    SubLabel.TextSize = 9
    SubLabel.Font = AuraLib.Theme.Font
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.ZIndex = 12
    SubLabel.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -34, 0, 8)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = AuraLib.Theme.TextSecondary
    CloseBtn.TextSize = 12
    CloseBtn.Font = AuraLib.Theme.FontBold
    CloseBtn.ZIndex = 12
    CloseBtn.Parent = Header

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.22)
        task.wait(0.23)
        if Blur then Blur:Destroy() end
        ScreenGui:Destroy()
    end)

    local isVisible = true
    MobileToggle.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        if isVisible then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 480, 0, 270)}, 0.2)
        else
            local t = Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            t.Completed:Connect(function()
                if not isVisible then MainFrame.Visible = false end
            end)
        end
    end)

    -- الشريط الجانبي
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 120, 1, -50)
    Sidebar.Position = UDim2.new(0, 8, 0, 42)
    Sidebar.BackgroundColor3 = AuraLib.Theme.Sidebar
    Sidebar.ZIndex = 11
    Sidebar.Parent = MainFrame

    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -6, 1, -6)
    TabScroll.Position = UDim2.new(0, 3, 0, 3)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.ZIndex = 12
    TabScroll.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout", TabScroll)
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- مساحة المحتوى
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -140, 1, -50)
    ContentHolder.Position = UDim2.new(0, 134, 0, 42)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.ZIndex = 11
    ContentHolder.Parent = MainFrame

    function Window:Ready()
        StepLoad("Finalizing")
        task.wait(0.2)
        isLoading = false

        if Blur then Tween(Blur, {Size = 0}, 0.35) end
        Tween(LoaderFrame, {BackgroundTransparency = 1}, 0.3)
        Tween(LoaderLabel, {TextTransparency = 1}, 0.3)
        Tween(NeonStroke, {Transparency = 1}, 0.3)

        task.delay(0.35, function()
            if Blur then Blur:Destroy() end
            LoaderFrame:Destroy()
            MobileToggle.Visible = true
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            Tween(MainFrame, {Size = UDim2.new(0, 480, 0, 270)}, 0.25)
        end)
    end

    function Window:CreateTab(tabName)
        StepLoad(tabName .. " Tab")
        local Tab = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 28)
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "  " .. tabName
        TabBtn.TextColor3 = AuraLib.Theme.TextSecondary
        TabBtn.TextSize = 11
        TabBtn.Font = AuraLib.Theme.Font
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.ZIndex = 13
        TabBtn.Parent = TabScroll

        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = AuraLib.Theme.Stroke
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.ZIndex = 12
        Page.Parent = ContentHolder

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 4)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local PagePadding = Instance.new("UIPadding", Page)
        PagePadding.PaddingRight = UDim.new(0, 4)
        PagePadding.PaddingBottom = UDim.new(0, 8)

        local function ActivateTab()
            if Window.CurrentTab then
                Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1, TextColor3 = AuraLib.Theme.TextSecondary}, 0.2)
                Window.CurrentTab.Page.Visible = false
            end
            Window.CurrentTab = {Button = TabBtn, Page = Page}
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0, BackgroundColor3 = AuraLib.Theme.Card, TextColor3 = AuraLib.Theme.TextPrimary}, 0.2)
        end

        TabBtn.MouseButton1Click:Connect(ActivateTab)

        if Window.CurrentTab == nil then
            ActivateTab()
        end

        -- 1. زر تنفيذي
        function Tab:CreateButton(btnConfig)
            local btnName = btnConfig.Name or "Button"
            StepLoad(btnName)
            local callback = btnConfig.Callback or function() end

            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 24)
            BtnFrame.BackgroundColor3 = AuraLib.Theme.Card
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            BtnFrame.ZIndex = 13
            BtnFrame.Parent = Page

            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 6)
            local Stroke = Instance.new("UIStroke", BtnFrame)
            Stroke.Color = AuraLib.Theme.Stroke
            Stroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -30, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = btnName
            Label.TextColor3 = AuraLib.Theme.TextPrimary
            Label.TextSize = 10
            Label.Font = AuraLib.Theme.Font
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 14
            Label.Parent = BtnFrame

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 16, 1, 0)
            Arrow.Position = UDim2.new(1, -22, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = ">"
            Arrow.TextColor3 = AuraLib.Theme.TextSecondary
            Arrow.TextSize = 10
            Arrow.Font = AuraLib.Theme.FontBold
            Arrow.ZIndex = 14
            Arrow.Parent = BtnFrame

            BtnFrame.MouseButton1Down:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = AuraLib.Theme.CardHover}, 0.1)
            end)

            BtnFrame.MouseButton1Up:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = AuraLib.Theme.Card}, 0.15)
                pcall(callback)
            end)
        end

        -- 2. زر تبديل
        function Tab:CreateToggle(tglConfig)
            local tglName = tglConfig.Name or "Toggle"
            StepLoad(tglName)

            local default = tglConfig.Default or false
            local callback = tglConfig.Callback or function() end
            local state = default
            AuraLib.Flags[tglName] = state

            local TglFrame = Instance.new("TextButton")
            TglFrame.Size = UDim2.new(1, 0, 0, 24)
            TglFrame.BackgroundColor3 = AuraLib.Theme.Card
            TglFrame.Text = ""
            TglFrame.AutoButtonColor = false
            TglFrame.ZIndex = 13
            TglFrame.Parent = Page

            Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)
            local Stroke = Instance.new("UIStroke", TglFrame)
            Stroke.Color = AuraLib.Theme.Stroke
            Stroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -40, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = tglName
            Label.TextColor3 = AuraLib.Theme.TextPrimary
            Label.TextSize = 10
            Label.Font = AuraLib.Theme.Font
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 14
            Label.Parent = TglFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 24, 0, 13)
            Switch.Position = UDim2.new(1, -32, 0.5, -6)
            Switch.BackgroundColor3 = state and AuraLib.Theme.Accent or Color3.fromRGB(35, 40, 55)
            Switch.ZIndex = 14
            Switch.Parent = TglFrame
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 9, 0, 9)
            Knob.Position = state and UDim2.new(1, -11, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.ZIndex = 15
            Knob.Parent = Switch
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

            local function UpdateState()
                AuraLib.Flags[tglName] = state
                if state then
                    Tween(Switch, {BackgroundColor3 = AuraLib.Theme.Accent}, 0.2)
                    Tween(Knob, {Position = UDim2.new(1, -11, 0.5, -4)}, 0.2)
                else
                    Tween(Switch, {BackgroundColor3 = Color3.fromRGB(35, 40, 55)}, 0.2)
                    Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -4)}, 0.2)
                end
                pcall(callback, state)
            end

            TglFrame.MouseButton1Click:Connect(function()
                state = not state
                UpdateState()
            end)
        end

        -- 3. سلايدر
        function Tab:CreateSlider(sldConfig)
            local sldName = sldConfig.Name or "Slider"
            StepLoad(sldName)

            local min = sldConfig.Min or 0
            local max = sldConfig.Max or 100
            local default = math.clamp(sldConfig.Default or min, min, max)
            local callback = sldConfig.Callback or function() end
            local value = default
            AuraLib.Flags[sldName] = value

            local SldFrame = Instance.new("Frame")
            SldFrame.Size = UDim2.new(1, 0, 0, 30)
            SldFrame.BackgroundColor3 = AuraLib.Theme.Card
            SldFrame.ZIndex = 13
            SldFrame.Parent = Page

            Instance.new("UICorner", SldFrame).CornerRadius = UDim.new(0, 6)
            local Stroke = Instance.new("UIStroke", SldFrame)
            Stroke.Color = AuraLib.Theme.Stroke
            Stroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -55, 0, 14)
            Label.Position = UDim2.new(0, 10, 0, 3)
            Label.BackgroundTransparency = 1
            Label.Text = sldName
            Label.TextColor3 = AuraLib.Theme.TextPrimary
            Label.TextSize = 10
            Label.Font = AuraLib.Theme.Font
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 14
            Label.Parent = SldFrame

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0, 45, 0, 14)
            ValLabel.Position = UDim2.new(1, -52, 0, 3)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(value)
            ValLabel.TextColor3 = AuraLib.Theme.Accent
            ValLabel.TextSize = 10
            ValLabel.Font = AuraLib.Theme.FontBold
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.ZIndex = 14
            ValLabel.Parent = SldFrame

            local SliderBar = Instance.new("TextButton")
            SliderBar.Size = UDim2.new(1, -20, 0, 6)
            SliderBar.Position = UDim2.new(0, 10, 0, 19)
            SliderBar.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
            SliderBar.Text = ""
            SliderBar.AutoButtonColor = false
            SliderBar.ZIndex = 14
            SliderBar.Parent = SldFrame
            Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = AuraLib.Theme.Accent
            Fill.BorderSizePixel = 0
            Fill.ZIndex = 15
            Fill.Parent = SliderBar
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local sliding = false
            local function Move(input)
                local posX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                value = math.floor(min + ((max - min) * posX))
                ValLabel.Text = tostring(value)
                Fill.Size = UDim2.new(posX, 0, 1, 0)
                AuraLib.Flags[sldName] = value
                pcall(callback, value)
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    Move(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Move(input)
                end
            end)
        end

        -- 4. إدخال نصي
        function Tab:CreateInput(inpConfig)
            local inpName = inpConfig.Name or "Input"
            StepLoad(inpName)

            local placeholder = inpConfig.Placeholder or "Enter text..."
            local callback = inpConfig.Callback or function() end
            AuraLib.Flags[inpName] = ""

            local InpFrame = Instance.new("Frame")
            InpFrame.Size = UDim2.new(1, 0, 0, 24)
            InpFrame.BackgroundColor3 = AuraLib.Theme.Card
            InpFrame.ZIndex = 13
            InpFrame.Parent = Page

            Instance.new("UICorner", InpFrame).CornerRadius = UDim.new(0, 6)
            local Stroke = Instance.new("UIStroke", InpFrame)
            Stroke.Color = AuraLib.Theme.Stroke
            Stroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.45, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = inpName
            Label.TextColor3 = AuraLib.Theme.TextPrimary
            Label.TextSize = 10
            Label.Font = AuraLib.Theme.Font
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 14
            Label.Parent = InpFrame

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(0.48, 0, 0, 18)
            TextBox.Position = UDim2.new(0.5, 0, 0.5, -9)
            TextBox.BackgroundColor3 = AuraLib.Theme.Sidebar
            TextBox.PlaceholderText = placeholder
            TextBox.PlaceholderColor3 = AuraLib.Theme.TextSecondary
            TextBox.Text = ""
            TextBox.TextColor3 = AuraLib.Theme.TextPrimary
            TextBox.TextSize = 9
            TextBox.Font = AuraLib.Theme.Font
            TextBox.ClearTextOnFocus = false
            TextBox.ZIndex = 14
            TextBox.Parent = InpFrame

            Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)

            TextBox.FocusLost:Connect(function()
                AuraLib.Flags[inpName] = TextBox.Text
                pcall(callback, TextBox.Text)
            end)
        end

        -- 5. قائمة منسدلة
        function Tab:CreateDropdown(drpConfig)
            local drpName = drpConfig.Name or "Dropdown"
            StepLoad(drpName)

            local options = drpConfig.Options or {}
            local current = drpConfig.Default or (options[1] or "Select...")
            local callback = drpConfig.Callback or function() end
            local isOpen = false
            AuraLib.Flags[drpName] = current

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 24)
            Container.BackgroundColor3 = AuraLib.Theme.Card
            Container.ClipsDescendants = true
            Container.ZIndex = 13
            Container.Parent = Page

            Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
            local Stroke = Instance.new("UIStroke", Container)
            Stroke.Color = AuraLib.Theme.Stroke
            Stroke.Thickness = 1

            local MainBtn = Instance.new("TextButton")
            MainBtn.Size = UDim2.new(1, 0, 0, 24)
            MainBtn.BackgroundTransparency = 1
            MainBtn.Text = ""
            MainBtn.ZIndex = 14
            MainBtn.Parent = Container

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 0, 24)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = drpName
            Label.TextColor3 = AuraLib.Theme.TextPrimary
            Label.TextSize = 10
            Label.Font = AuraLib.Theme.Font
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 15
            Label.Parent = MainBtn

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0.42, -20, 0, 24)
            SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Text = tostring(current)
            SelectedLabel.TextColor3 = AuraLib.Theme.Accent
            SelectedLabel.TextSize = 9
            SelectedLabel.Font = AuraLib.Theme.FontBold
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            SelectedLabel.ZIndex = 15
            SelectedLabel.Parent = MainBtn

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 16, 0, 24)
            Arrow.Position = UDim2.new(1, -20, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = AuraLib.Theme.TextSecondary
            Arrow.TextSize = 8
            Arrow.Font = AuraLib.Theme.Font
            Arrow.ZIndex = 15
            Arrow.Parent = MainBtn

            local OptionsHolder = Instance.new("Frame")
            OptionsHolder.Size = UDim2.new(1, -12, 0, #options * 22)
            OptionsHolder.Position = UDim2.new(0, 6, 0, 26)
            OptionsHolder.BackgroundTransparency = 1
            OptionsHolder.ZIndex = 14
            OptionsHolder.Parent = Container

            local OptLayout = Instance.new("UIListLayout", OptionsHolder)
            OptLayout.Padding = UDim.new(0, 2)

            local function ToggleMenu()
                isOpen = not isOpen
                local targetHeight = isOpen and (30 + (#options * 22)) or 24
                Tween(Container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                Arrow.Text = isOpen and "▲" or "▼"
            end

            MainBtn.MouseButton1Click:Connect(ToggleMenu)

            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 20)
                OptBtn.BackgroundColor3 = AuraLib.Theme.Sidebar
                OptBtn.Text = "  " .. tostring(opt)
                OptBtn.TextColor3 = AuraLib.Theme.TextSecondary
                OptBtn.TextSize = 9
                OptBtn.Font = AuraLib.Theme.Font
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.ZIndex = 15
                OptBtn.Parent = OptionsHolder

                Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

                OptBtn.MouseButton1Click:Connect(function()
                    current = opt
                    SelectedLabel.Text = tostring(opt)
                    AuraLib.Flags[drpName] = opt
                    ToggleMenu()
                    pcall(callback, opt)
                end)
            end
        end

        -- 6. اختصار كيبورد
        function Tab:CreateKeybind(kbConfig)
            local kbName = kbConfig.Name or "Keybind"
            StepLoad(kbName)

            local defaultKey = kbConfig.Default or "E"
            local currentKey = typeof(defaultKey) == "EnumItem" and defaultKey.Name or tostring(defaultKey)
            local callback = kbConfig.Callback or function() end
            local listening = false
            AuraLib.Flags[kbName] = currentKey

            local KbFrame = Instance.new("Frame")
            KbFrame.Size = UDim2.new(1, 0, 0, 24)
            KbFrame.BackgroundColor3 = AuraLib.Theme.Card
            KbFrame.ZIndex = 13
            KbFrame.Parent = Page

            Instance.new("UICorner", KbFrame).CornerRadius = UDim.new(0, 6)
            local Stroke = Instance.new("UIStroke", KbFrame)
            Stroke.Color = AuraLib.Theme.Stroke
            Stroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -70, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = kbName
            Label.TextColor3 = AuraLib.Theme.TextPrimary
            Label.TextSize = 10
            Label.Font = AuraLib.Theme.Font
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 14
            Label.Parent = KbFrame

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Size = UDim2.new(0, 52, 0, 16)
            KeyBtn.Position = UDim2.new(1, -60, 0.5, -8)
            KeyBtn.BackgroundColor3 = AuraLib.Theme.Sidebar
            KeyBtn.Text = currentKey
            KeyBtn.TextColor3 = AuraLib.Theme.Accent
            KeyBtn.TextSize = 9
            KeyBtn.Font = AuraLib.Theme.FontBold
            KeyBtn.ZIndex = 14
            KeyBtn.Parent = KbFrame

            Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 4)

            local connection
            KeyBtn.MouseButton1Click:Connect(function()
                if listening then
                    listening = false
                    KeyBtn.Text = currentKey
                    KeyBtn.TextColor3 = AuraLib.Theme.Accent
                    if connection then connection:Disconnect() end
                    return
                end

                listening = true
                KeyBtn.Text = "..."
                KeyBtn.TextColor3 = AuraLib.Theme.TextSecondary

                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode.Name
                        KeyBtn.Text = currentKey
                        KeyBtn.TextColor3 = AuraLib.Theme.Accent
                        AuraLib.Flags[kbName] = currentKey
                        listening = false
                        connection:Disconnect()
                        pcall(callback, input.KeyCode)
                    end
                end)
            end)
        end

        -- 7. محدد ألوان
        function Tab:CreateColorPicker(cpConfig)
            local cpName = cpConfig.Name or "Color Picker"
            StepLoad(cpName)

            local currentColor = cpConfig.Default or AuraLib.Theme.Accent
            local callback = cpConfig.Callback or function() end
            local isOpen = false
            AuraLib.Flags[cpName] = currentColor

            local palette = {
                Color3.fromRGB(99, 102, 241),
                Color3.fromRGB(139, 92, 246),
                Color3.fromRGB(236, 72, 153),
                Color3.fromRGB(239, 68, 68),
                Color3.fromRGB(245, 158, 11),
                Color3.fromRGB(16, 185, 129),
                Color3.fromRGB(6, 182, 212),
                Color3.fromRGB(255, 255, 255)
            }

            local CpContainer = Instance.new("Frame")
            CpContainer.Size = UDim2.new(1, 0, 0, 24)
            CpContainer.BackgroundColor3 = AuraLib.Theme.Card
            CpContainer.ClipsDescendants = true
            CpContainer.ZIndex = 13
            CpContainer.Parent = Page

            Instance.new("UICorner", CpContainer).CornerRadius = UDim.new(0, 6)
            local Stroke = Instance.new("UIStroke", CpContainer)
            Stroke.Color = AuraLib.Theme.Stroke
            Stroke.Thickness = 1

            local TopBtn = Instance.new("TextButton")
            TopBtn.Size = UDim2.new(1, 0, 0, 24)
            TopBtn.BackgroundTransparency = 1
            TopBtn.Text = ""
            TopBtn.ZIndex = 14
            TopBtn.Parent = CpContainer

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -40, 0, 24)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = cpName
            Label.TextColor3 = AuraLib.Theme.TextPrimary
            Label.TextSize = 10
            Label.Font = AuraLib.Theme.Font
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 15
            Label.Parent = TopBtn

            local ColorPreview = Instance.new("Frame")
            ColorPreview.Size = UDim2.new(0, 16, 0, 14)
            ColorPreview.Position = UDim2.new(1, -26, 0.5, -7)
            ColorPreview.BackgroundColor3 = currentColor
            ColorPreview.ZIndex = 15
            ColorPreview.Parent = TopBtn
            Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 4)

            local PaletteHolder = Instance.new("Frame")
            PaletteHolder.Size = UDim2.new(1, -20, 0, 24)
            PaletteHolder.Position = UDim2.new(0, 10, 0, 26)
            PaletteHolder.BackgroundTransparency = 1
            PaletteHolder.ZIndex = 14
            PaletteHolder.Parent = CpContainer

            local PalLayout = Instance.new("UIListLayout", PaletteHolder)
            PalLayout.FillDirection = Enum.FillDirection.Horizontal
            PalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            PalLayout.Padding = UDim.new(0, 6)

            for _, col in ipairs(palette) do
                local ColorBtn = Instance.new("TextButton")
                ColorBtn.Size = UDim2.new(0, 18, 0, 18)
                ColorBtn.BackgroundColor3 = col
                ColorBtn.Text = ""
                ColorBtn.AutoButtonColor = false
                ColorBtn.ZIndex = 15
                ColorBtn.Parent = PaletteHolder
                Instance.new("UICorner", ColorBtn).CornerRadius = UDim.new(1, 0)

                ColorBtn.MouseButton1Click:Connect(function()
                    currentColor = col
                    ColorPreview.BackgroundColor3 = col
                    AuraLib.Flags[cpName] = col
                    pcall(callback, col)
                end)
            end

            TopBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Tween(CpContainer, {Size = UDim2.new(1, 0, 0, isOpen and 54 or 24)}, 0.2)
            end)
        end

        -- 8. نص / فقرة
        function Tab:CreateLabel(text)
            local LblContainer = Instance.new("Frame")
            LblContainer.Size = UDim2.new(1, 0, 0, 18)
            LblContainer.BackgroundTransparency = 1
            LblContainer.ZIndex = 13
            LblContainer.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -16, 1, 0)
            Label.Position = UDim2.new(0, 8, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text or ""
            Label.TextColor3 = AuraLib.Theme.TextSecondary
            Label.TextSize = 9
            Label.Font = AuraLib.Theme.Font
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.ZIndex = 14
            Label.Parent = LblContainer
        end

        -- 9. فاصل أقسام
        function Tab:CreateSection(secName)
            local SecContainer = Instance.new("Frame")
            SecContainer.Size = UDim2.new(1, 0, 0, 20)
            SecContainer.BackgroundTransparency = 1
            SecContainer.ZIndex = 13
            SecContainer.Parent = Page

            local SecText = Instance.new("TextLabel")
            SecText.Size = UDim2.new(0, 0, 1, 0)
            SecText.Position = UDim2.new(0, 6, 0, 0)
            SecText.BackgroundTransparency = 1
            SecText.Text = string.upper(secName or "SECTION")
            SecText.TextColor3 = AuraLib.Theme.Accent
            SecText.TextSize = 9
            SecText.Font = AuraLib.Theme.FontBold
            SecText.TextXAlignment = Enum.TextXAlignment.Left
            SecText.AutomaticSize = Enum.AutomaticSize.X
            SecText.ZIndex = 14
            SecText.Parent = SecContainer

            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(0.65, 0, 0, 1)
            Line.Position = UDim2.new(0.33, 0, 0.5, 0)
            Line.BackgroundColor3 = AuraLib.Theme.Stroke
            Line.BorderSizePixel = 0
            Line.ZIndex = 14
            Line.Parent = SecContainer
        end

        return Tab
    end

    -- نظام الإشعارات
    function AuraLib:Notify(notifConfig)
        local nTitle = notifConfig.Title or "Notification"
        local nContent = notifConfig.Content or ""
        local nTime = notifConfig.Duration or 3

        local NotifCard = Instance.new("Frame")
        NotifCard.Size = UDim2.new(0, 180, 0, 48)
        NotifCard.Position = UDim2.new(1, 20, 1, -65)
        NotifCard.BackgroundColor3 = AuraLib.Theme.Card
        NotifCard.ZIndex = 2000
        NotifCard.Parent = ScreenGui

        Instance.new("UICorner", NotifCard).CornerRadius = UDim.new(0, 8)
        local NStroke = Instance.new("UIStroke", NotifCard)
        NStroke.Color = AuraLib.Theme.Accent
        NStroke.Thickness = 1.1

        local NTitle = Instance.new("TextLabel", NotifCard)
        NTitle.Size = UDim2.new(1, -16, 0, 16)
        NTitle.Position = UDim2.new(0, 8, 0, 6)
        NTitle.BackgroundTransparency = 1
        NTitle.Text = nTitle
        NTitle.TextColor3 = AuraLib.Theme.TextPrimary
        NTitle.TextSize = 11
        NTitle.Font = AuraLib.Theme.FontBold
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.ZIndex = 2001

        local NDesc = Instance.new("TextLabel", NotifCard)
        NDesc.Size = UDim2.new(1, -16, 0, 16)
        NDesc.Position = UDim2.new(0, 8, 0, 22)
        NDesc.BackgroundTransparency = 1
        NDesc.Text = nContent
        NDesc.TextColor3 = AuraLib.Theme.TextSecondary
        NDesc.TextSize = 9
        NDesc.Font = AuraLib.Theme.Font
        NDesc.TextXAlignment = Enum.TextXAlignment.Left
        NDesc.ZIndex = 2001

        Tween(NotifCard, {Position = UDim2.new(1, -195, 1, -65)}, 0.3)
        task.delay(nTime, function()
            local closeTween = Tween(NotifCard, {Position = UDim2.new(1, 20, 1, -65)}, 0.3)
            closeTween.Completed:Connect(function()
                NotifCard:Destroy()
            end)
        end)
    end

    -- نافذة الحوار والتأكيد
    function AuraLib:Dialog(dlgConfig)
        if not AuraLib.CurrentScreenGui then return end

        local dTitle = dlgConfig.Title or "Confirm Action"
        local dContent = dlgConfig.Content or "Are you sure you want to proceed?"
        local onConfirm = dlgConfig.Callback1 or function() end
        local onCancel = dlgConfig.Callback2 or function() end

        local Overlay = Instance.new("TextButton")
        Overlay.Name = "DialogOverlay"
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.Position = UDim2.new(0, 0, 0, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 1
        Overlay.Text = ""
        Overlay.AutoButtonColor = false
        Overlay.ZIndex = 9998
        Overlay.Parent = AuraLib.CurrentScreenGui

        local DialogBox = Instance.new("Frame")
        DialogBox.Size = UDim2.new(0, 250, 0, 120)
        DialogBox.Position = UDim2.new(0.5, -125, 0.5, -60)
        DialogBox.BackgroundColor3 = AuraLib.Theme.Background
        DialogBox.ClipsDescendants = true
        DialogBox.ZIndex = 9999
        DialogBox.Parent = Overlay

        Instance.new("UICorner", DialogBox).CornerRadius = UDim.new(0, 10)
        local DStroke = Instance.new("UIStroke", DialogBox)
        DStroke.Color = AuraLib.Theme.Stroke
        DStroke.Thickness = 1.2

        local DTitle = Instance.new("TextLabel", DialogBox)
        DTitle.Size = UDim2.new(1, -20, 0, 22)
        DTitle.Position = UDim2.new(0, 10, 0, 8)
        DTitle.BackgroundTransparency = 1
        DTitle.Text = dTitle
        DTitle.TextColor3 = AuraLib.Theme.TextPrimary
        DTitle.TextSize = 12
        DTitle.Font = AuraLib.Theme.FontBold
        DTitle.TextXAlignment = Enum.TextXAlignment.Left
        DTitle.ZIndex = 10000

        local DDesc = Instance.new("TextLabel", DialogBox)
        DDesc.Size = UDim2.new(1, -20, 0, 36)
        DDesc.Position = UDim2.new(0, 10, 0, 30)
        DDesc.BackgroundTransparency = 1
        DDesc.Text = dContent
        DDesc.TextColor3 = AuraLib.Theme.TextSecondary
        DDesc.TextSize = 10
        DDesc.Font = AuraLib.Theme.Font
        DDesc.TextXAlignment = Enum.TextXAlignment.Left
        DDesc.TextWrapped = true
        DDesc.ZIndex = 10000

        local YesBtn = Instance.new("TextButton", DialogBox)
        YesBtn.Size = UDim2.new(0.44, 0, 0, 24)
        YesBtn.Position = UDim2.new(0.52, 0, 1, -32)
        YesBtn.BackgroundColor3 = AuraLib.Theme.Accent
        YesBtn.Text = "Confirm"
        YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        YesBtn.TextSize = 10
        YesBtn.Font = AuraLib.Theme.FontBold
        YesBtn.ZIndex = 10000
        Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

        local NoBtn = Instance.new("TextButton", DialogBox)
        NoBtn.Size = UDim2.new(0.44, 0, 0, 24)
        NoBtn.Position = UDim2.new(0.04, 0, 1, -32)
        NoBtn.BackgroundColor3 = AuraLib.Theme.Card
        NoBtn.Text = "Cancel"
        NoBtn.TextColor3 = AuraLib.Theme.TextSecondary
        NoBtn.TextSize = 10
        NoBtn.Font = AuraLib.Theme.Font
        NoBtn.ZIndex = 10000
        Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

        Tween(Overlay, {BackgroundTransparency = 0.5}, 0.2)

        local function CloseDialog()
            Tween(Overlay, {BackgroundTransparency = 1}, 0.2)
            local t = Tween(DialogBox, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            t.Completed:Connect(function()
                Overlay:Destroy()
            end)
        end

        YesBtn.MouseButton1Click:Connect(function()
            CloseDialog()
            pcall(onConfirm)
        end)

        NoBtn.MouseButton1Click:Connect(function()
            CloseDialog()
            pcall(onCancel)
        end)
    end

    return Window
end

return AuraLib
