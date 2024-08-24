-- Utils
-- NSFWorks utils

local utils = {}

utils.init = function(self, e)
	self.env = e

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

	self.env.errorHandler = function(f, handler, ignore_handled)
		local handled = false
		local returned = nil
		return function(...)
			if ignore_handled ~= true then if handled == true then return end end
			local ok, err = pcall(f, ...)
			if not ok then
				handled = true
				handler(err)
			else
				return returned
			end
		end
	end

	self.env.loadFunction = function(func_or_string, env)
		return load(func_or_string, nil, "bt", env or self.env)
	end

	--http://lua-users.org/wiki/CopyTable
	self.env.copyTable = function(orig, copies)
		copies = copies or {}
		local orig_type = type(orig)
		local copy
		if orig_type == 'table' then
			if copies[orig] then
				copy = copies[orig]
			else
				copy = {}
				copies[orig] = copy
				for orig_key, orig_value in next, orig, nil do
					copy[self.env.copyTable(orig_key, copies)] = self.env.copyTable(orig_value, copies)
				end
				setmetatable(copy, self.env.copyTable(getmetatable(orig), copies))
			end
		else -- number, string, boolean, etc
			copy = orig
		end
		return copy
	end
end

return utils