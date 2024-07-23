debug.enabled = true
debug.log("server() - online")

Server.OnPlayerJoin = function(player)
	debug.log("server() - player joined [" .. player.Username .. "]")
end

Server.OnPlayerLeave = function(player)
	debug.log("server() - player leaved [" .. player.Username .. "]")
end

Server.DidReceiveEvent = function(e)
	crystal.ParseEvent(e, {
		"_" = function(event)
			debug.log("server() - got unknown event: "..tostring(event.action))
		end
	})
end