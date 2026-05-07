-- SwipeController.client.luau

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Client"):WaitForChild("modules")

local LikeEvent = ReplicatedStorage:WaitForChild("LikeEvent")

local CardAnimator = require(Modules:WaitForChild("CardAnimator"))
local CardFactory = require(Modules:WaitForChild("CardFactory"))
local MatchUI = require(Modules:WaitForChild("MatchUI"))

local Network = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"))

local RequestProfileEvent = Network.GetFunction("RequestProfile")

local LocalPlayer = Players.LocalPlayer

local currentCard = nil
local currentCardUserId = nil

local spring = CardAnimator.new(1, 150, 20)

local isDragging = false
local canMove = false

local startMousePos = Vector2.new(0, 0)

local threshold = 130
local moveDeadzone = 10

local viewedPlayers = {}
local matchedPlayers = {}

local searchingLabel = nil

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

		searchingLabel.ZIndex = 9999

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

	searchingLabel.Visible = (currentCard == nil)
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
				Name = matchedPlayer.DisplayName or matchedPlayer.Name
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
		then
			table.insert(availablePlayers, p)
		end
	end

	if #availablePlayers == 0 then

		viewedPlayers = {}

		for _, p in ipairs(allPlayers) do

			if p ~= LocalPlayer and not matchedPlayers[p.UserId] then
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

Players.PlayerAdded:Connect(function(player)

	if player ~= LocalPlayer then

		task.wait(1)

		if not currentCard then
			loadNextCard()
		end
	end
end)

------------------------------------------------
-- LOAD CARD
------------------------------------------------

function loadNextCard()

	local MainGui = LocalPlayer.PlayerGui:FindFirstChild("MainAppGui")

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
	-- GET PROFILE
	------------------------------------------------

	local profile = nil

	pcall(function()
		profile = RequestProfileEvent:InvokeServer(targetPlayer.UserId)
	end)

	profile = profile or {}

	------------------------------------------------
	-- CREATE CARD
	------------------------------------------------

	local profileData = nil

pcall(function()
	profileData = RequestProfileEvent:InvokeServer(targetPlayer.UserId)
end)

currentCard = CardFactory.create({
	UserId = targetPlayer.UserId,
	Name = targetPlayer.DisplayName or targetPlayer.Name,

	Friends = profileData and profileData.FriendsCount or 0,
	Likes = profileData and profileData.LikesReceived or 0,
	Streak = profileData and profileData.LoginStreak or 0,

	Interests = {{
		Name = "Online",
		Color = Color3.fromRGB(46, 204, 113)
	}}
})

	currentCard.Parent = MainGui

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
-- HANDLE DECISION
------------------------------------------------

function handleDecision(direction, targetUserId)

	if not currentCard or not currentCardUserId then
		return
	end

	isDragging = false
	canMove = false

	viewedPlayers[targetUserId] = true

	local cardToDestroy = currentCard

	if direction == "Like" then

		spring.Target = Vector2.new(2000, 0)

		LikeEvent:FireServer(targetUserId)

	else

		spring.Target = Vector2.new(-2000, 0)
	end

	task.spawn(function()

		task.wait(0.3)

		if cardToDestroy then
			cardToDestroy:Destroy()
		end
	end)

	if currentCard == cardToDestroy then

		currentCard = nil
		currentCardUserId = nil
	end

	loadNextCard()
end

------------------------------------------------
-- RENDER
------------------------------------------------

RunService.RenderStepped:Connect(function(dt)

	if not currentCard then
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

	task.spawn(function()

		task.wait(1)

		pcall(function()

			local profile = RequestProfileEvent:InvokeServer()

			if profile and profile.Matches then

				for userIdStr, _ in pairs(profile.Matches) do
					matchedPlayers[tonumber(userIdStr)] = true
				end
			end
		end)
	end)

	while true do

		task.wait(1)

		if not currentCard then
			loadNextCard()
		end
	end
end)