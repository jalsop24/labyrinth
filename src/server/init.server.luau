local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local DungeonService = require(ServerStorage.DungeonService)

local SEED = math.random(1, 10000)

DungeonService:CreateDungeon(SEED)

print(SEED)

local all_tags = CollectionService:GetAllTags()

print("tags")
print(all_tags)
