local ChatUI = {}
local Players = game:GetService("Players")

local function formatTime(timestamp)
	if not timestamp then return "" end
	local formatted = os.date("%I:%M %p", timestamp)
	return formatted:gsub("^0", "")
end

function ChatUI.setupChatElements(parent, targetName, onBack, isOnline, targetUserId)
	-- Cabecera Premium
	local header = Instance.new("Frame", parent)
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	header.BorderSizePixel = 0
	header.ZIndex = 1010
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 20)
	
	local back = Instance.new("TextButton", header)
	back.Size = UDim2.new(0, 50, 1, 0)
	back.Text = "←"
	back.TextColor3 = Color3.fromRGB(255, 255, 255)
	back.BackgroundTransparency = 1
	back.TextSize = 22
	back.ZIndex = 1011

	------------------------------------------------
-- AVATAR
------------------------------------------------

local avatar = Instance.new("ImageLabel", header)

avatar.Size = UDim2.new(0,60,0,60)

avatar.Position = UDim2.new(0,36,0.5,-44)

avatar.BackgroundTransparency = 1

avatar.Image =
	"rbxthumb://type=AvatarHeadShot&id="
	.. tostring(targetUserId)
	.. "&w=150&h=150"

avatar.ZIndex = 1011

avatar.Parent = header

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(1,0)
avatarCorner.Parent = avatar

------------------------------------------------
-- OPTIONS BUTTON
------------------------------------------------

local optionsBtn = Instance.new("ImageButton")

optionsBtn.Name = "OptionsButton"

optionsBtn.Size = UDim2.new(0,34,0,34)

optionsBtn.Position = UDim2.new(1,-48,0.5,-17)

optionsBtn.BackgroundTransparency = 1

optionsBtn.Image =
	"rbxassetid://72703336591426"

optionsBtn.ZIndex = 1012

optionsBtn.Parent = header

------------------------------------------------
-- OPEN DELETE POPUP
------------------------------------------------

optionsBtn.MouseButton1Click:Connect(function()

	ChatUI.createDeletePopup(parent, function()

		if ChatUI.OnDeleteMatch then
			ChatUI.OnDeleteMatch()
		end
	end)
end)
	
	local title = Instance.new("TextLabel", header)
	title.Size = UDim2.new(1, -60, 0, 30)
	title.Position = UDim2.new(0,98,0,2)
	title.Text = targetName:upper()
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 1011
	
	local status = Instance.new("TextLabel", header)
	status.Size = UDim2.new(1, -60, 0, 20)
	status.Position = UDim2.new(0,98,0,26)
	status.Text = isOnline and "EN LÍNEA" or "OFFLINE"
	status.TextColor3 = isOnline and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(170, 170, 170)
	status.Font = Enum.Font.Gotham
	status.TextSize = 12
	status.BackgroundTransparency = 1
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.ZIndex = 1011
	
	-- Contenedor de Mensajes
	local scroll = Instance.new("ScrollingFrame", parent)
	scroll.Name = "MsgScroll"
	scroll.Size = UDim2.new(1, -20, 1, -185)
	scroll.Position = UDim2.new(0, 10, 0, 90)
	scroll.BackgroundTransparency = 1
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollBarThickness = 0
	scroll.ZIndex = 1010
	
	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 8)
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	
	-- Barra de Input
	local inputBar = Instance.new("TextBox", parent)
	inputBar.Name = "ChatInput"
	inputBar.Size = UDim2.new(1, -84, 0, 60)
	inputBar.Position = UDim2.new(0, 12, 1, -75)
	inputBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	inputBar.PlaceholderText = "Escribe un mensaje..."
	inputBar.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
	inputBar.Text = ""
	inputBar.TextColor3 = Color3.fromRGB(255, 255, 255)
	inputBar.Font = Enum.Font.Gotham
	inputBar.TextSize = 14
	inputBar.ClearTextOnFocus = true
	inputBar.TextWrapped = true
	inputBar.MultiLine = true
	inputBar.ZIndex = 1010
	Instance.new("UICorner", inputBar).CornerRadius = UDim.new(0, 12)
	
	local padding = Instance.new("UIPadding", inputBar)
	padding.PaddingLeft = UDim.new(0, 15)
	
	-- Botón de Enviar
	local sendBtn = Instance.new("TextButton", parent)
	sendBtn.Name = "SendBtn"
	sendBtn.Size = UDim2.new(0, 48, 0, 60)
	sendBtn.Position = UDim2.new(1, -60, 1, -75)
	sendBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	sendBtn.Text = "→"
	sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	sendBtn.Font = Enum.Font.GothamBold
	sendBtn.TextSize = 18
	sendBtn.ZIndex = 1010
	Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 12)

	local typingLabel = Instance.new("TextLabel", parent)
	typingLabel.Size = UDim2.new(1, -24, 0, 20)
	typingLabel.Position = UDim2.new(0, 12, 0, 68)
	typingLabel.Text = ""
	typingLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	typingLabel.Font = Enum.Font.Gotham
	typingLabel.TextSize = 12
	typingLabel.BackgroundTransparency = 1
	typingLabel.TextXAlignment = Enum.TextXAlignment.Left
	typingLabel.ZIndex = 1010

	back.MouseButton1Click:Connect(onBack)
	
	return scroll, inputBar, sendBtn, typingLabel
end

function ChatUI.addMessage(scroll, text, isMe, timestamp, avatarUserId)
	local container = Instance.new("Frame", scroll)
	container.Size = UDim2.new(1, 0, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.BackgroundTransparency = 1
	container.ZIndex = 1011

	local bubbleContainer = Instance.new("Frame", container)
	bubbleContainer.Size = UDim2.new(1, 0, 0, 0)
	bubbleContainer.AutomaticSize = Enum.AutomaticSize.Y
	bubbleContainer.BackgroundTransparency = 1
	bubbleContainer.ZIndex = 1011

	local row = Instance.new("Frame", bubbleContainer)
	row.BackgroundTransparency = 1
	row.AutomaticSize = Enum.AutomaticSize.XY
	row.Size = UDim2.new(0, 0, 0, 0)
	row.AnchorPoint = isMe and Vector2.new(1, 0) or Vector2.new(0, 0)
	row.Position = isMe and UDim2.new(1, -16, 0, 0) or UDim2.new(0, 16, 0, 0)
	row.ZIndex = 1011

	local rowLayout = Instance.new("UIListLayout", row)
	rowLayout.FillDirection = Enum.FillDirection.Horizontal
	rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rowLayout.Padding = UDim.new(0, 8)
	rowLayout.HorizontalAlignment = isMe and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left

	if not isMe then
		local avatar = Instance.new("Frame", row)
		avatar.Name = "AvatarCircle"
		avatar.Size = UDim2.new(0, 34, 0, 34)
		avatar.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
		avatar.ZIndex = 1012
		local avatarCorner = Instance.new("UICorner", avatar)
		avatarCorner.CornerRadius = UDim.new(1, 0)

		local avatarImage = Instance.new("ImageLabel", avatar)
		avatarImage.Size = UDim2.new(1, 0, 1, 0)
		avatarImage.Position = UDim2.new(0, 0, 0, 0)
		avatarImage.BackgroundTransparency = 1
		avatarImage.ScaleType = Enum.ScaleType.Fit
		avatarImage.ZIndex = 1013

		local imageToShow = "rbxasset://textures/ui/AvatarIcon.png"
		if avatarUserId then
			local success, thumbnail = pcall(function()
				return Players:GetUserThumbnailAsync(avatarUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			end)
			if success and thumbnail and thumbnail ~= "" then
				imageToShow = thumbnail
			end
		end
		avatarImage.Image = imageToShow
	end

	local bubble = Instance.new("Frame", row)
bubble.Size = UDim2.new(0, 180, 0, 40)
bubble.AutomaticSize = Enum.AutomaticSize.Y
bubble.BackgroundColor3 = isMe and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(42, 42, 48)
bubble.ZIndex = 1012
	Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 12)

	local bubblePadding = Instance.new("UIPadding", bubble)
	bubblePadding.PaddingLeft = UDim.new(0, 14)
	bubblePadding.PaddingRight = UDim.new(0, 14)
	bubblePadding.PaddingTop = UDim.new(0, 10)
	bubblePadding.PaddingBottom = UDim.new(0, 24)

local txt = Instance.new("TextLabel")
txt.Parent = bubble
txt.BackgroundTransparency = 1
txt.Position = UDim2.new(0,0,0,0)
txt.Size = UDim2.new(0, 150, 0, 20)
txt.Text = tostring(text or "")
txt.TextColor3 = Color3.fromRGB(255,255,255)
txt.Font = Enum.Font.GothamMedium
txt.TextSize = 14
txt.TextWrapped = true
txt.TextXAlignment = Enum.TextXAlignment.Left
txt.TextYAlignment = Enum.TextYAlignment.Top
txt.RichText = false
txt.ZIndex = 1013

local textBounds =
	game:GetService("TextService"):GetTextSize(
		txt.Text,
		txt.TextSize,
		txt.Font,
		Vector2.new(150, 9999)
	)

txt.Size = UDim2.new(
	0,
	150,
	0,
	math.max(20, textBounds.Y)
)

bubble.Size = UDim2.new(
	0,
	180,
	0,
	textBounds.Y + 34
)

	local timeLabel = Instance.new("TextLabel", bubble)
	timeLabel.Size = UDim2.new(0, 0, 0, 0)
	timeLabel.AutomaticSize = Enum.AutomaticSize.XY
	timeLabel.AnchorPoint = Vector2.new(1, 1)
	timeLabel.Position = UDim2.new(1, -6, 1, -4)
	timeLabel.Text = formatTime(timestamp)
	timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	timeLabel.Font = Enum.Font.Gotham
	timeLabel.TextSize = 10
	timeLabel.BackgroundTransparency = 1
	timeLabel.TextXAlignment = Enum.TextXAlignment.Right
	timeLabel.ZIndex = 1014
end

------------------------------------------------
-- MATCH DELETE POPUP
------------------------------------------------

function ChatUI.createDeletePopup(parent, onConfirm)

	local overlay = Instance.new("Frame")

	overlay.Size = UDim2.new(1,0,1,0)

	overlay.BackgroundColor3 =
		Color3.fromRGB(0,0,0)

	overlay.BackgroundTransparency = 0.35

	overlay.ZIndex = 3000

	overlay.Parent = parent

	local overlayCorner = Instance.new("UICorner")

overlayCorner.CornerRadius =
	UDim.new(0,24)

overlayCorner.Parent = overlay

	------------------------------------------------
	-- BOX
	------------------------------------------------

	local box = Instance.new("Frame")

	box.Size = UDim2.new(0,300,0,180)

	box.Position = UDim2.new(0.5,0,0.5,0)

	box.AnchorPoint = Vector2.new(0.5,0.5)

	box.BackgroundColor3 =
		Color3.fromRGB(28,28,34)

	box.ZIndex = 3001

	box.Parent = overlay

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,20)
	corner.Parent = box

	------------------------------------------------
	-- TITLE
	------------------------------------------------

	local title = Instance.new("TextLabel")

	title.Size = UDim2.new(1,-30,0,30)

	title.Position = UDim2.new(0,15,0,18)

	title.BackgroundTransparency = 1

	title.Text =
		"¿Eliminar este match?"

	title.TextColor3 =
		Color3.fromRGB(255,255,255)

	title.Font = Enum.Font.GothamBold

	title.TextSize = 18

	title.ZIndex = 3002

	title.Parent = box

	------------------------------------------------
	-- DESC
	------------------------------------------------

	local desc = Instance.new("TextLabel")

	desc.Size = UDim2.new(1,-30,0,60)

	desc.Position = UDim2.new(0,15,0,58)

	desc.BackgroundTransparency = 1

	desc.Text =
		"Esta acción eliminará el match, el historial y el chat."

	desc.TextWrapped = true

	desc.TextColor3 =
		Color3.fromRGB(180,180,180)

	desc.Font = Enum.Font.Gotham

	desc.TextSize = 14

	desc.ZIndex = 3002

	desc.Parent = box

	------------------------------------------------
	-- CANCEL
	------------------------------------------------

	local cancelBtn =
		Instance.new("TextButton")

	cancelBtn.Size = UDim2.new(0,110,0,42)

	cancelBtn.Position =
		UDim2.new(0,20,1,-58)

	cancelBtn.BackgroundColor3 =
		Color3.fromRGB(55,55,65)

	cancelBtn.Text = "Cancelar"

	cancelBtn.TextColor3 =
		Color3.fromRGB(255,255,255)

	cancelBtn.Font = Enum.Font.GothamBold

	cancelBtn.TextSize = 14

	cancelBtn.ZIndex = 3002

	cancelBtn.Parent = box

	local c1 = Instance.new("UICorner")
	c1.CornerRadius = UDim.new(0,12)
	c1.Parent = cancelBtn

	------------------------------------------------
	-- DELETE
	------------------------------------------------

	local deleteBtn =
		Instance.new("TextButton")

	deleteBtn.Size = UDim2.new(0,110,0,42)

	deleteBtn.Position =
		UDim2.new(1,-130,1,-58)

	deleteBtn.BackgroundColor3 =
		Color3.fromRGB(220,60,60)

	deleteBtn.Text = "Eliminar"

	deleteBtn.TextColor3 =
		Color3.fromRGB(255,255,255)

	deleteBtn.Font = Enum.Font.GothamBold

	deleteBtn.TextSize = 14

	deleteBtn.ZIndex = 3002

	deleteBtn.Parent = box

	local c2 = Instance.new("UICorner")
	c2.CornerRadius = UDim.new(0,12)
	c2.Parent = deleteBtn

	------------------------------------------------
	-- EVENTS
	------------------------------------------------

	cancelBtn.MouseButton1Click:Connect(function()

		overlay:Destroy()
	end)

	deleteBtn.MouseButton1Click:Connect(function()

		if onConfirm then
			onConfirm()
		end

		overlay:Destroy()
	end)
end

return ChatUI