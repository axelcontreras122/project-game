local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants"))

local CardFactory = {}

local function createTag(text, color, parent)

	local tag = Instance.new("Frame")
	tag.BackgroundColor3 = color
	tag.Size = UDim2.new(0, 0, 0, 28)
	tag.AutomaticSize = Enum.AutomaticSize.X
	tag.ZIndex = 100002
	tag.Parent = parent

	Instance.new("UICorner", tag).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Text = "  " .. text .. "  "
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 15
	label.Font = Enum.Font.GothamMedium
	label.BackgroundTransparency = 1
	label.ZIndex = 100003
	label.Parent = tag
end

function CardFactory.create(playerData)

	local card = Instance.new("Frame")
	card.Name = "UserCard"
	card.Size = UDim2.new(0, 360, 0, 620)
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.new(0.5, 0, 0.45, 0)
	card.BackgroundColor3 = Constants.COLORS.CARD
	card.BorderSizePixel = 0
	card.ClipsDescendants = false
	card.ZIndex = 99999

	Instance.new("UICorner", card).CornerRadius = Constants.UI_SETTINGS.CORNER_RADIUS

	----------------------------------------------------------------
	-- VIEWPORT
	----------------------------------------------------------------

	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "AvatarView"
	viewport.Size = UDim2.new(1, 0, 0.68, 0)
	viewport.BackgroundTransparency = 1
	viewport.Ambient = Color3.fromRGB(180, 180, 180)
	viewport.BorderSizePixel = 0
	viewport.ZIndex = 100000
	viewport.Parent = card

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport

	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	task.spawn(function()

		local player = Players:GetPlayerByUserId(playerData.UserId)

		if not player then
			player = Players.LocalPlayer
		end

		local character = player.Character or player.CharacterAdded:Wait()

		character.Archivable = true

		local clono = character:Clone()
		clono.Parent = worldModel

		local hrp = clono:WaitForChild("HumanoidRootPart")

	camera.CFrame = CFrame.new(
	hrp.Position + (hrp.CFrame.LookVector * 14) + Vector3.new(0, 2.0, 0),
	hrp.Position + Vector3.new(0, 1.4, 0)
)

		local humanoid = clono:WaitForChild("Humanoid")

		local animator =
			humanoid:FindFirstChildOfClass("Animator")
			or Instance.new("Animator", humanoid)

		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://507766388"

		local track = animator:LoadAnimation(anim)
		track.Looped = true
		track:Play()
	end)

	----------------------------------------------------------------
	-- PANEL SUPERIOR ESTILO APP SOCIAL
	----------------------------------------------------------------

	local topProfile = Instance.new("Frame")
	topProfile.Name = "TopProfile"
	topProfile.Size = UDim2.new(1, -40, 0, 120)
	topProfile.Position = UDim2.new(0, 20, 0, 18)
	topProfile.BackgroundTransparency = 1
	topProfile.ZIndex = 100010
	topProfile.Parent = card

	-- DISPLAY NAME

	local displayName = Instance.new("TextLabel")
	displayName.Name = "DisplayName"
	displayName.Size = UDim2.new(1, 0, 0, 30)
	displayName.Position = UDim2.new(0, 0, 0, 0)
	displayName.BackgroundTransparency = 1
	displayName.Text = playerData.Name or "Unknown"
	displayName.TextColor3 = Color3.fromRGB(255,255,255)
	displayName.TextSize = 26
	displayName.Font = Enum.Font.GothamBold
	displayName.TextXAlignment = Enum.TextXAlignment.Left
	displayName.ZIndex = 100011
	displayName.Parent = topProfile

	----------------------------------------------------------------
	-- ONLINE TAG SUPERIOR (SE MANTIENE)
	----------------------------------------------------------------

	local onlineTag = Instance.new("TextLabel")
	onlineTag.Size = UDim2.new(0, 48, 0, 22)
	onlineTag.Position = UDim2.new(0, 245, 0, 3)
	onlineTag.BackgroundColor3 = Color3.fromRGB(67, 181, 129)
	onlineTag.Text = "Online"
	onlineTag.TextColor3 = Color3.new(1,1,1)
	onlineTag.TextSize = 12
	onlineTag.Font = Enum.Font.GothamMedium
	onlineTag.ZIndex = 100012
	onlineTag.Parent = topProfile

	Instance.new("UICorner", onlineTag).CornerRadius = UDim.new(1,0)

	-- USERNAME

	local usernameLabel = Instance.new("TextLabel")
	usernameLabel.Name = "Username"
	usernameLabel.Size = UDim2.new(1, 0, 0, 20)
	usernameLabel.Position = UDim2.new(0, 0, 0, 28)
	usernameLabel.BackgroundTransparency = 1
	usernameLabel.Text = "@loading..."
	usernameLabel.TextColor3 = Color3.fromRGB(180,180,180)
	usernameLabel.TextSize = 16
	usernameLabel.Font = Enum.Font.GothamMedium
	usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	usernameLabel.ZIndex = 100011
	usernameLabel.Parent = topProfile

	-- STATS CONTAINER

	local statsContainer = Instance.new("Frame")
	statsContainer.Size = UDim2.new(1, 0, 0, 55)
	statsContainer.Position = UDim2.new(0, 0, 0, 60)
	statsContainer.BackgroundTransparency = 1
	statsContainer.ZIndex = 100011
	statsContainer.Parent = topProfile

	local statsLayout = Instance.new("UIListLayout")
	statsLayout.FillDirection = Enum.FillDirection.Horizontal
	statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	statsLayout.Padding = UDim.new(0, 20)
	statsLayout.Parent = statsContainer

local function createStat(icon, value, title, parent)

	local statFrame = Instance.new("Frame")
	statFrame.Size = UDim2.new(0, 70, 0, 70)
	statFrame.BackgroundTransparency = 1
	statFrame.Parent = parent

	------------------------------------------------
	-- ICONO
	------------------------------------------------

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(1, 0, 0, 20)
	iconLabel.Position = UDim2.new(0, 0, 0, 0)

	iconLabel.BackgroundTransparency = 1

	iconLabel.Text = icon
	iconLabel.TextColor3 = Color3.fromRGB(255,255,255)

	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 18

	iconLabel.ZIndex = 100004

	iconLabel.Parent = statFrame

	------------------------------------------------
	-- NUMERO
	------------------------------------------------

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, 0, 0, 22)
	valueLabel.Position = UDim2.new(0, 0, 0, 20)

	valueLabel.BackgroundTransparency = 1

	valueLabel.Text = tostring(value)
	valueLabel.TextColor3 = Color3.fromRGB(255,255,255)

	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 20

	valueLabel.TextScaled = false

	valueLabel.ZIndex = 100004

	valueLabel.Parent = statFrame

	------------------------------------------------
	-- TITULO
	------------------------------------------------

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 18)
	titleLabel.Position = UDim2.new(0, 0, 0, 44)

	titleLabel.BackgroundTransparency = 1

	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(180,180,180)

	titleLabel.Font = Enum.Font.GothamMedium
	titleLabel.TextSize = 13

	titleLabel.TextScaled = false

	titleLabel.ZIndex = 100004

	titleLabel.Parent = statFrame
end

createStat("👥", playerData.Friends or 0, "Friends", statsContainer)
createStat("❤️", playerData.Likes or 0, "Likes", statsContainer)
createStat("🔥", playerData.Streak or 0, "Streak", statsContainer)

	task.spawn(function()

		local success, result = pcall(function()
			return Players:GetNameFromUserIdAsync(playerData.UserId)
		end)

		if success and result then
			usernameLabel.Text = "@" .. result
		end
	end)

	----------------------------------------------------------------
	-- ESPACIO VACÍO PARA FUTUROS TAGS
	----------------------------------------------------------------

	local infoContainer = Instance.new("Frame")
	infoContainer.Name = "Info"
	infoContainer.Size = UDim2.new(1, -40, 0, 100)
	infoContainer.Position = UDim2.new(0, 25, 0.69, 0)
	infoContainer.BackgroundTransparency = 1
	infoContainer.ZIndex = 100000
	infoContainer.Parent = card

	local futureTagsSpace = Instance.new("Frame")
	futureTagsSpace.Name = "FutureTagsSpace"
	futureTagsSpace.Size = UDim2.new(1, 0, 0, 35)
	futureTagsSpace.Position = UDim2.new(0, 0, 0, 10)
	futureTagsSpace.BackgroundTransparency = 1
	futureTagsSpace.ZIndex = 100001
	futureTagsSpace.Parent = infoContainer

	----------------------------------------------------------------
	-- BOTONES
	----------------------------------------------------------------

	local btnContainer = Instance.new("Frame")
	btnContainer.Name = "Actions"
	btnContainer.Size = UDim2.new(1, 0, 0, 120)
	btnContainer.Position = UDim2.new(0, 0, 1, -80)
	btnContainer.BackgroundTransparency = 1
	btnContainer.ZIndex = 100005
	btnContainer.Parent = card

	-- DISLIKE

	local rejectBtn = Instance.new("ImageButton")
	rejectBtn.Name = "RejectBtn"
	rejectBtn.Size = UDim2.new(0, 85, 0, 85)
	rejectBtn.Position = UDim2.new(0.28, 0, 0.5, -42)
	rejectBtn.AnchorPoint = Vector2.new(0.5, 0.5)

	rejectBtn.BackgroundTransparency = 1
	rejectBtn.BorderSizePixel = 0

	rejectBtn.Image = "rbxassetid://92185118464767"
	rejectBtn.ScaleType = Enum.ScaleType.Fit
	rejectBtn.ZIndex = 100006

	rejectBtn.Parent = btnContainer

	-- LIKE

	local likeBtn = Instance.new("ImageButton")
	likeBtn.Name = "LikeBtn"
	likeBtn.Size = UDim2.new(0, 85, 0, 85)
	likeBtn.Position = UDim2.new(0.78, 0, 0.5, -42)
	likeBtn.AnchorPoint = Vector2.new(0.5, 0.5)

	likeBtn.BackgroundTransparency = 1
	likeBtn.BorderSizePixel = 0

	likeBtn.Image = "rbxassetid://122843530438525"
	likeBtn.ScaleType = Enum.ScaleType.Fit
	likeBtn.ZIndex = 100006

	likeBtn.Parent = btnContainer

	return card
end

return CardFactory