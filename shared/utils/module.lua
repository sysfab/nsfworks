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
end

return utils