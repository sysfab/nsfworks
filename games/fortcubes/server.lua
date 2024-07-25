debug.enabled = true
debug.log("server() - online")

game = {}
players = {}
event_players = {}
function resetGame()
	debug.log("server() - resetting game..")
	game.time = 0
	game.ticks = 0
end

function getPlayerByUsername(username)
	for k, v in pairs(event_players) do
		if k == username then
			return v
		end
	end
end

Server.OnStart = function()
	resetGame()
end

Server.OnPlayerJoin = function(player)
	debug.log("server() - player joined [" .. player.Username .. "]")
end

Server.OnPlayerLeave = function(player)
	debug.log("server() - player leaved [" .. player.Username .. "]")
	if players[player.Username] ~= nil then
		players[player.Username] = nil
		event_players[player.Username] = nil
		debug.log("server() - removed player entry for '".. player.Username .."'")
	end
end

Server.DidReceiveEvent = function(e) 
	crystal.ParseEvent(e, {

	connect = function(event)
		debug.log("server() - connecting '".. event.Sender.Username .."'")
		if players[event.Sender.Username] == nil then
			for player, stats in pairs(Players) do
				if getPlayerByUsername(player) ~= nil then
					local r = crystal.Event("new_connection", {player = player, stat = stats})
					r:SendTo(getPlayerByUsername(player))
				else
					debug.error("server() - failed to find player "..player)
				end
			end
			players[event.Sender.Username] = {kills = 0, deaths = 0}
			event_players[event.Sender.Username] = event.Sender
			debug.log("server() - created player entry for '".. event.Sender.Username .."'")

			local r = crystal.Event("connected", {players = players, game = game, posX = math.random(20, 80)/100, posY = math.random(20, 80)/100})
			r:SendTo(event.Sender)
		end
	end,

	disconnect = function(event)
		debug.log("server() - disconnecting '".. event.Sender.Username .."'")
		if players[event.Sender.Username] ~= nil then
			for player, stats in pairs(Players) do
				if getPlayerByUsername(player) ~= nil then
					local r = crystal.Event("new_disconnection", {player = player, stat = stats})
					r:SendTo(getPlayerByUsername(player))
				else
					debug.error("server() - failed to find player "..player)
				end
			end
			players[event.Sender.Username] = nil
			event_players[event.Sender.Username] = nil
			debug.log("server() - removed player entry for '".. event.Sender.Username .."'")
		end
	end,

	["_"] = function(event)
		debug.log("server() - got unknown event: "..tostring(event.action))
	end

	})
end