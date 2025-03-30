local ServerStorage = game:GetService("ServerStorage")

local DungeonService = require(ServerStorage.DungeonService)

local SEED = math.random(1, 10000)

DungeonService:CreateDungeon(SEED)

print(SEED)

print("Hi from destination place")
