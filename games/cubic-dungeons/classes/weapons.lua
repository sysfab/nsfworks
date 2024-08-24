local weapons = {}

weapons.new = function(self, config)
    if type(config) ~= "table" then error("weapons:new(config) - config must be a table", 2) end
    
    local w = {}

    w.Parts = config.parts or {}

    return w
end

rawset(_ENV, "weapon", function(...) weapons:new(...) end)

return weapons