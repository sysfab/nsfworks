local l = {}

l.env = nil
l.init = function(self, env)
    self.env = env
end


l.loadGame = function(self, game)
    return self:loadFunction("games/" .. game .. "/main.lua", function(main)
        rawset(self.env, "Main", main)
        self.env.Main()
    end)
end


l.loadData = function(self, file, callback)
    if self.env == nil then
        error("loader:loadData() should be called with ':'!", 2)
    end
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
    if self.env == nil then
        error("loader:loadText() should be called with ':'!", 2)
    end
    return self:loadData(file, function(data) callback(data:ToString()) end)
end

l.loadFunction = function(self, file, callback)
    if self.env == nil then
        error("loader:loadFunction() should be called with ':'!", 2)
    end
    return self:loadText(file, function(data) callback(load(data, nil, "bt", self.env)) end)
end


return l
