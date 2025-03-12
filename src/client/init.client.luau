local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Network)

local version = ReplicatedStorage.Version.Value

local player = Players.LocalPlayer

print(`build version: {version}`)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainScreen"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

local button = Instance.new("TextButton")
button.Text = "Go to dungeon"
button.AnchorPoint = Vector2.new(1, 1)
button.Position = UDim2.new(1, -5, 1, -5)
button.BackgroundTransparency = 0
button.Size = UDim2.fromOffset(100, 45)
button.Parent = screenGui

button.Activated:Connect(function()
	print("clicked")
	Network.Dungeon.Fire(true)
end)
