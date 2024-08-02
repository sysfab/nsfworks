-- Utils
-- NSFWorks utils

local utils = {}

utils.init = function(self, env)
	self.env = env

	self.env.lerp = function(a, b, w)
		return a + (b-a)*w
	end

	self.env.mapRange = function(fromRange, value, toRange)
	    local fromMin, fromMax = fromRange[1], fromRange[2]
	    local toMin, toMax = toRange[1], toRange[2]
	    return (value - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin
	end

	self.env.minmax = function(min, max, value)
		return math.max(math.min(value, max), min)
	end

	self.env.distance = function(pos1, pos2)
		return math.sqrt((pos1.X-pos2.X)*(pos1.X-pos2.X) + (pos1.Y-pos2.Y)*(pos1.Y-pos2.Y) + (pos1.Z-pos2.Z)*(pos1.Z-pos2.Z))
	end

	self.env.errorHandler = function(f, handler)
		local handled = false
		local returned = nil
		return function(...)
			if handled == true then return end
			local ok, err = pcall(f, ...)
			if not ok then
				handled = true
				handler(err)
			else
				return returned
			end
		end
	end
end

return utils