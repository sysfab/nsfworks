debug.log("main() - started")

function set(key, value)
	rawset(_ENV, key, value)
end


-- CONFIG
set("VERSION", "v0.0")

debug.log("main() - config loaded")


load = {
	loading_screen = "games/fortcubes/loading_screen.lua",
	menu = "games/fortcubes/menu.lua",
	game = "games/fortcubes/game.lua"
}

for key, value in pairs(load) do
	if need_to_load == nil then need_to_load = 0 end
	need_to_load = need_to_load + 1

	loader:loadModule(value, function(module)
		debug.log("main() - Loaded '".. key .."'")

		_ENV[key] = module

		if loaded == nil then loaded = 0 end
		loaded = loaded + 1

		if loaded >= need_to_load then
			doneLoading()
		end
	end)
end
debug.log("main() - Loading " .. need_to_load .. " modules..")

-- Done loding 'Main' function of main function
function doneLoading()
	debug.log("main() - Loaded all modules")
	menu:create()
	Camera:SetParent(World)
end