local utils = {}

utils.init = function(env)
	env.lerp = function(a, b, w)
		return a + (b-a)*w
	end
end

return utils