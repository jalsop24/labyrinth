local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local DungeonService = require(ServerStorage.DungeonService)
local Logging = require(ServerStorage.Logging)
local Network = require(ServerStorage.Network)
local PlayerTransport = require(ServerStorage.PlayerTransport)
local ServerMessage = require(ServerStorage.ServerMessage)

print("Hi from destination place")

local function createSpawnPoint(location: CFrame)
	local spawnPoint = Instance.new("SpawnLocation")
	spawnPoint.Anchored = true
	spawnPoint:PivotTo(location)
	spawnPoint.CanCollide = false
	spawnPoint.Transparency = 1
	spawnPoint.Parent = workspace
	return spawnPoint
end

local function spawnPlayers()
	for _, player in Players:GetPlayers() do
		player:LoadCharacter()
	end
end

local function generateDungeon(message: any)
	Logging:Log("Received message", { Message = tostring(message), JobId = game.JobId })

	if type(message) ~= "table" then
		return
	end
	Logging:Log("message data", message)

	if message.seed == nil or DungeonService:HasGeneratedDungeon() then
		return
	end

	local spawnCframe = DungeonService:CreateDungeon(message.seed)
	local spawnLocation = createSpawnPoint(spawnCframe)
	Logging:Log(
		"Made spawn point",
		{ x = spawnLocation.Position.X, y = spawnLocation.Position.Y, z = spawnLocation.Position.Z }
	)
	Players.CharacterAutoLoads = true
	spawnPlayers()
end

local function handleHomeTeleport(player: Player)
	PlayerTransport:SendToPlace(player, "start")
end

ServerMessage:RegisterMessageHandler(generateDungeon)
Network.TeleportHome.On(handleHomeTeleport)

if RunService:IsStudio() then
	generateDungeon({ seed = 1234 })
end
