---@class Vec2
---@field x number The x-component
---@field y number The y-component
---@operator unm: Vec2
local Vec2 = {}
Vec2.__index = Vec2

--- Creates a new vector
---@param x number
---@param y number
---@return Vec2
function Vec2.new(x, y)
  assert(type(x) == 'number', 'Vec2.new: x must be a number, got ' .. type(x))
  assert(type(y) == 'number', 'Vec2.new: y must be a number, got ' .. type(y))
  return setmetatable({ x = x, y = y }, Vec2)
end

---@param size number
---@return Vec2
function Vec2.splat(size)
  assert(type(size) == 'number', 'Vec2.splat: size must be a number, got ' .. type(size))
  return setmetatable({ x = size, y = size }, Vec2)
end

function Vec2.zero()
  return Vec2.new(0, 0)
end

--- Returns the length (magnitude) of this vector
---@return number
function Vec2:length()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

--- Normalizes this vector in place (modifies x and y).
--- Sets to (0,0) if length = 0.
---@return Vec2 self (for chaining)
function Vec2:normalize()
  local len = self:length()
  if len == 0 then
    self.x, self.y = 0, 0
  else
    self.x, self.y = self.x / len, self.y / len
  end

  return self
end

-- massively inefficent shorthands

---@param a Vec2
---@return Vec2
function Vec2.__unm(a)
  return Vec2.new(-a.x, -a.y)
end

---@param a Vec2
---@param b Vec2
---@return Vec2
function Vec2.__add(a, b)
  return Vec2.new(a.x + b.x, a.y + b.y)
end

---@param a Vec2
---@param b Vec2
---@return Vec2
function Vec2.__sub(a, b)
  return Vec2.new(a.x - b.x, a.y - b.y)
end

---@param a Vec2 | number
---@param b Vec2 | number
---@return Vec2
function Vec2.__mul(a, b)
  if type(b) == 'number' then
    return Vec2.new(a.x * b, a.y * b)
  elseif type(a) == 'number' then
    return Vec2.new(a * b.x, a * b.y)
  else
    return Vec2.new(a.x * b.x, a.y * b.y)
  end
end

---@param a Vec2 | number
---@param b Vec2 | number
---@return Vec2
function Vec2.__div(a, b)
  if type(b) == 'number' then
    return Vec2.new(a.x / b, a.y / b)
  elseif type(a) == 'number' then
    return Vec2.new(a / b.x, a / b.y)
  else
    return Vec2.new(a.x / b.x, a.y / b.y)
  end
end

--- Sets this vector’s components.
---@param x? number
---@param y? number
---@return Vec2 self
function Vec2:set(x, y)
  self.x, self.y = x or 0, y or 0
  return self
end

--- Computes the dot product with another vector.
---@param other Vec2
---@return number
function Vec2:dot(other)
  return self.x * other.x + self.y * other.y
end

--- Linearly interpolates this vector towards another vector in place.
---@param other Vec2
---@param alpha number
---@return Vec2 self
function Vec2:lerp(other, alpha)
  self.x = math.lerp(self.x, other.x, alpha)
  self.y = math.lerp(self.y, other.y, alpha)
  return self
end

--- Copies another vector's components to this vector.
---@param other Vec2
---@return Vec2 self
function Vec2:copy(other)
  self.x = other.x
  self.y = other.y
  return self
end

---@return Vec2
function Vec2:clone()
  return Vec2.new(self.x, self.y)
end

--- Returns a string representation of the vector.
---@return string
function Vec2:__tostring()
  return string.format('Vec2(%.3f, %.3f)', self.x, self.y)
end

return Vec2
