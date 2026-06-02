local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ==========================================
-- GLOBAL STATES & SETTINGS
-- ==========================================
local Config = {
    flying = false,
    flySpeed = 50,
    jumpPower = 50,
    spinning = false,
    godMode = false,
    controlsVisible = false
}

local DefaultConfig = {
    flySpeed = 50,
    jumpPower = 50
}

local keys = {f=false, b=false, l=false, r=false, u=false, d=false}
local bodyVelocity, bodyGyro, spinVelocity
local toggles = {} -- Store toggle functions to update them externally
local sliders = {} -- Store slider update functions

-- ==========================================
-- UI SETUP & ANIMATIONS
-- ==========================================
local gui = Instance.new("ScreenGui")
gui.Name = "DZHackerUltimateV2"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- Tween Function for smooth UI animations
local function tweenUI(obj, properties, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

-- ==========================================
-- FLOATING ROUND MENU BUTTON (DZ)
-- ==========================================
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 55, 0, 55)
openBtn.Position = UDim2.new(0, 15, 0, 15)
openBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
openBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
openBtn.Text = "DZ"
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 22
openBtn.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(0, 255, 100)
openStroke.Thickness = 2.5
openStroke.Parent = openBtn

-- Button pulse animation
task.spawn(function()
    while true do
        tweenUI(openStroke, {Thickness = 4}, 0.5).Completed:Wait()
        tweenUI(openStroke, {Thickness = 2.5}, 0.5).Completed:Wait()
    end
end)

-- ==========================================
-- MAIN MENU FRAME & CUSTOM DRAGGING
-- ==========================================
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 320, 0, 0) -- Starts at 0 height for animation
menuFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
menuFrame.ClipsDescendants = true
menuFrame.Visible = false
menuFrame.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menuFrame

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(0, 255, 100)
menuStroke.Thickness = 1.5
menuStroke.Parent = menuFrame

-- Custom Smooth Dragging
local dragging, dragInput, dragStart, startPos
menuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = menuFrame.Position
    end
end)
menuFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Title Bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "🔥 DZ HACKER V2 🔥"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.Parent = menuFrame

-- Scroll Frame for contents
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -50)
scrollFrame.Position = UDim2.new(0, 0, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
scrollFrame.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ==========================================
-- ADVANCED UI COMPONENTS
-- ==========================================
local function createToggle(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.LayoutOrder = order
    btn.Parent = scrollFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local active = false
    local function setToggle(state)
        active = state
        if active then
            tweenUI(btn, {BackgroundColor3 = Color3.fromRGB(0, 180, 70), TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        else
            tweenUI(btn, {BackgroundColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
        end
        callback(active, btn)
    end

    btn.MouseButton1Click:Connect(function() setToggle(not active) end)
    return setToggle
end

local function createSlider(text, min, max, default, order, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    container.Parent = scrollFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = container

    local bgBar = Instance.new("Frame")
    bgBar.Size = UDim2.new(1, 0, 0, 10)
    bgBar.Position = UDim2.new(0, 0, 0, 30)
    bgBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    bgBar.Parent = container

    Instance.new("UICorner", bgBar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    fill.Parent = bgBar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local function setSlider(val)
        val = math.clamp(val, min, max)
        label.Text = text .. ": " .. val
        tweenUI(fill, {Size = UDim2.new((val - min) / (max - min), 0, 1, 0)}, 0.1)
        callback(val)
    end

    local dragging = false
    bgBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setSlider(math.floor(min + (max - min) * math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)))
        end
    end)
    UserInputService.InputEnded:Connect(function(input) dragging = false end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setSlider(math.floor(min + (max - min) * math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)))
        end
    end)

    return setSlider
end

local function createButton(text, color, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.LayoutOrder = order
    btn.Parent = scrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- MENU ITEMS & LOGIC
-- ==========================================

sliders.flySpeed = createSlider("FLY SPEED", 1, 500, DefaultConfig.flySpeed, 1, function(val)
    Config.flySpeed = val
end)

sliders.jumpPower = createSlider("JUMP POWER", 50, 500, DefaultConfig.jumpPower, 2, function(val)
    Config.jumpPower = val
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true; hum.JumpPower = val end
end)

toggles.controls = createToggle("SHOW CONTROLS", 3, function(active)
    Config.controlsVisible = active
    local ctrl = gui:FindFirstChild("ControlsFrame")
    if ctrl then ctrl.Visible = Config.controlsVisible end
end)

toggles.spin = createToggle("SPIN PLAYER", 4, function(active)
    Config.spinning = active
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        if Config.spinning then
            spinVelocity = Instance.new("BodyAngularVelocity")
            spinVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
            spinVelocity.AngularVelocity = Vector3.new(0, 40, 0)
            spinVelocity.Parent = hrp
        elseif spinVelocity then spinVelocity:Destroy() end
    end
end)

toggles.god = createToggle("GOD MODE", 5, function(active)
    Config.godMode = active
end)

-- RESET SETTINGS BUTTON
createButton("RESET SETTINGS", Color3.fromRGB(200, 100, 0), 6, function()
    sliders.flySpeed(DefaultConfig.flySpeed)
    sliders.jumpPower(DefaultConfig.jumpPower)
    toggles.spin(false)
    toggles.god(false)
end)

-- RESET CHARACTER BUTTON
createButton("RESET CHARACTER", Color3.fromRGB(200, 50, 50), 7, function()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)

-- Menu Open/Close Toggle
local menuOpen = false
openBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if menuOpen then
        menuFrame.Visible = true
        tweenUI(menuFrame, {Size = UDim2.new(0, 320, 0, 400)}, 0.3)
    else
        tweenUI(menuFrame, {Size = UDim2.new(0, 320, 0, 0)}, 0.3).Completed:Connect(function()
            if not menuOpen then menuFrame.Visible = false end
        end)
    end
end)

-- ==========================================
-- D-PAD CONTROLS FRAME (MOBILE)
-- ==========================================
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "ControlsFrame"
controlsFrame.Size = UDim2.new(1, 0, 1, 0)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Visible = false
controlsFrame.Parent = gui

local function buildDPad(text, pos)
    local b = Instance.new("TextButton", controlsFrame)
    b.Size = UDim2.new(0, 60, 0, 60)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    b.BackgroundTransparency = 0.4
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 16
    
    local stroke = Instance.new("UIStroke", b)
    stroke.Color = Color3.fromRGB(0, 255, 100)
    stroke.Transparency = 0.5
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
    return b
end

local btnFly = buildDPad("FLY", UDim2.new(1, -80, 0, 15))
local btnFwd = buildDPad("FWD", UDim2.new(1, -150, 0, 100))
local btnBwd = buildDPad("BWD", UDim2.new(1, -150, 0, 240))
local btnLft = buildDPad("LFT", UDim2.new(1, -220, 0, 170))
local btnRgt = buildDPad("RGT", UDim2.new(1, -80, 0, 170))
local btnUp  = buildDPad("UP",  UDim2.new(1, -320, 0, 100))
local btnDwn = buildDPad("DWN", UDim2.new(1, -320, 0, 240))

local function bind(btn, key)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            keys[key] = true
            tweenUI(btn, {BackgroundTransparency = 0.1}, 0.1)
        end
    end)
    btn.InputEnded:Connect(function(input)
        keys[key] = false
        tweenUI(btn, {BackgroundTransparency = 0.4}, 0.1)
    end)
end

bind(btnFwd, "f"); bind(btnBwd, "b"); bind(btnLft, "l"); bind(btnRgt, "r"); bind(btnUp, "u"); bind(btnDwn, "d")

-- ==========================================
-- CORE SCRIPTS (FLYING, GOD MODE, ANTI-AFK)
-- ==========================================
btnFly.MouseButton1Click:Connect(function()
    Config.flying = not Config.flying
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if Config.flying then
        tweenUI(btnFly, {BackgroundColor3 = Color3.fromRGB(0, 200, 80)}, 0.2)
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
            end
            bodyVelocity = Instance.new("BodyVelocity", hrp)
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.P = 9e4
            bodyGyro.CFrame = hrp.CFrame
        end
        if hum then hum.PlatformStand = true end
    else
        tweenUI(btnFly, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}, 0.2)
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    -- Smooth Fly Logic
    if Config.flying and hrp and bodyVelocity and bodyGyro then
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        
        if keys.f then moveDir = moveDir + cam.CFrame.LookVector end
        if keys.b then moveDir = moveDir - cam.CFrame.LookVector end
        if keys.l then moveDir = moveDir - cam.CFrame.RightVector end
        if keys.r then moveDir = moveDir + cam.CFrame.RightVector end
        if keys.u then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if keys.d then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        
        -- Smoothly interpolate velocity for less choppiness
        bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(moveDir * Config.flySpeed, 0.15)
        bodyGyro.CFrame = cam.CFrame
    end

    -- God Mode Override
    if Config.godMode and hum then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
end)

-- Anti-AFK (Prevents 20 min idle kick)
VirtualUser.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

-- Reset handling
player.CharacterAdded:Connect(function(char)
    Config.flying = false
    btnFly.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid", 3)
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = Config.jumpPower
        if Config.godMode then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end
    
    if Config.spinning then
        local hrp = char:WaitForChild("HumanoidRootPart", 3)
        if hrp then
            spinVelocity = Instance.new("BodyAngularVelocity", hrp)
            spinVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
            spinVelocity.AngularVelocity = Vector3.new(0, 40, 0)
        end
    end
end)
