local DataStoreService =
	game:GetService("DataStoreService")

	local CLEAR_ALL_DATA = false

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local Players =
	game:GetService("Players")

local Types =
	require(
		ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Types")
	)

local SessionManager = {}

------------------------------------------------
-- DATASTORE
------------------------------------------------

local ProfileStore =

	DataStoreService:GetDataStore(
		"PlayerProfilesV1"
	)

local GlobalPlayersStore =
	DataStoreService:GetDataStore(
		"GlobalPlayersV1"
	)
------------------------------------------------
-- ACTIVE PROFILES
------------------------------------------------

local activeProfiles:
	{[number]: Types.PlayerProfile} = {}

------------------------------------------------
-- DEFAULT PROFILE
------------------------------------------------

local function createDefaultProfile()

	return {

		Likes = 0,

		PlayTime = 0,

		Friends = 0,

		Tags = {},

		Matches = {},
	}
end

------------------------------------------------
-- GET PROFILE
------------------------------------------------

function SessionManager.GetProfile(
	userId: number
): Types.PlayerProfile?

	return activeProfiles[userId]
end

------------------------------------------------
-- SET PROFILE
------------------------------------------------

function SessionManager.SetProfile(
	userId: number,
	profileData: Types.PlayerProfile
)

	activeProfiles[userId] =
		profileData
end

------------------------------------------------
-- REMOVE PROFILE
------------------------------------------------

function SessionManager.RemoveProfile(
	userId: number
)

	activeProfiles[userId] = nil
end

------------------------------------------------
-- LOAD PROFILE
------------------------------------------------

function SessionManager.LoadProfile(
	player: Player
    
)

if CLEAR_ALL_DATA then

	pcall(function()

		ProfileStore:RemoveAsync(player.UserId)

		GlobalPlayersStore:RemoveAsync("ALL_PLAYERS")
	end)
end

	local success,data =
		pcall(function()

			return ProfileStore:GetAsync(
				player.UserId
			)
		end)

if success and data then

	activeProfiles[player.UserId] =
		data

else

	activeProfiles[player.UserId] =
		createDefaultProfile()
end

pcall(function()

	local ids =
		GlobalPlayersStore:GetAsync(
			"ALL_PLAYERS"
		) or {}

	if not table.find(ids,player.UserId) then

		table.insert(ids,player.UserId)

		GlobalPlayersStore:SetAsync(
			"ALL_PLAYERS",
			ids
		)
	end
end)

end

------------------------------------------------
-- SAVE PROFILE
------------------------------------------------

function SessionManager.SaveProfile(
	player: Player
)

	local profile =
		activeProfiles[player.UserId]

	if not profile then
		return
	end

	pcall(function()



		ProfileStore:SetAsync(
			player.UserId,
			profile
		)
	end)
end

------------------------------------------------
-- PLAYER JOIN
------------------------------------------------

Players.PlayerAdded:Connect(function(player)

	SessionManager.LoadProfile(player)

    task.spawn(function()

	while player.Parent do

		task.wait(60)

		local profile =
			activeProfiles[player.UserId]

		if profile then

			profile.PlayTime =
				(profile.PlayTime or 0) + 60
		end
	end
end)
end)

------------------------------------------------
-- PLAYER LEAVE
------------------------------------------------

Players.PlayerRemoving:Connect(function(player)

	SessionManager.SaveProfile(player)

	activeProfiles[player.UserId] =
		nil
end)

------------------------------------------------
-- SERVER CLOSE
------------------------------------------------

game:BindToClose(function()

	for _,player in ipairs(
		Players:GetPlayers()
	) do

		SessionManager.SaveProfile(player)
	end
end)

------------------------------------------------
-- RETURN
------------------------------------------------
------------------------------------------------
-- GET ALL PLAYERS
------------------------------------------------

function SessionManager.GetAllProfiles()

	local result = {}

	local success,ids =
		pcall(function()

			return GlobalPlayersStore:GetAsync(
				"ALL_PLAYERS"
			)
		end)

	if success and ids then

		for _,userId in ipairs(ids) do

			local profileSuccess,profile =
				pcall(function()

					return ProfileStore:GetAsync(
						userId
					)
				end)

			if profileSuccess and profile then

				local name = "Unknown"

				pcall(function()

					name =
						game.Players
						:GetNameFromUserIdAsync(
							userId
						)
				end)

				table.insert(result,{
					Name = name,
					Likes = profile.Likes or 0,
					PlayTime = profile.PlayTime or 0
				})
			end
		end
	end

	table.sort(result,function(a,b)

		return a.Likes > b.Likes
	end)

	return result
end


return SessionManager