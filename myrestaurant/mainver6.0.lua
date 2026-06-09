-- =================================================================
--  MY RESTAURANT - HYPER AUTOMATION MOD MENU (ALL-IN-ONE MAX SPEED)
--  MADE BY: DZ HACKER ALSO KNOWN AS DHWANIT ZALA
--  TELEGRAM: t.me/DZHACKER456
--  INSTAGRAM: @dhwanitzala
--  VERSION: v5.3 (0s ANIMATION SKIP & UNIVERSAL SNAP-TELEPORT)
-- =================================================================

if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId ~= 4490140733 then 
    warn("[DZ Hacker] Wrong Game! Please join My Restaurant.")
    return 
end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

print("[DZ Hacker] Initializing Hyper Bypass Engine v5.3...")

-- ============================================================================
-- 1. ADVANCED ANTI-AFK (NO MORE DISCONNECTS)
-- ============================================================================
local VirtualUser = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(0.5)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)
if getconnections then
    for _, v in next, getconnections(Player.Idled) do
        v:Disable()
    end
end

-- ============================================================================
-- 2. SECURE LIBRARY INJECTION (ANTI-CRASH)
-- ============================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Framework = ReplicatedStorage:WaitForChild("Framework", 10)
if not Framework then warn("[DZ Hacker] Error: Game Framework not found.") return end

local LibraryModule = Framework:WaitForChild("Library", 10)
if not LibraryModule then warn("[DZ Hacker] Error: Library not found.") return end

local Library = require(LibraryModule)
assert(Library, "[DZ Hacker] Library failed to load.")
while not Library.Loaded do task.wait() end

local function GetPath(...)
    local path = {...}
    local oldPath = Library
    if path and #path > 0 then
        for _, v in ipairs(path) do oldPath = oldPath[v] end
    end
    return oldPath
end

local Bakery = GetPath("Bakery")
local Customer = GetPath("Customer")
local Food = GetPath("Food")
local Entity = GetPath("Entity")
local Network = GetPath("Network")
local Cook = GetPath("Cook")
local Waiter = GetPath("Waiter")

-- ============================================================================
-- 3. EXPANDED CONFIGURATION SYSTEM (TASK-ISOLATED)
-- ============================================================================
local Config = {
    FastOrder = false, 
    GoldFood = false, 
    ForceVIP = false,
    AutoCelebrity = false, 
    InstantFinish = false, 
    GiveBestFood = false,
    InstantWash = false, 
    MasteryFarm = false, 
    InstantDelivery = false,
    TeleportAll = false, 
    UseRoles = false,
    
    -- Isolated Task Toggles
    GhostCooking = false,
    GhostCleaning = false,
    GhostOrders = false,
    InstantPayment = false,
    
    -- Dynamic ID Customization Value
    CustomCustomerID = "40"
}
-- ============================================================================
-- 4. HYPER NETWORK BYPASS (0s cook/eat wait)
-- ============================================================================
local Original_Invoke = Network.Invoke
Network.Invoke = function(remoteName, ...)
    if Config.FastOrder then
        if remoteName == "WaitForEatTime" or remoteName == "WaitForCookTime" then return true end
    end
    return Original_Invoke(remoteName, ...)
end

-- ============================================================================
-- 5. GOLDEN FOOD INJECTOR
-- ============================================================================
local Original_RandomFoodChoice = Food.RandomFoodChoice
Food.RandomFoodChoice = function(uid, id, rich, pirate, tree)
    if Config.GoldFood or Config.GiveBestFood then
        local spoof = Food.new("45", uid, id, true, true)
        spoof.IsGold = true
        return spoof
    end
    return Original_RandomFoodChoice(uid, id, rich, pirate, tree)
end

-- ============================================================================
-- 6. ULTRA-ADVANCED 0s SNAP-TELEPORT & INSTANT ACTION ENGINE
-- ============================================================================
local Original_WalkToPoint = Entity.WalkToPoint
Entity.WalkToPoint = function(self, x, y, z, callback, ...)
    if Config.TeleportAll then
        if self.model and self.model:FindFirstChild("HumanoidRootPart") then
            local floor = self:GetMyFloor()
            if floor then
                local pos = floor:WorldPositionFromVoxel(x, y, z)
                self.model.HumanoidRootPart.CFrame = CFrame.new(pos) + Vector3.new(0, 2, 0)
                self.xVoxel, self.zVoxel = x, z
                
                -- FORCE STATE UPDATE TO SKIP "THINKING" DELAYS
                if self.SetEntityState then 
                    pcall(function() self:SetEntityState("Walking") end) 
                end
                
                pcall(function() floor:BroadcastNPCPositionChange(self, self.xVoxel, self.zVoxel) end)
                
                -- INSTANT CALLBACK (Forces them to immediately do the next task)
                if callback then task.spawn(callback) end
                return
            end
        end
    end
    return Original_WalkToPoint(self, x, y, z, callback, ...)
end

local Original_WalkThroughWaypoints = Entity.WalkThroughWaypoints
Entity.WalkThroughWaypoints = function(self, voxelpoints, waypoints, ...)
    if Config.TeleportAll and #waypoints > 0 then
        local targetVoxel = voxelpoints[#waypoints]
        local targetWorld = waypoints[#waypoints]
        
        if self.model and self.model:FindFirstChild("HumanoidRootPart") then
            self.model.HumanoidRootPart.CFrame = CFrame.new(targetWorld) + Vector3.new(0, 2, 0)
        end
        if targetVoxel and targetVoxel.x and targetVoxel.y then
            self.xVoxel = targetVoxel.x
            self.zVoxel = targetVoxel.y
        end
        
        -- FORCE STATE SKIP
        if self.SetEntityState then pcall(function() self:SetEntityState("Walking") end) end
        pcall(function() 
            local floor = self:GetMyFloor()
            if floor then floor:BroadcastNPCPositionChange(self, self.xVoxel, self.zVoxel) end
        end)
        
        return
    end
    return Original_WalkThroughWaypoints(self, voxelpoints, waypoints, ...)
end

local Original_WalkToNewFloor = Entity.WalkToNewFloor
Entity.WalkToNewFloor = function(self, floor, callback, ...)
    if Config.TeleportAll then
        -- INSTANT FLOOR TRANSITION (No Elevator/Stairs delay)
        if callback then task.spawn(callback) end
        return
    end
    return Original_WalkToNewFloor(self, floor, callback, ...)
end

-- ============================================================================
-- 6.5 ZERO-DELAY HYPER STATE-BYPASS (FRAME-PERFECT INSTANT ACTION)
-- ============================================================================
local Original_SetEntityState = Entity.SetEntityState
Entity.SetEntityState = function(self, state, ...)
    if Config.TeleportAll or Config.FastOrder then
        
        -- 1. BYPASS WAITER 10s ORDER TAKING (Instant Frame-Perfect Skip)
        if state == "TakingOrder" then
            -- task.defer pushes this to the end of the current frame queue, skipping the 0.1s wait completely!
            task.defer(function()
                if self.SetEntityState then 
                    pcall(function() self:SetEntityState("Idle") end) 
                end
            end)
        end
        
        -- 2. BYPASS DISHWASHER STANDING (Frame-Perfect Walk Away)
        if state == "PuttingDishesInDishwasher" or state == "WalkingToDishwasher" then
            task.defer(function()
                if self.SetEntityState then 
                    pcall(function() self:SetEntityState("Idle") end) 
                end
            end)
        end
        
    end
    return Original_SetEntityState(self, state, ...)
end

-- ============================================================================
-- 8. 0-SECOND CUSTOMER AUTO-SIT & ORDER BYPASS (NO ANIMATION WAIT)
-- ============================================================================
local Original_ChangeToWaitForOrder = Customer.ChangeToWaitForOrderState
Customer.ChangeToWaitForOrderState = function(customer)
    if not Config.FastOrder then return Original_ChangeToWaitForOrder(customer) end
    if customer.state ~= "WalkingToSeat" then return end
    
    local seat = customer:EntityTable()[customer.stateData.seatUID]
    if seat.isDeleted then customer:ForcedToLeave() return end

    -- INSTANT SEAT SNAP (No walking up to it, no chair pulling animation)
    customer.xVoxel, customer.zVoxel = seat.xVoxel, seat.zVoxel
    if customer.model and customer.model:FindFirstChild("HumanoidRootPart") then
        local floor = customer:GetMyFloor()
        if floor then
            local pos = floor:WorldPositionFromVoxel(seat.xVoxel, seat.yVoxel, seat.zVoxel)
            customer.model.HumanoidRootPart.CFrame = CFrame.new(pos) + Vector3.new(0, 2, 0)
        end
    end

    customer:SetCustomerState("ThinkingAboutOrder")
    pcall(function() customer:SitInSeat(seat) end)
    
    -- INSTANTLY DECIDE & REQUEST FOOD (Skips menu reading)
    task.spawn(function()
        if customer.isDeleted then return end
        customer:StopReadingMenu()
        customer:SetCustomerState("DecidedOnOrder")
        customer:ReadyToOrder()
    end)
end

-- ============================================================================
-- 7. 100% CUSTOM TARGET ID OVERRIDE
-- ============================================================================
local Original_AddCustomers = Bakery.AddCustomersToQueueIfNecessary
Bakery.AddCustomersToQueueIfNecessary = function(bakery, kick, UIDBatch)
    if not bakery:IsMyBakery() then 
        return Original_AddCustomers(bakery, kick, UIDBatch) 
    end
    
    if Config.ForceVIP then
        -- Dynamically checks whatever number you type in the text box window
        local targetID = tostring(Config.CustomCustomerID) or "40"
        
        for i, data in pairs(UIDBatch) do
            -- Force EVERY single customer in the batch to match your custom input value
            UIDBatch[i].ID = targetID
        end
    end
    
    local response = table.pack(Original_AddCustomers(bakery, kick, UIDBatch))
    return table.unpack(response, 1, response.n)
end


-- ============================================================================
-- 7.5 HYPER-SERVER AUTOMATION GHOST ENGINE (ISOLATED REMOTE PUMPING)
-- ============================================================================
task.spawn(function()
    while task.wait(0.05) do -- 20Hz high-speed network ticks
        pcall(function()
            local MyBakery = Library.Variables.MyBakery
            if MyBakery and MyBakery.isOpen then
                
                -- Independent Toggle Check for Silent Cooking
                if Config.GhostCooking then
                    pcall(function() Network.Fire("ActivelyPlayingGame_Cooking") end)
                end
                
                -- Independent Toggle Check for Silent Cleaning
                if Config.GhostCleaning then
                    pcall(function() Network.Fire("ActivelyPlayingGame_Cleaning") end)
                end
                
                -- Independent Toggle Check for Silent Order Handshakes
                if Config.GhostOrders then
                    pcall(function() Network.Fire("ActivelyPlayingGame_TookCustomersOrder") end)
                end
                
                -- Combined Progression Trigger
                if Config.MasteryFarm then
                    pcall(function() Network.Fire("AwardBakeryExperienceWithVerification") end)
                end
                
                -- Task-Isolated Instant Table Clearing Logic
                if Config.GhostCleaning or Config.InstantWash then
                    for _, floor in pairs(MyBakery.floors) do
                        for _, customer in pairs(floor:GetEntitiesFromClassAndSubClass("Customer", "Customer")) do
                            if customer.state == "FinishedEating" then
                                pcall(function()
                                    Network.Fire("AwardWaiterExperienceForDeliveringOrderWithVerification", customer.UID)
                                    customer:SetCustomerState("ReadyToPay")
                                end)
                            end
                        end
                    end
                end
                
            end
        end)
    end
end)



-- ============================================================================
-- 8. AUTO-SEAT & INSTANT ARRIVAL ENGINE (NO WAITER NEEDED)
-- ============================================================================
local Original_CustomerState = Customer.SetCustomerState
Customer.SetCustomerState = function(self, state, ...)
    -- 1. IF CUSTOMER IS AT THE ENTRANCE, FORCE THEM TO FIND A SEAT IMMEDIATELY
    if state == "WaitingForWaiter" or state == "EnteringRestaurant" then
        if Config.TeleportAll then
            -- Bypass the waiter-follow check and skip directly to seating
            task.defer(function()
                if self.isDeleted then return end
                
                -- Force the customer to look for a seat directly
                pcall(function()
                    self:SetCustomerState("WalkingToSeat")
                    -- You can trigger your auto-seat logic here if the game has a standard function
                    -- This forces the AI to skip the 'Follow Waiter' pathing
                end)
            end)
            return -- Stop the game from forcing them to wait for a waiter
        end
    end
    
    return Original_CustomerState(self, state, ...)
end



-- ============================================================================
-- 9. AUTOMATION LOOPS (Delivery, Wash, Finish, Farm)
-- ============================================================================
task.spawn(function()
    while task.wait(0.1) do
        -- Instant Finish
        if Config.InstantFinish then
            pcall(function()
                local MyBakery = Library.Variables.MyBakery
                if MyBakery then
                    for _, floor in pairs(MyBakery.floors) do
                        for _, customer in pairs(floor:GetEntitiesFromClassAndSubClass("Customer", "Customer")) do
                            if customer.state == "EatingFood" then customer:SetCustomerState("ReadyToExit") end
                        end
                    end
                end
            end)
        end
        
        -- Instant Wash
        if Config.InstantWash then
            pcall(function()
                local myBakery = Library.Variables.MyBakery
                if myBakery then
                    for _, floor in ipairs(myBakery.floors) do
                        for _, dw in ipairs(floor:GetEntitiesFromClassAndSubClass("Appliance", "Dishwasher")) do
                            if dw.stateData.isWashingDishes then
                                dw.stateData.isWashingDishes = false
                                dw.stateData.numberDishes = 0
                                if dw.stateData.dishwasherUI then dw.stateData.dishwasherUI.Enabled = false end
                            end
                        end
                    end
                end
            end)
        end

        -- Instant Delivery
        if Config.InstantDelivery then
            pcall(function()
                local MyBakery = Library.Variables.MyBakery
                if MyBakery then
                    for _, floor in ipairs(MyBakery.floors) do
                        for _, stand in ipairs(floor:GetEntitiesFromClassAndSubClass("Appliance", "OrderStand")) do
                            if stand.stateData and stand.stateData.foodReadyList and #stand.stateData.foodReadyList > 0 then
                                for i = #stand.stateData.foodReadyList, 1, -1 do
                                    local foodOrder = stand.stateData.foodReadyList[i]
                                    if foodOrder then
                                        local customer = MyBakery.Entities[foodOrder.customerOwnerUID]
                                        if customer and not customer.isDeleted then
                                            table.remove(stand.stateData.foodReadyList, i)
                                            if foodOrder.associatedListItem then foodOrder.associatedListItem:Destroy() end
                                            customer:SetCustomerState("EatingFood")
                                            customer:ChangeToEatingState()
                                            stand:UpdateNotes()
                                            Network.Fire("AwardWaiterExperienceForDeliveringOrderWithVerification", foodOrder.customerOwnerUID)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Mastery Farm Loop
task.spawn(function()
    while task.wait(0.5) do
        if Config.MasteryFarm then
            pcall(function()
                if Library.Variables.MyBakery and Library.Variables.MyBakery.isOpen then
                    Network.Fire("ActivelyPlayingGame_Cooking")
                    Network.Fire("ActivelyPlayingGame_Cleaning")
                    Network.Fire("ActivelyPlayingGame_TookCustomersOrder")
                    Network.Fire("AwardBakeryExperienceWithVerification")
                end
            end)
        end
    end
end)

-- ============================================================================
-- 11. PROFIT-MAX: INSTANT PAYMENT & CLEARANCE (ISOLATED SWITCH)
-- ============================================================================
task.spawn(function()
    while task.wait(0.2) do
        if Config.InstantPayment then
            pcall(function()
                local MyBakery = Library.Variables.MyBakery
                if MyBakery then
                    for _, floor in pairs(MyBakery.floors) do
                        for _, customer in pairs(floor:GetEntitiesFromClassAndSubClass("Customer", "Customer")) do
                            -- Force instant transaction transition
                            if customer.state == "EatingFood" then 
                                pcall(function() customer:SetCustomerState("ReadyToPay") end)
                            end
                            
                            -- Force instant ordering transition
                            if customer.state == "ThinkingAboutOrder" then
                                pcall(function() customer:ReadyToOrder() end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================================
-- 10. ADVANCED UI LOADER (RAYFIELD OVERRIDE v5.6 - DYNAMIC CUSTOMER ID)
-- ============================================================================
print("[DZ Hacker] Loading Rayfield UI...")
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("=========================================================")
    warn("[DZ HACKER ERROR] FAILED TO LOAD UI!")
    warn("Your Executor DOES NOT support loadstring or your internet blocked it.")
    warn("Please enable 'Loadstring' in your Executor settings and try again.")
    warn("=========================================================")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "DZ HACKER v5.6 🚀",
    LoadingTitle = "DZ Hacker Maximum Override",
    LoadingSubtitle = "TG: t.me/DZHACKER456 | IG: @dhwanitzala",
    ConfigurationSaving = { Enabled = false }
})

local Toggles = {}

local FarmTab = Window:CreateTab("Hyper Farm", 4483362458)

-- MAX SPEED BUTTON
FarmTab:CreateSection("⚡ MAX SPEED OVERRIDE ⚡")
FarmTab:CreateButton({
    Name = "🚀 ENABLE ALL MAX SPEED FEATURES 🚀",
    Callback = function()
        local maxFeatures = {
            "Force Golden Food", "Give Best Food", "0s Cook & Eat", 
            "Instant Delivery", "Instant Finish", "Instant Dishwashing", 
            "Mastery Farm", "Universal Teleport (ALL)",
            "Ghost Cooking", "Ghost Cleaning", "Ghost Orders", "Instant Force Payments"
        }
        for _, name in ipairs(maxFeatures) do
            if Toggles[name] then Toggles[name]:Set(true) end
        end
        Rayfield:Notify({
            Title = "MAX SPEED ENGAGED!",
            Content = "All 0s Isolated Engines Active. Ghost farming at full capacity!",
            Duration = 4,
            Image = 4483362458
        })
    end
})

FarmTab:CreateSection("💰 Food & Customer Settings")
Toggles["Force VIP Customers"] = FarmTab:CreateToggle({ Name = "Force Custom Customer Tiers", CurrentValue = Config.ForceVIP, Callback = function(v) Config.ForceVIP = v end })

-- DYNAMIC CUSTOMER ID TEXT BOX INPUT (1 - 50)
FarmTab:CreateInput({
    Name = "Target Customer ID (1 - 50)",
    PlaceholderText = "Type ID here (e.g. 40)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local numericValue = tonumber(Text)
        if numericValue and numericValue >= 1 and numericValue <= 50 then
            Config.CustomCustomerID = tostring(numericValue)
            Rayfield:Notify({
                Title = "Target ID Updated!",
                Content = "Spawning Customer ID Tier: " .. tostring(numericValue),
                Duration = 3,
                Image = 4483362458
            })
        else
            warn("[DZ Hacker] Invalid input selection! Please type a whole number between 1 and 50.")
        end
    end,
})

Toggles["Force Golden Food"] = FarmTab:CreateToggle({ Name = "Force Golden Food", CurrentValue = Config.GoldFood, Callback = function(v) Config.GoldFood = v end })
Toggles["Give Best Food"] = FarmTab:CreateToggle({ Name = "Give Best Food", CurrentValue = Config.GiveBestFood, Callback = function(v) Config.GiveBestFood = v end })
Toggles["0s Cook & Eat"] = FarmTab:CreateToggle({ Name = "0s Cook & Eat Bypasses", CurrentValue = Config.FastOrder, Callback = function(v) Config.FastOrder = v end })

FarmTab:CreateSection("🤖 Ghost Server Exploits (Section 7.5)")
Toggles["Mastery Farm"] = FarmTab:CreateToggle({ Name = "Award Bakery Experience Loop", CurrentValue = Config.MasteryFarm, Callback = function(v) Config.MasteryFarm = v end })
Toggles["Ghost Cooking"] = FarmTab:CreateToggle({ Name = "Auto Ghost Cooking Remote", CurrentValue = Config.GhostCooking, Callback = function(v) Config.GhostCooking = v end })
Toggles["Ghost Cleaning"] = FarmTab:CreateToggle({ Name = "Auto Ghost Table Cleaning", CurrentValue = Config.GhostCleaning, Callback = function(v) Config.GhostCleaning = v end })
Toggles["Ghost Orders"] = FarmTab:CreateToggle({ Name = "Auto Ghost Order Taking", CurrentValue = Config.GhostOrders, Callback = function(v) Config.GhostOrders = v end })
Toggles["Instant Force Payments"] = FarmTab:CreateToggle({ Name = "Instant Force Payments", CurrentValue = Config.InstantPayment, Callback = function(v) Config.InstantPayment = v end })

FarmTab:CreateSection("⚡ Automation Settings")
Toggles["Instant Delivery"] = FarmTab:CreateToggle({ Name = "Instant Food Delivery", CurrentValue = Config.InstantDelivery, Callback = function(v) Config.InstantDelivery = v end })
Toggles["Instant Finish"] = FarmTab:CreateToggle({ Name = "Instant Eat & Leave", CurrentValue = Config.InstantFinish, Callback = function(v) Config.InstantFinish = v end })
Toggles["Instant Dishwashing"] = FarmTab:CreateToggle({ Name = "Instant Auto-Dishwasher Clean", CurrentValue = Config.InstantWash, Callback = function(v) Config.InstantWash = v end })

FarmTab:CreateSection("🏃 Movement & Pathing")
Toggles["Universal Teleport (ALL)"] = FarmTab:CreateToggle({ 
    Name = "Universal Instant Teleportation", 
    CurrentValue = Config.TeleportAll, 
    Callback = function(v) Config.TeleportAll = v end 
})

local InfoTab = Window:CreateTab("Info & Credits", 4483362458)
InfoTab:CreateSection("MADE BY DZ HACKER")
InfoTab:CreateLabel("ALSO KNOWN AS: DHWANIT ZALA")
InfoTab:CreateLabel("TELEGRAM: t.me/DZHACKER456")
InfoTab:CreateLabel("INSTAGRAM: @dhwanitzala")
InfoTab:CreateLabel("VERSION: v5.6 (Dynamic Custom ID Box)")

Rayfield:Notify({ Title = "DZ Hacker Script Loaded", Content = "Welcome Dhwanit Zala. Dynamic ID engine ready.", Duration = 6, Image = 4483362458 })

print("========================================")
print("  MADE BY DZ HACKER (DHWANIT ZALA)")
print("  TELEGRAM: t.me/DZHACKER456")
print("  INSTA: @dhwanitzala")
print("  STATUS: v5.6 Successfully Injected!")
print("========================================")
