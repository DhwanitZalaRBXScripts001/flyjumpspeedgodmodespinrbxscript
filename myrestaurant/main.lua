-- =================================================================
--  MY RESTAURANT - HYPER AUTOMATION MOD MENU (ALL-IN-ONE MAX SPEED)
--  MADE BY: DZ HACKER ALSO KNOWN AS DHWANIT ZALA
--  TELEGRAM: t.me/DZHACKER456
--  INSTAGRAM: @dhwanitzala
-- =================================================================

if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId ~= 4490140733 then return end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- ============================================================================
-- ANTI-AFK (HARDWARE LEVEL)
-- ============================================================================
Player.Idled:Connect(function()
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(0.5)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = require(ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
assert(Library, "Library fail to load.")
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
-- CONFIGURATION SYSTEM
-- ============================================================================
local ConfigFolder = "DZHacker_Config"
local ConfigFile = ConfigFolder.."/config.txt"

local Config = {
    FastOrder = false,
    GoldFood = false,
    ForceVIP = false,
    AutoCelebrity = false,
    InstantFinish = false,
    GiveBestFood = false,
    InstantWash = false,
    MasteryFarm = false,
    AutoInteract = false,
    InstantDelivery = false,
    InfExperience = false,
    AntiPace = false,
    AutoDailyReward = false,
    AutoFireplace = false,
    AutoRefillCandy = false,
    AutoShrine = false,
    AutoSlotMachine = false,
    AutoUseWell = false,
    BlacklistEveryone = false,
    AutoBuyWorkers = false,
    AutoBuyChefs = true,
    AutoBuyWaiters = true,
    TeleportWorkers = false,
    FastNPCs = false,
    NPCSpeed = 100,
    UseRoles = false, -- The 10/20/50/20 Waiter Split System
    WalkSpeedSpoof = false,
    SpoofedSpeed = 16
}

if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

function SaveConfig()
    pcall(function() writefile(ConfigFile, HttpService:JSONEncode(Config)) end)
end

-- ============================================================================
-- HYPER NETWORK BYPASS (0s cook/eat wait)
-- ============================================================================
local Original_Invoke = Network.Invoke
Network.Invoke = function(remoteName, ...)
    if Config.FastOrder then
        if remoteName == "WaitForEatTime" or remoteName == "WaitForCookTime" then return true end
    end
    return Original_Invoke(remoteName, ...)
end

-- ============================================================================
-- GOLDEN FOOD INJECTOR
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
-- ZERO-SECOND TELEPORT ENGINE (Workers Flash Instantly)
-- ============================================================================
local Original_WalkToPoint = Entity.WalkToPoint
Entity.WalkToPoint = function(self, x, y, z, callback, ...)
    if Config.TeleportWorkers and self:BelongsToMyBakery() then
        if self.model and self.model:FindFirstChild("HumanoidRootPart") then
            local floor = self:GetMyFloor()
            if floor then
                local pos = floor:WorldPositionFromVoxel(x, y, z)
                self.model.HumanoidRootPart.CFrame = CFrame.new(pos) + Vector3.new(0, 2, 0)
                self.xVoxel = x
                self.zVoxel = z
                pcall(function() floor:BroadcastNPCPositionChange(self, self.xVoxel, self.zVoxel) end)
                if callback then task.spawn(callback) end
                return
            end
        end
    end
    return Original_WalkToPoint(self, x, y, z, callback, ...)
end

local Original_WalkToNewFloor = Entity.WalkToNewFloor
Entity.WalkToNewFloor = function(self, floor, callback, ...)
    if Config.TeleportWorkers and self:BelongsToMyBakery() then
        if callback then task.spawn(callback) end
        return
    end
    return Original_WalkToNewFloor(self, floor, callback, ...)
end

local Original_WalkThroughWaypoints = Entity.WalkThroughWaypoints
Entity.WalkThroughWaypoints = function(self, voxelpoints, waypoints, u1, u2)
    if self:BelongsToMyBakery() then
        if Config.TeleportWorkers and #waypoints > 0 then
            local wayPoint = waypoints[#waypoints]
            local voxelPoint = voxelpoints[#waypoints]
            if wayPoint and voxelPoint and voxelPoint.x and voxelPoint.y then
                if self.model and self.model:FindFirstChild("HumanoidRootPart") then
                    self.model.HumanoidRootPart.CFrame = CFrame.new(wayPoint) * CFrame.new(0, 2, 0)
                end
                self.xVoxel, self.zVoxel = voxelPoint.x, voxelPoint.y
            end
            return
        elseif Config.FastNPCs and self.humanoid then
            self.humanoid.WalkSpeed = Config.NPCSpeed
        end
    end
    return Original_WalkThroughWaypoints(self, voxelpoints, waypoints, u1, u2)
end

-- ============================================================================
-- WAITER SPLIT SYSTEM (10% Entry, 20% Order, 50% Serve, 20% Plates)
-- ============================================================================
local function GetWaiterRole(waiter)
    local myBakery = Library.Variables.MyBakery
    if not myBakery then return "All" end
    local waiters = myBakery:GetAllOfClassName("Waiter")
    if not waiters or #waiters < 4 then return "All" end -- Need at least 4 waiters to split properly

    local sortedWaiters = {}
    for _, w in pairs(waiters) do table.insert(sortedWaiters, w) end
    table.sort(sortedWaiters, function(a, b) return a.UID < b.UID end)

    local index = 1
    for i, w in ipairs(sortedWaiters) do
        if w.UID == waiter.UID then
            index = i
            break
        end
    end

    local percentile = index / #sortedWaiters
    if percentile <= 0.10 then return "Greeter"
    elseif percentile <= 0.30 then return "OrderTaker"
    elseif percentile <= 0.80 then return "Server"
    else return "Cleaner" end
end

local Original_CheckQueued = Waiter.CheckForQueuedCustomers
Waiter.CheckForQueuedCustomers = function(self)
    if Config.UseRoles and GetWaiterRole(self) ~= "Greeter" and GetWaiterRole(self) ~= "All" then return false end
    return Original_CheckQueued(self)
end

local Original_CheckOrder = Waiter.CheckForCustomerOrder
Waiter.CheckForCustomerOrder = function(self)
    if Config.UseRoles and GetWaiterRole(self) ~= "OrderTaker" and GetWaiterRole(self) ~= "All" then return false end
    return Original_CheckOrder(self)
end

local Original_CheckDelivery = Waiter.CheckForFoodDelivery
Waiter.CheckForFoodDelivery = function(self)
    if Config.UseRoles and GetWaiterRole(self) ~= "Server" and GetWaiterRole(self) ~= "All" then return false end
    return Original_CheckDelivery(self)
end

local Original_CheckDish = Waiter.CheckForDishPickup
Waiter.CheckForDishPickup = function(self)
    if Config.UseRoles and GetWaiterRole(self) ~= "Cleaner" and GetWaiterRole(self) ~= "All" then return false end
    return Original_CheckDish(self)
end

-- ============================================================================
-- FORCE VIP CUSTOMERS
-- ============================================================================
local Original_AddCustomers = Bakery.AddCustomersToQueueIfNecessary
Bakery.AddCustomersToQueueIfNecessary = function(bakery, kick, UIDBatch)
    if not bakery:IsMyBakery() then return Original_AddCustomers(bakery, kick, UIDBatch) end
    
    if Config.ForceVIP then
        local targetIDs = {'38','30','35','26','34','37','33','33','32','22','27','29','13','31'}
        for i, data in pairs(UIDBatch) do
            if data.ID ~= '14' and data.ID ~= '20' and data.ID ~= '38' then
                UIDBatch[i].ID = targetIDs[math.random(#targetIDs)]
            end
        end
    end
    
    local response = table.pack(Original_AddCustomers(bakery, kick, UIDBatch))
    return table.unpack(response, 1, response.n)
end

-- ============================================================================
-- HYPER FAST ORDERING
-- ============================================================================
local Original_ChangeToWaitForOrder = Customer.ChangeToWaitForOrderState
Customer.ChangeToWaitForOrderState = function(customer)
    if not Config.FastOrder then return Original_ChangeToWaitForOrder(customer) end
    if customer.state ~= "WalkingToSeat" then return end

    local seat = customer:EntityTable()[customer.stateData.seatUID]
    if seat.isDeleted then customer:ForcedToLeave() return end

    customer:SetCustomerState("ThinkingAboutOrder")
    customer:SitInSeat(seat).Completed:Connect(function()
        customer.xVoxel, customer.zVoxel = seat.xVoxel, seat.zVoxel
        task.spawn(function()
            task.wait()
            if customer.isDeleted then return end
            customer:StopReadingMenu()
            customer:SetCustomerState("DecidedOnOrder")
            customer:ReadyToOrder()
        end)
    end)
end

-- ============================================================================
-- INSTANT STATE RESOLVER (FINISH)
-- ============================================================================
task.spawn(function()
    while task.wait(0.1) do
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
    end
end)

-- ============================================================================
-- INSTANT DELIVERY FORCE (ZERO DELAY)
-- ============================================================================
task.spawn(function()
    while true do
        task.wait()
        if Config.InstantDelivery then
            pcall(function()
                local MyBakery = Library.Variables.MyBakery
                if MyBakery then
                    for _, floor in ipairs(MyBakery.floors) do
                        local orderStands = floor:GetEntitiesFromClassAndSubClass("Appliance", "OrderStand")
                        for _, stand in ipairs(orderStands) do
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

-- ============================================================================
-- AUTO CELEBRITY
-- ============================================================================
task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoCelebrity then
            pcall(function()
                local MyBakery = Library.Variables.MyBakery
                if MyBakery then
                    for _, floor in pairs(MyBakery.floors) do
                        for _, entity in pairs(floor:GetEntitiesFromClassAndSubClass("Customer", "Celebrity Customer")) do
                            if entity.state == "ThinkingAboutOrder" then
                                Network.Fire("ActivelyPlayingGame_TookCustomersOrder", entity.UID)
                                entity:SetCustomerState("WaitingForFood")
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================================
-- INSTANT DISHWASHING
-- ============================================================================
task.spawn(function()
    while task.wait(0.1) do
        if Config.InstantWash then
            pcall(function()
                local myBakery = Library.Variables.MyBakery
                if myBakery then
                    for _, floor in ipairs(myBakery.floors) do
                        local dishwashers = floor:GetEntitiesFromClassAndSubClass("Appliance", "Dishwasher")
                        for _, dw in ipairs(dishwashers) do
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
    end
end)

-- ============================================================================
-- BACKGROUND MASTERY FARM
-- ============================================================================
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
-- RAYFIELD UI INTERFACE
-- ============================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "DZ HACKER v5.0 🚀",
    LoadingTitle = "DZ Hacker Maximum Override",
    LoadingSubtitle = "TG: t.me/DZHACKER456 | IG: @dhwanitzala",
    ConfigurationSaving = { Enabled = false }
})

local Toggles = {}
local Sliders = {}

local FarmTab = Window:CreateTab("Hyper Farm", 4483362458)

-- MAX SPEED BUTTON
FarmTab:CreateSection("⚡ MAX SPEED OVERRIDE ⚡")
FarmTab:CreateButton({
    Name = "🚀 ENABLE ALL MAX SPEED FEATURES 🚀",
    Callback = function()
        local maxFeatures = {
            "Force Golden Food", "Give Best Food", "Force VIP Customers",
            "0s Cook & Eat", "Instant Delivery", "Instant Finish",
            "Auto-Celebrity", "Instant Dishwashing", "Mastery Farm", "Instant Teleport"
        }
        for _, name in ipairs(maxFeatures) do
            if Toggles[name] then Toggles[name]:Set(true) end
        end
        if Sliders["Worker Speed"] then Sliders["Worker Speed"]:Set(300) end
        
        Rayfield:Notify({
            Title = "MAX SPEED ENGAGED!",
            Content = "All limits removed. Running at Maximum Speed!",
            Duration = 4,
            Image = 4483362458
        })
    end
})

FarmTab:CreateSection("💰 Farming")
Toggles["Force Golden Food"] = FarmTab:CreateToggle({ Name = "Force Golden Food", CurrentValue = Config.GoldFood, Callback = function(v) Config.GoldFood = v end })
Toggles["Give Best Food"] = FarmTab:CreateToggle({ Name = "Give Best Food", CurrentValue = Config.GiveBestFood, Callback = function(v) Config.GiveBestFood = v end })
Toggles["Force VIP Customers"] = FarmTab:CreateToggle({ Name = "Force VIP Customers", CurrentValue = Config.ForceVIP, Callback = function(v) Config.ForceVIP = v end })
Toggles["0s Cook & Eat"] = FarmTab:CreateToggle({ Name = "0s Cook & Eat", CurrentValue = Config.FastOrder, Callback = function(v) Config.FastOrder = v end })
Toggles["Instant Delivery"] = FarmTab:CreateToggle({ Name = "Instant Delivery", CurrentValue = Config.InstantDelivery, Callback = function(v) Config.InstantDelivery = v end })
Toggles["Instant Finish"] = FarmTab:CreateToggle({ Name = "Instant Finish", CurrentValue = Config.InstantFinish, Callback = function(v) Config.InstantFinish = v end })
Toggles["Auto-Celebrity"] = FarmTab:CreateToggle({ Name = "Auto-Celebrity", CurrentValue = Config.AutoCelebrity, Callback = function(v) Config.AutoCelebrity = v end })
Toggles["Instant Dishwashing"] = FarmTab:CreateToggle({ Name = "Instant Dishwashing", CurrentValue = Config.InstantWash, Callback = function(v) Config.InstantWash = v end })
Toggles["Mastery Farm"] = FarmTab:CreateToggle({ Name = "Mastery Farm", CurrentValue = Config.MasteryFarm, Callback = function(v) Config.MasteryFarm = v end })

FarmTab:CreateSection("🤖 Waiter AI & Split")
Toggles["Waiter Roles"] = FarmTab:CreateToggle({
    Name = "Strict Waiter Roles (10/20/50/20 Split)",
    CurrentValue = Config.UseRoles,
    Callback = function(v) 
        Config.UseRoles = v 
        if v then
            Rayfield:Notify({Title="Waiter Split Active", Content="10% Greeters, 20% Orders, 50% Servers, 20% Cleaners", Duration=3})
        end
    end
})

FarmTab:CreateSection("⚡ Worker Movement")
Toggles["Instant Teleport"] = FarmTab:CreateToggle({ Name = "Instant Teleport", CurrentValue = Config.TeleportWorkers, Callback = function(v) Config.TeleportWorkers = v end })
Toggles["Custom Walkspeed"] = FarmTab:CreateToggle({ Name = "Custom Walkspeed", CurrentValue = Config.FastNPCs, Callback = function(v) Config.FastNPCs = v end })
Sliders["Worker Speed"] = FarmTab:CreateSlider({ Name = "Worker Speed", Range = {16, 300}, Increment = 5, CurrentValue = Config.NPCSpeed, Callback = function(v) Config.NPCSpeed = v end })

local InfoTab = Window:CreateTab("Info & Credits", 4483362458)
InfoTab:CreateSection("MADE BY DZ HACKER")
InfoTab:CreateLabel("ALSO KNOWN AS: DHWANIT ZALA")
InfoTab:CreateLabel("TELEGRAM: t.me/DZHACKER456")
InfoTab:CreateLabel("INSTAGRAM: @dhwanitzala")
InfoTab:CreateLabel("VERSION: v5.0 Ultimate Engine")

Rayfield:Notify({ Title = "DZ Hacker Script Loaded", Content = "Welcome Dhwanit Zala. Engine active.", Duration = 6, Image = 4483362458 })

print("========================================")
print("  MADE BY DZ HACKER (DHWANIT ZALA)")
print("  TELEGRAM: t.me/DZHACKER456")
print("  INSTA: @dhwanitzala")
print("========================================")
