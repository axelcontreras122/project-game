-- SwipeController.client.luau

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Client",5):WaitForChild("modules",5)

local LikeEvent = ReplicatedStorage:WaitForChild("LikeEvent",5)

local CardAnimator = require(Modules:WaitForChild("CardAnimator",5))
local CardFactory = require(Modules:WaitForChild("CardFactory",5))
local MatchUI = require(Modules:WaitForChild("MatchUI",5))

local Network = require(ReplicatedStorage:WaitForChild("Shared",5):WaitForChild("Network",5))

local RequestProfileEvent = Network.GetFunction("RequestProfile")

local LocalPlayer = Players.LocalPlayer

local currentCard = nil
local currentCardUserId = nil

local spring = CardAnimator.new(1, 150, 20)

local isDragging = false
local canMove = false
local isProcessingDecision = false
local buttonDebounce = false

local startMousePos = Vector2.new(0, 0)

local threshold = 130
local moveDeadzone = 10

local viewedPlayers = {}
local matchedPlayers = {}
local likedPlayers = {}
local pendingRefresh = false

local searchingLabel = nil

local profileCache = {}

------------------------------------------------
-- SEARCH LABEL
------------------------------------------------

local function updateSearchingLabel(parentGui)

	if not searchingLabel then

		searchingLabel = Instance.new("TextLabel")

		searchingLabel.Size = UDim2.new(1, 0, 0, 100)
		searchingLabel.Position = UDim2.new(0, 0, 0.45, -50)

		searchingLabel.TextColor3 = Color3.fromRGB(150, 150, 150)

		searchingLabel.Font = Enum.Font.GothamMedium
		searchingLabel.TextSize = 18

		searchingLabel.BackgroundTransparency = 1

		searchingLabel.ZIndex = 5

		searchingLabel.Parent = parentGui
	end

	local inServer = #Players:GetPlayers()

	local matchCount = 0

	for _ in pairs(matchedPlayers) do
		matchCount += 1
	end

	searchingLabel.Text =
		"Buscando personas...\n\n--- INFO DEL RADAR ---\nJugadores en esta sala: "
		.. inServer
		.. "\nMatches ocultos: "
		.. matchCount

	local chatFrame = parentGui:FindFirstChild("ChatFrame")

if chatFrame and chatFrame.Visible then
	searchingLabel.Visible = false
else
	searchingLabel.Visible = (currentCard == nil)
end

end

------------------------------------------------
-- MATCH EVENT
------------------------------------------------

LikeEvent.OnClientEvent:Connect(function(senderId, data)

	if data == true then

		matchedPlayers[senderId] = true

		local matchedPlayer = Players:GetPlayerByUserId(senderId)

		if matchedPlayer then

	MatchUI.show({

		Name = matchedPlayer.DisplayName,

		UserId = matchedPlayer.UserId
	})
end
	end
end)

------------------------------------------------
-- NEXT PLAYER
------------------------------------------------

local function getNextRealPlayer()

	local allPlayers = Players:GetPlayers()

	local availablePlayers = {}

	for _, p in ipairs(allPlayers) do

		if p ~= LocalPlayer
	and not viewedPlayers[p.UserId]
	and not matchedPlayers[p.UserId]
	and not likedPlayers[p.UserId]
		then
			table.insert(availablePlayers, p)
		end
	end

	if #availablePlayers == 0 then

		viewedPlayers = {}

		for _, p in ipairs(allPlayers) do

			if p ~= LocalPlayer
	and not matchedPlayers[p.UserId]
	and not likedPlayers[p.UserId]
then
				table.insert(availablePlayers, p)
			end
		end
	end

	if #availablePlayers > 0 then
		return availablePlayers[1]
	end

	return nil
end

------------------------------------------------
-- PLAYER ADDED
------------------------------------------------

local function refreshCards()

	viewedPlayers = {}

	pendingRefresh = false

	if currentCard then

		currentCard:Destroy()

		currentCard = nil

		currentCardUserId = nil
	end

	task.wait()

	loadNextCard()
end

Players.PlayerAdded:Connect(function(player)

	if player == LocalPlayer then
		return
	end

	viewedPlayers[player.UserId] = nil

	------------------------------------------------
	-- REMOVE ALL OLD CARDS
	------------------------------------------------

	local MainGui =
		LocalPlayer.PlayerGui
		:WaitForChild("MainAppGui",5)

	local background =
		MainGui:FindFirstChild("Background")

	if background then

		for _,v in ipairs(background:GetChildren()) do

			if v.Name == "UserCard" then
				v:Destroy()
			end
		end
	end

	currentCard = nil
	currentCardUserId = nil

	task.wait(0.1)

	loadNextCard()
end)
------------------------------------------------
-- LOAD CARD
------------------------------------------------

function loadNextCard()

	local MainGui = LocalPlayer.PlayerGui:WaitForChild("MainAppGui",5)

	if not MainGui then
		return
	end

	if currentCard then
		return
	end

	local targetPlayer = getNextRealPlayer()

	if not targetPlayer then
		updateSearchingLabel(MainGui)
		return
	end

	spring.Position = Vector2.new(0,0)
	spring.Target = Vector2.new(0,0)
	spring.Velocity = Vector2.new(0,0)

	------------------------------------------------
	-- CREATE CARD
	------------------------------------------------

	local profileData =
	profileCache[targetPlayer.UserId]

if not profileData then

	local success, result =
		pcall(function()

			return RequestProfileEvent
				:InvokeServer(
					targetPlayer.UserId
				)
		end)

	if success and result then

		profileData = result

		profileCache[
			targetPlayer.UserId
		] = result

	else

		profileData = {}
	end
end

local playTime =
	(profileData and profileData.PlayTime) or 0

local hours =
	math.floor(playTime / 3600)

local minutes =
	math.floor((playTime % 3600) / 60)

local formattedTime =
	string.format(
		"%02d:%02d",
		hours,
		minutes
	)

currentCard = CardFactory.create({

	UserId = targetPlayer.UserId,

	Name = targetPlayer.DisplayName or targetPlayer.Name,

	Friends = profileData and profileData.Friends or 0,
	Likes = profileData and profileData.Likes or 0,


Hours = formattedTime,

Tags = profileData and profileData.Tags or {},

	Interests = {{
		Name = "Online",
		Color = Color3.fromRGB(46, 204, 113)
	}}
	
})

currentCard.Name = "UserCard"

	local background = MainGui:FindFirstChild("Background")

if background then
	currentCard.Parent = background
else
	currentCard.Parent = MainGui
end

	currentCard.ZIndex = 99999
	currentCard.Position = UDim2.new(0.5, 0, 0.45, 0)

	currentCardUserId = targetPlayer.UserId

	currentCard.Actions.LikeBtn.MouseButton1Click:Connect(function()
		handleDecision("Like", currentCardUserId)
	end)

	currentCard.Actions.RejectBtn.MouseButton1Click:Connect(function()
		handleDecision("Reject", currentCardUserId)
	end)

	updateSearchingLabel(MainGui)
end

------------------------------------------------
-- TRANSITION EFFECT
------------------------------------------------

local function playTransition(direction)

	local MainGui = LocalPlayer.PlayerGui:WaitForChild("MainAppGui",5)

	if not MainGui then
		return
	end

	------------------------------------------------
	-- OVERLAY
	------------------------------------------------

	local overlay = Instance.new("Frame")

	overlay.Size = UDim2.new(1,0,1,0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 200000

	if direction == "Like" then
		overlay.BackgroundColor3 = Color3.fromRGB(57, 255, 20)
	else
		overlay.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	end

	overlay.Parent = MainGui

	------------------------------------------------
	-- ICON
	------------------------------------------------

	local icon = Instance.new("ImageLabel")

	icon.AnchorPoint = Vector2.new(0.5,0.5)
	icon.Position = UDim2.new(0.5,0,0.5,0)

	icon.Size = UDim2.new(0,0,0,0)

	icon.BackgroundTransparency = 1
	icon.ImageTransparency = 1

	icon.ZIndex = 200001

	if direction == "Like" then
		icon.Image = "rbxassetid://122843530438525"
	else
		icon.Image = "rbxassetid://92185118464767"
	end

	icon.Parent = overlay

	------------------------------------------------
	-- ENTRADA SUAVE
	------------------------------------------------

	local fadeIn = TweenService:Create(
		overlay,
		TweenInfo.new(0.15, Enum.EasingStyle.Quad),
		{
			BackgroundTransparency = 0.15
		}
	)

	local iconIn = TweenService:Create(
		icon,
		TweenInfo.new(0.22, Enum.EasingStyle.Back),
		{
			Size = UDim2.new(0,220,0,220),
			ImageTransparency = 0
		}
	)

	fadeIn:Play()
	iconIn:Play()

	------------------------------------------------
	-- SALIDA SUAVE
	------------------------------------------------

	task.delay(0.45, function()

		local fadeOut = TweenService:Create(
			overlay,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad),
			{
				BackgroundTransparency = 1
			}
		)

		local iconOut = TweenService:Create(
			icon,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad),
			{
				Size = UDim2.new(0,320,0,320),
				ImageTransparency = 1
			}
		)

		fadeOut:Play()
		iconOut:Play()

		Debris:AddItem(overlay, 0.4)
	end)
end

------------------------------------------------
-- HANDLE DECISION
------------------------------------------------

function handleDecision(direction, targetUserId)

if buttonDebounce then
		return
	end

	buttonDebounce = true

	if isProcessingDecision then

		buttonDebounce = false
		return
	end

	isProcessingDecision = true

	if not currentCard or not currentCardUserId then
		isProcessingDecision = false
		

		buttonDebounce = false
		return
	end

	isDragging = false
	canMove = false

	viewedPlayers[targetUserId] = true

	local oldCard = currentCard

	------------------------------------------------
	-- LIMPIAR REFERENCIAS
	------------------------------------------------

	currentCard = nil
	currentCardUserId = nil

	spring.Position = Vector2.new(0,0)
spring.Target = Vector2.new(0,0)
spring.Velocity = Vector2.new(0,0)

	------------------------------------------------
	-- EFECTO VISUAL
	------------------------------------------------

	playTransition(direction)

	------------------------------------------------
	-- ANIMACIÓN SWIPE
	------------------------------------------------

	if direction == "Like" then

	likedPlayers[targetUserId] = true

		spring.Target = Vector2.new(2000, 0)

		LikeEvent:FireServer(targetUserId)

	else

		spring.Target = Vector2.new(-2000, 0)
	end

	------------------------------------------------
	-- DESTRUIR TARJETA
	------------------------------------------------

	task.spawn(function()

		task.wait(0.12)

		if oldCard and oldCard.Parent then
			oldCard:Destroy()
		end
	end)

	------------------------------------------------
	-- SIGUIENTE PERFIL
	------------------------------------------------

task.delay(0.2, function()

	if pendingRefresh then

		viewedPlayers = {}

		pendingRefresh = false
	end

	loadNextCard()

	local MainGui = LocalPlayer.PlayerGui:WaitForChild("MainAppGui",5)

	if MainGui then
		updateSearchingLabel(MainGui)
	end

	isProcessingDecision = false
			buttonDebounce = false
end)

end

------------------------------------------------
-- RENDER
------------------------------------------------

RunService.RenderStepped:Connect(function(dt)

if not currentCard then
	return
end

if not currentCard.Parent then

	currentCard = nil
	return
end

	dt = math.min(dt, 0.016)

	local targetPos = Vector2.new(0, 0)

	if isDragging then

		local mousePos = UserInputService:GetMouseLocation()

		if (mousePos - startMousePos).Magnitude > moveDeadzone then
			canMove = true
		end

		if canMove then
			targetPos = Vector2.new(
				mousePos.X - (workspace.CurrentCamera.ViewportSize.X / 2),
				0
			)
		end
	end

	spring.Target = targetPos

	local currentPos = spring:Update(dt)

	if currentPos.X ~= currentPos.X or math.abs(currentPos.X) > 5000 then

		spring.Position = Vector2.new(0,0)

		currentPos = Vector2.new(0,0)
	end

	currentCard.Position = UDim2.new(0.5, currentPos.X, 0.45, 0)

	currentCard.Rotation = currentPos.X / 15
end)

------------------------------------------------
-- INPUT
------------------------------------------------

UserInputService.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		isDragging = true

		startMousePos = UserInputService:GetMouseLocation()
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then

		if canMove
			and math.abs(spring.Position.X) > threshold
			and currentCardUserId
		then

			handleDecision(
				spring.Position.X > 0 and "Like" or "Reject",
				currentCardUserId
			)

		else

			isDragging = false
			canMove = false

			spring.Target = Vector2.new(0, 0)
		end
	end
end)

------------------------------------------------
-- START
------------------------------------------------

task.spawn(function()

	------------------------------------------------
	-- LOAD SAVED MATCHES
	------------------------------------------------

local success, profile =
	pcall(function()

		return RequestProfileEvent:InvokeServer()
	end)

if success and profile and profile.Matches then

	for userIdStr, _ in pairs(profile.Matches) do

		matchedPlayers[
			tonumber(userIdStr)
		] = true
	end
end

	------------------------------------------------
	-- MAIN LOOP
	------------------------------------------------

	while true do

		task.wait(1)

		if not currentCard then
			loadNextCard()
		end
	end
end)