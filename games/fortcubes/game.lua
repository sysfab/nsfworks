local game = {}

game.controls = {}
game.controls.created = false
game.controls.screenResize = function(controls)
	if controls.moveJoystick.loaded == true then
		controls.moveJoystick:setPos(Number2(10, 10))
	end
	if controls.shootJoystick.loaded == true then
		controls.shootJoystick:setPos(Number2(Screen.Width-10, 10))
	end
end
game.controls.create = function(controls)
	controls.moveJoystick = joysticks.create({
		pos = {10, 10}, -- position on screen.
		scale = 1.1, -- scale multiplier, 1 = 160 pixels.
		color = Color(200, 200, 255, 127), -- color of joystick's insides.
		borderColor = Color(200, 200, 255, 255) -- color of joystick's border.
	})
	controls.shootJoystick = joysticks.create({
		pos = {Screen.Width-10, 10}, -- position on screen.
		scale = 1.1, -- scale multiplier, 1 = 160 pixels.
		color = Color(255, 200, 200, 127), -- color of joystick's insides.
		borderColor = Color(255, 200, 200, 255) -- color of joystick's border.
	})
end
game.controls.remove = function(controls)
	game.controls.moveJoystick:remove()
	game.controls.shootJoystick:remove()
end

game.created = false
game.screenResize = function(self)
	if self.created ~= true then return end
	self.controls:screenResize()
end
game.create = function(self)
	self.created = true
	self.controls:create()
	self:screenResize()

	self.screenResizeListener = LocalEvent:Listen(LocalEvent.Name.ScreenDidResize, function()
        self:screenResize()
    end)
end
game.remove = function(self)
	self.screenResizeListener:Remove()
	self.controls:remove()
	self.created = false
end


return game