-- Network (old - Crystal)
-- Network module

local network = {}

local event_mt = {
	__metatable = nil,
	__type = "NetworkEvent",
	__index = function(self, key)
		if key == "data" then 
			return self.event.data
		elseif key == "action" then
			return self.event.action
		elseif key == "SendTo" then
			return self.event.SendTo
		elseif key == "Sender" then
			return self.event.Sender
		elseif key == "Author" then
			return self.event.author
		elseif key == "Reply" then
			return function(...)
				local r = network.Event(...)
				r:SendTo(self.Sender)
			end
		elseif key == "Forward" then
			return self.event.SendTo
		end
	end
	__newindex = function(self, key, value)
		if key == "data" then 
			self.event.data = value
		elseif key == "action" then
			self.event.action = value
		end
	end
}

network.init = function(self, env)
	self.env = env
	rawset(env, "Network", self)
end

local rawEvent = function(action, data, sender)
	local e = Event()
	e.action = action

	if IsClient then e.author = Player else e.author = Server end

	e.data = data

	return e
end

network.Event = function(action, data)
	local e = rawEvent(action, data)

	local event = {}
	event.event = event

	setmetatable(event, event_mt)

	return event
end

network.ParseEvent = function(self, event, parseTable)
	local new_event = self.Event(event.action, event.data)
	rawget(new_event, "event").sender = event.Sender

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