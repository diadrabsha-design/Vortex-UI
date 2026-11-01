--[[
    ╔═════════════════════════════════════════════════════════════════════════════════════╗
    ║                 VORTEX UI v3.5 - STANDALONE ALL-IN-ONE BEAST EDITION                ║
    ║       Zero Network Dependency - 100% Offline & Compatible with Delta Mobile 2026    ║
    ╚═════════════════════════════════════════════════════════════════════════════════════╝
]]

local Vortex = (function()
    local Vortex = {}
    Vortex.__index = Vortex
    Vortex.Version = "3.5.0"
    Vortex.Flags = {}

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
    local Players = GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local function GetSafeGuiParent()
        local success, parent = pcall(function()
            if gethui then return gethui()
            elseif syn and syn.protect_gui then
                local f = Instance.new("Folder")
                syn.protect_gui(f)
                f.Parent = CoreGui
                return f
            elseif CoreGui then return CoreGui end
            return nil
        end)
        if success and parent then return parent end
        return LocalPlayer:WaitForChild("PlayerGui")
    end

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
            Success = Color3.fromRGB(46, 213, 115),
            ToggleOff = Color3.fromRGB(44, 52, 70)
        }
    }

    local function FastTween(inst, props, dur, style, dir)
        dur = dur or 0.16
        style = style or Enum.EasingStyle.Quad
        dir = dir or Enum.EasingDirection.Out
        local t = TweenService:Create(inst, TweenInfo.new(dur, style, dir), props)
        t:Play()
        return t
    end

    local function SafeCallback(cb, ...)
        if type(cb) ~= "function" then return true end
        local args = { ... }
        local ok, err = pcall(function() cb(unpack(args)) end)
        if not ok then warn("[VORTEX UI SAFE PCALL ERROR]:", err) end
        return ok
    end

    local function IsArabicText(str)
        if type(str) ~= "string" then return false end
        for i = 1, #str do
            local byte = string.byte(str, i)
            if byte and byte >= 216 and byte <= 219 then return true end
        end
        return false
    end

    local function ApplyTextStyle(textLabel, text, size, color, font)
        textLabel.Text = tostring(text or "")
        textLabel.TextSize = size or 12
        textLabel.TextColor3 = color or Vortex.Themes.CyberDark.Text
        textLabel.Font = font or Enum.Font.GothamMedium
        textLabel.TextWrapped = true
        textLabel.BackgroundTransparency = 1
        textLabel.BorderSizePixel = 0
        if IsArabicText(text) then
            textLabel.TextXAlignment = Enum.TextXAlignment.Right
        else
            textLabel.TextXAlignment = Enum.TextXAlignment.Left
        end
    end

    local function MakeDraggable(dragPart, mainFrame)
        local dragging, dragInput, dragStart, startPos
        dragPart.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        dragPart.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                local cam = workspace.CurrentCamera
                local viewX = cam and cam.ViewportSize.X or 1920
                local viewY = cam and cam.ViewportSize.Y or 1080
                local newX = math.clamp(startPos.X.Offset + delta.X, 10, viewX - mainFrame.AbsoluteSize.X - 10)
                local newY = math.clamp(startPos.Y.Offset + delta.Y, 10, viewY - mainFrame.AbsoluteSize.Y - 10)
                mainFrame.Position = UDim2.new(0, newX, 0, newY)
            end
        end)
    end

    function Vortex:CreateWindow(cfg)
        cfg = cfg or {}
        local winName = cfg.Name or "VORTEX BEAST"
        local winSub = cfg.SubTitle or "Delta Mobile 2026"
        local theme = Vortex.Themes.CyberDark

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "VORTEX_BEAST_GUI_" .. tostring(math.random(1000, 9999))
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Parent = GetSafeGuiParent()

        local RootScaler = Instance.new("UIScale")
        RootScaler.Name = "AutoScaler"
        RootScaler.Parent = ScreenGui

        local function UpdateDpiScale()
            local cam = workspace.CurrentCamera
            if cam then
                local w = cam.ViewportSize.X
                if w < 650 then RootScaler.Scale = math.clamp(w / 640, 0.65, 0.95)
                elseif w < 1000 then RootScaler.Scale = 0.95
                else RootScaler.Scale = 1 end
            end
        end
        UpdateDpiScale()
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateDpiScale)

        local Main = Instance.new("Frame")
        Main.Name = "MainFrame"
        Main.Size = UDim2.new(0, 560, 0, 350)
        Main.Position = UDim2.new(0.5, -280, 0.5, -175)
        Main.BackgroundColor3 = theme.Background
        Main.BorderSizePixel = 0
        Main.ClipsDescendants = true
        Main.Parent = ScreenGui

        local mCorner = Instance.new("UICorner")
        mCorner.CornerRadius = UDim.new(0, 10)
        mCorner.Parent = Main

        local mStroke = Instance.new("UIStroke")
        mStroke.Color = theme.Border
        mStroke.Thickness = 1.2
        mStroke.Parent = Main

        -- Header
        local Header = Instance.new("Frame")
        Header.Name = "Header"
        Header.Size = UDim2.new(1, 0, 0, 44)
        Header.BackgroundColor3 = theme.Header
        Header.BorderSizePixel = 0
        Header.Parent = Main

        local hCorner = Instance.new("UICorner")
        hCorner.CornerRadius = UDim.new(0, 10)
        hCorner.Parent = Header

        local Title = Instance.new("TextLabel")
        ApplyTextStyle(Title, winName, 14, theme.Text, Enum.Font.GothamBold)
        Title.Position = UDim2.new(0, 14, 0, 6)
        Title.Size = UDim2.new(0, 160, 0, 18)
        Title.Parent = Header

        local Sub = Instance.new("TextLabel")
        ApplyTextStyle(Sub, winSub, 10, theme.Accent, Enum.Font.Gotham)
        Sub.Position = UDim2.new(0, 14, 0, 24)
        Sub.Size = UDim2.new(0, 160, 0, 14)
        Sub.Parent = Header

        -- Search Bar (Feature 10)
        local SearchBox = Instance.new("TextBox")
        SearchBox.Name = "GlobalSearch"
        SearchBox.Size = UDim2.new(0, 170, 0, 26)
        SearchBox.Position = UDim2.new(1, -225, 0, 9)
        SearchBox.BackgroundColor3 = theme.Card
        SearchBox.PlaceholderText = "🔍 بحث فوري (Search)..."
        SearchBox.PlaceholderColor3 = theme.SubText
        ApplyTextStyle(SearchBox, "", 11, theme.Text, Enum.Font.Gotham)
        SearchBox.ClearTextOnFocus = false
        SearchBox.Parent = Header

        local sCorner = Instance.new("UICorner")
        sCorner.CornerRadius = UDim.new(0, 6)
        sCorner.Parent = SearchBox

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 28, 0, 28)
        CloseBtn.Position = UDim2.new(1, -38, 0, 8)
        CloseBtn.BackgroundColor3 = theme.Card
        ApplyTextStyle(CloseBtn, "✕", 12, theme.SubText, Enum.Font.GothamBold)
        CloseBtn.Parent = Header

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 6)
        cCorner.Parent = CloseBtn

        -- Sidebar & Pages Container
        local Sidebar = Instance.new("ScrollingFrame")
        Sidebar.Size = UDim2.new(0, 125, 1, -50)
        Sidebar.Position = UDim2.new(0, 6, 0, 48)
        Sidebar.BackgroundColor3 = theme.Sidebar
        Sidebar.ScrollBarThickness = 2
        Sidebar.BorderSizePixel = 0
        Sidebar.Parent = Main

        local sbCorner = Instance.new("UICorner")
        sbCorner.CornerRadius = UDim.new(0, 8)
        sbCorner.Parent = Sidebar

        local sbLayout = Instance.new("UIListLayout")
        sbLayout.Padding = UDim.new(0, 4)
        sbLayout.Parent = Sidebar

        local Content = Instance.new("Frame")
        Content.Size = UDim2.new(1, -145, 1, -50)
        Content.Position = UDim2.new(0, 137, 0, 48)
        Content.BackgroundTransparency = 1
        Content.Parent = Main

        MakeDraggable(Header, Main)

        -- Mobile Floating Toggle Bubble (Feature 5)
        local Bubble = Instance.new("ImageButton")
        Bubble.Name = "VortexMobileBubble"
        Bubble.Size = UDim2.new(0, 46, 0, 46)
        Bubble.Position = UDim2.new(0, 20, 0.4, 0)
        Bubble.BackgroundColor3 = theme.Header
        Bubble.BorderSizePixel = 0
        Bubble.Parent = ScreenGui

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(1, 0)
        bCorner.Parent = Bubble

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = theme.Accent
        bStroke.Thickness = 2
        bStroke.Parent = Bubble

        local bLabel = Instance.new("TextLabel")
        ApplyTextStyle(bLabel, "⚡", 18, theme.Accent, Enum.Font.GothamBold)
        bLabel.Size = UDim2.new(1, 0, 1, 0)
        bLabel.TextXAlignment = Enum.TextXAlignment.Center
        bLabel.Parent = Bubble

        MakeDraggable(Bubble, Bubble)

        local isGuiVisible = true
        local function ToggleGui()
            isGuiVisible = not isGuiVisible
            Main.Visible = isGuiVisible
        end
        Bubble.MouseButton1Click:Connect(ToggleGui)
        CloseBtn.MouseButton1Click:Connect(ToggleGui)

        local WindowObj = { Tabs = {}, CurrentTab = nil, RegisteredElements = {} }

        -- Search functionality implementation (Feature 10)
        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local query = string.lower(SearchBox.Text)
            for _, item in ipairs(WindowObj.RegisteredElements) do
                if item.Frame and item.SearchText then
                    if query == "" or string.find(string.lower(item.SearchText), query, 1, true) then
                        item.Frame.Visible = true
                    else
                        item.Frame.Visible = false
                    end
                end
            end
        end)

        function WindowObj:CreateTab(tName, tIcon)
            tIcon = tIcon or "•"
            local TabBtn = Instance.new("TextButton")
            TabBtn.Size = UDim2.new(1, -6, 0, 32)
            TabBtn.BackgroundColor3 = theme.Card
            TabBtn.BorderSizePixel = 0
            ApplyTextStyle(TabBtn, " " .. tIcon .. "  " .. tName, 11, theme.SubText, Enum.Font.GothamMedium)
            TabBtn.Parent = Sidebar

            local tbCorner = Instance.new("UICorner")
            tbCorner.CornerRadius = UDim.new(0, 6)
            tbCorner.Parent = TabBtn

            local Page = Instance.new("ScrollingFrame")
            Page.Size = UDim2.new(1, 0, 1, 0)
            Page.BackgroundTransparency = 1
            Page.ScrollBarThickness = 3
            Page.Visible = false
            Page.Parent = Content

            local pLayout = Instance.new("UIListLayout")
            pLayout.Padding = UDim.new(0, 6)
            pLayout.Parent = Page

            pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Page.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 20)
            end)

            local function ActivateTab()
                for _, other in ipairs(WindowObj.Tabs) do
                    other.Page.Visible = false
                    FastTween(other.Btn, { BackgroundColor3 = theme.Card, TextColor3 = theme.SubText }, 0.15)
                end
                Page.Visible = true
                WindowObj.CurrentTab = Page
                FastTween(TabBtn, { BackgroundColor3 = theme.CardHover, TextColor3 = theme.Accent }, 0.15)
            end

            TabBtn.MouseButton1Click:Connect(ActivateTab)
            if #WindowObj.Tabs == 0 then ActivateTab() end

            local TabObj = { Btn = TabBtn, Page = Page }
            table.insert(WindowObj.Tabs, TabObj)

            -- SECTION
            function TabObj:CreateSection(secName)
                local SecLabel = Instance.new("TextLabel")
                SecLabel.Size = UDim2.new(1, 0, 0, 22)
                ApplyTextStyle(SecLabel, "  " .. secName, 10, theme.Accent, Enum.Font.GothamBold)
                SecLabel.Parent = Page
            end

            -- BUTTON
            function TabObj:CreateButton(opt)
                opt = opt or {}
                local bName = opt.Name or opt.Title or opt[1] or "Button"
                local cb = opt.Callback or opt[2]

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -6, 0, 34)
                Btn.BackgroundColor3 = theme.Card
                Btn.BorderSizePixel = 0
                ApplyTextStyle(Btn, "  " .. bName, 12, theme.Text, Enum.Font.GothamMedium)
                Btn.Parent = Page

                local bCorner = Instance.new("UICorner")
                bCorner.CornerRadius = UDim.new(0, 6)
                bCorner.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    FastTween(Btn, { BackgroundColor3 = theme.Accent }, 0.1)
                    task.wait(0.1)
                    FastTween(Btn, { BackgroundColor3 = theme.Card }, 0.15)
                    SafeCallback(cb)
                end)

                table.insert(WindowObj.RegisteredElements, { Frame = Btn, SearchText = bName })
                return Btn
            end
            TabObj.AddButton = TabObj.CreateButton

            -- TOGGLE (Feature 6: Flags)
            function TabObj:CreateToggle(opt)
                opt = opt or {}
                local tName = opt.Name or opt[1] or "Toggle"
                local curVal = opt.CurrentValue or opt.Default or false
                local flag = opt.Flag or tName
                local cb = opt.Callback or opt[2]

                Vortex.Flags[flag] = curVal

                local Card = Instance.new("Frame")
                Card.Size = UDim2.new(1, -6, 0, 36)
                Card.BackgroundColor3 = theme.Card
                Card.BorderSizePixel = 0
                Card.Parent = Page

                local cCorner = Instance.new("UICorner")
                cCorner.CornerRadius = UDim.new(0, 6)
                cCorner.Parent = Card

                local Label = Instance.new("TextLabel")
                ApplyTextStyle(Label, "  " .. tName, 12, theme.Text, Enum.Font.GothamMedium)
                Label.Size = UDim2.new(1, -60, 1, 0)
                Label.Parent = Card

                local Switch = Instance.new("TextButton")
                Switch.Size = UDim2.new(0, 44, 0, 22)
                Switch.Position = UDim2.new(1, -50, 0.5, -11)
                Switch.BackgroundColor3 = curVal and theme.Accent or theme.ToggleOff
                Switch.BorderSizePixel = 0
                Switch.Text = ""
                Switch.Parent = Card

                local swCorner = Instance.new("UICorner")
                swCorner.CornerRadius = UDim.new(1, 0)
                swCorner.Parent = Switch

                local Circle = Instance.new("Frame")
                Circle.Size = UDim2.new(0, 18, 0, 18)
                Circle.Position = curVal and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Circle.BorderSizePixel = 0
                Circle.Parent = Switch

                local cirCorner = Instance.new("UICorner")
                cirCorner.CornerRadius = UDim.new(1, 0)
                cirCorner.Parent = Circle

                local function SetState(val)
                    curVal = val
                    Vortex.Flags[flag] = val
                    FastTween(Switch, { BackgroundColor3 = val and theme.Accent or theme.ToggleOff }, 0.15)
                    FastTween(Circle, { Position = val and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9) }, 0.15)
                    SafeCallback(cb, val)
                end

                Switch.MouseButton1Click:Connect(function() SetState(not curVal) end)
                table.insert(WindowObj.RegisteredElements, { Frame = Card, SearchText = tName })

                return { Set = SetState, Get = function() return curVal end }
            end
            TabObj.AddToggle = TabObj.CreateToggle

            -- TEXT / NUMBER INPUT (Feature 2)
            function TabObj:CreateInput(opt)
                opt = opt or {}
                local iName = opt.Name or opt[1] or "Input Box"
                local placeholder = opt.PlaceholderText or "اكتب هنا..."
                local flag = opt.Flag or iName
                local cb = opt.Callback or opt[2]

                local Card = Instance.new("Frame")
                Card.Size = UDim2.new(1, -6, 0, 38)
                Card.BackgroundColor3 = theme.Card
                Card.BorderSizePixel = 0
                Card.Parent = Page

                local cCorner = Instance.new("UICorner")
                cCorner.CornerRadius = UDim.new(0, 6)
                cCorner.Parent = Card

                local Label = Instance.new("TextLabel")
                ApplyTextStyle(Label, "  " .. iName, 12, theme.Text, Enum.Font.GothamMedium)
                Label.Size = UDim2.new(0.55, 0, 1, 0)
                Label.Parent = Card

                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(0.42, 0, 0, 26)
                Box.Position = UDim2.new(0.56, 0, 0.5, -13)
                Box.BackgroundColor3 = theme.Header
                Box.PlaceholderText = placeholder
                Box.PlaceholderColor3 = theme.SubText
                Box.ClearTextOnFocus = false
                ApplyTextStyle(Box, "", 11, theme.Accent, Enum.Font.Gotham)
                Box.Parent = Card

                local bCorner = Instance.new("UICorner")
                bCorner.CornerRadius = UDim.new(0, 6)
                bCorner.Parent = Box

                local bStroke = Instance.new("UIStroke")
                bStroke.Color = theme.Border
                bStroke.Thickness = 1
                bStroke.Parent = Box

                Box.FocusLost:Connect(function(enterPressed)
                    Vortex.Flags[flag] = Box.Text
                    SafeCallback(cb, Box.Text, enterPressed)
                end)

                table.insert(WindowObj.RegisteredElements, { Frame = Card, SearchText = iName })

                return {
                    Set = function(_, txt) Box.Text = tostring(txt) end,
                    Get = function() return Box.Text end
                }
            end
            TabObj.CreateTextBox = TabObj.CreateInput
            TabObj.AddInput = TabObj.CreateInput

            -- SLIDER
            function TabObj:CreateSlider(opt)
                opt = opt or {}
                local sName = opt.Name or opt[1] or "Slider"
                local min = (opt.Range and opt.Range[1]) or opt.Min or 0
                local max = (opt.Range and opt.Range[2]) or opt.Max or 100
                local curVal = opt.CurrentValue or opt.Default or min
                local flag = opt.Flag or sName
                local cb = opt.Callback or opt[2]

                Vortex.Flags[flag] = curVal

                local Card = Instance.new("Frame")
                Card.Size = UDim2.new(1, -6, 0, 46)
                Card.BackgroundColor3 = theme.Card
                Card.BorderSizePixel = 0
                Card.Parent = Page

                local cCorner = Instance.new("UICorner")
                cCorner.CornerRadius = UDim.new(0, 6)
                cCorner.Parent = Card

                local Label = Instance.new("TextLabel")
                ApplyTextStyle(Label, "  " .. sName, 12, theme.Text, Enum.Font.GothamMedium)
                Label.Size = UDim2.new(0.7, 0, 0, 20)
                Label.Position = UDim2.new(0, 0, 0, 4)
                Label.Parent = Card

                local ValLabel = Instance.new("TextLabel")
                ApplyTextStyle(ValLabel, tostring(curVal), 11, theme.Accent, Enum.Font.GothamBold)
                ValLabel.Size = UDim2.new(0.28, 0, 0, 20)
                ValLabel.Position = UDim2.new(0.7, 0, 0, 4)
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.Parent = Card

                local Bar = Instance.new("TextButton")
                Bar.Size = UDim2.new(1, -16, 0, 8)
                Bar.Position = UDim2.new(0, 8, 0, 28)
                Bar.BackgroundColor3 = theme.Header
                Bar.BorderSizePixel = 0
                Bar.Text = ""
                Bar.Parent = Card

                local barCorner = Instance.new("UICorner")
                barCorner.CornerRadius = UDim.new(1, 0)
                barCorner.Parent = Bar

                local Fill = Instance.new("Frame")
                local pct = math.clamp((curVal - min) / (max - min), 0, 1)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                Fill.BackgroundColor3 = theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Parent = Bar

                local fCorner = Instance.new("UICorner")
                fCorner.CornerRadius = UDim.new(1, 0)
                fCorner.Parent = Fill

                local function UpdateSlider(input)
                    local barPos = Bar.AbsolutePosition.X
                    local barSize = Bar.AbsoluteSize.X
                    local relX = math.clamp((input.Position.X - barPos) / barSize, 0, 1)
                    local value = math.floor(min + ((max - min) * relX))
                    curVal = value
                    Vortex.Flags[flag] = value
                    Fill.Size = UDim2.new(relX, 0, 1, 0)
                    ValLabel.Text = tostring(value)
                    SafeCallback(cb, value)
                end

                local sliding = false
                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        UpdateSlider(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)

                table.insert(WindowObj.RegisteredElements, { Frame = Card, SearchText = sName })
                return { Set = function(_, v) curVal = v end }
            end
            TabObj.AddSlider = TabObj.CreateSlider

            -- DROPDOWN (Feature 4)
            function TabObj:CreateDropdown(opt)
                opt = opt or {}
                local dName = opt.Name or opt[1] or "Dropdown"
                local options = opt.Options or {"Option 1", "Option 2"}
                local selected = opt.CurrentOption or options[1] or ""
                local flag = opt.Flag or dName
                local cb = opt.Callback or opt[2]

                Vortex.Flags[flag] = selected

                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, -6, 0, 36)
                DropFrame.BackgroundColor3 = theme.Card
                DropFrame.BorderSizePixel = 0
                DropFrame.ClipsDescendants = true
                DropFrame.Parent = Page

                local dfCorner = Instance.new("UICorner")
                dfCorner.CornerRadius = UDim.new(0, 6)
                dfCorner.Parent = DropFrame

                local MainBtn = Instance.new("TextButton")
                MainBtn.Size = UDim2.new(1, 0, 0, 36)
                MainBtn.BackgroundTransparency = 1
                ApplyTextStyle(MainBtn, "  " .. dName .. "  :  " .. tostring(selected), 12, theme.Text, Enum.Font.GothamMedium)
                MainBtn.Parent = DropFrame

                local Arrow = Instance.new("TextLabel")
                ApplyTextStyle(Arrow, "▼", 11, theme.Accent, Enum.Font.Gotham)
                Arrow.Size = UDim2.new(0, 24, 0, 36)
                Arrow.Position = UDim2.new(1, -26, 0, 0)
                Arrow.Parent = DropFrame

                local List = Instance.new("Frame")
                List.Size = UDim2.new(1, -12, 0, #options * 28)
                List.Position = UDim2.new(0, 6, 0, 38)
                List.BackgroundTransparency = 1
                List.Parent = DropFrame

                local lLayout = Instance.new("UIListLayout")
                lLayout.Padding = UDim.new(0, 2)
                lLayout.Parent = List

                local isOpen = false
                local function PopulateOptions(newOpts)
                    for _, child in ipairs(List:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, optName in ipairs(newOpts) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, 0, 0, 26)
                        OptBtn.BackgroundColor3 = theme.Header
                        ApplyTextStyle(OptBtn, "   " .. tostring(optName), 11, theme.SubText, Enum.Font.Gotham)
                        OptBtn.Parent = List

                        local oCorner = Instance.new("UICorner")
                        oCorner.CornerRadius = UDim.new(0, 4)
                        oCorner.Parent = OptBtn

                        OptBtn.MouseButton1Click:Connect(function()
                            selected = optName
                            Vortex.Flags[flag] = optName
                            MainBtn.Text = "  " .. dName .. "  :  " .. tostring(optName)
                            isOpen = false
                            Arrow.Text = "▼"
                            FastTween(DropFrame, { Size = UDim2.new(1, -6, 0, 36) }, 0.15)
                            SafeCallback(cb, optName)
                        end)
                    end
                end
                PopulateOptions(options)

                MainBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    Arrow.Text = isOpen and "▲" or "▼"
                    local targetH = isOpen and (42 + (#options * 28)) or 36
                    FastTween(DropFrame, { Size = UDim2.new(1, -6, 0, targetH) }, 0.2)
                end)

                table.insert(WindowObj.RegisteredElements, { Frame = DropFrame, SearchText = dName })

                return {
                    Refresh = function(_, newOpts)
                        options = newOpts or {}
                        PopulateOptions(options)
                    end,
                    Set = function(_, val)
                        selected = val
                        Vortex.Flags[flag] = val
                        MainBtn.Text = "  " .. dName .. "  :  " .. tostring(val)
                    end
                }
            end
            TabObj.AddDropdown = TabObj.CreateDropdown

            -- KEYBIND (Feature 8)
            function TabObj:CreateKeybind(opt)
                opt = opt or {}
                local kName = opt.Name or opt[1] or "Keybind"
                local curKey = opt.Default or opt.CurrentKeybind or "E"
                local flag = opt.Flag or kName
                local cb = opt.Callback or opt[2]

                local Card = Instance.new("Frame")
                Card.Size = UDim2.new(1, -6, 0, 36)
                Card.BackgroundColor3 = theme.Card
                Card.BorderSizePixel = 0
                Card.Parent = Page

                local cCorner = Instance.new("UICorner")
                cCorner.CornerRadius = UDim.new(0, 6)
                cCorner.Parent = Card

                local Label = Instance.new("TextLabel")
                ApplyTextStyle(Label, "  " .. kName, 12, theme.Text, Enum.Font.GothamMedium)
                Label.Size = UDim2.new(0.65, 0, 1, 0)
                Label.Parent = Card

                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Size = UDim2.new(0, 75, 0, 24)
                KeyBtn.Position = UDim2.new(1, -85, 0.5, -12)
                KeyBtn.BackgroundColor3 = theme.Header
                ApplyTextStyle(KeyBtn, tostring(curKey), 11, theme.Accent, Enum.Font.GothamBold)
                KeyBtn.TextXAlignment = Enum.TextXAlignment.Center
                KeyBtn.Parent = Card

                local kbCorner = Instance.new("UICorner")
                kbCorner.CornerRadius = UDim.new(0, 4)
                kbCorner.Parent = KeyBtn

                local listening = false
                KeyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeyBtn.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if not gpe and listening and input.KeyCode ~= Enum.KeyCode.Unknown then
                        listening = false
                        curKey = input.KeyCode.Name
                        Vortex.Flags[flag] = curKey
                        KeyBtn.Text = curKey
                    elseif not gpe and not listening and input.KeyCode.Name == curKey then
                        SafeCallback(cb, curKey)
                    end
                end)

                table.insert(WindowObj.RegisteredElements, { Frame = Card, SearchText = kName })
                return { Set = function(_, k) curKey = k; KeyBtn.Text = tostring(k) end }
            end
            TabObj.AddKeybind = TabObj.CreateKeybind

            -- COLOR PICKER (Feature 9)
            function TabObj:CreateColorPicker(opt)
                opt = opt or {}
                local cpName = opt.Name or opt[1] or "Color Picker"
                local curColor = opt.Color or Color3.fromRGB(0, 240, 255)
                local flag = opt.Flag or cpName
                local cb = opt.Callback or opt[2]

                local Card = Instance.new("Frame")
                Card.Size = UDim2.new(1, -6, 0, 38)
                Card.BackgroundColor3 = theme.Card
                Card.BorderSizePixel = 0
                Card.Parent = Page

                local cCorner = Instance.new("UICorner")
                cCorner.CornerRadius = UDim.new(0, 6)
                cCorner.Parent = Card

                local Label = Instance.new("TextLabel")
                ApplyTextStyle(Label, "  " .. cpName, 12, theme.Text, Enum.Font.GothamMedium)
                Label.Size = UDim2.new(0.7, 0, 1, 0)
                Label.Parent = Card

                local Preview = Instance.new("TextButton")
                Preview.Size = UDim2.new(0, 28, 0, 22)
                Preview.Position = UDim2.new(1, -38, 0.5, -11)
                Preview.BackgroundColor3 = curColor
                Preview.BorderSizePixel = 0
                Preview.Text = ""
                Preview.Parent = Card

                local pCorner = Instance.new("UICorner")
                pCorner.CornerRadius = UDim.new(0, 4)
                pCorner.Parent = Preview

                local palette = {
                    Color3.fromRGB(0, 240, 255),
                    Color3.fromRGB(46, 213, 115),
                    Color3.fromRGB(255, 71, 87),
                    Color3.fromRGB(255, 165, 2),
                    Color3.fromRGB(165, 94, 234)
                }
                local pIndex = 1

                Preview.MouseButton1Click:Connect(function()
                    pIndex = (pIndex % #palette) + 1
                    curColor = palette[pIndex]
                    Preview.BackgroundColor3 = curColor
                    Vortex.Flags[flag] = curColor
                    SafeCallback(cb, curColor)
                end)

                table.insert(WindowObj.RegisteredElements, { Frame = Card, SearchText = cpName })
                return { Set = function(_, c) curColor = c; Preview.BackgroundColor3 = c end }
            end
            TabObj.AddColorPicker = TabObj.CreateColorPicker

            return TabObj
        end

        -- DIALOG CONFIRMATION MODAL
        function WindowObj:Dialog(opt)
            opt = opt or {}
            local dTitle = opt.Title or "تأكيد"
            local dContent = opt.Content or "هل أنت متأكد؟"
            local btns = opt.Buttons or {}

            local Overlay = Instance.new("Frame")
            Overlay.Size = UDim2.new(1, 0, 1, 0)
            Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Overlay.BackgroundTransparency = 0.5
            Overlay.ZIndex = 50
            Overlay.Parent = Main

            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0, 300, 0, 130)
            Box.Position = UDim2.new(0.5, -150, 0.5, -65)
            Box.BackgroundColor3 = theme.Header
            Box.ZIndex = 51
            Box.Parent = Overlay

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 8)
            bCorner.Parent = Box

            local tLbl = Instance.new("TextLabel")
            ApplyTextStyle(tLbl, dTitle, 13, theme.Accent, Enum.Font.GothamBold)
            tLbl.Position = UDim2.new(0, 10, 0, 8)
            tLbl.Size = UDim2.new(1, -20, 0, 20)
            tLbl.ZIndex = 52
            tLbl.Parent = Box

            local cLbl = Instance.new("TextLabel")
            ApplyTextStyle(cLbl, dContent, 11, theme.Text, Enum.Font.Gotham)
            cLbl.Position = UDim2.new(0, 10, 0, 32)
            cLbl.Size = UDim2.new(1, -20, 0, 45)
            cLbl.ZIndex = 52
            cLbl.Parent = Box

            local bHolder = Instance.new("Frame")
            bHolder.Size = UDim2.new(1, -20, 0, 32)
            bHolder.Position = UDim2.new(0, 10, 1, -38)
            bHolder.BackgroundTransparency = 1
            bHolder.ZIndex = 52
            bHolder.Parent = Box

            local bhLayout = Instance.new("UIListLayout")
            bhLayout.FillDirection = Enum.FillDirection.Horizontal
            bhLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            bhLayout.Padding = UDim.new(0, 8)
            bhLayout.Parent = bHolder

            for _, bOpt in ipairs(btns) do
                local ActionBtn = Instance.new("TextButton")
                ActionBtn.Size = UDim2.new(0, 85, 1, 0)
                ActionBtn.BackgroundColor3 = bOpt.Primary and theme.Accent or theme.Card
                ApplyTextStyle(ActionBtn, bOpt.Title or "موافق", 11, bOpt.Primary and Color3.fromRGB(10, 15, 20) or theme.Text, Enum.Font.GothamBold)
                ActionBtn.ZIndex = 53
                ActionBtn.Parent = bHolder

                local aCorner = Instance.new("UICorner")
                aCorner.CornerRadius = UDim.new(0, 6)
                aCorner.Parent = ActionBtn

                ActionBtn.MouseButton1Click:Connect(function()
                    Overlay:Destroy()
                    SafeCallback(bOpt.Callback)
                end)
            end
        end

        return WindowObj
    end

    -- NOTIFY SYSTEM (Feature 3)
    function Vortex:Notify(titleOrOpt, content, duration)
        local nTitle = "إشعار"
        local nContent = ""
        duration = 3

        if type(titleOrOpt) == "table" then
            nTitle = titleOrOpt.Title or nTitle
            nContent = titleOrOpt.Content or titleOrOpt.Text or ""
            duration = titleOrOpt.Duration or duration
        else
            nTitle = tostring(titleOrOpt or nTitle)
            nContent = tostring(content or "")
        end

        local targetGui = GetSafeGuiParent():FindFirstChildOfClass("ScreenGui")
        if not targetGui then
            targetGui = Instance.new("ScreenGui")
            targetGui.Name = "VORTEX_NOTIF_GUI"
            targetGui.Parent = GetSafeGuiParent()
        end

        local Holder = targetGui:FindFirstChild("VortexNotifHolder")
        if not Holder then
            Holder = Instance.new("Frame")
            Holder.Name = "VortexNotifHolder"
            Holder.Size = UDim2.new(0, 260, 1, -20)
            Holder.Position = UDim2.new(1, -270, 0, 10)
            Holder.BackgroundTransparency = 1
            Holder.Parent = targetGui

            local nLayout = Instance.new("UIListLayout")
            nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            nLayout.Padding = UDim.new(0, 8)
            nLayout.Parent = Holder
        end

        local Toast = Instance.new("Frame")
        Toast.Size = UDim2.new(1, 0, 0, 60)
        Toast.BackgroundColor3 = Vortex.Themes.CyberDark.Header
        Toast.BorderSizePixel = 0
        Toast.Parent = Holder

        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 8)
        tCorner.Parent = Toast

        local tStroke = Instance.new("UIStroke")
        tStroke.Color = Vortex.Themes.CyberDark.Accent
        tStroke.Thickness = 1.2
        tStroke.Parent = Toast

        local tTitle = Instance.new("TextLabel")
        ApplyTextStyle(tTitle, nTitle, 12, Vortex.Themes.CyberDark.Accent, Enum.Font.GothamBold)
        tTitle.Position = UDim2.new(0, 10, 0, 6)
        tTitle.Size = UDim2.new(1, -20, 0, 16)
        tTitle.Parent = Toast

        local tBody = Instance.new("TextLabel")
        ApplyTextStyle(tBody, nContent, 10, Vortex.Themes.CyberDark.Text, Enum.Font.Gotham)
        tBody.Position = UDim2.new(0, 10, 0, 24)
        tBody.Size = UDim2.new(1, -20, 0, 26)
        tBody.Parent = Toast

        local Prog = Instance.new("Frame")
        Prog.Size = UDim2.new(1, 0, 0, 2)
        Prog.Position = UDim2.new(0, 0, 1, -2)
        Prog.BackgroundColor3 = Vortex.Themes.CyberDark.Accent
        Prog.BorderSizePixel = 0
        Prog.Parent = Toast

        FastTween(Prog, { Size = UDim2.new(0, 0, 0, 2) }, duration)
        task.delay(duration, function()
            FastTween(Toast, { BackgroundTransparency = 1 }, 0.2)
            FastTween(tTitle, { TextTransparency = 1 }, 0.2)
            FastTween(tBody, { TextTransparency = 1 }, 0.2)
            FastTween(tStroke, { Transparency = 1 }, 0.2)
            task.wait(0.2)
            Toast:Destroy()
        end)
    end

    return Vortex
end)()

-------------------------------------------------------------------------
-- [ تجربة السكربت الميداني لاختبار كافة الميزات العشر في Delta Mobile ] --
-------------------------------------------------------------------------

local Window = Vortex:CreateWindow({
    Name = "VORTEX BEAST",
    SubTitle = "Delta Mobile 2026",
    Theme = "CyberDark"
})

-- الميزة 3: إشعار ترحيبي عائم
Vortex:Notify({
    Title = "VORTEX v3.5",
    Content = "تم تشغيل المكتبة بنجاح! جميع الميزات العشر مدعومة 100%.",
    Duration = 3.5
})

-- التبويب الأول: خصائص اللاعب والسرعة
local TabPlayer = Window:CreateTab("اللاعب", "👤")
TabPlayer:CreateSection("السرعة والفيزياء (دعم كامل للعربية RTL)")

-- الميزة 2: حقل إدخال نصوص وأرقام لكتابة السرعة المخصصة (0.09 أو أي رقم)
TabPlayer:CreateInput({
    Name = "كتابة سرعة مخصصة بدقة",
    PlaceholderText = "مثال: 0.09 أو 120...",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = num
                Vortex:Notify("تم التعديل", "تم ضبط سرعة اللاعب على: " .. tostring(num), 2.5)
            end
        else
            Vortex:Notify("تنبيه", "يرجى كتابة رقم صحيح فقط!", 2)
        end
    end
})

-- الميزة 6: حفظ الحالة عبر الـ Flags
TabPlayer:CreateToggle({
    Name = "القفز اللانهائي في الهواء",
    CurrentValue = false,
    Flag = "InfiniteJumpFlag",
    Callback = function(state)
        print("Flag InfiniteJump is:", state, "Stored in Vortex.Flags:", Vortex.Flags.InfiniteJumpFlag)
        Vortex:Notify("الحالة", state and "تم تفعيل القفز اللانهائي" or "تم إيقاف القفز", 2)
    end
})

TabPlayer:CreateSlider({
    Name = "شريط سرعة المشي المباشر",
    Range = {16, 250},
    CurrentValue = 16,
    Flag = "SpeedSliderFlag",
    Callback = function(val)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end
})

-- التبويب الثاني: الأوتوفارم والقوائم والمفاتيح
local TabFarm = Window:CreateTab("الأوتو", "⚡")
TabFarm:CreateSection("التجميع والقوائم المنسدلة")

-- الميزة 4: قائمة منسدلة متعددة الخيارات (CreateDropdown)
TabFarm:CreateDropdown({
    Name = "اختيار أسلوب الهجوم",
    Options = {"الأقرب جغرافياً", "أضعف صحة", "أعلى مكافأة", "الزعماء فقط"},
    Flag = "TargetModeFlag",
    Callback = function(selected)
        Vortex:Notify("الهدف", "تم تحديد النمط: " .. selected, 2)
    end
})

-- الميزة 8: اختصار المفاتيح وزر اللمس (CreateKeybind)
TabFarm:CreateKeybind({
    Name = "مفتاح تشغيل الأوتوفارم السريع",
    Default = "E",
    Callback = function(key)
        Vortex:Notify("اختصار المفاتيح", "تم الضغط على المفتاح: " .. tostring(key), 2)
    end
})

-- الميزة 9: محدد الألوان التفاعلي (CreateColorPicker)
TabFarm:CreateColorPicker({
    Name = "لون تحديد الأعداء (ESP Color)",
    Color = Color3.fromRGB(0, 240, 255),
    Flag = "ESPColorFlag",
    Callback = function(color)
        Vortex:Notify("الألوان", "تم تغيير لون التحديد!", 2)
    end
})

-- التبويب الثالث: الإعدادات والنوافذ المنبثقة
local TabSettings = Window:CreateTab("الإعدادات", "⚙️")
TabSettings:CreateSection("النظام والأمان والحفظ")

-- نافذة تأكيد تفاعلية (Dialog)
TabSettings:CreateButton({
    Name = "إعادة ضبط السكربت (نافذة Dialog)",
    Callback = function()
        Window:Dialog({
            Title = "تأكيد إعادة الضبط",
            Content = "هل تريد حقاً إعادة ضبط جميع الإعدادات للوضع الافتراضي؟",
            Buttons = {
                {
                    Title = "نعم، أعد الضبط",
                    Primary = true,
                    Callback = function()
                        Vortex:Notify("تم الضبط", "تمت إعادة ضبط السكربت بنجاح!", 2.5)
                    end
                },
                {
                    Title = "إلغاء",
                    Callback = function()
                        Vortex:Notify("إلغاء", "تم إلغاء العملية.", 1.5)
                    end
                }
            }
        })
    end
})
