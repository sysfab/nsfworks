local rarity_tiers = {}

rarity_tiers.new = function(self, config)
    if type(config) ~= "table" then error("rarity_tiers:new(config) - config must be a table", 2) end
    
    local w = {}

    w.Name = config.name
    w.Color = config.color

    setmetatable(w, {type="rarity_tier"})
    return w
end

rawset(_ENV, "rarity", function(...) return rarity_tiers:new(...) end)

return rarity_tiers