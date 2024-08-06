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

game.world = gameWorld

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