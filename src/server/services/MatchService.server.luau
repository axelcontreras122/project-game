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

	-- If DataStore is empty or unavailable, keep the local session history.
	if #storedHistory == 0 and #sessionHistory > 0 then
		return sessionHistory
	end

	-- If session history is longer than stored history, return it as the most up-to-date copy.
	if #sessionHistory > #storedHistory then
		return sessionHistory
	end

	return storedHistory
end

TypingEvent.OnServerEvent:Connect(function(player, targetUserId, isTyping)
	if not targetUserId then return end
	local targetPlayer = game.Players:GetPlayerByUserId(targetUserId)
	if targetPlayer then
		TypingEvent:FireClient(targetPlayer, player.UserId, isTyping)
	end
end)

-- 1. SISTEMA DE LIKES Y MATCHES
LikeEvent.OnServerEvent:Connect(function(player, targetUserId)
	if not targetUserId then return end
	if not likes[player.UserId] then likes[player.UserId] = {} end
	
	-- Guardamos el Like
	likes[player.UserId][targetUserId] = true
	
	-- Verificamos si es mutuo (Match)
	if likes[targetUserId] and likes[targetUserId][player.UserId] then
		-- Disparamos el evento para que aparezca en el panel de ambos
		LikeEvent:FireClient(player, targetUserId, true)
		
		local targetPlayer = game.Players:GetPlayerByUserId(targetUserId)
		if targetPlayer then
			LikeEvent:FireClient(targetPlayer, player.UserId, true)
		end
		
		-- Guardar el match en los perfiles
		local playerProfile = SessionManager.GetProfile(player.UserId)
		if playerProfile then
			playerProfile.Matches[tostring(targetUserId)] = true
		end
		
		local targetProfile = SessionManager.GetProfile(targetUserId)
		if targetProfile then
			targetProfile.Matches[tostring(player.UserId)] = true
		end
	end
end)

-- 2. SISTEMA DE CHAT (Rebote de mensajes)
ChatEvent.OnServerEvent:Connect(function(player, targetId, message)
	if not targetId or message == "" then return end
	
	local targetPlayer = game.Players:GetPlayerByUserId(targetId)
	local timestamp = os.time()

	-- Devolver para que se pinte en tu pantalla siempre
	ChatEvent:FireClient(player, player.UserId, message, timestamp)

	if targetPlayer then
		ChatEvent:FireClient(targetPlayer, player.UserId, message, timestamp)
	end

	-- Guardar en DataStore para que la historia persista
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