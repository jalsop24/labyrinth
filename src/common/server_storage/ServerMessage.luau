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

local ServerMessage = {}

function ServerMessage:SendMessage(jobId: number, message: any)
	MessagingService:PublishAsync(tostring(jobId), message)
end

return ServerMessage
