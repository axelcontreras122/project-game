local MatchListUI = {}

function MatchListUI.createEntry(parent, data, online, unread, onClick)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, 85)
	b.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	b.Text = ""
	b.ZIndex = 1010
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 15)
	
	local img = Instance.new("ImageLabel", b)
	img.Size = UDim2.new(0, 45, 0, 45)
	img.Position = UDim2.new(0, 15, 0.5, -22)
	img.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(data.UserId) .. "&w=150&h=150"
	img.ZIndex = 1011
	Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
	
	local t = Instance.new("TextLabel", b)
	t.Size = UDim2.new(1, -80, 0, 20)
	t.Position = UDim2.new(0, 75, 0.2, 0)
	t.Text = data.DisplayName or data.Name or "Usuario"
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.Font = Enum.Font.GothamBold
	t.TextSize = 15
	t.BackgroundTransparency = 1
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.ZIndex = 1011

	local status = Instance.new("TextLabel", b)
	status.Size = UDim2.new(1, -80, 0, 18)
	status.Position = UDim2.new(0, 75, 0.55, 0)
	status.Text = online and "En línea" or "Offline"
	status.TextColor3 = online and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(170, 170, 170)
	status.Font = Enum.Font.Gotham
	status.TextSize = 12
	status.BackgroundTransparency = 1
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.ZIndex = 1011

	------------------------------------------------
-- UNREAD BADGE
------------------------------------------------

if unread then

	local badge = Instance.new("Frame")

	badge.Size = UDim2.new(0,14,0,14)

	badge.Position = UDim2.new(1,-24,0,12)

	badge.BackgroundColor3 =
		Color3.fromRGB(255,60,60)

	badge.BorderSizePixel = 0

	badge.ZIndex = 1015

	badge.Parent = b

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1,0)
	corner.Parent = badge

end

	b.MouseButton1Click:Connect(onClick)
	return b
end

return MatchListUI