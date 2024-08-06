connection = {}

connection.onEvent = errorHandler(function(connection, e)
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
			playerConstructor.remove(p)
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

return connection