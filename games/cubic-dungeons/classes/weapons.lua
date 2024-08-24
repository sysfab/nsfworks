local weapons = {}

weapons.new = function(self, config)
    if type(config) ~= "table" then error("weapons:new(config) - config must be a table", 2) end
    
    local w = {}

    w.Type = config.type
    w.Name = config.name
    w.Description = config.description
    w.Rarity = config.rarity
    w.Parts = config.parts or {}


    w.calculateStats = function(s)
        s.Stats = {}

        for _, part in ipairs(s.Parts) do
            local effects = part.StatsEffects

            for _, effect in ipairs(effects) do
                effect(s.Stats)
            end
        end
    end

    w:calculateStats()

    setmetatable(w, {type="weapon"})
    return w
end

rawset(_ENV, "weapon", function(...) return weapons:new(...) end)

return weapons