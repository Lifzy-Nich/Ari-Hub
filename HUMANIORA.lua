-- ============================================
-- UNIVERSAL INFINITY HUB v1.0
-- FEATURES: ESP | GOD MODE | ANTI STUN | TELEPORT | ANTI-CHEAT
-- UNIVERSAL - BISA DIGUNAKAN DI SEMUA GAME
-- ============================================

-- ================= PART 1: ANTI-CHEAT BYPASS & PROTECTION =================
local AntiCheat = {
    Enabled = true,
    Protected = false,
    OriginalGlobals = {},
    FakeExecutors = {"Synapse", "Krnl", "ScriptWare", "Sentinel", "ProtoSmasher", "Delta"}
}

-- Sembunyikan exploit dari deteksi
local function hideExploit()
    -- Fake executor name untuk mengelabui anti-cheat
    local fakeName = "RobloxApp"
    if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
        local fake = Instance.new("ScreenGui")
        fake.Name = "RobloxPromptGui"
        fake.Parent = game:GetService("CoreGui")
    end
    
    -- Bersihkan console dari log mencurigakan
    local function clearConsole()
        local console = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
        if console then
            for _, v in pairs(console:GetChildren()) do
                if v:IsA("Frame") and (v.Name == "Console" or v.Name == "DeveloperConsole") then
                    v:Destroy()
                end
            end
        end
    end
    clearConsole()
    
    -- Hook loadstring untuk mencegah deteksi
    local oldLoadstring = loadstring
    getgenv().loadstring = function(str, chunkname)
        if str and (str:find("infinity") or str:find("exploit") or str:find("hub") or str:find("skizo")) then
            return function() return end
        end
        return oldLoadstring(str, chunkname)
    end
    
    -- Sembunyikan dari getgc
    if getgc then
        local gc = getgc(true)
        for _, v in pairs(gc) do
            if type(v) == "function" and tostring(v):find("infinity") then
                v = function() return end
            end
        end
    end
    
    -- Fake environment
    if getrenv then
        local renv = getrenv()
        renv.script = nil
        renv.Synapse = nil
        renv.Krnl = nil
    end
end

-- Deteksi dan hancurkan anti-cheat
local function detectAndDestroyAntiCheat()
    local detected = false
    local antiCheatNames = {"AntiCheat", "AC", "Security", "Protection", "Admin", "Ban", "Check", "Monitor"}
    local remoteNames = {"Anti", "Cheat", "Ban", "Kick", "Report", "Log"}
    
    -- Cek dan hancurkan di workspace
    for _, v in pairs(workspace:GetChildren()) do
        for _, name in pairs(antiCheatNames) do
            if v.Name and v.Name:find(name) then
                detected = true
                pcall(function() v:Destroy() end)
            end
        end
    end
    
    -- Cek dan hancurkan di replicated storage
    for _, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
        for _, name in pairs(antiCheatNames) do
            if v.Name and v.Name:find(name) then
                detected = true
                pcall(function() v:Destroy() end)
            end
        end
    end
    
    -- Hancurkan remote events yang mencurigakan
    local remoteEvents = game:GetService("ReplicatedStorage"):GetChildren()
    for _, v in pairs(remoteEvents) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, name in pairs(remoteNames) do
                if v.Name and v.Name:find(name) then
                    pcall(function() v:Destroy() end)
                end
            end
        end
    end
    
    -- Blokir remote yang tidak bisa dihancurkan
    for _, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
        if v:IsA("RemoteEvent") and v.Name:find("Anti") then
            local oldFire = v.FireServer
            v.FireServer = function() return end
        end
    end
    
    return detected
end

-- Self-repair mechanism
local function selfRepair()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        -- Perbaiki speed jika terkena freeze
        if humanoid.WalkSpeed == 0 and not speedEnabled then
            humanoid.WalkSpeed = 16
        end
        -- Perbaiki jump jika terkena nerf
        if humanoid.JumpPower == 0 then
            humanoid.JumpPower = 50
        end
        -- Perbaiki health jika god mode aktif
        if godModeEnabled and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end
    
    -- Unanchor jika terkena anchor
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart and rootPart.Anchored then
        rootPart.Anchored = false
    end
end

-- Main anti-cheat loop
local function startAntiCheat()
    hideExploit()
    detectAndDestroyAntiCheat()
    
    -- Periodic check setiap 10 detik
    spawn(function()
        while wait(10) do
            if AntiCheat.Enabled then
                detectAndDestroyAntiCheat()
                selfRepair()
            end
        end
    end)
    
    print("🛡️ [ANTI-CHEAT] Protection Active")
end

-- ================= PART 2: VARIABLES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Core Variables
local espEnabled = false
local espObjects = {}
local godModeEnabled = false
local antiStunEnabled = false
local savedData = {points = {}, teleports = {}}
local fileName = "InfinityData.json"
local isSpectating = false
local currentSpectateTarget = nil

-- Speed Variables
local speedEnabled = false
local currentSpeed = 50
local speedConnection = nil

-- Fly Variables
local flyEnabled = false
local flySpeed = 50
local flyBodyVelocity = nil
local flyBodyGyro = nil
local originalGravity = nil

-- No Clip Variables
local noClipEnabled = false
local noClipConnection = nil

-- ================= PART 3: SAVE/LOAD SYSTEM =================
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
            if not savedData.teleports then savedData.teleports = {} end
            if not savedData.speed then savedData.speed = 50 end
            if not savedData.flySpeed then savedData.flySpeed = 50 end
            currentSpeed = savedData.speed or 50
            flySpeed = savedData.flySpeed or 50
            print("📁 Loaded: " .. #savedData.points .. " points, " .. #savedData.teleports .. " teleports")
            return
        end
    end
    savedData = {points = {}, teleports = {}, speed = 50, flySpeed = 50}
    currentSpeed = 50
    flySpeed = 50
    print("📁 New data file created")
end

local function saveData()
    savedData.speed = currentSpeed
    savedData.flySpeed = flySpeed
    local encoded = game:GetService("HttpService"):JSONEncode(savedData)
    pcall(function()
        if writefile then
            writefile(fileName, encoded)
        end
    end)
end

-- ================= PART 4: ESP SYSTEM =================
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
    
    -- Billboard untuk nama dan jarak
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 120, 0, 40)
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
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.GothamBold
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Parent = billboard
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0"
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextSize = 9
    
    -- Health Bar
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Parent = billboard
    healthBarBg.Size = UDim2.new(0.8, 0, 0, 3)
    healthBarBg.Position = UDim2.new(0.1, 0, 0.85, 0)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    healthBarBg.BorderSizePixel = 0
    
    local healthBar = Instance.new("Frame")
    healthBar.Parent = healthBarBg
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    
    billboard.Parent = humanoidRootPart
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight_" .. player.Name
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 215, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 215, 0)
    highlight.OutlineTransparency = 0.4
    highlight.Parent = character
    
    espObjects[player] = {
        billboard = billboard,
        highlight = highlight,
        healthBar = healthBar,
        distanceLabel = distanceLabel,
        nameLabel = nameLabel
    }
    
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
            
            -- Update health bar
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local hpPercent = humanoid.Health / humanoid.MaxHealth
                healthBar.Size = UDim2.new(hpPercent, 0, 1, 0)
                
                if hpPercent > 0.6 then
                    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                elseif hpPercent > 0.3 then
                    healthBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                else
                    healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
            
            -- Warna berdasarkan jarak
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
        print("✅ ESP ENABLED")
    else
        for _, player in pairs(Players:GetPlayers()) do removeESP(player) end
        print("❌ ESP DISABLED")
    end
end

-- ================= PART 5: GOD MODE =================
local function toggleGodMode()
    godModeEnabled = not godModeEnabled
    
    if godModeEnabled then
        -- Buat loop untuk menjaga health
        spawn(function()
            while godModeEnabled and wait(0.1) do
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.Health = humanoid.MaxHealth
                        humanoid.BreakJointsOnDeath = false
                    end
                    -- Matikan collision damage
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                        end
                    end
                end
            end
        end)
        print("🛡️ GOD MODE ENABLED - You are invincible")
    else
        -- Kembalikan normal
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0.5, 0.5)
                end
            end
        end
        print("❌ GOD MODE DISABLED")
    end
end

-- ================= PART 6: ANTI STUN =================
local function startAntiStunLoop()
    spawn(function()
        while antiStunEnabled and wait(0.1) do
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    -- Cegah stun/freeze
                    if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                    if humanoid:GetState() == Enum.HumanoidStateType.GettingUp then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                    -- Cegah slow
                    if speedEnabled and humanoid.WalkSpeed ~= currentSpeed then
                        humanoid.WalkSpeed = currentSpeed
                    end
                end
                -- Cegah knockback
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart and rootPart.AssemblyLinearVelocity.Y < -30 then
                    rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, 0, rootPart.AssemblyLinearVelocity.Z)
                end
            end
        end
    end)
end

local function toggleAntiStun()
    antiStunEnabled = not antiStunEnabled
    if antiStunEnabled then
        startAntiStunLoop()
        print("🛡️ ANTI STUN ENABLED - Immune to stun/slow/knockback")
    else
        print("❌ ANTI STUN DISABLED")
    end
end

-- ================= PART 7: TELEPORT SYSTEM =================
-- Teleport ke koordinat
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

-- Teleport ke player
local function teleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    
    local targetPos = targetRoot.Position + Vector3.new(0, 3, 0)
    return teleportToPosition(targetPos)
end

-- Teleport ke cursor
local function teleportToCursor()
    local mouse = LocalPlayer:GetMouse()
    if mouse and mouse.Hit then
        return teleportToPosition(mouse.Hit.Position + Vector3.new(0, 3, 0))
    end
    return false
end

-- Simpan teleport point
local function saveTeleportPoint(name)
    local character = LocalPlayer.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local point = {
        name = name,
        x = rootPart.Position.X,
        y = rootPart.Position.Y,
        z = rootPart.Position.Z,
        time = os.date("%H:%M")
    }
    table.insert(savedData.teleports, point)
    saveData()
    print(string.format("📍 Teleport point '%s' saved at (%.0f, %.0f, %.0f)", name, point.x, point.y, point.z))
    return true
end

-- Teleport ke saved point
local function teleportToSavedPoint(index)
    if not savedData.teleports[index] then return false end
    local point = savedData.teleports[index]
    return teleportToPosition(Vector3.new(point.x, point.y, point.z))
end

-- Hapus saved point
local function deleteTeleportPoint(index)
    if savedData.teleports[index] then
        local name = savedData.teleports[index].name
        table.remove(savedData.teleports, index)
        saveData()
        print(string.format("🗑️ Deleted teleport point '%s'", name))
        return true
    end
    return false
end

-- ================= PART 8: SPEED SYSTEM =================
local function applySpeed()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then humanoid.WalkSpeed = currentSpeed end
end

local function startSpeedControl()
    if speedConnection then speedConnection:Disconnect() end
    speedConnection = RunService.RenderStepped:Connect(function()
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
        startSpeedControl()
        print("⚡ Speed ENABLED - Speed: " .. currentSpeed)
    else
        local character = LocalPlayer.Character
        if character then
    local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
        if speedConnection then speedConnection:Disconnect() speedConnection = nil end
        print("❌ Speed DISABLED")
    end
end

-- ================= PART 9: FLY SYSTEM =================
local function setupFly()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    
    if originalGravity == nil then originalGravity = workspace.Gravity end
    workspace.Gravity = 0
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = rootPart
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
    flyBodyGyro.CFrame = rootPart.CFrame
    flyBodyGyro.Parent = rootPart
    
    humanoid.PlatformStand = true
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end

local function cleanupFly()
    local character = LocalPlayer.Character
    if originalGravity then workspace.Gravity = originalGravity end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then rootPart.Velocity = Vector3.new(0, 0, 0) end
    end
end

local function updateFlyMovement()
    if not flyEnabled or not LocalPlayer.Character then return end
    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart or not flyBodyVelocity then return end
    
    local moveDirection = humanoid.MoveDirection
    local velocity = Vector3.new(0, 0, 0)
    
    if moveDirection.Magnitude > 0 then
        velocity = moveDirection * flySpeed
    end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        velocity = velocity + Vector3.new(0, flySpeed, 0)
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then
        velocity = velocity + Vector3.new(0, -flySpeed, 0)
    end
    
    flyBodyVelocity.Velocity = velocity
    
    if moveDirection.Magnitude > 0.1 then
        local lookCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + moveDirection)
        flyBodyGyro.CFrame = lookCFrame
    end
end

local function startFlyLoop()
    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.RenderStepped:Connect(function()
        updateFlyMovement()
    end)
end

local function setFlySpeed(value)
    flySpeed = math.clamp(value, 10, 500)
    savedData.flySpeed = flySpeed
    saveData()
end

local function toggleFly()
    flyEnabled = not flyEnabled
    if flyEnabled then
        setupFly()
        startFlyLoop()
        print("🦅 FLY MODE ENABLED - Use analog/Space/Ctrl")
    else
        cleanupFly()
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        print("❌ FLY MODE DISABLED")
    end
end

-- ================= PART 10: NO CLIP SYSTEM =================
local function applyNoClip()
    local character = LocalPlayer.Character
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noClipEnabled
        end
    end
end

local function startNoClip()
    if noClipConnection then noClipConnection:Disconnect() end
    noClipConnection = RunService.RenderStepped:Connect(function()
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
        startNoClip()
        print("🧱 NO CLIP ENABLED - Can walk through walls")
    else
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        if noClipConnection then noClipConnection:Disconnect() noClipConnection = nil end
        print("❌ NO CLIP DISABLED")
    end
end
-- ================= PART 11: GET PLAYER LIST =================
local function getPlayerList()
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player)
        end
    end
    return players
end

-- ================= PART 12: CHARACTER RESPAWN HANDLER =================
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.5)
    if speedEnabled then applySpeed() end
    if noClipEnabled then applyNoClip() end
    if flyEnabled then 
        cleanupFly()
        wait(0.1)
        setupFly()
        startFlyLoop()
    end
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then createESP(player) end
        end
    end
end)

-- ================= PART 13: GUI CREATION =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InfinityHub"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 260, 0, 400)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Parent = mainFrame
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
header.BorderSizePixel = 0

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Parent = header
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "∞ INFINITY HUB"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = header
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -65, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
minimizeBtn.TextSize = 18

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = header
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -32, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
closeBtn.TextSize = 14

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Tab Buttons
local tabFrame = Instance.new("Frame")
tabFrame.Parent = mainFrame
tabFrame.Size = UDim2.new(1, 0, 0, 36)
tabFrame.Position = UDim2.new(0, 0, 0, 38)
tabFrame.BackgroundTransparency = 1

local tabs = {"ESP", "COMBAT", "MOVEMENT", "TELEPORT"}
local tabButtons = {}
local currentTab = "ESP"

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Parent = tabFrame
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(25, 25, 30)
    btn.BorderSizePixel = 0
    btn.Text = tabName
    btn.TextColor3 = i == 1 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    tabButtons[tabName] = btn
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
end

-- Content Container
local container = Instance.new("Frame")
container.Parent = mainFrame
container.Size = UDim2.new(1, -16, 1, -94)
container.Position = UDim2.new(0, 8, 0, 78)
container.BackgroundTransparency = 1

-- ================= PART 14: ESP PANEL =================
local espPanel = Instance.new("Frame")
espPanel.Parent = container
espPanel.Size = UDim2.new(1, 0, 1, 0)
espPanel.BackgroundTransparency = 1

local espToggle = Instance.new("TextButton")
espToggle.Parent = espPanel
espToggle.Size = UDim2.new(1, 0, 0, 40)
espToggle.Position = UDim2.new(0, 0, 0, 0)
espToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
espToggle.BorderSizePixel = 0
espToggle.Text = "🔘 ENABLE ESP"
espToggle.TextColor3 = Color3.fromRGB(255, 215, 0)
espToggle.TextSize = 12
espToggle.Font = Enum.Font.GothamBold

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 6)
espCorner.Parent = espToggle

local espStatus = Instance.new("TextLabel")
espStatus.Parent = espPanel
espStatus.Size = UDim2.new(1, 0, 0, 25)
espStatus.Position = UDim2.new(0, 0, 0, 45)
espStatus.BackgroundTransparency = 1
espStatus.Text = "● ESP: OFF"
espStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
espStatus.TextSize = 10

-- Player List
local playerListTitle = Instance.new("TextLabel")
playerListTitle.Parent = espPanel
playerListTitle.Size = UDim2.new(1, 0, 0, 20)
playerListTitle.Position = UDim2.new(0, 0, 0, 75)
playerListTitle.BackgroundTransparency = 1
playerListTitle.Text = "PLAYERS IN SERVER"
playerListTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
playerListTitle.TextSize = 9
playerListTitle.Font = Enum.Font.GothamBold

local playerListScroll = Instance.new("ScrollingFrame")
playerListScroll.Parent = espPanel
playerListScroll.Size = UDim2.new(1, 0, 1, -100)
playerListScroll.Position = UDim2.new(0, 0, 0, 95)
playerListScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
playerListScroll.BackgroundTransparency = 0.5
playerListScroll.BorderSizePixel = 0
playerListScroll.ScrollBarThickness = 3

local playerCorner = Instance.new("UICorner")
playerCorner.CornerRadius = UDim.new(0, 6)
playerCorner.Parent = playerListScroll

local function refreshPlayerList()
    for _, child in pairs(playerListScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local players = getPlayerList()
    local yPos = 4
    
    for i, player in ipairs(players) do
        local item = Instance.new("Frame")
        item.Parent = playerListScroll
        item.Size = UDim2.new(1, -8, 0, 38)
        item.Position = UDim2.new(0, 4, 0, yPos)
        item.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        item.BorderSizePixel = 0
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 4)
        itemCorner.Parent = item
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = item
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 8, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        nameLabel.TextSize = 10
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        yPos = yPos + 46
    end
    
    playerListScroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 8)
end

refreshPlayerList()
spawn(function()
    while wait(3) do
        if espPanel.Visible then refreshPlayerList() end
    end
end)
-- ================= PART 15: COMBAT PANEL =================
local combatPanel = Instance.new("Frame")
combatPanel.Parent = container
combatPanel.Size = UDim2.new(1, 0, 1, 0)
combatPanel.BackgroundTransparency = 1
combatPanel.Visible = false

-- God Mode
local godModeToggle = Instance.new("TextButton")
godModeToggle.Parent = combatPanel
godModeToggle.Size = UDim2.new(1, 0, 0, 40)
godModeToggle.Position = UDim2.new(0, 0, 0, 0)
godModeToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
godModeToggle.BorderSizePixel = 0
godModeToggle.Text = "🛡️ GOD MODE"
godModeToggle.TextColor3 = Color3.fromRGB(255, 215, 0)
godModeToggle.TextSize = 12
godModeToggle.Font = Enum.Font.GothamBold

local godModeCorner = Instance.new("UICorner")
godModeCorner.CornerRadius = UDim.new(0, 6)
godModeCorner.Parent = godModeToggle

local godModeStatus = Instance.new("TextLabel")
godModeStatus.Parent = combatPanel
godModeStatus.Size = UDim2.new(1, 0, 0, 25)
godModeStatus.Position = UDim2.new(0, 0, 0, 45)
godModeStatus.BackgroundTransparency = 1
godModeStatus.Text = "● GOD MODE: OFF"
godModeStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
godModeStatus.TextSize = 10

-- Anti Stun
local antiStunToggle = Instance.new("TextButton")
antiStunToggle.Parent = combatPanel
antiStunToggle.Size = UDim2.new(1, 0, 0, 40)
antiStunToggle.Position = UDim2.new(0, 0, 0, 80)
antiStunToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
antiStunToggle.BorderSizePixel = 0
antiStunToggle.Text = "⚡ ANTI STUN"
antiStunToggle.TextColor3 = Color3.fromRGB(255, 215, 0)
antiStunToggle.TextSize = 12
antiStunToggle.Font = Enum.Font.GothamBold

local antiStunCorner = Instance.new("UICorner")
antiStunCorner.CornerRadius = UDim.new(0, 6)
antiStunCorner.Parent = antiStunToggle

local antiStunStatus = Instance.new("TextLabel")
antiStunStatus.Parent = combatPanel
antiStunStatus.Size = UDim2.new(1, 0, 0, 25)
antiStunStatus.Position = UDim2.new(0, 0, 0, 125)
antiStunStatus.BackgroundTransparency = 1
antiStunStatus.Text = "● ANTI STUN: OFF"
antiStunStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
antiStunStatus.TextSize = 10

-- ================= PART 16: MOVEMENT PANEL =================
local movementPanel = Instance.new("Frame")
movementPanel.Parent = container
movementPanel.Size = UDim2.new(1, 0, 1, 0)
movementPanel.BackgroundTransparency = 1
movementPanel.Visible = false

-- Speed
local speedToggle = Instance.new("TextButton")
speedToggle.Parent = movementPanel
speedToggle.Size = UDim2.new(1, 0, 0, 38)
speedToggle.Position = UDim2.new(0, 0, 0, 0)
speedToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
speedToggle.BorderSizePixel = 0
speedToggle.Text = "⚡ SPEED HACK"
speedToggle.TextColor3 = Color3.fromRGB(255, 215, 0)
speedToggle.TextSize = 11

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 5)
speedCorner.Parent = speedToggle

local speedSliderBg = Instance.new("Frame")
speedSliderBg.Parent = movementPanel
speedSliderBg.Size = UDim2.new(1, 0, 0, 3)
speedSliderBg.Position = UDim2.new(0, 0, 0, 45)
speedSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
speedSliderBg.BorderSizePixel = 0

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = speedSliderBg

local speedSlider = Instance.new("Frame")
speedSlider.Parent = speedSliderBg
speedSlider.Size = UDim2.new(currentSpeed / 1000, 0, 1, 0)
speedSlider.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
speedSlider.BorderSizePixel = 0

local speedValue = Instance.new("TextLabel")
speedValue.Parent = movementPanel
speedValue.Size = UDim2.new(1, 0, 0, 20)
speedValue.Position = UDim2.new(0, 0, 0, 52)
speedValue.BackgroundTransparency = 1
speedValue.Text = "Speed: " .. currentSpeed
speedValue.TextColor3 = Color3.fromRGB(200, 200, 200)
speedValue.TextSize = 9

-- Fly Mode
local flyToggle = Instance.new("TextButton")
flyToggle.Parent = movementPanel
flyToggle.Size = UDim2.new(1, 0, 0, 38)
flyToggle.Position = UDim2.new(0, 0, 0, 80)
flyToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
flyToggle.BorderSizePixel = 0
flyToggle.Text = "🦅 FLY MODE"
flyToggle.TextColor3 = Color3.fromRGB(255, 215, 0)
flyToggle.TextSize = 11

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 5)
flyCorner.Parent = flyToggle

local flySliderBg = Instance.new("Frame")
flySliderBg.Parent = movementPanel
flySliderBg.Size = UDim2.new(1, 0, 0, 3)
flySliderBg.Position = UDim2.new(0, 0, 0, 125)
flySliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
flySliderBg.BorderSizePixel = 0

local flySliderCorner = Instance.new("UICorner")
flySliderCorner.CornerRadius = UDim.new(1, 0)
flySliderCorner.Parent = flySliderBg

local flySlider = Instance.new("Frame")
flySlider.Parent = flySliderBg
flySlider.Size = UDim2.new(flySpeed / 500, 0, 1, 0)
flySlider.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
flySlider.BorderSizePixel = 0

local flyValue = Instance.new("TextLabel")
flyValue.Parent = movementPanel
flyValue.Size = UDim2.new(1, 0, 0, 20)
flyValue.Position = UDim2.new(0, 0, 0, 132)
flyValue.BackgroundTransparency = 1
flyValue.Text = "Fly Speed: " .. flySpeed
flyValue.TextColor3 = Color3.fromRGB(200, 200, 200)
flyValue.TextSize = 9

-- No Clip
local noClipToggle = Instance.new("TextButton")
noClipToggle.Parent = movementPanel
noClipToggle.Size = UDim2.new(1, 0, 0, 38)
noClipToggle.Position = UDim2.new(0, 0, 0, 160)
noClipToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
noClipToggle.BorderSizePixel = 0
noClipToggle.Text = "🧱 NO CLIP"
noClipToggle.TextColor3 = Color3.fromRGB(255, 215, 0)
noClipToggle.TextSize = 11

local noClipCorner = Instance.new("UICorner")
noClipCorner.CornerRadius = UDim.new(0, 5)
noClipCorner.Parent = noClipToggle
-- ================= PART 17: TELEPORT PANEL =================
local teleportPanel = Instance.new("Frame")
teleportPanel.Parent = container
teleportPanel.Size = UDim2.new(1, 0, 1, 0)
teleportPanel.BackgroundTransparency = 1
teleportPanel.Visible = false

-- Teleport to Cursor
local cursorTPBtn = Instance.new("TextButton")
cursorTPBtn.Parent = teleportPanel
cursorTPBtn.Size = UDim2.new(1, 0, 0, 38)
cursorTPBtn.Position = UDim2.new(0, 0, 0, 0)
cursorTPBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
cursorTPBtn.BorderSizePixel = 0
cursorTPBtn.Text = "📍 TELEPORT TO CURSOR"
cursorTPBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
cursorTPBtn.TextSize = 11

local cursorCorner = Instance.new("UICorner")
cursorCorner.CornerRadius = UDim.new(0, 5)
cursorCorner.Parent = cursorTPBtn

-- Save Current Position
local savePointInput = Instance.new("TextBox")
savePointInput.Parent = teleportPanel
savePointInput.Size = UDim2.new(1, 0, 0, 32)
savePointInput.Position = UDim2.new(0, 0, 0, 48)
savePointInput.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
savePointInput.BorderSizePixel = 0
savePointInput.PlaceholderText = "Point name..."
savePointInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
savePointInput.TextColor3 = Color3.fromRGB(255, 255, 255)
savePointInput.TextSize = 10

local saveInputCorner = Instance.new("UICorner")
saveInputCorner.CornerRadius = UDim.new(0, 5)
saveInputCorner.Parent = savePointInput

local savePointBtn = Instance.new("TextButton")
savePointBtn.Parent = teleportPanel
savePointBtn.Size = UDim2.new(1, 0, 0, 35)
savePointBtn.Position = UDim2.new(0, 0, 0, 85)
savePointBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
savePointBtn.BorderSizePixel = 0
savePointBtn.Text = "💾 SAVE CURRENT POSITION"
savePointBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
savePointBtn.TextSize = 10
savePointBtn.Font = Enum.Font.GothamBold

local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 5)
saveCorner.Parent = savePointBtn

-- Saved Points List
local pointsTitle = Instance.new("TextLabel")
pointsTitle.Parent = teleportPanel
pointsTitle.Size = UDim2.new(1, 0, 0, 20)
pointsTitle.Position = UDim2.new(0, 0, 0, 128)
pointsTitle.BackgroundTransparency = 1
pointsTitle.Text = "SAVED TELEPORT POINTS"
pointsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
pointsTitle.TextSize = 9
pointsTitle.Font = Enum.Font.GothamBold

local pointsScroll = Instance.new("ScrollingFrame")
pointsScroll.Parent = teleportPanel
pointsScroll.Size = UDim2.new(1, 0, 1, -155)
pointsScroll.Position = UDim2.new(0, 0, 0, 148)
pointsScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
pointsScroll.BackgroundTransparency = 0.5
pointsScroll.BorderSizePixel = 0
pointsScroll.ScrollBarThickness = 3

local pointsCorner = Instance.new("UICorner")
pointsCorner.CornerRadius = UDim.new(0, 6)
pointsCorner.Parent = pointsScroll

local function refreshPointsList()
    for _, child in pairs(pointsScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local yPos = 4
    
    for i, point in ipairs(savedData.teleports) do
        local item = Instance.new("Frame")
        item.Parent = pointsScroll
        item.Size = UDim2.new(1, -8, 0, 48)
        item.Position = UDim2.new(0, 4, 0, yPos)
        item.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        item.BorderSizePixel = 0
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 5)
        itemCorner.Parent = item
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = item
        nameLabel.Size = UDim2.new(1, -70, 0, 20)
        nameLabel.Position = UDim2.new(0, 8, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = point.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        nameLabel.TextSize = 10
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.GothamBold
        
        local posLabel = Instance.new("TextLabel")
        posLabel.Parent = item
        posLabel.Size = UDim2.new(1, -70, 0, 16)
        posLabel.Position = UDim2.new(0, 8, 0, 25)
        posLabel.BackgroundTransparency = 1
        posLabel.Text = string.format("%.0f, %.0f, %.0f", point.x, point.y, point.z)
        posLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        posLabel.TextSize = 8
        posLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local tpBtn = Instance.new("TextButton")
        tpBtn.Parent = item
        tpBtn.Size = UDim2.new(0, 45, 0, 28)
        tpBtn.Position = UDim2.new(1, -53, 0, 4)
        tpBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        tpBtn.BorderSizePixel = 0
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        tpBtn.TextSize = 9
        
        local tpCorner = Instance.new("UICorner")
        tpCorner.CornerRadius = UDim.new(0, 4)
        tpCorner.Parent = tpBtn
        
        tpBtn.MouseButton1Click:Connect(function()
            teleportToSavedPoint(i)
        end)
        
        local delBtn = Instance.new("TextButton")
        delBtn.Parent = item
        delBtn.Size = UDim2.new(0, 45, 0, 28)
        delBtn.Position = UDim2.new(1, -53, 0, 35)
        delBtn.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
        delBtn.BorderSizePixel = 0
        delBtn.Text = "DEL"
        delBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
        delBtn.TextSize = 9
        
        local delCorner = Instance.new("UICorner")
        delCorner.CornerRadius = UDim.new(0, 4)
        delCorner.Parent = delBtn
        
        delBtn.MouseButton1Click:Connect(function()
            deleteTeleportPoint(i)
            refreshPointsList()
        end)
        
        yPos = yPos + 56
    end
    
    pointsScroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 8)
end

-- Player Teleport List
local playerTPTitle = Instance.new("TextLabel")
playerTPTitle.Parent = teleportPanel
playerTPTitle.Size = UDim2.new(1, 0, 0, 20)
playerTPTitle.Position = UDim2.new(0, 0, 1, -95)
playerTPTitle.BackgroundTransparency = 1
playerTPTitle.Text = "TELEPORT TO PLAYER"
playerTPTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
playerTPTitle.TextSize = 9
playerTPTitle.Font = Enum.Font.GothamBold

local playerTPScroll = Instance.new("ScrollingFrame")
playerTPScroll.Parent = teleportPanel
playerTPScroll.Size = UDim2.new(1, 0, 0, 70)
playerTPScroll.Position = UDim2.new(0, 0, 1, -70)
playerTPScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
playerTPScroll.BackgroundTransparency = 0.5
playerTPScroll.BorderSizePixel = 0
playerTPScroll.ScrollBarThickness = 3

local playerTPCorner = Instance.new("UICorner")
playerTPCorner.CornerRadius = UDim.new(0, 6)
playerTPCorner.Parent = playerTPScroll

local function refreshPlayerTPList()
    for _, child in pairs(playerTPScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local players = getPlayerList()
    local yPos = 4
    
    for i, player in ipairs(players) do
        local item = Instance.new("Frame")
        item.Parent = playerTPScroll
        item.Size = UDim2.new(1, -8, 0, 30)
        item.Position = UDim2.new(0, 4, 0, yPos)
        item.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        item.BorderSizePixel = 0
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 4)
        itemCorner.Parent = item
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = item
        nameLabel.Size = UDim2.new(1, -55, 1, 0)
        nameLabel.Position = UDim2.new(0, 8, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        nameLabel.TextSize = 9
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local tpBtn = Instance.new("TextButton")
        tpBtn.Parent = item
        tpBtn.Size = UDim2.new(0, 45, 0, 24)
        tpBtn.Position = UDim2.new(1, -53, 0.5, -12)
        tpBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        tpBtn.BorderSizePixel = 0
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        tpBtn.TextSize = 9
        
        local tpCorner = Instance.new("UICorner")
        tpCorner.CornerRadius = UDim.new(0, 4)
        tpCorner.Parent = tpBtn
        
        tpBtn.MouseButton1Click:Connect(function()
            teleportToPlayer(player)
        end)
        
        yPos = yPos + 38
    end
    
    playerTPScroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 8)
end

refreshPointsList()
refreshPlayerTPList()

spawn(function()
    while wait(3) do
        if teleportPanel.Visible then
            refreshPlayerTPList()
        end
    end
end)

spawn(function()
    while wait(5) do
        if teleportPanel.Visible then
            refreshPointsList()
        end
    end
end)
-- ================= PART 18: TAB SWITCHING =================
local function switchTab(tabName)
    currentTab = tabName
    for name, btn in pairs(tabButtons) do
        if name == tabName then
            btn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    espPanel.Visible = (tabName == "ESP")
    combatPanel.Visible = (tabName == "COMBAT")
    movementPanel.Visible = (tabName == "MOVEMENT")
    teleportPanel.Visible = (tabName == "TELEPORT")
end

tabButtons["ESP"].MouseButton1Click:Connect(function() switchTab("ESP") end)
tabButtons["COMBAT"].MouseButton1Click:Connect(function() switchTab("COMBAT") end)
tabButtons["MOVEMENT"].MouseButton1Click:Connect(function() switchTab("MOVEMENT") end)
tabButtons["TELEPORT"].MouseButton1Click:Connect(function() switchTab("TELEPORT") end)

-- ================= PART 19: BUTTON FUNCTIONS =================
-- ESP
espToggle.MouseButton1Click:Connect(function()
    toggleESP()
    if espEnabled then
        espToggle.Text = "🔴 DISABLE ESP"
        espToggle.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
        espStatus.Text = "● ESP: ON"
        espStatus.TextColor3 = Color3.fromRGB(255, 215, 0)
    else
        espToggle.Text = "🔘 ENABLE ESP"
        espToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        espStatus.Text = "● ESP: OFF"
        espStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

-- God Mode
godModeToggle.MouseButton1Click:Connect(function()
    toggleGodMode()
    if godModeEnabled then
        godModeToggle.Text = "🛡️ GOD MODE [ON]"
        godModeToggle.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
        godModeStatus.Text = "● GOD MODE: ON"
        godModeStatus.TextColor3 = Color3.fromRGB(255, 215, 0)
    else
        godModeToggle.Text = "🛡️ GOD MODE"
        godModeToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        godModeStatus.Text = "● GOD MODE: OFF"
        godModeStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

-- Anti Stun
antiStunToggle.MouseButton1Click:Connect(function()
    toggleAntiStun()
    if antiStunEnabled then
        antiStunToggle.Text = "⚡ ANTI STUN [ON]"
        antiStunToggle.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
        antiStunStatus.Text = "● ANTI STUN: ON"
        antiStunStatus.TextColor3 = Color3.fromRGB(255, 215, 0)
    else
        antiStunToggle.Text = "⚡ ANTI STUN"
        antiStunToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        antiStunStatus.Text = "● ANTI STUN: OFF"
        antiStunStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

-- Speed
speedToggle.MouseButton1Click:Connect(function()
    toggleSpeed()
    if speedEnabled then
        speedToggle.Text = "⚡ SPEED HACK [ON]"
        speedToggle.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
    else
        speedToggle.Text = "⚡ SPEED HACK"
        speedToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    end
end)

-- Fly
flyToggle.MouseButton1Click:Connect(function()
    toggleFly()
    if flyEnabled then
        flyToggle.Text = "🦅 FLY MODE [ON]"
        flyToggle.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
    else
        flyToggle.Text = "🦅 FLY MODE"
        flyToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    end
end)

-- No Clip
noClipToggle.MouseButton1Click:Connect(function()
    toggleNoClip()
    if noClipEnabled then
        noClipToggle.Text = "🧱 NO CLIP [ON]"
        noClipToggle.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
    else
        noClipToggle.Text = "🧱 NO CLIP"
        noClipToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    end
end)

-- Teleport to Cursor
cursorTPBtn.MouseButton1Click:Connect(function()
    if teleportToCursor() then
        local oldColor = cursorTPBtn.BackgroundColor3
        cursorTPBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        wait(0.2)
        cursorTPBtn.BackgroundColor3 = oldColor
        print("✨ Teleported to cursor position")
    end
end)

-- Save Point
savePointBtn.MouseButton1Click:Connect(function()
    local name = savePointInput.Text
    if name == "" then name = "Point " .. (#savedData.teleports + 1) end
    if saveTeleportPoint(name) then
        savePointInput.Text = ""
        refreshPointsList()
        local oldColor = savePointBtn.BackgroundColor3
        savePointBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        wait(0.2)
        savePointBtn.BackgroundColor3 = oldColor
    end
end)

-- ================= PART 20: SLIDER FUNCTIONS =================
local speedDragging = false
speedSliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        speedDragging = true
        local percent = math.clamp((input.Position.X - speedSliderBg.AbsolutePosition.X) / speedSliderBg.AbsoluteSize.X, 0, 1)
        local newSpeed = math.floor(percent * 999 + 1)
        setSpeed(newSpeed)
        speedSlider.Size = UDim2.new(percent, 0, 1, 0)
        speedValue.Text = "Speed: " .. currentSpeed
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if speedDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local percent = math.clamp((input.Position.X - speedSliderBg.AbsolutePosition.X) / speedSliderBg.AbsoluteSize.X, 0, 1)
        local newSpeed = math.floor(percent * 999 + 1)
        setSpeed(newSpeed)
        speedSlider.Size = UDim2.new(percent, 0, 1, 0)
        speedValue.Text = "Speed: " .. currentSpeed
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        speedDragging = false
    end
end)

local flyDragging = false
flySliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        flyDragging = true
        local percent = math.clamp((input.Position.X - flySliderBg.AbsolutePosition.X) / flySliderBg.AbsoluteSize.X, 0, 1)
        local newSpeed = math.floor(percent * 490 + 10)
        setFlySpeed(newSpeed)
        flySlider.Size = UDim2.new(percent, 0, 1, 0)
        flyValue.Text = "Fly Speed: " .. flySpeed
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if flyDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local percent = math.clamp((input.Position.X - flySliderBg.AbsolutePosition.X) / flySliderBg.AbsoluteSize.X, 0, 1)
        local newSpeed = math.floor(percent * 490 + 10)
        setFlySpeed(newSpeed)
        flySlider.Size = UDim2.new(percent, 0, 1, 0)
        flyValue.Text = "Fly Speed: " .. flySpeed
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        flyDragging = false
    end
end)
-- ================= PART 21: MINIMIZE & CLOSE =================
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        mainFrame.Size = UDim2.new(0, 260, 0, 38)
        tabFrame.Visible = false
        container.Visible = false
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 260, 0, 400)
        tabFrame.Visible = true
        container.Visible = true
        minimizeBtn.Text = "−"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    if espEnabled then toggleESP() end
    if speedEnabled then toggleSpeed() end
    if flyEnabled then toggleFly() end
    if noClipEnabled then toggleNoClip() end
    if godModeEnabled then toggleGodMode() end
    if antiStunEnabled then toggleAntiStun() end
    screenGui:Destroy()
    print("🔴 Infinity Hub Closed")
end)

-- ================= PART 22: DRAGABLE UI =================
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

-- ================= PART 23: PLAYER HANDLERS =================
Players.PlayerAdded:Connect(function(player)
    if espEnabled and player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            wait(0.5)
            createESP(player)
        end)
    end
    if espPanel.Visible then refreshPlayerList() end
    if teleportPanel.Visible then refreshPlayerTPList() end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    if espPanel.Visible then refreshPlayerList() end
    if teleportPanel.Visible then refreshPlayerTPList() end
end)

-- ================= PART 24: INITIALIZATION =================
loadData()
currentSpeed = savedData.speed or 50
flySpeed = savedData.flySpeed or 50
speedSlider.Size = UDim2.new(currentSpeed / 1000, 0, 1, 0)
flySlider.Size = UDim2.new(flySpeed / 500, 0, 1, 0)
speedValue.Text = "Speed: " .. currentSpeed
flyValue.Text = "Fly Speed: " .. flySpeed

-- Start Anti-Cheat
startAntiCheat()

print("=" .. string.rep("=", 50))
print("∞ UNIVERSAL INFINITY HUB v1.0")
print("📱 UI Size: 260x400 | Universal Script")
print("")
print("🎮 FEATURES:")
print("   🔍 ESP PLAYER - Nama, Jarak, Health Bar")
print("   🛡️ GOD MODE - Invincible (ON/OFF)")
print("   ⚡ ANTI STUN - Immune to stun/slow/knockback (ON/OFF)")
print("   📍 TELEPORT - To Player, Cursor, Saved Points")
print("   💾 SAVE POINTS - Simpan teleport ke JSON")
print("   🦅 FLY MODE - Free flight with analog")
print("   ⚡ SPEED HACK - 1-1000 (ON/OFF)")
print("   🧱 NO CLIP - Walk through walls (ON/OFF)")
print("")
print("🛡️ ANTI-CHEAT PROTECTION:")
print("   • Hide Exploit from Detection")
print("   • Destroy Anti-Cheat Remotes")
print("   • Self-Repair Mechanism")
print("   • Fake Executor Detection")
print("")
print("💾 Data saved to: " .. fileName)
print("👆 Drag header to move UI")
print("=" .. string.rep("=", 50))
