local utils = {}

utils.init = function(env)
	env.lerp = function(a, b, w)
		return a + (b-a)*w
	end

	env.slerp = function(a, b, w)
		local r = Rotation(a, 0, 0)
		r:Slerp(Rotation(b, 0, 0))
		return r
	end
end

return utils