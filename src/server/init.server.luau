local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DungeonGenerator = require(ServerStorage.DungeonGenerator)

local TILE_SET = ReplicatedStorage.Assets.SmallTileSet
local ORIGIN = Vector3.new(0, 20, 0)
local SIZE = Vector2.new(10, 10)
local MIN_NODES = 15
local MAX_NODES = 40
local SEED = math.random(1, 10000)

local gen = DungeonGenerator.new(TILE_SET)
gen:Generate(ORIGIN, SIZE, MIN_NODES, MAX_NODES, SEED)
print(SEED)
