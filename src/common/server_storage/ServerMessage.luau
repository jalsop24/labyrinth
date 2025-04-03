local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local ServerStorage = game:GetService("ServerStorage")

local Logging = require(ServerStorage.Logging)

type Message = {
	Name: string,
	Data: any,
}

local function getQueue(privateServerId: string)
	return MemoryStoreService:GetQueue(`messages-{privateServerId}`)
end

local function onMessage(message: Message)
	Logging:Log("Received message", { Message = message, JobId = game.JobId })
end

local function pollQueue(queue: MemoryStoreQueue)
	while true do
		pcall(function()
			local items, id = queue:ReadAsync(10, false, 30)

			for _, item in items do
				onMessage({ Name = "x", Data = item })
			end

			if #items > 0 then
				queue:RemoveAsync(id)
			end
		end)
		task.wait(0.5)
	end
end

local function setupSubs()
	MessagingService:SubscribeAsync(tostring(game.JobId), onMessage)
	if game.PrivateServerId ~= "" then
		MessagingService:SubscribeAsync(tostring(game.PrivateServerId), onMessage)
		local queue = getQueue(game.PrivateServerId)
		task.spawn(pollQueue, queue)
	end
end

local ServerMessage = {}

function ServerMessage:SendMessage(serverId: number | string, message: any)
	local queue = getQueue(tostring(serverId))
	queue:AddAsync(message, 1800)
end

setupSubs()
return ServerMessage
