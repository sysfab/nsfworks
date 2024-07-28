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

		bullet = function(event)
			local b = Shape(shapes.bullet, {includeChildren = true})
			b.owner = getPlayerByUsername(event.data.player)

			b:SetParent(World)
			b.Rotation = Rotation(0, event.data.rot, 0)
			b.Scale = Number3(0.5, 0.5, 1)

			if b.owner == Player then
				b.Position = lerp(Number3(event.data.x, event.data.y, event.data.z), Player.Head.Position, 0.5)
			else
				b.Position = Number3(event.data.x, event.data.y, event.data.z)
			end

			b.Physics = PhysicsMode.Trigger
			b:GetChild(1).Physics = PhysicsMode.Trigger
			b.as = AudioSource("gun_shot_1")
			b.as:SetParent(b.owner)
			b.as.Volume = settings.currentSettings.soundVolume*0.01
			if distance(b.Position, Player.Position) < 120 then
				b.as:Play()
			end
			b.damage = 20

			b.particle = particles.createEmitter({
				position = b.Position + b.Forward*2.5 + b.Down*0.5,
				scale = Number3(1, 1, 1),
				color = Color(255, 239, 94),
				life = 0.5,
				scale_end = Number3(0, 0, 0),
			})
			for i=1, 10 do
				if b.owner ~= Player then
					b.particle:updateConfig({
						position = b.Position + b.Backward*2.5 + b.Down*0.5,
					})
				end
				b.particle:updateConfig({
					velocity = (b.Forward*math.random(-10, 10)/15 + b.Right*math.random(-10, 10)/7 + b.Up*math.random(5, 15)/4)*10 + b.owner.Motion*0.75,
				})
				b.particle:emit()
			end

			b.lifeTime = 0.5
			b.Tick = function(self, dt)
				local dt_factor = dt*63
				self.Position = self.Position + self.Forward * 4 * dt_factor

				self.lifeTime = self.lifeTime - dt
				if self.lifeTime <= 0 then
					for i=1, 10 do
						self.particle:updateConfig({
							position = self.Position,
							velocity = Number3(math.random(-10, 10), math.random(-10, 20), math.random(-10, 10)) + self.Forward * dt_factor*50,
						})
						self.particle:emit()
					end
					self:remove()
				end
			end
			b.remove = function(self)
				self.particle:remove()
				--self.as:SetParent(nil)
				--self.as = nil
				self:SetParent(nil)
				self.Tick = nil
			end
		end,

		connected = function(event)
			debug.log("game() - connected")
			
			Player.Velocity = Number3(0, 0, 0)
			Player.Motion = Number3(0, 0, 0)
			Player.Position = Number3(event.data.posX*(game.world.map.Width-16), 10, event.data.posY*(game.world.map.Depth-16))*game.world.map.Scale
			AudioListener:SetParent(Player)
			debug.log("game() - position set")

			for k, v in pairs(Players) do
				if event.data.players[v.Username] ~= nil then
		            v.IsHidden = false
					v.lastDamager = nil
		            if v.pistol == nil then
		                Object:Load("voxels.silver_pistol", function(s)
		                    v.pistol = Shape(s)
		                    v.pistol:SetParent(v.Body.RightArm.RightHand)
		                    v.pistol.Scale = 0.65
							v.pistol.Shadow = true
		                    v.pistol.Physics = PhysicsMode.Disabled
		                    v.pistol.LocalRotation = Rotation(math.pi-0.2, math.pi/2, math.pi/2)
		                    v.pistol.LocalPosition = Number3(7, 0.2, 2)
							v.Animations.Idle:Stop()
							if v.Animations.Walk.Stop ~= nil then
								v.Animations.Walk:Stop()
							end
							rawset(v.Animations, "Walk", {})
							v.particles = particles.createEmitter()
							v.particlesTick = 0

							v.health = 100

							v.healthBarBG = Quad()
							v.healthBarBG:SetParent(v)
							v.healthBarBG.Color = Color(0, 0, 0, 200)
							v.healthBarBG.Width, v.healthBarBG.Height = 20, 3.5
							v.healthBarBG.Tick = function(self, dt)
								self.Position = self:GetParent().Position + Number3(self.Width/4, 15 + self.Height/2, 0)
								self.Forward = Camera.Backward
							end
							v.healthBar = Quad()
							v.healthBar:SetParent(v)
							v.healthBar.Color = Color(255, 0, 0, 255)
							v.healthBar.Width, v.healthBar.Height = 19*v.health*0.01, 2
							v.healthBar.Tick = function(self, dt)
								self.Position = self:GetParent().healthBarBG.Position + Number3(-10+0.25, 0.5, 0.01)
								self.Width, self.Height = 19*self:GetParent().health*0.01, 2
								self.Backward = Camera.Backward
							end

							v.bushcollider = Object()
							v.bushcollider:SetParent(v)
							v.bushcollider.CollisionBox = Box(Number3(-2.5, 0, -2.5), Number3(2.5, 20, 2.5))
							v.bushcollider.Physics = PhysicsMode.Trigger
							v.bushcollider.LocalPosition.Y = 9
							v.bushcollider.t = 0
							v.bushcollider.collides = false
							v.bushcollider.OnCollisionBegin = function(self, other)
								if self:GetParent() == Player and other.type == "bush" then
									v.bushcollider.collides = true
								end
								local as = AudioSource("gun_shot_1")
								as.Sound = audio.bush
								as:SetParent(v)
								as.Volume = settings.currentSettings.soundVolume*0.005
								if distance(v.Position, Player.Position) < 120 then
									as:Play()
								end
							end
							v.bushcollider.OnCollisionEnd = function(self, other)
								if self:GetParent() == Player and other.type == "bush" then
									v.bushcollider.collides = false
								end
							end
							v.bushcollider.Tick = function(self, dt)
								if self:GetParent() == Player then
									if self.collides and not self:GetParent().Body.isMoving then
										self.t = self.t + 63*dt

										if self.t > 60 then
											if not self.inbush then
												self.inbush = true
												self:GetParent().inbush = true
												local e = crystal.Event("enable_invisibility", {player = Player.Username})
												e:SendTo(OtherPlayers)
											end
										else
											if self.inbush then
												self.inbush = false
												self:GetParent().inbush = false
												local e = crystal.Event("disable_invisibility", {player = Player.Username})
												e:SendTo(OtherPlayers)
											end
										end
									else
										if self.inbush then
											self.inbush = false
											self:GetParent().inbush = false
											local e = crystal.Event("disable_invisibility", {player = Player.Username})
											e:SendTo(OtherPlayers)
										end
										self.t = 0
									end
								end
							end

							v.CollisionBox = Box({-8, 0, -8}, {8, 29, 8})

							v.OnCollisionBegin = function(self, other)
								if self ~= Player and other.damage ~= nil then
									if other.owner == Player then
										local e = crystal.Event("set_health", {player = self.Username, damage = other.damage})
										e:SendTo(Players)
									end
								end
								if other.owner.Username ~= self.Username and other.damage ~= nil and not self.isDead then
									self.damageParticles = particles:createEmitter()
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
									self.damageParticles:remove()
									other:remove()
								end
							end
		
							v.decreaseHealth = function(self, damage)
								self.health = self.health - damage
								self.bushcollider.t = 0
								self.inbush = false
							end
		
							v.die = function(self)
								local exp = require("explode")
								exp:shapes(self)
								self.isDead = true
								Timer(2, false, function()
									self.Position = Number3(-100000, -100000, -100000)
									self.health = 100
									if self == Player then
										self.Velocity = Number3(0, 0, 0)
										self.Motion = Number3(0, 0, 0)
										self.Position = Number3(math.random(20, 80)/100*(game.world.map.Width-16), 10, math.random(20, 80)/100*(game.world.map.Depth-16))*game.world.map.Scale
										AudioListener:SetParent(Player)
									end
								end)
								Timer(2.2, false, function()
									self.isDead = false
									self.IsHidden = false
								end)
							end

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
								
								if self.health <= 0 and not self.isDead then
									self:die()
								end

								if self.isDead == true or self.inbush then
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
									self.Body:nanStop()
									self.particlesTick = 0
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
					p.Animations.Idle:Stop()
					if p.Animations.Walk.Stop ~= nil then
						p.Animations.Walk:Stop()
					end
					rawset(p.Animations, "Walk", {})
					p.particles = particles.createEmitter()
					p.particlesTick = 0

					p.health = 100

					p.healthBarBG = Quad()
					p.healthBarBG:SetParent(p)
					p.healthBarBG.Color = Color(0, 0, 0, 200)
					p.healthBarBG.Width, p.healthBarBG.Height = 20, 3.5
					p.healthBarBG.Tick = function(self, dt)
						self.Position = self:GetParent().Position + Number3(self.Width/4, 15 + self.Height/2, 0)
						self.Forward = Camera.Backward
					end
					p.healthBar = Quad()
					p.healthBar:SetParent(p)
					p.healthBar.Color = Color(255, 0, 0, 255)
					p.healthBar.Width, p.healthBar.Height = 19*p.health*0.01, 2
					p.healthBar.Tick = function(self, dt)
						self.Position = self:GetParent().healthBarBG.Position + Number3(-10+0.25, 0.5, 0.01)
						self.Width, self.Height = 19*self:GetParent().health*0.01, 2
						self.Backward = Camera.Backward
					end

					p.bushcollider = Object()
					p.bushcollider:SetParent(p)
					p.bushcollider.CollisionBox = Box(Number3(-2.5, 0, -2.5), Number3(2.5, 20, 2.5))
					p.bushcollider.Physics = PhysicsMode.Trigger
					p.bushcollider.LocalPosition.Y = 9
					p.bushcollider.t = 0
					p.bushcollider.collides = false
					p.bushcollider.OnCollisionBegin = function(self, other)
						if self:GetParent() == Player and other.type == "bush" then
							p.bushcollider.collides = true
						end
						local as = AudioSource("gun_shot_1")
						as.Sound = audio.bush
						as:SetParent(p)
						as.Volume = settings.currentSettings.soundVolume*0.005
						if distance(p.Position, Player.Position) < 120 then
							as:Play()
						end
					end
					p.bushcollider.OnCollisionEnd = function(self, other)
						if self:GetParent() == Player and other.type == "bush" then
							p.bushcollider.collides = false
						end
					end
					p.bushcollider.Tick = function(self, dt)
						if self:GetParent() == Player then
							if self.collides and not self:GetParent().Body.isMoving then
								self.t = self.t + 63*dt

								if self.t > 60 then
									if not self.inbush then
										self.inbush = true
										self:GetParent().inbush = true
										local e = crystal.Event("enable_invisibility", {player = Player.Username})
										e:SendTo(OtherPlayers)
									end
								else
									if self.inbush then
										self.inbush = false
										self:GetParent().inbush = false
										local e = crystal.Event("disable_invisibility", {player = Player.Username})
										e:SendTo(OtherPlayers)
									end
								end
							else
								if self.inbush then
									self.inbush = false
									self:GetParent().inbush = false
									local e = crystal.Event("disable_invisibility", {player = Player.Username})
									e:SendTo(OtherPlayers)
								end
								self.t = 0
							end
						end
					end

					p.CollisionBox = Box({-8, 0, -8}, {8, 29, 8})

					p.OnCollisionBegin = function(self, other)
						if self ~= Player and other.damage ~= nil then
							if other.owner == Player then
								local e = crystal.Event("set_health", {player = self.Username, damage = other.damage})
								e:SendTo(Players)
							end
						end
						if other.owner.Username ~= self.Username and other.damage ~= nil and not self.isDead then
							self.damageParticles = particles:createEmitter()
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
							self.damageParticles:remove()
							other:remove()
						end
					end

					p.decreaseHealth = function(self, damage)
						self.health = self.health - damage
						self.bushcollider.t = 0
						self.inbush = false
					end

					p.die = function(self)
						local exp = require("explode")
						exp:shapes(self)
						self.isDead = true
						Timer(2, false, function()
							self.Position = Number3(-100000, -100000, -100000)
							self.health = 100
							if self == Player then
								self.Velocity = Number3(0, 0, 0)
								self.Motion = Number3(0, 0, 0)
								self.Position = Number3(math.random(20, 80)/100*(game.world.map.Width-16)+8, 10, math.random(20, 80)/100*(game.world.map.Depth-16)+8)*game.world.map.Scale
								AudioListener:SetParent(Player)
							end
						end)
						Timer(2.2, false, function()
							self.isDead = false
							self.IsHidden = false
						end)
					end

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
						
						if self.health <= 0 and not self.isDead then
							self:die()
						end

						if self.isDead == true or self.inbush then
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
							self.Body:nanStop()
							self.particlesTick = 0
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
			debug.log("game() - set_health event of " .. event.data.player .. " with damage [" .. event.data.damage .. "].")

			p:decreaseHealth(event.data.damage)
			p.lastDamager = event.Sender.Username
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

				bush.Physics = PhysicsMode.Trigger
				bush.Scale = Number3(0.75, 1.5, 0.75)
				bush.Shadow = true
				bush.CollisionBox = Box(Number3(6, 0, 5), Number3(9, 16, 8))

				game.world.map.bushes[k] = bush
			end
		end,

		enable_invisibility = function(event)
			debug.log("game() - invisibility enabled for " .. event.data.player)
			local p = getPlayerByUsername(event.data.player)
			p.inbush = true
		end,

		disable_invisibility = function(event)
			debug.log("game() - invisibility disabled for " .. event.data.player)
			local p = getPlayerByUsername(event.data.player)
			p.inbush = false
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
		world.map.rocks[i] = nil
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

game.tick = function(self, dt)
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
		local e = crystal.Event("set_health", {player = Player.Username, damage = 100})
		e:SendTo(OtherPlayers) 
	end

	self.shootTimer = math.max(0, self.shootTimer - dt)
	if self.controls.shooting and not Player.isDead then
		if self.shootTimer == 0 then
			local e = crystal.Event("bullet", {player = Player.Username, rot = Player.Rotation.Y, x = Player.Head.Position.X+Player.Forward.X*10, y = Player.Head.Position.Y-1+Player.Forward.Y*10, z = Player.Head.Position.Z+Player.Forward.Z*10})
			e:SendTo(Players)
			Player.bushcollider.t = 0
			local e = crystal.Event("disable_invisibility", {player = Player.Username})
			e:SendTo(OtherPlayers)

			self.shootTimer = 0.25
		end
	end
end

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

	local e = crystal.Event("send_rocks", {player = Player.Username})
	e:SendTo(Server)
	
	local e = crystal.Event("send_bushes", {player = Player.Username})
	e:SendTo(Server)
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