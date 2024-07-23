debug.enabled = true
debug.log("server() - online")

game = {}
players = {}
function resetGame()
	debug.log("server() - resetting game..")
	game.time = 0
	game.ticks = 0
end

Server.OnStart = function()
	resetGame()
end

Server.OnPlayerJoin = function(player)
	debug.log("server() - player joined [" .. player.Username .. "]")
end

Server.OnPlayerLeave = function(player)
	debug.log("server() - player leaved [" .. player.Username .. "]")
	if players[event.Sender] ~= nil then
		players[event.Sender] = nil
		debug.log("server() - removed player from players [" .. player.Username .. "]")
	end
end

Server.DidReceiveEvent = function(e) 
	crystal.ParseEvent(e, {

	connect = function(event)
		debug.log("server() - connecting '".. event.Sender.Username .."'")
		if players[event.Sender] == nil then
			players[event.Sender] = {kills = 0, deaths = 0}
			debug.log("server() - created player entry for '".. event.Sender.Username .."'")
		end
	end,

	["_"] = function(event)
		debug.log("server() - got unknown event: "..tostring(event.action))
	end

	})
end