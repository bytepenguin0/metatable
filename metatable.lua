-- init
type userdata = {}
type _function = (...any) -> (...any)

local metatable = {
	metamethods = {
		__index = function(self, key)
			return self[key]
		end,
		__newindex = function(self, key, value)
			self[key] = value
		end,
		__call = function(self, ...)
			return self(...)
		end,
		__concat = function(self, b)
			return self..b
		end,
		__add = function(self, b)
			return self + b
		end,
		__sub = function(self, b)
			return self - b
		end,
		__mul = function(self, b)
			return self * b
		end,
		__div = function(self, b)
			return self / b
		end,
		__idiv = function(self, b)
			return self // b
		end,
		__mod = function(self, b)
			return self % b
		end,
		__pow = function(self, b)
			return self ^ b
		end,
		__tostring = function(self)
			return tostring(self)
		end,
		__eq = function(self, b)
			return self == b
		end,
		__lt = function(self, b)
			return self < b
		end,
		__le = function(self, b)
			return self <= b
		end,
		__len = function(self)
			return #self
		end,
		__iter = function(self)
			return next, self
		end,
		__namecall = function(self, ...)
			return self:_(...)
		end,
		__metatable = function(self)
			return getmetatable(self)
		end
	}
}

-- methods
function metatable.get_L_closure(metamethod: string, obj: {any} | userdata)
	local hooked
	local metamethod_emulator = metatable.metamethods[metamethod]
	
	xpcall(function()
		metamethod_emulator(obj)
	end, function()
		hooked = debug.info(2, "f")
	end)
	
	return hooked
end

function metatable.get_all_L_closures(obj: {any} | userdata)
	local metamethods = {}
	local innacurate = {}

	for method, _ in metatable.metamethods do
		local metamethod, accurate = metatable.get_L_closure(method, obj)
		metamethods[method] = metamethod
	end

	return metamethods
end

function metatable.metahook(t: any, f: _function)
	local metahook = {
		__metatable = getmetatable(t) or "The metatable is locked"
	}
	

	for metamethod, value in metatable.metamethods do
		metahook[metamethod] = function(self, ...)
			f(metamethod, ...)
			
			if metamethod == "__tostring" then
				return ""
			elseif metamethod == "__len" then
				return math.random(0, 1024)
			end
			
			return metatable.metahook({}, f) 
		end
	end

	return setmetatable({}, metahook)
end

return metatable
