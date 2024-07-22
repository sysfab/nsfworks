local game = {}

game.controls = {}
game.controls.created = false
game.controls.create = function(controls)
	game.controls.moveJoystick = joysticks.create({
		pos = {0, 0}, -- position on screen.
		scale = 1, -- scale multiplier, 1 = 160 pixels.
		color = Color(255, 255, 255, 127), -- color of joystick's insides.
		borderColor = Color(255, 255, 255, 255) -- color of joystick's border.
	})
end
game.controls.remove = function(controls)
	game.controls.moveJoystick:remove()
end


game.create = function(self)
	self.controls:create()
end
game.remove = function(self)
	self.controls:remove()
end


return game