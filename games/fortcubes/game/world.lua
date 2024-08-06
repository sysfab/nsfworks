local gameworld = {}

gameworld.create = function(world, scale)
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
gameworld.remove = function(world)

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

return gameworld