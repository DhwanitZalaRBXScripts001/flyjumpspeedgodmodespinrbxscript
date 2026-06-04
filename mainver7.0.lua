--[[
    DZ HACKER V7.0 – "AntiBan" Edition
    Features:
    - Anti‑Kick (blocks kick attempts)
    - Anti‑Ban remote blocker
    - GUI name randomisation (evades scanners)
    - All V6 features (fly, noclip, ESP, godmode, etc.)
    - Fixed ESP lines + spin on respawn
    - Less detectable speed/jump/noclip
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ==========================================
--  ANTI-BAN / ANTI-KICK
-- ==========================================
-- Override LocalPlayer:Kick (prevents script‑based kicks)
local oldKick = player.Kick
player.Kick = function(self, msg)
    warn("⛔ ANTI‑KICK BLOCKED: " .. tostring(msg))
    return nil
end

-- Block remote events that contain "kick", "ban", "antitamper"
local function blockBanRemotes()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("kick") or name:find("ban") or name:find("antitamper") then
                local oldFire = obj.FireServer
                if oldFire then
                    obj.FireServer = function() end
                end
                local oldInvoke = obj.InvokeServer
                if oldInvoke then
                    obj.InvokeServer = function() return nil end
                end
            end
        end
    end
end
task.spawn(blockBanRemotes)
-- Re‑scan every 30 seconds in case new remotes appear
task.spawn(function()
    while true do
        task.wait(30)
        blockBanRemotes()
    end
end)

-- ==========================================
--  STEALTH GUI – RANDOM OBJECT NAMES
-- ==========================================
local function randomString(len)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local out = ""
    for _ = 1, len do
        out = out .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return out
end

local gui = Instance.new("ScreenGui")
gui.Name = randomString(12)
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- periodically rename the GUI to avoid static detection
task.spawn(function()
    while true do
        task.wait(60)
        gui.Name = randomString(12)
    end
end)

-- ==========================================
--  GLOBAL STATES & SETTINGS
-- ==========================================
local Config = {
    flying = false,
    noclip = false,
    flySpeed = 50,
    walkSpeed = 16,
    jumpPower = 50,
    spinning = false,
    godMode = false,
    invisible = false,
    esp = false,
    controlsVisible = false
}

local DefaultConfig = {
    flySpeed = 50,
    walkSpeed = 16,
    jumpPower = 50
}

local keys = { f = false, b = false, l = false, r = false, u = false, d = false }
local bodyVelocity, bodyGyro
local toggles = {}
local sliders = {}

-- ==========================================
--  UI ANIMATIONS
-- ==========================================
local function tweenUI(obj, properties, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

-- ==========================================
--  FLOATING DRAG BUTTON (RANDOMISED TEXT)
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

-- subtle pulse animation
task.spawn(function()
    while true do
        tweenUI(openStroke, { Thickness = 4 }, 0.5).Completed:Wait()
        tweenUI(openStroke, { Thickness = 2.5 }, 0.5).Completed:Wait()
    end
end)

-- Drag logic
local draggingBtn = false
local dragInput, mousePos, framePos

openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true
        mousePos = input.Position
        framePos = openBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingBtn = false
            end
        end)
    end
end)

openBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and draggingBtn then
        local delta = input.Position - mousePos
        openBtn.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
--  MAIN MENU FRAME (RANDOMISED NAME)
-- ==========================================
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 320, 0, 0)
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

-- Dragging menu
local draggingMenu, dragMenuStart, startMenuPos
menuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = true
        dragMenuStart = input.Position
        startMenuPos = menuFrame.Position
    end
end)
menuFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingMenu and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragMenuStart
        menuFrame.Position = UDim2.new(startMenuPos.X.Scale, startMenuPos.X.Offset + delta.X, startMenuPos.Y.Scale, startMenuPos.Y.Offset + delta.Y)
    end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "🔥 DZ HACKER V7.0 🔥"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.Parent = menuFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -50)
scrollFrame.Position = UDim2.new(0, 0, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 770)
scrollFrame.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ==========================================
--  UI COMPONENTS (TOGGLES, SLIDERS, BUTTONS)
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
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local active = false
    local function setToggle(state)
        active = state
        if active then
            tweenUI(btn, { BackgroundColor3 = Color3.fromRGB(0, 180, 70), TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.2)
        else
            tweenUI(btn, { BackgroundColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.fromRGB(200, 200, 200) }, 0.2)
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
        tweenUI(fill, { Size = UDim2.new((val - min) / (max - min), 0, 1, 0) }, 0.1)
        callback(val)
    end

    local draggingSlider = false
    bgBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            setSlider(math.floor(min + (max - min) * math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)))
        end
    end)
    UserInputService.InputEnded:Connect(function(input) draggingSlider = false end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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
--  MENU ITEMS & LOGIC
-- ==========================================
sliders.flySpeed = createSlider("FLY SPEED", 1, 500, DefaultConfig.flySpeed, 1, function(val) Config.flySpeed = val end)
sliders.walkSpeed = createSlider("WALK SPEED", 16, 500, DefaultConfig.walkSpeed, 2, function(val) Config.walkSpeed = val end)
sliders.jumpPower = createSlider("JUMP POWER", 50, 500, DefaultConfig.jumpPower, 3, function(val) Config.jumpPower = val end)

toggles.esp = createToggle("ESP (NAMES/LINES/HP/DIST)", 4, function(active) Config.esp = active end)
toggles.controls = createToggle("SHOW CONTROLS", 5, function(active)
    Config.controlsVisible = active
    local ctrl = gui:FindFirstChild("ControlsFrame")
    if ctrl then ctrl.Visible = Config.controlsVisible end
end)
toggles.spin = createToggle("SPIN PLAYER", 6, function(active)
    Config.spinning = active
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do if v.Name == "DZSpin" then v:Destroy() end end
        if Config.spinning then
            local newSpin = Instance.new("BodyAngularVelocity")
            newSpin.Name = "DZSpin"
            newSpin.MaxTorque = Vector3.new(0, math.huge, 0)
            newSpin.AngularVelocity = Vector3.new(0, 40, 0)
            newSpin.Parent = hrp
        end
    end
end)
toggles.god = createToggle("GOD MODE", 7, function(active) Config.godMode = active end)

local function setInvisibility(char, state)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = state and 1 or 0
        elseif part:IsA("Decal") and part.Name == "face" then
            part.Transparency = state and 1 or 0
        end
    end
end

toggles.invisible = createToggle("INVISIBLE", 8, function(active)
    Config.invisible = active
    setInvisibility(player.Character, active)
end)

createButton("FORCE FIRST PERSON", Color3.fromRGB(60, 100, 200), 9, function() player.CameraMode = Enum.CameraMode.LockFirstPerson end)
createButton("FORCE THIRD PERSON", Color3.fromRGB(60, 180, 200), 10, function()
    player.CameraMode = Enum.CameraMode.Classic
    player.CameraMinZoomDistance = 12
    task.wait(0.1)
    player.CameraMinZoomDistance = 0.5
end)
createButton("RESET SETTINGS", Color3.fromRGB(200, 100, 0), 11, function()
    sliders.flySpeed(DefaultConfig.flySpeed)
    sliders.walkSpeed(DefaultConfig.walkSpeed)
    sliders.jumpPower(DefaultConfig.jumpPower)
    toggles.esp(false)
    toggles.spin(false)
    toggles.god(false)
    toggles.invisible(false)
    Config.noclip = false
    Config.flying = false
end)
createButton("RESET CHARACTER", Color3.fromRGB(200, 50, 50), 12, function()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)

-- Menu toggle
local menuOpen = false
openBtn.MouseButton1Click:Connect(function()
    if draggingBtn then return end
    menuOpen = not menuOpen
    if menuOpen then
        menuFrame.Visible = true
        tweenUI(menuFrame, { Size = UDim2.new(0, 320, 0, 400) }, 0.3)
    else
        tweenUI(menuFrame, { Size = UDim2.new(0, 320, 0, 0) }, 0.3).Completed:Connect(function()
            if not menuOpen then menuFrame.Visible = false end
        end)
    end
end)

-- ==========================================
--  D-PAD CONTROLS (MOBILE)
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

local function buildSmallBtn(text, pos, activeColor)
    local b = Instance.new("TextButton", controlsFrame)
    b.Size = UDim2.new(0, 55, 0, 45)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    b.BackgroundTransparency = 0.2
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 12
    local stroke = Instance.new("UIStroke", b)
    stroke.Color = activeColor
    stroke.Transparency = 0.2
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local btnFly = buildSmallBtn("FLY", UDim2.new(1, -135, 0, 15), Color3.fromRGB(0, 255, 100))
local btnWall = buildSmallBtn("WALL", UDim2.new(1, -70, 0, 15), Color3.fromRGB(200, 50, 255))

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
            tweenUI(btn, { BackgroundTransparency = 0.1 }, 0.1)
        end
    end)
    btn.InputEnded:Connect(function(input)
        keys[key] = false
        tweenUI(btn, { BackgroundTransparency = 0.4 }, 0.1)
    end)
end

bind(btnFwd, "f"); bind(btnBwd, "b"); bind(btnLft, "l"); bind(btnRgt, "r"); bind(btnUp, "u"); bind(btnDwn, "d")

-- ==========================================
--  ESP SYSTEM (TRACERS & LABELS)
-- ==========================================
local espObjects = {}

local function createESP(plr)
    if espObjects[plr] then return end

    local line = Instance.new("Frame")
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.ZIndex = 1
    line.Parent = gui

    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 12
    text.ZIndex = 2
    text.Parent = gui

    espObjects[plr] = { Line = line, Text = text }
end

local function removeESP(plr)
    if espObjects[plr] then
        espObjects[plr].Line:Destroy()
        espObjects[plr].Text:Destroy()
        espObjects[plr] = nil
    end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= player then createESP(plr) end
end

-- ==========================================
--  CORE LOOP (FLY, NOCLIP, ESP, SPEED)
-- ==========================================
-- Fly toggle
btnFly.MouseButton1Click:Connect(function()
    Config.flying = not Config.flying
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if Config.flying then
        tweenUI(btnFly, { BackgroundColor3 = Color3.fromRGB(0, 200, 80) }, 0.2)
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "DZFlyVel" or v.Name == "DZFlyGyro" then v:Destroy() end
            end
            bodyVelocity = Instance.new("BodyVelocity", hrp)
            bodyVelocity.Name = "DZFlyVel"
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.Name = "DZFlyGyro"
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.P = 9e4
            bodyGyro.CFrame = hrp.CFrame
        end
        if hum then hum.PlatformStand = true end
    else
        tweenUI(btnFly, { BackgroundColor3 = Color3.fromRGB(15, 15, 15) }, 0.2)
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end)

-- Wall hack (noclip) with periodic re‑apply to avoid detection
btnWall.MouseButton1Click:Connect(function()
    Config.noclip = not Config.noclip
    if Config.noclip then
        tweenUI(btnWall, { BackgroundColor3 = Color3.fromRGB(150, 0, 200) }, 0.2)
    else
        tweenUI(btnWall, { BackgroundColor3 = Color3.fromRGB(15, 15, 15) }, 0.2)
    end
end)

-- Stepped applies noclip every frame (immediate effect)
RunService.Stepped:Connect(function()
    if Config.noclip then
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- RenderStepped for flying, speed/jump, ESP
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local myHead = char and char:FindFirstChild("Head")

    -- Fly movement
    if Config.flying and hrp and bodyVelocity and bodyGyro and hrp:FindFirstChild("DZFlyVel") then
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        if keys.f then moveDir = moveDir + cam.CFrame.LookVector end
        if keys.b then moveDir = moveDir - cam.CFrame.LookVector end
        if keys.l then moveDir = moveDir - cam.CFrame.RightVector end
        if keys.r then moveDir = moveDir + cam.CFrame.RightVector end
        if keys.u then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if keys.d then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        bodyVelocity.Velocity = moveDir * Config.flySpeed
        bodyGyro.CFrame = cam.CFrame
    end

    -- WalkSpeed / JumpPower (set only if different to avoid spam detection)
    if hum then
        if hum.WalkSpeed ~= Config.walkSpeed then hum.WalkSpeed = Config.walkSpeed end
        if hum.JumpPower ~= Config.jumpPower then hum.JumpPower = Config.jumpPower end
        if Config.godMode then
            if hum.MaxHealth ~= 9e9 then hum.MaxHealth = 9e9 end
            if hum.Health ~= 9e9 then hum.Health = 9e9 end
        end
    end

    -- ESP rendering
    if Config.esp then
        local cam = workspace.CurrentCamera
        for plr, objs in pairs(espObjects) do
            local targetChar = plr.Character
            local targetHead = targetChar and targetChar:FindFirstChild("Head")
            local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
            if targetChar and targetHead and targetHum and targetHum.Health > 0 and myHead then
                local headPos, onScreen = cam:WorldToViewportPoint(targetHead.Position + Vector3.new(0, 1.5, 0))
                local myHeadPos, myOnScreen = cam:WorldToViewportPoint(myHead.Position)
                if onScreen and myOnScreen then
                    objs.Text.Visible = true
                    local dist = (myHead.Position - targetHead.Position).Magnitude
                    local hp = math.floor(targetHum.Health)
                    objs.Text.Text = string.format("%s\nHP: %d\n[%dm]", plr.Name, hp, math.floor(dist))
                    objs.Text.Position = UDim2.new(0, headPos.X, 0, headPos.Y - 30)

                    objs.Line.Visible = true
                    local distance2D = (Vector2.new(headPos.X, headPos.Y) - Vector2.new(myHeadPos.X, myHeadPos.Y)).Magnitude
                    objs.Line.Size = UDim2.new(0, 1.5, 0, distance2D)
                    objs.Line.Position = UDim2.new(0, (headPos.X + myHeadPos.X) / 2, 0, (headPos.Y + myHeadPos.Y) / 2)
                    local angle = math.deg(math.atan2(headPos.Y - myHeadPos.Y, headPos.X - myHeadPos.X))
                    objs.Line.Rotation = angle + 90
                else
                    objs.Text.Visible = false
                    objs.Line.Visible = false
                end
            else
                objs.Text.Visible = false
                objs.Line.Visible = false
            end
        end
    else
        for _, objs in pairs(espObjects) do
            objs.Text.Visible = false
            objs.Line.Visible = false
        end
    end
end)

-- Anti‑AFK (still needed)
VirtualUser.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

-- Respawn handler: reset fly, noclip, re‑apply invisible / spin
player.CharacterAdded:Connect(function(char)
    Config.flying = false
    Config.noclip = false
    btnFly.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btnWall.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hum.UseJumpPower = true end

    if Config.invisible then
        task.wait(0.5)
        setInvisibility(char, true)
    end

    if Config.spinning then
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            local newSpin = Instance.new("BodyAngularVelocity")
            newSpin.Name = "DZSpin"
            newSpin.MaxTorque = Vector3.new(0, math.huge, 0)
            newSpin.AngularVelocity = Vector3.new(0, 40, 0)
            newSpin.Parent = hrp
        end
    end
end)

print("✅ DZ HACKER V7.0 loaded – AntiBan active")
