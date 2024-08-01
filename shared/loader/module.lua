-- Loader
-- NSFWorks loader module (base of all games)

local l = {}

l.env = nil
l.repo = "sysfab/nsfworks/main"

l.init = function(self, env)
    self.env = env
end


-- DO NOT USE THIS FUNCTION, USE loadData
l.load = function(self, file, callback, error_callback)
    if self.env == nil then
        error("loader:loadData() should be called with ':'!", 2)
    end
    local url = "https://raw.githubusercontent.com/" .. self.repo .. "/" .. file

    local request = HTTP:Get(url, function(response)
        if response.StatusCode ~= 200 then
            if error_callback ~= nil then
                error_callback(response.Body, response.StatusCode)
            else
                error("Error when loading '" .. url .. "'. Code: " .. response.StatusCode, 3)
            end
        end

        callback(response.Body)
    end)

    return request
end

--
-- STANDARD FUNCTIONS
--
l.LoadData = function(self, file, callback, error_callback)
    if self.env == nil then
        error("loader:loadData() should be called with ':'!", 2)
    end
    return self:load(file, function(data) callback(data) end, error_callback)
end

-- LEGACY
l.LoadText = function(self, file, callback, error_callback)
    if self.env == nil then
        error("loader:loadText() should be called with ':'!", 2)
    end
    return self:load(file, function(data) callback(data:ToString()) end, error_callback)
end

-- LEGACY
l.LoadJSON = function(self, file, callback, error_callback)
    if self.env == nil then
        error("loader:loadJSON() should be called with ':'!", 2)
    end
    return self:load(file, function(data) callback(JSON:Decode(data:ToString())) end, error_callback)
end

-- LEGACY
l.LoadFunction = function(self, file, callback, error_callback)
    if self.env == nil then
        error("loader:loadFunction() should be called with ':'!", 2)
    end
    return self:load(file, function(data) callback(load(data:ToString(), nil, "bt", self.env)) end, error_callback)
end

--
-- LEGACY FUNCTIONS:
--
-- LEGACY
l.loadData = l.LoadData

-- LEGACY
l.loadText = l.LoadText

-- LEGACY
l.loadJSON = l.LoadJSON

-- LEGACY
l.loadFunction = l.LoadFunction


return l
