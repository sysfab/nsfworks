local l = {}

l.env = nil
l.loadGame = function(self, game, env)
    self.env = env
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

l.loadData = function(self, file, callback)
    local url = "https://raw.githubusercontent.com/sysfab/nsfworks/main/" .. file

    local request = HTTP:Get(url, function(response)
        if response.StatusCode ~= 200 then
            error("Error when loading '" .. url .. "'. Code: " .. response.StatusCode, 2)
        end

        callback(response.Body)
    end)

    return request
end

l.loadText = function(self, file, callback)
    self:loadData(file, function(data) callback(data:ToString()) end)
end

l.loadFunction = function(self, file, callback)
    self:loadText(file, function(data) callback(load(data, nil, "bt", self.env)) end)
end

return l
