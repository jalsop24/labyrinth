local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Env = require(ReplicatedStorage.Env)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Network = require(ReplicatedStorage.Network)

type Fusion = typeof(Fusion)

local player = Players.LocalPlayer

local rootScope = Fusion.scoped(Fusion)

local isStartPlace = game.PlaceId == tonumber(Env.START_PLACE_ID)

local function getButtonText()
	if isStartPlace then
		return "Go to dungeon"
	end

	return "Go to home"
end

local function DungeonButton(scope: Fusion.Scope<Fusion>, props: { Text: Fusion.UsedAs<string> })
	return scope:New("TextButton")({
		Text = props.Text,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -5, 1, -5),
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(100, 45),
		[Fusion.OnEvent("Activated")] = function()
			print("clicked")
			if isStartPlace then
				Network.Dungeon.Fire(true, "4321")
			else
				Network.Dungeon.Fire(false)
			end
		end,
	})
end

local _screenGui = rootScope:New("ScreenGui")({
	Name = "MainScreen",
	ResetOnSpawn = false,
	Parent = player.PlayerGui,

	[Fusion.Children] = {
		textButton = DungeonButton(rootScope, { Text = getButtonText() }),
	},
})
