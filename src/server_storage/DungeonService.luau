local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DungeonGenerator = require(ServerStorage.DungeonGenerator)
local Network = require(ServerStorage.Network)

local TILE_SET = ReplicatedStorage.Assets.SmallTileSet
local ORIGIN = Vector3.new(0, 0, 0)
local SIZE = Vector2.new(10, 10)
local MIN_NODES = 15
local MAX_NODES = 40

local SPAWN_ATTRIBUTE = "spawn_cframe"

local generator = DungeonGenerator.new(TILE_SET)

Network.Dungeon.On(function(player: Player, foo: boolean)
	print("dungeon event")
	print(player, foo)
end)

local DungeonService = {}

function DungeonService:CreateDungeon(seed: number)
	local dungeon = generator:Generate(ORIGIN, SIZE, MIN_NODES, MAX_NODES, seed)
	print(dungeon)

	local startNode = dungeon.Graph[1]
	local room = startNode.Tile.Model
	local spawnPart = room.Spawn

	dungeon.Model:SetAttribute(SPAWN_ATTRIBUTE, spawnPart:GetPivot())
end

return DungeonService
