-- Made by Dz HACKER
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "DzHackerGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Create Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 72, 0, 92)
frame.Position = UDim2.new(0.5, -36, 0.5, -46) -- Centered
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Add Rounding and Stroke
local fCorner = Instance.new("UICorner", frame)
fCorner.CornerRadius = UDim.new(0, 14)
local fStroke = Instance.new("UIStroke", frame)
fStroke.Color = Color3.fromRGB(50, 50, 50)

-- Make it Movable (Draggable)
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Toggle Button
local toggle = Instance.new("TextButton", frame)
toggle.Name = "Toggle"
toggle.Size = UDim2.new(0, 50, 0, 50)
toggle.Position = UDim2.new(0, 11, 0, 6)
toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggle.Text = ""
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 12)
local tStroke = Instance.new("UIStroke", toggle)
tStroke.Color = Color3.fromRGB(0, 200, 80)

local tIcon = Instance.new("TextLabel", toggle)
tIcon.Size = UDim2.new(1, 0, 1, 0)
tIcon.BackgroundTransparency = 1
tIcon.Text = "✓"
tIcon.TextColor3 = Color3.fromRGB(0, 200, 80)
tIcon.Font = Enum.Font.GothamBold

-- Close Button
local close = Instance.new("TextButton", frame)
close.Name = "Close"
close.Size = UDim2.new(0, 50, 0, 24)
close.Position = UDim2.new(0, 11, 0, 62)
close.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
close.Text = ""
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", close).Color = Color3.fromRGB(200, 50, 50)

local cIcon = Instance.new("TextLabel", close)
cIcon.Size = UDim2.new(1, 0, 1, 0)
cIcon.BackgroundTransparency = 1
cIcon.Text = "✕ CLOSE"
cIcon.TextColor3 = Color3.fromRGB(200, 50, 50)
cIcon.TextSize = 10
cIcon.Font = Enum.Font.GothamBold

-- Logic
local function updateVisual()
    if _G.cookroomfucker then
        tStroke.Color = Color3.fromRGB(0, 200, 80)
        tIcon.Text = "✓"
    else
        tStroke.Color = Color3.fromRGB(200, 50, 50)
        tIcon.Text = "✕"
    end
end

toggle.MouseButton1Click:Connect(function()
    _G.cookroomfucker = not _G.cookroomfucker
    updateVisual()
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
