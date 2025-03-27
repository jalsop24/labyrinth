local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Network = require(ReplicatedStorage.Network)

local player = Players.LocalPlayer

print("Fusion version")
print(Fusion.version)

local rootScope = Fusion.scoped(Fusion)

local _screenGui = rootScope:New("ScreenGui")({
	Name = "MainScreen",
	ResetOnSpawn = false,
	Parent = player.PlayerGui,

	[Fusion.Children] = {
		textButton = rootScope:New("TextButton")({
			Text = "Go to dungeon",
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
