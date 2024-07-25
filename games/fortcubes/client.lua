debug.enabled = true
debug.log("client() - started")

Player.Position = Number3(-1000, -1000, -1000)
multi = require("multi")

Camera:SetParent(nil)
Fog.On = false
Clouds.On = false
ui = uikit_loader()

function set(key, value)
	rawset(_ENV, key, value)
end


-- CONFIG
set("VERSION", "v0.0")

debug.log("client() - config loaded")


Client.DirectionalPad = nil
Client.AnalogPad = nil
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
	game = "games/fortcubes/game.lua"
}

animations = {}
loadAnimations = {
	nanskip = "games/fortcubes/assets/animations/menu/nanskip.json",
	sysfab = "games/fortcubes/assets/animations/menu/sysfab.json",
	katana_idle = "games/fortcubes/assets/animations/menu/katana_idle.json",
	pistol_idle = "games/fortcubes/assets/animations/menu/pistol_idle.json",
	player_walk = "games/fortcubes/assets/animations/game/walk.json",
}

loaded = 0
need_to_load = 2

for key, value in pairs(loadModules) do
	if need_to_load_modules == nil then need_to_load_modules = 0 end
	need_to_load_modules = need_to_load_modules + 1

	loader:loadFunction(value, function(module)
		debug.log("client() - Loaded '".. key .."'")

		_ENV[key] = module()

		if loaded_modules == nil then loaded_modules = 0 end
		loaded_modules = loaded_modules + 1

		if loaded_modules >= need_to_load_modules then
			loaded = loaded + 1
			if loaded == need_to_load then
                doneLoading()
				debug.log("client() - Loaded all modules.")
            end
		end
	end)
end
debug.log("client() - Loading " .. need_to_load_modules.. " modules..")

for key, value in pairs(loadAnimations) do
	if need_to_load_animations == nil then need_to_load_animations = 0 end
	need_to_load_animations = need_to_load_animations + 1

	loader:loadText(value, function(text)
		debug.log("client() - Loaded '".. key .."'")

		animations[key] = text

		if loaded_animations == nil then loaded_animations = 0 end
		loaded_animations = loaded_animations + 1

		if loaded_animations >= need_to_load_animations then
			loaded = loaded + 1
			if loaded == need_to_load then
                doneLoading()
				debug.log("client() - Loaded all animations.")
            end
		end
	end)
end
debug.log("client() - Loading " .. need_to_load_animations .. " animations..")

function doneLoading()
	debug.log("client() - Loaded all assets.")

	loadingBG:remove()
	loadingBG = nil
	loading_screen:create()

	menu:create()
	Camera:SetParent(World)
end