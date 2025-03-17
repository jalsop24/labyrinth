local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DungeonGenerator = require(ServerStorage.DungeonGenerator)
local Network = require(ServerStorage.Network)

local TILE_SET = ReplicatedStorage.Assets.tile_set
local ORIGIN = Vector3.new(0, 0, 0)
local SIZE = Vector2.new(10, 10)
local MIN_NODES = 15
local MAX_NODES = 40

local SPAWN_ATTRIBUTE = "spawn_cframe"

local generator = DungeonGenerator.new(TILE_SET)

local spawnPoint: CFrame? = nil

Network.Dungeon.On(function(player: Player, foo: boolean)
	print("dungeon event")
	print(player, foo)

	if not player.Character or not spawnPoint then
		return
	end

	local character = player.Character
	local destination = spawnPoint + Vector3.new(0, 4, 0)

	character:PivotTo(destination)
	Network.Teleported.Fire(player, destination)
end)

local DungeonService = {}

function DungeonService:CreateDungeon(seed: number)
	local dungeon = generator:Generate(ORIGIN, SIZE, MIN_NODES, MAX_NODES, seed)
	print(dungeon)

	local startNode = dungeon.Graph[1]
	local room = startNode.Tile.Model
	local spawnPart: BasePart = room.Spawn

	dungeon.Model:SetAttribute(SPAWN_ATTRIBUTE, spawnPart:GetPivot())
	spawnPoint = spawnPart:GetPivot()
end

return DungeonService
