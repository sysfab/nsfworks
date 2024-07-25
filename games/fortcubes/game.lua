local game = {}

function getPlayerByUsername(username)
	for k, v in pairs(Players) do
		if v.Username == username then
			return v
		end
	end
end

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
			
			Player.Position = Number3(event.data.posX*game.world.map.Width, 10, event.data.posY*game.world.map.Depth)*game.world.map.Scale
			debug.log("game() - position set")

			for k, v in pairs(Players) do
				if event.data.players[v.Username] ~= nil then
		            v.IsHidden = false
		            if v.pistol == nil then
		                Object:Load("voxels.silver_pistol", function(s)
		                    v.pistol = Shape(s)
		                    v.pistol:SetParent(v.Body.RightArm.RightHand)
		                    v.pistol.Scale = 0.65
							v.pistol.Shadow = true
		                    v.pistol.Physics = PhysicsMode.Disabled
		                    v.pistol.LocalRotation = Rotation(math.pi-0.2, math.pi/2, math.pi/2)
		                    v.pistol.LocalPosition = Number3(7, 0.2, 2)
							rawset(v.Animations, "Walk", {})
							v.Tick = function(self, dt)
								self.Body.RightArm.LocalRotation = Rotation(-math.pi/2, -math.pi/2-0.3, 0)
								self.Body.RightHand.LocalRotation = Rotation(0, 0, 0)
								self.Body.LeftArm.LocalRotation = Rotation(-math.pi/2, 0, math.pi/2+0.6)
								self.Body.LeftArm.LocalPosition = Number3(-4, 0, 1)
								self.Body.LeftHand.LocalRotation = Rotation(0, 0, 0)

								self.Body.isMoving = false
								if self.Motion.X ~= 0 or self.Motion.Z ~= 0 then
									self.Body.isMoving = true
								end
								if self.Body.isMoving then
									self.Body:setLoop(true)
									self.Body:setPlaySpeed(8)
									self.Body:nanPlay("player_walk")
								else
									self.Body:nanStop()
								end
							end
		                end)
		            end
					if v.Body.nanplayer == nil then
						nanimator.add(v.Body, "player_walk")
					end
		        end
	        end

			game.connection.connected = true
		end,

		new_connection = function(event)
			debug.log("game() - new connection of '".. event.data.player .. "'")
			local p = getPlayerByUsername(event.data.player)
			p.IsHidden = false
            if p.pistol == nil then
                Object:Load("voxels.silver_pistol", function(s)
                    p.pistol = Shape(s)
                    p.pistol:SetParent(p.Body.RightArm.RightHand)
                    p.pistol.Scale = 0.65
                    p.pistol.Physics = PhysicsMode.Disabled
                    p.pistol.LocalRotation = Rotation(math.pi, math.pi/2, math.pi/2)
                    p.pistol.LocalPosition = Number3(7, 0.2, 2)
					p.pistol.parent = p
					rawset(v.Animations, "Walk", {})
					p.Tick = function(self, dt)
						self.Body.RightArm.LocalRotation = Rotation(-math.pi/2, -math.pi/2-0.3, 0)
						self.Body.RightHand.LocalRotation = Rotation(0, 0, 0)
						self.Body.LeftArm.LocalRotation = Rotation(-math.pi/2, 0, math.pi/2+0.6)
						self.Body.LeftArm.LocalPosition = Number3(-4, 0, 1)
						self.Body.LeftHand.LocalRotation = Rotation(0, 0, 0)

						self.Body.isMoving = false
						if self.Motion.X ~= 0 or self.Motion.Z ~= 0 then
							self.Body.isMoving = true
						end
						if self.Body.isMoving then
							self.Body:setLoop(true)
							self.Body:setPlaySpeed(8)
							self.Body:nanPlay("player_walk")
						else
							self.Body:nanStop()
						end
					end
                end)
            end
			if p.Body.nanplayer == nil then
				nanimator.add(p.Body, "player_walk")
			end
		end,

		new_disconnection = function(event)
			debug.log("game() - disconnect of '".. event.data.player .. "'")
			local p = getPlayerByUsername(event.data.player)
			p.IsHidden = true
            if p.pistol ~= nil then
                p.pistol:SetParent(nil)
				p.pistol.Tick  = nil
                p.pistol = nil
            end
		end,

		["_"] = function(event)
			if event.action ~= nil then
				debug.log("game() - got unknown event: '".. event.action .."'")
			end
		end

	})
end

game.ui = {}
game.ui.created = false
game.ui.create = function(u)
	u.theme = {
        button = {
            borders = true,
            underline = false,
            padding = true,
            shadow = false,
            sound = "button_1",
            color = Color(100, 100, 100, 127),
            colorPressed = Color(50, 50, 50, 127),
            colorSelected = Color(50, 50, 50, 127),
            colorDisabled = Color(100, 100, 100, 127/2),
            textColor = Color(255, 255, 255, 255),
            textColorDisabled = Color(255, 255, 255, 200),
        }
    }
    u.closing = false

    function u.setBorders(button)
        if button == nil or button.borders == nil then
            error("game.ui.setBorders(button) 1st argument should be a button.")
        end

        for k, v in pairs(button.borders) do
            v.Color = Color(0, 0, 0, 127)
        end
    end

    u.wh = math.max(Screen.Width, Screen.Height)
    u.screenWidth = math.min(640, u.wh)/1920
    u.screenHeight = math.min(360, u.wh)/1080

    local coff = (0.5+(Screen.Width*Screen.Height)/(1920*1080)*0.5)*3
    u.screenWidth = u.screenWidth * coff
    u.screenHeight = u.screenHeight * coff

    if u.object == nil then
        u.object = Object()
    end

    u.object.Tick = function(self, dt)
		local delta = dt*63
        if u.toMenu ~= nil then
            u.setBorders(u.toMenu)
        end
        if u.blackPanel ~= nil and u.blackPanel.alpha ~= nil then
            u.blackPanel.Color.A = u.blackPanel.alpha
        end
        if u.closing then
            if u.blackPanel.alpha ~= nil then
                u.blackPanel.alpha = math.ceil(lerp(u.blackPanel.alpha, 255, 0.3))
            end
        else
            if u.blackPanel.alpha ~= nil then
                u.blackPanel.alpha = math.floor(lerp(u.blackPanel.alpha, 0, 0.3))
            end
        end
		if u.music ~= nil then
            if u.created == true then
                u.music.Volume = lerp(u.music.Volume, settings.currentSettings.musicVolume*0.01, 0.005*delta)
                if not u.music.IsPlaying then
                    u.music:Play()
                end
            else
                u.music.Volume = lerp(u.music.Volume, 0, 0.05*delta)
            end
        end
    end

	if u.music == nil then
		u.music = AudioSource("gun_shot_1")
		u.music:SetParent(Camera)
		u.music.Sound = audio.game_theme
		u.music:Play()
		u.music.Loop = true
		u.music.Volume = 0.0001
    end

    u.toMenu = ui:createButton("To Menu", u.theme.button)
    u.toMenu.pos = Number2(-1000, -1000)
    u.toMenu.onRelease = function(s)
    	u.toMenu:disable()
        game:remove(function() menu:create() menu:update() end)
    end

    u.blackPanel = ui:createFrame(Color(0, 0, 0, 0))
    u.blackPanel.alpha = 255

	u.created = true
end
game.ui.remove = function(u, callback)
    if u.created == nil then
        error("game.ui.remove() should be called with ':'!", 2)
    end
    if not u.created then
        error("game.ui:remove() - menu currently removed.", 2)
    end

    debug.log("game() - Removing game.ui...")
    u.closing = true

    Timer(0.5, false, function()
        u.created = false

        u.toMenu:remove()
        u.toMenu = nil
        
        u.blackPanel:remove()
        u.blackPanel = nil

        debug.log("game() - game.ui removed.")
        if callback ~= nil then callback() end
    end)
end
game.ui.screenResize = function(u)
	if u.created == nil then
        error("menu.update() should be called with ':'!", 2)
    end

    u.wh = math.max(Screen.Width, Screen.Height)
    u.screenWidth = math.min(640, u.wh)/1920
    u.screenHeight = math.min(360, u.wh)/1080

    local coff = (0.5+(Screen.Width*Screen.Height)/(1920*1080)*0.5)*3
    u.screenWidth = u.screenWidth * coff
    u.screenHeight = u.screenHeight * coff

    u.blackPanel.Width = Screen.Width
    u.blackPanel.Height = Screen.Height

    u.toMenu.Width, u.toMenu.Height = 380 * u.screenWidth * 0.7, 80 * u.screenHeight * 0.6
    u.toMenu.pos.Y = Screen.Height - Screen.SafeArea.Top - 5 - u.toMenu.Height
    u.toMenu.pos.X = 5
    u.toMenu.content.Scale.X = u.screenWidth * 2
    u.toMenu.content.Scale.Y = u.screenHeight * 2
    u.toMenu.content.pos = Number2(u.toMenu.Width/2 - u.toMenu.content.Width/2, u.toMenu.Height/2 - u.toMenu.content.Height/2)
end

game.mobileControls = {}
game.mobileControls.created = false
game.mobileControls.screenResize = function(controls)
	if controls.moveJoystick.loaded == true then
		controls.moveJoystick:setPos(Number2(10+48, 10+48))
	end
	if controls.shootJoystick.loaded == true then
		controls.shootJoystick:setPos(Number2(Screen.Width-10-176, 10+48))
	end
end
game.mobileControls.create = function(controls)
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
game.mobileControls.remove = function(controls)
	controls.moveJoystick:remove()
	controls.shootJoystick:remove()
	controls.moveJoystick = nil
	controls.shootJoystick = nil
	controls.created = false
end

game.world = {}
game.world.create = function(world, scale)
	debug.log("game() - Generating world...")
	world.map = MutableShape()
	world.map.Scale = 5
	world.map.Physics = PhysicsMode.StaticPerBlock
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

	Player:SetParent(World)
end
game.world.remove = function(world)
	world.map:SetParent(nil)
	world.map = nil

	Player:SetParent(nil)
end

game.camera = {}
game.camera.created = false
game.camera.create = function(camera)
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
game.camera.remove = function(camera)
	camera.object.Tick = nil
	camera.object = nil
	camera.created = false
end

game.controls = {}
game.controls.shooting = false
game.controls.create = function(controls)
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
			--controls.analogPad(pe.X, pe.Y)
			game.controls.shooting = true
		end
		Pointer.Up = function(pe)
			controls.analogPad(pe.X, pe.Y)
			game.controls.shooting = false
		end
	end
end
game.controls.remove = function(controls)
	Client.DirectionalPad = nil
	Pointer.Drag = nil
	Pointer.Down = nil
	Pointer.Up = nil
end
game.controls.analogPad = function(dx, dy, isJoy)
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

	Player.Forward = Number3(dx, 0, dy)*25
end
game.controls.directionalPad = function(dx, dy, isJoy)
	if isJoy == true then
		local d = Number2(dx, dy)
		d:Normalize()
		dx = d.X
		dy = d.Y
	end
	Player.Motion = Number3(dx, 0, dy)*80
	game.controls.move = {dx, dy}
end

game.created = false
game.screenResize = function(self)
	if self.created ~= true then return end

	self.ui:screenResize()
	if self.mobileControls ~= nil then
		self.mobileControls:screenResize()
	end
end

game.tick = function(self)
	Player.Velocity.Y = Player.Velocity.Y + 0.01
	if game.controls.move[1] ~= nil and game.controls.move[2] ~= nil and not game.controls.shooting then
		Player.Forward = lerp(Player.Forward, Number3(game.controls.move[1]+math.random(-100, 100)/ 100000, 0, game.controls.move[2]+math.random(-100, 100)/ 100000), 0.3)
	end
end

game.create = function(self)
	self.created = true
	self.world:create(128)
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
    debug.log("game() - created")
end
game.remove = function(self, callback)
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
	debug.log("game() - removed")
end


return game