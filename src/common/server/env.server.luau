local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Env = require(ReplicatedStorage.Env)
print("Environment:")
for k, v in pairs(Env) do
	print(`{k} = {v}`)
end
