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
game.bullets = {}

game.connection.connect = function(connection)
	if connection.connected == false then
		Debug.log("game() - connecting...")
		local e = Network.Event("connect", {})
		e:SendTo(Server)
	else
		Debug.error("game() - trying to connect when already connected", 2)
	end
end
game.connection.disconnect = function(connection)
	Debug.log("game() - disconnecting...")
	local e = Network.Event("disconnect", {})
	e:SendTo(Server)
	connection.connected = false
end
game.connection.onEvent = errorHandler(function(connection, e)
	Network:ParseEvent(e, {

		bullet = function(event)
			bullet.create(event.data)
		end,

		connected = function(event)
			Debug.log("game() - connected")
			
			Player.Velocity = Number3(0, 0, 0)
			Player.Motion = Number3(0, 0, 0)
			Player.Position = Number3(event.data.posX*(game.world.map.Width-16), 10, event.data.posY*(game.world.map.Depth-16))*game.world.map.Scale
			Player.health = 100
			AudioListener:SetParent(Player)
			Debug.log("game() - position set")

			for k, v in pairs(Players) do
				if event.data.players[v.Username] ~= nil then
					playerConstructor.create(v)
		        end
	        end

			game.connection.connected = true
		end,

		new_connection = function(event)
			Debug.log("game() - new connection of '".. event.data.player .. "'")
			local v = getPlayerByUsername(event.data.player)
			playerConstructor.create(v)
		end,

		new_disconnection = function(event)
			Debug.log("game() - disconnect of '".. event.data.player .. "'")
			local p = getPlayerByUsername(event.data.player)
			p.IsHidden = true
			p.leaveParticles = particles:createEmitter()
			for i=1, 30 do
				p.leaveParticles:updateConfig({
					position = p.Position + Number3(math.random(-10, 10)/2, math.random(0, 40)/2, math.random(-10, 10)/2),
					rotation = Rotation(0, 0, 0),
					scale = Number3(3, 3, 3),
					color = Color(255, 255, 255, 200),
					life = 3.0,
					velocity = Number3(math.random(-20, 20)/2, math.random(0, 80)/2, math.random(-20, 20)/2),
				})
				p.leaveParticles:emit()
			end
			p.leaveParticles:remove()
            if p.pistol ~= nil then
                p.pistol:SetParent(nil)
				p.pistol.Tick  = nil
                p.pistol = nil
            end
		end,

		set_health = function(event)
			local p = getPlayerByUsername(event.data.player)

			if event.data.damage ~= nil then
				Debug.log("game() - set_health event of " .. event.data.player .. " with damage [" .. event.data.damage .. "].")
				p:decreaseHealth(event.data.damage)
				p.lastDamager = event.Sender.Username
			elseif event.data.health ~= nil then
				Debug.log("game() - set_health event of " .. event.data.player .. " with health [" .. event.data.health .. "].")
				p.health = event.data.health
			end
		end,

		load_rocks = function(event)
			local rocks = JSON:Decode(event.data.rocks)

			for k, v in pairs(rocks) do
				local rock = Shape(shapes.rock)
				rock:SetParent(World)
				rock.Position = rocks[k].pos + Number3(2.5, 0, 2.5)
				rock.Rotation.Y = rocks[k].rot
				rock.Palette[1].Color = Color(rocks[k].col1[1], rocks[k].col1[2], rocks[k].col1[3])
				rock.Palette[2].Color = Color(rocks[k].col2[1], rocks[k].col2[2], rocks[k].col2[3])
				rock.id = rocks[k].id
				rock.type = "rock"

				rock.Physics = PhysicsMode.Trigger
				rock.Scale = 0.5
				rock.Shadow = true

				game.world.map.rocks[k] = rock
			end
		end,

		load_bushes = function(event)
			local bushes = JSON:Decode(event.data.bushes)

			for k, v in pairs(bushes) do
				local bush = Shape(shapes.bush)
				bush:SetParent(World)
				bush.Position = bushes[k].pos + Number3(2.5, 5, 2.5)
				bush.Rotation.Y = bushes[k].rot
				bush.id = bushes[k].id
				bush.type = "bush"
				bush.particles = particles.createEmitter()

				bush.move = function(self)
					if not self.ismoving then
						local defaultRot = Rotation(self.Rotation.X, self.Rotation.Y, self.Rotation.Z)
						local r = {"X", "Y", "Z"}
						local c = r[math.random(1, 3)]
						self.Rotation[c] = self.Rotation[c] + math.random(-10, 10)*0.05
						self.ismoving = true
						for i=1, 20 do
							Timer(i/2*0.016, false, function()
								self.Rotation:Slerp(self.Rotation, defaultRot, 0.3)
							end)
							Timer(10*0.016, false, function()
								self.ismoving = false
							end)
							self.particles:updateConfig({
								position = self.Position + Number3(math.random(-5, 5), math.random(0, 10), math.random(-5, 5)/4),
								scale = math.random(5, 8)*0.1,
								color = Color(63, 105, 64),
								life = 1.0,
								velocity = Number3(math.random(-10, 10), math.random(0, 20), math.random(-10, 10)),
								scale_end = Number3(0, 0, 0),
							})
							self.particles:emit()
						end
					end
				end

				bush.Physics = PhysicsMode.Trigger
				bush.Scale = Number3(0.75, 1.5, 0.75)
				bush.Shadow = true
				bush.CollisionBox = Box(Number3(5, 0, 4), Number3(10, 16, 9))

				game.world.map.bushes[k] = bush
			end
		end,

		enable_invisibility = function(event)
			Debug.log("game() - invisibility enabled for " .. event.data.player)
			local p = getPlayerByUsername(event.data.player)
			for i=1, 20 do
				p.particles:updateConfig({
					position = p.Position + Number3(math.random(-5, 5), math.random(0, 10), math.random(-5, 5)/4),
					scale = math.random(5, 8)*0.1,
					color = Color(63, 105, 64),
					life = 1.0,
					velocity = Number3(math.random(-10, 10), math.random(0, 20), math.random(-10, 10)),
					scale_end = Number3(0, 0, 0),
				})
				p.particles:emit()
			end
			p.inbush = true
		end,

		disable_invisibility = function(event)
			Debug.log("game() - invisibility disabled for " .. event.data.player)
			local p = getPlayerByUsername(event.data.player)
			p.inbush = false
		end,

		round_end = function(event)
			Debug.log("game() - round end. Winner: " .. event.data.winner)
			game:remove(function() menu.lastWinner = event.data.winner menu:create() menu:update() end)
		end,
		
		get_round = function(event)
			Debug.log("game() - loaded round. Time: " .. event.data.time .. ". End time: " .. event.data.time_end .. ". Mode: " .. event.data.mode)
			game.ui.loadedTimer = true
			game.time = event.data.time
			game.time_end = event.data.time_end
			game.mode = event.data.mode
		end,

		top = function(event)
			Debug.log("game() - loaded top 1 player: " .. event.data.winner)
			print("Winner: " .. event.data.winner .. " with " .. event.data.kills .. " kills and " .. event.data.deaths .. " deaths.")
		end,

		["_"] = function(event)
			if event.action ~= nil then
				Debug.log("game() - got unknown event: '".. event.action .."'")
			end
		end

	})
end, function(err) CRASH("game.connection.onEvent - "..err) end)
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

	u.timerBG = ui:createFrame(Color(0, 0, 0, 0.5))
	u.timerBG.pos = Number2(-1000, -1000)
	u.timer = ui:createText("0:00", Color(255, 255, 255))
	u.timer.pos = Number2(-1000, -1000)

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
		
		if u.timer ~= nil and u.loadedTimer then
			u.timer.pos = Number2(Screen.Width/2-Screen.SafeArea.Right-u.timer.Width/2, Screen.Height-Screen.SafeArea.Top-u.timer.Height-15)
			u.timerBG.pos = Number2(u.timer.pos.X-15, u.timer.pos.Y-15)
			u.timerBG.Width = u.timer.Width + 30
			u.timerBG.Height = u.timer.Height + 30

			local minutes = (game.time_end - math.floor(game.time))//60
			local seconds = (game.time_end - math.floor(game.time))%60
			if seconds < 10 then
                seconds = "0".. seconds
			end
			u.timer.Text = minutes .. ":" .. seconds
			game.time = game.time + dt
		end
    end

	if u.music == nil then
		u.music = AudioSource("gun_shot_1")
		u.music:SetParent(Player)
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

    Debug.log("game() - Removing game.ui...")
    u.closing = true

    Timer(0.5, false, function()
        u.created = false

		u.timerBG:remove()
		u.timerBG = nil
		u.timer:remove()
        u.timer = nil
		u.loadedTimer = false

        u.toMenu:remove()
        u.toMenu = nil
        
        u.blackPanel:remove()
        u.blackPanel = nil

        Debug.log("game() - game.ui removed.")
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
	Debug.log("game() - Generating world...")
	world.map = MutableShape()
	world.map.Scale = 5
	world.map.Physics = PhysicsMode.StaticPerBlock
	world.map.Shadow = true
	for x = 1, scale do
		for y = 1, scale do
			local a = perlin.get(x*0.1, y*0.1)*30
			local b = perlin.get(x+18532*0.2, y+13532*0.2)*20
			local plus = (a + b) / 2
			local block = Block(Color(math.floor(77-plus), math.floor(140-plus), math.floor(77-plus), 255), Number3(x, 0, y))

			world.map:AddBlock(block)
		end
	end
	for x = -8, 0 do
		for y = -7, scale+8 do
			local minusY = 0
			if y < 0 then
				minusY = y
			elseif y > scale then
				minusY = -(y-scale)
			end
			
			for i=1, 2 do
				local chance = math.random(math.min(x+minusY, 0), math.max(x+1+minusY, 0))
				if chance == 0 then
					local a = perlin.get(x*0.1, y*0.1)*30
					local b = perlin.get(x+18532*0.2, y+13532*0.2)*20
					local plus = math.abs(((a + b) / 2)*3//3*3)
					local block = Block(Color(math.floor(77-plus), math.floor(140-plus), math.floor(77-plus), 255), Number3(x+1, 0, y))
					local coff = math.min(1, (1/(1/(math.abs(x+minusY)))/8)*2)
					block.Color = Color(math.floor(lerp(block.Color.R, 230-plus, coff)), math.floor(lerp(block.Color.G, 230-plus, coff)), math.floor(lerp(block.Color.B, 131-plus, coff)))

					world.map:AddBlock(block)
				end
			end
		end
	end

	for x = scale+1, scale+8 do
		for y = -7, scale+8 do
			local minusY = 0
			if y < 0 then
				minusY = y
			elseif y > scale then
				minusY = -(y-scale)
			end
			
			for i=1, 2 do
				local chance = math.random(math.min(x-scale-minusY, 0), math.max(x-scale-minusY, 0))
				if chance == 0 then
					local a = perlin.get(x*0.1, y*0.1)*30
					local b = perlin.get(x+18532*0.2, y+13532*0.2)*20
					local plus = math.abs(((a + b) / 2)*3//3*3)
					local block = Block(Color(math.floor(77-plus), math.floor(140-plus), math.floor(77-plus), 255), Number3(x, 0, y))
					local coff = math.min(1, (1/(1/(math.abs(x-scale-minusY)))/8)*2)
					block.Color = Color(math.floor(lerp(block.Color.R, 230-plus, coff)), math.floor(lerp(block.Color.G, 230-plus, coff)), math.floor(lerp(block.Color.B, 131-plus, coff)))
					
					world.map:AddBlock(block)
				end
			end
		end
	end

	for y = -8, 0 do
		for x = 0, scale do
			for i=1, 2 do
				local chance = math.random(math.min(y, 0), math.max(y+1, 0))
				if chance == 0 then
					local a = perlin.get(x*0.1, y*0.1)*30
					local b = perlin.get(x+18532*0.2, y+13532*0.2)*20
					local plus = math.abs(((a + b) / 2)*3//3*3)
					local block = Block(Color(math.floor(77-plus), math.floor(140-plus), math.floor(77-plus), 255), Number3(x, 0, y+1))
					local coff = math.min(1, (1/(1/(math.abs(y)))/8)*2)
					block.Color = Color(math.floor(lerp(block.Color.R, 230-plus, coff)), math.floor(lerp(block.Color.G, 230-plus, coff)), math.floor(lerp(block.Color.B, 131-plus, coff)))
					
					world.map:AddBlock(block)
				end
			end
		end
	end
	for y = scale, scale+8 do
		for x = 0, scale do
			for i=1, 2 do
				local chance = math.random(math.min(y-scale, 0), math.max(y-scale, 0))
				if chance == 0 then
					local a = perlin.get(x*0.1, y*0.1)*30
					local b = perlin.get(x+18532*0.2, y+13532*0.2)*20
					local plus = math.abs(((a + b) / 2)*3//3*3)
					local block = Block(Color(math.floor(77-plus), math.floor(140-plus), math.floor(77-plus), 255), Number3(x, 0, y))
					local coff = math.min(1, (1/(1/(math.abs(y-scale)))/8)*2)
					block.Color = Color(math.floor(lerp(block.Color.R, 230-plus, coff)), math.floor(lerp(block.Color.G, 230-plus, coff)), math.floor(lerp(block.Color.B, 131-plus, coff)))
					
					world.map:AddBlock(block)
				end
			end
		end
	end
	world.map:SetParent(World)
	world.map.water = Quad()
	world.map.water.Color = Color(99, 143, 219)
	world.map.water.Rotation.X = math.pi/2
	world.map.water.Scale = 32*20
	world.map.water:SetParent(World)
	world.map.water.Position = Number3(-32*5, 4, -32*5)
	world.map.water.t = 0
	world.map.water.Tick = function(self, dt)
		local delta = 63*dt
		self.t = self.t + delta
		self.LocalPosition.Y = 4 + (math.sin(self.t*0.03)*0.5)*0.5
	end

	world.map.water.shadow = Shape(world.map)
	world.map.water.shadow:SetParent(World)
	world.map.water.shadow.Scale = 5
	world.map.water.shadow.Scale.Y = 0.01
	world.map.water.shadow.Rotation = Rotation(0, 0, 0)
	world.map.water.shadow.Tick = function(self, dt)
		self.Position = Number3(world.map.Position.X, world.map.water.Position.Y, world.map.Position.Z) + Number3(0.5, 0.01, 0.5)
	end
	for i=1, #world.map.water.shadow.Palette do
		world.map.water.shadow.Palette[i].Color = Color(0, 0, 0, 0.2)
	end
	world.map.water.shadow:RefreshModel()
	world.map.rocks = {}
	world.map.bushes = {}

	Player.Position.Y = 10000
	Player:SetParent(World)
end
game.world.remove = function(world)

	for i=1, #world.map.rocks do
		world.map.rocks[i]:SetParent(nil)
		world.map.rocks[i].Tick = nil
		world.map.rocks[i] = nil
	end

	for i=1, #world.map.bushes do
		world.map.bushes[i]:SetParent(nil)
		world.map.bushes[i].particles:remove()
		world.map.bushes[i].Tick = nil
		world.map.bushes[i] = nil
	end

	world.map.water.shadow:SetParent(nil)
	world.map.water.shadow.Tick = nil
	world.map.water:SetParent(nil)
	world.map.water.Tick = nil
	world.map.water = nil
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
			controls.analogPad(pe.X, pe.Y)
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
	local dxmul = 1
	if dy < 0 then
		dxmul = 1.2
	else
		dxmul = 1.3
	end
	Player.Forward = Number3(dx*dxmul, 0, dy)*25
end
game.controls.directionalPad = function(dx, dy, isJoy)
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

game.created = false
game.screenResize = function(self)
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

game.create = function(self)

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
	Debug.log("game() - removed")
end

return game