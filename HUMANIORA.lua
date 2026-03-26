--!native
--[[
    Native Script Loader
    Fungsi: Menampilkan GUI untuk verifikasi kunci, lalu memuat skrip utama.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = cloneref(game:GetService("CoreGui"))

-- ==================== KONSTANTA & KONFIGURASI ====================

local DISCORD_INVITE_CODE = "QyNghGRmH3"
local DISCORD_INVITE_URL = "https://discord.gg/QyNghGRmH3"

local LINKVERTISE_API_URL = "https://ads.luarmor.net/get_key?for=Native_Linkvertise-OlHmNGrpKcxc"
local LOOTLABS_API_URL = "https://ads.luarmor.net/get_key?for=Native_Lootlabs-hgTHxCASTxVE"

-- Warna (Color3)
local Color = {
    Black = Color3.fromRGB(0, 0, 0),
    Night = Color3.fromRGB(7, 7, 7),
    Deep = Color3.fromRGB(12, 12, 12),
    Slate = Color3.fromRGB(24, 24, 24),
    Border = Color3.fromRGB(27, 27, 27),
    Divider = Color3.fromRGB(28, 28, 28),
    Cloud = Color3.fromRGB(235, 235, 235),
    White = Color3.fromRGB(255, 255, 255),
    Azure = Color3.fromRGB(30, 86, 216),
    Usedcvnt = Color3.fromRGB(113, 35, 188),
    Amber = Color3.fromRGB(188, 111, 35),
    Mist = Color3.fromRGB(205, 225, 255),
    Text = Color3.fromRGB(235, 235, 235),
    Accent = Color3.fromRGB(210, 10, 46),
}

-- Asset ID Gambar
local Images = {
    headerCross = "rbxassetid://138587803745667",
    headerPseudoShader = "rbxassetid://79912556398061",
    buttonPseudoShader = "rbxassetid://134622165963267",
    play = "rbxassetid://82185954191052",
    link = "rbxassetid://124316681458847",
    key = "rbxassetid://127769833326655",
    earth = "rbxassetid://116793177414727",
}

-- Font
local MontserratSemiBold = Font.new(
    "rbxasset://fonts/families/Montserrat.json",
    Enum.FontWeight.SemiBold,
    Enum.FontStyle.Normal
)

-- ==================== FUNGSI UTILITY ====================

-- Fungsi untuk menyalin teks ke clipboard
local function setClipboard(text)
    local copyFunc = setclipboard or toclipboard or setrbxclipboard
    if copyFunc then
        copyFunc(text)
    end
end

-- ==================== SISTEM SPRING ANIMASI ====================
-- (Modul untuk animasi halus, diambil dari Roblox Spring Module)
-- ... [Kode spring yang panjang, disederhanakan untuk ringkasan] ...
-- Intinya: Digunakan untuk menganimasikan GUI (menampilkan/menyembunyikan dengan efek)

-- ==================== PEMBUATAN ELEMEN GUI ====================

-- Fungsi untuk membuat tombol sentuh (TouchButton)
local function createTouchButton(parent, config)
    local button = Instance.new("TextButton")
    button.BackgroundTransparency = 1
    button.AnchorPoint = config.AnchorPoint or Vector2.new(0.5, 0.5)
    button.Position = config.Position or UDim2.fromScale(0.5, 0.5)
    button.Size = config.Size or UDim2.fromScale(1, 1)
    button.Text = ""
    button.ZIndex = 2147483647
    button.Parent = parent

    config.Callback(button)
end

-- Fungsi untuk efek tekan tombol (animasi spring)
local spring = require(script:WaitForChild("Spring")) -- Asumsi ada modul spring
local function onButtonPressed(button, callback, destroyCallback)
    spring.target(button, 1, 1.658, {Position = UDim2.fromScale(0.5, 1.5)})
    spring.completed(button, function()
        button:Destroy()
        if destroyCallback then destroyCallback() end
        if callback then callback() end
    end)
end

-- ... [Fungsi pembuatan elemen GUI lainnya seperti tombol Linkvertise, Lootlabs, Discord, dll] ...

-- ==================== SKEMA GUI UTAMA ====================

local function setupGateway(config)
    -- config berisi: linkvertise, lootlabs, parent, onLaunch, onValidation, onClose
    local linkvertiseKey = config.linkvertise
    local lootlabsKey = config.lootlabs
    local parent = config.parent
    local onLaunch = config.onLaunch
    local onValidation = config.onValidation
    local onClose = config.onClose

    -- Buat ScreenGui utama
    local gui = Instance.new("ScreenGui")
    gui.Name = "Gateway"
    gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
    gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
    gui.Archivable = false
    gui.ResetOnSpawn = false
    gui.AutoLocalize = false
    gui.DisplayOrder = 2147483647
    gui.Parent = parent

    -- Buat Frame utama (MainContainer)
    local mainFrame = Instance.new("Frame")
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color.Night
    mainFrame.Position = UDim2.fromScale(0.5, 1.5)
    mainFrame.Size = UDim2.fromScale(0.5, 0.5)
    mainFrame.Parent = gui
    -- ... [Tambahkan komponen seperti UIAspectRatioConstraint, UICorner, UIStroke] ...

    -- ... [Pembangunan seluruh struktur GUI: Header, InteractionArea, Tombol Launch, Linkvertise, Lootlabs, Discord, dll] ...
    -- Semua elemen GUI dibuat di sini dengan detail yang sangat lengkap.

    -- Logika utama untuk input kunci dan validasi
    local keyTextBox = textBox -- referensi ke TextBox
    local feedbackStroke = uiStroke -- referensi ke UIStroke untuk feedback

    -- Objek untuk mengelola kunci yang dimasukkan
    local keyHandler = {
        getKey = function()
            return keyTextBox.Text
        end,
        close = function()
            spring.target(mainFrame, 1, 1.658, {Position = UDim2.fromScale(0.5, 1.5)})
            spring.completed(mainFrame, function()
                gui:Destroy()
            end)
        end
    }

    -- Event saat teks di kotak kunci berubah
    keyTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local currentKey = keyTextBox.Text
        if #currentKey == 0 then
            spring.target(feedbackStroke, 1, 0.975, {Transparency = 1})
            return
        end

        if onValidation and type(onValidation) == "function" then
            local isValid = onValidation(keyHandler)
            if not isValid then
                spring.target(feedbackStroke, 1, 1.7, {Transparency = 0.15}) -- feedback merah
            else
                spring.target(feedbackStroke, 1, 0.975, {Transparency = 1}) -- normal
            end
        end
    end)

    -- Tombol Launch
    local launchButton = launchButtonInstance
    createTouchButton(launchButton, keyTextBox, keyHandler, onLaunch)

    -- Tombol Linkvertise
    createLinkvertiseButton(linkvertiseButtonInstance, linkvertiseKey)

    -- Tombol Lootlabs
    createLootlabsButton(lootlabsButtonInstance, lootlabsKey)

    -- Tombol Discord
    createDiscordButton(discordButtonInstance)

    -- Animasi GUI masuk
    spring.target(mainFrame, 1, 1.59, {Position = UDim2.fromScale(0.5, 0.5)})

    return gui
end

-- ==================== FUNGSI UTAMA LOADER ====================

-- Daftar hash kunci untuk berbagai game (mapping GameId/PlaceId -> Key)
local keyHashes = {
    [7750955984] = "9c7ff25555ddd4aa46b88d35361ceef7",
    [5166944221] = "2623c74821b882b1e5e529b9078bd30a",
    [5578556129] = "be2f65b9bda9c9e9aaf37dbbe3d48070",
    [5750914919] = "3c7650df1287b147b62944e27ae8006a",
    -- ... [dan seterusnya] ...
}

-- Fungsi untuk mendapatkan kunci yang benar untuk game saat ini
local function getExpectedKey()
    local gameId = game.GameId
    local placeId = game.PlaceId
    return keyHashes[gameId] or keyHashes[placeId]
end

-- Fungsi untuk memuat skrip utama dari server
local function loadScript(scriptKey, expectedKey)
    -- expectedKey adalah hash yang harus cocok dengan scriptKey
    local url = "https://api.luarmor.net/files/v4/loaders/" .. expectedKey .. ".lua"
    local scriptContent = game:HttpGet(url)
    loadstring(scriptContent)()
end

-- Fungsi validasi kunci (panjang 32 karakter dan tidak kosong)
local function isValidKey(key)
    return key and type(key) == "string" and #key == 32 and key:gsub(" ", "") ~= ""
end

-- Fungsi untuk memulai GUI dan proses verifikasi
local function initialize()
    local expectedKey = getExpectedKey()
    if not expectedKey then
        return
    end

    -- Cek apakah kunci yang disimpan (dari script_key) valid
    local savedKey = script_key -- Variabel global dari executor
    if isValidKey(savedKey) and savedKey == expectedKey then
        -- Jika kunci valid, langsung muat skrip
        loadScript(savedKey, expectedKey)
        return
    end

    -- Jika tidak, tampilkan GUI untuk mendapatkan kunci
    return setupGateway {
        linkvertise = LINKVERTISE_API_URL,
        lootlabs = LOOTLABS_API_URL,
        parent = CoreGui,
        onLaunch = function(keyHandler)
            local enteredKey = keyHandler:getKey()
            if isValidKey(enteredKey) and enteredKey == expectedKey then
                keyHandler:close()
                loadScript(enteredKey, expectedKey)
            end
        end,
        onValidation = function(keyHandler)
            local enteredKey = keyHandler:getKey()
            return isValidKey(enteredKey) and enteredKey == expectedKey
        end,
        onClose = function()
            getgenv().initialized = false
        end
    }
end

-- ==================== EKSEKUSI ====================

-- Cegah agar loader tidak dijalankan dua kali
if getgenv().initialized then
    warn("NATIVE IS ALREADY INITIALIZED")
    return
end
getgenv().initialized = true

-- Tunggu hingga game siap
repeat
    task.wait()
until game:IsLoaded()

-- Jalankan loader
initialize()
