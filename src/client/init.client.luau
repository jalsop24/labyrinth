local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Network)

local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local cameraOffset = CFrame.new(0, 10, 10)

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

Network.Teleported.On(function(_: CFrame)
	local character = player.Character
	if not character then
		return
	end

	task.delay(0, function()
		Camera.CFrame = character.WorldPivot * cameraOffset

		-- char * offset = workspace_cam
		-- offset = char:inv * workspace_cam

		print(`Set camera - {Camera.CFrame}`)
		print(`offset - {cameraOffset.Position}`)
	end)
end)
