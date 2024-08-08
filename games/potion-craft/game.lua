local game = {}

game.create = function(self)
    --Camera:SetModeFree()
    Camera:SetParent(World)
    Player:SetParent(World)

    self.map = Shape(shapes.map, {includeChildren = true})
    self.map.Scale = 6
    local ha = require("hierarchyactions")
    ha:applyToDescendants(self.map, {includeRoot = true}, function(s)
        s.Physics = PhysicsMode.StaticPerBlock
    end)
    self.map:SetParent(World)
    self.map.Position = Number3(0, 0, 0)

    dpadX = 0
    dpadY = 0
    apadX = 0
    apadY = 0

    baseMovementSpeed = 80
    baseJumpHeight = 100
    baseJumpMidAir = false
    baseRotationSensivity = 1
    baseScale = 0.5
    baseBounciness = 0

    resetPlayer = function()
        Player.Position = Number3(95, -170, -160)
        Player.Velocity = Number3(0, 0, 0)
        Player.movementSpeed = baseMovementSpeed
        Player.jumpHeight = baseJumpHeight
        Player.jumpMidAir = baseJumpMidAir
        Player.rotationSensivity = baseRotationSensivity
        Player.Scale = baseScale
        Player.Bounciness = baseBounciness
    end
    resetPlayer()

    Pointer.Drag = function(pe)
        apadX = pe.DX
        apadY = pe.DY

        Player.Head.Rotation.Y = Player.Head.Rotation.Y + pe.DX * 0.01 * Player.rotationSensivity
        Player.LocalRotation.Y = Player.Head.Rotation.Y
    
        if Player.Head.Rotation.X < 3 then
            Player.Head.Rotation.X = math.min(Player.Head.Rotation.X + -pe.DY * 0.01 * Player.rotationSensivity, (3.14 / 2) * 0.9)
        else
            Player.Head.Rotation.X = math.max(Player.Head.Rotation.X + -pe.DY * 0.01 * Player.rotationSensivity, 4.72 * 1.02)
        end
    end

    Client.DirectionalPad = function(dx, dy)
        dpadX = dx
        dpadY = dy
    end

    Client.Action1 = function()
        if (Player.jumpMidAir == true) or (Player.IsOnGround == true) then
            Player.Velocity.Y = Player.jumpHeight
        end
    end

    Player.Tick = function(s, dt)
        Player.Motion = (Player.Forward * Player.movementSpeed * dpadY) + (Player.Right * Player.movementSpeed * dpadX)
    end
end

game.remove = function(self)
    self.map:SetParent(nil)
    self.map = nil
    Pointer.Drag = nil
    Player.Tick = nil
end

return game