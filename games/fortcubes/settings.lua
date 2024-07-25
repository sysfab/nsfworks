local settings = {}
local default_settings = {
    musicVolume = 70,
    soundVolume = 70,
}

settings.currentSettings = default_settings

function settings.set(self, setting, value)
    if value == nil then
        error("settings:set(setting, value) - 2nd parameter is nil.", 2)
    end
    if setting == nil then
        error("settings:set(setting, value) - 1st parameter is nil.", 2)
    end
    if self.currentSettings[setting] == nil then
        error("settings:set(setting, value) - setting parameter can't be set.", 2)
    end
    self.currentSettings[setting] = value
end

function settings.save(self)
    local store = KeyValueStore("data: " .. Player.Username)
    store:Set("settings", JSON:Encode(self.currentSettings), function(success)
        if success then
            debug.log("settings() - saved.")
        else
            debug.log("settings() - save failed.")
        end
    end)
end

function settings.load(self)
    local store = KeyValueStore("data: " .. Player.Username)
    store:Get("settings", function(success, result)
        if success then
            if result.settings == nil then
                self.currentSettings = default_settings
                debug.log("settings() - saved default settings.")
                self:save()
                return
            end
            self.currentSettings = JSON:Decode(result.settings)
            debug.log("settings() - loaded.")
        else
            debug.log("settings() - load failed.")
        end
    end)
end

return settings