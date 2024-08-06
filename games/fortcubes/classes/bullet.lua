bullet = {}

bullet.create = function(data)
    local b = Shape(shapes.bullet, {includeChildren = true})
    b.owner = getPlayerByUsername(data.player)

    b:SetParent(World)
    b.Rotation = Rotation(0, data.rot, 0)
    b.Scale = Number3(0.5, 0.5, 1)

    if b.owner == Player then
        b.Position = lerp(Number3(data.x, data.y, data.z), Player.Head.Position, 0.5)
    else
        b.Position = Number3(data.x, data.y, data.z)
    end

    b.Physics = PhysicsMode.Trigger
    b:GetChild(1).Physics = PhysicsMode.Trigger
    b.as = AudioSource("gun_shot_1")
    b.as:SetParent(b.owner)
    b.as.Volume = settings.currentSettings.soundVolume*0.01
    if distance(b.Position, Player.Position) < 120 then
        b.as:Play()
    end
    b.damage = 20

    b.OnCollisionBegin = function(self, other)
        if other.type == "bush" then
            other:move()
        end
    end
    
    b.lifeTime = 0.5
    b.Tick = errorHandler(function(self, dt)
        local dt_factor = dt*63
        self.Position = self.Position + self.Forward * 4 * dt_factor

        self.lifeTime = self.lifeTime - dt
        if self.lifeTime <= 0 then
            for i=1, 10 do
                self.particle:updateConfig({
                    position = self.Position,
                    velocity = Number3(math.random(-10, 10), math.random(-10, 20), math.random(-10, 10)) + self.Forward * dt_factor*50,
                })
                self.particle:emit()
            end
            self:remove()
        end
    end, function(err) CRASH("b.Tick - "..err) end)
    b.remove = function(self)
        self.particle:remove()
        self.OnCollisionBegin = nil
        --self.as:SetParent(nil)
        --self.as = nil
        self:SetParent(nil)
        self.Tick = nil
    end
end

return bullet