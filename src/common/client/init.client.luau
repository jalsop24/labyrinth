local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Network)

local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local cameraOffset = CFrame.new(0, 10, 10)

Network.Teleported.On(function(_: CFrame)
	local character = player.Character
	if not character then
		return
	end

	task.spawn(function()
		Camera.CFrame = character.WorldPivot * cameraOffset

		-- char * offset = workspace_cam
		-- offset = char:inv * workspace_cam

		print(`Set camera - {Camera.CFrame}`)
		print(`offset - {cameraOffset.Position}`)
	end)
end)
