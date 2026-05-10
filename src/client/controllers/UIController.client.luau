local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local UIController = {}

local function createBaseInterface()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- 1. GUI PRINCIPAL
	local mainGui = playerGui:FindFirstChild("MainAppGui")
	if not mainGui then
		mainGui = Instance.new("ScreenGui")
		mainGui.Name = "MainAppGui"
		mainGui.IgnoreGuiInset = true
		mainGui.ResetOnSpawn = false
		mainGui.Parent = playerGui
	end
	
	-- 2. FONDO OSCURO
	local background = mainGui:FindFirstChild("Background")
	if not background then
		background = Instance.new("Frame")
		background.Name = "Background"
		background.Size = UDim2.new(1, 0, 1, 0)
		background.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
		background.BorderSizePixel = 0
		background.Parent = mainGui
	end

	-- 3. CONTENEDOR DE TARJETAS (Centro)
	local centralContainer = background:FindFirstChild("CentralContainer")
	if not centralContainer then
		centralContainer = Instance.new("Frame")
		centralContainer.Name = "CentralContainer"
		centralContainer.Size = UDim2.new(0, 380, 1, -180)
		centralContainer.Position = UDim2.new(0.5, 0, 0.45, 0)
		centralContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		centralContainer.BackgroundTransparency = 1
		centralContainer.Parent = background
	end

	-- 4. BARRA DE NAVEGACIÓN (Botones abajo)
	if background:FindFirstChild("NavBar") then
		background.NavBar:Destroy()
	end
	
	local navBar = Instance.new("Frame")
	navBar.Name = "NavBar"
	navBar.Size = UDim2.new(1, 0, 0, 90)
	navBar.Position = UDim2.new(0, 0, 1, -90)
	navBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	navBar.BorderSizePixel = 0
	navBar.ZIndex = 100
	navBar.Parent = background
	
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 50)
	layout.Parent = navBar

local function createNavButton(name, text, imageId, isMain)

	local btn = Instance.new("TextButton")

	btn.Name = name .. "Btn"

	btn.Size = UDim2.new(0, 90, 1, 0)

	btn.BackgroundTransparency = 1

	btn.Text = ""

	btn.ZIndex = 105

	btn.Parent = navBar

	------------------------------------------------
	-- ICON
	------------------------------------------------

	local icon = Instance.new("ImageLabel")

	icon.Name = "Icon"

	icon.Size = UDim2.new(0,38,0,38)

	icon.Position = UDim2.new(0.5,-19,0,16)

	icon.BackgroundTransparency = 1

	icon.ZIndex = 106

	icon.Image = "http://www.roblox.com/asset/?id=" .. imageId

	icon.ImageColor3 = Color3.fromRGB(255,255,255)

	icon.Parent = btn

	------------------------------------------------
	-- TEXT
	------------------------------------------------

	local label = Instance.new("TextLabel")

	label.Size = UDim2.new(1,0,0,20)

	label.Position = UDim2.new(0,0,1,-18)

	label.BackgroundTransparency = 1

	label.Text = text

	label.Font = Enum.Font.GothamBold

	label.TextSize = 13

	label.TextColor3 =
		isMain
		and Color3.fromRGB(46,204,113)
		or Color3.fromRGB(220,220,220)

	label.ZIndex = 106

	label.Parent = btn

	return btn
end

	local homeBtn =
	createNavButton(
		"Home",
		"INICIO",
		"73466733433996",
		true
	)

local profileBtn =
	createNavButton(
		"Profile",
		"PERFIL",
		"78274676644723",
		false
	)

local chatBtn =
	createNavButton(
		"Chat",
		"CHATS",
		"99789767122944",
		false
	)

------------------------------------------------
-- MOBILE CHAT FIX
------------------------------------------------

local function setCardsVisible(state)

	------------------------------------------------
	-- MAIN GUI
	------------------------------------------------

	for _, guiObject in ipairs(mainGui:GetChildren()) do

		if guiObject.Name == "UserCard" then
			guiObject.Visible = state
		end
	end

	------------------------------------------------
	-- BACKGROUND
	------------------------------------------------

	local background = mainGui:FindFirstChild("Background")

	if background then

		for _, guiObject in ipairs(background:GetChildren()) do

			if guiObject.Name == "UserCard" then
				guiObject.Visible = state
			end
		end
	end
end

------------------------------------------------
-- CHAT BUTTON
------------------------------------------------

chatBtn.MouseButton1Click:Connect(function()

	if UserInputService.TouchEnabled then
		setCardsVisible(false)
	end
end)

------------------------------------------------
-- HOME BUTTON
------------------------------------------------

homeBtn.MouseButton1Click:Connect(function()

	setCardsVisible(true)
end)

------------------------------------------------
-- PROFILE BUTTON
------------------------------------------------

profileBtn.MouseButton1Click:Connect(function()

	setCardsVisible(true)
end)
	
	print("✅ Interfaz base lista sin errores.")
end

task.spawn(createBaseInterface)

return UIController