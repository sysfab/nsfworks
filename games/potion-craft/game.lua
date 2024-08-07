local game = {}

game.create = function(self)
    --Camera:SetModeFree()
    Camera:SetParent(World)
    Player:SetParent(World)
    Player.Velocity = Number3(0, 0, 0)

    self.map = Shape(shapes.map, {includeChildren = true})
    self.map.Scale = 25
    self.map.Physics = PhysicsMode.StaticPerBlock
    self.map:SetParent(World)
    self.map.Position = Number3(0, 0, 0)

    Player.Position = Number3(self.map.Width/2, self.map.Height, self.map.Depth*0.35)
end

game.remove = function(self)
    self.map:SetParent(nil)
    self.map = nil
end

return game