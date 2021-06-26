local Vector3 = {}
Vector3.__index = Vector3

function Vector3.new(x, y, z)
	if type(x) ~= "number" then
		error("Error: Expected number for the value of x, but received argument of type "..type(x)..".")
	end
	if type(y) ~= "number" then
		error("Error: Expected number for the value of y, but received argument of type "..type(y)..".")
	end
	if type(z) ~= "number" then
		error("Error: Expected number for the value of z, but received argument of type "..type(z)..".")
	end
	
	local result = {
		x = x,
		y = y,
		z = z
	}
	setmetatable(result, Vector3)
	return result
end

--- Adds the specified vectors or numbers together.
-- Returns the result as a new vector.
-- If 1 of the inputs is a number and the other a vector, then the number will
-- be added to each of the components of the vector.
-- @param	a	Vector3|number	The first item to add.
-- @param	a	Vector3|number	The second item to add.
-- @returns	Vector3				The result as a new Vector3 object.
function Vector3.add(a, b)
	if type(a) == "number" then
		return Vector3.new(b.x + a, b.y + a, b.z + a)
	elseif type(b) == "number" then
		return Vector3.new(a.x + b, a.y + b, a.z + b)
	end
	return Vector3.new(a.x + b.x, a.y + b.y, a.z + b.z)
end

--- Subtracts the specified vectors or numbers together.
-- Returns the result as a new vector.
-- If 1 of the inputs is a number and the other a vector, then the number will
-- be subtracted to each of the components of the vector.
-- @param	a	Vector3|number	The first item to subtract.
-- @param	a	Vector3|number	The second item to subtract.
-- @returns	Vector3				The result as a new Vector3 object.
function Vector3.subtract(a, b)
	if type(a) == "number" then
		return Vector3.new(b.x - a, b.y - a, b.z - a)
	elseif type(b) == "number" then
		return Vector3.new(a.x - b, a.y - b, a.z - b)
	end
	return Vector3.new(a.x - b.x, a.y - b.y, a.z - b.z)
end
--- Alias for Vector3.subtract.
function Vector3.sub(a, b) return Vector3.subtract(a, b) end

--- Multiplies the specified vectors or numbers together.
-- Returns the result as a new vector.
-- If 1 of the inputs is a number and the other a vector, then the number will
-- be multiplied to each of the components of the vector.
-- 
-- If both of the inputs are vectors, then the components are multiplied
-- by each other (NOT the cross product). In other words:
-- a.x * b.x, a.y * b.y, a.z * b.z
-- 
-- @param	a	Vector3|number	The first item to multiply.
-- @param	a	Vector3|number	The second item to multiply.
-- @returns	Vector3				The result as a new Vector3 object.
function Vector3.multiply(a, b)
	if type(a) == "number" then
		return Vector3.new(b.x * a, b.y * a, b.z * a)
	elseif type(b) == "number" then
		return Vector3.new(a.x * b, a.y * b, a.z * b)
	end
	return Vector3.new(a.x * b.x, a.y * b.y, a.z * b.z)
end
--- Alias for Vector3.multiply.
function Vector3.mul(a, b) return Vector3.multiply(a, b) end

--- Divides the specified vectors or numbers together.
-- Returns the result as a new vector.
-- If 1 of the inputs is a number and the other a vector, then the number will
-- be divided to each of the components of the vector.
-- @param	a	Vector3|number	The first item to divide.
-- @param	a	Vector3|number	The second item to divide.
-- @returns	Vector3				The result as a new Vector3 object.
function Vector3.divide(a, b)
	if type(a) == "number" then
		return Vector3.new(b.x / a, b.y / a, b.z / a)
	elseif type(b) == "number" then
		return Vector3.new(a.x / b, a.y / b, a.z / b)
	end
	return Vector3.new(a.x / b.x, a.y / b.y, a.z / b.z)
end
--- Alias for Vector3.divide.
function Vector3.div(a, b) return Vector3.divide(a, b) end

--  ██████  ██████  ███████ ██████   █████  ████████  ██████  ██████
-- ██    ██ ██   ██ ██      ██   ██ ██   ██    ██    ██    ██ ██   ██
-- ██    ██ ██████  █████   ██████  ███████    ██    ██    ██ ██████
-- ██    ██ ██      ██      ██   ██ ██   ██    ██    ██    ██ ██   ██
--  ██████  ██      ███████ ██   ██ ██   ██    ██     ██████  ██   ██
-- 
--  ██████  ██    ██ ███████ ██████  ██████  ██ ██████  ███████ ███████
-- ██    ██ ██    ██ ██      ██   ██ ██   ██ ██ ██   ██ ██      ██
-- ██    ██ ██    ██ █████   ██████  ██████  ██ ██   ██ █████   ███████
-- ██    ██  ██  ██  ██      ██   ██ ██   ██ ██ ██   ██ ██           ██
--  ██████    ████   ███████ ██   ██ ██   ██ ██ ██████  ███████ ███████

function Vector3.__call(x, y, z)
	return Vector3.new(x, y, z)
end
function Vector3.__add(a, b)
	return Vector3.add(a, b)
end

function Vector3.__sub(a, b)
	return Vector3.sub(a, b)
end

function Vector3.__mul(a, b)
	return Vector3.mul(a, b)
end

function Vector3.__div(a, b)
	return Vector3.divide(a, b)
end

--- Returns the current Vector3 as a string.
function Vector3.__tostring(a)
	return "("..a.x..", "..a.y..", "..a.z..")"
end



if worldeditadditions then
	worldeditadditions.Vector3 = Vector3
else
	return Vector3
end
