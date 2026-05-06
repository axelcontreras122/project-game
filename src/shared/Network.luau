-- src/shared/Network.luau
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = {}
local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") 

if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "Remotes"
    remotesFolder.Parent = ReplicatedStorage
end

function Network.GetEvent(name: string): RemoteEvent
    local event = remotesFolder:FindFirstChild(name)
    if not event then
        assert(RunService:IsServer(), "Solo el servidor puede crear RemoteEvents.")
        event = Instance.new("RemoteEvent")
        event.Name = name
        event.Parent = remotesFolder
    end
    return event
end

function Network.GetFunction(name: string): RemoteFunction
    local func = remotesFolder:FindFirstChild(name)
    if not func then
        assert(RunService:IsServer(), "Solo el servidor puede crear RemoteFunctions.")
        func = Instance.new("RemoteFunction")
        func.Name = name
        func.Parent = remotesFolder
    end
    return func
end

-- ESTA LÍNEA ES LA QUE TE ESTÁ DANDO EL ERROR SI FALTA O SI NO HAS GUARDADO
return Network