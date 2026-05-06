-- src/server/services/DataService.server.luau
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileStore = DataStoreService:GetDataStore("AppProfiles_V1")

-- Solución: "Shared" con S mayúscula
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))
local Network = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"))
local SessionManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("modules"):WaitForChild("SessionManager"))

local RequestProfileEvent = Network.GetFunction("RequestProfile")

local DEFAULT_PROFILE: Types.PlayerProfile = {
    UserId = 0,
    Name = "Axel Contreras",
    DisplayName = "Axel Contreras",
    Bio = "¡Hola! Estoy buscando amigos para jugar y desarrollar.",
    Interests = {"Gaming", "Desarrollo web"},
    LikesSent = {},
    Matches = {},
    ChatHistory = {}
}

local function onPlayerAdded(player: Player)
    local success, data = pcall(function()
        return ProfileStore:GetAsync(tostring(player.UserId))
    end)

    local profileData = data or DEFAULT_PROFILE
    profileData.UserId = player.UserId
    if not profileData.Name or profileData.Name == "" or profileData.Name == player.Name then
        profileData.Name = player.DisplayName or player.Name
    end
    profileData.DisplayName = player.DisplayName or player.Name

    if success then
        SessionManager.SetProfile(player.UserId, profileData)
    else
        warn("No se pudo cargar la data de " .. player.Name)
        player:Kick("Error de conexión con la base de datos.")
    end
end

local function onPlayerRemoving(player: Player)
    local data = SessionManager.GetProfile(player.UserId)
    if data then
        local success, err = pcall(function()
            ProfileStore:SetAsync(tostring(player.UserId), data)
        end)
        if not success then
            warn("Fallo al guardar data de " .. player.Name .. ": " .. err)
        end
        SessionManager.RemoveProfile(player.UserId)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

RequestProfileEvent.OnServerInvoke = function(player, targetUserId)
    if targetUserId and tonumber(targetUserId) and tonumber(targetUserId) ~= player.UserId then
        local key = tostring(tonumber(targetUserId))
        local success, data = pcall(function()
            return ProfileStore:GetAsync(key)
        end)
        if success and type(data) == "table" then
            return data
        end
        return nil
    end

    return SessionManager.GetProfile(player.UserId)
end