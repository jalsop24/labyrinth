local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local DungeonService = require(ServerStorage.DungeonService)
local Logging = require(ServerStorage.Logging)
local ServerMessage = require(ServerStorage.ServerMessage)

print("Hi from destination place")

local function generateDungeon(message: any)
	Logging:Log("Received message", { Message = tostring(message), JobId = game.JobId })

	if type(message) ~= "table" then
		return
	end
	Logging:Log("message data", message)

	if message.seed == nil or DungeonService:HasGeneratedDungeon() then
		return
	end

	DungeonService:CreateDungeon(message.seed)
end

ServerMessage:RegisterMessageHandler(generateDungeon)

if RunService:IsStudio() then
	generateDungeon({ seed = 1234 })
end
