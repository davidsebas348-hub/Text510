repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

repeat task.wait() until LocalPlayer
repeat task.wait() until LocalPlayer.Character
repeat task.wait() until LocalPlayer.Character:FindFirstChild("Humanoid")

task.wait(2)

-- ======================
-- CONFIGURACIÓN
-- ======================

local GUN_NAME = "GunDrop"

if _G.GunESPActive == nil then
    _G.GunESPActive = false
end

-- ======================
-- TOGGLE: DESACTIVAR
-- ======================

if _G.GunESPActive then
    _G.GunESPActive = false

    -- Detener vigilancia periódica
    if _G._GunESPWatchdog then
        task.cancel(_G._GunESPWatchdog)
        _G._GunESPWatchdog = nil
    end

    -- Desconectar eventos
    if _G._GunESPConnections then
        for _, connection in ipairs(_G._GunESPConnections) do
            connection:Disconnect()
        end
        _G._GunESPConnections = nil
    end

    -- Destruir elementos visuales
    if _G._GunESPObjects then
        for _, obj in ipairs(_G._GunESPObjects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        _G._GunESPObjects = nil
    end

    -- Quitar etiquetas anti-duplicados
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == GUN_NAME then
            local tag = obj:FindFirstChild("GunESP_Active")
            if tag then
                tag:Destroy()
            end
        end
    end

    print("Gun ESP desactivado")
    return
end

-- ======================
-- ACTIVAR
-- ======================

_G.GunESPActive = true
_G._GunESPObjects = {}
_G._GunESPConnections = {}

local monitored = setmetatable({}, {__mode = "k"})

print("Gun ESP activado")

-- ======================
-- APLICAR ESP
-- ======================

local function applyESP(gun)
    if not _G.GunESPActive then return end
    if not gun or not gun.Parent then return end

    if gun:FindFirstChild("GunESP_Active") then
        return
    end

    local tag = Instance.new("BoolValue")
    tag.Name = "GunESP_Active"
    tag.Parent = gun

    local highlight = Instance.new("Highlight")
    highlight.Name = "GunESP_Highlight"
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = gun
    highlight.Parent = gun

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GunESP_Billboard"
    billboard.Size = UDim2.new(0, 120, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = gun
    billboard.Parent = gun

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.fromRGB(255, 255, 0)
    text.TextStrokeTransparency = 0
    text.Text = "DROPPED\nGUN"
    text.Parent = billboard

    table.insert(_G._GunESPObjects, highlight)
    table.insert(_G._GunESPObjects, billboard)
end

-- ======================
-- VIGILAR MAPAS
-- ======================

local function monitorModel(model)
    if not _G.GunESPActive then return end
    if not model:IsA("Model") then return end
    if not model:FindFirstChild("Spawns") then return end
    if monitored[model] then return end

    monitored[model] = true

    for _, obj in ipairs(model:GetDescendants()) do
        if obj.Name == GUN_NAME and obj:IsA("BasePart") then
            applyESP(obj)
        end
    end

    local connection = model.DescendantAdded:Connect(function(obj)
        if not _G.GunESPActive then return end

        if obj.Name == GUN_NAME and obj:IsA("BasePart") then
            applyESP(obj)
        end
    end)

    table.insert(_G._GunESPConnections, connection)
end

-- Mapas existentes
for _, child in ipairs(Workspace:GetChildren()) do
    monitorModel(child)
end

-- Mapas nuevos
local mapConnection = Workspace.ChildAdded:Connect(function(child)
    task.wait(0.1)

    if _G.GunESPActive then
        monitorModel(child)
    end
end)

table.insert(_G._GunESPConnections, mapConnection)

-- ======================
-- RECUPERACIÓN CADA 5 SEGUNDOS
-- ======================

_G._GunESPWatchdog = task.spawn(function()
    while _G.GunESPActive do
        task.wait(5)

        if not _G.GunESPActive then
            break
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not _G.GunESPActive then
                break
            end

            if obj:IsA("BasePart") and obj.Name == GUN_NAME then
                applyESP(obj)
            end
        end
    end
end)

print("Gun ESP listo: vigilancia activada")
