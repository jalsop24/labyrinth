local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DungeonGenerator = require(ServerStorage.DungeonGenerator)
local Logging = require(ServerStorage.Logging)
local Network = require(ServerStorage.Network)
local PlayerTransport = require(ServerStorage.PlayerTransport)
local ServerMessage = require(ServerStorage.ServerMessage)

local TILE_SET = ReplicatedStorage.Assets.tile_set
local ORIGIN = Vector3.new(0, 0, 0)
local SIZE = Vector2.new(10, 10)
local MIN_NODES = 15
local MAX_NODES = 40

local SPAWN_ATTRIBUTE = "spawn_cframe"

local generator = DungeonGenerator.new(TILE_SET)

local spawnPoint: CFrame? = nil

Network.Dungeon.On(function(player: Player, to_place: boolean)
	print("dungeon event")
	print(player, to_place)

	if to_place then
		PlayerTransport:SendToPlace(player)
	else
		assert(spawnPoint ~= nil, "Spawn point must not be nil")
		PlayerTransport:SentToCFrame(player, spawnPoint)
	end
end)

local DungeonService = {}

function DungeonService:CreateDungeon(seed: number)
	local dungeon = generator:Generate(ORIGIN, SIZE, MIN_NODES, MAX_NODES, seed)
	print(dungeon)

	local startNode = dungeon.Graph[1]
	local room = startNode.Tile.Model
	local spawnPart: BasePart = room.Spawn

	dungeon.Model:SetAttribute(SPAWN_ATTRIBUTE, spawnPart:GetPivot())
	spawnPoint = spawnPart:GetPivot() + Vector3.new(0, 4, 0)
end

ServerMessage:RegisterMessageHandler(function(message: any)
	Logging:Log("Received message", { Message = tostring(message), JobId = game.JobId })
	if type(message) == "table" then
		Logging:Log("message data", message)
	end
end)

return DungeonService
