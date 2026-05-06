local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local MatchUI = {}

function MatchUI.show(playerData)
	local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Parent = Lighting
	TweenService:Create(blur, TweenInfo.new(0.4), {Size = 12}):Play()

	local overlay = Instance.new("Frame")
	overlay.Name = "MatchOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 100
	overlay.Parent = PlayerGui:WaitForChild("MainAppGui")

	local matchPanel = Instance.new("CanvasGroup")
	matchPanel.Name = "MatchPanel"
	matchPanel.Size = UDim2.new(0, 400, 0, 300)
	matchPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	matchPanel.Position = UDim2.new(0.5, 0, 0.45, 0)
	matchPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	matchPanel.GroupTransparency = 1
	matchPanel.Parent = overlay

	Instance.new("UICorner", matchPanel).CornerRadius = UDim.new(0, 20)

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
	})
	gradient.Rotation = 45
	gradient.Parent = matchPanel

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 60)
	title.Position = UDim2.new(0, 0, 0.15, 0)
	title.Text = "¡ES UN MATCH!"
	title.TextColor3 = Color3.fromRGB(46, 204, 113)
	title.TextSize = 38
	title.Font = Enum.Font.GothamBlack
	title.BackgroundTransparency = 1
	title.Parent = matchPanel

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0, 30)
	sub.Position = UDim2.new(0, 0, 0.4, 0)
	sub.Text = "A " .. playerData.Name .. " también le gustas"
	sub.TextColor3 = Color3.fromRGB(200, 200, 200)
	sub.TextSize = 18
	sub.Font = Enum.Font.GothamMedium
	sub.BackgroundTransparency = 1
	sub.Parent = matchPanel

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 240, 0, 50)
	btn.Position = UDim2.new(0.5, -120, 0.7, 0)
	btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	btn.Text = "SEGUIR BUSCANDO"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.Parent = matchPanel
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

	TweenService:Create(matchPanel, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		Size = UDim2.new(0, 400, 0, 300),
		GroupTransparency = 0
	}):Play()

	btn.MouseButton1Click:Connect(function()
		local fade = TweenService:Create(matchPanel, TweenInfo.new(0.3), {GroupTransparency = 1})
		local blurFade = TweenService:Create(blur, TweenInfo.new(0.3), {Size = 0})
		fade:Play()
		blurFade:Play()
		fade.Completed:Wait()
		overlay:Destroy()
		blur:Destroy()
	end)
end

return MatchUI