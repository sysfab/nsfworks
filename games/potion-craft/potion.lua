local potion = {}

potion.create = function(self, config)
    Debug.log("potion() - creating potion with config - "..tostring(config))

    local p = {}
    if config == nil then config = {} end

    p.effects = config.effects or {}
    p.drink = function(s, player)
        for i, effect in ipairs(s.effects) do
            effect(player)
        end
    end

    return p
end

setmetatable(potion, {__call = function(self, ...) self:create(...)  end})

return potion