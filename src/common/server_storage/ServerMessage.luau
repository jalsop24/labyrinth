local MessagingService = game:GetService("MessagingService")
local ServerStorage = game:GetService("ServerStorage")

local Logging = require(ServerStorage.Logging)

type Message = {
	Name: string,
	Data: any,
}

local function onMessage(message: Message)
	Logging:Log("Received message", { Message = message, JobId = game.JobId })
end

MessagingService:SubscribeAsync(tostring(game.JobId), onMessage)
if game.PrivateServerId ~= "" then
	MessagingService:SubscribeAsync(tostring(game.PrivateServerId), onMessage)
end

local ServerMessage = {}

function ServerMessage:SendMessage(serverId: number | string, message: any)
	MessagingService:PublishAsync(tostring(serverId), message)
end

return ServerMessage
