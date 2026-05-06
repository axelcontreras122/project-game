local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")
local ChatEvent = ReplicatedStorage:WaitForChild("ChatEvent")

local Network = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"))
local SessionManager = require(ServerScriptService:WaitForChild("Server"):WaitForChild("modules"):WaitForChild("SessionManager"))

local ChatStore = DataStoreService:GetDataStore("ChatHistory_V1")
local GetChatHistory = Network.GetFunction("GetChatHistory")
local TypingEvent = Network.GetEvent("TypingEvent")

local function getChatKey(userA, userB)
	return "Chat_" .. tostring(math.min(userA, userB)) .. "_" .. tostring(math.max(userA, userB))
end

local ChatService = {}

GetChatHistory.OnServerInvoke = function(player, targetId)
	local key = getChatKey(player.UserId, targetId)
	local success, data = pcall(function()
		return ChatStore:GetAsync(key) or {}
	end)
	return success and type(data) == "table" and data or {}
end

TypingEvent.OnServerEvent:Connect(function(player, targetUserId, isTyping)
	if not targetUserId then return end
	local targetPlayer = game.Players:GetPlayerByUserId(targetUserId)
	if targetPlayer then
		TypingEvent:FireClient(targetPlayer, player.UserId, isTyping)
	end
end)

-- Chat event handling is centralized in MatchService to prevent duplicate processing
-- ChatService only provides GetChatHistory and TypingEvent support

print("💬 ChatService inicializado en el servidor.")
return ChatService