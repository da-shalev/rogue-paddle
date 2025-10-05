--- @class Vec2
--- @field x number The x-component
--- @field y number The y-component
local Vec2 = {}
Vec2.__index = Vec2

--- Creates a new vector
--- @param x number
--- @param y number
--- @return Vec2
function Vec2.new(x, y)
  assert(type(x) == 'number', 'Vec2.new: x must be a number, got ' .. type(x))
  assert(type(y) == 'number', 'Vec2.new: y must be a number, got ' .. type(y))
  return setmetatable({ x = x, y = y }, Vec2)
end

--- Returns the length (magnitude) of this vector
--- @return number
function Vec2:length()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

--- Normalizes this vector in place (modifies x and y).
--- Sets to (0,0) if length = 0.
--- @return Vec2 self (for chaining)
function Vec2:normalize()
  local len = self:length()
  if len == 0 then
    self.x, self.y = 0, 0
  else
    self.x, self.y = self.x / len, self.y / len
  end

  return self
end

--- Adds another vector to this one in place.
--- @param other Vec2
--- @return Vec2 self
function Vec2:add(other)
  self.x = self.x + other.x
  self.y = self.y + other.y
  return self
end

--- Subtracts another vector from this one in place.
--- @param other Vec2
--- @return Vec2 self
function Vec2:sub(other)
  self.x = self.x - other.x
  self.y = self.y - other.y
  return self
end

--- Scales this vector by a scalar in place.
--- @param s number
--- @return Vec2 self
function Vec2:scale(s)
  self.x = self.x * s
  self.y = self.y * s
  return self
end

--- Sets this vector’s components.
--- @param x number
--- @param y number
--- @return Vec2 self
function Vec2:set(x, y)
  self.x, self.y = x, y
  return self
end

--- Computes the dot product with another vector.
--- @param other Vec2
--- @return number
function Vec2:dot(other)
  return self.x * other.x + self.y * other.y
end

--- Returns a string representation of the vector.
--- @return string
function Vec2:__tostring()
  return string.format('Vec2(%.3f, %.3f)', self.x, self.y)
end

return Vec2
