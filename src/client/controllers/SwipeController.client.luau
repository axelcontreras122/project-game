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

local LocalPlayer = Players.LocalPlayer
local currentCard = nil
local currentCardUserId = nil
local spring = CardAnimator.new(1, 150, 20)
local isDragging, canMove = false, false
local startMousePos = Vector2.new(0, 0)
local threshold, moveDeadzone = 130, 10
local viewedPlayers = {} -- Track which players we've already shown

--- === LÓGICA DE MATCH (LIMPIA Y DIRECTA) === ---
LikeEvent.OnClientEvent:Connect(function(senderId, data)
	-- Si es true, hubo Match.
	-- SOLO mostramos la UI central. El ChatController ahora escucha esto por su cuenta.
	if data == true then
		local matchedPlayer = Players:GetPlayerByUserId(senderId)
		if matchedPlayer then
			MatchUI.show({Name = matchedPlayer.DisplayName or matchedPlayer.Name})
		end
	end
end)

--- === LÓGICA DE TARJETAS Y SWIPE === ---
local function getNextRealPlayer()
	local allPlayers = Players:GetPlayers()
	local availablePlayers = {}
	
	-- Get all players except LocalPlayer who haven't been viewed yet
	for _, p in ipairs(allPlayers) do
		if p ~= LocalPlayer and not viewedPlayers[p.UserId] then
			table.insert(availablePlayers, p)
		end
	end
	
	-- If all players have been viewed, reset the list
	if #availablePlayers == 0 then
		viewedPlayers = {}
		for _, p in ipairs(allPlayers) do
			if p ~= LocalPlayer then
				table.insert(availablePlayers, p)
			end
		end
	end
	
	if #availablePlayers > 0 then
		return availablePlayers[1]
	end
	return nil
end

-- Listen for new players joining
Players.PlayerAdded:Connect(function(player)
	-- If a new player joins and we have an active card, refresh the pool
	if player ~= LocalPlayer and currentCard then
		-- New player is automatically available since they're not in viewedPlayers
	end
end)

function loadNextCard()
	local MainGui = LocalPlayer.PlayerGui:WaitForChild("MainAppGui")
	local background = MainGui:WaitForChild("Background")
	local container = background:WaitForChild("CentralContainer")
	
	if currentCard or not container.Visible then return end
	
	local targetPlayer = getNextRealPlayer()
	if not targetPlayer then return end

	currentCard = CardFactory.create({
		UserId = targetPlayer.UserId, 
		Name = targetPlayer.DisplayName or targetPlayer.Name, 
		Interests = {{Name = "Online", Color = Color3.fromRGB(46, 204, 113)}}
	})
	currentCardUserId = targetPlayer.UserId
	
	currentCard.Parent = container
	
	currentCard.Actions.LikeBtn.MouseButton1Click:Connect(function() 
		handleDecision("Like", currentCardUserId) 
	end)
	
	currentCard.Actions.RejectBtn.MouseButton1Click:Connect(function() 
		handleDecision("Reject", currentCardUserId) 
	end)
	
	spring.Position, spring.Target, spring.Velocity = Vector2.new(0,0), Vector2.new(0,0), Vector2.new(0,0)
end

function handleDecision(direction, targetUserId)
	if not currentCard or not currentCardUserId then return end
	isDragging, canMove = false, false
	
	-- Mark this player as viewed
	viewedPlayers[targetUserId] = true
	
	local fadeTween = TweenService:Create(currentCard, TweenInfo.new(0.3), {GroupTransparency = 1})
	
	if direction == "Like" then
		spring.Target = Vector2.new(1200, 0)
		LikeEvent:FireServer(targetUserId)
	else
		spring.Target = Vector2.new(-1200, 0)
	end
	
	fadeTween:Play()
	fadeTween.Completed:Connect(function()
		if currentCard then 
			currentCard:Destroy() 
			currentCard = nil
			currentCardUserId = nil
		end
		loadNextCard()
	end)
end

--- === BUCLE DE RENDERIZADO Y ENTRADA === ---
RunService.RenderStepped:Connect(function(dt)
	if not currentCard then return end
	
	local targetPos = Vector2.new(0, 0)
	
	if isDragging then
		local mousePos = UserInputService:GetMouseLocation()
		if (mousePos - startMousePos).Magnitude > moveDeadzone then 
			canMove = true 
		end
		
		if canMove then 
			targetPos = Vector2.new(mousePos.X - (workspace.CurrentCamera.ViewportSize.X / 2), 0) 
		end
	end
	
	spring.Target = targetPos
	local currentPos = spring:Update(dt)
	
	currentCard.Position = UDim2.new(0.5, currentPos.X, 0.5, currentPos.Y)
	currentCard.Rotation = currentPos.X / 15
end)

UserInputService.InputBegan:Connect(function(input) 
	if input.UserInputType == Enum.UserInputType.MouseButton1 then 
		isDragging = true
		startMousePos = UserInputService:GetMouseLocation() 
	end 
end)

UserInputService.InputEnded:Connect(function(input) 
	if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then 
		if canMove and math.abs(spring.Position.X) > threshold and currentCardUserId then
			handleDecision(spring.Position.X > 0 and "Like" or "Reject", currentCardUserId)
		else 
			isDragging, canMove = false, false 
			spring.Target = Vector2.new(0, 0)
		end 
	end 
end)

task.spawn(function() 
	while true do 
		task.wait(2) 
		if not currentCard then loadNextCard() end 
	end 
end)