local game = {}

game.create = function(self)
    Camera:SetModeFree()
    Camera:SetParent(World)
    Player:SetParent(World)

    self.map = MutableShape(shapes.map, {include_children = true})
    self.map.Scale = 5
    self.map.Physics = PhysicsMode.StaticPerBlock
    self.map:SetParent(World)

    Player.Position = self.map.Position + Number3(self.map.Width/2, self.map.Height, self.map.Depth/2)*self.map.Size
end

game.remove = function(self)
    self.map:SetParent(nil)
    self.map = nil
end

return game