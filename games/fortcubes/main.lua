debug.log("Main() - started")

load = {
	loading_screen = "games/fortcubes/loading_screen.lua",
	menu = "games/fortcubes/menu.lua"
}
need_to_load = 0
loaded = 0

for key, value in pairs(load) do
	need_to_load = need_to_load + 1

	loader:loadModule(value, function(module)
		debug.log("Main() - Loaded '".. key .."'")
		_ENV[key] = module
		loaded = loaded + 1
		if loaded >= need_to_load then
			doneLoading()
		end
	end)
end
debug.log("Main() - Loading " .. need_to_load .. " modules..")

-- Done loding 'Main' function of main function
function doneLoading()
	debug.log("Main() - Loaded all modules")
	menu:create()
end