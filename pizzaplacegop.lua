-- Made by Dz HACKER
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- Clean up any existing instances of this UI before running a fresh build
if PlayerGui:FindFirstChild("DzHackerGUI") then
    PlayerGui.DzHackerGUI:Destroy()
end

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "DzHackerGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Create Frame (Slightly widened to accommodate a modern, layout-friendly close button)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 110, 0, 100)
frame.Position = UDim2.new(0.5, -55, 0.5, -50) -- Centered precisely
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Add Rounding and Frame Stroke
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local fStroke = Instance.new("UIStroke", frame)
fStroke.Color = Color3.fromRGB(45, 45, 45)
fStroke.Thickness = 1.5

-- Dragging Mechanics Engine
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

-- Professional Top Right Close Button (✕)
local close = Instance.new("TextButton", frame)
close.Name = "CloseButton"
close.Size = UDim2.new(0, 20, 0, 20)
close.Position = UDim2.new(1, -26, 0, 6)
close.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
close.Text = "✕"
close.TextColor3 = Color3.fromRGB(220, 60, 60)
close.TextSize = 11
close.Font = Enum.Font.GothamBold
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 4)
local cStroke = Instance.new("UIStroke", close)
cStroke.Color = Color3.fromRGB(50, 30, 30)

-- Main Execution Toggle Button
local toggle = Instance.new("TextButton", frame)
toggle.Name = "Toggle"
toggle.Size = UDim2.new(0, 88, 0, 50)
toggle.Position = UDim2.new(0, 11, 0, 38)
toggle.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
toggle.Text = ""
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)
local tStroke = Instance.new("UIStroke", toggle)
tStroke.Color = Color3.fromRGB(220, 60, 60) -- Default to Off State (Red)

local tIcon = Instance.new("TextLabel", toggle)
tIcon.Size = UDim2.new(1, 0, 1, 0)
tIcon.BackgroundTransparency = 1
tIcon.Text = "OFF"
tIcon.TextSize = 14
tIcon.TextColor3 = Color3.fromRGB(220, 60, 60)
tIcon.Font = Enum.Font.GothamBold

--- Execution Loop Mechanism ---
local activeThread = nil

local function runExecutionLoop()
    -- Wrap background operations inside a task thread to prevent game freezes
    activeThread = task.spawn(function()
        while _G.cookroomfucker do
            print("DZ HACKER Loop Active...") 
            -- PLACE YOUR AUTOMATION LOGIC ACTIONS DIRECTLY HERE
            
            task.wait(1) -- Safety throttle delay time
        end
    end)
end

local function stopExecutionLoop()
    _G.cookroomfucker = false
    if activeThread then
        -- Force-kill the active task execution stream
        task.cancel(activeThread)
        activeThread = nil
    end
    print("DZ HACKER Loop Halted Completely.")
end

-- Interactive UI State Switching
local function updateVisuals()
    if _G.cookroomfucker then
        tStroke.Color = Color3.fromRGB(0, 220, 100)
        tIcon.TextColor3 = Color3.fromRGB(0, 220, 100)
        tIcon.Text = "ON"
        runExecutionLoop()
    else
        tStroke.Color = Color3.fromRGB(220, 60, 60)
        tIcon.TextColor3 = Color3.fromRGB(220, 60, 60)
        tIcon.Text = "OFF"
        stopExecutionLoop()
    end
end

-- Event Listeners
toggle.MouseButton1Click:Connect(function()
    _G.cookroomfucker = not _G.cookroomfucker
    updateVisuals()
end)

close.MouseButton1Click:Connect(function()
    stopExecutionLoop()
    gui:Destroy()
end)

-- Initialize App State Default
_G.cookroomfucker = false
updateVisuals()
