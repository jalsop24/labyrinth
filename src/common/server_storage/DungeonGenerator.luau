local PI = math.pi
local HALF_PI = 0.5 * PI
local WAIT_CYCLES = 1000
local WAIT_DURATION = 0.1

type Direction = "North" | "East" | "South" | "West"

local OPPOSITE_DIRECTIONS: { [Direction]: Direction } = {
	North = "South",
	East = "West",
	South = "North",
	West = "East",
}

local function rollList(list, num)
	-- Rolls a list such that
	-- rollList({"a", "b", "c", "d"}, 1) == {"b", "c", "d", "a"}

	local rolledList = {}
	for i = 1, #list do
		local newIdx = ((i + num - 1) % #list) + 1

		rolledList[i] = list[newIdx]
	end

	return rolledList
end

local Tile = {}
Tile.__index = Tile

type TileType = "Start" | "Basic" | "Treasure"

local TileType = {
	Start = "Start",
	Basic = "Basic",
	Treasure = "Treasure",
}

function Tile.new(model: Model)
	local self = {}

	self.NorthDoor = model:GetAttribute("NorthDoor") == true
	self.EastDoor = model:GetAttribute("EastDoor") == true
	self.SouthDoor = model:GetAttribute("SouthDoor") == true
	self.WestDoor = model:GetAttribute("WestDoor") == true

	self.TileType = (model:GetAttribute("TileType") or "Basic") :: TileType

	self.Model = model
	self.Rotation = model:GetPivot().Rotation

	setmetatable(self, Tile)
	return self
end

function Tile:Clone()
	return Tile.new(self.Model:Clone())
end

function Tile:SetPosition(position: Vector3)
	self.Model:PivotTo(CFrame.new(position) * self.Rotation)
end

type Tile = typeof(Tile.new(Instance.new("Model")))
type TileSet = {
	TileMap: {
		[string]: Tile,
	},
	TileWidth: number,
}

local function createTileSet(tileSetModel: Model): TileSet
	local tileMap = {}
	for _, child in tileSetModel:GetChildren() do
		local tileDoors = {
			child:GetAttribute("NorthDoor"),
			child:GetAttribute("EastDoor"),
			child:GetAttribute("SouthDoor"),
			child:GetAttribute("WestDoor"),
		}

		for i = 0, 3 do
			local rotatedModel = child:Clone()

			rotatedModel:PivotTo(child:GetPivot() * CFrame.Angles(0, HALF_PI * i, 0))

			local newDoors = rollList(tileDoors, i)

			rotatedModel:SetAttribute("NorthDoor", newDoors[1])
			rotatedModel:SetAttribute("EastDoor", newDoors[2])
			rotatedModel:SetAttribute("SouthDoor", newDoors[3])
			rotatedModel:SetAttribute("WestDoor", newDoors[4])

			rotatedModel.Name = `{child.Name}_{i}`

			tileMap[rotatedModel.Name] = Tile.new(rotatedModel)
		end
	end

	return {
		TileMap = tileMap,
		TileWidth = tileSetModel:GetAttribute("TileWidth"),
	}
end

type TileOption = {
	Position: {
		X: number,
		Y: number,
	},
	Tiles: { Tile },
}

type TileOptions = { TileOption }

type DungeonNode = {
	Tile: Tile,
	Position: { X: number, Y: number },
	Connections: { [Direction]: DungeonNode },
}

local Dungeon = {}
Dungeon.__index = Dungeon

local EMPTY = " - "
local OUT_OF_BOUNDS = " x "

function Dungeon.new(size: Vector2, tileSet: TileSet, minTiles: number, maxTiles: number, seed: number)
	local self = {}

	local populatedTiles = {}
	for x = 1, size.X do
		local row = {}
		for y = 1, size.Y do
			row[y] = EMPTY
		end
		populatedTiles[x] = row
	end

	self.Model = nil :: Model?
	self.Graph = {} :: { DungeonNode }
	self.Size = size
	self.PopulatedTiles = populatedTiles
	self.TileSet = tileSet
	self.TileWidth = tileSet.TileWidth
	self.MinTiles = minTiles
	self.MaxTiles = maxTiles
	self.Seed = seed
	self.RNG = Random.new(seed)

	setmetatable(self, Dungeon)
	return self
end

function Dungeon:_random(min: number, max: number)
	return self.RNG:NextInteger(min, max)
end

function Dungeon:_getTile(x, y)
	if x < 1 or x > self.Size.X or y < 1 or y > self.Size.Y then
		return OUT_OF_BOUNDS
	end
	return self.PopulatedTiles[x][y]
end

function Dungeon:_doesTileFit(tile: Tile, x: number, y: number): boolean
	local northTile = self:_getTile(x, y - 1)
	local eastTile = self:_getTile(x + 1, y)
	local southTile = self:_getTile(x, y + 1)
	local westTile = self:_getTile(x - 1, y)

	local northFits = (
		northTile == EMPTY
		or (tile.NorthDoor and (northTile ~= OUT_OF_BOUNDS and northTile.SouthDoor))
		or (not tile.NorthDoor and (northTile == OUT_OF_BOUNDS or not northTile.SouthDoor))
	)

	local eastFits = (
		eastTile == EMPTY
		or (tile.EastDoor and (eastTile ~= OUT_OF_BOUNDS and eastTile.WestDoor))
		or (not tile.EastDoor and (eastTile == OUT_OF_BOUNDS or not eastTile.WestDoor))
	)

	local southFits = (
		southTile == EMPTY
		or (tile.SouthDoor and (southTile ~= OUT_OF_BOUNDS and southTile.NorthDoor))
		or (not tile.SouthDoor and (southTile == OUT_OF_BOUNDS or not southTile.NorthDoor))
	)

	local westFits = (
		westTile == EMPTY
		or (tile.WestDoor and (westTile ~= OUT_OF_BOUNDS and westTile.EastDoor))
		or (not tile.WestDoor and (westTile == OUT_OF_BOUNDS or not westTile.EastDoor))
	)

	return northFits and eastFits and southFits and westFits
end

function Dungeon:_doesTileConnect(tile: Tile, x: number, y: number)
	local northTile = self:_getTile(x, y - 1)
	local eastTile = self:_getTile(x + 1, y)
	local southTile = self:_getTile(x, y + 1)
	local westTile = self:_getTile(x - 1, y)

	local northConnection = northTile and northTile.SouthDoor
	local eastConnection = eastTile and eastTile.WestDoor
	local southConnection = southTile and southTile.NorthDoor
	local westConnection = westTile and westTile.EastDoor

	return (
		(tile.NorthDoor and northConnection)
		or (tile.EastDoor and eastConnection)
		or (tile.SouthDoor and southConnection)
		or (tile.WestDoor and westConnection)
	)
end

function Dungeon:_getConnectingTiles(
	tile: Tile,
	x: number,
	y: number
): { North: Tile?, East: Tile?, South: Tile?, West: Tile? }
	local northTile = self:_getTile(x, y - 1)
	local eastTile = self:_getTile(x + 1, y)
	local southTile = self:_getTile(x, y + 1)
	local westTile = self:_getTile(x - 1, y)

	local northConnection = northTile and northTile.SouthDoor
	local eastConnection = eastTile and eastTile.WestDoor
	local southConnection = southTile and southTile.NorthDoor
	local westConnection = westTile and westTile.EastDoor

	return {
		North = (tile.NorthDoor and northConnection) and northTile or nil,
		East = (tile.EastDoor and eastConnection) and eastTile or nil,
		South = (tile.SouthDoor and southConnection) and southTile or nil,
		West = (tile.WestDoor and westConnection) and westTile or nil,
	}
end

function Dungeon:_getNodeFromTile(tile: Tile)
	for _, node in self.Graph do
		if node.Tile == tile then
			return node
		end
	end

	return nil
end

function Dungeon:_getConnectingNodes(tile: Tile, x: number, y: number): { [Direction]: DungeonNode }
	local connectedTiles = self:_getConnectingTiles(tile, x, y)
	local nodes = {}
	for direction, connectedTile in connectedTiles do
		local connectedNode = self:_getNodeFromTile(connectedTile)
		nodes[direction] = connectedNode
	end
	return nodes
end

function Dungeon:_addToGraph(tile: Tile, x: number, y: number)
	local connectedTiles = self:_getConnectingTiles(tile, x, y)

	local newNode = {} :: DungeonNode
	newNode.Tile = tile
	newNode.Position = {
		X = x,
		Y = y,
	}

	newNode.Connections = {}
	for direction, connectedTile in connectedTiles do
		local connectedNode = self:_getNodeFromTile(connectedTile)
		newNode.Connections[direction] = connectedNode

		if connectedNode then
			local oppositeDirection = OPPOSITE_DIRECTIONS[direction]
			connectedNode.Connections[oppositeDirection] = newNode
		end
	end

	table.insert(self.Graph, newNode)

	return newNode
end

function Dungeon:_getTileOptions(): TileOptions
	local tileOptions: TileOptions = {}

	local openSlots = self:_getOpenSlots()
	for _, pos in openSlots do
		local x = pos.X
		local y = pos.Y

		local possibleTiles: { Tile } = self:_getPossibleTiles(x, y)
		if #possibleTiles > 0 then
			table.insert(tileOptions, {
				Position = {
					X = x,
					Y = y,
				},
				Tiles = possibleTiles,
			})
		end
	end

	return tileOptions
end

function Dungeon:_getPossibleTiles(x: number, y: number): { Tile }
	local tileSet: TileSet = self.TileSet
	local possibleTiles: { Tile } = {}

	for _, tile in tileSet.TileMap do
		if not self:_isTileSuitable(tile, x, y) then
			continue
		end

		table.insert(possibleTiles, tile)
	end
	return possibleTiles
end

function Dungeon:_isTileSuitable(tile: Tile, x: number, y: number): boolean
	local isStart = #self.Graph == 0

	local isStartTile = tile.TileType == TileType.Start

	if not isStart and isStartTile or isStart and not isStartTile then
		return false
	end

	-- Does the tile close up the dungeon?
	local openSlots = self:_getOpenSlots()
	local connectingTiles = self:_getConnectingTiles(tile, x, y)

	local tileDoors = 0
	for _, door in { "NorthDoor", "EastDoor", "SouthDoor", "WestDoor" } do
		if tile[door] then
			tileDoors += 1
		end
	end

	local connectedDoors = 0
	for _, direction in { "North", "East", "South", "West" } do
		if connectingTiles[direction] then
			connectedDoors += 1
		end
	end

	local closesDungeon = tileDoors == connectedDoors
	if #openSlots == 1 and #self.Graph <= self.MinTiles and closesDungeon then
		return false
	end

	if #self.Graph > self.MaxTiles and not closesDungeon then
		return false
	end

	return ((isStart or self:_doesTileConnect(tile, x, y)) and self:_doesTileFit(tile, x, y))
end

function Dungeon:_getOpenSlots(): { Vector2 }
	local memo = self._getOpenSlotsMemo or {}
	if memo[1] == #self.Graph then
		return memo[2]
	end

	local isStart = #self.Graph == 0
	if isStart then
		local x = self:_random(1, self.Size.X)
		local y = self:_random(1, self.Size.Y)
		return { Vector2.new(x, y) }
	end

	local openSlots = {}
	local scanNodes = self.Graph
	if memo[1] == #self.Graph - 1 then
		local newNode = self.Graph[#self.Graph]
		local lastNodes = memo[3]

		scanNodes = table.clone(lastNodes)
		table.insert(scanNodes, newNode)
	end

	local openNodes = {}
	for _, node in scanNodes do
		local tile: Tile = node.Tile
		local position = node.Position

		local x = position.X
		local y = position.Y

		local tileOpenSlots = self:_tileOpenSlots(tile, x, y)
		if #tileOpenSlots > 0 then
			table.insert(openNodes, node)
		end
		for _, slot in tileOpenSlots do
			if not table.find(openSlots, slot) then
				table.insert(openSlots, slot)
			end
		end
	end

	self._getOpenSlotsMemo = { #self.Graph, openSlots, openNodes }
	return openSlots
end

function Dungeon:_tileOpenSlots(tile: Tile, x: number, y: number): { Vector2 }
	local slots = {}

	local connectingTiles = self:_getConnectingTiles(tile, x, y)
	if not connectingTiles.North and tile.NorthDoor and self:_getTile(x, y - 1) ~= OUT_OF_BOUNDS then
		local newSlot = Vector2.new(x, y - 1)
		table.insert(slots, newSlot)
	end

	if not connectingTiles.East and tile.EastDoor and self:_getTile(x + 1, y) ~= OUT_OF_BOUNDS then
		local newSlot = Vector2.new(x + 1, y)
		table.insert(slots, newSlot)
	end

	if not connectingTiles.South and tile.SouthDoor and self:_getTile(x, y + 1) ~= OUT_OF_BOUNDS then
		local newSlot = Vector2.new(x, y + 1)
		table.insert(slots, newSlot)
	end

	if not connectingTiles.West and tile.WestDoor and self:_getTile(x - 1, y) ~= OUT_OF_BOUNDS then
		local newSlot = Vector2.new(x - 1, y)
		table.insert(slots, newSlot)
	end

	return slots
end

function Dungeon:GetTiles()
	local thread = coroutine.create(function()
		for x, row in ipairs(self.PopulatedTiles) do
			for y, tile in ipairs(row) do
				coroutine.yield(x, y, tile)
			end
		end
	end)

	return function()
		local _, x, y, tile = coroutine.resume(thread)
		return x, y, tile
	end
end

function Dungeon:Generate(origin: Vector3, parent: Instance)
	local dungeonModel = Instance.new("Model")
	dungeonModel.Name = "Dungeon"
	dungeonModel.Parent = parent
	self.Model = dungeonModel

	local tileOptions = self:_getTileOptions()

	local counter = 0

	while #tileOptions > 0 do
		-- Get the option with the least number of possible tiles
		-- (i.e. options where only one tile is possible are handled first)
		table.sort(tileOptions, function(a: TileOption, b: TileOption)
			return #a.Tiles < #b.Tiles
		end)

		local smallestNumTiles = #tileOptions[1].Tiles
		local matchingOptionsCount = 0
		for i, options in tileOptions do
			if #options.Tiles > smallestNumTiles then
				break
			end
			matchingOptionsCount = i
		end

		-- Pick a random option when there is a tie for least tiles possible
		local tileOption = tileOptions[self:_random(1, matchingOptionsCount)]

		local position = tileOption.Position
		local tiles = tileOption.Tiles
		-- From that option, pick a random tile
		local tileIndex = self:_random(1, #tiles)

		-- Add new tile to the dungeon
		local tile: Tile = tiles[tileIndex]

		local clonedTile = tile:Clone()
		self.PopulatedTiles[position.X][position.Y] = clonedTile

		-- Update graph data
		self:_addToGraph(clonedTile, position.X, position.Y)

		clonedTile.Model.Name ..= ` ({position.X}, {position.Y})`

		if tile.TileType ~= TileType.Basic then
			clonedTile.Model.Name ..= `  [{tile.TileType}]`
		end

		local tilePosition = origin + self.TileWidth * (Vector3.xAxis * position.X + Vector3.zAxis * position.Y)
		clonedTile:SetPosition(tilePosition)
		clonedTile.Model.Parent = dungeonModel

		tileOptions = self:_getTileOptions()

		counter += 1
		if counter % WAIT_CYCLES == 0 then
			counter = 0
			print(#self.Graph)
			task.wait(WAIT_DURATION)
		end
	end
end

local DungeonGenerator = {}
DungeonGenerator.__index = DungeonGenerator

function DungeonGenerator.new(tileSetModel: Model)
	local self = {}

	self.TileSet = createTileSet(tileSetModel)

	setmetatable(self, DungeonGenerator)
	return self
end

function DungeonGenerator:Generate(origin: Vector3, size: Vector2, minNodes: number, maxNodes: number, seed: number)
	local dungeon = Dungeon.new(size, self.TileSet, minNodes, maxNodes, seed)
	dungeon:Generate(origin, workspace)
	return dungeon
end

return DungeonGenerator
