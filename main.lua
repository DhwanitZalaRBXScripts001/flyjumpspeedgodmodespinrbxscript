local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- Global States
local flying = false
local flySpeed = 50
local jumpPower = 50
local spinning = false
local godMode = false
local controlsVisible = false

local keys = {f=false, b=false, l=false, r=false, u=false, d=false}
local bodyVelocity, bodyGyro, spinVelocity

-- UI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "DZHackerModMenu"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- ==========================================
-- ROUND MOD MENU OPEN BUTTON
-- ==========================================
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenMenuBtn"
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Text = "DZ"
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextScaled = true
openBtn.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0) -- Makes it perfectly round
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(0, 255, 100)
openStroke.Thickness = 2
openStroke.Parent = openBtn

-- ==========================================
-- MAIN MENU FRAME
-- ==========================================
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 300, 0, 360)
menuFrame.Position = UDim2.new(0.5, -150, 0.5, -180)
menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menuFrame.Visible = false
menuFrame.Active = true
menuFrame.Draggable = true
menuFrame.Parent = gui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menuFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "MADE BY DZ HACKER"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.Parent = menuFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = menuFrame

-- Layout for Menu Items
local listLayout = Instance.new("UIListLayout")
listLayout.Parent = menuFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Push elements down below the title
local spacer = Instance.new("Frame")
spacer.Size = UDim2.new(1, 0, 0, 40)
spacer.BackgroundTransparency = 1
spacer.LayoutOrder = 0
spacer.Parent = menuFrame

-- ==========================================
-- HELPER FUNCTIONS FOR UI
-- ==========================================
local function createToggle(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.LayoutOrder = order
    btn.Parent = menuFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
        callback(active, btn)
    end)
    return btn
end

local function createSlider(text, min, max, default, order, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    container.Parent = menuFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = container

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, 0, 0, 20)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bar.Text = ""
    bar.Parent = container

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    fill.Parent = bar

    local dragging = false

    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        label.Text = text .. ": " .. val
        callback(val)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
end

-- ==========================================
-- MENU ITEMS
-- ==========================================
createSlider("FLY SPEED", 1, 500, 50, 1, function(val)
    flySpeed = val
end)

createSlider("JUMP ADJUST", 50, 500, 50, 2, function(val)
    jumpPower = val
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
        player.Character:FindFirstChildOfClass("Humanoid").JumpPower = val
    end
end)

local btnShowControls = createToggle("SHOW CONTROLS", 3, function(active)
    controlsVisible = active
    local ctrl = gui:FindFirstChild("ControlsFrame")
    if ctrl then ctrl.Visible = controlsVisible end
end)

createToggle("SPIN PLAYER", 4, function(active)
    spinning = active
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if spinning then
            spinVelocity = Instance.new("BodyAngularVelocity")
            spinVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
            spinVelocity.AngularVelocity = Vector3.new(0, 30, 0) -- Spin speed
            spinVelocity.Parent = hrp
        else
            if spinVelocity then spinVelocity:Destroy() end
        end
    end
end)

createToggle("GOD MODE", 5, function(active)
    godMode = active
end)

-- Menu Open/Close Logic
openBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)
closeBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
end)

-- ==========================================
-- CONTROLS FRAME (D-PAD & FLY)
-- ==========================================
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "ControlsFrame"
controlsFrame.Size = UDim2.new(1, 0, 1, 0)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Visible = false
controlsFrame.Parent = gui

local function createControlButton(text, pos)
    local b = Instance.new("TextButton", controlsFrame)
    b.Size = UDim2.new(0, 55, 0, 55)
    b.Position = pos
    b.Text = text
    b.BackgroundTransparency = 0.3
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBlack
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = b
    
    return b
end

local btnFly = createControlButton("FLY", UDim2.new(1, -75, 0, 10))

local btnFwd = createControlButton("FWD", UDim2.new(1, -140, 0, 80))
local btnBwd = createControlButton("BWD", UDim2.new(1, -140, 0, 200))
local btnLft = createControlButton("LFT", UDim2.new(1, -200, 0, 140))
local btnRgt = createControlButton("RGT", UDim2.new(1, -80, 0, 140))

local btnUp  = createControlButton("UP",  UDim2.new(1, -280, 0, 80))
local btnDwn = createControlButton("DWN", UDim2.new(1, -280, 0, 200))

local function bindButton(btn, key)
    btn.MouseButton1Down:Connect(function() keys[key] = true end)
    btn.MouseButton1Up:Connect(function() keys[key] = false end)
    btn.MouseLeave:Connect(function() keys[key] = false end) 
end

bindButton(btnFwd, "f")
bindButton(btnBwd, "b")
bindButton(btnLft, "l")
bindButton(btnRgt, "r")
bindButton(btnUp, "u")
bindButton(btnDwn, "d")

-- ==========================================
-- FLY LOGIC
-- ==========================================
btnFly.MouseButton1Click:Connect(function()
    flying = not flying
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if flying then
        btnFly.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
            end
            
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = hrp
            
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.P = 9e4
            bodyGyro.CFrame = hrp.CFrame
            bodyGyro.Parent = hrp
        end
        if hum then hum.PlatformStand = true end
    else
        btnFly.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end)

-- ==========================================
-- MAIN LOOP (Movement, GodMode, Anti-AFK)
-- ==========================================
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    -- Fly Movement Update
    if flying and hrp and bodyVelocity and bodyGyro then
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        
        if keys.f then moveDir = moveDir + cam.CFrame.LookVector end
        if keys.b then moveDir = moveDir - cam.CFrame.LookVector end
        if keys.l then moveDir = moveDir - cam.CFrame.RightVector end
        if keys.r then moveDir = moveDir + cam.CFrame.RightVector end
        if keys.u then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if keys.d then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end
        
        bodyVelocity.Velocity = moveDir * flySpeed
        bodyGyro.CFrame = cam.CFrame
    end

    -- God Mode Update
    if godMode and hum then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
end)

-- Anti-AFK
VirtualUser.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

-- Reset on Death/Respawn
player.CharacterAdded:Connect(function()
    flying = false
    btnFly.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    if spinning then
        -- Reapply spin on respawn if active
        task.wait(1)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            spinVelocity = Instance.new("BodyAngularVelocity")
            spinVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
            spinVelocity.AngularVelocity = Vector3.new(0, 30, 0)
            spinVelocity.Parent = hrp
        end
    end
    if godMode then
        task.wait(1)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end
    -- Reapply Jump Power
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = jumpPower
    end
end)
