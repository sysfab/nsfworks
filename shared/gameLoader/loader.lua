local l = {}

l.load = function(game, env)
	local url = "https://raw.githubusercontent.com/sysfab/nsfworks/main/games/" .. game .. "/main.lua"

	local request = HTTP:Get(url, function(res)
        if res.StatusCode ~= 200 then
            error("Error when loading '" .. url .."'. Code: " .. res.StatusCode, 2)
            return
        end

        local main = load(res.Body:ToString(), nil, "bt", env)
        rawset(env, "Main", main)
   	end)

    return request
end

return l
