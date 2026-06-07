-- Made by Dz HACKER
local gui = Instance.new("ScreenGui")
gui.Name = "DzHackerGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 72, 0, 92)
frame.Position = UDim2.new(0, 10, 0.5, -46)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local fCorner = Instance.new("UICorner")
fCorner.CornerRadius = UDim.new(0, 14)
fCorner.Parent = frame

local fStroke = Instance.new("UIStroke")
fStroke.Color = Color3.fromRGB(50, 50, 50)
fStroke.Thickness = 1
fStroke.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Name = "Toggle"
toggle.Size = UDim2.new(0, 50, 0, 50)
toggle.Position = UDim2.new(0, 11, 0, 6)
toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggle.BorderSizePixel = 0
toggle.Text = ""
toggle.Parent = frame

local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(0, 12)
tCorner.Parent = toggle

local tStroke = Instance.new("UIStroke")
tStroke.Color = Color3.fromRGB(0, 200, 80)
tStroke.Thickness = 2
tStroke.Parent = toggle

local tIcon = Instance.new("TextLabel")
tIcon.Size = UDim2.new(1, 0, 1, 0)
tIcon.BackgroundTransparency = 1
tIcon.Text = "✓"
tIcon.TextColor3 = Color3.fromRGB(0, 200, 80)
tIcon.TextSize = 22
tIcon.Font = Enum.Font.GothamBold
tIcon.Parent = toggle

local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.new(0, 50, 0, 24)
close.Position = UDim2.new(0, 11, 0, 62)
close.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
close.BorderSizePixel = 0
close.Text = ""
close.Parent = frame

local cCorner = Instance.new("UICorner")
cCorner.CornerRadius = UDim.new(0, 8)
cCorner.Parent = close

local cStroke = Instance.new("UIStroke")
cStroke.Color = Color3.fromRGB(200, 50, 50)
cStroke.Thickness = 1.5
cStroke.Parent = close

local cIcon = Instance.new("TextLabel")
cIcon.Size = UDim2.new(1, 0, 1, 0)
cIcon.BackgroundTransparency = 1
cIcon.Text = "✕ CLOSE"
cIcon.TextColor3 = Color3.fromRGB(200, 50, 50)
cIcon.TextSize = 10
cIcon.Font = Enum.Font.GothamBold
cIcon.Parent = close

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(0, 100, 0, 14)
credit.Position = UDim2.new(0, 88, 0.5, -7)
credit.BackgroundTransparency = 1
credit.Text = "Dz HACKER"
credit.TextColor3 = Color3.fromRGB(100, 100, 100)
credit.TextSize = 10
credit.Font = Enum.Font.Gotham
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.Parent = gui

local function updateVisual()
    if _G.cookroomfucker then
        tStroke.Color = Color3.fromRGB(0, 200, 80)
        tIcon.Text = "✓"
        tIcon.TextColor3 = Color3.fromRGB(0, 200, 80)
    else
        tStroke.Color = Color3.fromRGB(200, 50, 50)
        tIcon.Text = "✕"
        tIcon.TextColor3 = Color3.fromRGB(200, 50, 50)
    end
end

toggle.MouseButton1Click:Connect(function()
    _G.cookroomfucker = not _G.cookroomfucker
    updateVisual()
end)

close.MouseButton1Click:Connect(function()
    _G.cookroomfucker = false
    gui:Destroy()
    -- kills all loops that check _G.cookroomfucker
    -- and removes the GUI completely
end)

updateVisual()
