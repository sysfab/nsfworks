debug.log("Main() - started")

load = {
	loading_screen = "games/fortcubes/loading_screen.lua",
	menu = "games/fortcubes/menu.lua"
}
need_to_load = 0
loaded = 0

for key, value in pairs(load) do
	loader:loadModule(value, function(module)
		_ENV[key] = module
		loaded = loaded + 1
		if loaded >= need_to_load then
			doneLoading()
		end
	end)
	need_to_load = need_to_load + 1
end

-- Done loding 'Main' function of main function
function doneLoading()
	menu:create()
end