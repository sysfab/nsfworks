-- Utils
-- NSFWorks utils

local utils = {}

utils.init = function(env)
	env.lerp = function(a, b, w)
		return a + (b-a)*w
	end

	env.mapRange = function(fromRange, value, toRange)
	    local fromMin, fromMax = fromRange[1], fromRange[2]
	    local toMin, toMax = toRange[1], toRange[2]
	    return (value - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin
	end

	env.minmax = function(min, max, value)
		return math.max(math.min(value, max), min)
	end

	env.distance = function(pos1, pos2)
		return math.sqrt((pos1.X-pos2.X)*(pos1.X-pos2.X) + (pos1.Y-pos2.Y)*(pos1.Y-pos2.Y) + (pos1.Z-pos2.Z)*(pos1.Z-pos2.Z))
	end

	env.errorHandler = function(f, handler)
		local handled = false
		local returned = nil
		local f_wrapped = function(...)
			return function()
				f(...)
			end
		end
		return function(...)
			if handled == true then return end
			local ok, err = pcall(f_wrapped(...))
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