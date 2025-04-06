local MemoryStoreService = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Logging = require(ServerStorage.Logging)

local handlers = {}

local function getQueue(privateServerId: string)
	return MemoryStoreService:GetQueue(`messages-{privateServerId}`)
end

local function onMessage(message: any)
	for _, handler in handlers do
		pcall(handler, message)
	end
end

local function pollQueue(queue: MemoryStoreQueue)
	while true do
		local success, errorMessage = pcall(function()
			local items, id = queue:ReadAsync(10, false, 30)

			local numItems = 0
			if items ~= nil then
				numItems = #items
			end

			Logging:Log("Queue items", { numItems = numItems })

			if numItems == 0 then
				return
			end

			for _, item in items do
				onMessage(item)
			end
			queue:RemoveAsync(id)
		end)
		Logging:Log("Polled message queue", { success = success, error = errorMessage })
		task.wait(0.5)
	end
end

local function setupSubs()
	if game.PrivateServerId ~= "" then
		local queue = getQueue(game.PrivateServerId)
		task.spawn(pollQueue, queue)
	end
end

local ServerMessage = {}

function ServerMessage:SendMessage(serverId: number | string, message: any)
	if RunService:IsStudio() then
		Logging:Log("In studio - not sending real message", { Message = message })
		return
	end
	local queue = getQueue(tostring(serverId))
	queue:AddAsync(message, 1800)
end

function ServerMessage:RegisterMessageHandler(handler: (...any) -> nil)
	table.insert(handlers, handler)
end

setupSubs()
return ServerMessage
