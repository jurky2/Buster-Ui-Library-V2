local Buster = {}

if not gethui then
    getfenv().gethui = function() return game:GetService("CoreGui") end
end
if not syn then
    getfenv().syn = {}
end
if not identifyexecutor then
    getfenv().identifyexecutor = function()
        if getexecutorname then
            return getexecutorname()
        end
        return "Unknown"
    end
end
if not getexecutorname then
    getfenv().getexecutorname = function()
        if identifyexecutor then
            return identifyexecutor()
        end
        return "Unknown"
    end
end
if not request then
    getfenv().request = function() return {Success = false, StatusCode = 404} end
end
if not isnetworkowner then
    getfenv().isnetworkowner = function() return true end
end
if not setscriptable then
    getfenv().setscriptable = function() end
end
if not getconnections then
    getfenv().getconnections = function() return {} end
end
if not firesignal then
    getfenv().firesignal = function() end
end
if not fireproximityprompt then
    getfenv().fireproximityprompt = function() end
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function getInsetY()
    local insetY = 0
    pcall(function()
        local inset = GuiService:GetGuiInset()
        insetY = inset.Y
    end)
    return insetY
end

local Theme = {

    Bg = Color3.fromRGB(23, 25, 29),
    Top = Color3.fromRGB(27, 29, 33),
    Side = Color3.fromRGB(27, 29, 33),
    Card = Color3.fromRGB(33, 34, 38),
    Card2 = Color3.fromRGB(33, 36, 42),
    Stroke = Color3.fromRGB(65, 69, 77),
    StrokeSoft = Color3.fromRGB(65, 69, 77),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(165, 165, 165),

    Accent = Color3.fromRGB(161, 169, 225),
    ToggleOff = Color3.fromRGB(17, 19, 22),
    Track = Color3.fromRGB(33, 34, 38),
    White = Color3.fromRGB(255, 255, 255),
}

local OldButtonTheme = {

    Neutral = Color3.fromRGB(65, 69, 77),
    NeutralHover = Color3.fromRGB(85, 89, 97),
    CloseHover = Color3.fromRGB(200, 50, 60),
}

local function tween(instance, properties, duration)
    duration = duration or 0.18
    local t = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    t:Play()
    return t
end

local function clamp(n, minValue, maxValue)
    if n < minValue then
        return minValue
    end
    if n > maxValue then
        return maxValue
    end
    return n
end

local function applyCorner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = instance
    return c
end

local function applyStroke(instance, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = 1
    s.Transparency = transparency or 0.55
    s.Parent = instance
    return s
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput
    local startPos
    local startInputPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            startInputPos = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if input == dragInput then
                dragging = false
                dragInput = nil
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragInput then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - startInputPos
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if input == dragInput or dragging then
                dragging = false
                dragInput = nil
            end
        end
    end)
end

local function truncateWithStars(text, maxChars)
    text = tostring(text or "")
    maxChars = maxChars or 24
    if #text <= maxChars then
        return text
    end
    if maxChars <= 2 then
        return "**"
    end
    return string.sub(text, 1, maxChars - 2) .. "**"
end

local function safeParentGui(gui)
    if syn and syn.protect_gui then
        pcall(function()
            syn.protect_gui(gui)
        end)
        gui.Parent = CoreGui
        return
    end
    if gethui then
        gui.Parent = gethui()
        return
    end
    gui.Parent = CoreGui
end

local function createRow(parent, height)
    local row = Instance.new("Frame")
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, height)
    row.Parent = parent
    return row
end

local function createText(parent, text, size, bold, color)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Text = text
    lbl.TextSize = size
    lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    lbl.TextColor3 = color or Theme.Text
    lbl.Parent = parent
    return lbl
end

local function createSquareToggle(parent, default, callback)
    local btn = Instance.new("TextButton")
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.BackgroundColor3 = Theme.ToggleOff
    btn.Parent = parent
    applyCorner(btn, 6)
    applyStroke(btn, Theme.StrokeSoft, 0.4)

    local state = default and true or false
    local function render()
        if state then
            btn.BackgroundColor3 = Theme.Accent
        else
            btn.BackgroundColor3 = Theme.ToggleOff
        end
    end
    render()

    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
        pcall(callback, state)
    end)

    return {
        SetValue = function(_, v)
            state = v and true or false
            render()
        end,
        GetValue = function()
            return state
        end,
    }
end

local function createDivider(parent)
    local div = Instance.new("Frame")
    div.BorderSizePixel = 0
    div.BackgroundColor3 = Theme.StrokeSoft
    div.BackgroundTransparency = 0.6
    div.Size = UDim2.new(1, -18, 0, 1)
    div.Position = UDim2.new(0, 9, 0, 0)
    div.Parent = parent
    return div
end

function Buster:CreateWindow(options)
    options = options or {}
    local titleText = options.Name or "Sev.cc"
    local subtitleText = options.Subtitle or "The Bronx"
    local footerText = options.Footer or subtitleText
    local brandText = options.BrandText or "S"
    local brandImage = options.BrandImage
    local forcedSize = options.Size
    local enableGroups = options.Groups == true
    local defaultToggleKey = options.ToggleKey or Enum.KeyCode.RightShift

    local function computeWindowSize()
        local isPhone = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        local viewport = (Camera and Camera.ViewportSize) or Vector2.new(1280, 720)
        local insetY = getInsetY()

        if isPhone then
            local availableWidth = viewport.X
            local availableHeight = viewport.Y - insetY

            local baseWidth = (forcedSize and forcedSize.Width) or 860
            local baseHeight = (forcedSize and forcedSize.Height) or 480

            local maxW = math.floor(availableWidth * 0.96)
            local maxH = math.floor(availableHeight * 0.90)

            local w = math.min(baseWidth, maxW)
            local h = math.min(baseHeight, maxH)

            return clamp(w, 420, maxW), clamp(h, 360, maxH)
        end

        if forcedSize and forcedSize.Width and forcedSize.Height then
            return forcedSize.Width, forcedSize.Height
        end

        return 860, 480
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = "Buster"
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.ResetOnSpawn = false
    safeParentGui(screen)
    
    local customCursor = Instance.new("Frame")
    customCursor.Name = "CustomCursor"
    customCursor.BackgroundColor3 = Theme.Accent
    customCursor.BorderSizePixel = 0
    customCursor.Size = UDim2.new(0, 12, 0, 12)
    customCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    customCursor.ZIndex = 50000
    customCursor.Visible = false
    customCursor.Parent = screen
    applyCorner(customCursor, 6)

    local cursorStroke = Instance.new("UIStroke")
    cursorStroke.Color = Theme.White
    cursorStroke.Thickness = 2
    cursorStroke.Transparency = 0.3
    cursorStroke.Parent = customCursor

    local cursorCenter = Instance.new("Frame")
    cursorCenter.Name = "CursorCenter"
    cursorCenter.BackgroundColor3 = Theme.White
    cursorCenter.BorderSizePixel = 0
    cursorCenter.Size = UDim2.new(0, 4, 0, 4)
    cursorCenter.Position = UDim2.new(0.5, -2, 0.5, -2)
    cursorCenter.ZIndex = 50001
    cursorCenter.Parent = customCursor
    applyCorner(cursorCenter, 2)

    local cursorEnabled = false
    RunService.RenderStepped:Connect(function()
        if cursorEnabled and customCursor.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local insetY = getInsetY()
            customCursor.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y - insetY)
        end
    end)

    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.ZIndex = 10_000
    overlay.Visible = true
    overlay.Parent = screen

    local outsideToggle = Instance.new("TextButton")
    outsideToggle.Name = "OutsideToggle"
    outsideToggle.AutoButtonColor = false
    outsideToggle.BorderSizePixel = 0
    outsideToggle.Size = UDim2.new(0, 42, 0, 42)
    outsideToggle.Position = UDim2.new(1, -54, 0, 12)
    outsideToggle.BackgroundColor3 = Theme.Top
    outsideToggle.Text = ""
    outsideToggle.ZIndex = 10_200
    outsideToggle.Parent = overlay
    applyCorner(outsideToggle, 10)
    applyStroke(outsideToggle, Theme.StrokeSoft, 0.6)

    local outsideText = Instance.new("TextLabel")
    outsideText.Name = "OutsideText"
    outsideText.BackgroundTransparency = 1
    outsideText.Size = UDim2.new(1, 0, 1, 0)
    outsideText.Position = UDim2.new(0, 0, 0, 0)
    outsideText.Text = tostring(brandText)
    outsideText.TextColor3 = Theme.Accent
    outsideText.TextSize = 16
    outsideText.Font = Enum.Font.GothamBold
    outsideText.ZIndex = 10_210
    outsideText.Parent = outsideToggle

    local outsideImg = Instance.new("ImageLabel")
    outsideImg.Name = "OutsideImage"
    outsideImg.BackgroundTransparency = 1
    outsideImg.Size = UDim2.new(0, 18, 0, 18)
    outsideImg.Position = UDim2.new(0.5, -9, 0.5, -9)
    outsideImg.Image = brandImage or ""
    outsideImg.ImageColor3 = Theme.Accent
    outsideImg.Visible = brandImage ~= nil and brandImage ~= ""
    outsideImg.ZIndex = 10_210
    outsideImg.Parent = outsideToggle

    if outsideImg.Visible then
        outsideText.Visible = false
    end

    local isMobileToggle = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    outsideToggle.Visible = isMobileToggle
    if isMobileToggle then
        outsideToggle.Size = UDim2.new(0, 84, 0, 34)
        outsideToggle.Position = UDim2.new(1, -96, 0, 12)
        outsideImg.Visible = false
        outsideText.Visible = true
        outsideText.Text = "Close"
        outsideText.TextColor3 = Theme.Text
        outsideText.TextSize = 12
    end

    local main = Instance.new("Frame")
    main.Name = "Main"

    local startW, startH = computeWindowSize()
    main.Size = UDim2.new(0, startW, 0, startH)
    main.Position = UDim2.new(0.5, -startW / 2, 0.5, -startH / 2)
    main.BackgroundColor3 = Theme.Bg
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = screen
    applyCorner(main, 10)
    applyStroke(main, Theme.Stroke, 0.6)

    local top = Instance.new("Frame")
    top.Name = "TopBar"
    top.Size = UDim2.new(1, 0, 0, 52)
    top.BackgroundColor3 = Theme.Top
    top.BorderSizePixel = 0
    top.Parent = main
    applyCorner(top, 10)

    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 14)
    topFix.Position = UDim2.new(0, 0, 1, -14)
    topFix.BackgroundColor3 = Theme.Top
    topFix.BorderSizePixel = 0
    topFix.Parent = top

    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(1, 0, 0, 1)
    topLine.Position = UDim2.new(0, 0, 1, 0)
    topLine.BackgroundColor3 = Theme.StrokeSoft
    topLine.BackgroundTransparency = 0.6
    topLine.BorderSizePixel = 0
    topLine.Parent = top

    local brandWrap = Instance.new("Frame")
    brandWrap.BackgroundTransparency = 1
    brandWrap.BorderSizePixel = 0
    brandWrap.Size = UDim2.new(0, 40, 1, 0)
    brandWrap.Position = UDim2.new(0, 14, 0, 0)
    brandWrap.Parent = top

    local brand = Instance.new("TextLabel")
    brand.Name = "BrandText"
    brand.BackgroundTransparency = 1
    brand.Size = UDim2.new(1, 0, 1, 0)
    brand.Position = UDim2.new(0, 0, 0, 0)
    brand.Text = tostring(brandText)
    brand.TextColor3 = Theme.Accent
    brand.TextSize = 16
    brand.Font = Enum.Font.GothamBold
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.Parent = brandWrap

    local brandImg = Instance.new("ImageLabel")
    brandImg.Name = "BrandImage"
    brandImg.BackgroundTransparency = 1
    brandImg.Size = UDim2.new(0, 18, 0, 18)
    brandImg.Position = UDim2.new(0, 0, 0.5, -9)
    brandImg.Image = brandImage or ""
    brandImg.ImageColor3 = Theme.Accent
    brandImg.Visible = brandImage ~= nil and brandImage ~= ""
    brandImg.Parent = brandWrap

    if brandImg.Visible then
        brand.Visible = false
    end

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0, 260, 0, 18)
    title.Position = UDim2.new(0, 52, 0, 14)
    title.Text = titleText
    title.TextColor3 = Theme.Text
    title.TextSize = 15
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(0, 260, 0, 16)
    subtitle.Position = UDim2.new(0, 52, 0, 30)
    subtitle.Text = "| " .. footerText
    subtitle.TextColor3 = Theme.SubText
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = top

    local controls = Instance.new("Frame")
    controls.BackgroundTransparency = 1
    controls.Size = UDim2.new(0, 66, 0, 16)
    controls.Position = UDim2.new(1, -80, 0, 18)
    controls.Parent = top

    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    controlsLayout.Padding = UDim.new(0, 6)
    controlsLayout.Parent = controls

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Text = ""
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Size = UDim2.new(0, 14, 0, 14)
    minimizeBtn.BackgroundColor3 = OldButtonTheme.Neutral
    minimizeBtn.LayoutOrder = 1
    minimizeBtn.Parent = controls
    pcall(function() minimizeBtn.MouseIcon = "rbxasset://SystemCursors/PointingHand" end)
    applyCorner(minimizeBtn, 12)

    local fullscreenBtn = Instance.new("TextButton")
    fullscreenBtn.Name = "Fullscreen"
    fullscreenBtn.AutoButtonColor = false
    fullscreenBtn.Text = ""
    fullscreenBtn.BorderSizePixel = 0
    fullscreenBtn.Size = UDim2.new(0, 14, 0, 14)
    fullscreenBtn.BackgroundColor3 = OldButtonTheme.Neutral
    fullscreenBtn.LayoutOrder = 2
    fullscreenBtn.Parent = controls
    pcall(function() fullscreenBtn.MouseIcon = "rbxasset://SystemCursors/PointingHand" end)
    applyCorner(fullscreenBtn, 12)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.AutoButtonColor = false
    closeBtn.Text = ""
    closeBtn.BorderSizePixel = 0
    closeBtn.Size = UDim2.new(0, 14, 0, 14)
    closeBtn.BackgroundColor3 = OldButtonTheme.Neutral
    closeBtn.LayoutOrder = 3
    closeBtn.Parent = controls
    pcall(function() closeBtn.MouseIcon = "rbxasset://SystemCursors/PointingHand" end)
    applyCorner(closeBtn, 12)

    makeDraggable(main, top)

    
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.BackgroundColor3 = Theme.Accent
    resizeHandle.BackgroundTransparency = 0.7
    resizeHandle.BorderSizePixel = 0
    resizeHandle.Size = UDim2.new(0, 80, 0, 8)
    resizeHandle.Position = UDim2.new(0.5, -40, 1, -8)
    resizeHandle.ZIndex = 100
    resizeHandle.Parent = main
    applyCorner(resizeHandle, 4)

    
    local resizeIndicator = Instance.new("Frame")
    resizeIndicator.Name = "ResizeIndicator"
    resizeIndicator.BackgroundColor3 = Theme.White
    resizeIndicator.BackgroundTransparency = 0.8
    resizeIndicator.BorderSizePixel = 0
    resizeIndicator.Size = UDim2.new(0, 20, 0, 3)
    resizeIndicator.Position = UDim2.new(0.5, -10, 0.5, -1.5)
    resizeIndicator.Parent = resizeHandle
    applyCorner(resizeIndicator, 2)

    
    local resizeBtn = Instance.new("TextButton")
    resizeBtn.Name = "ResizeButton"
    resizeBtn.BackgroundTransparency = 1
    resizeBtn.Text = ""
    resizeBtn.Size = UDim2.new(1, 0, 1, 0)
    resizeBtn.Parent = resizeHandle
    pcall(function() resizeBtn.MouseIcon = "rbxasset://SystemCursors/SizeNS" end)

    
    local resizing = false
    local resizeStartPos
    local resizeStartSize
    local resizeDragInput

    resizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeDragInput = input
            resizeStartPos = input.Position
            resizeStartSize = main.Size
            tween(resizeHandle, { BackgroundTransparency = 0.3 }, 0.12)
        end
    end)

    resizeBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if input == resizeDragInput or resizing then
                resizing = false
                resizeDragInput = nil
                tween(resizeHandle, { BackgroundTransparency = 0.7 }, 0.12)
            end
        end
    end)

    local lastTween = nil
    local lastTweenTime = 0
    UserInputService.InputChanged:Connect(function(input)
        if not resizing or not resizeDragInput then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local curPos = input.Position
            local delta = curPos.Y - resizeStartPos.Y

            local viewport = (Camera and Camera.ViewportSize) or Vector2.new(1280, 720)
            local insetY = getInsetY()
            local maxHeight = math.floor((viewport.Y - insetY) * 0.95)

            local newHeight = clamp(resizeStartSize.Y.Offset + delta, 320, maxHeight)
            local newWidth = resizeStartSize.X.Offset

            local now = tick()
            if now - lastTweenTime >= 0.03 then
                lastTweenTime = now
                pcall(function()
                    if lastTween then
                    end
                    local props = {
                        Size = UDim2.new(0, newWidth, 0, newHeight),
                        Position = UDim2.new(0.5, -newWidth / 2, 0.5, -newHeight / 2),
                    }
                    lastTween = tween(main, props, 0.08)
                end)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if input == resizeDragInput or resizing then
                resizing = false
                resizeDragInput = nil
                tween(resizeHandle, { BackgroundTransparency = 0.7 }, 0.12)
            end
        end
    end)

    resizeBtn.MouseEnter:Connect(function()
        if not resizing then
            tween(resizeHandle, { BackgroundTransparency = 0.4 }, 0.12)
        end
    end)

    resizeBtn.MouseLeave:Connect(function()
        if not resizing then
            tween(resizeHandle, { BackgroundTransparency = 0.7 }, 0.12)
        end
    end)

    local minimized = false
    local fullscreen = false
    local restoreSize = main.Size
    local restorePos = main.Position
    local function centerTo(w, h)
        main.Size = UDim2.new(0, w, 0, h)
        main.Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2)
    end

    local function minimizeToggle()
        minimized = not minimized
        local w = main.Size.X.Offset
        local h = main.Size.Y.Offset
        if minimized then
            tween(main, { Position = UDim2.new(0.5, -w / 2, 1.5, 0) }, 0.22)
        else
            tween(main, { Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2) }, 0.22)
        end
    end

    local function fullscreenToggle()
        if minimized then
            minimizeToggle()
        end

        fullscreen = not fullscreen
        if fullscreen then
            restoreSize = main.Size
            restorePos = main.Position

            local viewport = (Camera and Camera.ViewportSize) or Vector2.new(1280, 720)
            local insetY = getInsetY()
            local w = math.max(580, math.floor(viewport.X - 40))
            local h = math.max(360, math.floor((viewport.Y - insetY) - 40))
            tween(main, {
                Size = UDim2.new(0, w, 0, h),
                Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2),
            }, 0.22)
        else
            tween(main, { Size = restoreSize, Position = restorePos }, 0.22)
        end
    end

    minimizeBtn.MouseButton1Click:Connect(minimizeToggle)
    fullscreenBtn.MouseButton1Click:Connect(fullscreenToggle)
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
    end)

    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, { BackgroundColor3 = OldButtonTheme.NeutralHover }, 0.12)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, { BackgroundColor3 = OldButtonTheme.Neutral }, 0.12)
    end)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, { BackgroundColor3 = OldButtonTheme.CloseHover }, 0.12)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, { BackgroundColor3 = OldButtonTheme.Neutral }, 0.12)
    end)

    fullscreenBtn.MouseEnter:Connect(function()
        tween(fullscreenBtn, { BackgroundColor3 = OldButtonTheme.NeutralHover }, 0.12)
    end)
    fullscreenBtn.MouseLeave:Connect(function()
        tween(fullscreenBtn, { BackgroundColor3 = OldButtonTheme.Neutral }, 0.12)
    end)

    local function isPhone()
        return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end

    if Camera and (not forcedSize or isPhone()) then
        Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if minimized then
                return
            end
            local w, h = computeWindowSize()
            tween(main, {
                Size = UDim2.new(0, w, 0, h),
                Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2),
            }, 0.22)
        end)
    end

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 176, 1, -52)
    sidebar.Position = UDim2.new(0, 0, 0, 52)
    sidebar.BackgroundColor3 = Theme.Side
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    applyStroke(sidebar, Theme.StrokeSoft, 0.7)

    local nav = Instance.new("ScrollingFrame")
    nav.Name = "Nav"
    nav.BackgroundTransparency = 1
    nav.BorderSizePixel = 0
    nav.Size = UDim2.new(1, 0, 1, -72)
    nav.Position = UDim2.new(0, 0, 0, 0)
    nav.ScrollBarThickness = 0
    nav.CanvasSize = UDim2.new(0, 0, 0, 0)
    nav.Parent = sidebar

    local navPad = Instance.new("UIPadding")
    navPad.PaddingTop = UDim.new(0, 10)
    navPad.PaddingLeft = UDim.new(0, 10)
    navPad.PaddingRight = UDim.new(0, 10)
    navPad.Parent = nav

    local navLayout = Instance.new("UIListLayout")
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 6)
    navLayout.Parent = nav

    navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        nav.CanvasSize = UDim2.new(0, 0, 0, navLayout.AbsoluteContentSize.Y + 14)
    end)

    local profile = Instance.new("Frame")
    profile.Name = "Profile"
    profile.Size = UDim2.new(1, 0, 0, 72)
    profile.Position = UDim2.new(0, 0, 1, -72)
    profile.BackgroundColor3 = Theme.Card
    profile.BorderSizePixel = 0
    profile.Parent = sidebar
    applyStroke(profile, Theme.StrokeSoft, 0.7)

    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 34, 0, 34)
    avatar.Position = UDim2.new(0, 12, 0, 19)
    avatar.BackgroundColor3 = Theme.Card2
    avatar.BorderSizePixel = 0
    avatar.Parent = profile
    applyCorner(avatar, 17)
    applyStroke(avatar, Theme.StrokeSoft, 0.65)

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "AvatarImage"
    avatarImg.BackgroundTransparency = 1
    avatarImg.BorderSizePixel = 0
    avatarImg.Size = UDim2.new(1, 0, 1, 0)
    avatarImg.Position = UDim2.new(0, 0, 0, 0)
    avatarImg.Image = ""
    avatarImg.ScaleType = Enum.ScaleType.Crop
    avatarImg.Parent = avatar
    applyCorner(avatarImg, 17)

    task.spawn(function()
        if LocalPlayer and LocalPlayer.UserId then
            local ok, content = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and content and avatarImg and avatarImg.Parent then
                avatarImg.Image = content
            end
        end
    end)

    local displayName = createText(profile, truncateWithStars((LocalPlayer and LocalPlayer.DisplayName) or "User", 18), 10, true, Theme.Text)
    displayName.Size = UDim2.new(1, -60, 0, 16)
    displayName.Position = UDim2.new(0, 54, 0, 22)

    local username = createText(profile, truncateWithStars((LocalPlayer and ("@" .. LocalPlayer.Name)) or "@user", 20), 9, false, Theme.SubText)
    username.Size = UDim2.new(1, -60, 0, 14)
    username.Position = UDim2.new(0, 54, 0, 38)

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Size = UDim2.new(1, -176, 1, -52)
    content.Position = UDim2.new(0, 176, 0, 52)
    content.Parent = main

    local tabRoot = Instance.new("Frame")
    tabRoot.Name = "TabRoot"
    tabRoot.BackgroundTransparency = 1
    tabRoot.Size = UDim2.new(1, 0, 1, 0)
    tabRoot.Parent = content

    main.MouseEnter:Connect(function()
        cursorEnabled = true
        customCursor.Visible = true
        pcall(function() UserInputService.MouseIconEnabled = false end)
    end)

    main.MouseLeave:Connect(function()
        cursorEnabled = false
        customCursor.Visible = false
        pcall(function() UserInputService.MouseIconEnabled = true end)
    end)

    local window = {}
    window._screen = screen
    window._main = main
    window._nav = nav
    window._tabs = {}
    window._tabOrder = 0
    window._currentTab = nil
    window._currentGroup = nil
    window._overlay = overlay
    window._titleLabel = title
    window._subtitleLabel = subtitle
    window._brandTextLabel = brand
    window._brandImageLabel = brandImg
    window._enableGroups = enableGroups
    window._keybindListening = false
    window._toggleKey = defaultToggleKey
    window._customCursor = customCursor
    window._cursorEnabled = function() return cursorEnabled end

    local function computeSidebarWidth(w)
        local isPhone = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        if isPhone then
            if w < 680 then
                return 110
            end
            if w < 760 then
                return 120
            end
        elseif UserInputService.TouchEnabled then
            if w < 680 then
                return 150
            end
            if w < 760 then
                return 160
            end
        end
        return 176
    end

    local function applySubLayout()
        local w = main.Size.X.Offset
        local sidebarW = computeSidebarWidth(w)
        sidebar.Size = UDim2.new(0, sidebarW, 1, -52)
        content.Size = UDim2.new(1, -sidebarW, 1, -52)
        content.Position = UDim2.new(0, sidebarW, 0, 52)

        for _, t in ipairs(window._tabs) do
            if t._applyColumns then
                t._applyColumns(w)
            end
        end
    end

    applySubLayout()
    main:GetPropertyChangedSignal("Size"):Connect(function()
        if minimized then
            return
        end
        applySubLayout()
    end)

    function window:AddGroup(name)
        if not window._enableGroups then
            window._currentGroup = name
            return nil
        end
        local header = Instance.new("TextLabel")
        header.BackgroundTransparency = 1
        header.Size = UDim2.new(1, 0, 0, 16)
        header.Text = name
        header.TextColor3 = Theme.SubText
        header.TextSize = 11
        header.Font = Enum.Font.Gotham
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = nav
        window._currentGroup = name
        return header
    end

    local function setTabActive(tab, active)
        if not tab or not tab._button then
            return
        end
        if active then
            tab._content.Visible = true
            tween(tab._button, { BackgroundColor3 = Theme.Card2 }, 0.12)
            tab._label.TextColor3 = Theme.Text
            tab._indicator.BackgroundTransparency = 0
            tab._iconTint.ImageColor3 = Theme.Accent
        else
            tab._content.Visible = false
            tween(tab._button, { BackgroundColor3 = Theme.Side }, 0.12)
            tab._label.TextColor3 = Theme.SubText
            tab._indicator.BackgroundTransparency = 1
            tab._iconTint.ImageColor3 = Theme.SubText
        end
    end

    function window:CreateTab(tabOptions)
        local name
        local icon
        local group
        local customOrder

        if type(tabOptions) == "string" then
            name = tabOptions
            icon = nil
            group = window._currentGroup
            customOrder = nil
        elseif type(tabOptions) == "table" then
            name = tabOptions.Name or "Tab"
            icon = tabOptions.Icon
            group = tabOptions.Group or window._currentGroup
            customOrder = tabOptions.LayoutOrder
        else
            name = "Tab"
            group = window._currentGroup
            customOrder = nil
        end

        local tab = {}
        tab.Name = name
        tab.Group = group

        window._tabOrder += 1

        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Theme.Side

        btn.LayoutOrder = customOrder or window._tabOrder
        btn.Parent = nav
        pcall(function() btn.MouseIcon = "rbxasset://SystemCursors/PointingHand" end)
        applyCorner(btn, 8)

        local indicator = Instance.new("Frame")
        indicator.BorderSizePixel = 0
        indicator.BackgroundColor3 = Theme.Accent
        indicator.BackgroundTransparency = 1
        indicator.Size = UDim2.new(0, 3, 0, 18)
        indicator.Position = UDim2.new(0, 6, 0.5, -9)
        indicator.Parent = btn
        applyCorner(indicator, 2)

        local iconImg = Instance.new("ImageLabel")
        iconImg.Name = "Icon"
        iconImg.BackgroundTransparency = 1
        iconImg.Size = UDim2.new(0, 16, 0, 16)
        iconImg.Position = UDim2.new(0, 18, 0.5, -8)
        iconImg.Image = icon or "rbxassetid://0"
        iconImg.ImageColor3 = Theme.SubText
        iconImg.Parent = btn

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -52, 1, 0)
        label.Position = UDim2.new(0, 42, 0, 0)
        label.Text = tostring(name)
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.TextColor3 = Theme.SubText
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = btn

        local tabContent = Instance.new("Frame")
        tabContent.Name = name .. "Content"
        tabContent.BackgroundTransparency = 1
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Visible = false
        tabContent.Parent = tabRoot

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 12)
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.PaddingBottom = UDim.new(0, 12)
        pad.Parent = tabContent

        local leftCol = Instance.new("ScrollingFrame")
        leftCol.Name = "Left"
        leftCol.BackgroundTransparency = 1
        leftCol.BorderSizePixel = 0
        leftCol.ScrollBarThickness = 0
        leftCol.Size = UDim2.new(0.5, -8, 1, 0)
        leftCol.Position = UDim2.new(0, 0, 0, 0)
        leftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        leftCol.Parent = tabContent

        local leftPad = Instance.new("UIPadding")
        leftPad.PaddingBottom = UDim.new(0, 12)
        leftPad.Parent = leftCol

        local rightCol = Instance.new("ScrollingFrame")
        rightCol.Name = "Right"
        rightCol.BackgroundTransparency = 1
        rightCol.BorderSizePixel = 0
        rightCol.ScrollBarThickness = 0
        rightCol.Size = UDim2.new(0.5, -8, 1, 0)
        rightCol.Position = UDim2.new(0.5, 16, 0, 0)
        rightCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        rightCol.Parent = tabContent

        local rightPad = Instance.new("UIPadding")
        rightPad.PaddingBottom = UDim.new(0, 12)
        rightPad.Parent = rightCol

        local function attachLayout(sf)
            local layout = Instance.new("UIListLayout")
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 10)
            layout.Parent = sf
            
            local function updateCanvasSize()
                task.wait()
                pcall(function()
                    if layout and layout.Parent and sf and sf.Parent then
                        local contentHeight = math.max(0, layout.AbsoluteContentSize.Y)
                        sf.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 12)
                    end
                end)
            end
            
            pcall(function()
                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
            end)

            pcall(function()
                sf.ChildAdded:Connect(updateCanvasSize)
                sf.ChildRemoved:Connect(updateCanvasSize)
            end)

            task.defer(updateCanvasSize)
            return layout
        end

        attachLayout(leftCol)
        attachLayout(rightCol)

        local function applyColumnsForWidth(w)
            local isPhone = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

            if isPhone then

                leftCol.Size = UDim2.new(0.5, -6, 1, 0)
                leftCol.Position = UDim2.new(0, 0, 0, 0)

                rightCol.Size = UDim2.new(0.5, -6, 1, 0)
                rightCol.Position = UDim2.new(0.5, 6, 0, 0)
                return
            end

            if w < 720 then
                leftCol.Size = UDim2.new(1, 0, 0.52, -6)
                leftCol.Position = UDim2.new(0, 0, 0, 0)

                rightCol.Size = UDim2.new(1, 0, 0.48, -6)
                rightCol.Position = UDim2.new(0, 0, 0.52, 12)
            else
                leftCol.Size = UDim2.new(0.5, -8, 1, 0)
                leftCol.Position = UDim2.new(0, 0, 0, 0)

                rightCol.Size = UDim2.new(0.5, -8, 1, 0)
                rightCol.Position = UDim2.new(0.5, 16, 0, 0)
            end
        end

        applyColumnsForWidth(main.Size.X.Offset)

        btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(window._tabs) do
                setTabActive(t, false)
            end
            setTabActive(tab, true)
            window._currentTab = tab
        end)

        btn.MouseEnter:Connect(function()
            if window._currentTab ~= tab then
                tween(btn, { BackgroundColor3 = Theme.Card }, 0.12)
            end
        end)

        btn.MouseLeave:Connect(function()
            if window._currentTab ~= tab then
                tween(btn, { BackgroundColor3 = Theme.Side }, 0.12)
            end
        end)

        tab._button = btn
        tab._indicator = indicator
        tab._label = label
        tab._iconTint = iconImg
        tab._content = tabContent
        tab._left = leftCol
        tab._right = rightCol
        tab._applyColumns = applyColumnsForWidth

        local function makePanel(column, panelOptions)
            panelOptions = panelOptions or {}
            local pTitle = panelOptions.Title or "Panel"
            local pIcon = panelOptions.Icon
            local target = (column == "Right") and rightCol or leftCol

            local cardInset = 6

            local card = Instance.new("Frame")
            card.BackgroundColor3 = Theme.Card
            card.BorderSizePixel = 0
            card.Size = UDim2.new(1, -(cardInset * 2), 0, 100)
            card.Position = UDim2.new(0, cardInset, 0, 0)
            card.Parent = target
            do
                local maxOrder = 0
                for _, ch in ipairs(target:GetChildren()) do
                    if type(ch.LayoutOrder) == "number" then
                        maxOrder = math.max(maxOrder, ch.LayoutOrder)
                    end
                end
                card.LayoutOrder = maxOrder + 1
            end
            applyCorner(card, 10)
            applyStroke(card, Theme.StrokeSoft, 0.55)

            local cardPad = Instance.new("UIPadding")
            cardPad.PaddingTop = UDim.new(0, 10)
            cardPad.PaddingLeft = UDim.new(0, 10)
            cardPad.PaddingRight = UDim.new(0, 10)
            cardPad.PaddingBottom = UDim.new(0, 10)
            cardPad.Parent = card

            local cardLayout = Instance.new("UIListLayout")
            cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
            cardLayout.Padding = UDim.new(0, 8)
            cardLayout.Parent = card

            local headerRow = createRow(card, 22)
            headerRow.LayoutOrder = 1
            local headerIcon = Instance.new("ImageLabel")
            headerIcon.BackgroundTransparency = 1
            headerIcon.Size = UDim2.new(0, 16, 0, 16)
            headerIcon.Position = UDim2.new(0, 0, 0.5, -8)
            headerIcon.Image = pIcon or "rbxassetid://0"
            headerIcon.ImageColor3 = Theme.SubText
            headerIcon.Parent = headerRow

            local headerText = createText(headerRow, truncateWithStars(pTitle, 28), 13, true, Theme.Text)
            headerText.Size = UDim2.new(1, -22, 1, 0)
            headerText.Position = UDim2.new(0, 22, 0, 0)

            local body = Instance.new("Frame")
            body.BackgroundTransparency = 1
            body.BorderSizePixel = 0
            body.Size = UDim2.new(1, 0, 0, 0)
            body.LayoutOrder = 2
            body.Parent = card

            local bodyLayout = Instance.new("UIListLayout")
            bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
            bodyLayout.Padding = UDim.new(0, 8)
            bodyLayout.Parent = body

            local function updateCardSize()
                task.wait()
                pcall(function()
                    if cardLayout and cardLayout.Parent and card and card.Parent then
                        local fullHeight = math.max(0, cardLayout.AbsoluteContentSize.Y)
                        card.Size = UDim2.new(1, -(cardInset * 2), 0, fullHeight)
                    end
                    if bodyLayout and bodyLayout.Parent and body and body.Parent then
                        local contentHeight = math.max(0, bodyLayout.AbsoluteContentSize.Y)
                        body.Size = UDim2.new(1, 0, 0, contentHeight)
                    end
                end)
            end

            pcall(function()
                cardLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCardSize)
                bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCardSize)
            end)

            
            pcall(function()
                body.ChildAdded:Connect(updateCardSize)
                body.ChildRemoved:Connect(updateCardSize)
                card.ChildAdded:Connect(updateCardSize)
                card.ChildRemoved:Connect(updateCardSize)
            end)

            task.defer(updateCardSize)

            local panel = {}
            panel.Frame = card
            panel._layoutOrder = 0

            function panel:Divider()
                panel._layoutOrder = panel._layoutOrder + 1
                local dWrap = createRow(body, 6)
                dWrap.LayoutOrder = panel._layoutOrder
                createDivider(dWrap)
                return dWrap
            end

            function panel:CreateToggle(opt)
                opt = opt or {}
                panel._layoutOrder = panel._layoutOrder + 1
                local success = pcall(function()
                    local row = createRow(body, 26)
                    row.LayoutOrder = panel._layoutOrder
                    local hasIcon = opt.Icon ~= nil
                    local x = 0
                    if hasIcon then
                        local ic = Instance.new("ImageLabel")
                        ic.BackgroundTransparency = 1
                        ic.Size = UDim2.new(0, 16, 0, 16)
                        ic.Position = UDim2.new(0, 0, 0.5, -8)
                        ic.Image = opt.Icon
                        ic.ImageColor3 = Theme.SubText
                        ic.Parent = row
                        x = 22
                    end

                    local lbl = createText(row, truncateWithStars(opt.Name or "Toggle", 30), 12, false, Theme.Text)
                    lbl.Size = UDim2.new(1, -40 - x, 1, 0)
                    lbl.Position = UDim2.new(0, x, 0, 0)

                    local tWrap = Instance.new("Frame")
                    tWrap.BackgroundTransparency = 1
                    tWrap.Size = UDim2.new(0, 22, 0, 22)
                    tWrap.Position = UDim2.new(1, -22, 0.5, -11)
                    tWrap.Parent = row

                    local cb = opt.Callback or function() end
                    return createSquareToggle(tWrap, opt.Default or false, cb)
                end)
                if not success then
                    warn("Failed to create toggle:", opt.Name)
                end
            end

            function panel:CreateLabel(opt)
                if type(opt) == "string" then
                    opt = { Text = opt }
                end
                opt = opt or {}
                panel._layoutOrder = panel._layoutOrder + 1
                local row = createRow(body, opt.Height or 22)
                row.LayoutOrder = panel._layoutOrder
                local lbl = createText(row, opt.Text or "Label", opt.Size or 12, opt.Bold or false, opt.Color or Theme.SubText)
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.TextXAlignment = opt.AlignRight and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
                return lbl
            end

            function panel:CreateButton(opt)
                opt = opt or {}
                panel._layoutOrder = panel._layoutOrder + 1
                local row = createRow(body, 32)
                row.LayoutOrder = panel._layoutOrder
                local btn2 = Instance.new("TextButton")
                btn2.AutoButtonColor = false
                btn2.BorderSizePixel = 0
                btn2.BackgroundColor3 = Color3.fromRGB(50, 53, 60)
                btn2.Size = UDim2.new(1, 0, 0, 30)
                btn2.Position = UDim2.new(0, 0, 0.5, -15)
                btn2.Text = opt.Name or opt.Text or "Button"
                btn2.TextColor3 = Theme.Text
                btn2.TextSize = 11
                btn2.Font = Enum.Font.Gotham
                btn2.TextXAlignment = Enum.TextXAlignment.Left
                btn2.Parent = row
                pcall(function() btn2.MouseIcon = "rbxasset://SystemCursors/PointingHand" end)
                applyCorner(btn2, 7)
                applyStroke(btn2, Theme.Stroke, 0.5)
                
                local textPadding = Instance.new("UIPadding")
                textPadding.PaddingLeft = UDim.new(0, 12)
                textPadding.Parent = btn2
                
                btn2.MouseEnter:Connect(function()
                    tween(btn2, { BackgroundColor3 = Color3.fromRGB(60, 63, 70) }, 0.12)
                end)
                btn2.MouseLeave:Connect(function()
                    tween(btn2, { BackgroundColor3 = Color3.fromRGB(50, 53, 60) }, 0.12)
                end)
                btn2.MouseButton1Click:Connect(function()
                    pcall(opt.Callback or function() end)
                end)
                return btn2
            end

            function panel:CreateSlider(opt)
                opt = opt or {}
                local nameText = opt.Name or "Slider"
                local min = opt.Min or 0
                local max = opt.Max or 100
                local default = opt.Default or min
                local step = opt.Increment or 1
                local suffix = opt.Suffix or "%"
                local cb = opt.Callback or function() end

                panel._layoutOrder = panel._layoutOrder + 1
                local wrap = Instance.new("Frame")
                wrap.BackgroundTransparency = 1
                wrap.BorderSizePixel = 0
                wrap.Size = UDim2.new(1, 0, 0, 46)
                wrap.LayoutOrder = panel._layoutOrder
                wrap.Parent = body

                local titleRow = createRow(wrap, 18)
                local lbl = createText(titleRow, nameText, 12, false, Theme.Text)
                lbl.Size = UDim2.new(0.7, 0, 1, 0)

                local val = Instance.new("TextLabel")
                val.BackgroundTransparency = 1
                val.Size = UDim2.new(0.3, 0, 1, 0)
                val.Position = UDim2.new(0.7, 0, 0, 0)
                val.TextXAlignment = Enum.TextXAlignment.Right
                val.Text = tostring(default) .. "/" .. tostring(max) .. suffix
                val.TextColor3 = Theme.SubText
                val.TextSize = 11
                val.Font = Enum.Font.Gotham
                val.Parent = titleRow

                local track = Instance.new("Frame")
                track.BorderSizePixel = 0
                track.BackgroundColor3 = Theme.Track
                track.Size = UDim2.new(1, 0, 0, 6)
                track.Position = UDim2.new(0, 0, 0, 28)
                track.Parent = wrap
                applyCorner(track, 3)
                applyStroke(track, Theme.StrokeSoft, 0.25)

                local fill = Instance.new("Frame")
                fill.BorderSizePixel = 0
                fill.BackgroundColor3 = Theme.Accent
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.Parent = track
                applyCorner(fill, 3)

                local knob = Instance.new("Frame")
                knob.BorderSizePixel = 0
                knob.BackgroundColor3 = Theme.White
                knob.Size = UDim2.new(0, 12, 0, 12)
                knob.Position = UDim2.new(0, -6, 0.5, -6)
                knob.Parent = track
                applyCorner(knob, 6)
                applyStroke(knob, Theme.StrokeSoft, 0.35)

                local current = default
                local dragging = false
                local dragInput

                local function formatValue(v)
                    val.Text = tostring(v) .. "/" .. tostring(max) .. suffix
                end

                local function setValue(v)
                    v = clamp(v, min, max)
                    v = math.floor((v - min) / step + 0.5) * step + min
                    current = v
                    local pct = (max == min) and 0 or ((v - min) / (max - min))
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    knob.Position = UDim2.new(pct, -6, 0.5, -6)
                    formatValue(v)
                    pcall(cb, v)
                end

                setValue(default)

                local function updateFromX(x)
                    local rel = x - track.AbsolutePosition.X
                    local denom = track.AbsoluteSize.X
                    local pct = (denom <= 0) and 0 or clamp(rel / denom, 0, 1)
                    setValue(min + (max - min) * pct)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragInput = input
                        updateFromX(input.Position.X)
                    end
                end)

                track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if input == dragInput then
                            dragging = false
                            dragInput = nil
                        end
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateFromX(input.Position.X)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input == dragInput or (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        if dragging then
                            dragging = false
                            dragInput = nil
                        end
                    end
                end)

                knob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragInput = input
                        updateFromX(input.Position.X)
                    end
                end)

                knob.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if input == dragInput then
                            dragging = false
                            dragInput = nil
                        end
                    end
                end)

                return {
                    SetValue = function(_, v)
                        setValue(v)
                    end,
                    GetValue = function()
                        return current
                    end,
                }
            end

            function panel:CreateKeybind(opt)
                opt = opt or {}
                panel._layoutOrder = panel._layoutOrder + 1
                local row = createRow(body, 28)
                row.LayoutOrder = panel._layoutOrder
                local hasIcon = opt.Icon ~= nil
                local x = 0
                if hasIcon then
                    local ic = Instance.new("ImageLabel")
                    ic.BackgroundTransparency = 1
                    ic.Size = UDim2.new(0, 16, 0, 16)
                    ic.Position = UDim2.new(0, 0, 0.5, -8)
                    ic.Image = opt.Icon
                    ic.ImageColor3 = Theme.SubText
                    ic.Parent = row
                    x = 22
                end

                local lbl = createText(row, opt.Name or "Keybind", 12, false, Theme.Text)
                lbl.Size = UDim2.new(1, -130 - x, 1, 0)
                lbl.Position = UDim2.new(0, x, 0, 0)

                local keyBtn = Instance.new("TextButton")
                keyBtn.AutoButtonColor = false
                keyBtn.BorderSizePixel = 0
                keyBtn.Size = UDim2.new(0, 110, 0, 22)
                keyBtn.Position = UDim2.new(1, -110, 0.5, -11)
                keyBtn.BackgroundColor3 = Theme.ToggleOff
                keyBtn.TextColor3 = Theme.Text
                keyBtn.TextSize = 11
                keyBtn.Font = Enum.Font.Gotham
                keyBtn.Text = (opt.Default and opt.Default.Name) or "None"
                keyBtn.Parent = row
                applyCorner(keyBtn, 7)
                applyStroke(keyBtn, Theme.StrokeSoft, 0.45)

                local current = opt.Default or Enum.KeyCode.LeftControl
                local listening = false
                local cb = opt.Callback or function() end

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    window._keybindListening = true
                    keyBtn.Text = "Press key"
                    keyBtn.TextColor3 = Theme.Accent
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if not listening then
                        return
                    end

                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Backspace then
                            current = nil
                            keyBtn.Text = "None"
                        else
                            current = input.KeyCode
                            keyBtn.Text = current.Name
                        end
                        keyBtn.TextColor3 = Theme.Text
                        listening = false
                        window._keybindListening = false
                        pcall(cb, current)
                        return
                    end

                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                        current = input.UserInputType
                        keyBtn.Text = (current == Enum.UserInputType.MouseButton1 and "Mouse1") or "Mouse2"
                        keyBtn.TextColor3 = Theme.Text
                        listening = false
                        window._keybindListening = false
                        pcall(cb, current)
                        return
                    end
                end)

                return {
                    SetValue = function(_, v)
                        current = v
                        if typeof(current) == "EnumItem" then
                            keyBtn.Text = current.Name
                        elseif current == Enum.UserInputType.MouseButton1 then
                            keyBtn.Text = "Mouse1"
                        elseif current == Enum.UserInputType.MouseButton2 then
                            keyBtn.Text = "Mouse2"
                        else
                            keyBtn.Text = "None"
                        end
                    end,
                    GetValue = function()
                        return current
                    end,
                }
            end

            function panel:CreateDropdown(opt)
                opt = opt or {}
                local list = opt.List or {}
                local current = opt.Default or list[1] or "None"
                local cb = opt.Callback or function() end
                local labelText = opt.Label

                panel._layoutOrder = panel._layoutOrder + 1
                local wrap = Instance.new("Frame")
                wrap.BackgroundTransparency = 1
                wrap.BorderSizePixel = 0
                wrap.Size = UDim2.new(1, 0, 0, (labelText and labelText ~= "") and 52 or 34)
                wrap.LayoutOrder = panel._layoutOrder
                wrap.Parent = body

                if labelText and labelText ~= "" then
                    local lbl = createText(wrap, labelText, 12, false, Theme.Text)
                    lbl.Size = UDim2.new(1, 0, 0, 16)
                    lbl.Position = UDim2.new(0, 0, 0, 0)
                end

                local field = Instance.new("TextButton")
                field.AutoButtonColor = false
                field.BorderSizePixel = 0
                field.BackgroundColor3 = Theme.Card2
                field.Size = UDim2.new(1, 0, 0, 30)
                field.Position = UDim2.new(0, 0, 0, (labelText and labelText ~= "") and 20 or 2)
                field.Text = ""
                field.Parent = wrap
                applyCorner(field, 7)
                local fieldStroke = applyStroke(field, Theme.StrokeSoft, 0.25)

                local valueLabel = Instance.new("TextLabel")
                valueLabel.BackgroundTransparency = 1
                valueLabel.BorderSizePixel = 0
                valueLabel.Size = UDim2.new(1, -30, 1, 0)
                valueLabel.Position = UDim2.new(0, 12, 0, 0)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                valueLabel.TextYAlignment = Enum.TextYAlignment.Center
                valueLabel.Text = truncateWithStars(tostring(current), 26)
                valueLabel.TextColor3 = Theme.Text
                valueLabel.TextSize = 11
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.Parent = field

                local arrows = Instance.new("Frame")
                arrows.BackgroundTransparency = 1
                arrows.BorderSizePixel = 0
                arrows.Size = UDim2.new(0, 16, 0, 18)
                arrows.Position = UDim2.new(1, -22, 0.5, -9)
                arrows.Parent = field
                arrows.ZIndex = field.ZIndex + 1

                local arrowUp = Instance.new("TextLabel")
                arrowUp.BackgroundTransparency = 1
                arrowUp.Size = UDim2.new(1, 0, 0.5, 0)
                arrowUp.Position = UDim2.new(0, 0, 0, -1)
                arrowUp.Text = "˄"
                arrowUp.TextColor3 = Theme.SubText
                arrowUp.TextSize = 12
                arrowUp.Font = Enum.Font.Gotham
                arrowUp.TextXAlignment = Enum.TextXAlignment.Center
                arrowUp.TextYAlignment = Enum.TextYAlignment.Center
                arrowUp.Parent = arrows

                local arrowDown = Instance.new("TextLabel")
                arrowDown.BackgroundTransparency = 1
                arrowDown.Size = UDim2.new(1, 0, 0.5, 0)
                arrowDown.Position = UDim2.new(0, 0, 0.5, -1)
                arrowDown.Text = "˅"
                arrowDown.TextColor3 = Theme.SubText
                arrowDown.TextSize = 12
                arrowDown.Font = Enum.Font.Gotham
                arrowDown.TextXAlignment = Enum.TextXAlignment.Center
                arrowDown.TextYAlignment = Enum.TextYAlignment.Center
                arrowDown.Parent = arrows

                local catcher = Instance.new("TextButton")
                catcher.Name = "DropdownCatcher"
                catcher.AutoButtonColor = false
                catcher.Text = ""
                catcher.BackgroundTransparency = 1
                catcher.BorderSizePixel = 0
                catcher.Size = UDim2.new(1, 0, 1, 0)
                catcher.Position = UDim2.new(0, 0, 0, 0)
                catcher.Visible = false
                catcher.ZIndex = 10_005
                catcher.Parent = window._overlay

                local drop = Instance.new("ScrollingFrame")
                drop.Name = "DropdownList"
                drop.Visible = false
                drop.BorderSizePixel = 0
                drop.BackgroundColor3 = Theme.ToggleOff
                drop.ClipsDescendants = true
                drop.Size = UDim2.new(0, 0, 0, 0)
                drop.Position = UDim2.new(0, 0, 0, 0)
                drop.ZIndex = 10_010
                drop.ScrollBarThickness = 4
                drop.ScrollBarImageColor3 = Theme.Accent
                drop.ScrollBarImageTransparency = 0.5
                drop.CanvasSize = UDim2.new(0, 0, 0, 0)
                drop.Parent = window._overlay
                applyCorner(drop, 7)
                local dropStroke = applyStroke(drop, Theme.StrokeSoft, 0.25)

                local listLayout = Instance.new("UIListLayout")
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Padding = UDim.new(0, 2)
                listLayout.Parent = drop

                local listPad = Instance.new("UIPadding")
                listPad.PaddingTop = UDim.new(0, 6)
                listPad.PaddingBottom = UDim.new(0, 6)
                listPad.PaddingLeft = UDim.new(0, 4)
                listPad.PaddingRight = UDim.new(0, 4)
                listPad.Parent = drop

                listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    drop.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
                end)

                local expanded = false
                local openUp = false
                local fieldHovered = false
                local dropHovered = false

                local function setStrokeHover(isHover)
                    local c = isHover and Theme.Stroke or Theme.StrokeSoft
                    tween(fieldStroke, { Color = c }, 0.12)
                    tween(dropStroke, { Color = c }, 0.12)
                end

                local function placeDrop(targetHeight)
                    local absPos = field.AbsolutePosition
                    local absSize = field.AbsoluteSize
                    local viewport = (Camera and Camera.ViewportSize) or Vector2.new(1280, 720)
                    local h = targetHeight or drop.Size.Y.Offset
                    local belowSpace = viewport.Y - (absPos.Y + absSize.Y)
                    openUp = belowSpace < (h + 18)

                    local y = absPos.Y + absSize.Y + 4
                    if openUp then
                        y = absPos.Y - h - 4
                    end

                    drop.Position = UDim2.fromOffset(absPos.X, y)
                    drop.Size = UDim2.fromOffset(absSize.X, drop.Size.Y.Offset)
                end

                local function startTracking()

                    task.spawn(function()
                        while expanded and drop.Visible and drop.Parent do
                            placeDrop(drop.Size.Y.Offset)
                            task.wait(0.05)
                        end
                    end)
                end

                local function rebuild(items)
                    for _, ch in ipairs(drop:GetChildren()) do
                        if ch:IsA("TextButton") or ch:IsA("Frame") then
                            if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then
                                ch:Destroy()
                            end
                        end
                    end
                    for i, item in ipairs(items) do
                        local optWrap = Instance.new("Frame")
                        optWrap.Name = "OptionWrapper"

                        optWrap.BackgroundColor3 = Theme.Card2
                        optWrap.BackgroundTransparency = 1
                        optWrap.BorderSizePixel = 0
                        optWrap.Size = UDim2.new(1, 0, 0, 26)
                        optWrap.LayoutOrder = i
                        optWrap.Parent = drop
                        optWrap.ZIndex = 10_015
                        applyCorner(optWrap, 6)

                        local optPad = Instance.new("UIPadding")
                        optPad.PaddingLeft = UDim.new(0, 8)
                        optPad.PaddingRight = UDim.new(0, 6)
                        optPad.Parent = optWrap

                        local it = Instance.new("TextButton")
                        it.AutoButtonColor = false
                        it.BorderSizePixel = 0
                        it.BackgroundTransparency = 1
                        it.Size = UDim2.new(1, 0, 1, 0)
                        it.Position = UDim2.new(0, 0, 0, 0)
                        it.Text = ""
                        it.ZIndex = 10_020
                        it.Parent = optWrap

                        local itemLabel = Instance.new("TextLabel")
                        itemLabel.BackgroundTransparency = 1
                        itemLabel.Size = UDim2.new(1, -18, 1, 0)
                        itemLabel.Position = UDim2.new(0, 0, 0, 0)
                        itemLabel.Text = tostring(item)
                        itemLabel.TextColor3 = (tostring(item) == tostring(current)) and Theme.Text or Theme.SubText
                        itemLabel.TextSize = 11
                        itemLabel.Font = Enum.Font.Gotham
                        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
                        itemLabel.ZIndex = 10_018
                        itemLabel.Parent = optWrap

                        local isActive = tostring(item) == tostring(current)

                        local function activate()
                            isActive = true
                            tween(optWrap, { BackgroundTransparency = 0.5 }, 0.12)
                            tween(itemLabel, { TextColor3 = Theme.Text }, 0.12)
                            tween(optPad, { PaddingLeft = UDim.new(0, 12) }, 0.12)
                        end

                        local function deactivate()
                            isActive = false
                            tween(optWrap, { BackgroundTransparency = 1 }, 0.12)
                            tween(itemLabel, { TextColor3 = Theme.SubText }, 0.12)
                            tween(optPad, { PaddingLeft = UDim.new(0, 8) }, 0.12)
                        end

                        if isActive then
                            optWrap.BackgroundTransparency = 0.5
                            itemLabel.TextColor3 = Theme.Text
                            optPad.PaddingLeft = UDim.new(0, 12)
                        end

                        it.MouseEnter:Connect(function()
                            if not isActive then
                                tween(optWrap, { BackgroundTransparency = 0.8 }, 0.12)
                                tween(itemLabel, { TextColor3 = Theme.Text }, 0.12)
                                tween(optPad, { PaddingLeft = UDim.new(0, 12) }, 0.12)
                            end
                        end)

                        it.MouseLeave:Connect(function()
                            if not isActive then
                                tween(optWrap, { BackgroundTransparency = 1 }, 0.12)
                                tween(itemLabel, { TextColor3 = Theme.SubText }, 0.12)
                                tween(optPad, { PaddingLeft = UDim.new(0, 8) }, 0.12)
                            end
                        end)

                        it.MouseButton1Click:Connect(function()
                            current = item
                            valueLabel.Text = truncateWithStars(tostring(current), 26)
                            expanded = false
                            tween(arrowUp, { TextColor3 = Theme.SubText }, 0.08)
                            tween(arrowDown, { TextColor3 = Theme.SubText }, 0.08)
                            catcher.Visible = false
                            tween(drop, { Size = UDim2.fromOffset(field.AbsoluteSize.X, 0) }, 0.14)
                            task.wait(0.14)
                            if drop and drop.Parent then
                                drop.Visible = false
                            end
                            rebuild(items)
                            pcall(cb, current)
                        end)
                    end
                end

                rebuild(list)

                field.MouseEnter:Connect(function()
                    fieldHovered = true
                    tween(field, { BackgroundColor3 = Theme.Track }, 0.12)
                    setStrokeHover(true)
                end)

                field.MouseLeave:Connect(function()
                    fieldHovered = false
                    if not expanded then
                        tween(field, { BackgroundColor3 = Theme.Card2 }, 0.12)
                        setStrokeHover(false)
                    end
                end)

                drop.MouseEnter:Connect(function()
                    dropHovered = true
                    setStrokeHover(true)
                end)

                drop.MouseLeave:Connect(function()
                    dropHovered = false
                    if not fieldHovered and not expanded then
                        setStrokeHover(false)
                    end
                end)

                field.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    if expanded then
                        drop.Visible = true
                        catcher.Visible = true
                        tween(arrowUp, { TextColor3 = Theme.Accent }, 0.12)
                        tween(arrowDown, { TextColor3 = Theme.SubText }, 0.12)
                        local h = math.min(#list * 26 + 12, 175)
                        placeDrop(h)
                        drop.ScrollBarImageTransparency = 1
                        tween(drop, { Size = UDim2.fromOffset(field.AbsoluteSize.X, h) }, 0.14)
                        task.wait(0.14)
                        drop.ScrollBarImageTransparency = 0.5
                        startTracking()
                    else
                        tween(arrowUp, { TextColor3 = Theme.SubText }, 0.12)
                        tween(arrowDown, { TextColor3 = Theme.SubText }, 0.12)
                        catcher.Visible = false
                        drop.ScrollBarImageTransparency = 1
                        tween(drop, { Size = UDim2.fromOffset(field.AbsoluteSize.X, 0) }, 0.14)
                        task.wait(0.14)
                        if drop and drop.Parent then
                            drop.Visible = false
                        end
                        if not fieldHovered then
                            tween(field, { BackgroundColor3 = Theme.Card2 }, 0.12)
                            tween(fieldStroke, { Color = Theme.StrokeSoft }, 0.12)
                        end
                    end
                end)

                catcher.MouseButton1Click:Connect(function()
                    if expanded then
                        expanded = false
                        tween(arrowUp, { TextColor3 = Theme.SubText }, 0.12)
                        tween(arrowDown, { TextColor3 = Theme.SubText }, 0.12)
                        catcher.Visible = false
                        drop.ScrollBarImageTransparency = 1
                        tween(drop, { Size = UDim2.fromOffset(field.AbsoluteSize.X, 0) }, 0.14)
                        task.wait(0.14)
                        if drop and drop.Parent then
                            drop.Visible = false
                        end
                        if not fieldHovered then
                            tween(field, { BackgroundColor3 = Theme.Card2 }, 0.12)
                            tween(fieldStroke, { Color = Theme.StrokeSoft }, 0.12)
                        end
                    end
                end)

                return {
                    SetValue = function(_, v)
                        current = v
                        valueLabel.Text = truncateWithStars(tostring(current), 26)
                        rebuild(list)
                    end,
                    UpdateList = function(_, newList)
                        list = newList or {}
                        rebuild(list)
                    end,
                    GetValue = function()
                        return current
                    end,
                }
            end

            panel.CreateButton = panel.CreateButton

            return panel
        end

        function tab:CreatePanel(panelOptions)
            return makePanel(panelOptions and panelOptions.Column or "Left", panelOptions)
        end

        function tab:CreateSection(sectionName)
            return makePanel("Left", { Title = sectionName })
        end

        table.insert(window._tabs, tab)
        if #window._tabs == 1 then
            setTabActive(tab, true)
            window._currentTab = tab
        end

        return tab
    end

    local notifyHost = Instance.new("Frame")
    notifyHost.Name = "Notifications"
    notifyHost.BackgroundTransparency = 1
    notifyHost.BorderSizePixel = 0
    notifyHost.Size = UDim2.new(0, 320, 1, -24)
    notifyHost.Position = UDim2.new(1, -332, 0, 12)
    notifyHost.ZIndex = 10_100
    notifyHost.Parent = overlay

    local notifyLayout = Instance.new("UIListLayout")
    notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notifyLayout.Padding = UDim.new(0, 8)
    notifyLayout.Parent = notifyHost

    function window:Notify(opt)
        opt = opt or {}
        local nTitle = opt.Title or titleText
        local nText = opt.Text or ""
        local duration = opt.Duration or 2.5

        local toast = Instance.new("Frame")
        toast.BackgroundColor3 = Theme.Card
        toast.BorderSizePixel = 0
        toast.Size = UDim2.new(1, 0, 0, 56)
        toast.ZIndex = 10_110
        toast.Parent = notifyHost
        applyCorner(toast, 10)
        applyStroke(toast, Theme.StrokeSoft, 0.55)

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
        pad.Parent = toast

        local t1 = createText(toast, tostring(nTitle), 12, true, Theme.Text)
        t1.Size = UDim2.new(1, 0, 0, 18)
        t1.ZIndex = 10_120

        local t2 = createText(toast, tostring(nText), 11, false, Theme.SubText)
        t2.Size = UDim2.new(1, 0, 0, 16)
        t2.Position = UDim2.new(0, 0, 0, 20)
        t2.ZIndex = 10_120

        toast.BackgroundTransparency = 1
        tween(toast, { BackgroundTransparency = 0 }, 0.14)

        task.delay(duration, function()
            if toast and toast.Parent then
                tween(toast, { BackgroundTransparency = 1 }, 0.14)
                task.wait(0.16)
                if toast and toast.Parent then
                    toast:Destroy()
                end
            end
        end)
    end

    function window:Toggle()
        if not main.Visible then
            main.Visible = true
            if minimized then
                minimized = false
            end
            local w = main.Size.X.Offset
            local h = main.Size.Y.Offset
            main.Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2)
        else
            main.Visible = false
        end
    end

    function window:SetTitle(text)
        window._titleLabel.Text = tostring(text)
    end

    function window:SetFooter(text)
        window._subtitleLabel.Text = "| " .. tostring(text)
    end

    function window:SetBrandText(text)
        window._brandTextLabel.Text = tostring(text)
        window._brandTextLabel.Visible = true
        window._brandImageLabel.Visible = false

        outsideText.Text = tostring(text)
        outsideText.Visible = true
        outsideImg.Visible = false
    end

    function window:SetBrandImage(image)
        window._brandImageLabel.Image = tostring(image or "")
        window._brandImageLabel.Visible = window._brandImageLabel.Image ~= ""
        window._brandTextLabel.Visible = not window._brandImageLabel.Visible

        outsideImg.Image = tostring(image or "")
        outsideImg.Visible = outsideImg.Image ~= ""
        outsideText.Visible = not outsideImg.Visible
    end

    function window:Destroy()
        screen:Destroy()
    end

    function window:SetToggleKey(key)
        window._toggleKey = key
    end

    do
        local settingsTab = window:CreateTab("Settings")
        local panel = settingsTab:CreatePanel({ Column = "Left", Title = "Settings" })

        panel:CreateKeybind({
            Name = "Toggle UI Key",
            Default = defaultToggleKey,
            Callback = function(key)
                if typeof(key) == "EnumItem" then
                    window:SetToggleKey(key)
                    window:Notify({ Title = titleText, Text = "Toggle key set to " .. key.Name, Duration = 1.5 })
                elseif key == nil then
                    window:SetToggleKey(nil)
                    window:Notify({ Title = titleText, Text = "Toggle key cleared", Duration = 1.5 })
                end
            end,
        })
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if window._keybindListening then
            return
        end
        local key = window._toggleKey
        if not key then
            return
        end

        if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
                window:Toggle()
            end
            return
        end

        if typeof(key) == "EnumItem" and key.EnumType == Enum.UserInputType then
            if input.UserInputType == key then
                window:Toggle()
            end
        end
    end)

    outsideToggle.MouseButton1Click:Connect(function()
        window:Toggle()
        if isMobileToggle and outsideText and outsideText.Parent then
            outsideText.Text = main.Visible and "Close" or "Open"
        end
    end)

    local function refreshAllLayouts()
        pcall(function()
            for _, tab in ipairs(window._tabs) do
                for _, sf in ipairs({ tab._left, tab._right }) do
                    if sf and sf.Parent then
                        
                        local mainLayout = sf:FindFirstChildWhichIsA("UIListLayout", true)
                        if mainLayout then
                            local height = math.max(0, mainLayout.AbsoluteContentSize.Y)
                            sf.CanvasSize = UDim2.new(0, 0, 0, height + 12)
                        end

                        for _, child in ipairs(sf:GetChildren()) do
                            if child:IsA("Frame") then
                                local cardLayout = child:FindFirstChildWhichIsA("UIListLayout")
                                if cardLayout then
                                    local fullHeight = math.max(0, cardLayout.AbsoluteContentSize.Y)
                                    
                                    child.Size = UDim2.new(1, -12, 0, fullHeight)
                                end
                                
                                for _, sub in ipairs(child:GetChildren()) do
                                    if sub:IsA("Frame") and sub:FindFirstChildWhichIsA("UIListLayout") then
                                        local bLayout = sub:FindFirstChildWhichIsA("UIListLayout")
                                        if bLayout then
                                            sub.Size = UDim2.new(1, 0, 0, math.max(0, bLayout.AbsoluteContentSize.Y))
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    task.spawn(function()
        while not destroyed and main and main.Parent do
            refreshAllLayouts()
            task.wait(1)
        end
    end)

    return window
end

function Buster:CreateHomeTab(window, options)
    options = options or {}

    local tabName = options.Name or "Home"
    local tabIcon = options.Icon
    local homeTab = window:CreateTab({ Name = tabName, Icon = tabIcon })

    local RunService = game:GetService("RunService")
    local StatsService = game:GetService("Stats")
    local MarketplaceService = game:GetService("MarketplaceService")
    local LocalizationService = game:GetService("LocalizationService")

    local discordInvite = options.DiscordInvite or ""
    local supportedExecutors = options.SupportedExecutors or {}
    local unsupportedExecutors = options.UnsupportedExecutors or {}
    local changelog = options.Changelog or {}

    local content = homeTab._content
    local leftCol = content and content:FindFirstChild("Left")
    local rightCol = content and content:FindFirstChild("Right")
    if not content or not leftCol or not rightCol then
        return homeTab
    end

    for _, child in ipairs(content:GetChildren()) do
        if string.sub(child.Name, 1, 4) == "Home" then
            child:Destroy()
        end
    end
    for _, sf in ipairs({ leftCol, rightCol }) do
        for _, child in ipairs(sf:GetChildren()) do
            if string.sub(child.Name, 1, 4) == "Home" then
                child:Destroy()
            end
        end
    end

    local function safeDestroyConnection(conn)
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(function()
                conn:Disconnect()
            end)
        end
    end

    local destroyed = false
    local connections = {}
    content.AncestryChanged:Connect(function(_, parent)
        if parent == nil and not destroyed then
            destroyed = true
            for _, conn in ipairs(connections) do
                safeDestroyConnection(conn)
            end
        end
    end)

    local function createCard(parent, titleText, subtitleText, iconImage, fixedHeight)
        local cardInset = 6
        local card = Instance.new("Frame")
        card.Name = "HomeCard"
        card.BackgroundColor3 = Theme.Card
        card.BorderSizePixel = 0
        card.Size = UDim2.new(1, -(cardInset * 2), 0, fixedHeight or 96)
        card.Position = UDim2.new(0, cardInset, 0, 0)
        card.Parent = parent
        applyCorner(card, 10)
        applyStroke(card, Theme.StrokeSoft, 0.55)

        local cardPad = Instance.new("UIPadding")
        cardPad.Name = "HomePad"
        cardPad.PaddingTop = UDim.new(0, 10)
        cardPad.PaddingLeft = UDim.new(0, 10)
        cardPad.PaddingRight = UDim.new(0, 10)
        cardPad.PaddingBottom = UDim.new(0, 10)
        cardPad.Parent = card

        local headerRow = Instance.new("Frame")
        headerRow.Name = "HomeHeader"
        headerRow.BackgroundTransparency = 1
        headerRow.BorderSizePixel = 0
        headerRow.Size = UDim2.new(1, 0, 0, 22)
        headerRow.Parent = card

        local icon = Instance.new("ImageLabel")
        icon.Name = "HomeIcon"
        icon.BackgroundTransparency = 1
        icon.BorderSizePixel = 0
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Position = UDim2.new(0, 0, 0.5, -8)
        icon.Image = iconImage or ""
        icon.ImageColor3 = Theme.Text
        icon.Visible = icon.Image ~= ""
        icon.Parent = headerRow

        local title = createText(headerRow, titleText or "", 13, true, Theme.Text)
        title.Name = "HomeTitle"
        title.Size = UDim2.new(1, -22, 1, 0)
        title.Position = UDim2.new(0, icon.Visible and 22 or 0, 0, 0)
        title.TextXAlignment = Enum.TextXAlignment.Left

        local subtitle = nil
        if subtitleText and subtitleText ~= "" then
            subtitle = createText(card, subtitleText, 11, false, Theme.SubText)
            subtitle.Name = "HomeSubtitle"
            subtitle.Size = UDim2.new(1, 0, 0, 16)
            subtitle.Position = UDim2.new(0, 0, 0, 26)
            subtitle.TextXAlignment = Enum.TextXAlignment.Left
        end

        local body = Instance.new("Frame")
        body.Name = "HomeBody"
        body.BackgroundTransparency = 1
        body.BorderSizePixel = 0
        body.Position = UDim2.new(0, 0, 0, subtitle and 46 or 28)
        body.Size = UDim2.new(1, 0, 1, -(subtitle and 46 or 28))
        body.Parent = card

        return card, body
    end

    local welcomeHeight = 110
    local topGap = 12
    local topOffset = welcomeHeight + topGap

    local welcome = Instance.new("Frame")
    welcome.Name = "HomeWelcome"
    welcome.BackgroundColor3 = Theme.Card
    welcome.BorderSizePixel = 0
    welcome.Size = UDim2.new(1, 0, 0, welcomeHeight)
    welcome.Position = UDim2.new(0, 0, 0, 0)
    welcome.Parent = content
    applyCorner(welcome, 12)
    applyStroke(welcome, Theme.StrokeSoft, 0.55)

    local backdrop = Instance.new("ImageLabel")
    backdrop.Name = "HomeBackdrop"
    backdrop.BackgroundTransparency = 1
    backdrop.BorderSizePixel = 0
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.ScaleType = Enum.ScaleType.Crop
    backdrop.ImageTransparency = 0.55
    backdrop.Image = ""
    backdrop.ZIndex = 1
    backdrop.Parent = welcome
    applyCorner(backdrop, 12)

    if options.Backdrop ~= nil then
        if options.Backdrop == 0 then
            backdrop.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. game.PlaceId .. "&width=768&height=432&format=png"
        else
            backdrop.Image = "rbxassetid://" .. tostring(options.Backdrop)
        end
    end

    local backdropFade = Instance.new("Frame")
    backdropFade.Name = "HomeBackdropFade"
    backdropFade.BackgroundColor3 = Theme.Card
    backdropFade.BorderSizePixel = 0
    backdropFade.BackgroundTransparency = 0.2
    backdropFade.Size = UDim2.new(1, 0, 1, 0)
    backdropFade.ZIndex = 2
    backdropFade.Parent = welcome
    applyCorner(backdropFade, 12)

    local welcomePad = Instance.new("UIPadding")
    welcomePad.Name = "HomeWelcomePad"
    welcomePad.PaddingTop = UDim.new(0, 12)
    welcomePad.PaddingLeft = UDim.new(0, 12)
    welcomePad.PaddingRight = UDim.new(0, 12)
    welcomePad.PaddingBottom = UDim.new(0, 12)
    welcomePad.Parent = welcome

    local welcomeContent = Instance.new("Frame")
    welcomeContent.Name = "HomeWelcomeContent"
    welcomeContent.BackgroundTransparency = 1
    welcomeContent.BorderSizePixel = 0
    welcomeContent.Size = UDim2.new(1, 0, 1, 0)
    welcomeContent.ZIndex = 3
    welcomeContent.Parent = welcome

    local avatarWrap = Instance.new("Frame")
    avatarWrap.Name = "HomeAvatarWrap"
    avatarWrap.BackgroundColor3 = Theme.Card2
    avatarWrap.BorderSizePixel = 0
    avatarWrap.Size = UDim2.new(0, 54, 0, 54)
    avatarWrap.Position = UDim2.new(0, 0, 0.5, -27)
    avatarWrap.ZIndex = 4
    avatarWrap.Parent = welcomeContent
    applyCorner(avatarWrap, 27)
    applyStroke(avatarWrap, Theme.StrokeSoft, 0.65)

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "HomeAvatar"
    avatarImg.BackgroundTransparency = 1
    avatarImg.BorderSizePixel = 0
    avatarImg.Size = UDim2.new(1, 0, 1, 0)
    avatarImg.ScaleType = Enum.ScaleType.Crop
    avatarImg.ZIndex = 5
    avatarImg.Parent = avatarWrap
    applyCorner(avatarImg, 27)

    task.spawn(function()
        pcall(function()
            local lp = Players.LocalPlayer
            if not (lp and lp.UserId) then
                return
            end
            local thumb = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            if avatarImg and avatarImg.Parent then
                avatarImg.Image = thumb
            end
        end)
    end)

    local welcomeTitle = createText(welcomeContent, "Welcome, " .. tostring((Players.LocalPlayer and Players.LocalPlayer.DisplayName) or "User"), 18, true, Theme.Text)
    welcomeTitle.Name = "HomeWelcomeTitle"
    welcomeTitle.Position = UDim2.new(0, 66, 0, 18)
    welcomeTitle.Size = UDim2.new(1, -220, 0, 22)
    welcomeTitle.ZIndex = 5

    local welcomeSub = createText(welcomeContent, "", 12, false, Theme.SubText)
    welcomeSub.Name = "HomeWelcomeSub"
    welcomeSub.Position = UDim2.new(0, 66, 0, 42)
    welcomeSub.Size = UDim2.new(1, -220, 0, 18)
    welcomeSub.ZIndex = 5

    local timeLabel = createText(welcomeContent, "", 12, false, Theme.SubText)
    timeLabel.Name = "HomeTime"
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Position = UDim2.new(1, -8, 0, 20)
    timeLabel.Size = UDim2.new(0, 200, 0, 18)
    timeLabel.ZIndex = 5

    local dateLabel = createText(welcomeContent, "", 12, false, Theme.SubText)
    dateLabel.Name = "HomeDate"
    dateLabel.TextXAlignment = Enum.TextXAlignment.Right
    dateLabel.Position = UDim2.new(1, -8, 0, 42)
    dateLabel.Size = UDim2.new(0, 200, 0, 18)
    dateLabel.ZIndex = 5

    local function getGreetingString(hour)
        if hour >= 4 and hour < 12 then
            return "Good Morning!"
        end
        if hour >= 12 and hour < 19 then
            return "How's Your Day Going?"
        end
        if hour >= 19 and hour <= 23 then
            return "Sweet Dreams."
        end
        return "Jeez you should be asleep..."
    end

    task.spawn(function()
        while not destroyed and welcome and welcome.Parent do
            local t = os.date("*t")
            local formattedTime = string.format("%02d : %02d : %02d", t.hour, t.min, t.sec)
            timeLabel.Text = formattedTime
            dateLabel.Text = string.format("%02d / %02d / %02d", t.day, t.month, t.year % 100)
            local lp = Players.LocalPlayer
            local lpName = (lp and lp.Name) or "User"
            welcomeSub.Text = getGreetingString(t.hour) .. " | " .. tostring(lpName)
            task.wait(1)
        end
    end)

    local function applyHomeColumns(w)
        local h = content.AbsoluteSize.Y
        local remaining = math.max(0, h - topOffset)

        if w < 720 then
            local leftH = math.max(0, math.floor(remaining * 0.52 - 6))
            local rightH = math.max(0, remaining - leftH - 12)

            leftCol.Size = UDim2.new(1, 0, 0, leftH)
            leftCol.Position = UDim2.new(0, 0, 0, topOffset)

            rightCol.Size = UDim2.new(1, 0, 0, rightH)
            rightCol.Position = UDim2.new(0, 0, 0, topOffset + leftH + 12)
        else
            leftCol.Size = UDim2.new(0.58, -8, 1, -topOffset)
            leftCol.Position = UDim2.new(0, 0, 0, topOffset)

            rightCol.Size = UDim2.new(0.42, -8, 1, -topOffset)
            rightCol.Position = UDim2.new(0.58, 16, 0, topOffset)
        end
    end

    homeTab._applyColumns = applyHomeColumns
    applyHomeColumns(window._main.Size.X.Offset)
    table.insert(connections, content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        applyHomeColumns(window._main.Size.X.Offset)
    end))

    do
        local discordCard = createCard(leftCol, "Discord", "Tap to join the discord of\nyour script.", options.DiscordIcon, 88)

        local discordInteract = Instance.new("TextButton")
        discordInteract.Name = "HomeDiscordInteract"
        discordInteract.AutoButtonColor = false
        discordInteract.BackgroundTransparency = 1
        discordInteract.BorderSizePixel = 0
        discordInteract.Text = ""
        discordInteract.Size = UDim2.new(1, 0, 1, 0)
        discordInteract.Position = UDim2.new(0, 0, 0, 0)
        discordInteract.Parent = discordCard

        discordInteract.MouseEnter:Connect(function()
            tween(discordCard, { BackgroundColor3 = Theme.Card2 }, 0.12)
        end)
        discordInteract.MouseLeave:Connect(function()
            tween(discordCard, { BackgroundColor3 = Theme.Card }, 0.12)
        end)
        discordInteract.MouseButton1Click:Connect(function()
            if discordInvite == "" then
                window:Notify({ Title = "Discord", Text = "No invite set", Duration = 2 })
                return
            end
            pcall(function()
                setclipboard("https://discord.gg/" .. tostring(discordInvite))
            end)
            window:Notify({ Title = "Discord", Text = "Invite copied", Duration = 2 })
        end)

        local gameName = "Unknown"
        pcall(function()
            gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
        end)

        local serverCard, serverBody = createCard(
            leftCol,
            "Server",
            "Currently Playing " .. truncateWithStars(gameName, 26) .. "...",
            options.ServerIcon,
            250
        )

        local grid = Instance.new("Frame")
        grid.Name = "HomeServerGrid"
        grid.BackgroundTransparency = 1
        grid.BorderSizePixel = 0
        grid.Size = UDim2.new(1, 0, 1, 0)
        grid.Parent = serverBody

        local gridLayout = Instance.new("UIGridLayout")
        gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
        gridLayout.CellSize = UDim2.new(0.5, -5, 0, 56)
        gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
        gridLayout.Parent = grid

        local function statTile(titleText)
            local tile = Instance.new("Frame")
            tile.Name = "HomeStatTile"
            tile.BackgroundColor3 = Theme.Card2
            tile.BorderSizePixel = 0
            tile.Parent = grid
            applyCorner(tile, 10)
            applyStroke(tile, Theme.StrokeSoft, 0.7)

            local p = Instance.new("UIPadding")
            p.Name = "HomeStatPad"
            p.PaddingTop = UDim.new(0, 8)
            p.PaddingLeft = UDim.new(0, 10)
            p.PaddingRight = UDim.new(0, 10)
            p.PaddingBottom = UDim.new(0, 8)
            p.Parent = tile

            local title = createText(tile, titleText, 11, true, Theme.Text)
            title.Size = UDim2.new(1, 0, 0, 16)

            local value = createText(tile, "", 11, false, Theme.SubText)
            value.Position = UDim2.new(0, 0, 0, 18)
            value.Size = UDim2.new(1, 0, 0, 30)
            value.TextWrapped = true
            value.TextYAlignment = Enum.TextYAlignment.Top
            return tile, value
        end

        local tilePlayers, valPlayers = statTile("Players")
        local tileCapacity, valCapacity = statTile("Capacity")
        local tileLatency, valLatency = statTile("Latency")
        local tileJoin, valJoin = statTile("Join Script")
        local tileTime, valTime = statTile("Time")
        local tileRegion, valRegion = statTile("Region")

        valJoin.Text = "Click to copy"
        local joinInteract = Instance.new("TextButton")
        joinInteract.Name = "HomeJoinInteract"
        joinInteract.AutoButtonColor = false
        joinInteract.BackgroundTransparency = 1
        joinInteract.BorderSizePixel = 0
        joinInteract.Text = ""
        joinInteract.Size = UDim2.new(1, 0, 1, 0)
        joinInteract.Parent = tileJoin
        joinInteract.MouseButton1Click:Connect(function()
            local scriptText = string.format(
                'game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)',
                game.PlaceId,
                tostring(game.JobId)
            )
            pcall(function()
                setclipboard(scriptText)
            end)
            window:Notify({ Title = "Server", Text = "Join script copied", Duration = 2 })
        end)

        local function updateCounts()
            valPlayers.Text = tostring(#Players:GetPlayers()) .. " Players\nIn This Server"
            valCapacity.Text = tostring(Players.MaxPlayers) .. " Players\nCan Join"
        end
        updateCounts()
        table.insert(connections, Players.PlayerAdded:Connect(updateCounts))
        table.insert(connections, Players.PlayerRemoving:Connect(updateCounts))

        task.spawn(function()
            pcall(function()
                local region = LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer)
                if valRegion and valRegion.Parent then
                    valRegion.Text = tostring(region)
                end
            end)
        end)

        local startTick = tick()

        local function formatElapsed(sec)
            sec = math.max(0, math.floor(sec))
            if sec < 60 then
                return tostring(sec) .. "s"
            end
            if sec < 3600 then
                return tostring(math.floor(sec / 60)) .. "m"
            end
            return tostring(math.floor(sec / 3600)) .. "h"
        end

        local fpsCounter = 0
        local lastFpsUpdate = tick()

        local function getPingMs()
            local ping = nil
            pcall(function()
                ping = StatsService.PerformanceStats.Ping:GetValue()
            end)
            if typeof(ping) == "number" then
                return math.round(ping)
            end

            local netPing = nil
            pcall(function()
                netPing = LocalPlayer:GetNetworkPing()
            end)
            if typeof(netPing) == "number" then
                return math.round(netPing * 1000)
            end
            return 0
        end

        table.insert(
            connections,
            RunService.Heartbeat:Connect(function()
                if destroyed then
                    return
                end
                fpsCounter += 1
                local now = tick()
                if now - lastFpsUpdate >= 1 then
                    local pingMs = getPingMs()
                    valLatency.Text = tostring(fpsCounter) .. " FPS\n" .. tostring(pingMs) .. "ms"
                    valTime.Text = formatElapsed(now - startTick)
                    fpsCounter = 0
                    lastFpsUpdate = now
                end
            end)
        )

        local changelogCard, changelogBody = createCard(leftCol, "Changelog", "", options.ChangelogIcon, 250)
        changelogCard.Name = "HomeChangelog"

        if changelog[1] then
            local latest = changelog[1]
            local title = createText(changelogBody, tostring(latest.Title or "Latest"), 13, true, Theme.Text)
            title.Size = UDim2.new(1, 0, 0, 18)

            if latest.Date then
                local date = createText(changelogBody, tostring(latest.Date), 11, false, Theme.SubText)
                date.Position = UDim2.new(0, 0, 0, 20)
                date.Size = UDim2.new(1, 0, 0, 16)
            end

            if latest.Description then
                local desc = createText(changelogBody, tostring(latest.Description), 11, false, Theme.SubText)
                desc.Position = UDim2.new(0, 0, 0, 40)
                desc.Size = UDim2.new(1, 0, 1, -40)
                desc.TextWrapped = true
                desc.TextYAlignment = Enum.TextYAlignment.Top
            end
        else
            local empty = createText(changelogBody, "No updates yet.", 11, false, Theme.SubText)
            empty.Size = UDim2.new(1, 0, 1, 0)
            empty.TextYAlignment = Enum.TextYAlignment.Top
        end
    end

    do
        local accountCard = createCard(rightCol, "Account", "Coming Soon.", options.AccountIcon, 88)
        accountCard.Name = "HomeAccount"

        local executorName = (identifyexecutor and identifyexecutor())
            or (getexecutorname and getexecutorname())
            or "Roblox Studio"

        local execCard, execBody = createCard(rightCol, tostring(executorName), "", options.ExecutorIcon, 88)
        execCard.Name = "HomeExecutor"

        table.insert(unsupportedExecutors, "Roblox Studio")

        local execText = "Your Executor Seems To Be\nSupported By This Script."
        if table.find(unsupportedExecutors, executorName) then
            execText = "Your Executor Is Unsupported\nBy This Script."
        elseif #supportedExecutors > 0 and not table.find(supportedExecutors, executorName) then
            execText = "Your Executor Is Unsupported\nBy This Script."
        end
        local l = createText(execBody, execText, 11, false, Theme.SubText)
        l.Size = UDim2.new(1, 0, 1, 0)
        l.TextWrapped = true
        l.TextYAlignment = Enum.TextYAlignment.Top

        local friendsCard, friendsBody = createCard(rightCol, "Friends", "", options.FriendsIcon, 250)
        friendsCard.Name = "HomeFriends"

        local grid = Instance.new("Frame")
        grid.Name = "HomeFriendsGrid"
        grid.BackgroundTransparency = 1
        grid.BorderSizePixel = 0
        grid.Size = UDim2.new(1, 0, 1, 0)
        grid.Parent = friendsBody

        local gridLayout = Instance.new("UIGridLayout")
        gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
        gridLayout.CellSize = UDim2.new(0.5, -5, 0, 56)
        gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
        gridLayout.Parent = grid

        local function friendTile(titleText)
            local tile = Instance.new("Frame")
            tile.Name = "HomeFriendTile"
            tile.BackgroundColor3 = Theme.Card2
            tile.BorderSizePixel = 0
            tile.Parent = grid
            applyCorner(tile, 10)
            applyStroke(tile, Theme.StrokeSoft, 0.7)

            local p = Instance.new("UIPadding")
            p.Name = "HomeFriendPad"
            p.PaddingTop = UDim.new(0, 8)
            p.PaddingLeft = UDim.new(0, 10)
            p.PaddingRight = UDim.new(0, 10)
            p.PaddingBottom = UDim.new(0, 8)
            p.Parent = tile

            local title = createText(tile, titleText, 11, true, Theme.Text)
            title.Size = UDim2.new(1, 0, 0, 16)
            local value = createText(tile, "0 friends", 11, false, Theme.SubText)
            value.Position = UDim2.new(0, 0, 0, 18)
            value.Size = UDim2.new(1, 0, 0, 30)
            value.TextWrapped = true
            value.TextYAlignment = Enum.TextYAlignment.Top
            return value
        end

        local inServerLabel = friendTile("In Server")
        local offlineLabel = friendTile("Offline")
        local onlineLabel = friendTile("Online")
        local totalLabel = friendTile("Total")

        local friendsCooldown = 0
        local function checkFriends()
            if friendsCooldown > 0 then
                friendsCooldown -= 1
                return
            end
            friendsCooldown = 25

            local lp = Players.LocalPlayer
            if not (lp and lp.UserId) then
                return
            end

            local total = 0
            local online = 0
            local inServer = 0

            pcall(function()
                online = #lp:GetFriendsOnline()
            end)

            pcall(function()
                local playersFriends = {}
                local list = Players:GetFriendsAsync(lp.UserId)
                while true do
                    for _, data in list:GetCurrentPage() do
                        total += 1
                        table.insert(playersFriends, data)
                    end
                    if list.IsFinished then
                        break
                    end
                    list:AdvanceToNextPageAsync()
                end

                for _, data in ipairs(playersFriends) do
                    if Players:FindFirstChild(data.Username) then
                        inServer += 1
                    end
                end
            end)

            local offline = math.max(0, total - online)

            inServerLabel.Text = tostring(inServer) .. " friends"
            offlineLabel.Text = tostring(offline) .. " friends"
            onlineLabel.Text = tostring(online) .. " friends"
            totalLabel.Text = tostring(total) .. " friends"
        end

        checkFriends()
        table.insert(
            connections,
            RunService.Heartbeat:Connect(function()
                if destroyed then
                    return
                end
                checkFriends()
            end)
        )
    end

    return homeTab
end

Buster.BronxUI = Buster

return Buster
