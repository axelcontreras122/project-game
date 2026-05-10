-- ProfileController.client.luau

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local SaveTagsEvent =
	ReplicatedStorage
	:WaitForChild("SaveTagsEvent")

local ProfileController = {}

------------------------------------------------
-- DATA
------------------------------------------------

local selectedTags = {}

local categories = {
	{
		Name = "🎮 Juegos",
		Tags = {
			"Horror",
			"Aventura",
			"PvP",
			"Sandbox",
			"Survival",
			"RPG"
		}
	},

	{
		Name = "🍕 Comida",
		Tags = {
			"Pizza",
			"Hamburguesa",
			"Sushi",
			"Pollo",
			"Postres"
		}
	},

	{
		Name = "🐶 Mascotas",
		Tags = {
			"Gatos",
			"Perros",
			"Conejos",
			"Peces"
		}
	},

	{
		Name = "🎵 Música",
		Tags = {
			"Rock",
			"Phonk",
			"Lo-fi",
			"Vocaloid",
			"K-pop"
		}
	},

	{
		Name = "🌙 Personalidad",
		Tags = {
			"Introvertido",
			"Extrovertido",
			"Chill",
			"Nocturno",
			"Competitivo"
		}
	}
}

------------------------------------------------
-- TAG STYLE
------------------------------------------------

local function createTag(text, parent)

	local tag = Instance.new("TextButton")

	tag.AutoButtonColor = false
	tag.BackgroundColor3 = Color3.fromRGB(35,35,42)

	tag.Size = UDim2.new(0,120,0,36)

	tag.Text = text

	tag.TextColor3 = Color3.fromRGB(255,255,255)

	tag.Font = Enum.Font.GothamMedium
	tag.TextSize = 14

	tag.BorderSizePixel = 0

	tag.Parent = parent

    tag.ZIndex = 200107

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1,0)
	corner.Parent = tag

	return tag
end

------------------------------------------------
-- CREATE PROFILE UI
------------------------------------------------

local function createProfileUI()

	local playerGui =
		LocalPlayer:WaitForChild("PlayerGui")

	local MainGui =
		playerGui:WaitForChild("MainAppGui")

	local background =
		MainGui:WaitForChild("Background")

	------------------------------------------------
	-- PROFILE FRAME
	------------------------------------------------

	local profileFrame = Instance.new("Frame")

	profileFrame.Name = "ProfileFrame"

	local isMobile = UserInputService.TouchEnabled

	if isMobile then

		profileFrame.Size =
			UDim2.new(1,0,1,-90)

		profileFrame.Position =
			UDim2.new(1,0,0,0)

		profileFrame.AnchorPoint =
			Vector2.new(0,0)

	else

		------------------------------------------------
		-- PC LEFT PANEL
		------------------------------------------------

		profileFrame.Size =
	UDim2.new(0,370,0,620)

		profileFrame.Position =
	UDim2.new(0,-305,0.5,-350)

		profileFrame.AnchorPoint =
			Vector2.new(0,0)
	end

	profileFrame.BackgroundColor3 =
		Color3.fromRGB(15,15,18)

	profileFrame.BorderSizePixel = 0

	profileFrame.Visible = false

	profileFrame.ZIndex = 200000

	profileFrame.Parent = background

	local profileCorner = Instance.new("UICorner")

	profileCorner.CornerRadius = UDim.new(0,28)

	profileCorner.Parent = profileFrame

	------------------------------------------------
	-- TOP BAR
	------------------------------------------------

local topBar = Instance.new("Frame")

topBar.Size = UDim2.new(1,0,0,100)

topBar.BackgroundColor3 =
	Color3.fromRGB(20,20,25)

topBar.BorderSizePixel = 0

topBar.ZIndex = 200001

topBar.Parent = profileFrame

local topCorner = Instance.new("UICorner")

topCorner.CornerRadius = UDim.new(0,28)

topCorner.Parent = topBar

	------------------------------------------------
	-- USERNAME
	------------------------------------------------

	local username = Instance.new("TextLabel")

	username.Size = UDim2.new(1,-30,0,40)

	username.Position = UDim2.new(0,15,0,10)

	username.BackgroundTransparency = 1

	username.Text =
		"Hola " ..
		(LocalPlayer.DisplayName or LocalPlayer.Name)

	username.Font = Enum.Font.GothamBold

	username.TextSize = 28

	username.TextColor3 =
		Color3.fromRGB(255,255,255)

	username.TextXAlignment =
		Enum.TextXAlignment.Left

	username.ZIndex = 200002

	username.Parent = topBar

	------------------------------------------------
	-- AVATAR
	------------------------------------------------

	local avatar = Instance.new("ImageLabel")

	avatar.Size = UDim2.new(0,70,0,70)

	avatar.Position = UDim2.new(0,15,0,120)

	avatar.BackgroundTransparency = 1

	avatar.Image =
		Players:GetUserThumbnailAsync(
			LocalPlayer.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)

	avatar.ZIndex = 200002

	avatar.Parent = profileFrame

	local avatarCorner = Instance.new("UICorner")

avatarCorner.CornerRadius = UDim.new(1,0)

avatarCorner.Parent = avatar

	------------------------------------------------
	-- EDIT BUTTON
	------------------------------------------------

	local editBtn = Instance.new("TextButton")

	editBtn.Size = UDim2.new(0,180,0,45)

	editBtn.Position = UDim2.new(0,100,0,132)

	editBtn.BackgroundColor3 =
		Color3.fromRGB(46,204,113)

	editBtn.Text = "Editar Perfil"

	editBtn.Font = Enum.Font.GothamBold

	editBtn.TextSize = 18

	editBtn.TextColor3 =
		Color3.new(1,1,1)

	editBtn.ZIndex = 200002

	editBtn.Parent = profileFrame

	local editCornerBtn = Instance.new("UICorner")

editCornerBtn.CornerRadius = UDim.new(0,12)

editCornerBtn.Parent = editBtn

	------------------------------------------------
	-- MAIN SCROLL
	------------------------------------------------

	local scroll = Instance.new("ScrollingFrame")

	scroll.Size = UDim2.new(1,-30,1,-250)

	scroll.Position = UDim2.new(0,15,0,220)

	scroll.BackgroundTransparency = 1

	scroll.BorderSizePixel = 0

	scroll.ScrollBarThickness = 4

	scroll.AutomaticCanvasSize =
		Enum.AutomaticSize.Y

	scroll.CanvasSize =
		UDim2.new(0,0,0,0)

	scroll.ZIndex = 200001

	scroll.Parent = profileFrame

	local layout = Instance.new("UIListLayout")

	layout.Padding = UDim.new(0,12)

	layout.HorizontalAlignment =
		Enum.HorizontalAlignment.Center

	layout.Parent = scroll

	------------------------------------------------
	-- MENU BUTTONS
	------------------------------------------------

-- REEMPLAZA SOLO EL BLOQUE DE MENU BUTTONS Y FRIENDS PAGE
-- DESDE:
-- local function createMenuButton(text)
-- HASTA justo antes de:
-- ------------------------------------------------
-- EDIT PANEL
-- ------------------------------------------------

------------------------------------------------
-- MENU BUTTONS
------------------------------------------------

local function createMenuButton(text)

	local btn = Instance.new("TextButton")

	btn.Size = UDim2.new(1,0,0,70)

	btn.BackgroundColor3 =
		Color3.fromRGB(25,25,30)

	btn.Text = text

	btn.Font = Enum.Font.GothamBold

	btn.TextSize = 22

	btn.TextColor3 =
		Color3.new(1,1,1)

	btn.ZIndex = 200002

	btn.Parent = scroll

	local corner = Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(0,12)

	corner.Parent = btn

	return btn
end

local friendsButton =
	createMenuButton("👥 Friends")

local leaderboardButton =
	createMenuButton("🏆 Leaderboards")

	------------------------------------------------
-- LEADERBOARD PAGE
------------------------------------------------

local leaderboardPage = Instance.new("Frame")

leaderboardPage.Size = UDim2.new(1,0,1,0)

leaderboardPage.BackgroundTransparency = 1

leaderboardPage.Visible = false

leaderboardPage.ZIndex = 200050

leaderboardPage.Parent = profileFrame

------------------------------------------------
-- TITLE
------------------------------------------------

local leaderboardTitle = Instance.new("TextLabel")

leaderboardTitle.Size = UDim2.new(1,0,0,50)

leaderboardTitle.Position = UDim2.new(0,0,0,20)

leaderboardTitle.BackgroundTransparency = 1

leaderboardTitle.Text = "LEADERBOARDS MUNDIAL"

leaderboardTitle.Font = Enum.Font.GothamBold

leaderboardTitle.TextSize = 28

leaderboardTitle.TextColor3 = Color3.new(1,1,1)

leaderboardTitle.ZIndex = 200052

leaderboardTitle.Parent = leaderboardPage

------------------------------------------------
-- BACK BUTTON
------------------------------------------------

local backLeaderboard = Instance.new("TextButton")

backLeaderboard.Size = UDim2.new(0,110,0,40)

backLeaderboard.Position = UDim2.new(0,20,0,20)

backLeaderboard.BackgroundColor3 =
	Color3.fromRGB(25,25,30)

backLeaderboard.Text = "← Volver"

backLeaderboard.Font = Enum.Font.GothamBold

backLeaderboard.TextSize = 16

backLeaderboard.TextColor3 = Color3.new(1,1,1)

backLeaderboard.ZIndex = 200052

backLeaderboard.Parent = leaderboardPage

local backLeaderboardCorner = Instance.new("UICorner")

backLeaderboardCorner.CornerRadius =
	UDim.new(0,12)

backLeaderboardCorner.Parent =
	backLeaderboard

------------------------------------------------
-- TOP BUTTONS
------------------------------------------------

local likesTab = Instance.new("TextButton")

likesTab.Size = UDim2.new(0.43,0,0,45)

likesTab.Position = UDim2.new(0.05,0,0,85)

likesTab.BackgroundColor3 =
	Color3.fromRGB(46,204,113)

likesTab.Text = "🤍 POR LIKES"

likesTab.Font = Enum.Font.GothamBold

likesTab.TextSize = 18

likesTab.TextColor3 = Color3.new(1,1,1)

likesTab.Parent = leaderboardPage

likesTab.ZIndex = 200052

local likesCorner = Instance.new("UICorner")

likesCorner.CornerRadius = UDim.new(0,12)

likesCorner.Parent = likesTab

local streakTab = Instance.new("TextButton")

streakTab.Size = UDim2.new(0.43,0,0,45)

streakTab.Position = UDim2.new(0.52,0,0,85)

streakTab.BackgroundColor3 =
	Color3.fromRGB(35,35,42)

streakTab.Text = "⏰ POR HORAS"

streakTab.Font = Enum.Font.GothamBold

streakTab.TextSize = 18

streakTab.TextColor3 = Color3.new(1,1,1)

streakTab.Parent = leaderboardPage

streakTab.ZIndex = 200052

local streakCorner = Instance.new("UICorner")

streakCorner.CornerRadius = UDim.new(0,12)

streakCorner.Parent = streakTab


------------------------------------------------
-- SCROLL
------------------------------------------------

local leaderboardScroll =
	Instance.new("ScrollingFrame")

leaderboardScroll.Size =
	UDim2.new(1,-30,1,-170)

leaderboardScroll.Position =
	UDim2.new(0,15,0,150)

leaderboardScroll.BackgroundTransparency = 1

leaderboardScroll.BorderSizePixel = 0

leaderboardScroll.ScrollBarThickness = 4

leaderboardScroll.AutomaticCanvasSize =
	Enum.AutomaticSize.Y

leaderboardScroll.CanvasSize =
	UDim2.new(0,0,0,0)

leaderboardScroll.Parent =
	leaderboardPage

	leaderboardScroll.ZIndex = 200051

local leaderboardLayout =
	Instance.new("UIListLayout")

leaderboardLayout.Padding =
	UDim.new(0,8)

leaderboardLayout.Parent =
	leaderboardScroll

------------------------------------------------
-- DUMMY DATA
------------------------------------------------

local Network =
	require(game.ReplicatedStorage
		.Shared.Network)

local GetLeaderboard =
	Network.GetFunction("GetLeaderboard")

local currentLeaderboardMode = "Likes"

local function refreshLeaderboard()

	for _,child in ipairs(
		leaderboardScroll:GetChildren()
	) do

		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local realPlayers = {}

	pcall(function()

		realPlayers =
			GetLeaderboard:InvokeServer()
	end)

	table.sort(realPlayers,function(a,b)

	if currentLeaderboardMode == "Hours" then

		return (a.PlayTime or 0) >
			(b.PlayTime or 0)
	end

	return (a.Likes or 0) >
		(b.Likes or 0)
end)

	for rank,data in ipairs(realPlayers) do

		local row = Instance.new("Frame")

		row.ZIndex = 200053

		row.Size = UDim2.new(1,-5,0,55)

		row.BackgroundColor3 =
			Color3.fromRGB(25,25,30)

		row.Parent = leaderboardScroll

		local rowCorner =
			Instance.new("UICorner")

		rowCorner.CornerRadius =
			UDim.new(0,12)

		rowCorner.Parent = row

		local rankLabel =
			Instance.new("TextLabel")

		rankLabel.Size =
			UDim2.new(0,60,1,0)

		rankLabel.BackgroundTransparency = 1

		rankLabel.Text = "#" .. rank

		rankLabel.Font =
			Enum.Font.GothamBold

		rankLabel.TextSize = 20

		rankLabel.TextColor3 =
			Color3.new(1,1,1)

		rankLabel.ZIndex = 200054

		rankLabel.Parent = row

		local userLabel =
			Instance.new("TextLabel")

		userLabel.Size =
			UDim2.new(0.4,0,1,0)

		userLabel.Position =
			UDim2.new(0,70,0,0)

		userLabel.BackgroundTransparency = 1

		userLabel.Text = data.Name

		userLabel.Font =
			Enum.Font.GothamBold

		userLabel.TextSize = 18

		userLabel.TextColor3 =
			Color3.new(1,1,1)

		userLabel.TextXAlignment =
			Enum.TextXAlignment.Left

		userLabel.ZIndex = 200054

		userLabel.Parent = row

local statLabel =
	Instance.new("TextLabel")

statLabel.Size =
	UDim2.new(0.35,0,1,0)

statLabel.Position =
	UDim2.new(0.6,0,0,0)

statLabel.BackgroundTransparency = 1

statLabel.Font =
	Enum.Font.GothamBold

statLabel.TextSize = 16

statLabel.TextColor3 =
	Color3.new(1,1,1)

statLabel.ZIndex = 200054

if currentLeaderboardMode == "Hours" then

	local totalSeconds =
		data.PlayTime or 0

	local hours =
		math.floor(totalSeconds / 3600)

	local minutes =
		math.floor((totalSeconds % 3600) / 60)

	statLabel.Text =
		"⏰ "..string.format(
			"%02d:%02d",
			hours,
			minutes
		)

else

	statLabel.Text =
		"🤍 "..tostring(
			data.Likes
		)
end

statLabel.Parent = row
	end
end

likesTab.MouseButton1Click:Connect(function()

	currentLeaderboardMode = "Likes"

	likesTab.BackgroundColor3 =
		Color3.fromRGB(46,204,113)

	streakTab.BackgroundColor3 =
		Color3.fromRGB(35,35,42)

	refreshLeaderboard()
end)

streakTab.MouseButton1Click:Connect(function()

	currentLeaderboardMode = "Hours"

	streakTab.BackgroundColor3 =
		Color3.fromRGB(46,204,113)

	likesTab.BackgroundColor3 =
		Color3.fromRGB(35,35,42)

	refreshLeaderboard()
end)

------------------------------------------------
-- OPEN LEADERBOARD
------------------------------------------------
local leaderboardUpdating = false

leaderboardButton.MouseButton1Click:Connect(function()

	scroll.Visible = false

	topBar.Visible = false

	avatar.Visible = false

	editBtn.Visible = false

	leaderboardPage.Visible = true

	refreshLeaderboard()

if not leaderboardUpdating then

	leaderboardUpdating = true

	task.spawn(function()

		while leaderboardPage.Visible do

			task.wait(5)

			if leaderboardPage.Visible then
				refreshLeaderboard()
			end
		end

		leaderboardUpdating = false
	end)
end

end)

------------------------------------------------
-- CLOSE LEADERBOARD
------------------------------------------------

backLeaderboard.MouseButton1Click:Connect(function()


	leaderboardPage.Visible = false

	scroll.Visible = true

	topBar.Visible = true

	avatar.Visible = true

	editBtn.Visible = true
end)


------------------------------------------------
-- FRIENDS PAGE
------------------------------------------------

local friendsPage = Instance.new("Frame")

friendsPage.Size = UDim2.new(1,0,1,0)

friendsPage.BackgroundTransparency = 1

friendsPage.Visible = false

friendsPage.ZIndex = 200050

friendsPage.Parent = profileFrame

local friendsTitle = Instance.new("TextLabel")

friendsTitle.Size = UDim2.new(1,0,0,50)

friendsTitle.Position = UDim2.new(0,0,0,20)

friendsTitle.BackgroundTransparency = 1

friendsTitle.Text = "Friends"

friendsTitle.Font = Enum.Font.GothamBold

friendsTitle.TextSize = 30

friendsTitle.TextColor3 = Color3.new(1,1,1)

friendsTitle.ZIndex = 200052

friendsTitle.Parent = friendsPage

local backFriends = Instance.new("TextButton")

backFriends.Size = UDim2.new(0,110,0,40)

backFriends.Position = UDim2.new(0,20,0,20)

backFriends.BackgroundColor3 =
	Color3.fromRGB(25,25,30)

backFriends.Text = "← Volver"

backFriends.Font = Enum.Font.GothamBold

backFriends.TextSize = 16

backFriends.TextColor3 =
	Color3.new(1,1,1)

backFriends.ZIndex = 200052

backFriends.Parent = friendsPage

local backCorner = Instance.new("UICorner")

backCorner.CornerRadius = UDim.new(0,12)

backCorner.Parent = backFriends

local friendsScroll = Instance.new("ScrollingFrame")

friendsScroll.Size =
	UDim2.new(1,-30,1,-100)

friendsScroll.Position =
	UDim2.new(0,15,0,80)

friendsScroll.BackgroundTransparency = 1

friendsScroll.BorderSizePixel = 0

friendsScroll.ScrollBarThickness = 4

friendsScroll.AutomaticCanvasSize =
	Enum.AutomaticSize.Y

friendsScroll.CanvasSize =
	UDim2.new(0,0,0,0)

friendsScroll.Parent = friendsPage

friendsScroll.ZIndex = 200051

local friendsLayout =
	Instance.new("UIListLayout")

friendsLayout.Padding =
	UDim.new(0,10)

friendsLayout.Parent =
	friendsScroll

friendsLayout:GetPropertyChangedSignal(
	"AbsoluteContentSize"
):Connect(function()

	friendsScroll.CanvasSize =
		UDim2.new(
			0,0,
			0,
			friendsLayout.AbsoluteContentSize.Y + 10
		)
end)

for _,player in ipairs(Players:GetPlayers()) do

	if player ~= LocalPlayer then

		local card =
			Instance.new("Frame")
			card.ZIndex = 200053

		card.Size =
			UDim2.new(1,-5,0,90)

		card.BackgroundColor3 =
			Color3.fromRGB(28,28,35)

		card.Parent = friendsScroll

		local cardCorner =
			Instance.new("UICorner")

		cardCorner.CornerRadius =
			UDim.new(0,20)

		cardCorner.Parent = card

		local thumb =
			Players:GetUserThumbnailAsync(
				player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size150x150
			)

		local avatarImage =
			Instance.new("ImageLabel")

		avatarImage.Size =
			UDim2.new(0,55,0,55)

		avatarImage.Position =
			UDim2.new(0,15,0.5,-27)

		avatarImage.BackgroundTransparency = 1

		avatarImage.Image = thumb

		avatarImage.Parent = card

		avatarImage.ZIndex = 200054

		local avatarCorner =
			Instance.new("UICorner")

		avatarCorner.CornerRadius =
			UDim.new(1,0)

		avatarCorner.Parent =
			avatarImage

		local usernameLabel =
			Instance.new("TextLabel")

		usernameLabel.Size =
			UDim2.new(1,-90,0,30)

		usernameLabel.Position =
			UDim2.new(0,85,0,18)

		usernameLabel.BackgroundTransparency = 1

		usernameLabel.Text =
			player.DisplayName

		usernameLabel.Font =
			Enum.Font.GothamBold

		usernameLabel.TextSize = 20

		usernameLabel.TextColor3 =
			Color3.new(1,1,1)

		usernameLabel.TextXAlignment =
			Enum.TextXAlignment.Left

		usernameLabel.Parent = card

		usernameLabel.ZIndex = 200054

		local status =
			Instance.new("TextLabel")

		status.Size =
			UDim2.new(1,-90,0,20)

		status.Position =
			UDim2.new(0,85,0,48)

		status.BackgroundTransparency = 1

		status.Text = "Online"

		status.Font =
			Enum.Font.GothamMedium

		status.TextSize = 14

		status.TextColor3 =
			Color3.fromRGB(46,204,113)

		status.TextXAlignment =
			Enum.TextXAlignment.Left

		status.Parent = card

		status.ZIndex = 200054
	end
end

friendsButton.MouseButton1Click:Connect(function()

	scroll.Visible = false

	topBar.Visible = false

	avatar.Visible = false

	editBtn.Visible = false

	friendsPage.Visible = true
end)

backFriends.MouseButton1Click:Connect(function()

	friendsPage.Visible = false

	scroll.Visible = true

	topBar.Visible = true

	avatar.Visible = true

	editBtn.Visible = true
end)

	------------------------------------------------
	-- EDIT PANEL
	------------------------------------------------

	local editPanel = Instance.new("Frame")

	editPanel.Size = UDim2.new(1,0,1,0)

	editPanel.Position = UDim2.new(0,0,1,0)

	editPanel.BackgroundColor3 =
		Color3.fromRGB(12,12,15)

	editPanel.Visible = false

	editPanel.ClipsDescendants = true

	editPanel.ZIndex = 200100

	editPanel.Parent = profileFrame

    local editCorner = Instance.new("UICorner")

editCorner.CornerRadius = UDim.new(0,28)

editCorner.Parent = editPanel

	------------------------------------------------
	-- TITLE
	------------------------------------------------

	local editTitle = Instance.new("TextLabel")

	editTitle.Size = UDim2.new(1,0,0,60)

	editTitle.Position = UDim2.new(0,0,0,20)

	editTitle.BackgroundTransparency = 1

	editTitle.Text = "Editar Perfil"

	editTitle.Font = Enum.Font.GothamBold

	editTitle.TextSize = 30

	editTitle.TextColor3 =
		Color3.new(1,1,1)

	editTitle.ZIndex = 200101

	editTitle.Parent = editPanel

	------------------------------------------------
	-- TAG SCROLL
	------------------------------------------------

	local tagScroll = Instance.new("ScrollingFrame")

	tagScroll.Size = UDim2.new(1,-20,1,-170)

	tagScroll.Position = UDim2.new(0,10,0,90)

	tagScroll.BackgroundTransparency = 1

	tagScroll.BorderSizePixel = 0

	tagScroll.ScrollBarThickness = 4

	tagScroll.AutomaticCanvasSize =
		Enum.AutomaticSize.Y

	tagScroll.CanvasSize =
		UDim2.new(0,0,0,0)

	tagScroll.ZIndex = 200101

	tagScroll.Parent = editPanel

	local tagLayout = Instance.new("UIListLayout")

	tagLayout.Padding = UDim.new(0,20)

	tagLayout.HorizontalAlignment =
		Enum.HorizontalAlignment.Center

	tagLayout.SortOrder =
		Enum.SortOrder.LayoutOrder

	tagLayout.Parent = tagScroll

	------------------------------------------------
	-- CATEGORIES
	------------------------------------------------

	for _, category in ipairs(categories) do

		local categoryFrame = Instance.new("Frame")

categoryFrame.AutomaticSize =
	Enum.AutomaticSize.Y

categoryFrame.Size =
	UDim2.new(1,-10,0,0)

categoryFrame.BackgroundTransparency = 1

categoryFrame.ClipsDescendants = false

categoryFrame.ZIndex = 200104

categoryFrame.Parent = tagScroll

		local categoryTitle =
			Instance.new("TextLabel")

		categoryTitle.Size =
			UDim2.new(1,0,0,30)

		categoryTitle.BackgroundTransparency = 1

		categoryTitle.Text = category.Name

		categoryTitle.Font =
			Enum.Font.GothamBold

		categoryTitle.TextSize = 20

		categoryTitle.TextColor3 =
			Color3.new(1,1,1)

		categoryTitle.TextXAlignment =
			Enum.TextXAlignment.Left

            categoryTitle.TextYAlignment =
	Enum.TextYAlignment.Center

		categoryTitle.Parent = categoryFrame

        categoryTitle.ZIndex = 200105

		local tagsContainer = Instance.new("Frame")

tagsContainer.ZIndex = 200106

tagsContainer.Size =
	UDim2.new(1,0,0,190)

tagsContainer.Position =
	UDim2.new(0,0,0,45)

tagsContainer.BackgroundTransparency = 1

tagsContainer.ClipsDescendants = false

tagsContainer.Parent = categoryFrame

tagsContainer.AutomaticSize =
	Enum.AutomaticSize.Y

tagsContainer.ClipsDescendants = false


		local flow = Instance.new("UIGridLayout")

		flow.CellSize =
	UDim2.new(0,150,0,42)

		flow.CellPadding =
			UDim2.new(0,8,0,8)

		flow.HorizontalAlignment =
			Enum.HorizontalAlignment.Left

		flow.VerticalAlignment =
			Enum.VerticalAlignment.Top

		flow.Parent = tagsContainer

        flow.FillDirectionMaxCells = 2

flow.SortOrder = Enum.SortOrder.LayoutOrder

        flow:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

	tagsContainer.Size =
		UDim2.new(1,0,0,
			flow.AbsoluteContentSize.Y)

	categoryFrame.Size =
		UDim2.new(1,-10,0,
			flow.AbsoluteContentSize.Y + 70)
end)

		for _, tagName in ipairs(category.Tags) do

			local tagBtn =
				createTag(tagName, tagsContainer)

			tagBtn.MouseButton1Click:Connect(function()

				if selectedTags[tagName] then

					selectedTags[tagName] = nil

					TweenService:Create(
						tagBtn,
						TweenInfo.new(0.15),
						{
							BackgroundColor3 =
								Color3.fromRGB(35,35,42)
						}
					):Play()

				else

					selectedTags[tagName] = true

					TweenService:Create(
						tagBtn,
						TweenInfo.new(0.15),
						{
							BackgroundColor3 =
								Color3.fromRGB(46,204,113)
						}
					):Play()
				end
			end)
		end
	end

	------------------------------------------------
	-- SAVE BUTTON
	------------------------------------------------

	local saveBtn = Instance.new("TextButton")

	saveBtn.Size = UDim2.new(0,180,0,50)

	saveBtn.Position = UDim2.new(0.5,-90,1,-70)

	saveBtn.BackgroundColor3 =
		Color3.fromRGB(46,204,113)

	saveBtn.Text = "Guardar"

	saveBtn.Font = Enum.Font.GothamBold

	saveBtn.TextSize = 20

	saveBtn.TextColor3 =
		Color3.new(1,1,1)

	saveBtn.ZIndex = 200102

	saveBtn.Parent = editPanel

	local saveCorner = Instance.new("UICorner")

saveCorner.CornerRadius = UDim.new(0,12)

saveCorner.Parent = saveBtn

	------------------------------------------------
	-- OPEN EDIT
	------------------------------------------------

	editBtn.MouseButton1Click:Connect(function()

		editPanel.Visible = true

		TweenService:Create(
			editPanel,
			TweenInfo.new(0.35, Enum.EasingStyle.Quint),
			{
				Position = UDim2.new(0,0,0,0)
			}
		):Play()
	end)

	------------------------------------------------
	-- CLOSE EDIT
	------------------------------------------------

	saveBtn.MouseButton1Click:Connect(function()

	------------------------------------------------
	-- SAVE TAGS
	------------------------------------------------

	local tagsToSave = {}

	for tagName,_ in pairs(selectedTags) do

		table.insert(
			tagsToSave,
			tagName
		)
	end

	SaveTagsEvent:FireServer(
		tagsToSave
	)

		local tween = TweenService:Create(
			editPanel,
			TweenInfo.new(0.35, Enum.EasingStyle.Quint),
			{
				Position = UDim2.new(0,0,1,0)
			}
		)

		tween:Play()

		tween.Completed:Wait()

		editPanel.Visible = false
	end)

	------------------------------------------------
	-- NAVIGATION
	------------------------------------------------

	local navBar =
		background:WaitForChild("NavBar")

	local profileBtn =
		navBar:WaitForChild("ProfileBtn")

	local homeBtn =
		navBar:WaitForChild("HomeBtn")

	local profileOpen = false

profileBtn.MouseButton1Click:Connect(function()

	if profileOpen then

		local closeTween = TweenService:Create(
			profileFrame,
			TweenInfo.new(0.35, Enum.EasingStyle.Quint),
			{
				Position = isMobile
					and UDim2.new(1,0,0,0)
					or UDim2.new(0,-305,0.5,-350)
			}
		)

		closeTween:Play()

		closeTween.Completed:Wait()

		profileFrame.Visible = false

		profileOpen = false

	else

			------------------------------------------------
		-- HIDE SWIPE CARDS
		------------------------------------------------

		local background =
			MainGui:FindFirstChild(
				"Background"
			)

		if background then

			for _,v in ipairs(
				background:GetChildren()
			) do

				if v.Name == "UserCard" then

					v.Visible = false
				end
			end
		end

		profileFrame.Visible = true

		TweenService:Create(
			profileFrame,
			TweenInfo.new(0.35, Enum.EasingStyle.Quint),
			{
				Position = isMobile
					and UDim2.new(0,0,0,0)
					or UDim2.new(0,195,0.5,-350)
			}
		):Play()

		profileOpen = true
	end
end)

	homeBtn.MouseButton1Click:Connect(function()

		------------------------------------------------
	-- SHOW SWIPE CARDS AGAIN
	------------------------------------------------

	local background =
		MainGui:FindFirstChild(
			"Background"
		)

	if background then

		for _,v in ipairs(
			background:GetChildren()
		) do

			if v.Name == "UserCard" then

				v.Visible = true
			end
		end
	end

		local tween = TweenService:Create(
			profileFrame,
			TweenInfo.new(0.35, Enum.EasingStyle.Quint),
			{
				Position = isMobile
					and UDim2.new(1,0,0,0)
					or UDim2.new(0,-450,0.5,-350)
			}
		)

		tween:Play()

		tween.Completed:Wait()

		profileFrame.Visible = false
	end)
end

------------------------------------------------
-- START
------------------------------------------------

task.spawn(function()

	task.wait(1)

	createProfileUI()
end)

return ProfileController