-- Network (old - Crystal)
-- Network module

local network = {}

network.init = function(self, env)
	self.env = env
	rawset(env, "Network", self)
end

network.Event = function(action, data)
	local e = Event()
	e.action = action
	e.data = data

	return e
end

network.ParseEvent = function(self, event, parseTable)
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

return network