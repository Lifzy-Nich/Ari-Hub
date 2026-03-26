-- ============================================
-- PART 1: HEADER & ANTI-CHEAT
-- INFINITY YIELD ULTIMATE v2.1
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local espEnabled = false
local espObjects = {}
local godModeEnabled = false
local antiStunEnabled = false
local speedEnabled = false
local noClipEnabled = false
local currentSpeed = 50
local savedData = {points = {}, settings = {}}
local fileName = "InfinityYield.json"
local godModeConnections = {}
local antiStunLoop = nil
local speedLoop = nil
local noClipLoop = nil

print("✅ PART 1 LOADED - Variables & Anti-Cheat Ready")
-- ============================================
-- PART 2: ANTI-CHEAT SYSTEM
-- ============================================

local function hideExploit()
    pcall(function()
        if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
            local fake = Instance.new("ScreenGui")
            fake.Name = "RobloxPromptGui"
            fake.Parent = game:GetService("CoreGui")
        end
    end)
    
    pcall(function()
        local console = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
        if console then
            for _, v in pairs(console:GetChildren()) do
                if v:IsA("Frame") and (v.Name == "Console" or v.Name == "DeveloperConsole") then
                    v:Destroy()
                end
            end
        end
    end)
end

local function detectAndDestroyAntiCheat()
    local antiCheatNames = {"AntiCheat", "AC", "Security", "Protection", "Admin", "Ban", "Check", "Monitor"}
    local remoteNames = {"Anti", "Cheat", "Ban", "Kick", "Report", "Log"}
    
    pcall(function()
        for _, v in pairs(workspace:GetChildren()) do
            for _, name in pairs(antiCheatNames) do
                if v.Name and string.find(v.Name, name) then
                    v:Destroy()
                end
            end
        end
    end)
    
    pcall(function()
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            for _, name in pairs(antiCheatNames) do
                if v.Name and string.find(v.Name, name) then
                    v:Destroy()
                end
            end
        end
    end)
    
    pcall(function()
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                for _, name in pairs(remoteNames) do
                    if v.Name and string.find(v.Name, name) then
                        v:Destroy()
                    end
                end
            end
        end
    end)
end

local function startAntiCheat()
    pcall(function()
        hideExploit()
        detectAndDestroyAntiCheat()
    end)
    
    spawn(function()
        while wait(15) do
            pcall(function() detectAndDestroyAntiCheat() end)
        end
    end)
    print("🛡️ Anti-Cheat Active")
end

print("✅ PART 2 LOADED - Anti-Cheat System Ready")
-- ============================================
-- PART 3: SAVE & LOAD SYSTEM
-- ============================================

local function loadData()
    local success, data = pcall(function()
        if isfile and isfile(fileName) then
            return readfile(fileName)
        end
        return nil
    end)
    
    if success and data then
        local decoded = game:GetService("HttpService"):JSONDecode(data)
        if decoded then
            savedData = decoded
            if not savedData.points then savedData.points = {} end
            if not savedData.settings then savedData.settings = {} end
            currentSpeed = savedData.settings.speed or 50
            print("📁 Loaded: " .. #savedData.points .. " points")
            return
        end
    end
    savedData = {points = {}, settings = {speed = 50}}
    currentSpeed = 50
    print("📁 New data file created")
end

local function saveData()
    savedData.settings.speed = currentSpeed
    local encoded = game:GetService("HttpService"):JSONEncode(savedData)
    pcall(function()
        if writefile then
            writefile(fileName, encoded)
        end
    end)
end

print("✅ PART 3 LOADED - Save/Load System Ready")
-- ============================================
-- PART 4: GOD MODE SYSTEM (INVINCIBLE)
-- ============================================

local function destroyConnections()
    for _, conn in pairs(godModeConnections) do
        pcall(function() conn:Disconnect() end)
    end
    godModeConnections = {}
end

local function startGodMode()
    destroyConnections()
    
    local healthConn = RunService.RenderStepped:Connect(function()
        if not godModeEnabled then return end
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                if humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
                humanoid.BreakJointsOnDeath = false
                pcall(function()
                    humanoid.MaxHealth = 9e9
                    humanoid.Health = 9e9
                end)
            end
        end
    end)
    table.insert(godModeConnections, healthConn)
    
    local damageConn = RunService.RenderStepped:Connect(function()
        if not godModeEnabled then return end
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                    end)
                end
            end
        end
    end)
    table.insert(godModeConnections, damageConn)
    
    local killConn = RunService.RenderStepped:Connect(function()
        if not godModeEnabled then return end
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.BreakJointsOnDeath = false
            end
        end
    end)
    table.insert(godModeConnections, killConn)
    
    local envConn = RunService.RenderStepped:Connect(function()
        if not godModeEnabled then return end
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                if rootPart.Position.Y < -100 then
                    rootPart.CFrame = CFrame.new(0, 50, 0)
                end
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end
    end)
    table.insert(godModeConnections, envConn)
    
    local anchorConn = RunService.RenderStepped:Connect(function()
        if not godModeEnabled then return end
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart and rootPart.Anchored then
                rootPart.Anchored = false
            end
        end
    end)
    table.insert(godModeConnections, anchorConn)
    
    print("🛡️ GOD MODE ACTIVE")
end

local function stopGodMode()
    destroyConnections()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.MaxHealth = 100
                humanoid.Health = 100
                humanoid.BreakJointsOnDeath = true
            end)
        end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0.5, 0.5)
                end)
            end
        end
    end
    print("❌ GOD MODE OFF")
end

local function toggleGodMode()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        startGodMode()
    else
        stopGodMode()
    end
end

print("✅ PART 4 LOADED - God Mode Ready")
-- ============================================
-- PART 5: ANTI STUN & SPEED SYSTEM
-- ============================================

local function startAntiStun()
    if antiStunLoop then antiStunLoop:Disconnect() end
    antiStunLoop = RunService.RenderStepped:Connect(function()
        if not antiStunEnabled then return end
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local state = humanoid:GetState()
                if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.GettingUp then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
                if speedEnabled and humanoid.WalkSpeed ~= currentSpeed then
                    humanoid.WalkSpeed = currentSpeed
                end
            end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart and rootPart.AssemblyLinearVelocity.Y < -30 then
                rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, 0, rootPart.AssemblyLinearVelocity.Z)
            end
        end
    end)
end

local function toggleAntiStun()
    antiStunEnabled = not antiStunEnabled
    if antiStunEnabled then
        startAntiStun()
        print("⚡ Anti Stun ON")
    else
        if antiStunLoop then antiStunLoop:Disconnect() antiStunLoop = nil end
        print("❌ Anti Stun OFF")
    end
end

local function applySpeed()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = currentSpeed end
    end
end

local function startSpeedLoop()
    if speedLoop then speedLoop:Disconnect() end
    speedLoop = RunService.RenderStepped:Connect(function()
        if speedEnabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= currentSpeed then
                humanoid.WalkSpeed = currentSpeed
            end
        end
    end)
end

local function setSpeed(value)
    currentSpeed = math.clamp(value, 1, 1000)
    saveData()
    if speedEnabled then applySpeed() end
end

local function toggleSpeed()
    speedEnabled = not speedEnabled
    if speedEnabled then
        applySpeed()
        startSpeedLoop()
        print("⚡ Speed ON: " .. currentSpeed)
    else
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
        if speedLoop then speedLoop:Disconnect() speedLoop = nil end
        print("❌ Speed OFF")
    end
end

print("✅ PART 5 LOADED - Anti Stun & Speed Ready")
-- ============================================
-- PART 6: NO CLIP & ESP SYSTEM
-- ============================================

local function applyNoClip()
    local character = LocalPlayer.Character
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noClipEnabled
        end
    end
end

local function startNoClipLoop()
    if noClipLoop then noClipLoop:Disconnect() end
    noClipLoop = RunService.RenderStepped:Connect(function()
        if noClipEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function toggleNoClip()
    noClipEnabled = not noClipEnabled
    if noClipEnabled then
        applyNoClip()
        startNoClipLoop()
        print("🧱 No Clip ON")
    else
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        if noClipLoop then noClipLoop:Disconnect() noClipLoop = nil end
        print("❌ No Clip OFF")
    end
end

local function createESP(player)
    if not espEnabled then return end
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then
        player.CharacterAdded:Wait()
        character = player.Character
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if espObjects[player] then
        pcall(function()
            if espObjects[player].billboard then espObjects[player].billboard:Destroy() end
            if espObjects[player].highlight then espObjects[player].highlight:Destroy() end
            if espObjects[player].connection then espObjects[player].connection:Disconnect() end
        end)
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 100, 0, 32)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    
    local bg = Instance.new("Frame")
    bg.Parent = billboard
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.BorderSizePixel = 0
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    nameLabel.TextSize = 9
    nameLabel.Font = Enum.Font.GothamBold
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Parent = billboard
    distanceLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.6, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0"
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextSize = 7
    
    billboard.Parent = humanoidRootPart
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight_" .. player.Name
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 215, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 215, 0)
    highlight.OutlineTransparency = 0.4
    highlight.Parent = character
    
    espObjects[player] = {billboard = billboard, highlight = highlight, distanceLabel = distanceLabel, nameLabel = nameLabel}
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not espEnabled or not player.Parent or not LocalPlayer.Character then
            if connection then connection:Disconnect() end
            return
        end
        local char = LocalPlayer.Character
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart and humanoidRootPart and humanoidRootPart.Parent then
            local distance = (humanoidRootPart.Position - rootPart.Position).Magnitude
            distanceLabel.Text = string.format("%.0f", distance)
            if distance < 50 then
                nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
            elseif distance < 150 then
                nameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                highlight.FillColor = Color3.fromRGB(255, 100, 0)
            else
                nameLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
            end
        end
    end)
    espObjects[player].connection = connection
end

local function removeESP(player)
    if espObjects[player] then
        pcall(function()
            if espObjects[player].billboard then espObjects[player].billboard:Destroy() end
            if espObjects[player].highlight then espObjects[player].highlight:Destroy() end
            if espObjects[player].connection then espObjects[player].connection:Disconnect() end
        end)
        espObjects[player] = nil
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then createESP(player) end
        end
        print("✅ ESP ON")
    else
        for _, player in pairs(Players:GetPlayers()) do removeESP(player) end
        print("❌ ESP OFF")
    end
end

print("✅ PART 6 LOADED - No Clip & ESP Ready")
-- ============================================
-- PART 7: TELEPORT SYSTEM
-- ============================================

local function teleportToPosition(pos)
    local character = LocalPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return false end
    rootPart.CFrame = CFrame.new(pos)
    humanoid:MoveTo(pos)
    return true
end

local function teleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    return teleportToPosition(targetRoot.Position + Vector3.new(0, 3, 0))
end

local function saveTeleportPoint(name)
    local character = LocalPlayer.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    table.insert(savedData.points, {
        name = name,
        x = rootPart.Position.X,
        y = rootPart.Position.Y,
        z = rootPart.Position.Z,
        time = os.date("%H:%M")
    })
    saveData()
    print("📍 Saved: " .. name)
    return true
end

local function teleportToSavedPoint(index)
    if not savedData.points[index] then return false end
    local point = savedData.points[index]
    return teleportToPosition(Vector3.new(point.x, point.y, point.z))
end

local function deleteTeleportPoint(index)
    if savedData.points[index] then
        local name = savedData.points[index].name
        table.remove(savedData.points, index)
        saveData()
        print("🗑️ Deleted: " .. name)
        return true
    end
    return false
end

local function getPlayerList()
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player)
        end
    end
    return players
end

print("✅ PART 7 LOADED - Teleport System Ready")
-- ============================================
-- PART 8: UI HEADER & TAB BUTTONS
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InfinityYield"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 180, 0, 200)
mainFrame.Position = UDim2.new(0, 8, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local header = Instance.new("Frame")
header.Parent = mainFrame
header.Size = UDim2.new(1, 0, 0, 26)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
header.BorderSizePixel = 0

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Parent = header
title.Size = UDim2.new(1, -55, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "∞ YIELD"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = header
minimizeBtn.Size = UDim2.new(0, 22, 1, 0)
minimizeBtn.Position = UDim2.new(1, -48, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
minimizeBtn.TextSize = 14

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 4)
minCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = header
closeBtn.Size = UDim2.new(0, 22, 1, 0)
closeBtn.Position = UDim2.new(1, -24, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
closeBtn.TextSize = 10

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

local tabFrame = Instance.new("Frame")
tabFrame.Parent = mainFrame
tabFrame.Size = UDim2.new(1, 0, 0, 26)
tabFrame.Position = UDim2.new(0, 0, 0, 26)
tabFrame.BackgroundTransparency = 1

local tabs = {"MAIN", "TP"}
local tabButtons = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Parent = tabFrame
    btn.Size = UDim2.new(0.5, 0, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.5, 0, 0, 0)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(20, 20, 25)
    btn.BorderSizePixel = 0
    btn.Text = tabName
    btn.TextColor3 = i == 1 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    tabButtons[tabName] = btn
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
end

local container = Instance.new("Frame")
container.Parent = mainFrame
container.Size = UDim2.new(1, -10, 1, -62)
container.Position = UDim2.new(0, 5, 0, 54)
container.BackgroundTransparency = 1

print("✅ PART 8 LOADED - UI Header Ready")
-- ============================================
-- PART 9: MAIN PANEL BUTTONS
-- ============================================

local mainPanel = Instance.new("Frame")
mainPanel.Parent = container
mainPanel.Size = UDim2.new(1, 0, 1, 0)
mainPanel.BackgroundTransparency = 1

local espBtn = Instance.new("TextButton")
espBtn.Parent = mainPanel
espBtn.Size = UDim2.new(1, 0, 0, 28)
espBtn.Position = UDim2.new(0, 0, 0, 0)
espBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
espBtn.BorderSizePixel = 0
espBtn.Text = "🔍 ESP"
espBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
espBtn.TextSize = 10
local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 5)
espCorner.Parent = espBtn

local godBtn = Instance.new("TextButton")
godBtn.Parent = mainPanel
godBtn.Size = UDim2.new(1, 0, 0, 28)
godBtn.Position = UDim2.new(0, 0, 0, 32)
godBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
godBtn.BorderSizePixel = 0
godBtn.Text = "🛡️ GOD MODE"
godBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
godBtn.TextSize = 10
local godCorner = Instance.new("UICorner")
godCorner.CornerRadius = UDim.new(0, 5)
godCorner.Parent = godBtn

local stunBtn = Instance.new("TextButton")
stunBtn.Parent = mainPanel
stunBtn.Size = UDim2.new(1, 0, 0, 28)
stunBtn.Position = UDim2.new(0, 0, 0, 64)
stunBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
stunBtn.BorderSizePixel = 0
stunBtn.Text = "⚡ ANTI STUN"
stunBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
stunBtn.TextSize = 10
local stunCorner = Instance.new("UICorner")
stunCorner.CornerRadius = UDim.new(0, 5)
stunCorner.Parent = stunBtn

local speedBtn = Instance.new("TextButton")
speedBtn.Parent = mainPanel
speedBtn.Size = UDim2.new(1, 0, 0, 28)
speedBtn.Position = UDim2.new(0, 0, 0, 96)
speedBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
speedBtn.BorderSizePixel = 0
speedBtn.Text = "⚡ SPEED: " .. currentSpeed
speedBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
speedBtn.TextSize = 9
local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 5)
speedCorner.Parent = speedBtn

local sliderBg = Instance.new("Frame")
sliderBg.Parent = mainPanel
sliderBg.Size = UDim2.new(1, 0, 0, 3)
sliderBg.Position = UDim2.new(0, 0, 0, 128)
sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
sliderBg.BorderSizePixel = 0
local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Parent = sliderBg
sliderFill.Size = UDim2.new(currentSpeed / 1000, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
sliderFill.BorderSizePixel = 0

local noclipBtn = Instance.new("TextButton")
noclipBtn.Parent = mainPanel
noclipBtn.Size = UDim2.new(1, 0, 0, 28)
noclipBtn.Position = UDim2.new(0, 0, 0, 135)
noclipBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
noclipBtn.BorderSizePixel = 0
noclipBtn.Text = "🧱 NO CLIP"
noclipBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
noclipBtn.TextSize = 10
local noclipCorner = Instance.new("UICorner")
noclipCorner.CornerRadius = UDim.new(0, 5)
noclipCorner.Parent = noclipBtn

print("✅ PART 9 LOADED - Main Panel Ready")
-- ============================================
-- PART 10: TELEPORT PANEL & BUTTON FUNCTIONS
-- ============================================

local tpPanel = Instance.new("Frame")
tpPanel.Parent = container
tpPanel.Size = UDim2.new(1, 0, 1, 0)
tpPanel.BackgroundTransparency = 1
tpPanel.Visible = false

local saveInput = Instance.new("TextBox")
saveInput.Parent = tpPanel
saveInput.Size = UDim2.new(1, 0, 0, 26)
saveInput.Position = UDim2.new(0, 0, 0, 0)
saveInput.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
saveInput.BorderSizePixel = 0
saveInput.PlaceholderText = "Point name"
saveInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
saveInput.TextColor3 = Color3.fromRGB(255, 255, 255)
saveInput.TextSize = 8
local saveInputCorner = Instance.new("UICorner")
saveInputCorner.CornerRadius = UDim.new(0, 4)
saveInputCorner.Parent = saveInput

local saveBtn = Instance.new("TextButton")
saveBtn.Parent = tpPanel
saveBtn.Size = UDim2.new(1, 0, 0, 26)
saveBtn.Position = UDim2.new(0, 0, 0, 30)
saveBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
saveBtn.BorderSizePixel = 0
saveBtn.Text = "💾 SAVE"
saveBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
saveBtn.TextSize = 8
local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 4)
saveCorner.Parent = saveBtn

local pointsTitle = Instance.new("TextLabel")
pointsTitle.Parent = tpPanel
pointsTitle.Size = UDim2.new(1, 0, 0, 18)
pointsTitle.Position = UDim2.new(0, 0, 0, 60)
pointsTitle.BackgroundTransparency = 1
pointsTitle.Text = "SAVED"
pointsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
pointsTitle.TextSize = 8

local pointsScroll = Instance.new("ScrollingFrame")
pointsScroll.Parent = tpPanel
pointsScroll.Size = UDim2.new(1, 0, 0, 60)
pointsScroll.Position = UDim2.new(0, 0, 0, 78)
pointsScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
pointsScroll.BackgroundTransparency = 0.5
pointsScroll.BorderSizePixel = 0
pointsScroll.ScrollBarThickness = 2
local pointsCorner = Instance.new("UICorner")
pointsCorner.CornerRadius = UDim.new(0, 4)
pointsCorner.Parent = pointsScroll

local playerTitle = Instance.new("TextLabel")
playerTitle.Parent = tpPanel
playerTitle.Size = UDim2.new(1, 0, 0, 18)
playerTitle.Position = UDim2.new(0, 0, 1, -48)
playerTitle.BackgroundTransparency = 1
playerTitle.Text = "PLAYERS"
playerTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
playerTitle.TextSize = 8

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Parent = tpPanel
playerScroll.Size = UDim2.new(1, 0, 0, 45)
playerScroll.Position = UDim2.new(0, 0, 1, -28)
playerScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
playerScroll.BackgroundTransparency = 0.5
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 2
local playerCorner = Instance.new("UICorner")
playerCorner.CornerRadius = UDim.new(0, 4)
playerCorner.Parent = playerScroll

local function refreshPointsList()
    for _, child in pairs(pointsScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local yPos = 2
    for i, point in ipairs(savedData.points) do
        local item = Instance.new("Frame")
        item.Parent = pointsScroll
        item.Size = UDim2.new(1, -6, 0, 32)
        item.Position = UDim2.new(0, 3, 0, yPos)
        item.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        item.BorderSizePixel = 0
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 3)
        itemCorner.Parent = item
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = item
        nameLabel.Size = UDim2.new(1, -55, 0, 16)
        nameLabel.Position = UDim2.new(0, 5, 0, 2)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = point.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        nameLabel.TextSize = 7
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        local tpBtn = Instance.new("TextButton")
        tpBtn.Parent = item
        tpBtn.Size = UDim2.new(0, 35, 0, 20)
        tpBtn.Position = UDim2.new(1, -40, 0, 2)
        tpBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        tpBtn.BorderSizePixel = 0
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        tpBtn.TextSize = 7
        local tpCorner = Instance.new("UICorner")
        tpCorner.CornerRadius = UDim.new(0, 3)
        tpCorner.Parent = tpBtn
        tpBtn.MouseButton1Click:Connect(function()
            teleportToSavedPoint(i)
        end)
        local delBtn = Instance.new("TextButton")
        delBtn.Parent = item
        delBtn.Size = UDim2.new(0, 35, 0, 20)
        delBtn.Position = UDim2.new(1, -40, 0, 24)
        delBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        delBtn.BorderSizePixel = 0
        delBtn.Text = "DEL"
        delBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
        delBtn.TextSize = 7
        local delCorner = Instance.new("UICorner")
        delCorner.CornerRadius = UDim.new(0, 3)
        delCorner.Parent = delBtn
        delBtn.MouseButton1Click:Connect(function()
            deleteTeleportPoint(i)
            refreshPointsList()
        end)
        yPos = yPos + 38
    end
    pointsScroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 4)
end

local function refreshPlayerList()
    for _, child in pairs(playerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local players = getPlayerList()
    local yPos = 2
    for i, player in ipairs(players) do
        local item = Instance.new("Frame")
        item.Parent = playerScroll
        item.Size = UDim2.new(1, -6, 0, 26)
        item.Position = UDim2.new(0, 3, 0, yPos)
        item.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        item.BorderSizePixel = 0
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 3)
        itemCorner.Parent = item
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = item
        nameLabel.Size = UDim2.new(1, -45, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        nameLabel.TextSize = 7
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        local tpBtn = Instance.new("TextButton")
        tpBtn.Parent = item
        tpBtn.Size = UDim2.new(0, 35, 0, 20)
        tpBtn.Position = UDim2.new(1, -40, 0.5, -10)
        tpBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        tpBtn.BorderSizePixel = 0
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        tpBtn.TextSize = 7
        local tpCorner = Instance.new("UICorner")
        tpCorner.CornerRadius = UDim.new(0, 3)
        tpCorner.Parent = tpBtn
        tpBtn.MouseButton1Click:Connect(function()
            teleportToPlayer(player)
        end)
        yPos = yPos + 32
    end
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 4)
end

espBtn.MouseButton1Click:Connect(function()
    toggleESP()
    if espEnabled then
        espBtn.Text = "🔍 ESP [ON]"
        espBtn.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
    else
        espBtn.Text = "🔍 ESP"
        espBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    end
end)

godBtn.MouseButton1Click:Connect(function()
    toggleGodMode()
    if godModeEnabled then
        godBtn.Text = "🛡️ GOD [ON]"
        godBtn.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
    else
        godBtn.Text = "🛡️ GOD MODE"
        godBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    end
end)

stunBtn.MouseButton1Click:Connect(function()
    toggleAntiStun()
    if antiStunEnabled then
        stunBtn.Text = "⚡ STUN [ON]"
        stunBtn.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
    else
        stunBtn.Text = "⚡ ANTI STUN"
        stunBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    end
end)

speedBtn.MouseButton1Click:Connect(function()
    toggleSpeed()
    if speedEnabled then
        speedBtn.Text = "⚡ SPEED: " .. currentSpeed .. " [ON]"
        speedBtn.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
    else
        speedBtn.Text = "⚡ SPEED: " .. currentSpeed
        speedBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    toggleNoClip()
    if noClipEnabled then
        noclipBtn.Text = "🧱 CLIP [ON]"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
    else
        noclipBtn.Text = "🧱 NO CLIP"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    end
end)

saveBtn.MouseButton1Click:Connect(function()
    local name = saveInput.Text
    if name == "" then name = "P" .. (#savedData.points + 1) end
    if saveTeleportPoint(name) then
        saveInput.Text = ""
        refreshPointsList()
        local oldColor = saveBtn.BackgroundColor3
        saveBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        wait(0.2)
        saveBtn.BackgroundColor3 = oldColor
    end
end)

local sliderDragging = false
sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local newSpeed = math.floor(percent * 999 + 1)
        setSpeed(newSpeed)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        speedBtn.Text = "⚡ SPEED: " .. currentSpeed .. (speedEnabled and " [ON]" or "")
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local newSpeed = math.floor(percent * 999 + 1)
        setSpeed(newSpeed)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        speedBtn.Text = "⚡ SPEED: " .. currentSpeed .. (speedEnabled and " [ON]" or "")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)

local function switchTab(tabName)
    for name, btn in pairs(tabButtons) do
        if name == tabName then
            btn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    mainPanel.Visible = (tabName == "MAIN")
    tpPanel.Visible = (tabName == "TP")
    if tabName == "TP" then
        refreshPointsList()
        refreshPlayerList()
    end
end

tabButtons["MAIN"].MouseButton1Click:Connect(function() switchTab("MAIN") end)
tabButtons["TP"].MouseButton1Click:Connect(function() switchTab("TP") end)

local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        mainFrame.Size = UDim2.new(0, 180, 0, 26)
        tabFrame.Visible = false
        container.Visible = false
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 180, 0, 200)
        tabFrame.Visible = true
        container.Visible = true
        minimizeBtn.Text = "−"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    if espEnabled then toggleESP() end
    if godModeEnabled then toggleGodMode() end
    if antiStunEnabled then toggleAntiStun() end
    if speedEnabled then toggleSpeed() end
    if noClipEnabled then toggleNoClip() end
    screenGui:Destroy()
    print("🔴 Infinity Yield Closed")
end)

local dragStartPos, dragStartMouse
local dragging = false

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = mainFrame.Position
        dragStartMouse = input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStartMouse
        mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.5)
    if speedEnabled then applySpeed() end
    if noClipEnabled then applyNoClip() end
    if godModeEnabled then startGodMode() end
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then createESP(player) end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    if espEnabled and player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            wait(0.5)
            createESP(player)
        end)
    end
    if tpPanel.Visible then refreshPlayerList() end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    if tpPanel.Visible then refreshPlayerList() end
end)

spawn(function()
    while wait(5) do
        if tpPanel.Visible then
            refreshPointsList()
            refreshPlayerList()
        end
    end
end)

loadData()
currentSpeed = savedData.settings.speed or 50
sliderFill.Size = UDim2.new(currentSpeed / 1000, 0, 1, 0)
speedBtn.Text = "⚡ SPEED: " .. currentSpeed
refreshPointsList()
refreshPlayerList()
startAntiCheat()
switchTab("MAIN")

print("=" .. string.rep("=", 45))
print("∞ INFINITY YIELD ULTIMATE v2.1")
print("📱 OPTIMIZED FOR DELTA HP")
print("📐 UI: 180x200 | Auto Save Settings")
print("")
print("🎮 FEATURES:")
print("   🔍 ESP - Player name & distance")
print("   🛡️ GOD MODE - Complete invincible")
print("   ⚡ ANTI STUN - No stun/slow/knockback")
print("   ⚡ SPEED - 1-1000 (Slider)")
print("   🧱 NO CLIP - Walk through walls")
print("   📍 TELEPORT - To Player & Saved Points")
print("")
print("💾 Auto save to: " .. fileName)
print("👆 Drag header to move UI")
print("=" .. string.rep("=", 45))
