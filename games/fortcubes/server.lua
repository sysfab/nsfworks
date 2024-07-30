debug.enabled = false
debug.log("server() - Loaded from: '"..repo.."' repo. Commit: '"..githash.."'")
debug.log("server() - Starting '"..game.."' server...")

function set(key, value)
	rawset(_ENV, key, value)
end

set("CRASH", function(message)
	message = tostring(message)
	pcall(function()
		Server.DidReceiveEvent = nil
		Server.OnPlayerJoin = nil
		Server.OnPlayerLeave = nil
		Server.Tick = nil
	end)

	local e = crystal.Event("server_crash", {error=message})
	e:SendTo(Players)

	debug.log("")
	debug.log("CRASH WAS CALLED:")
	debug.log(message)
	debug.log("")
	debug.error("CRASH() - crash was called", 2)
	error("CRASH() - crash was called", 2)
end)

-- CONFIG
set("VERSION", "v1.0")
set("ADMINS", {"nsfworks", "fab3kleuuu", "nanskip"})

debug.log("server() - version: "..VERSION)

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

Server.DidReceiveEvent = errorHandler(function(e) 
	crystal.ParseEvent(e, {

	connect = function(event)
		debug.log("server() - connecting '".. event.Sender.Username .."'")
		if players[event.Sender.Username] == nil then
			for player, stats in pairs(players) do
				if getPlayerByUsername(player) ~= nil then
					local r = crystal.Event("new_connection", {player = event.Sender.Username, stat = stats})
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
			for player, stats in pairs(players) do
				if getPlayerByUsername(player) ~= nil then
					local r = crystal.Event("new_disconnection", {player = event.Sender.Username, stat = stats})
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

	get_logs = function(event)
		debug.log("server() - sending server logs to "..event.Sender.Username)

		local r = crystal.Event("server_logs", debug:export())
		r:SendTo(event.Sender)
	end,

	send_rocks = function(event)
		local e = crystal.Event("load_rocks", {rocks = JSON:Encode(server_rocks)})
		e:SendTo(event.Sender)
	end,

	send_bushes = function(event)
		local e = crystal.Event("load_bushes", {bushes = JSON:Encode(server_bushes)})
		e:SendTo(event.Sender)
	end,

	crash = function(event)
		for i, username in ipairs(ADMINS) do
			if username == event.Sender.Username then
				error("crashed by admin")
			end
		end
	end,

	["_"] = function(event)
		debug.log("server() - got unknown event: "..tostring(event.action))
	end

	})
end, function(err) CRASH("Server.DidReceiveEvent - "..err) end)

function createRocks()
	server_rocks = {}
	debug.log("server() - creating rocks...")
	
	for i=1, 50 do
		server_rocks[i] = {}
		server_rocks[i].pos = {(math.random(1, 64))*5, 5, (math.random(1, 64))*5}
		server_rocks[i].rot = math.random(-314, 314)*0.01

		local c = math.random(-20, 20)
		server_rocks[i].col1 = {130+c, 140+c, 140+c}
		server_rocks[i].col2 = {140+c, 150+c, 160+c}
		server_rocks[i].id = i
	end

	debug.log("server() - rocks created: " .. tostring(server_bushes))
end

function createBushes()
	server_bushes = {}
	debug.log("server() - creating rocks...")
	
	for i=1, 50 do
		server_bushes[i] = {}
		server_bushes[i].pos = {(math.random(1, 64))*5, 5, (math.random(1, 64))*5}
		server_bushes[i].rot = math.random(-314, 314)*0.01

		local c = math.random(-20, 20)
		server_bushes[i].id = i
	end

	debug.log("server() - rocks created: " .. tostring(server_bushes))
end

resetGame()
createRocks()
createBushes()