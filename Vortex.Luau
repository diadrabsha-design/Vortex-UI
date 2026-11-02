-- [[ ====================================================================
--    AURA LUXE UI LIBRARY (ULTIMATE EDITION - ARABIC & MULTI-SLOT)
--    Engineered for Delta, Codex & Roblox Mobile Executors
--    Enhanced with RTL, UIGradients, Keybind Modes, Watermark & Smooth Scroll
--    ==================================================================== ]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- دالة مساعدة لاكتشاف اللغة العربية فائقة السرعة
local function IsArabic(str)
    if typeof(str) ~= "string" then return false end
    -- نطاق محارف اللغة العربية في ترميز UTF-8
    return str:match("[\216-\219][\128-\191]") ~= nil
end

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
    Registry = {},       -- لتخزين دوال التحكم البرمجي Set
    AllElements = {},    -- لتخزين جميع العناصر للبحث
    CurrentScreenGui = nil,
    NotifHolder = nil,
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

-- نظام التمرير الناعم (Smooth Scrolling)
local function EnableSmoothScroll(scrollFrame)
    local targetPos = scrollFrame.CanvasPosition.Y
    local scrollTween = nil

    scrollFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local maxScroll = math.max(0, scrollFrame.AbsoluteCanvasSize.Y - scrollFrame.AbsoluteWindowSize.Y)
            local delta = input.Position.Z * 55
            targetPos = math.clamp(targetPos - delta, 0, maxScroll)

            if scrollTween then scrollTween:Cancel() end
            scrollTween = TweenService:Create(
                scrollFrame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { CanvasPosition = Vector2.new(0, targetPos) }
            )
            scrollTween:Play()
        end
    end)

    scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if not scrollTween or scrollTween.PlaybackState ~= Enum.PlaybackState.Playing then
            targetPos = scrollFrame.CanvasPosition.Y
        end
    end)
end

-- نظام سحب لمسي يدعم التقييس
local function MakeDraggable(dragHandle, targetFrame, getScaleFunc)
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
            local scale = getScaleFunc and getScaleFunc() or 1
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + (delta.X / scale),
                startPos.Y.Scale,
                startPos.Y.Offset + (delta.Y / scale)
            )
        end
    end)
end

-- ==========================================
-- 4. العلامة المائية (Watermark)
-- ==========================================
function AuraLib:CreateWatermark(text)
    if not self.CurrentScreenGui then return end

    local WatermarkFrame = Instance.new("Frame")
    WatermarkFrame.Name = "AuraWatermark"
    WatermarkFrame.Size = UDim2.new(0, 0, 0, 22)
    WatermarkFrame.AutomaticSize = Enum.AutomaticSize.X
    WatermarkFrame.Position = UDim2.new(1, -12, 0, 10)
    WatermarkFrame.AnchorPoint = Vector2.new(1, 0)
    WatermarkFrame.BackgroundColor3 = self.Theme.Card
    WatermarkFrame.ZIndex = 9999
    WatermarkFrame.Parent = self.CurrentScreenGui

    Instance.new("UICorner", WatermarkFrame).CornerRadius = UDim.new(0, 6)
    local WmStroke = Instance.new("UIStroke", WatermarkFrame)
    WmStroke.Color = self.Theme.Stroke
    WmStroke.Thickness = 1

    local WmGrad = Instance.new("UIGradient", WatermarkFrame)
    WmGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 36, 52)),
        ColorSequenceKeypoint.new(1, self.Theme.Card)
    })
    WmGrad.Rotation = 90

    local WmPadding = Instance.new("UIPadding", WatermarkFrame)
    WmPadding.PaddingLeft = UDim.new(0, 8)
    WmPadding.PaddingRight = UDim.new(0, 8)

    local WmLabel = Instance.new("TextLabel")
    WmLabel.Size = UDim2.new(0, 0, 1, 0)
    WmLabel.AutomaticSize = Enum.AutomaticSize.X
    WmLabel.BackgroundTransparency = 1
    WmLabel.Text = (text or "Aura Luxe") .. " | FPS: -- | Ping: --ms"
    WmLabel.TextColor3 = self.Theme.TextPrimary
    WmLabel.TextSize = 9
    WmLabel.Font = self.Theme.FontBold
    WmLabel.ZIndex = 10000
    WmLabel.Parent = WatermarkFrame

    local frameCount = 0
    local lastTime = os.clock()
    local ping = 0

    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = os.clock()
        if now - lastTime >= 1 then
            local fps = math.round(frameCount / (now - lastTime))
            frameCount = 0
            lastTime = now

            pcall(function()
                local stats = game:GetService("Stats")
                if stats and stats.Network and stats.Network.ServerStatsItem and stats.Network.ServerStatsItem["Data Ping"] then
                    ping = math.round(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end
            end)

            WmLabel.Text = string.format("%s | FPS: %d | Ping: %dms", text or "Aura Luxe", fps, ping)
        end
    end)
end

-- ==========================================
-- 5. نظام القوائم المتعددة (Multi-Slot Configs)
-- ==========================================
local function NormalizeSlot(slot)
    slot = tostring(slot or "Slot1"):gsub("%s+", "")
    if not slot:find("%.json$") then
        slot = slot .. ".json"
    end
    return slot
end

function AuraLib:SaveConfig(slot)
    local filename = NormalizeSlot(slot)
    if not writefile then
        self:Notify({ Title = "Config Error", Content = "writefile not supported.", Duration = 2.5 })
        return false
    end

    local exportData = {}
    for k, v in pairs(self.Flags) do
        if typeof(v) == "Color3" then
            exportData[k] = { __type = "Color3", R = v.R, G = v.G, B = v.B }
        else
            exportData[k] = v
        end
    end

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(exportData)
    end)

    if success and encoded then
        local writeSuccess = pcall(function()
            writefile(filename, encoded)
        end)
        if writeSuccess then
            self:Notify({ Title = "Config Saved", Content = "Saved to " .. filename, Duration = 2.5 })
            return true
        end
    end
    self:Notify({ Title = "Config Error", Content = "Failed to save file.", Duration = 2.5 })
    return false
end

function AuraLib:LoadConfig(slot)
    local filename = NormalizeSlot(slot)
    if not readfile or (isfile and not isfile(filename)) then
        self:Notify({ Title = "Config Error", Content = "File " .. filename .. " not found.", Duration = 2.5 })
        return false
    end

    local content
    local readSuccess = pcall(function()
        content = readfile(filename)
    end)

    if not readSuccess or not content then return false end

    local decodeSuccess, decoded = pcall(function()
        return HttpService:JSONDecode(content)
    end)

    if decodeSuccess and typeof(decoded) == "table" then
        for flagName, val in pairs(decoded) do
            if typeof(val) == "table" and val.__type == "Color3" then
                val = Color3.new(val.R, val.G, val.B)
            end
            if self.Registry[flagName] then
                pcall(self.Registry[flagName], val)
            else
                self.Flags[flagName] = val
            end
        end
        self:Notify({ Title = "Config Loaded", Content = "Loaded from " .. filename, Duration = 2.5 })
        return true
    end
    return false
end

-- نظام الإشعارات المتراكمة
function AuraLib:Notify(notifConfig)
    if not self.CurrentScreenGui then return end
    
    local nTitle = notifConfig.Title or "Notification"
    local nContent = notifConfig.Content or ""
    local nTime = notifConfig.Duration or 3

    if not self.NotifHolder or not self.NotifHolder.Parent then
        self.NotifHolder = Instance.new("Frame")
        self.NotifHolder.Name = "NotifHolder"
        self.NotifHolder.Size = UDim2.new(0, 220, 1, -20)
        self.NotifHolder.Position = UDim2.new(1, -230, 0, 10)
        self.NotifHolder.BackgroundTransparency = 1
        self.NotifHolder.ZIndex = 5000
        self.NotifHolder.Parent = self.CurrentScreenGui

        local NotifLayout = Instance.new("UIListLayout", self.NotifHolder)
        NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        NotifLayout.Padding = UDim.new(0, 6)
        NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    end

    local NotifCard = Instance.new("Frame")
    NotifCard.Size = UDim2.new(1, 0, 0, 48)
    NotifCard.BackgroundColor3 = self.Theme.Card
    NotifCard.ZIndex = 5001
    NotifCard.Parent = self.NotifHolder

    Instance.new("UICorner", NotifCard).CornerRadius = UDim.new(0, 8)
    local NStroke = Instance.new("UIStroke", NotifCard)
    NStroke.Color = self.Theme.Accent
    NStroke.Thickness = 1.1

    local NTitle = Instance.new("TextLabel", NotifCard)
    NTitle.Size = UDim2.new(1, -16, 0, 16)
    NTitle.Position = UDim2.new(0, 8, 0, 6)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = nTitle
    NTitle.TextColor3 = self.Theme.TextPrimary
    NTitle.TextSize = 11
    NTitle.Font = self.Theme.FontBold
    NTitle.TextXAlignment = IsArabic(nTitle) and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    NTitle.ZIndex = 5002

    local NDesc = Instance.new("TextLabel", NotifCard)
    NDesc.Size = UDim2.new(1, -16, 0, 18)
    NDesc.Position = UDim2.new(0, 8, 0, 24)
    NDesc.BackgroundTransparency = 1
    NDesc.Text = nContent
    NDesc.TextColor3 = self.Theme.TextSecondary
    NDesc.TextSize = 9
    NDesc.Font = self.Theme.Font
    NDesc.TextXAlignment = IsArabic(nContent) and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    NDesc.TextWrapped = true
    NDesc.ZIndex = 5002

    NotifCard.Position = UDim2.new(1, 50, 0, 0)
    Tween(NotifCard, {Position = UDim2.new(0, 0, 0, 0)}, 0.25)

    task.delay(nTime, function()
        pcall(function()
            local closeTween = Tween(NotifCard, {Position = UDim2.new(1, 80, 0, 0), BackgroundTransparency = 1}, 0.25)
            closeTween.Completed:Connect(function()
                NotifCard:Destroy()
            end)
        end)
    end)
end

function AuraLib:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "AURA LUXE"
    local Subtitle = config.Subtitle or "Ultimate Edition"

    local Window = { CurrentTab = nil }

    local Blur = Instance.new("BlurEffect")
    Blur.Name = "AuraLoadingBlur"
    Blur.Size = 48
    pcall(function() Blur.Parent = Lighting end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AuraLuxeUltimate"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 2147483647
    ScreenGui.Parent = SafeParent
    AuraLib.CurrentScreenGui = ScreenGui

    ScreenGui.Destroying:Connect(function()
        pcall(function() if Blur then Blur:Destroy() end end)
    end)

    -- شاشة التحميل (Loader)
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

    -- زر الهاتف العائم
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

    -- 2. تدرج الإطار الرئيسي (MainStroke UIGradient)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 1.4

    local StrokeGrad = Instance.new("UIGradient", MainStroke)
    StrokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, AuraLib.Theme.Accent),
        ColorSequenceKeypoint.new(0.5, AuraLib.Theme.AccentGradient),
        ColorSequenceKeypoint.new(1, AuraLib.Theme.Stroke)
    })
    StrokeGrad.Rotation = 45

    -- التقييس المتجاوب (Responsive Scale)
    local MainScale = Instance.new("UIScale", MainFrame)
    local function UpdateScale()
        pcall(function()
            local cam = Workspace.CurrentCamera
            if cam then
                local vpX = cam.ViewportSize.X
                if vpX < 600 then
                    MainScale.Scale = math.clamp(vpX / 580, 0.65, 0.8)
                else
                    MainScale.Scale = 1
                end
            end
        end)
    end
    UpdateScale()
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
    end

    -- 2. شريط العنوان مع التدرج اللوني (Header with UIGradient)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
    Header.BorderSizePixel = 0
    Header.ZIndex = 11
    Header.Parent = MainFrame
    MakeDraggable(Header, MainFrame, function() return MainScale.Scale end)

    local HeaderGrad = Instance.new("UIGradient", Header)
    HeaderGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 34, 50)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 22, 32)),
        ColorSequenceKeypoint.new(1, AuraLib.Theme.Background)
    })
    HeaderGrad.Rotation = 90

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 150, 0, 20)
    TitleLabel.Position = UDim2.new(0, 14, 0, 6)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = AuraLib.Theme.TextPrimary
    TitleLabel.TextSize = 13
    TitleLabel.Font = AuraLib.Theme.FontBold
    TitleLabel.TextXAlignment = IsArabic(Title) and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 12
    TitleLabel.Parent = Header

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0, 150, 0, 12)
    SubLabel.Position = UDim2.new(0, 14, 0, 24)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = Subtitle
    SubLabel.TextColor3 = AuraLib.Theme.Accent
    SubLabel.TextSize = 9
    SubLabel.Font = AuraLib.Theme.Font
    SubLabel.TextXAlignment = IsArabic(Subtitle) and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
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
    CloseBtn.ZIndex = 13
    CloseBtn.Parent = Header

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.22)
        task.wait(0.23)
        if Blur then Blur:Destroy() end
        ScreenGui:Destroy()
    end)

    -- شريط البحث (Search Box)
    local SearchBoxContainer = Instance.new("Frame")
    SearchBoxContainer.Size = UDim2.new(0, 120, 0, 24)
    SearchBoxContainer.Position = UDim2.new(1, -165, 0, 9)
    SearchBoxContainer.BackgroundColor3 = AuraLib.Theme.Card
    SearchBoxContainer.ZIndex = 12
    SearchBoxContainer.Parent = Header
    Instance.new("UICorner", SearchBoxContainer).CornerRadius = UDim.new(0, 6)
    local SearchStroke = Instance.new("UIStroke", SearchBoxContainer)
    SearchStroke.Color = AuraLib.Theme.Stroke
    SearchStroke.Thickness = 1

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -12, 1, 0)
    SearchBox.Position = UDim2.new(0, 6, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.PlaceholderText = "🔍 Search..."
    SearchBox.PlaceholderColor3 = AuraLib.Theme.TextSecondary
    SearchBox.Text = ""
    SearchBox.TextColor3 = AuraLib.Theme.TextPrimary
    SearchBox.TextSize = 9
    SearchBox.Font = AuraLib.Theme.Font
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 13
    SearchBox.Parent = SearchBoxContainer

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text):gsub("^%s*(.-)%s*$", "%1")
        for _, item in ipairs(AuraLib.AllElements) do
            pcall(function()
                if query == "" then
                    item.Frame.Visible = true
                else
                    if string.find(string.lower(item.Name), query, 1, true) then
                        item.Frame.Visible = true
                    else
                        item.Frame.Visible = false
                    end
                end
            end)
        end
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
    EnableSmoothScroll(TabScroll)

    local TabLayout = Instance.new("UIListLayout", TabScroll)
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -140, 1, -50)
    ContentHolder.Position = UDim2.new(0, 134, 0, 42)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.ZIndex = 11
    ContentHolder.Parent = MainFrame

    -- نافذة التلميحات (Tooltip)
    local TooltipCard = Instance.new("Frame")
    TooltipCard.Name = "GlobalTooltip"
    TooltipCard.Size = UDim2.new(0, 160, 0, 26)
    TooltipCard.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
    TooltipCard.Visible = false
    TooltipCard.ZIndex = 10005
    TooltipCard.Parent = MainFrame

    Instance.new("UICorner", TooltipCard).CornerRadius = UDim.new(0, 6)
    local TooltipStroke = Instance.new("UIStroke", TooltipCard)
    TooltipStroke.Color = AuraLib.Theme.Accent
    TooltipStroke.Thickness = 1

    local TooltipLabel = Instance.new("TextLabel", TooltipCard)
    TooltipLabel.Size = UDim2.new(1, -10, 1, 0)
    TooltipLabel.Position = UDim2.new(0, 5, 0, 0)
    TooltipLabel.BackgroundTransparency = 1
    TooltipLabel.TextColor3 = AuraLib.Theme.TextPrimary
    TooltipLabel.TextSize = 9
    TooltipLabel.Font = AuraLib.Theme.Font
    TooltipLabel.TextWrapped = true
    TooltipLabel.Text = ""
    TooltipLabel.ZIndex = 10006

    local function ShowTooltip(text)
        TooltipLabel.Text = text
        TooltipLabel.TextXAlignment = IsArabic(text) and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
        TooltipCard.Visible = true
        TooltipCard.Position = UDim2.new(0.5, -80, 1, -32)
        Tween(TooltipCard, {BackgroundTransparency = 0}, 0.15)
    end

    local function HideTooltip()
        TooltipCard.Visible = false
    end

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

        local isTabAr = IsArabic(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 28)
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = isTabAr and (tabName .. "  ") or ("  " .. tabName)
        TabBtn.TextColor3 = AuraLib.Theme.TextSecondary
        TabBtn.TextSize = 11
        TabBtn.Font = AuraLib.Theme.Font
        TabBtn.TextXAlignment = isTabAr and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
        TabBtn.ZIndex = 13
        TabBtn.Parent = TabScroll

        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        -- 6. تطبيق التمرير الناعم (Smooth Scroll)
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
        EnableSmoothScroll(Page)

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

        -- 1 & 2. زر تنفيذي مع تدرج لوني ودعم RTL
        function Tab:CreateButton(btnConfig)
            local btnName = btnConfig.Name or "Button"
            local desc = btnConfig.Desc
            StepLoad(btnName)
            local callback = btnConfig.Callback or function() end

            local isAr = IsArabic(btnName)

            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 24)
            BtnFrame.BackgroundColor3 = AuraLib.Theme.Card
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            BtnFrame.ZIndex = 13
            BtnFrame.Parent = Page

            table.insert(AuraLib.AllElements, { Frame = BtnFrame, Name = btnName, Tab = Page })

            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 6)
            local Stroke = Instance.new("UIStroke", BtnFrame)
            Stroke.Color = AuraLib.Theme.Stroke
            Stroke.Thickness = 1

            -- 2. UIGradient خفيف للأزرار
            local BtnGrad = Instance.new("UIGradient", BtnFrame)
            BtnGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 36, 52)),
                ColorSequenceKeypoint.new(1, AuraLib.Theme.Card)
            })
            BtnGrad.Rotation = 90

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, desc and -45 or -30, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = btnName
            Label.TextColor3 = AuraLib.Theme.TextPrimary
            Label.TextSize = 10
            Label.Font = AuraLib.Theme.Font
            Label.TextXAlignment = isAr and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
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

            if desc then
                local InfoBtn = Instance.new("TextButton")
                InfoBtn.Size = UDim2.new(0, 14, 0, 14)
                InfoBtn.Position = UDim2.new(1, -38, 0.5, -7)
                InfoBtn.BackgroundColor3 = AuraLib.Theme.Sidebar
                InfoBtn.Text = "?"
                InfoBtn.TextColor3 = AuraLib.Theme.TextSecondary
                InfoBtn.TextSize = 9
                InfoBtn.Font = AuraLib.Theme.FontBold
                InfoBtn.ZIndex = 15
                InfoBtn.Parent = BtnFrame
                Instance.new("UICorner", InfoBtn).CornerRadius = UDim.new(1, 0)

                InfoBtn.MouseButton1Click:Connect(function()
                    ShowTooltip(desc)
                    task.delay(2.5, HideTooltip)
                end)

                BtnFrame.MouseEnter:Connect(function() ShowTooltip(desc) end)
                BtnFrame.MouseLeave:Connect(HideTooltip)
            end

            BtnFrame.MouseButton1Down:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = AuraLib.Theme.CardHover}, 0.1)
            end)

            BtnFrame.MouseButton1Up:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = AuraLib.Theme.Card}, 0.15)
                pcall(callback)
            end)
        end

        -- 1 & 2. زر تبديل مع RTL و UIGradient و Set/Get
        function Tab:CreateToggle(tglConfig)
            local tglName = tglConfig.Name or "Toggle"
            local desc = tglConfig.Desc
            StepLoad(tglName)

            local isAr = IsArabic(tglName)
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

            table.insert(AuraLib.AllElements, { Frame = TglFrame, Name = tglName, Tab = Page })

            Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)
            local Stroke = Instance.new("UIStroke", TglFrame)
            Stroke.Color = AuraLib.Theme.Stroke
            Stroke.Thickness = 1

            local TglGrad = Instance.new("UIGradient", TglFrame)
            TglGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 36, 52)),
                ColorSequenceKeypoint.new(1, AuraLib.Theme.Card)
            })
            TglGrad.Rotation = 90

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, desc and -55 or -40, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = tglName
            Label.TextColor3 = AuraLib.Theme.TextPrimary
            Label.TextSize = 10
            Label.Font = AuraLib.Theme.Font
            Label.TextXAlignment = isAr and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
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

            local function UpdateState(callCb)
                AuraLib.Flags[tglName] = state
                if state then
                    Tween(Switch, {BackgroundColor3 = AuraLib.Theme.Accent}, 0.2)
                    Tween(Knob, {Position = UDim2.new(1, -11, 0.5, -4)}, 0.2)
                else
                    Tween(Switch, {BackgroundColor3 = Color3.fromRGB(35, 40, 55)}, 0.2)
                    Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -4)}, 0.2)
                end
                if callCb ~= false then
                    pcall(callback, state)
                end
            end

            if desc then
                local InfoBtn = Instance.new("TextButton")
                InfoBtn.Size = UDim2.new(0, 14, 0, 14)
                InfoBtn.Position = UDim2.new(1, -50, 0.5, -7)
                InfoBtn.BackgroundColor3 = AuraLib.Theme.Sidebar
                InfoBtn.Text = "?"
                InfoBtn.TextColor3 = AuraLib.Theme.TextSecondary
                InfoBtn.TextSize = 9
                InfoBtn.Font = AuraLib.Theme.FontBold
                InfoBtn.ZIndex = 15
                InfoBtn.Parent = TglFrame
                Instance.new("UICorner", InfoBtn).CornerRadius = UDim.new(1, 0)

                InfoBtn.MouseButton1Click:Connect(function()
                    ShowTooltip(desc)
                    task.delay(2.5, HideTooltip)
                end)

                TglFrame.MouseEnter:Connect(function() ShowTooltip(desc) end)
                TglFrame.MouseLeave:Connect(HideTooltip)
            end

            TglFrame.MouseButton1Click:Connect(function()
                state = not state
                UpdateState(true)
            end)

            local ToggleController = {}
            function ToggleController:Set(val)
                state = (val == true)
                UpdateState(true)
            end
            function ToggleController:Get()
                return state
            end

            AuraLib.Registry[tglName] = function(v) ToggleController:Set(v) end
            return ToggleController
        end

        -- سلايدر
        function Tab:CreateSlider(sldConfig)
            local sldName = sldConfig.Name or "Slider"
            StepLoad(sldName)

            local isAr = IsArabic(sldName)
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

            table.insert(AuraLib.AllElements, { Frame = SldFrame, Name = sldName, Tab = Page })

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
            Label.TextXAlignment = isAr and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
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

            local SliderController = {}
            function SliderController:Set(newVal)
                newVal = math.clamp(tonumber(newVal) or min, min, max)
                value = newVal
                ValLabel.Text = tostring(value)
                Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                AuraLib.Flags[sldName] = value
                pcall(callback, value)
            end
            function SliderController:Get()
                return value
            end

            AuraLib.Registry[sldName] = function(v) SliderController:Set(v) end
            return SliderController
        end

        -- إدخال نصي
        function Tab:CreateInput(inpConfig)
            local inpName = inpConfig.Name or "Input"
            StepLoad(inpName)

            local isAr = IsArabic(inpName)
            local placeholder = inpConfig.Placeholder or "Enter text..."
            local callback = inpConfig.Callback or function() end
            AuraLib.Flags[inpName] = ""

            local InpFrame = Instance.new("Frame")
            InpFrame.Size = UDim2.new(1, 0, 0, 24)
            InpFrame.BackgroundColor3 = AuraLib.Theme.Card
            InpFrame.ZIndex = 13
            InpFrame.Parent = Page

            table.insert(AuraLib.AllElements, { Frame = InpFrame, Name = inpName, Tab = Page })

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
            Label.TextXAlignment = isAr and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
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

            local InputController = {}
            function InputController:Set(text)
                TextBox.Text = tostring(text)
                AuraLib.Flags[inpName] = tostring(text)
                pcall(callback, tostring(text))
            end
            AuraLib.Registry[inpName] = function(v) InputController:Set(v) end
            return InputController
        end

        -- قائمة منسدلة
        function Tab:CreateDropdown(drpConfig)
            local drpName = drpConfig.Name or "Dropdown"
            StepLoad(drpName)

            local isAr = IsArabic(drpName)
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

            table.insert(AuraLib.AllElements, { Frame = Container, Name = drpName, Tab = Page })

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
            Label.TextXAlignment = isAr and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
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
                OptBtn.TextXAlignment = IsArabic(tostring(opt)) and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
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

            local DropdownController = {}
            function DropdownController:Set(opt)
                current = opt
                SelectedLabel.Text = tostring(opt)
                AuraLib.Flags[drpName] = opt
                pcall(callback, opt)
            end
            function DropdownController:Get()
                return current
            end

            AuraLib.Registry[drpName] = function(v) DropdownController:Set(v) end
            return DropdownController
        end

        -- 3. وضع الاختصارات المتقدم (Keybind Modes: Toggle & Hold)
        function Tab:CreateKeybind(kbConfig)
            local kbName = kbConfig.Name or "Keybind"
            local mode = kbConfig.Mode or "Toggle" -- "Toggle" أو "Hold"
            StepLoad(kbName)

            local isAr = IsArabic(kbName)
            local defaultKey = kbConfig.Default or "E"
            local currentKey = typeof(defaultKey) == "EnumItem" and defaultKey.Name or tostring(defaultKey)
            local callback = kbConfig.Callback or function() end
            local listening = false
            local isHolding = false
            local isToggled = false
            AuraLib.Flags[kbName] = currentKey

            local KbFrame = Instance.new("Frame")
            KbFrame.Size = UDim2.new(1, 0, 0, 24)
            KbFrame.BackgroundColor3 = AuraLib.Theme.Card
            KbFrame.ZIndex = 13
            KbFrame.Parent = Page

            table.insert(AuraLib.AllElements, { Frame = KbFrame, Name = kbName, Tab = Page })

            Instance.new("UICorner", KbFrame).CornerRadius = UDim.new(0, 6)
            local Stroke = Instance.new("UIStroke", KbFrame)
            Stroke.Color = AuraLib.Theme.Stroke
            Stroke.Thickness = 1

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -95, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = kbName
            Label.TextColor3 = AuraLib.Theme.TextPrimary
            Label.TextSize = 10
            Label.Font = AuraLib.Theme.Font
            Label.TextXAlignment = isAr and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
            Label.ZIndex = 14
            Label.Parent = KbFrame

            -- زر تبديل الوضع (Toggle / Hold)
            local ModeBtn = Instance.new("TextButton")
            ModeBtn.Size = UDim2.new(0, 26, 0, 16)
            ModeBtn.Position = UDim2.new(1, -82, 0.5, -8)
            ModeBtn.BackgroundColor3 = AuraLib.Theme.Sidebar
            ModeBtn.Text = mode == "Toggle" and "TG" or "HD"
            ModeBtn.TextColor3 = AuraLib.Theme.Accent
            ModeBtn.TextSize = 8
            ModeBtn.Font = AuraLib.Theme.FontBold
            ModeBtn.ZIndex = 14
            ModeBtn.Parent = KbFrame
            Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 4)

            ModeBtn.MouseButton1Click:Connect(function()
                mode = (mode == "Toggle") and "Hold" or "Toggle"
                ModeBtn.Text = (mode == "Toggle") and "TG" or "HD"
                AuraLib:Notify({
                    Title = "Keybind Mode",
                    Content = kbName .. " is now: " .. mode,
                    Duration = 1.5
                })
            end)

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Size = UDim2.new(0, 50, 0, 16)
            KeyBtn.Position = UDim2.new(1, -54, 0.5, -8)
            KeyBtn.BackgroundColor3 = AuraLib.Theme.Sidebar
            KeyBtn.Text = currentKey
            KeyBtn.TextColor3 = AuraLib.Theme.Accent
            KeyBtn.TextSize = 9
            KeyBtn.Font = AuraLib.Theme.FontBold
            KeyBtn.ZIndex = 14
            KeyBtn.Parent = KbFrame
            Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 4)

            local rebindConn
            KeyBtn.MouseButton1Click:Connect(function()
                if listening then
                    listening = false
                    KeyBtn.Text = currentKey
                    KeyBtn.TextColor3 = AuraLib.Theme.Accent
                    if rebindConn then rebindConn:Disconnect() end
                    return
                end

                listening = true
                KeyBtn.Text = "..."
                KeyBtn.TextColor3 = AuraLib.Theme.TextSecondary

                rebindConn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode.Name
                        KeyBtn.Text = currentKey
                        KeyBtn.TextColor3 = AuraLib.Theme.Accent
                        AuraLib.Flags[kbName] = currentKey
                        listening = false
                        rebindConn:Disconnect()
                    end
                end)
            end)

            -- معالجة أوضاع Toggle و Hold
            local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe or listening then return end
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == currentKey then
                    if mode == "Toggle" then
                        isToggled = not isToggled
                        pcall(callback, isToggled, input.KeyCode)
                    elseif mode == "Hold" then
                        if not isHolding then
                            isHolding = true
                            pcall(callback, true, input.KeyCode)
                        end
                    end
                end
            end)

            local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
                if listening then return end
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == currentKey then
                    if mode == "Hold" and isHolding then
                        isHolding = false
                        pcall(callback, false, input.KeyCode)
                    end
                end
            end)

            ScreenGui.Destroying:Connect(function()
                pcall(function()
                    if inputBeganConn then inputBeganConn:Disconnect() end
                    if inputEndedConn then inputEndedConn:Disconnect() end
                end)
            end)
        end

        -- محدد الألوان
        function Tab:CreateColorPicker(cpConfig)
            local cpName = cpConfig.Name or "Color Picker"
            StepLoad(cpName)

            local isAr = IsArabic(cpName)
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

            table.insert(AuraLib.AllElements, { Frame = CpContainer, Name = cpName, Tab = Page })

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
            Label.TextXAlignment = isAr and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
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

            local CpController = {}
            function CpController:Set(newCol)
                currentColor = newCol
                ColorPreview.BackgroundColor3 = newCol
                AuraLib.Flags[cpName] = newCol
                pcall(callback, newCol)
            end
            AuraLib.Registry[cpName] = function(v) CpController:Set(v) end
            return CpController
        end

        -- 1. نص / فقرة مع دعم RTL
        function Tab:CreateLabel(text)
            local isAr = IsArabic(text)
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
            Label.TextXAlignment = isAr and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.ZIndex = 14
            Label.Parent = LblContainer
        end

        -- فاصل أقسام مع دعم RTL
        function Tab:CreateSection(secName)
            local isAr = IsArabic(secName)
            local SecContainer = Instance.new("Frame")
            SecContainer.Size = UDim2.new(1, 0, 0, 20)
            SecContainer.BackgroundTransparency = 1
            SecContainer.ZIndex = 13
            SecContainer.Parent = Page

            local SecText = Instance.new("TextLabel")
            SecText.Size = UDim2.new(0, 0, 1, 0)
            SecText.Position = isAr and UDim2.new(1, -6, 0, 0) or UDim2.new(0, 6, 0, 0)
            SecText.AnchorPoint = isAr and Vector2.new(1, 0) or Vector2.new(0, 0)
            SecText.BackgroundTransparency = 1
            SecText.Text = secName or "SECTION"
            SecText.TextColor3 = AuraLib.Theme.Accent
            SecText.TextSize = 9
            SecText.Font = AuraLib.Theme.FontBold
            SecText.TextXAlignment = isAr and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
            SecText.AutomaticSize = Enum.AutomaticSize.X
            SecText.ZIndex = 14
            SecText.Parent = SecContainer

            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(0.6, 0, 0, 1)
            Line.Position = isAr and UDim2.new(0, 6, 0.5, 0) or UDim2.new(0.36, 0, 0.5, 0)
            Line.BackgroundColor3 = AuraLib.Theme.Stroke
            Line.BorderSizePixel = 0
            Line.ZIndex = 14
            Line.Parent = SecContainer
        end

        -- 5. قسم إدارة القوائم المتعددة الجاهز (Multi-Slot Config Section)
        function Tab:CreateConfigSection()
            Tab:CreateSection("إدارة الإعدادات | Config Slots")

            local selectedSlot = "Slot 1"
            Tab:CreateDropdown({
                Name = "اختر الحافظة | Slot",
                Options = {"Slot 1", "Slot 2", "Slot 3"},
                Default = "Slot 1",
                Callback = function(choice)
                    selectedSlot = choice
                end
            })

            Tab:CreateButton({
                Name = "حفظ الإعدادات | Save Config",
                Desc = "يحفظ الإعدادات الحالية في الحافظة المحددة.",
                Callback = function()
                    AuraLib:SaveConfig(selectedSlot)
                end
            })

            Tab:CreateButton({
                Name = "استرجاع الإعدادات | Load Config",
                Desc = "يسترجع الإعدادات المحفوظة من الحافظة المحددة.",
                Callback = function()
                    AuraLib:LoadConfig(selectedSlot)
                end
            })
        end

        return Tab
    end

    return Window
end

return AuraLib
