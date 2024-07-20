local crystal = {}

crystal.Event = function(action, data)
	local e = Event()
	e.action = action
	e.data = data

	return e
end

crystal.ParseEvent = function(event, parseTable)
	for action, func in pairs(parseTable) do
		if event.action == action then
			func(event)
			return
		end
	end
	if parseTable["_"] ~= nil then
		parseTable["_"](event)
	end
end

return crystal