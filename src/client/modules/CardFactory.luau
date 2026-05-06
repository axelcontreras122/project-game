local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants"))

local CardFactory = {}

local function createTag(text, color, parent)
	local tag = Instance.new("Frame")
	tag.BackgroundColor3 = color
	tag.Size = UDim2.new(0, 0, 0, 28) 
	tag.AutomaticSize = Enum.AutomaticSize.X
	tag.Parent = parent
	Instance.new("UICorner", tag).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Text = "  " .. text .. "  "
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 15
	label.Font = Enum.Font.GothamMedium
	label.BackgroundTransparency = 1
	label.Parent = tag
end

function CardFactory.create(playerData)
	local card = Instance.new("CanvasGroup") 
	card.Name = "UserCard"
	card.Size = UDim2.new(0, 360, 0, 620)
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.new(0.5, 0, 0.45, 0)
	card.BackgroundColor3 = Constants.COLORS.CARD
	card.BorderSizePixel = 0
	card.GroupTransparency = 0 
	
	Instance.new("UICorner", card).CornerRadius = Constants.UI_SETTINGS.CORNER_RADIUS

	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "AvatarView"
	viewport.Size = UDim2.new(1, 0, 0.72, 0)
	viewport.BackgroundTransparency = 1
	viewport.Ambient = Color3.fromRGB(180, 180, 180)
	viewport.Parent = card

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport

	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	viewport.CurrentCamera = camera
	camera.Parent = viewport

	task.spawn(function()
		local player = Players:GetPlayerByUserId(playerData.UserId) or Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		character.Archivable = true
		local clono = character:Clone()
		clono.Parent = worldModel
		local hrp = clono:WaitForChild("HumanoidRootPart")
		camera.CFrame = CFrame.new(hrp.Position + (hrp.CFrame.LookVector * 14) + Vector3.new(0, 1.2, 0), hrp.Position + Vector3.new(0, 0.8, 0))
        
        local humanoid = clono:WaitForChild("Humanoid")
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://507766388"
        local track = animator:LoadAnimation(anim)
        track.Looped = true
        track:Play()
	end)

	local infoContainer = Instance.new("Frame")
	infoContainer.Name = "Info"
	infoContainer.Size = UDim2.new(1, -40, 0, 100)
	infoContainer.Position = UDim2.new(0, 25, 0.74, 0)
	infoContainer.BackgroundTransparency = 1
	infoContainer.Parent = card

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 40)
	nameLabel.Text = playerData.Name
	nameLabel.TextColor3 = Constants.COLORS.TEXT
	nameLabel.TextSize = 28
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = infoContainer

	local tagContainer = Instance.new("Frame")
	tagContainer.Size = UDim2.new(1, 0, 0, 35)
	tagContainer.Position = UDim2.new(0, 0, 0, 45)
	tagContainer.BackgroundTransparency = 1
	tagContainer.Parent = infoContainer

	local tagLayout = Instance.new("UIListLayout")
	tagLayout.FillDirection = Enum.FillDirection.Horizontal
	tagLayout.Padding = UDim.new(0, 10)
	tagLayout.Parent = tagContainer

	if playerData.Interests then
		for _, interest in ipairs(playerData.Interests) do
			createTag(interest.Name, interest.Color, tagContainer)
		end
	end

	local btnContainer = Instance.new("Frame")
	btnContainer.Name = "Actions"
	btnContainer.Size = UDim2.new(1, 0, 0, 100)
	btnContainer.Position = UDim2.new(0, 0, 1, -110)
	btnContainer.BackgroundTransparency = 1
	btnContainer.Parent = card

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 75)
	layout.Parent = btnContainer

	local function createBtn(name, color, text)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = UDim2.new(0, 68, 0, 68)
		btn.BackgroundColor3 = color
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 30
		btn.Font = Enum.Font.GothamBold
		btn.Parent = btnContainer
		Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
	end

	createBtn("RejectBtn", Color3.fromRGB(231, 76, 60), "✕")
	createBtn("LikeBtn", Color3.fromRGB(46, 204, 113), "♥")

	return card
end

return CardFactory