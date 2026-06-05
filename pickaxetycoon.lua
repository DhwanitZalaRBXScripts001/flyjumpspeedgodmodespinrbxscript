print("Thanks for using the DZ Mod Menu Script!")
warn("Like it on scriptblox!")

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Prevent duplicate UI
if CoreGui:FindFirstChild("DZ_ModMenu") then
    CoreGui.DZ_ModMenu:Destroy()
end

--=========================================--
--          DZ MOD MENU UI LAYOUT          --
--=========================================--

local DZ_ModMenu = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local AutoFarmBtn = Instance.new("TextButton")
local GodModeBtn = Instance.new("TextButton")
local SpeedBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

DZ_ModMenu.Name = "DZ_ModMenu"
DZ_ModMenu.Parent = CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = DZ_ModMenu
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Active = true
MainFrame.Draggable = true -- Allows you to drag the menu around

UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 10)

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "⚡ DZ MOD MENU ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(170, 0, 255)
TitleLabel.TextSize = 18

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleLabel

local function CreateButton(name, yPos, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Position = UDim2.new(0.1, 0, 0, yPos)
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

AutoFarmBtn = CreateButton("AutoFarmBtn", 60, "Auto Farm: OFF")
GodModeBtn = CreateButton("GodModeBtn", 110, "999x God Mode: OFF")
SpeedBtn = CreateButton("SpeedBtn", 160, "Flash Speed: OFF")

--=========================================--
--             SCRIPT LOGIC                --
--=========================================--

getgenv().AutoFarm = false
getgenv().GodMode = false
getgenv().FlashSpeed = false

local LootPickup = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("LootPickup")

-- Auto Farm Loop (Optimized)
task.spawn(function()
    while true do
        task.wait(0.01) -- Insanely fast but prevents crashing
        if getgenv().AutoFarm then
            
            -- Loot Pickup Loop
            for i = 1, 24 do
                for count = 1, 40 do
                    LootPickup:FireServer({i})
                end
            end
            
            -- Plot Interaction
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            for plotNum = 1, 6 do
                local plotName = "Plot_" .. plotNum
                local plot = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild(plotName)
                
                if plot then
                    local shelfFolder = plot:FindFirstChild("Shelf")
                    local baseFolder = shelfFolder and shelfFolder:FindFirstChild("Base")
                    local ramp = baseFolder and baseFolder:FindFirstChild("Ramp")
                    
                    if ramp then
                        local trough = ramp:FindFirstChild("Trough")
                        if trough then trough:Destroy() end
                        
                        local children = ramp:GetChildren()
                        if children[5] then children[5]:Destroy() end
                    end
                    
                    if rootPart and firetouchinterest then
                        local function safeFire(buttonPath)
                            if buttonPath and buttonPath:FindFirstChild("Button") then
                                local target = buttonPath.Button
                                firetouchinterest(rootPart, target, 0)
                                firetouchinterest(rootPart, target, 1)
                            end
                        end
                        
                        local sellFolder = plot:FindFirstChild("Sell")
                        if sellFolder then
                            safeFire(sellFolder:FindFirstChild("DepositButton"))
                            safeFire(sellFolder:FindFirstChild("CollectButton"))
                        end
                        
                        local buttonsFolder = plot:FindFirstChild("Buttons")
                        if buttonsFolder then
                            safeFire(buttonsFolder:FindFirstChild("ButtonBuy100"))
                            safeFire(buttonsFolder:FindFirstChild("ButtonBuy25"))
                            safeFire(buttonsFolder:FindFirstChild("ButtonBuy5"))
                            safeFire(buttonsFolder:FindFirstChild("ButtonBuy1"))
                            safeFire(buttonsFolder:FindFirstChild("ButtonMerge"))
                        end
                    end
                end
            end
        end
    end
end)

-- God Mode Loop
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    
    if getgenv().GodMode and hum then
        hum.MaxHealth = 999999
        hum.Health = 999999
    end
    
    if getgenv().FlashSpeed and hum then
        hum.WalkSpeed = 150
    elseif not getgenv().FlashSpeed and hum and hum.WalkSpeed > 100 then
        hum.WalkSpeed = 16 -- Reset to default
    end
end)

--=========================================--
--               UI TOGGLES                --
--=========================================--

AutoFarmBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    AutoFarmBtn.Text = getgenv().AutoFarm and "Auto Farm: ON (FAST!)" or "Auto Farm: OFF"
    AutoFarmBtn.TextColor3 = getgenv().AutoFarm and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
end)

GodModeBtn.MouseButton1Click:Connect(function()
    getgenv().GodMode = not getgenv().GodMode
    GodModeBtn.Text = getgenv().GodMode and "999x God Mode: ON" or "999x God Mode: OFF"
    GodModeBtn.TextColor3 = getgenv().GodMode and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
end)

SpeedBtn.MouseButton1Click:Connect(function()
    getgenv().FlashSpeed = not getgenv().FlashSpeed
    SpeedBtn.Text = getgenv().FlashSpeed and "Flash Speed: ON" or "Flash Speed: OFF"
    SpeedBtn.TextColor3 = getgenv().FlashSpeed and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
end)
