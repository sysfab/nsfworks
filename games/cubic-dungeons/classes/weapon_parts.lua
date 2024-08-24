local weapon_parts = {}

weapon_parts.new = function(self, config)
    if type(config) ~= "table" then error("weapon_parts:new(config) - config must be a table", 2) end
    
    local w = {}

    w.Type = config.type
    w.Description = config.description
    w.StatsEffects = config.stat_effects or {}
    w.TextureName = config.texture_name

    w.Texture = images[w.TextureName]
    if w.Texture == nil then
        --error("weapon_parts:new(config) - config.texture_name, texture '"..tostring(w.TextureName).."' not found in images table", 2)
    end

    setmetatable(w, {type="weapon_part"})
    return w
end

rawset(_ENV, "weapon_part", function(...) return weapon_parts:new(...) end)

return weapon_parts