local game = {}

game.controls = {}
game.controls.created = false
game.controls.create = function(controls)

end
game.controls.remove = function(controls)

end


game.create = function(self)
	self.controls:create()
end
game.remove = function(self)
	self.controls:remove()
end


return game