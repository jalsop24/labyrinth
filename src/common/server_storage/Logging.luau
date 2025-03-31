local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")

local Logging = {}

type RecordData = {
	[string]: any,
} | nil

type Record = {
	Message: string,
	Data: RecordData,
	Timestamp: DateTime,
}

type RecordHandler = (Record) -> nil

local records: { Record } = table.create(1_000)

local handlers: { RecordHandler } = {}

local function runHandlers(record: Record)
	for _, handler in handlers do
		handler(record)
	end
end

function Logging:Log(message: string, data: RecordData)
	local record: Record = {
		Message = message,
		Data = data,
		Timestamp = DateTime.now(),
	}
	runHandlers(record)
	table.insert(records, record)
end

function Logging:RegisterHandler(handler: (record: Record) -> nil)
	table.insert(handlers, handler)
end

-- -- --

function Logging.PrintHandler(record: Record)
	local message = `[{record.Timestamp:ToIsoDate()}] - {record.Message}`

	if record.Data ~= nil then
		print(message)
		print(HttpService:JSONEncode(record.Data))
	else
		print(message)
	end
end

function Logging.MemoryStoreHandler(record: Record)
	local EXPIRATION = 60 * 60 -- seconds

	local queue = MemoryStoreService:GetQueue("logging")
	queue:AddAsync(
		{
			Message = record.Message,
			Timestamp = record.Timestamp:ToIsoDate(),
			Data = HttpService:JSONEncode(record.Data),
		},
		EXPIRATION
	)
end

Logging:RegisterHandler(Logging.PrintHandler)

if not RunService:IsStudio() then
	Logging:RegisterHandler(Logging.MemoryStoreHandler)
end

return Logging
