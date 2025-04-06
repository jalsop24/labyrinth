local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")

local Env = require(ReplicatedStorage.Env)
local Logging = require(ServerStorage.Logging)
local Network = require(ServerStorage.Network)

local PlayerTransport = {}

function PlayerTransport:SendToPlace(player: Player): TeleportAsyncResult?
	local placeId = nil
	if game.PlaceId == tonumber(Env.DESTINATION_PLACE_ID) then
		placeId = tonumber(Env.START_PLACE_ID)
	elseif game.PlaceId == tonumber(Env.START_PLACE_ID) then
		placeId = tonumber(Env.DESTINATION_PLACE_ID)
	else
		Logging:Log("In unknown place", { PlaceId = game.PlaceId })
		return
	end

	local options = Instance.new("TeleportOptions")
	options.ShouldReserveServer = true

	local result = TeleportService:TeleportAsync(placeId, { player }, options)

	Logging:Log("Sent player to place", {
		UserId = player.UserId,
		PrivateServerId = result.PrivateServerId,
	})

	return result
end

function PlayerTransport:SentToCFrame(player: Player, destination: CFrame)
	if not player.Character then
		return
	end

	local character = player.Character

	character:PivotTo(destination)
	Network.Teleported.Fire(player, destination)
end

return PlayerTransport
