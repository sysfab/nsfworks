local l = {}

l.load = function(game, env)
    local url = "https://raw.githubusercontent.com/sysfab/nsfworks/main/games/" .. game .. "/main.lua"

    local request = HTTP:Get(url, function(response)
        if response.StatusCode ~= 200 then
            error("Error when loading '" .. url .. "'. Code: " .. response.StatusCode, 2)
        end

        local main = load(response.Body:ToString(), nil, "bt", env)
        rawset(env, "Main", main)
    end)

    return request
end

return l
