local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")

local DungeonGenerator = require(ServerStorage.DungeonGenerator)
local Env = require(ReplicatedStorage.Env)
local Network = require(ServerStorage.Network)

local TILE_SET = ReplicatedStorage.Assets.tile_set
local ORIGIN = Vector3.new(0, 0, 0)
local SIZE = Vector2.new(10, 10)
local MIN_NODES = 15
local MAX_NODES = 40

local SPAWN_ATTRIBUTE = "spawn_cframe"

local generator = DungeonGenerator.new(TILE_SET)

local spawnPoint: CFrame? = nil

local function localTeleport(player: Player)
	if not player.Character or not spawnPoint then
		return
	end

	local character = player.Character
	local destination = spawnPoint + Vector3.new(0, 4, 0)

	character:PivotTo(destination)
	Network.Teleported.Fire(player, destination)
end

local function placeTeleport(player: Player)
	local placeId = nil
	if game.PlaceId == tonumber(Env.DESTINATION_PLACE_ID) then
		placeId = tonumber(Env.START_PLACE_ID)
	elseif game.PlaceId == tonumber(Env.START_PLACE_ID) then
		placeId = tonumber(Env.DESTINATION_PLACE_ID)
	else
		print(`In unknown place id={game.PlaceId}`)
		return
	end

	TeleportService:TeleportAsync(placeId, { player })
end

Network.Dungeon.On(function(player: Player, to_place: boolean)
	print("dungeon event")
	print(player, to_place)

	if to_place then
		placeTeleport(player)
	else
		localTeleport(player)
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
	spawnPoint = spawnPart:GetPivot()
end

return DungeonService
