local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local NotificationUI = {}

local notificationQueue = {}

local isShowing = false

function NotificationUI.show(data)

if data then
	table.insert(notificationQueue,data)
end

if isShowing then
	return
end

local currentData =
	table.remove(notificationQueue,1)

if not currentData then
	return
end

isShowing = true

local destroyed = false

data = currentData

	local playerGui =
		Players.LocalPlayer
		:WaitForChild("PlayerGui")

	local mainGui =
		playerGui:WaitForChild("MainAppGui")

	------------------------------------------------
	-- HOLDER
	------------------------------------------------

	local holder =
		mainGui:FindFirstChild("NotificationHolder")

	if not holder then

		holder = Instance.new("Frame")

		holder.Name = "NotificationHolder"

		holder.Size = UDim2.new(1,0,1,0)

		holder.BackgroundTransparency = 1

		holder.ZIndex = 500

		holder.Parent = mainGui
	end

	------------------------------------------------
	-- CARD
	------------------------------------------------

	local card = Instance.new("TextButton")

	card.Name = "Notification"

	card.AutoButtonColor = false

	card.Text = ""

	card.Size = UDim2.new(0,420,0,90)

	card.AnchorPoint = Vector2.new(0.5,0)

	card.Position = UDim2.new(0.5,0,0,-120)

	card.BackgroundColor3 =
		Color3.fromRGB(20,20,25)

	card.ZIndex = 501

	card.Parent = holder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,18)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(46,204,113)
	stroke.Thickness = 2
	stroke.Transparency = 0.2
	stroke.Parent = card

	------------------------------------------------
	-- AVATAR
	------------------------------------------------

	local avatar = Instance.new("ImageLabel")

	avatar.Size = UDim2.new(0,58,0,58)

	avatar.Position = UDim2.new(0,14,0.5,-29)

	avatar.BackgroundTransparency = 1

	avatar.Image =
		"https://www.roblox.com/headshot-thumbnail/image?userId="
		.. data.UserId ..
		"&width=420&height=420&format=png"

	avatar.ZIndex = 502

	avatar.Parent = card

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(1,0)
	avatarCorner.Parent = avatar

	------------------------------------------------
	-- TITLE
	------------------------------------------------

	local title = Instance.new("TextLabel")

	title.BackgroundTransparency = 1

	title.Position = UDim2.new(0,86,0,10)

	title.Size = UDim2.new(1,-100,0,26)

	title.Font = Enum.Font.GothamBold

	title.TextSize = 25

	title.TextXAlignment =
		Enum.TextXAlignment.Left

	title.TextColor3 = Color3.new(1,1,1)

	title.Text = "New Message"

	title.ZIndex = 502

	title.Parent = card

	------------------------------------------------
	-- USERNAME
	------------------------------------------------

	local username = Instance.new("TextLabel")

	username.BackgroundTransparency = 1

	username.Position = UDim2.new(0,86,0,38)

	username.Size = UDim2.new(1,-100,0,20)

	username.Font = Enum.Font.GothamBold

	username.TextSize = 18

	username.TextXAlignment =
		Enum.TextXAlignment.Left

	username.TextColor3 =
		Color3.fromRGB(46,204,113)

	username.Text = data.Name

	username.ZIndex = 502

	username.Parent = card

	------------------------------------------------
	-- PREVIEW
	------------------------------------------------

	local preview = Instance.new("TextLabel")

	preview.BackgroundTransparency = 1

	preview.Position = UDim2.new(0,86,0,58)

	preview.Size = UDim2.new(1,-100,0,18)

	preview.Font = Enum.Font.Gotham

	preview.TextSize = 15

	preview.TextXAlignment =
		Enum.TextXAlignment.Left

	preview.TextColor3 =
		Color3.fromRGB(180,180,180)

	preview.Text =
		data.Message or "Sent you a message"

	preview.ZIndex = 502

	preview.Parent = card

	------------------------------------------------
	-- SHOW
	------------------------------------------------

	local showTween =
	TweenService:Create(

		card,

		TweenInfo.new(
			0.45,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),

		{
			Position =
				UDim2.new(0.5,0,0,14)
		}

	)

showTween:Play()

	------------------------------------------------
	-- CLICK OPEN CHAT
	------------------------------------------------

	card.MouseButton1Click:Connect(function()

		if data.OnClick then
			data.OnClick()
		end

		if destroyed then
	return
end

destroyed = true

showTween:Cancel()

card:Destroy()

isShowing = false

if #notificationQueue > 0 then
	NotificationUI.show()
end
	end)

	------------------------------------------------
	-- AUTO REMOVE
	------------------------------------------------

	task.delay(3,function()

		if destroyed then
	return
end

if not card.Parent then
	return
end

		local tween =
			TweenService:Create(

				card,

				TweenInfo.new(0.3),

				{
					Position =
						UDim2.new(0.5,0,0,-120),

					BackgroundTransparency = 1
				}
			)

		tween:Play()

		tween.Completed:Wait()
destroyed = true

showTween:Cancel()

		card:Destroy()
        isShowing = false

if #notificationQueue > 0 then

	NotificationUI.show()
end
	end)
end

return NotificationUI