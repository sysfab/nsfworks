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

    u.object.Tick = function()
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

	self.ui:screenResize()
	if self.mobileControls ~= nil then
		self.mobileControls:screenResize()
	end
end
game.create = function(self)
	self.created = true
	self.ui:create()
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
game.remove = function(self, callback)
	self.screenResizeListener:Remove()
	self.eventListener:Remove()
	if self.mobileControls.created then
		self.mobileControls:remove()
	end
	self.connection:disconnect()
	self.world:remove()
	self.ui:remove(callback)
	self.created = false
end


return game