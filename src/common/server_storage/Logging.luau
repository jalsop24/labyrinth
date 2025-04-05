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
	UtcMillis: number,
	Source: string,
	LineNum: number,
	FuncName: string?,
}

local function isoDatetime(datetime: DateTime)
	return datetime:FormatUniversalTime("YYYY-MM-DD HH:mm:ss.SSS+00:00", "en-gb")
end

type RecordHandler = (Record) -> nil

local records: { Record } = table.create(1_000)

local handlers: { RecordHandler } = {}

local function runHandlers(record: Record)
	for _, handler in handlers do
		handler(record)
	end
end

function Logging:Log(message: string, data: RecordData)
	local source, lineNum, funcName = debug.info(2, "sln")
	local record: Record = {
		Message = message,
		Data = data,
		Timestamp = DateTime.now(),
		UtcMillis = tick() * 1000,
		Source = source,
		LineNum = lineNum,
		FuncName = funcName,
	}
	runHandlers(record)
	table.insert(records, record)
end

function Logging:RegisterHandler(handler: (record: Record) -> nil)
	table.insert(handlers, handler)
end

-- -- --

function Logging.PrintHandler(record: Record)
	local message = `[{isoDatetime(record.Timestamp)}] {record.Message} - {record.Source}:{record.LineNum}`

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
	queue:AddAsync({
		Message = record.Message,
		Timestamp = isoDatetime(record.Timestamp),
		UtcMillis = record.UtcMillis,
		Data = HttpService:JSONEncode(record.Data),
		Source = record.Source,
		LineNum = record.LineNum,
		FuncName = record.FuncName,
	}, EXPIRATION)
end

Logging:RegisterHandler(Logging.PrintHandler)

if not RunService:IsStudio() then
	Logging:RegisterHandler(Logging.MemoryStoreHandler)
end

return Logging
