local ServerStorage = game:GetService("ServerStorage")

local Logging = require(ServerStorage.Logging)
require(ServerStorage.DungeonService)

game.Close:Connect(function()
	Logging:Log("Server shutting down", { JobId = game.JobId, PlaceId = game.PlaceId })
end)
