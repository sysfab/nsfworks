local game = {}

function getPlayerByUsername(username)
	for k, v in pairs(Players) do
		if v.Username == username then
			return v
		end
	end
end

game.bullets = {}

game.connection = gameEvent
game.ui = gameUI

game.mobileControls = {}
game.mobileControls.created = false
function game.mobileControls.screenResize(controls)
	if controls.moveJoystick.loaded == true then
		controls.moveJoystick:setPos(Number2(10+48, 10+48))
	end
	if controls.shootJoystick.loaded == true then
		controls.shootJoystick:setPos(Number2(Screen.Width-10-176, 10+48))
	end
end
function game.mobileControls.create(controls)
	controls.moveJoystick = joysticks.create({
		pos = {10+48, 10+48}, -- position on screen.
		scale = 0.8, -- scale multiplier, 1 = 160 pixels.
		color = Color(100, 100, 255, 127), -- color of joystick's insides.
		borderColor = Color(100, 100, 255, 255) -- color of joystick's border.
	})
	controls.shootJoystick = joysticks.create({
		pos = {Screen.Width-10-176, 10+48}, -- position on screen.
		scale = 0.8, -- scale multiplier, 1 = 160 pixels.
		color = Color(255, 100, 100, 127), -- color of joystick's insides.
		borderColor = Color(255, 100, 100, 255) -- color of joystick's border.
	})

	controls.moveJoystick.onDrag = function()
		game.controls.directionalPad(controls.moveJoystick.x, controls.moveJoystick.y, true)
	end
	controls.moveJoystick.onRelease = function()
		game.controls.directionalPad(controls.moveJoystick.x, controls.moveJoystick.y, true)
	end
	controls.shootJoystick.onDrag = function()
		game.controls.analogPad(controls.shootJoystick.x, controls.shootJoystick.y, true)
		game.controls.shooting = true
	end
	controls.shootJoystick.onRelease = function()
		--game.controls.analogPad(controls.shootJoystick.x, controls.shootJoystick.y, true)
		game.controls.shooting = false
	end

	controls.created = true
end
function game.mobileControls.remove(controls)
	controls.moveJoystick:remove()
	controls.shootJoystick:remove()
	controls.moveJoystick = nil
	controls.shootJoystick = nil
	controls.created = false
end

game.camera = {}
game.camera.created = false
function game.camera.create(camera)
	Camera:SetModeFree()

	camera.object = Object()
	camera.object.Tick = function()
		Camera.Position = Player.Position + Number3(0, 200, -195)
		Camera.Forward = Player.Down
		Camera.Rotation.X = Camera.Rotation.X - math.pi/4
		Camera.FOV = 20
	end

	camera.created = true
end
function game.camera.remove(camera)
	camera.object.Tick = nil
	camera.object = nil
	camera.created = false
end

game.controls = {}
game.controls.shooting = false
function game.controls.create(controls)
	if Client.IsMobile == true then
		Client.DirectionalPad = nil
		Pointer.Drag = nil
		Pointer.Down = nil
		Pointer.Up = nil
	else
		Client.DirectionalPad = controls.directionalPad
		Pointer.Drag = function(pe)
			controls.analogPad(pe.X, pe.Y)
			game.controls.shooting = true
		end
		Pointer.Down = function(pe)
			controls.analogPad(pe.X, pe.Y)
			game.controls.shooting = true
		end
		Pointer.Up = function(pe)
			controls.analogPad(pe.X, pe.Y)
			game.controls.shooting = false
		end
	end
end
function game.controls.remove(controls)
	Client.DirectionalPad = nil
	Pointer.Drag = nil
	Pointer.Down = nil
	Pointer.Up = nil
end
function game.controls.analogPad(dx, dy, isJoy)
	if isJoy ~= true then
		local wh = Screen.Width/Screen.Height

		dx = (dx-0.5)*2
		dy = (dy-0.5)*2
	else
		local d = Number2(dx, dy)
		d:Normalize()
		dx = d.X
		dy = d.Y
	end
	local dxmul = 1
	if dy < 0 then
		dxmul = 1.2
	else
		dxmul = 1.3
	end
	Player.Forward = Number3(dx*dxmul, 0, dy)*25
end
function game.controls.directionalPad(dx, dy, isJoy)
	if isJoy == true then
		local d = Number2(dx, dy)
		d:Normalize()
		dx = d.X
		dy = d.Y
	end
	if Player.isDead then
		dx = 0
		dy = 0
	end
	Player.Motion = Number3(dx, 0, dy)*60
	game.controls.move = {dx, dy}
end

game.world = gameWorld

game.created = false
function game.screenResize(self)
	if self.created ~= true then return end

	self.ui:screenResize()
	if self.mobileControls ~= nil then
		self.mobileControls:screenResize()
	end
end

game.tick = errorHandler(function(self, dt)
	Player.Velocity.Y = Player.Velocity.Y + 0.01
	if game.controls.move[1] ~= nil and game.controls.move[2] ~= nil and not game.controls.shooting and not Player.isDead then
		Player.Forward = lerp(Player.Forward, Number3(game.controls.move[1]+math.random(-100, 100)/ 100000, 0, game.controls.move[2]+math.random(-100, 100)/ 100000), 0.3)
	end
	Player.Head.LocalRotation.X = 0
	AudioListener.Rotation = Camera.Rotation

	if Player.Position.X < 7.5 then
		Player.Position.X = 7.5
	end
	if Player.Position.Z < 7.5 then
		Player.Position.Z = 7.5
	end
	if Player.Position.X > (game.world.map.Width-16) * game.world.map.Scale.X +2.5 then
		Player.Position.X = (game.world.map.Width-16) * game.world.map.Scale.X +2.5 
	end
	if Player.Position.Z > (game.world.map.Depth-16) * game.world.map.Scale.Z +2.5 then 
		Player.Position.Z = (game.world.map.Depth-16) * game.world.map.Scale.Z +2.5 
	end
	if Player.Position.Y < 3 and not Player.isDead then
		Player.health = 0
		local e = Network.Event("set_health", {player = Player.Username, health = 0})
		e:SendTo(OtherPlayers) 
	end

	self.shootTimer = math.max(0, self.shootTimer - dt)
	if self.controls.shooting and not Player.isDead then
		if self.shootTimer == 0 then
			local e = Network.Event("bullet", {player = Player.Username, rot = Player.Rotation.Y, x = Player.Head.Position.X+Player.Forward.X*10, y = Player.Head.Position.Y-1+Player.Forward.Y*10, z = Player.Head.Position.Z+Player.Forward.Z*10})
			e:SendTo(Players)
			Player.bushcollider.t = 0
			local e = Network.Event("disable_invisibility", {player = Player.Username})
			e:SendTo(OtherPlayers)

			self.shootTimer = 0.25
		end
	end
end, function(err) CRASH("game.tick - "..err) end)

function game.create(self)

	self.shootTimer = 0

	self.created = true
	self.world:create(64)
	self.camera:create()
	self.ui:create()
	self.controls:create()
	nanimator.import(animations.player_walk, "player_walk")

	if Client.IsMobile then
		self.mobileControls:create()
	end

	self:screenResize()

	self.screenResizeListener = LocalEvent:Listen(LocalEvent.Name.ScreenDidResize, function(...)
        self:screenResize(...)
    end)
    self.eventListener = LocalEvent:Listen(LocalEvent.Name.DidReceiveEvent, function(...)
        self.connection:onEvent(...)
    end)
    self.tickListener = LocalEvent:Listen(LocalEvent.Name.Tick, function(...)
        self:tick(...)
    end)

    self.connection:connect()

	local e = Network.Event("send_rocks", {player = Player.Username})
	e:SendTo(Server)
	
	local e = Network.Event("send_bushes", {player = Player.Username})
	e:SendTo(Server)

	local e = Network.Event("send_round", {player = Player.Username})
	e:SendTo(Server)
    Debug.log("game() - created")
end
function game.remove(self, callback)
	self.controls:remove()
	self.screenResizeListener:Remove()
	self.eventListener:Remove()
	if self.mobileControls.created then
		self.mobileControls:remove()
	end
	self.tickListener:Remove()
	self.connection:disconnect()
	self.camera:remove()
	self.world:remove()
	self.ui:remove(callback)
	self.created = false
	Player.Position = Number3(-1000, -1000, -1000)
	Debug.log("game() - removed")
end

return game