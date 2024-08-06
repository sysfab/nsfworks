Debug.enabled = false
Debug.log("server() - Loaded from: '"..repo.."' repo. Commit: '"..githash.."'")
Debug.log("server() - Starting '"..game.."' server...")

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

	local e = Network.Event("server_crash", {error=message})
	e:SendTo(Players)

	Debug.log("")
	Debug.log("CRASH WAS CALLED:")
	Debug.log(message)
	Debug.log("")
	Debug.error("CRASH() - crash was called", 2)
	error("CRASH() - crash was called", 2)
end)

-- CONFIG
set("VERSION", "v1.1")
set("ADMINS", {"nsfworks", "fab3kleuuu", "nanskip"})
set("BOT_COUNT", 1)

Debug.log("server() - version: "..VERSION)

game = {}
players = {}
event_players = {}

function createBot(username)
	local bot = {}
	bot.username = username

	bot.x = math.random(1, 64*5)
	bot.z = math.random(1, 64*5)

	bot.rotation = 0

	return bot
end

function resetGame()
	Debug.log("server() - resetting game..")
	game.time = 0
	game.time_end = 60*3 -- In seconds
	game.ticks = 0
	game.winner = "unknown"
	if game.players ~= nil then
		local top_player = "unknown"
		local kills = 0
		local deaths = 0
		local coff = 0

		for k, v in pairs(game.players) do
			local score = v.kills - (v.deaths/v.kills)
			if score > coff then
                coff = score
				top_player = v.name
				kills = v.kills
                deaths = v.deaths
			end
			Debug.log("server() - player " .. v.name .. " kills: " .. v.kills .. "; deaths: " .. v.deaths)
		end

		local e = Network.Event("top", {winner = top_player, kills = kills, deaths = deaths})
        e:SendTo(Players)
		game.winner = top_player
	end
	game.players = {}
	game.players_connected = 0
	game.bots = {}

	Debug.log("Creating bots...")
	for i = 1, BOT_COUNT do
		table.insert(game.bots, createBot("bot"..i.." "))
		Debug.log("Created bot with username 'bot"..i.." '")
	end

	local e = Network.Event("round_end", {winner = game.winner})
	e:SendTo(Players)
end

function getPlayerByUsername(username)
	for k, v in pairs(event_players) do
		if k == username then
			return v
		end
	end
end

Server.OnPlayerJoin = function(player)
	Debug.log("server() - player joined [" .. player.Username .. "]")
end

Server.OnPlayerLeave = function(player)
	Debug.log("server() - player leaved [" .. player.Username .. "]")
	if players[player.Username] ~= nil then
		players[player.Username] = nil
		event_players[player.Username] = nil
		game.players_connected = game.players_connected - 1
		Debug.log("server() - removed player entry for '".. player.Username .."'")
	end
end

Server.DidReceiveEvent = errorHandler(function(e) 
	Network:ParseEvent(e, {

	connect = function(event)
		Debug.log("server() - connecting '".. event.Sender.Username .."'")
		if players[event.Sender.Username] == nil then
			for player, stats in pairs(players) do
				if getPlayerByUsername(player) ~= nil then
					local r = Network.Event("new_connection", {player = event.Sender.Username, stat = stats})
					r:SendTo(getPlayerByUsername(player))
				else
					Debug.error("server() - failed to find player "..player)
				end
			end
			players[event.Sender.Username] = {kills = 0, deaths = 0}
			event_players[event.Sender.Username] = event.Sender
			game.players_connected = game.players_connected + 1
			Debug.log("server() - created player entry for '".. event.Sender.Username .."'")

			local r = Network.Event("connected", {players = players, game = game, posX = math.random(20, 80)/100, posY = math.random(20, 80)/100})
			r:SendTo(event.Sender)
			if game.players[event.Sender.Username] == nil then
				game.players[event.Sender.Username] = {kills = 0, deaths = 0, name = event.Sender.Username}
			end
		end
	end,

	disconnect = function(event)
		Debug.log("server() - disconnecting '".. event.Sender.Username .."'")
		if players[event.Sender.Username] ~= nil then
			for player, stats in pairs(players) do
				if getPlayerByUsername(player) ~= nil then
					local r = Network.Event("new_disconnection", {player = event.Sender.Username, stat = stats})
					r:SendTo(getPlayerByUsername(player))
				else
					Debug.error("server() - failed to find player "..player)
				end
			end
			players[event.Sender.Username] = nil
			event_players[event.Sender.Username] = nil
			game.players_connected = game.players_connected - 1
			Debug.log("server() - removed player entry for '".. event.Sender.Username .."'")
		end
	end,

	get_logs = function(event)
		Debug.log("server() - sending server logs to "..event.Sender.Username)

		local r = Network.Event("server_logs", Debug:export())
		r:SendTo(event.Sender)
	end,

	send_rocks = function(event)
		local e = Network.Event("load_rocks", {rocks = JSON:Encode(server_rocks)})
		e:SendTo(event.Sender)
	end,

	send_bushes = function(event)
		local e = Network.Event("load_bushes", {bushes = JSON:Encode(server_bushes)})
		e:SendTo(event.Sender)
	end,

	send_round = function(event)
		local e = Network.Event("get_round", {time = game.time, time_end = game.time_end, mode = "default"})
		e:SendTo(event.Sender)
	end,

	kill = function(event)
		game.players[event.data.player].deaths = game.players[event.data.player].deaths + 1
		game.players[event.data.killer].kills = game.players[event.data.killer].kills + 1
	end,

	crash = function(event)
		if Debug.enabled ~= true then return end
		for i, username in ipairs(ADMINS) do
			if username == event.Sender.Username then
				error("crashed by admin")
			end
		end
	end,

	["_"] = function(event)
		Debug.log("server() - got unknown event: "..tostring(event.action))
	end

	})
end, function(err) CRASH("Server.DidReceiveEvent - "..err) end)

function createRocks()
	server_rocks = {}
	Debug.log("server() - creating rocks...")
	
	for i=1, 50 do
		server_rocks[i] = {}
		server_rocks[i].pos = {(math.random(1, 64))*5, 5, (math.random(1, 64))*5}
		server_rocks[i].rot = math.random(-314, 314)*0.01

		local c = math.random(-20, 20)
		server_rocks[i].col1 = {130+c, 140+c, 140+c}
		server_rocks[i].col2 = {140+c, 150+c, 160+c}
		server_rocks[i].id = i
	end

	Debug.log("server() - rocks created: " .. tostring(server_bushes))
end

function createBushes()
	server_bushes = {}
	Debug.log("server() - creating rocks...")
	
	for i=1, 50 do
		server_bushes[i] = {}
		server_bushes[i].pos = {(math.random(1, 64))*5, 5, (math.random(1, 64))*5}
		server_bushes[i].rot = math.random(-314, 314)*0.01

		local c = math.random(-20, 20)
		server_bushes[i].id = i
	end

	Debug.log("server() - rocks created: " .. tostring(server_bushes))
end

resetGame()
createRocks()
createBushes()

function botsTick()
	
end

tick = Object()
tick.Tick = errorHandler(function(self, dt)
	if game.players_connected > 0 then
		botsTick()
	end

	game.ticks = game.ticks + dt
	if game.ticks > 1 then
		game.ticks = 0
		game.time = game.time + 1
	end
	if game.time > game.time_end then
		resetGame()
	end
end, function(err) CRASH("Server.tick.Tick - "..err) end)

Debug.log("server() - created tick object with Tick function.")