local debug = {}

debug.enabled = false

debug.log = function(message)
	if debug.enabled == true then
		print("[DEBUG]: "..tostring(message))
	end
end

debug.error = function(message, level)
	if level == nil then
		level = 1
	end
	level = level + 1

	if debug.enabled == true then
		error("[DEBUG]: "..tostring(message), level)
	end
end

return debug