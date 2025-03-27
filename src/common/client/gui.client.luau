local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Env = require(ReplicatedStorage.Env)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Network = require(ReplicatedStorage.Network)

local player = Players.LocalPlayer

local rootScope = Fusion.scoped(Fusion)

local isStartPlace = game.PlaceId == tonumber(Env.START_PLACE_ID)

local function getButtonText()
	if isStartPlace then
		return "Go to dungeon"
	end

	return "Go to home"
end

local _screenGui = rootScope:New("ScreenGui")({
	Name = "MainScreen",
	ResetOnSpawn = false,
	Parent = player.PlayerGui,

	[Fusion.Children] = {
		textButton = rootScope:New("TextButton")({
			Text = getButtonText(),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -5, 1, -5),
			BackgroundTransparency = 0,
			Size = UDim2.fromOffset(100, 45),
			[Fusion.OnEvent("Activated")] = function()
				print("clicked")
				Network.Dungeon.Fire(true)
			end,
		}),
	},
})
