-- DataService.server.luau

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local ProfileStore = DataStoreService:GetDataStore("AppProfiles_V1")

local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))
local Network = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"))
local SessionManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("modules"):WaitForChild("SessionManager"))

local RequestProfileEvent = Network.GetFunction("RequestProfile")

local function createDefaultProfile()
	return {
		UserId = 0,
		Name = "",
		DisplayName = "",
		Bio = "",
		Interests = {},

		FriendsCount = 0,
		LikesReceived = 0,
		LoginStreak = 1,
		LastLogin = os.time(),

		LikesSent = {},
		Matches = {},
		ChatHistory = {}
	}
end

local function onPlayerAdded(player: Player)

	local success, data = pcall(function()
		return ProfileStore:GetAsync(tostring(player.UserId))
	end)

	local profileData = (success and type(data) == "table") and data or createDefaultProfile()

	profileData.UserId = player.UserId

	if not profileData.Name or profileData.Name == "" or profileData.Name == player.Name then
		profileData.Name = player.DisplayName or player.Name
	end

	profileData.DisplayName = player.DisplayName or player.Name

	------------------------------------------------
	-- ASEGURAR CAMPOS NUEVOS
	------------------------------------------------

	profileData.Likes = profileData.Likes or 0
	profileData.Friends = profileData.Friends or 0

	profileData.Streak = profileData.Streak or 1
	profileData.LastLoginDay = profileData.LastLoginDay or os.date("%Y-%m-%d")

	------------------------------------------------
	-- SISTEMA DE STREAK
	------------------------------------------------

	local today = os.date("%Y-%m-%d")

	if profileData.LastLoginDay ~= today then

		local year = tonumber(string.sub(profileData.LastLoginDay,1,4))
		local month = tonumber(string.sub(profileData.LastLoginDay,6,7))
		local day = tonumber(string.sub(profileData.LastLoginDay,9,10))

		local lastTime = os.time({
			year = year,
			month = month,
			day = day
		})

		local currentTime = os.time()

		local diffDays = math.floor((currentTime - lastTime) / 86400)

		if diffDays == 1 then
			profileData.Streak += 1
		elseif diffDays > 1 then
			profileData.Streak = 1
		end

		profileData.LastLoginDay = today
	end

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
			warn("Fallo al guardar data de " .. player.Name .. ": " .. tostring(err))
		end

		SessionManager.RemoveProfile(player.UserId)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

game:BindToClose(function()

	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerRemoving(player)
	end

	if RunService:IsStudio() then
		task.wait(2)
	end
end)

RequestProfileEvent.OnServerInvoke = function(player, targetUserId)

	if targetUserId and tonumber(targetUserId) and tonumber(targetUserId) ~= player.UserId then

		local key = tostring(tonumber(targetUserId))

		local success, data = pcall(function()
			return ProfileStore:GetAsync(key)
		end)

	if success and type(data) == "table" then

	local matchCount = 0

	if data.Matches then
		for _, _ in pairs(data.Matches) do
			matchCount += 1
		end
	end

	data.FriendsCount = matchCount
	data.LikesReceived = data.LikesReceived or 0
	data.LoginStreak = data.LoginStreak or 1

	return data
end

		return nil
	end

	local profile = SessionManager.GetProfile(player.UserId)

if profile then

	local matchCount = 0

	if profile.Matches then
		for _, _ in pairs(profile.Matches) do
			matchCount += 1
		end
	end

	profile.FriendsCount = matchCount
	profile.LikesReceived = profile.LikesReceived or 0
	profile.LoginStreak = profile.LoginStreak or 1
end

return profile
end