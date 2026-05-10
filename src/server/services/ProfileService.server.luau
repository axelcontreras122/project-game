local Players = game:GetService("Players")

local ProfileService = {}

------------------------------------------------
-- PLAYER DATA
------------------------------------------------

local playerProfiles = {}

------------------------------------------------
-- CREATE PROFILE
------------------------------------------------

local function createProfile(player)

	playerProfiles[player.UserId] = {

		Likes = 0,

		Streak = 0,

		Friends = {},

		Tags = {},

	}
end

------------------------------------------------
-- PLAYER JOIN
------------------------------------------------

Players.PlayerAdded:Connect(function(player)

	createProfile(player)
end)

------------------------------------------------
-- PLAYER LEAVE
------------------------------------------------

Players.PlayerRemoving:Connect(function(player)

	playerProfiles[player.UserId] = nil
end)

------------------------------------------------
-- GET PROFILE
------------------------------------------------

function ProfileService.GetProfile(player)

	return playerProfiles[player.UserId]
end

------------------------------------------------
-- ADD LIKE
------------------------------------------------

function ProfileService.AddLike(player)

	local profile =
		playerProfiles[player.UserId]

	if profile then

		profile.Likes += 1
	end
end

------------------------------------------------
-- ADD STREAK
------------------------------------------------

function ProfileService.AddStreak(player)

	local profile =
		playerProfiles[player.UserId]

	if profile then

		profile.Streak += 1
	end
end

------------------------------------------------
-- GET LEADERBOARD
------------------------------------------------

function ProfileService.GetLeaderboard()

	local leaderboard = {}

	for _,player in pairs(Players:GetPlayers()) do

		local profile =
			playerProfiles[player.UserId]

		if profile then

			table.insert(leaderboard, {

				Name = player.Name,

				Likes = profile.Likes,

				Streak = profile.Streak,
			})
		end
	end

	table.sort(leaderboard,function(a,b)

		return a.Likes > b.Likes
	end)

	return leaderboard
end

------------------------------------------------
-- RETURN
------------------------------------------------

return ProfileService