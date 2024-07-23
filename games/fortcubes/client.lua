debug.enabled = true
debug.log("client() - started")

Camera:SetParent(nil)
ui = uikit_loader()

function set(key, value)
	rawset(_ENV, key, value)
end


-- CONFIG
set("VERSION", "v0.0")

debug.log("client() - config loaded")


Client.DirectionalPad = function() end
Client.AnalogPad = function() end


load = {
	loading_screen = "games/fortcubes/loading_screen.lua",
	menu = "games/fortcubes/menu.lua",
	game = "games/fortcubes/game.lua"
}

for key, value in pairs(load) do
	if need_to_load == nil then need_to_load = 0 end
	need_to_load = need_to_load + 1

	loader:loadFunction(value, function(module)
		debug.log("client() - Loaded '".. key .."'")

		_ENV[key] = module()

		if loaded == nil then loaded = 0 end
		loaded = loaded + 1

		if loaded >= need_to_load then
			doneLoading()
		end
	end)
end
debug.log("client() - Loading " .. need_to_load .. " modules..")

function doneLoading()
	debug.log("client() - Loaded all modules")
	menu:create()
	Camera:SetParent(World)
end