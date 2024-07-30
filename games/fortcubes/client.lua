debug.enabled = false
debug.log("client() - Loaded from: '"..repo.."' repo. Commit: '"..githash.."'. Modules commit: '"..hash.."'")
debug.log("client() - Starting '"..game.."'...")

randomEasterLogs = {
	"Once upon a time...",
	"NOT SAFE TO PLAY",
	"It starts with...",
	"Who coded this??",
	"Hello world!",
	"Good luck debugging this",
	"Who also hates bugs?",
	"SYSTEMS: ONLINE | STATUS: WORKING (or not)",
	"im totally not just adding garbage logs into this",
	":3",
	"pew pew",
	"Do not touch anything",
	"please, forgive me",
	"Hello    anyone??",
	"Im watching you <0>",
	"TOP SECRET",
	"If it breaks, im not guilty"
}

Player.Position = Number3(-1000, -1000, -1000)

Camera:SetParent(nil)
Fog.On = false
Clouds.On = false

debug.log("client() - loading cubzh modules...")
multi = require("multi")
ui = uikit_loader()
toast = require("ui_toast")
debug.log("client() - loaded cubzh modules")


function copyClientLogs()
	debug.log("client() - copying client logs")

	Dev:CopyToClipboard(debug:export())
	toast:create({message = "Logs are copied to clipboard."})

	debug.log("client() - client logs are copied")
end
function copyServerLogs()
	debug.log("client() - copying server logs")
	
	local e = crystal.Event("get_logs", {})
	e:SendTo(Server)

	if serverLogListener ~= nil then
		serverLogListener:Remove()
		serverLogListener = nil
	end
	serverLogListener = LocalEvent:Listen(LocalEvent.Name.DidReceiveEvent, function(e)
		Dev:CopyToClipboard(e.data)
		toast:create({message = "Server logs are copied to clipboard."})
		serverLogListener:Remove()
		serverLogListener = nil

		debug.log("client() - server logs are copied")
	end)
end
function copyLogs()
	debug.log("client() - copying client and server logs")
	
	copyLogsLogs = {}
	copyLogsLogs.client = JSON:Decode(debug:export())

	local e = crystal.Event("get_logs", {})
	e:SendTo(Server)

	if serverLogListener ~= nil then
		serverLogListener:Remove()
		serverLogListener = nil
	end
	serverLogListener = LocalEvent:Listen(LocalEvent.Name.DidReceiveEvent, function(e)
		copyLogsLogs.server = JSON:Decode(e.data)
		serverLogListener:Remove()
		serverLogListener = nil

		toast:create({message = "Logs are copied."})

		Dev:CopyToClipboard(JSON:Encode(copyLogsLogs))
		debug.log("client() - clint and server logs are copied")
	end)
end

function set(key, value)
	rawset(_ENV, key, value)
end


-- CONFIG
set("VERSION", "v1.0")
set("ADMINS", {"nsfworks", "fab3kleuuu", "nanskip"})

debug.log("client() - version: "..VERSION)


Client.DirectionalPad = nil
Client.AnalogPad = nil
Client.OnPlayerJoin = function(p)
	if p == Player and not playerJoined then
		playerJoined = true
		checkLoading()
	end
end
Pointer.Drag = nil


loadingBG = ui:createFrame(Color(0, 0, 0, 255))
loadingBG.parentDidResize = function(_)
	loadingBG.Width = Screen.Width
	loadingBG.Height = Screen.Height
end
loadingBG.parentDidResize()


loadModules = {
	loading_screen = "games/fortcubes/loading_screen.lua",
	menu = "games/fortcubes/menu.lua",
	game = "games/fortcubes/game.lua",
	settings = "games/fortcubes/settings.lua",
}

animations = {}
loadAnimations = {
	nanskip = "games/fortcubes/assets/animations/menu/nanskip.json",
	sysfab = "games/fortcubes/assets/animations/menu/sysfab.json",
	katana_idle = "games/fortcubes/assets/animations/menu/katana_idle.json",
	pistol_idle = "games/fortcubes/assets/animations/menu/pistol_idle.json",
	player_walk = "games/fortcubes/assets/animations/game/walk.json",
}

shapes = {}
loadShapes = {
	bush = "nanskip.bush_1_alternate",
	yard = "nsfworks.fortcubes_yard",
	book = "nsfworks.fortcubes_settings",
	tree = "nanskip.tree_2",
	toolgun = "nanskip.toolgun",
	lua_block = "fab3kleuuu.lua_block",
	bullet = "nanskip.ca_bullet",
	rock = "nsfworks.fortcubes_rock"
}

audio = {}
loadAudios = {
	game_theme = "games/fortcubes/assets/gameTheme.mp3",
	menu_theme = "games/fortcubes/assets/menuTheme.mp3",
	bush = "games/fortcubes/assets/bush.mp3"
}

loaded = 0
need_to_load = 0

for key, value in pairs(loadModules) do
	if need_to_load_modules == nil then need_to_load_modules = 0 end
	need_to_load_modules = need_to_load_modules + 1
	need_to_load = need_to_load + 1

	loader:loadFunction(value, function(module)
		debug.log("client() - Loaded '".. value .."'")

		_ENV[key] = module()

		if loaded_modules == nil then loaded_modules = 0 end
		loaded_modules = loaded_modules + 1
		loaded = loaded + 1

		if loaded_modules >= need_to_load_modules then
			if loaded == need_to_load then
                checkLoading()
            end
			debug.log("client() - Loaded all modules.")
			if loading_screen.created then
				loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
			elseif loading_screen ~= nil then
				loading_screen:create()
				
				loadingBG:remove()
				loadingBG = nil
			end
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
debug.log("client() - Loading " .. need_to_load_modules.. " modules..")

for key, value in pairs(loadAnimations) do
	if need_to_load_animations == nil then need_to_load_animations = 0 end
	need_to_load_animations = need_to_load_animations + 1
	need_to_load = need_to_load + 1

	loader:loadText(value, function(text)
		debug.log("client() - Loaded '".. value .."'")

		animations[key] = text

		if loaded_animations == nil then loaded_animations = 0 end
		loaded_animations = loaded_animations + 1
		loaded = loaded + 1

		if loaded_animations >= need_to_load_animations then
			debug.log("client() - Loaded all animations.")
			if loading_screen.created then
				loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
			elseif loading_screen ~= nil then
				loading_screen:create()
				
				loadingBG:remove()
				loadingBG = nil
			end
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
debug.log("client() - Loading " .. need_to_load_animations .. " animations..")

for key, value in pairs(loadShapes) do
	if need_to_load_shapes == nil then need_to_load_shapes = 0 end
	need_to_load_shapes = need_to_load_shapes + 1
	need_to_load = need_to_load + 1

	Object:Load(value, function(shape)
		debug.log("client() - Loaded '".. value .."'")

		shapes[key] = shape

		if loaded_shapes == nil then loaded_shapes = 0 end
		loaded_shapes = loaded_shapes + 1
		loaded = loaded + 1

		if loaded_shapes >= need_to_load_shapes then
			debug.log("client() - Loaded all shapes.")
			if loading_screen.created then
				loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
			elseif loading_screen ~= nil then
				loading_screen:create()
				
				loadingBG:remove()
				loadingBG = nil
			end
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
debug.log("client() - Loading " .. need_to_load_shapes .. " shapes..")

for key, value in pairs(loadAudios) do
	if need_to_load_audios == nil then need_to_load_audios = 0 end
	need_to_load_audios = need_to_load_audios + 1
	need_to_load = need_to_load + 1

	loader:loadData(value, function(audioData)
		debug.log("client() - Loaded '".. value .."'")

		audio[key] = audioData

		if loaded_audios == nil then loaded_audios = 0 end
		loaded_audios = loaded_audios + 1
		loaded = loaded + 1

		if loaded_audios >= need_to_load_audios then
			debug.log("client() - Loaded all audios.")
			if loading_screen.created then
				loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
			elseif loading_screen ~= nil then
				loading_screen:create()
				
				loadingBG:remove()
				loadingBG = nil
			end
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
debug.log("client() - Loading " .. need_to_load_audios .. " audios..")


debug.log("client() - Total: " .. need_to_load .. " assets")

function checkLoading()
	if playerJoined and loaded >= need_to_load then
		doneLoading()
	end
end

function doneLoading()
	Camera:SetParent(World)
	debug.log("")
	debug.log("GAME LOADED")
	debug.log("")

	debug.log("#"..randomEasterLogs[math.random(1, #randomEasterLogs)])

	if debug.enabled == true then
		toast:create({message = "Game launched with debug enabled."})
	end

	settings:load()
	menu:create()
end

LocalEvent:Listen(LocalEvent.Name.OnChat, function(payload)
    message = payload.message
    if message == "?logs" then
        copyClientLogs()
    end
end)