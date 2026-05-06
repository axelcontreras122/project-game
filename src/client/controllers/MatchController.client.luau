-- src/client/controllers/MatchController.client.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Corregido: "Shared" con S mayúscula y WaitForChild
local Network = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"))

local MatchFoundEvent = Network.GetEvent("MatchFound")

MatchFoundEvent.OnClientEvent:Connect(function(matchedUserId: number)
    print("=======================================")
    print("🎉 ¡NUEVO MATCH! Felicidades, ahora puedes chatear con el usuario ID:", matchedUserId)
    print("=======================================")
end)