-- Loader
-- NSFWorks loader module (base of all games)

local l = {}

l.env = nil
l.repo = "sysfab/nsfworks/main"

l.init = function(self, env)
    self.env = env
end


-- DO NOT USE THIS FUNCTION, USE LoadData
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
-- ADVANCED FUNCTIONS 
--
l.Loader = function(self, file, type, callback, error_callback)
    local lr = {}
    lr.file = file
    lr.type = type
    lr.callback = callback
    lr.error_callback = error_callback

    lr.Start = function(s)
        if s.type == "Data" then
            s.request = l.LoadData(s.file, s.callback, s.error_callback)
            return s.request
        elseif s.type == "Text" then
            s.request = l.LoadText(s.file, s.callback, s.error_callback)
            return s.request
        elseif s.type == "JSON" then
            s.request = l.LoadJSON(s.file, s.callback, s.error_callback)
            return s.request
        elseif s.type == "Function" then
            s.request = l.LoadFunction(s.file, s.callback, s.error_callback)
            return s.request
        end
        return s
    end

    lr.Cancel = function(s)
        if s.request ~= nil then
            s.request:Cancel()
        end
        return s
    end
    return lr
end

l.BatchLoader = function(self, files)
    local bl = {}
    bl.files = files

    bl.result = {}
    bl.loaders = {}

    bl.Start = function(s, callback, error_callback)
        s.result = {}
        s.error_callback = function(...)
            for i, request in pairs(s.loaders) do
                request:Cancel()
            end
            s.loaders = {}
            error_callback(...)
        end

        s.loaded = 0
        s.need_to_load = 0
        for key, setting in pairs(s.files) do
            s.need_to_load = s.need_to_load + 1
            local loader = l.Loader(setting[2], setting[1], 
            function(result)
                s.results[setting[2]] = result
                s.loaded = s.loaded + 1
                if s.loaded >= s.need_to_load then
                    s.loaders = {}
                    callback(s.results)
                end
            end, s.error_callback)
            table.insert(s.loaders, loader)
        end
        for i, loader in ipairs(s.loaders) do
            loader:Start()
        end
        return bl
    end
    bl.Cancel = function(s)
        for i, request in pairs(s.loaders) do
            request:Cancel()
        end
        s.result = {}
        s.loaders = {}
        return bl
    end
    return bl
end

--
-- BASIC FUNCTIONS
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
