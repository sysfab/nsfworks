local game = {}

game.connection = {}
game.connection.connected = false

game.connection.connect = function(connection)
	if connection.connected == false then
		debug.log("game() - connecting...")
		local e = crystal.Event("connect", {})
		e:SendTo(Server)
	else
		debug.error("game() - trying to connect when already connected", 2)
	end
end
game.connection.disconnect = function(connection)
	debug.log("game() - disconnecting...")
	local e = crystal.Event("disconnect", {})
	e:SendTo(Server)
	connection.connected = false
end
game.connection.onEvent = function(connection, e)
	crystal.ParseEvent(e, {

		connected = function(event)
			debug.log("game() - connected")
			game.connection.connected = true
		end

	})
end

game.mobileControls = {}
game.mobileControls.created = false
game.mobileControls.screenResize = function(controls)
	if controls.moveJoystick.loaded == true then
		controls.moveJoystick:setPos(Number2(10, 10))
	end
	if controls.shootJoystick.loaded == true then
		controls.shootJoystick:setPos(Number2(Screen.Width-10-176, 10))
	end
end
game.mobileControls.create = function(controls)
	controls.moveJoystick = joysticks.create({
		pos = {10, 10}, -- position on screen.
		scale = 1.1, -- scale multiplier, 1 = 160 pixels.
		color = Color(100, 100, 255, 127), -- color of joystick's insides.
		borderColor = Color(100, 100, 255, 255) -- color of joystick's border.
	})
	controls.shootJoystick = joysticks.create({
		pos = {Screen.Width-10-176, 10}, -- position on screen.
		scale = 1.1, -- scale multiplier, 1 = 160 pixels.
		color = Color(255, 100, 100, 127), -- color of joystick's insides.
		borderColor = Color(255, 100, 100, 255) -- color of joystick's border.
	})
end
game.mobileControls.remove = function(controls)
	controls.moveJoystick:remove()
	controls.shootJoystick:remove()
	controls.moveJoystick = nil
	controls.shootJoystick = nil
end

game.world = {}
game.world.create = function(world, scale)
	world.map = MutableShape()
	for x = 1, scale do
		for y = 1, scale do
			local a = perlin.get(x*0.1, y*0.1)*30
			local b = perlin.get(x+18532*0.2, y+13532*0.2)*20
			local plus = (a + b) / 2
			local block = Block(Color(math.floor(77-plus), math.floor(140-plus), math.floor(77-plus), 255), Number3(x, 0, y))

			world.map:AddBlock(block)
		end
	end
	world.map:SetParent(World)
end
game.world.remove = function(world)
	world.map:SetParent(nil)
	world.map = nil
end

game.created = false
game.screenResize = function(self)
	if self.created ~= true then return end

	if self.mobileControls ~= nil then
		self.mobileControls:screenResize()
	end
end
game.create = function(self)
	self.created = true
	self:screenResize()

	self.screenResizeListener = LocalEvent:Listen(LocalEvent.Name.ScreenDidResize, function(...)
        self:screenResize(...)
    end)
    self.eventListener = LocalEvent:Listen(LocalEvent.Name.DidReceiveEvent, function(...)
        self.connection:onEvent(...)
    end)

    self.connection:connect()
	self.world:create(100)
end
game.remove = function(self)
	self.screenResizeListener:Remove()
	self.eventListener:Remove()
	if self.mobileControls.created then
		self.mobileControls:remove()
	end
	self.connection:disconnect()
	self.world:remove()
	self.created = false
end


return game