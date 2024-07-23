-- Debug
-- Debugging module

local debug = {}

debug.enabled = false
debug.history = {}

debug.log = function(message)
	table.insert(debug.history, {type = "message", content = tostring(message)})
	if debug.enabled == true then
		print("[DEBUG]: "..tostring(message))
	end
end

debug.error = function(message, level)
	if level == nil then
		level = 1
	end
	level = level + 1

	table.insert(debug.history, {type = "error", content = tostring(message)})
	if debug.enabled == true then
		error("[DEBUG ERROR]: "..tostring(message), level)
	end
end

debug.assert = function(condition, message, level)
	if level == nil then
		level = 1
	end
	level = level + 1

	if not condition then
		table.insert(debug.history, {type = "error", content = tostring(message)})
	end
	if debug.enabled == true then
		if not condition then
			error("[DEBUG ASSERT]: "..tostring(message), level)
		end
	end
end

return debug