-- MatchService.server.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")

local LikeEvent = ReplicatedStorage:WaitForChild("LikeEvent")
local ChatEvent = ReplicatedStorage:WaitForChild("ChatEvent")

local Network = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"))
local SessionManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("modules"):WaitForChild("SessionManager"))

local ChatStore = DataStoreService:GetDataStore("ChatHistory_V1")

local GetChatHistory = Network.GetFunction("GetChatHistory")
local TypingEvent = Network.GetEvent("TypingEvent")

local function getChatKey(userA, userB)
	return "Chat_" .. tostring(math.min(userA, userB)) .. "_" .. tostring(math.max(userA, userB))
end

local likes = {}

GetChatHistory.OnServerInvoke = function(player, targetId)

	local key = getChatKey(player.UserId, targetId)

	local success, data = pcall(function()
		return ChatStore:GetAsync(key) or {}
	end)

	local storedHistory = success and type(data) == "table" and data or {}

	local profile = SessionManager.GetProfile(player.UserId)

	local sessionHistory = {}

	if profile and profile.ChatHistory and profile.ChatHistory[tostring(targetId)] then
		sessionHistory = profile.ChatHistory[tostring(targetId)]
	end

	if #storedHistory == 0 and #sessionHistory > 0 then
		return sessionHistory
	end

	if #sessionHistory > #storedHistory then
		return sessionHistory
	end

	return storedHistory
end

TypingEvent.OnServerEvent:Connect(function(player, targetUserId, isTyping)

	if not targetUserId then
		return
	end

	local targetPlayer = game.Players:GetPlayerByUserId(targetUserId)

	if targetPlayer then
		TypingEvent:FireClient(targetPlayer, player.UserId, isTyping)
	end
end)

------------------------------------------------
-- SISTEMA DE LIKES Y MATCHES
------------------------------------------------

LikeEvent.OnServerEvent:Connect(function(player, targetUserId)

	if not targetUserId then
		return
	end

	if not likes[player.UserId] then
		likes[player.UserId] = {}
	end

	------------------------------------------------
	-- EVITAR DUPLICAR LIKES
	------------------------------------------------

	if likes[player.UserId][targetUserId] then
		return
	end

	------------------------------------------------
	-- GUARDAR LIKE
	------------------------------------------------

	likes[player.UserId][targetUserId] = true

	local targetProfile = SessionManager.GetProfile(targetUserId)

if targetProfile then
	targetProfile.LikesReceived =
		(targetProfile.LikesReceived or 0) + 1
end

	------------------------------------------------
	-- SUMAR LIKE RECIBIDO
	------------------------------------------------

	local targetProfile = SessionManager.GetProfile(targetUserId)

	if targetProfile then
		targetProfile.Likes = (targetProfile.Likes or 0) + 1
	end

	------------------------------------------------
	-- VERIFICAR MATCH
	------------------------------------------------

	if likes[targetUserId] and likes[targetUserId][player.UserId] then

		LikeEvent:FireClient(player, targetUserId, true)

		local targetPlayer = game.Players:GetPlayerByUserId(targetUserId)

		if targetPlayer then
			LikeEvent:FireClient(targetPlayer, player.UserId, true)
		end

		------------------------------------------------
		-- PLAYER PROFILE
		------------------------------------------------

		local playerProfile = SessionManager.GetProfile(player.UserId)

		if playerProfile then

			playerProfile.Matches[tostring(targetUserId)] = true

			playerProfile.FriendsCount =
	(playerProfile.FriendsCount or 0) + 1

			local totalFriends = 0

			for _, _ in pairs(playerProfile.Matches) do
				totalFriends += 1
			end

			playerProfile.Friends = totalFriends
		end

		------------------------------------------------
		-- TARGET PROFILE
		------------------------------------------------

		if targetProfile then

			targetProfile.Matches[tostring(player.UserId)] = true

			targetProfile.FriendsCount =
	(targetProfile.FriendsCount or 0) + 1

			local totalFriends = 0

			for _, _ in pairs(targetProfile.Matches) do
				totalFriends += 1
			end

			targetProfile.Friends = totalFriends
		end
	end
end)

------------------------------------------------
-- CHAT
------------------------------------------------

ChatEvent.OnServerEvent:Connect(function(player, targetId, message)

	if not targetId or message == "" then
		return
	end

	local targetPlayer = game.Players:GetPlayerByUserId(targetId)

	local timestamp = os.time()

	ChatEvent:FireClient(player, player.UserId, message, timestamp)

	if targetPlayer then
		ChatEvent:FireClient(targetPlayer, player.UserId, message, timestamp)
	end

	local key = getChatKey(player.UserId, targetId)

	pcall(function()

		ChatStore:UpdateAsync(key, function(oldHistory)

			local history = type(oldHistory) == "table" and oldHistory or {}

			table.insert(history, {
				senderId = player.UserId,
				message = message,
				timestamp = timestamp
			})

			if #history > 50 then

				local newHistory = {}

				for i = #history - 49, #history do
					table.insert(newHistory, history[i])
				end

				history = newHistory
			end

			return history
		end)
	end)
end)