--[[
    ╔═════════════════════════════════════════════════════════════════════════════════════╗
    ║                 VORTEX UI v3.5 - STANDALONE ALL-IN-ONE BEAST EDITION                ║
    ║       Zero Network Dependency - 100% Offline & Compatible with Delta Mobile 2026    ║
    ║       Fixed: Freedom of Upward Drag, IgnoreGuiInset, Full RTL Arabic Support        ║
    ╚═════════════════════════════════════════════════════════════════════════════════════╝
]]

local Vortex = (function()
    local Vortex = {}
    Vortex.__index = Vortex
    Vortex.Version = "3.5.0"
    Vortex.Author = "Vortex Core Team"
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
    local HttpService = GetService("HttpService")
    local Players = GetService("Players")
    local LocalPlayer = Players.LocalPlayer

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
        if not ok then warn("[VORTEX SAFE PCALL ERROR]:", err) end
        return ok
    end

    local function IsArabicText(str)
        if type(str) ~= "string" then return false end
        for i = 1, #str do
            local b = string.byte(str, i)
            if b and b >= 216 and b <= 219 then return true end
        end
        return false
    end

    local function ApplyTextStyle(label, text, size, color, font)
        label.Text = tostring(text or "")
        label.Font = font or Enum.Font.GothamSemibold
        label.TextSize = size or 13
        label.TextColor3 = color or Vortex.Themes.CyberDark.Text
        label.BackgroundTransparency = 1
        label.TextWrapped = true
        label.AutomaticSize = Enum.AutomaticSize.None

        if IsArabicText(text) then
            label.TextXAlignment = Enum.TextXAlignment.Right
        else
            label.TextXAlignment = Enum.TextXAlignment.Left
        end
    end

    function Vortex:CreateWindow(config)
        config = config or {}
        local WindowName = config.Name or "VORTEX BEAST"
        local SubTitle = config.SubTitle or "Delta Mobile 2026"
        local Theme = Vortex.Themes.CyberDark

        local cam = workspace.CurrentCamera
        local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
        local winW = math.clamp(vp.X - 30, 360, 560)
        local winH = math.clamp(vp.Y - 50, 280, 360)
        local WindowSize = config.Size or UDim2.fromOffset(winW, winH)

        -- 1. ScreenGui مع تفعيل IgnoreGuiInset للحركة الحرة للأعلى
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "VORTEX_" .. HttpService:GenerateGUID(false):sub(1, 8)
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.IgnoreGuiInset = true -- يسمح بسحب النافذة لأعلى الشاشة دون عوائق
        ScreenGui.Parent = GetSafeGuiParent()

        -- 2. مقياس الشاشة الذكي UIScale
        local UIScale = Instance.new("UIScale")
        UIScale.Parent = ScreenGui
        local function UpdateDPI()
            if cam then
                local currentVp = cam.ViewportSize
                if currentVp.X < 650 or currentVp.Y < 450 then
                    UIScale.Scale = math.clamp(currentVp.X / 650, 0.72, 0.88)
                elseif currentVp.X < 900 then
                    UIScale.Scale = 0.92
                else
                    UIScale.Scale = 1.0
                end
            end
        end
        UpdateDPI()
        if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateDPI) end

        local function GetCurrentScale()
            if UIScale and UIScale.Scale and UIScale.Scale > 0 then
                return UIScale.Scale
            end
            return 1
        end

        -- 3. الإطار الأساسي MainFrame
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

        -- 4. الشريط العلوي Header مع منطقة سحب موسعة
        local Header = Instance.new("Frame")
        Header.Name = "Header"
        Header.Size = UDim2.new(1, 0, 0, 48)
        Header.BackgroundColor3 = Theme.Header
        Header.BorderSizePixel = 0
        Header.Active = true
        Header.Parent = MainFrame

        local hCorner = Instance.new("UICorner")
        hCorner.CornerRadius = UDim.new(0, 12)
        hCorner.Parent = Header

        local Title = Instance.new("TextLabel")
        ApplyTextStyle(Title, WindowName, 15, Theme.Text, Enum.Font.GothamBold)
        Title.Position = UDim2.new(0, 14, 0, 8)
        Title.Size = UDim2.new(0, 170, 0, 18)
        Title.Active = false
        Title.Parent = Header

        local SubTitleLabel = Instance.new("TextLabel")
        ApplyTextStyle(SubTitleLabel, SubTitle .. " • v3.5 Beast", 10, Theme.SubText, Enum.Font.Gotham)
        SubTitleLabel.Position = UDim2.new(0, 14, 0, 26)
        SubTitleLabel.Size = UDim2.new(0, 170, 0, 14)
        SubTitleLabel.Active = false
        SubTitleLabel.Parent = Header

        -- شريط البحث الفوري
        local SearchBox = Instance.new("TextBox")
        SearchBox.PlaceholderText = "🔍 بحث سريع..."
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

        -- 5. محرك السحب فائق السلاسة والدقة
        local isDragging = false
        local dragStart = Vector3.new()
        local startPos = UDim2.new()

        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local scale = GetCurrentScale()
                local deltaX = (input.Position.X - dragStart.X) / scale
                local deltaY = (input.Position.Y - dragStart.Y) / scale
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + deltaX,
                    startPos.Y.Scale,
                    startPos.Y.Offset + deltaY
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)

        -- 6. الزر العائم للهاتف (⚡)
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

        local bDrag = false
        local bDStart = Vector3.new()
        local bSPos = UDim2.new()
        local bMoved = false

        Bubble.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                bDrag = true
                bDStart = i.Position
                bSPos = Bubble.Position
                bMoved = false
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if bDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local dist = (i.Position - bDStart).Magnitude
                if dist > 5 then bMoved = true end
                local scale = GetCurrentScale()
                local deltaX = (i.Position.X - bDStart.X) / scale
                local deltaY = (i.Position.Y - bDStart.Y) / scale
                Bubble.Position = UDim2.new(bSPos.X.Scale, bSPos.X.Offset + deltaX, bSPos.Y.Scale, bSPos.Y.Offset + deltaY)
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                bDrag = false
            end
        end)

        Bubble.MouseButton1Click:Connect(function()
            if not bMoved then
                MainFrame.Visible = not MainFrame.Visible
                FastTween(Bubble, { Size = UDim2.new(0, 54, 0, 54) }, 0.08)
                task.wait(0.08)
                FastTween(Bubble, { Size = UDim2.new(0, 48, 0, 48) }, 0.12)
            end
        end)

        CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

        -- 7. حاوية التبويبات والمحتوى
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
        Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Sidebar.Parent = Body

        local sLayout = Instance.new("UIListLayout")
        sLayout.Padding = UDim.new(0, 6)
        sLayout.Parent = Sidebar

        local ContentArea = Instance.new("Frame")
        ContentArea.Size = UDim2.new(1, -140, 1, 0)
        ContentArea.Position = UDim2.new(0, 140, 0, 0)
        ContentArea.BackgroundTransparency = 1
        ContentArea.Parent = Body

        local WindowObj = { _gui = ScreenGui, _main = MainFrame, _tabs = {} }

        -- البحث الفوري
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

        -- إنشاء تبويب
        function WindowObj:CreateTab(tabName, icon)
            icon = icon or "⚡"
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
            TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            TabContainer.Visible = false
            TabContainer.Parent = ContentArea

            local tcPad = Instance.new("UIPadding")
            tcPad.PaddingRight = UDim.new(0, 6)
            tcPad.PaddingBottom = UDim.new(0, 10)
            tcPad.Parent = TabContainer

            local tcLayout = Instance.new("UIListLayout")
            tcLayout.Padding = UDim.new(0, 8)
            tcLayout.Parent = TabContainer

            tcLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                TabContainer.CanvasSize = UDim2.new(0, 0, 0, tcLayout.AbsoluteContentSize.Y + 20)
            end)

            local TabObj = { _btn = TabBtn, _c = TabContainer, _elements = {} }

            local function SelectTab()
                for _, t in pairs(WindowObj._tabs) do
                    t._c.Visible = false
                    t._btn.BackgroundTransparency = 0.85
                    t._btn.TextColor3 = Theme.SubText
                end
                TabContainer.Visible = true
                TabBtn.BackgroundTransparency = 0
                TabBtn.TextColor3 = Theme.Accent
            end

            TabBtn.MouseButton1Click:Connect(SelectTab)
            if #WindowObj._tabs == 0 then SelectTab() end
            table.insert(WindowObj._tabs, TabObj)

            -- إضافة قسم
            function TabObj:CreateSection(sTitle)
                local SecLbl = Instance.new("TextLabel")
                ApplyTextStyle(SecLbl, string.upper(sTitle), 11, Theme.Accent, Enum.Font.GothamBold)
                SecLbl.Size = UDim2.new(1, 0, 0, 22)
                SecLbl.Parent = TabContainer
                return SecLbl
            end

            -- زر
            function TabObj:CreateButton(opt)
                opt = opt or {}
                local bName = opt.Name or opt[1] or "Button"
                local cb = opt.Callback or opt[2]

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 40)
                Btn.BackgroundColor3 = Theme.Card
                Btn.BorderSizePixel = 0
                Btn.Text = ""
                Btn.AutoButtonColor = false
                Btn.Parent = TabContainer

                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 8)
                btnCorner.Parent = Btn

                local Lbl = Instance.new("TextLabel")
                ApplyTextStyle(Lbl, bName, 13, Theme.Text, Enum.Font.GothamSemibold)
                Lbl.Position = UDim2.new(0, 12, 0, 0)
                Lbl.Size = UDim2.new(1, -44, 1, 0)
                Lbl.Parent = Btn

                local Arrow = Instance.new("TextLabel")
                Arrow.Text = "➜"
                Arrow.Font = Enum.Font.GothamBold
                Arrow.TextSize = 12
                Arrow.TextColor3 = Theme.SubText
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(1, -28, 0.5, -8)
                Arrow.Size = UDim2.new(0, 16, 0, 16)
                Arrow.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    FastTween(Btn, { BackgroundColor3 = Theme.CardHover }, 0.08)
                    SafeCallback(cb)
                    task.wait(0.1)
                    FastTween(Btn, { BackgroundColor3 = Theme.Card }, 0.15)
                end)

                table.insert(TabObj._elements, { Frame = Btn, SearchText = bName:lower() })
                return Btn
            end
            TabObj.AddButton = TabObj.CreateButton

            -- حقل إدخال (CreateInput)
            function TabObj:CreateInput(opt)
                opt = opt or {}
                local iName = opt.Name or opt[1] or "Input Box"
                local placeholder = opt.PlaceholderText or "اكتب هنا..."
                local cb = opt.Callback or opt[2]
                local flag = opt.Flag

                local InpFrame = Instance.new("Frame")
                InpFrame.Size = UDim2.new(1, 0, 0, 42)
                InpFrame.BackgroundColor3 = Theme.Card
                InpFrame.BorderSizePixel = 0
                InpFrame.Parent = TabContainer

                local infCorner = Instance.new("UICorner")
                infCorner.CornerRadius = UDim.new(0, 8)
                infCorner.Parent = InpFrame

                local Lbl = Instance.new("TextLabel")
                ApplyTextStyle(Lbl, iName, 13, Theme.Text, Enum.Font.GothamSemibold)
                Lbl.Position = UDim2.new(0, 12, 0, 0)
                Lbl.Size = UDim2.new(0.4, 0, 1, 0)
                Lbl.Parent = InpFrame

                local TxtBox = Instance.new("TextBox")
                TxtBox.PlaceholderText = placeholder
                TxtBox.Font = Enum.Font.Gotham
                TxtBox.TextSize = 12
                TxtBox.TextColor3 = Theme.Accent
                TxtBox.PlaceholderColor3 = Theme.SubText
                TxtBox.BackgroundColor3 = Theme.Header
                TxtBox.BorderSizePixel = 0
                TxtBox.Position = UDim2.new(0.42, 0, 0.15, 0)
                TxtBox.Size = UDim2.new(0.58, -10, 0.7, 0)
                TxtBox.ClearTextOnFocus = false
                TxtBox.Parent = InpFrame

                local tbCorner = Instance.new("UICorner")
                tbCorner.CornerRadius = UDim.new(0, 6)
                tbCorner.Parent = TxtBox

                TxtBox.FocusLost:Connect(function(enter)
                    if flag then Vortex.Flags[flag] = TxtBox.Text end
                    SafeCallback(cb, TxtBox.Text, enter)
                end)

                table.insert(TabObj._elements, { Frame = InpFrame, SearchText = iName:lower() })
                return {
                    Set = function(_, t) TxtBox.Text = tostring(t); if flag then Vortex.Flags[flag] = t end end,
                    Get = function() return TxtBox.Text end
                }
            end
            TabObj.CreateTextBox = TabObj.CreateInput
            TabObj.AddInput = TabObj.CreateInput

            -- توجل
            function TabObj:CreateToggle(opt)
                opt = opt or {}
                local tName = opt.Name or opt[1] or "Toggle"
                local state = opt.CurrentValue or opt.Default or false
                local cb = opt.Callback or opt[2]
                local flag = opt.Flag

                if flag and Vortex.Flags[flag] ~= nil then state = Vortex.Flags[flag]
                elseif flag then Vortex.Flags[flag] = state end

                local TFrame = Instance.new("TextButton")
                TFrame.Size = UDim2.new(1, 0, 0, 40)
                TFrame.BackgroundColor3 = Theme.Card
                TFrame.BorderSizePixel = 0
                TFrame.Text = ""
                TFrame.AutoButtonColor = false
                TFrame.Parent = TabContainer

                local tfCorner = Instance.new("UICorner")
                tfCorner.CornerRadius = UDim.new(0, 8)
                tfCorner.Parent = TFrame

                local Lbl = Instance.new("TextLabel")
                ApplyTextStyle(Lbl, tName, 13, Theme.Text, Enum.Font.GothamSemibold)
                Lbl.Position = UDim2.new(0, 12, 0, 0)
                Lbl.Size = UDim2.new(1, -64, 1, 0)
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
                    if flag then Vortex.Flags[flag] = state end
                    FastTween(Track, { BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff }, 0.15)
                    FastTween(Knob, { Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.15)
                    SafeCallback(cb, state)
                end

                TFrame.MouseButton1Click:Connect(function() Update(not state) end)
                table.insert(TabObj._elements, { Frame = TFrame, SearchText = tName:lower() })
                return { Set = function(_, v) Update(v) end, Get = function() return state end }
            end
            TabObj.AddToggle = TabObj.CreateToggle

            -- سلايدر
            function TabObj:CreateSlider(opt)
                opt = opt or {}
                local sName = opt.Name or opt[1] or "Slider"
                local minV = (opt.Range and opt.Range[1]) or opt.Min or 0
                local maxV = (opt.Range and opt.Range[2]) or opt.Max or 100
                local curV = opt.CurrentValue or opt.Default or minV
                local cb = opt.Callback or opt[2]
                local flag = opt.Flag

                if flag and Vortex.Flags[flag] ~= nil then curV = Vortex.Flags[flag]
                elseif flag then Vortex.Flags[flag] = curV end

                local SFrame = Instance.new("Frame")
                SFrame.Size = UDim2.new(1, 0, 0, 52)
                SFrame.BackgroundColor3 = Theme.Card
                SFrame.BorderSizePixel = 0
                SFrame.Parent = TabContainer

                local sfCorner = Instance.new("UICorner")
                sfCorner.CornerRadius = UDim.new(0, 8)
                sfCorner.Parent = SFrame

                local Lbl = Instance.new("TextLabel")
                ApplyTextStyle(Lbl, sName, 13, Theme.Text, Enum.Font.GothamSemibold)
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
                Bar.Position = UDim2.new(0, 12, 0, 34)
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
                    if flag then Vortex.Flags[flag] = curV end
                    SafeCallback(cb, curV)
                end

                SFrame.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        sliding = true; Update(i.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        Update(i.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
                end)

                table.insert(TabObj._elements, { Frame = SFrame, SearchText = sName:lower() })
                return {
                    Set = function(_, v)
                        curV = math.clamp(v, minV, maxV)
                        Fill.Size = UDim2.new((curV - minV) / (maxV - minV), 0, 1, 0)
                        ValLbl.Text = tostring(curV)
                        if flag then Vortex.Flags[flag] = curV end
                        SafeCallback(cb, curV)
                    end,
                    Get = function() return curV end
                }
            end
            TabObj.AddSlider = TabObj.CreateSlider

            -- قائمة منسدلة Dropdown
            function TabObj:CreateDropdown(opt)
                opt = opt or {}
                local dName = opt.Name or opt[1] or "Dropdown"
                local opts = opt.Options or opt[2] or {}
                local cb = opt.Callback or opt[3]
                local flag = opt.Flag
                local cur = opts[1] or "اختر..."

                if flag and Vortex.Flags[flag] ~= nil then cur = Vortex.Flags[flag]
                elseif flag then Vortex.Flags[flag] = cur end

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
                local OptHolder = Instance.new("ScrollingFrame")
                OptHolder.Size = UDim2.new(1, -16, 0, 110)
                OptHolder.Position = UDim2.new(0, 8, 0, 42)
                OptHolder.BackgroundTransparency = 1
                OptHolder.BorderSizePixel = 0
                OptHolder.ScrollBarThickness = 2
                OptHolder.Parent = DFrame

                local ohLayout = Instance.new("UIListLayout")
                ohLayout.Padding = UDim.new(0, 4)
                ohLayout.Parent = OptHolder

                local function Populate(options)
                    for _, ch in pairs(OptHolder:GetChildren()) do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    for _, o in ipairs(options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, 0, 0, 24)
                        OptBtn.BackgroundColor3 = Theme.Header
                        OptBtn.Text = o
                        OptBtn.TextColor3 = Theme.Text
                        OptBtn.Font = Enum.Font.Gotham
                        OptBtn.TextSize = 11
                        OptBtn.BorderSizePixel = 0
                        OptBtn.Parent = OptHolder

                        local opCorner = Instance.new("UICorner")
                        opCorner.CornerRadius = UDim.new(0, 4)
                        opCorner.Parent = OptBtn

                        OptBtn.MouseButton1Click:Connect(function()
                            cur = o
                            TBtn.Text = "  " .. dName .. "  ➜  " .. cur
                            open = false
                            FastTween(DFrame, { Size = UDim2.new(1, 0, 0, 40) }, 0.16)
                            if flag then Vortex.Flags[flag] = cur end
                            SafeCallback(cb, cur)
                        end)
                    end
                    OptHolder.CanvasSize = UDim2.new(0, 0, 0, #options * 28)
                end
                Populate(opts)

                TBtn.MouseButton1Click:Connect(function()
                    open = not open
                    FastTween(DFrame, { Size = UDim2.new(1, 0, 0, open and math.min(160, 48 + (#opts * 28)) or 40) }, 0.16)
                end)

                table.insert(TabObj._elements, { Frame = DFrame, SearchText = dName:lower() })
                return {
                    Set = function(_, o) cur = o; TBtn.Text = "  " .. dName .. "  ➜  " .. cur; if flag then Vortex.Flags[flag] = o end end,
                    Refresh = function(_, newOpts) opts = newOpts; Populate(newOpts) end,
                    Get = function() return cur end
                }
            end
            TabObj.AddDropdown = TabObj.CreateDropdown

            -- مفاتيح ولمس Keybind
            function TabObj:CreateKeybind(opt)
                opt = opt or {}
                local kName = opt.Name or opt[1] or "Keybind"
                local currentKey = opt.Default or opt[2] or "E"
                local cb = opt.Callback or opt[3]
                local flag = opt.Flag

                local KFrame = Instance.new("TextButton")
                KFrame.Size = UDim2.new(1, 0, 0, 40)
                KFrame.BackgroundColor3 = Theme.Card
                KFrame.BorderSizePixel = 0
                KFrame.Text = ""
                KFrame.AutoButtonColor = false
                KFrame.Parent = TabContainer

                local kfCorner = Instance.new("UICorner")
                kfCorner.CornerRadius = UDim.new(0, 8)
                kfCorner.Parent = KFrame

                local Lbl = Instance.new("TextLabel")
                ApplyTextStyle(Lbl, kName, 13, Theme.Text, Enum.Font.GothamSemibold)
                Lbl.Position = UDim2.new(0, 12, 0, 0)
                Lbl.Size = UDim2.new(0.6, 0, 1, 0)
                Lbl.Parent = KFrame

                local KeyBadge = Instance.new("TextButton")
                KeyBadge.Text = tostring(currentKey)
                KeyBadge.Font = Enum.Font.GothamBold
                KeyBadge.TextSize = 11
                KeyBadge.TextColor3 = Theme.Accent
                KeyBadge.BackgroundColor3 = Theme.Header
                KeyBadge.BorderSizePixel = 0
                KeyBadge.Position = UDim2.new(1, -60, 0.5, -11)
                KeyBadge.Size = UDim2.new(0, 48, 0, 22)
                KeyBadge.Parent = KFrame

                local kbCorner = Instance.new("UICorner")
                kbCorner.CornerRadius = UDim.new(0, 4)
                kbCorner.Parent = KeyBadge

                local isListening = false
                KeyBadge.MouseButton1Click:Connect(function()
                    isListening = true
                    KeyBadge.Text = "..."
                end)

                KFrame.MouseButton1Click:Connect(function()
                    if not isListening then SafeCallback(cb, currentKey) end
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if isListening and input.KeyCode ~= Enum.KeyCode.Unknown then
                        isListening = false
                        currentKey = input.KeyCode.Name
                        KeyBadge.Text = tostring(currentKey)
                        if flag then Vortex.Flags[flag] = currentKey end
                    elseif not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode.Name:lower() == tostring(currentKey):lower() then
                            SafeCallback(cb, currentKey)
                        end
                    end
                end)

                table.insert(TabObj._elements, { Frame = KFrame, SearchText = kName:lower() })
                return {
                    Set = function(_, k) currentKey = k; KeyBadge.Text = tostring(k) end,
                    Get = function() return currentKey end
                }
            end
            TabObj.AddKeybind = TabObj.CreateKeybind

            -- محدد الألوان ColorPicker
            function TabObj:CreateColorPicker(opt)
                opt = opt or {}
                local cName = opt.Name or opt[1] or "Color Picker"
                local curColor = opt.Color or opt[2] or Color3.fromRGB(0, 240, 255)
                local cb = opt.Callback or opt[3]
                local flag = opt.Flag

                local CFrame = Instance.new("TextButton")
                CFrame.Size = UDim2.new(1, 0, 0, 40)
                CFrame.BackgroundColor3 = Theme.Card
                CFrame.BorderSizePixel = 0
                CFrame.Text = ""
                CFrame.AutoButtonColor = false
                CFrame.Parent = TabContainer

                local cfCorner = Instance.new("UICorner")
                cfCorner.CornerRadius = UDim.new(0, 8)
                cfCorner.Parent = CFrame

                local Lbl = Instance.new("TextLabel")
                ApplyTextStyle(Lbl, cName, 13, Theme.Text, Enum.Font.GothamSemibold)
                Lbl.Position = UDim2.new(0, 12, 0, 0)
                Lbl.Size = UDim2.new(0.6, 0, 1, 0)
                Lbl.Parent = CFrame

                local Tile = Instance.new("Frame")
                Tile.Size = UDim2.new(0, 36, 0, 22)
                Tile.Position = UDim2.new(1, -48, 0.5, -11)
                Tile.BackgroundColor3 = curColor
                Tile.BorderSizePixel = 0
                Tile.Parent = CFrame

                local tCorner = Instance.new("UICorner")
                tCorner.CornerRadius = UDim.new(0, 6)
                tCorner.Parent = Tile

                local Palette = {
                    Color3.fromRGB(0, 240, 255),
                    Color3.fromRGB(0, 255, 157),
                    Color3.fromRGB(255, 42, 85),
                    Color3.fromRGB(170, 68, 255),
                    Color3.fromRGB(255, 183, 3),
                    Color3.fromRGB(255, 255, 255)
                }
                local pIdx = 1

                CFrame.MouseButton1Click:Connect(function()
                    pIdx = (pIdx % #Palette) + 1
                    curColor = Palette[pIdx]
                    Tile.BackgroundColor3 = curColor
                    if flag then Vortex.Flags[flag] = curColor end
                    SafeCallback(cb, curColor)
                end)

                table.insert(TabObj._elements, { Frame = CFrame, SearchText = cName:lower() })
                return {
                    Set = function(_, col) curColor = col; Tile.BackgroundColor3 = col; SafeCallback(cb, col) end,
                    Get = function() return curColor end
                }
            end
            TabObj.AddColorPicker = TabObj.CreateColorPicker

            return TabObj
        end

        -- نافذة التأكيد Dialog
        function WindowObj:Dialog(dConfig)
            dConfig = dConfig or {}
            local dTitle = dConfig.Title or "تأكيد"
            local dContent = dConfig.Content or "هل أنت متأكد؟"
            local buttons = dConfig.Buttons or {
                { Title = "تأكيد", Callback = function() end, Primary = true },
                { Title = "إلغاء", Callback = function() end }
            }

            local Overlay = Instance.new("Frame")
            Overlay.Size = UDim2.new(1, 0, 1, 0)
            Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Overlay.BackgroundTransparency = 0.5
            Overlay.BorderSizePixel = 0
            Overlay.ZIndex = 50
            Overlay.Parent = MainFrame

            local DialogBox = Instance.new("Frame")
            DialogBox.Size = UDim2.new(0, 300, 0, 150)
            DialogBox.Position = UDim2.new(0.5, -150, 0.5, -75)
            DialogBox.BackgroundColor3 = Theme.Header
            DialogBox.BorderSizePixel = 0
            DialogBox.ZIndex = 51
            DialogBox.Parent = Overlay

            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(0, 10)
            dCorner.Parent = DialogBox

            local dStroke = Instance.new("UIStroke")
            dStroke.Color = Theme.Accent
            dStroke.Thickness = 1.2
            dStroke.Parent = DialogBox

            local DTitleLbl = Instance.new("TextLabel")
            ApplyTextStyle(DTitleLbl, dTitle, 14, Theme.Accent, Enum.Font.GothamBold)
            DTitleLbl.Position = UDim2.new(0, 12, 0, 12)
            DTitleLbl.Size = UDim2.new(1, -24, 0, 18)
            DTitleLbl.ZIndex = 52
            DTitleLbl.Parent = DialogBox

            local DContentLbl = Instance.new("TextLabel")
            ApplyTextStyle(DContentLbl, dContent, 12, Theme.Text, Enum.Font.Gotham)
            DContentLbl.Position = UDim2.new(0, 12, 0, 36)
            DContentLbl.Size = UDim2.new(1, -24, 0, 50)
            DContentLbl.ZIndex = 52
            DContentLbl.Parent = DialogBox

            local BtnHolder = Instance.new("Frame")
            BtnHolder.Size = UDim2.new(1, -24, 0, 32)
            BtnHolder.Position = UDim2.new(0, 12, 1, -42)
            BtnHolder.BackgroundTransparency = 1
            BtnHolder.ZIndex = 52
            BtnHolder.Parent = DialogBox

            local bLayout = Instance.new("UIListLayout")
            bLayout.FillDirection = Enum.FillDirection.Horizontal
            bLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            bLayout.Padding = UDim.new(0, 8)
            bLayout.Parent = BtnHolder

            for _, btnData in ipairs(buttons) do
                local B = Instance.new("TextButton")
                B.Size = UDim2.new(0, 75, 1, 0)
                B.BackgroundColor3 = btnData.Primary and Theme.Accent or Theme.Card
                B.Text = btnData.Title
                B.TextColor3 = btnData.Primary and Color3.fromRGB(10, 10, 10) or Theme.Text
                B.Font = Enum.Font.GothamBold
                B.TextSize = 11
                B.ZIndex = 53
                B.Parent = BtnHolder

                local bCorner2 = Instance.new("UICorner")
                bCorner2.CornerRadius = UDim.new(0, 6)
                bCorner2.Parent = B

                B.MouseButton1Click:Connect(function()
                    Overlay:Destroy()
                    SafeCallback(btnData.Callback)
                end)
            end
        end

        return WindowObj
    end

    -- نظام الإشعارات المنبثقة Notify
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
            targetGui.IgnoreGuiInset = true
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
        Toast.Size = UDim2.new(1, 0, 0, 64)
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
        ApplyTextStyle(tTitle, nTitle, 13, Vortex.Themes.CyberDark.Accent, Enum.Font.GothamBold)
        tTitle.Position = UDim2.new(0, 12, 0, 8)
        tTitle.Size = UDim2.new(1, -24, 0, 16)
        tTitle.Parent = Toast

        local tBody = Instance.new("TextLabel")
        ApplyTextStyle(tBody, nContent, 11, Vortex.Themes.CyberDark.Text, Enum.Font.Gotham)
        tBody.Position = UDim2.new(0, 12, 0, 26)
        tBody.Size = UDim2.new(1, -24, 0, 26)
        tBody.Parent = Toast

        local Prog = Instance.new("Frame")
        Prog.Size = UDim2.new(1, 0, 0, 2)
        Prog.Position = UDim2.new(0, 0, 1, -2)
        Prog.BackgroundColor3 = Vortex.Themes.CyberDark.Accent
        Prog.BorderSizePixel = 0
        Prog.Parent = Toast

        FastTween(Prog, { Size = UDim2.new(0, 0, 0, 2) }, duration)
        task.delay(duration, function()
            FastTween(Toast, { BackgroundTransparency = 1 }, 0.25)
            FastTween(tTitle, { TextTransparency = 1 }, 0.25)
            FastTween(tBody, { TextTransparency = 1 }, 0.25)
            FastTween(tStroke, { Transparency = 1 }, 0.25)
            task.wait(0.25)
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
    SubTitle = "Delta Mobile 2026"
})

-- إشعار عائم
Vortex:Notify({
    Title = "VORTEX v3.5",
    Content = "تم تشغيل المكتبة بنجاح! تم حل مشكلة التحريك للأعلى والواجهة تعمل بسلاسة 100%.",
    Duration = 3.5
})

-- التبويب 1: اللاعب والسرعة
local TabPlayer = Window:CreateTab("اللاعب", "👤")
TabPlayer:CreateSection("السرعة والفيزياء (دعم كامل للعربية RTL)")

-- حقل إدخال السرعة بدقة
TabPlayer:CreateInput({
    Name = "كتابة سرعة مخصصة بدقة",
    PlaceholderText = "مثال: 0.09 أو 120...",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = num
                Vortex:Notify("تم التعديل", "تم ضبط السرعة على: " .. tostring(num), 2.5)
            end
        else
            Vortex:Notify("تنبيه", "يرجى كتابة رقم صحيح فقط!", 2)
        end
    end
})

-- حفظ الحالة في الـ Flags
TabPlayer:CreateToggle({
    Name = "القفز اللانهائي في الهواء",
    CurrentValue = false,
    Flag = "InfiniteJumpFlag",
    Callback = function(state)
        Vortex:Notify("الحالة", state and "تم تفعيل القفز اللانهائي" or "تم الإيقاف", 2)
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

-- التبويب 2: الأوتوفارم والقوائم والمفاتيح
local TabFarm = Window:CreateTab("الأوتو", "⚡")
TabFarm:CreateSection("التجميع والقوائم المنسدلة")

TabFarm:CreateDropdown({
    Name = "اختيار أسلوب الهجوم",
    Options = {"الأقرب جغرافياً", "أضعف صحة", "أعلى مكافأة", "الزعماء فقط"},
    Flag = "TargetModeFlag",
    Callback = function(selected)
        Vortex:Notify("الهدف", "تم تحديد النمط: " .. selected, 2)
    end
})

TabFarm:CreateKeybind({
    Name = "مفتاح تشغيل الأوتوفارم السريع",
    Default = "E",
    Callback = function(key)
        Vortex:Notify("اختصار المفاتيح", "تم الضغط على المفتاح: " .. tostring(key), 2)
    end
})

TabFarm:CreateColorPicker({
    Name = "لون تحديد الأعداء (ESP Color)",
    Color = Color3.fromRGB(0, 240, 255),
    Flag = "ESPColorFlag",
    Callback = function(color)
        Vortex:Notify("الألوان", "تم تحديث لون التحديد!", 2)
    end
})

-- التبويب 3: الإعدادات والنوافذ المنبثقة
local TabSettings = Window:CreateTab("الإعدادات", "⚙️")
TabSettings:CreateSection("النظام والأمان")

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
                        Vortex:Notify("تم الضبط", "تمت إعادة الضبط بنجاح!", 2.5)
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
