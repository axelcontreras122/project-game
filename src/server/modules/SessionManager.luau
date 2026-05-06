-- src/server/modules/SessionManager.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))

local SessionManager = {}
local activeProfiles: {[number]: Types.PlayerProfile} = {}

function SessionManager.GetProfile(userId: number): Types.PlayerProfile?
    return activeProfiles[userId]
end

function SessionManager.SetProfile(userId: number, profileData: Types.PlayerProfile)
    activeProfiles[userId] = profileData
end

function SessionManager.RemoveProfile(userId: number)
    activeProfiles[userId] = nil
end

-- ESTA LÍNEA ES LA QUE TE ESTÁ DANDO EL ERROR SI FALTA O SI NO HAS GUARDADO
return SessionManager