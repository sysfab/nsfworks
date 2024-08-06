playerConstructor = {}

playerConstructor.create = function(player)
	player.IsHidden = false
	player.lastDamager = nil
	if player.pistol == nil then
		Object:Load("voxels.silver_pistol", errorHandler(function(s)
			player.pistol = Shape(s)
			player.pistol:SetParent(player.Body.RightArm.RightHand)
			player.pistol.Scale = 0.65
			player.pistol.Shadow = true
			player.pistol.Physics = PhysicsMode.Disabled
			player.pistol.LocalRotation = Rotation(math.pi-0.2, math.pi/2, math.pi/2)
			player.pistol.LocalPosition = Number3(7, 0.2, 2)
			player.Animations.Idle:Stop()
			if player.Animations.Walk.Stop ~= nil then
				player.Animations.Walk:Stop()
			end
			rawset(player.Animations, "Walk", {})
			player.particles = particles.createEmitter()
			player.particlesTick = 0

			player.health = 100

			player.healthBarBG = Quad()
			player.healthBarBG:SetParent(player)
			player.healthBarBG.Color = Color(0, 0, 0, 200)
			player.healthBarBG.Width, player.healthBarBG.Height = 20, 3.5
			player.healthBarBG.Tick = function(self, dt)
				self.Position = self:GetParent().Position + Number3(self.Width/4, 15 + self.Height/2, 0)
				self.Forward = Camera.Backward
			end
			player.healthBar = Quad()
			player.healthBar:SetParent(player)
			player.healthBar.Color = Color(255, 0, 0, 255)
			player.healthBar.Width, player.healthBar.Height = 19*player.health*0.01, 2
			player.healthBar.Tick = function(self, dt)
				self.Position = self:GetParent().healthBarBG.Position + Number3(-10+0.25, 0.5, 0.01)
				self.Width, self.Height = 19*self:GetParent().health*0.01, 2
				self.Backward = Camera.Backward
			end

			player.bushcollider = Object()
			player.bushcollider:SetParent(player)
			player.bushcollider.CollisionBox = Box(Number3(-2.5, 0, -2.5), Number3(2.5, 20, 2.5))
			player.bushcollider.Physics = PhysicsMode.Trigger
			player.bushcollider.LocalPosition.Y = 9
			player.bushcollider.t = 0
			player.bushcollider.collides = false

			player.bushcollider.sound = AudioSource("gun_shot_1")
			player.bushcollider.sound.Sound = audio.bush
			player.bushcollider.sound:SetParent(player)
			player.bushcollider.sound.Volume = settings.currentSettings.soundVolume*0.01

			player.bushcollider.OnCollisionBegin = function(self, other)
				if self:GetParent() == Player and other.type == "bush" then
					player.bushcollider.collides = true
				end
				if distance(player.Position, Player.Position) < 120 and other.type == "bush"then
					player.bushcollider.sound.Volume = settings.currentSettings.soundVolume*0.01
					player.bushcollider.sound:Play()
					other:move()
				end
			end
			player.bushcollider.OnCollisionEnd = function(self, other)
				if self:GetParent() == Player and other.type == "bush" then
					player.bushcollider.collides = false
				end
			end
			player.bushcollider.Tick = function(self, dt)
				if self:GetParent() == Player then
					if self.collides and not self:GetParent().Body.isMoving then
						self.t = self.t + 63*dt

						if self.t > 60 then
							if not self.inbush then
								self.inbush = true
								self:GetParent().inbush = true
								local e = Network.Event("enable_invisibility", {player = Player.Username})
								e:SendTo(OtherPlayers)
								for i=1, 20 do
									self:GetParent().particles:updateConfig({
										position = self:GetParent().Position + Number3(math.random(-5, 5), math.random(0, 10), math.random(-5, 5)/4),
										scale = math.random(5, 8)*0.1,
										color = Color(63, 105, 64),
										life = 1.0,
										velocity = Number3(math.random(-10, 10), math.random(0, 20), math.random(-10, 10)),
										scale_end = Number3(0, 0, 0),
									})
									self:GetParent().particles:emit()
								end
							end
						else
							if self.inbush then
								self.inbush = false
								self:GetParent().inbush = false
								local e = Network.Event("disable_invisibility", {player = Player.Username})
								e:SendTo(OtherPlayers)
							end
						end
					else
						if self.inbush then
							self.inbush = false
							self:GetParent().inbush = false
							local e = Network.Event("disable_invisibility", {player = Player.Username})
							e:SendTo(OtherPlayers)
						end
						self.t = 0
					end
				end
			end

			player.bushparticles = particles:createEmitter()
			player.damageParticles = particles:createEmitter()
			player.shootParticles = particles.createEmitter({
				position = player.Position + player.Forward*2.5 + player.Down*0.5,
				scale = Number3(1, 1, 1),
				color = Color(255, 239, 94),
				life = 0.5,
				scale_end = Number3(0, 0, 0),
			})

            player.shootIndicator = Quad()
            player.shootIndicator.Image = images.gradient
            player.shootIndicator.Color = Color(255, 255, 255, 127)
            player.shootIndicator.Scale = Number3(10, 120, 0)
            player.shootIndicator.Rotation.X = math.pi/2
            player.shootIndicator.LocalPosition = Number3(-5, 0.5, 0)
            player.shootIndicator.IsHidden = true
            player.shootIndicator:SetParent(player)

			player.CollisionBox = Box({-8, 0, -8}, {8, 29, 8})

			player.OnCollisionBegin = function(self, other)
				if self ~= Player and other.damage ~= nil then
					if other.owner == Player and not self.isDead then
						local e = Network.Event("set_health", {player = self.Username, damage = other.damage})
						e:SendTo(Players)
					end
				end
				if other.owner.Username ~= self.Username and other.damage ~= nil and not self.isDead then
					for i=1, 30 do
						self.damageParticles:updateConfig({
							position = self.Position + Number3(math.random(-10, 10)/3, 10+math.random(-10, 10)/3, math.random(-10, 10)/3),
							rotation = Rotation(0, 0, 0),
							scale = Number3(1, 1, 1),
							color = Color(255, 0, 0, 230),
							life = 3.0,
							velocity = Number3(math.random(-40, 40)/2, math.random(0, 80)/2, math.random(-40, 40)/2) + other.Forward*5,
						})
						self.damageParticles:emit()
					end
					other:remove()
				end
			end

			player.decreaseHealth = function(self, damage)
				self.health = self.health - damage
				self.bushcollider.t = 0
				self.inbush = false
			end

			player.die = function(self)
				
				self.Body:nanStop()
				self.Body:setPlaySpeed(2)
				self.Body:setLoop(true)
				self.Body:nanPlay("player_die")
				self.healthBar.IsHidden = true
				self.healthBarBG.IsHidden = true

				self.isDead = true
				Timer(2, false, function()
					self.Position = Number3(-100000, -100000, -100000)
					self.health = 100
					self.isDead = false
					self.healthBar.IsHidden = false
					self.healthBarBG.IsHidden = false
					if self == Player then
						self.Velocity = Number3(0, 0, 0)
						self.Motion = Number3(0, 0, 0)
						self.Position = Number3(math.random(20, 80)/100*(game.world.map.Width-16), 10, math.random(20, 80)/100*(game.world.map.Depth-16))*game.world.map.Scale
						AudioListener:SetParent(Player)
					end
				end)
				Timer(2.2, false, function()
					local e = Network.Event("set_health", {player = self.Username, health = 100})
					e:SendTo(OtherPlayers)
				end)
				if self == Player then
					local e = Network.Event("kill", {player = self.Username, killer = self.lastDamager})
					e:SendTo(Server)
				end
			end

			player.Tick = errorHandler(function(self, dt)
				if not self.isDead then
					self.Body.RightArm.LocalRotation = Rotation(-math.pi/2, -math.pi/2-0.3, 0)
					self.Body.RightHand.LocalRotation = Rotation(0, 0, 0)
					self.Body.LeftArm.LocalRotation = Rotation(-math.pi/2, 0, math.pi/2+0.6)
					self.Body.LeftArm.LocalPosition = Number3(-4, 0, 1)
					self.Body.LeftHand.LocalRotation = Rotation(0, 0, 0)
				end
				self.Body.isMoving = false
				if self.Motion.X ~= 0 or self.Motion.Z ~= 0 then
					self.Body.isMoving = true
				end
				
				if self.health <= 0 and not self.isDead then
					self:die()
				end

				if self.inbush then
					self.IsHidden = true
				end

				if self.Body.isMoving then
					self.particlesTick = self.particlesTick + 1
					if self.particlesTick > 8 then
						self.particlesTick = 0
						for i=1, 5 do
							self.particles:updateConfig({
								position = self.Position + self.Forward,
								velocity = Number3(math.random(-10, 10), math.random(10, 20), math.random(-10, 10))*2,
								scale = Number3(1.5, 1.5, 1.5),
								color = Color(77, 144, 77),
								life = 0.5,
								scale_end = Number3(0, 0, 0),
							})
							self.particles:emit()
						end
					end
					self.Body:setLoop(true)
					self.Body:setPlaySpeed(10)
					self.Body:nanPlay("player_walk")
				else
					if not self.isDead then
						self.Body:nanStop()
					end
					self.particlesTick = 0
				end
			end, function(err) CRASH("player.Tick - "..err) end)
		end, function(err) CRASH("Object:Load(\"voxels.silver_pistol\") - "..err) end))
	end
	if player.Body.nanplayer == nil then
		nanimator.add(player.Body, "player_walk")
		nanimator.add(player.Body, "player_die")
	end
end

playerConstructor.remove = function(player)
    player.IsHidden = true
    player.leaveParticles = particles:createEmitter()
    for i=1, 30 do
        player.leaveParticles:updateConfig({
            position = player.Position + Number3(math.random(-10, 10)/2, math.random(0, 40)/2, math.random(-10, 10)/2),
            rotation = Rotation(0, 0, 0),
            scale = Number3(3, 3, 3),
            color = Color(255, 255, 255, 200),
            life = 3.0,
            velocity = Number3(math.random(-20, 20)/2, math.random(0, 80)/2, math.random(-20, 20)/2),
        })
        player.leaveParticles:emit()
    end
    player.leaveParticles:remove()
    if player.pistol ~= nil then
        player.pistol:SetParent(nil)
        player.pistol.Tick  = nil
        player.pistol = nil
    end
end

return playerConstructor