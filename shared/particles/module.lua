local particles = {}

particles.init = function(self, env)
    self.env = env
end

particles.createEmitter = function(config)
    local defaultConfig = {
        position = Number3(0, 0, 0),
        rotation = Rotation(0, 0, 0),
        scale = Number3(1, 1, 1),
        color = Color(255, 255, 255),
        life = 1.0,
        velocity = Number3(0, 0, 0),
        scale_end = Number3(0, 0, 0),
    }
    
    local merged = {}
    for key, value in pairs(defaultConfig, config) do
        if config[key] ~= nil then
            merged[key] = config[key]
        else
            merged[key] = value
        end
    end

    local emitter = Object()
    emitter.pool = {}
    emitter.config = merged

    emitter.updateConfig = function(self, config)
        if self ~= emitter then
            error("emitter:updateConfig(config) should be called with ':'!")
        end
        local merged = {}
        for key, value in pairs(self.config, config) do
            if config[key] ~= nil then
                merged[key] = config[key]
            else
                merged[key] = value
            end
        end
        self.config = merged
    end

    emitter.emit = function(self)
        if self ~= emitter then
            error("emitter:emit() should be called with ':'!")
        end

        local particle = table.remove(self.pool)
        if not particle then
            particle = MutableShape()
            particle.Pivot = Number3(0.5, 0.5, 0.5)
            particle.Physics = PhysicsMode.Dynamic
            particle.CollidesWithGroups = CollisionGroups()
            particle.CollisionGroups = CollisionGroups()
            local b = Block(self.config.color, Number3(0, 0, 0))
            particle:AddBlock(b)
        else
            local b = particle:GetBlock(Number3(0, 0, 0))
            b.Color = self.config.color
        end
        
        particle.Position = self.config.position
        particle.Rotation = self.config.rotation
        particle.Scale = self.config.scale
        particle.Velocity = self.config.velocity
        particle:SetParent(World)
        particle.life = 0

        particle.Tick = function(p, dt)
            p.Scale = particles.lerp(p.Scale, self.config.scale_end, dt/self.config.life)
            p.life = p.life + dt
            if p.life > self.config.life then
                p.Tick = nil
                p:SetParent(nil)
                table.insert(self.pool, p)
            end
        end
    end

    emitter.remove = function(self)
        if self ~= emitter then
            error("emitter:remove() should be called with ':'!")
        end

        self:SetParent(nil)
        self = nil
    end

    return emitter
end

particles.lerp = function(a, b, w)
    return a + (b-a)*w
end

return particles