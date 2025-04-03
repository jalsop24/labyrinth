local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Env = require(ReplicatedStorage.Env)
local Logging = require(ServerStorage.Logging)

require(ServerStorage.DungeonService)
require(ServerStorage.ServerMessage)

Logging:Log("Server starting", {
	JobId = game.JobId,
	PlaceId = game.PlaceId,
	PrivateServerId = game.PrivateServerId,
	build = Env.BUILD_VERSION,
})

game.Close:Connect(function()
	Logging:Log("Server shutting down", { JobId = game.JobId, PlaceId = game.PlaceId })
end)
