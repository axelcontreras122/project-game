local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ChatEvent = ReplicatedStorage:WaitForChild("ChatEvent")
local LikeEvent = ReplicatedStorage:WaitForChild("LikeEvent")
local OpenChatEvent =
	ReplicatedStorage
	:WaitForChild("OpenChatEvent")

local RemoveMatchEvent =
	ReplicatedStorage
	:WaitForChild("RemoveMatchEvent")

	local MatchRemovedEvent =
	ReplicatedStorage
	:WaitForChild("MatchRemovedEvent")

local Modules = ReplicatedStorage:WaitForChild("Client"):WaitForChild("modules")
local ChatUI = require(Modules:WaitForChild("ChatUI"))
local NotificationUI =
	require(
		ReplicatedStorage
		.Client
		.modules
		.NotificationUI
	)

local MatchListUI = require(Modules:WaitForChild("MatchListUI"))

local Network = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"))
local RequestProfileEvent = Network.GetFunction("RequestProfile")
local GetChatHistory = Network.GetFunction("GetChatHistory")
local TypingEvent = Network.GetEvent("TypingEvent")

local LocalPlayer = Players.LocalPlayer
local chatPanel, currentScroll, chatTargetId, currentTypingLabel
local matchesSaved = {} -- Aquí se guardan los matches sin perderse
local unreadMessages = {}
local playerNameCache = {}
local chatHistoryCache = {}

-- Store event connections to disconnect them later
local inputTextConnection
local inputFocusLostConnection
local sendBtnConnection

local function getPlayerName(userId)
	if playerNameCache[userId] then
		return playerNameCache[userId]
	end
	-- 1. Intentar obtener el apodo del jugador online
	local p = game:GetService("Players"):GetPlayerByUserId(userId)
	if p then
				playerNameCache[userId] =
			tostring(p.DisplayName)

		return playerNameCache[userId]
	end

	-- 2. Obtener el apodo real de los servidores de Roblox (para los que están offline)
	local success, info = pcall(function()
		return game:GetService("UserService"):GetUserInfosByUserIdsAsync({userId})
	end)
	if success and info and info[1] then
			playerNameCache[userId] =
			tostring(info[1].DisplayName)

		return playerNameCache[userId]
end

	-- 3. Respaldo por si fallan los servidores de Roblox
	local profile = nil
	pcall(function()
		profile = RequestProfileEvent:InvokeServer(userId)
	end)
	
	if profile then

	if profile.DisplayName then

		playerNameCache[userId] =
			tostring(profile.DisplayName)

		return playerNameCache[userId]
	end

	if profile.Name then

		playerNameCache[userId] =
			tostring(profile.Name)

		return playerNameCache[userId]
	end
end

		playerNameCache[userId] = "Usuario"

	return playerNameCache[userId]
end

-- 📱💻 Responsivo: Adaptación a Celular y PC
local function updateLayoutForDevice()
	if not chatPanel then return end
	local screenWidth = workspace.CurrentCamera.ViewportSize.X
	
	if screenWidth < 800 then
		-- Celular
		chatPanel.Size = UDim2.new(0.9, 0, 0.8, 0)
		chatPanel.Position = UDim2.new(0.5, 0, 0.45, 0)
		chatPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	else
		-- PC
		chatPanel.Size = UDim2.new(0, 360, 0, 620)
		chatPanel.Position = UDim2.new(0.5, 200, 0.45, 0)
		chatPanel.AnchorPoint = Vector2.new(0, 0.5)
	end
end

-- ✏️ Dibujar la Lista de Chats
local function renderMatchList()
	if not chatPanel then return end
	chatPanel:ClearAllChildren()
	Instance.new("UICorner", chatPanel).CornerRadius = UDim.new(0, 24)
	
	chatTargetId = nil
	currentScroll = nil
	currentTypingLabel = nil
	
	local scroll = Instance.new("ScrollingFrame", chatPanel)
	scroll.Name = "MatchListScroll"
	scroll.Size = UDim2.new(1, 0, 1, -20)
	scroll.Position = UDim2.new(0, 0, 0, 10)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 0
	scroll.CanvasSize = UDim2.new(0,0,0,0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ZIndex = 1005
	
	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 5)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local hasMatches = false
	for id, data in pairs(matchesSaved) do
		hasMatches = true
		local isOnline = Players:GetPlayerByUserId(id) ~= nil
		MatchListUI.createEntry(

	scroll,

	data,

	isOnline,

	unreadMessages[id],

	function()
			chatTargetId = id
			unreadMessages[id] = nil
			chatPanel:ClearAllChildren()
			Instance.new("UICorner", chatPanel).CornerRadius = UDim.new(0, 24)
			
			-- Disconnect any existing event handlers
			if inputTextConnection then inputTextConnection:Disconnect() end
			if inputFocusLostConnection then inputFocusLostConnection:Disconnect() end
			if sendBtnConnection then sendBtnConnection:Disconnect() end
			
			local s, input, sendBtn, typingLabel = ChatUI.setupChatElements(
	chatPanel,
	data.DisplayName or data.Name,
	renderMatchList,
	isOnline,
	id
)
			currentScroll = s
			currentTypingLabel = typingLabel

			ChatUI.OnDeleteMatch = function()

	------------------------------------------------
	-- REMOVE MATCH SERVER
	------------------------------------------------

	RemoveMatchEvent:FireServer(id)

	------------------------------------------------
	-- LOCAL CLEANUP
	------------------------------------------------

	matchesSaved[id] = nil

	unreadMessages[id] = nil

	chatTargetId = nil

	renderMatchList()
end
			
			-- Cargar historial de chat
			local history =
	chatHistoryCache[id]

if not history then

	history = {}

	if GetChatHistory then

		local success, result =
			pcall(function()

				return GetChatHistory
					:InvokeServer(id)
			end)

		if success and type(result) == "table" then

			history = result

			chatHistoryCache[id] =
				result
		end
	end
end

			for _, msgData in ipairs(history) do
				ChatUI.addMessage(currentScroll, msgData.message, (msgData.senderId == LocalPlayer.UserId), msgData.timestamp, msgData.senderId)
			end
			-- Scroll to bottom
			task.defer(function()
				currentScroll.CanvasPosition = Vector2.new(0, math.max(0, currentScroll.AbsoluteCanvasSize.Y - currentScroll.AbsoluteSize.Y))
			end)
			
			local lastTyping = false
			local function updateTypingState()
				local isTyping = input:IsFocused() and input.Text ~= ""
				if isTyping ~= lastTyping then
					lastTyping = isTyping
					TypingEvent:FireServer(id, isTyping)
				end
			end

			local function sendMessage()
				local msgText = input.Text
				if msgText and msgText:match("^%s*$") == nil and msgText ~= "" then
					input.Text = ""
					ChatEvent:FireServer(id, msgText)


					if lastTyping then
						lastTyping = false
						TypingEvent:FireServer(id, false)
					end
				end
			end
			
			inputTextConnection = input:GetPropertyChangedSignal("Text"):Connect(function()
				local hasNewline = input.Text:find("\n")
				if hasNewline then
					sendMessage()
					input.Text = ""
				end
				updateTypingState()
			end)
			
			inputFocusLostConnection = input.FocusLost:Connect(function(enterPressed)
				if enterPressed then
					sendMessage()
				end
				if lastTyping then
					lastTyping = false
					TypingEvent:FireServer(id, false)
				end
			end)
			
			sendBtnConnection = sendBtn.MouseButton1Click:Connect(function()
				sendMessage()
				input:CaptureFocus()
			end)
		end)
	end
	
	-- Aviso de chats vacíos
	if not hasMatches then
		local lbl = Instance.new("TextLabel", chatPanel)
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.Text = "No tienes chats aún."
		lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 14
		lbl.BackgroundTransparency = 1
		lbl.ZIndex = 1010
	end
end

-- 🚀 Crear el Panel Correctamente (Restaurado)
local function initPanel()
	local mainGui = LocalPlayer.PlayerGui:WaitForChild("MainAppGui")
	local bg = mainGui:WaitForChild("Background")
	
	-- Creación segura para evitar que el script se congele
	chatPanel = bg:FindFirstChild("RightAppPanel")
	if not chatPanel then
		chatPanel = Instance.new("Frame")
		chatPanel.Name = "RightAppPanel"
		chatPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
		chatPanel.BorderSizePixel = 0
		chatPanel.Visible = false
		chatPanel.ZIndex = 1000
		chatPanel.Parent = bg
		Instance.new("UICorner", chatPanel).CornerRadius = UDim.new(0, 24)
	end
	
	updateLayoutForDevice()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateLayoutForDevice)
end

-- 📡 Eventos del Servidor
LikeEvent.OnClientEvent:Connect(function(matchedUserId, isMatch)
	if isMatch == true then
		local name = getPlayerName(matchedUserId)
		if name == "Usuario" then
			local profile = RequestProfileEvent:InvokeServer(matchedUserId)
			if profile then
				name = profile.DisplayName or profile.Name or name
			end
		end
		matchesSaved[matchedUserId] = {UserId = matchedUserId, Name = name, DisplayName = name}
		
		if chatPanel and chatPanel.Visible then
			renderMatchList()
		end
	end
end)

ChatEvent.OnClientEvent:Connect(function(senderId, message, timestamp)

	if not chatHistoryCache[senderId] then
		chatHistoryCache[senderId] = {}
	end

table.insert(
	chatHistoryCache[senderId],
	{
		senderId = senderId,
		message = message,
		timestamp = timestamp
	}
)

if #chatHistoryCache[senderId] > 50 then

	table.remove(
		chatHistoryCache[senderId],
		1
	)
end

	if currentScroll and (senderId == chatTargetId or senderId == LocalPlayer.UserId) then
		ChatUI.addMessage(currentScroll, message, (senderId == LocalPlayer.UserId), timestamp, senderId)
		-- Scroll to bottom
		task.defer(function()
			currentScroll.CanvasPosition = Vector2.new(0, math.max(0, currentScroll.AbsoluteCanvasSize.Y - currentScroll.AbsoluteSize.Y))
			
		end)
	end
	------------------------------------------------
	-- MOVE CHAT TO TOP
	------------------------------------------------

	if senderId ~= LocalPlayer.UserId then

		local oldData = matchesSaved[senderId]

		if oldData then

			matchesSaved[senderId] = nil

			local reordered = {
				[senderId] = oldData
			}

			for id,data in pairs(matchesSaved) do
				reordered[id] = data
			end

			matchesSaved = reordered
		end

		------------------------------------------------
		-- UNREAD
		------------------------------------------------

		if senderId ~= chatTargetId then
			unreadMessages[senderId] = true
		end
	end

		------------------------------------------------
	-- NOTIFICATION
	------------------------------------------------

	if senderId ~= LocalPlayer.UserId
	and senderId ~= chatTargetId then

		local senderName =
			getPlayerName(senderId)

		NotificationUI.show({

			Name = senderName,

			UserId = senderId,

			Message = message,

			OnClick = function()

				chatPanel.Visible = true

				OpenChatEvent:Fire(senderId)
			end
		})
	end


end)

TypingEvent.OnClientEvent:Connect(function(senderId, isTyping)

	if currentTypingLabel and senderId == chatTargetId then
		currentTypingLabel.Text =
			isTyping and "Escribiendo..." or ""
	end
end)

------------------------------------------------
-- OPEN CHAT EVENT
------------------------------------------------

OpenChatEvent.Event:Connect(function(userId)

	if not chatPanel then
		return
	end

	local data = matchesSaved[userId]

	if not data then
		return
	end

	chatPanel.Visible = true

	chatTargetId = userId

	chatPanel:ClearAllChildren()

	Instance.new("UICorner", chatPanel)
		.CornerRadius = UDim.new(0,24)

	local isOnline =
		Players:GetPlayerByUserId(userId) ~= nil

	local s,input,sendBtn,typingLabel =
		ChatUI.setupChatElements(
	chatPanel,
	data.DisplayName or data.Name,
	renderMatchList,
	isOnline,
	userId
)
	currentScroll = s
	currentTypingLabel = typingLabel

ChatUI.OnDeleteMatch = function()

	------------------------------------------------
	-- REMOVE MATCH SERVER
	------------------------------------------------

	RemoveMatchEvent:FireServer(userId)

	------------------------------------------------
	-- LOCAL CLEANUP
	------------------------------------------------

	matchesSaved[userId] = nil

	unreadMessages[userId] = nil

	chatTargetId = nil

	renderMatchList()
end

	local history =
	chatHistoryCache[userId]

if not history then

	history = {}

	if GetChatHistory then

		local success, result =
			pcall(function()

				return GetChatHistory
					:InvokeServer(userId)
			end)

		if success and type(result) == "table" then

			history = result

			chatHistoryCache[userId] =
	result
		end
	end
end

	for _,msgData in ipairs(history) do

		ChatUI.addMessage(
			currentScroll,
			msgData.message,
			(msgData.senderId == LocalPlayer.UserId),
			msgData.timestamp,
			msgData.senderId
		)
	end

	task.defer(function()

		currentScroll.CanvasPosition =
			Vector2.new(
				0,
				math.max(
					0,
					currentScroll.AbsoluteCanvasSize.Y
					-
					currentScroll.AbsoluteSize.Y
				)
			)
	end)
end)



-- 🔌 Conectar Botón e Iniciar (Restaurado)
task.spawn(function()
	initPanel()
	
	-- Cargar matches existentes del perfil
	local profile = RequestProfileEvent:InvokeServer()
	if profile and profile.Matches then
		for userIdStr, _ in pairs(profile.Matches) do
			local userId = tonumber(userIdStr)
			if userId then
				local name = getPlayerName(userId)
				if name == "Usuario" then
					local otherProfile = RequestProfileEvent:InvokeServer(userId)
					if otherProfile then
						name = otherProfile.DisplayName or otherProfile.Name or name
					end
				end
				matchesSaved[userId] = {UserId = userId, Name = name, DisplayName = name}
			end
		end
	end
	
	-- Esta es la conexión que te borré por error y rompía el botón
	local mainGui = LocalPlayer.PlayerGui:WaitForChild("MainAppGui")
	local bg = mainGui:WaitForChild("Background")
	local nav = bg:WaitForChild("NavBar")
	local chatBtn = nav:WaitForChild("ChatBtn")
	
	chatBtn.MouseButton1Click:Connect(function()
		chatPanel.Visible = not chatPanel.Visible
		if chatPanel.Visible then 
			renderMatchList() 
		end
	end)
end)

------------------------------------------------
-- REALTIME ONLINE STATUS
------------------------------------------------

local function refreshChatStatuses()

	if not chatPanel then
		return
	end

	if not chatPanel.Visible then
		return
	end

	------------------------------------------------
	-- ONLY REFRESH MATCH LIST
	------------------------------------------------

	if not chatTargetId then

		renderMatchList()
	end
end

------------------------------------------------
-- MATCH REMOVED REALTIME
------------------------------------------------
MatchRemovedEvent.OnClientEvent:Connect(function(removedUserId)

	------------------------------------------------
	-- REMOVE LOCAL DATA
	------------------------------------------------

	matchesSaved[removedUserId] = nil

	unreadMessages[removedUserId] = nil

	------------------------------------------------
	-- CLOSE ACTIVE CHAT
	------------------------------------------------

	if chatTargetId == removedUserId then

		chatTargetId = nil

		currentScroll = nil

		currentTypingLabel = nil

			------------------------------------------------
	-- DISCONNECT CHAT EVENTS
	------------------------------------------------

	if inputTextConnection then
		inputTextConnection:Disconnect()
	end

	if inputFocusLostConnection then
		inputFocusLostConnection:Disconnect()
	end

	if sendBtnConnection then
		sendBtnConnection:Disconnect()
	end

		renderMatchList()
	end

	------------------------------------------------
	-- REFRESH UI
	------------------------------------------------

	if chatPanel and chatPanel.Visible then

		renderMatchList()
	end
end)

Players.PlayerAdded:Connect(function()

	task.wait(1)

	refreshChatStatuses()
end)

Players.PlayerRemoving:Connect(function()

	task.wait(1)

	refreshChatStatuses()
end)