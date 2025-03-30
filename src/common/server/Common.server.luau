local ServerStorage = game:GetService("ServerStorage")

local Logging = require(ServerStorage.Logging)

require(ServerStorage.DungeonService)
require(ServerStorage.ServerMessage)

Logging:Log("Server starting", { JobId = game.JobId, PlaceId = game.PlaceId })

game.Close:Connect(function()
	Logging:Log("Server shutting down", { JobId = game.JobId, PlaceId = game.PlaceId })
end)
