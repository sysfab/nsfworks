local game = {}

game.create = function(self)
    --Camera:SetModeFree()
    Camera:SetParent(World)
    Player:SetParent(World)
    Player.Velocity = Number3(0, 0, 0)

    self.map = Shape(shapes.map, {includeChildren = true})
    self.map.Scale = 6
    local ha = require("hierarchyactions")
    ha:applyToDescendants(self.map, {includeRoot = true}, function(s)
        s.Physics = PhysicsMode.StaticPerBlock
    end)
    self.map:SetParent(World)
    self.map.Position = Number3(0, 0, 0)

    Player.Position = Number3(self.map.Width/2, self.map.Height*0.9, self.map.Depth*0.4)

    dpadX = 0
    dpadY = 0
    apadX = 0
    apadY = 0

    Pointer.Drag = function(pe)
        apadX = pe.DX
        apadY = pe.DY

        Player.Head.Rotation.Y = Player.Head.Rotation.Y + pe.DX * 0.01
        Player.LocalRotation.Y = Player.Head.Rotation.Y
    
        if Player.Head.Rotation.X < 3 then
            Player.Head.Rotation.X = math.min(Player.Head.Rotation.X + -pe.DY * 0.01, (3.14 / 2) * 0.9)
        else
            Player.Head.Rotation.X = math.max(Player.Head.Rotation.X + -pe.DY * 0.01, 4.72 * 1.02)
        end
    end

    Client.DirectionalPad = function(dx, dy)
        dpadX = dx
        dpadY = dy
    end

    Player.Tick = function(s, dt)
        Player.Motion = (Player.Forward * 40 * dpadY) + (Player.Right * 40 * dpadX)
    end
end

game.remove = function(self)
    self.map:SetParent(nil)
    self.map = nil
    Pointer.Drag = nil
    Player.Tick = nil
end

return game