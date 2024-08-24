local weapons = {}

weapons.new = function(self, config)
    if type(config) ~= "table" then error("weapons:new(config) - config must be a table", 2) end
    
    local w = {}

    w.Type = config.type
    w.Parts = config.parts or {}


    w.calculateStats = function(s)
        s.Stats = {}

        for _, part in ipairs(s.Parts) do
            local effects = part.StatsEffects

            for _, effect in ipairs(effects) do
                local action = effect[1]

                if action == "set" then
                    s.Stats[effect[2]] = effect[3]
                elseif action == "add" then
                    s.Stats[effect[2]] = s.Stats[effect[2]] + effect[3]
                elseif action == "sub" then
                    s.Stats[effect[2]] = s.Stats[effect[2]] - effect[3]
                elseif action == "mul" then
                    s.Stats[effect[2]] = s.Stats[effect[2]] * effect[3]
                elseif action == "div" then
                    s.Stats[effect[2]] = s.Stats[effect[2]] / effect[3]
                elseif action == "func" then
                    effect[2](s.Stats)
                end
            end
        end
    end

    w:calculateStats()

    setmetatable(w, {type="weapon"})
    return w
end

rawset(_ENV, "weapon", function(...) return weapons:new(...) end)

return weapons