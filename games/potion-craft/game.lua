local game = {}

game.create = function(self)
    --Camera:SetModeFree()
    Camera:SetParent(World)
    Player:SetParent(World)
    Player.Velocity = Number3(0, 0, 0)

    self.map = Shape(shapes.map, {includeChildren = true})
    self.map.Scale = 15
    self.map.Physics = PhysicsMode.StaticPerBlock
    self.map:SetParent(World)
    self.map.Position = Number3(0, 0, 0)

    Player.Position = Number3(self.map.Width/2, self.map.Height, self.map.Depth*0.35)

    Pointer.Drag = function(pe)
        Player.Head.Rotation.Y = Player.Head.Rotation.Y + pe.DX * 0.01
        Player.LocalRotation.Y = Player.Head.Rotation.Y
    
        if Player.Head.Rotation.X < 3 then
            Player.Head.Rotation.X = math.max(Player.Head.Rotation.X + -pe.DY * 0.01, (3.14 / 2) * 0.9)
        else
            Player.Head.Rotation.X = math.min(Player.Head.Rotation.X + -pe.DY * 0.01, 4.72 * 1.02)
        end
    end
end

game.remove = function(self)
    self.map:SetParent(nil)
    self.map = nil
    Pointer.Drag = nil
end

return game