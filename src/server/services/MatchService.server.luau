-- MatchService.server.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")
local TextService = game:GetService("TextService")

local LikeEvent = ReplicatedStorage:WaitForChild("LikeEvent")
local ChatEvent = ReplicatedStorage:WaitForChild("ChatEvent")

local Network = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"))
local SessionManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("modules"):WaitForChild("SessionManager"))

local ChatStore = DataStoreService:GetDataStore("ChatHistory_V1")

local GetChatHistory = Network.GetFunction("GetChatHistory")
local TypingEvent = Network.GetEvent("TypingEvent")
local GetLeaderboard =
	Network.GetFunction("GetLeaderboard")

local function getChatKey(userA, userB)
	return "Chat_" .. tostring(math.min(userA, userB)) .. "_" .. tostring(math.max(userA, userB))
end

local likes = {}

local lastMessageTimes = {}
------------------------------------------------
-- LEADERBOARD
------------------------------------------------

GetLeaderboard.OnServerInvoke = function()

	return SessionManager.GetAllProfiles()
end

TypingEvent.OnServerEvent:Connect(function(player, targetUserId, isTyping)

	if not targetUserId then
		return
	end

	if typeof(isTyping) ~= "boolean" then
	return
end

	------------------------------------------------
-- VERIFY MATCH STILL EXISTS
------------------------------------------------

local playerProfile =
	SessionManager.GetProfile(player.UserId)

if not playerProfile then
	return
end

if not playerProfile.Matches then
	return
end

if not playerProfile.Matches[tostring(targetUserId)] then
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

	if typeof(targetUserId) ~= "number" then
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

	------------------------------------------------
	-- RATE LIMIT
	------------------------------------------------

	local now = tick()

	if lastMessageTimes[player.UserId]
	and now - lastMessageTimes[player.UserId] < 0.5 then
		return
	end

	lastMessageTimes[player.UserId] = now

	if typeof(message) ~= "string" then
	return
end

if typeof(targetId) ~= "number" then
	return
end

message = message:sub(1,200)

if message:match("^%s*$") then
	return
end

	------------------------------------------------
-- VERIFY MATCH STILL EXISTS
------------------------------------------------

local playerProfile =
	SessionManager.GetProfile(player.UserId)

if not playerProfile then
	return
end

if not playerProfile.Matches then
	return
end

if not playerProfile.Matches[tostring(targetId)] then
	return
end

	------------------------------------------------
	-- FILTER MESSAGE
	------------------------------------------------

local senderMessage = message
local targetMessage = message

local success, filterResult =
	pcall(function()

		return TextService:FilterStringAsync(
			message,
			player.UserId
		)
	end)

if success and filterResult then

	local ok1, filteredForSender =
		pcall(function()

			return filterResult:GetChatForUserAsync(
				player.UserId
			)
		end)

	if ok1 and filteredForSender then
		senderMessage = filteredForSender
	end

	local ok2, filteredForTarget =
		pcall(function()

			return filterResult:GetChatForUserAsync(
				targetId
			)
		end)

	if ok2 and filteredForTarget then
		targetMessage = filteredForTarget
	end

else

	senderMessage = "###"
	targetMessage = "###"
end

	local targetPlayer = game.Players:GetPlayerByUserId(targetId)

	local timestamp = os.time()

	ChatEvent:FireClient(
	player,
	player.UserId,
	senderMessage,
	timestamp
)

if targetPlayer then

	ChatEvent:FireClient(
		targetPlayer,
		player.UserId,
		targetMessage,
		timestamp
	)
end

	local key = getChatKey(player.UserId, targetId)

	pcall(function()

		ChatStore:UpdateAsync(key, function(oldHistory)

			local history = type(oldHistory) == "table" and oldHistory or {}

			table.insert(history, {
				senderId = player.UserId,
				message = filteredMessage,
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