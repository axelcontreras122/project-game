local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local MatchUI = {}

function MatchUI.show(playerData)

print("MATCH DATA:")

for i,v in pairs(playerData) do
	print(i,v)
end

	local PlayerGui =
		game.Players.LocalPlayer
		:WaitForChild("PlayerGui")

	------------------------------------------------
	-- BLUR
	------------------------------------------------

	local blur = Instance.new("BlurEffect")

	blur.Size = 0

	blur.Parent = Lighting

	TweenService:Create(
		blur,
		TweenInfo.new(0.35),
		{
			Size = 18
		}
	):Play()

	------------------------------------------------
	-- SCREEN GUI
	------------------------------------------------

	local screenGui =
		Instance.new("ScreenGui")

	screenGui.Name = "MatchScreen"

	screenGui.IgnoreGuiInset = true

	screenGui.ResetOnSpawn = false

	screenGui.DisplayOrder = 999999999

	screenGui.ZIndexBehavior =
	Enum.ZIndexBehavior.Sibling

	screenGui.Parent = PlayerGui

	------------------------------------------------
	-- OVERLAY
	------------------------------------------------

	local overlay =
	Instance.new("Frame")

	overlay.Name = "MatchOverlay"

	overlay.Size =
		UDim2.new(1,0,1,0)

	overlay.BackgroundColor3 =
		Color3.fromRGB(6,8,12)

		overlay.BackgroundTransparency = 0



	overlay.Parent = screenGui

	overlay.Active = true

	overlay.Selectable = true

	------------------------------------------------
	-- BACKGROUND GRADIENT
	------------------------------------------------

	local gradient =
		Instance.new("UIGradient")

	gradient.Color = ColorSequence.new({

		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(8,10,15)
		),

		ColorSequenceKeypoint.new(
			0.5,
			Color3.fromRGB(12,18,28)
		),

		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(0,35,40)
		)
	})

	gradient.Rotation = 25

	gradient.Parent = overlay

	------------------------------------------------
	-- NOISE TEXTURE
	------------------------------------------------

	local noise =
		Instance.new("ImageLabel")

	noise.BackgroundTransparency = 1

	noise.Size =
		UDim2.new(1,0,1,0)

	noise.Image =
		"rbxassetid://9968344105"

	noise.ImageTransparency = 0.93

	noise.ScaleType =
		Enum.ScaleType.Tile

	noise.TileSize =
		UDim2.new(0,250,0,250)

	noise.ZIndex = 1

	noise.Parent = overlay

	------------------------------------------------
	-- TITLE
	------------------------------------------------

	local title =
		Instance.new("TextLabel")

	title.BackgroundTransparency = 1

	title.Size =
		UDim2.new(1,0,0,70)

	title.Position =
		UDim2.new(0,0,0.08,0)

	title.Text = "New Friend"

	title.Font =
		Enum.Font.GothamBold

	title.TextSize = 30

	title.TextColor3 =
		Color3.new(1,1,1)

	title.ZIndex = 2

	title.Parent = overlay

	------------------------------------------------
	-- MATCHED TEXT
	------------------------------------------------

	local matched =
		Instance.new("TextLabel")

	matched.BackgroundTransparency = 1

	matched.Size =
		UDim2.new(1,0,0,120)

	matched.Position =
		UDim2.new(0,0,0.14,0)

	matched.Text = "Matched!"

	matched.Font =
		Enum.Font.GothamBlack

	matched.TextSize = 76

	matched.TextColor3 =
		Color3.fromRGB(0,220,170)

	matched.ZIndex = 2

	matched.Parent = overlay

	------------------------------------------------
	-- AVATAR
	------------------------------------------------

	local avatar =
		Instance.new("ImageLabel")

	avatar.BackgroundTransparency = 1

	avatar.Size =
		UDim2.new(0,180,0,180)

	avatar.AnchorPoint =
		Vector2.new(0.5,0.5)

	avatar.Position =
	UDim2.new(0.5,0,0.42,0)

	local thumbType =
	Enum.ThumbnailType.HeadShot

local thumbSize =
	Enum.ThumbnailSize.Size420x420

local content, ready =
	game.Players:GetUserThumbnailAsync(
		playerData.UserId,
		thumbType,
		thumbSize
	)


avatar.Image = content

	avatar.ZIndex = 2

	avatar.Parent = overlay

	local avatarCorner =
		Instance.new("UICorner")

	avatarCorner.CornerRadius =
		UDim.new(1,0)

	avatarCorner.Parent = avatar

	local avatarStroke =
		Instance.new("UIStroke")

	avatarStroke.Color =
		Color3.fromRGB(0,200,160)

	avatarStroke.Thickness = 4

	avatarStroke.Parent = avatar

	------------------------------------------------
	-- USERNAME
	------------------------------------------------

	local username =
		Instance.new("TextLabel")

	username.BackgroundTransparency = 1

	username.Size =
		UDim2.new(1,0,0,50)

	username.Position =
	UDim2.new(0,0,0.56,0)

	username.Text =
		playerData.Name

	username.Font =
		Enum.Font.GothamBold

	username.TextSize = 30

	username.TextColor3 =
		Color3.new(1,1,1)

	username.ZIndex = 2

	username.Parent = overlay

	------------------------------------------------
	-- MESSAGE BUTTON
	------------------------------------------------

	local messageBtn =
		Instance.new("TextButton")

	messageBtn.Size =
		UDim2.new(0,340,0,65)

	messageBtn.AnchorPoint =
		Vector2.new(0.5,0)

	messageBtn.Position =
	UDim2.new(0.5,0,0.67,0)

	messageBtn.BackgroundColor3 =
		Color3.fromRGB(0,170,140)

	messageBtn.Text = "💬 Message"

	messageBtn.Font =
		Enum.Font.GothamBold

	messageBtn.TextSize = 28

	messageBtn.TextColor3 =
		Color3.new(1,1,1)

	messageBtn.ZIndex = 2

	messageBtn.Parent = overlay

	messageBtn.Active = true

	local msgCorner =
		Instance.new("UICorner")

	msgCorner.CornerRadius =
		UDim.new(0,18)

	msgCorner.Parent = messageBtn

	------------------------------------------------
	-- MESSAGE GRADIENT
	------------------------------------------------

	local msgGradient =
		Instance.new("UIGradient")

	msgGradient.Color = ColorSequence.new({

		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(0,170,140)
		),

		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(0,120,150)
		)
	})

	msgGradient.Rotation = 15

	msgGradient.Parent = messageBtn

	------------------------------------------------
	-- CLOSE BUTTON
	------------------------------------------------

	local closeBtn =
		Instance.new("TextButton")

	closeBtn.Size =
		UDim2.new(0,340,0,55)

	closeBtn.AnchorPoint =
		Vector2.new(0.5,0)

	closeBtn.Position =
	UDim2.new(0.5,0,0.77,0)

	closeBtn.BackgroundColor3 =
		Color3.fromRGB(15,20,25)

	closeBtn.Text = "Close"

	closeBtn.Font =
		Enum.Font.GothamBold

	closeBtn.TextSize = 24

	closeBtn.TextColor3 =
		Color3.fromRGB(180,180,180)

	closeBtn.ZIndex = 2

	closeBtn.Parent = overlay

	closeBtn.Active = true

	local closeCorner =
		Instance.new("UICorner")

	closeCorner.CornerRadius =
		UDim.new(0,18)

	closeCorner.Parent = closeBtn

	------------------------------------------------
	-- FADE IN
	------------------------------------------------

	------------------------------------------------
	-- CLOSE FUNCTION
	------------------------------------------------

	local function closeOverlay()

	overlay.Visible = false

	local blurFade =
		TweenService:Create(
			blur,
			TweenInfo.new(0.25),
			{
				Size = 0
			}
		)

	blurFade:Play()

	task.wait(0.25)

	screenGui:Destroy()

	blur:Destroy()
end

	------------------------------------------------
	-- BUTTON EVENTS
	------------------------------------------------

	closeBtn.MouseButton1Down:Connect(function()

		closeOverlay()
	end)
	

	messageBtn.MouseButton1Down:Connect(function()

		closeOverlay()

	task.defer(function()

		local OpenChatEvent =
			ReplicatedStorage
			:WaitForChild("OpenChatEvent")

		OpenChatEvent:Fire(
			playerData.UserId
		)
	end)
end)
end

return MatchUI