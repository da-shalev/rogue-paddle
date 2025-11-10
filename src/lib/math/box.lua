local alias = {
  x = {
    get = function(b)
      return b.pos.x
    end,
    set = function(b, v)
      b.pos.x = v
    end,
  },
  y = {
    get = function(b)
      return b.pos.y
    end,
    set = function(b, v)
      b.pos.y = v
    end,
  },
  w = {
    get = function(b)
      return b.size.x
    end,
    set = function(b, v)
      b.size.x = v
    end,
  },
  h = {
    get = function(b)
      return b.size.y
    end,
    set = function(b, v)
      b.size.y = v
    end,
  },
}

--- @class Box
--- @field x number -- alias to pos.x
--- @field y number -- alias to pos.y
--- @field w number -- alias to size.x
--- @field h number -- alias to size.y
--- @field pos Vec2
--- @field size Vec2
--- @field rot number
local Box = {}
Box.__index = function(t, k)
  local a = alias[k]
  if a then
    return a.get(t)
  else
    return Box[k]
  end
end

Box.__newindex = function(t, k, v)
  local a = alias[k]
  if a then
    a.set(t, v)
  else
    rawset(t, k, v)
  end
end

--- @param pos Vec2
--- @param size Vec2
--- @param rot? number
--- @param starting_offset? Vec2
--- @return Box
function Box.new(pos, size, rot, starting_offset)
  starting_offset = starting_offset or Origin.TOP_LEFT
  pos:subScaled(size, starting_offset)

  return setmetatable({
    pos = pos,
    size = size,
    rot = rot or 0,
  }, Box)
end

function Box.zero()
  return Box.new(math.vec2.zero(), math.vec2.zero(), 0, math.vec2.zero())
end

--- @param other Box
--- @return boolean xCollide
--- @return boolean yCollide
function Box:collides(other)
  return not (other.pos.x >= self.pos.x + self.size.x or other.pos.x + other.size.x <= self.pos.x),
    not (other.pos.y >= self.pos.y + self.size.y or other.pos.y + other.size.y <= self.pos.y)
end

--- @param other Box
--- @return boolean xWithin
--- @return boolean yWithin
function Box:within(other)
  return self.pos.x >= other.pos.x and self.pos.x + self.size.x <= other.pos.x + other.size.x,
    self.pos.y >= other.pos.y and self.pos.y + self.size.y <= other.pos.y + other.size.y
end

--- @param other Box
--- @return number xOverlap Percentage
--- @return number yOverlap Percentage
function Box:overlaps(other)
  return math.min(self.pos.x + self.size.x - other.pos.x, other.pos.x + other.size.x - self.pos.x),
    math.min(self.pos.y + self.size.y - other.pos.y, other.pos.y + other.size.y - self.pos.y)
end

--- @param prev Box Previous frame's box
--- @param current Box Current frame's box
--- @param alpha number Interpolation factor (0=prev, 1=current)
--- @return Box self This box (for chaining)
function Box:lerp(prev, current, alpha)
  self.pos = prev.pos:lerp(current.pos, alpha)
  self.size = prev.size:lerp(current.size, alpha)
  self.rot = math.lerp(prev.rot, current.rot, alpha)
  return self
end

--- Copies position and transform values from another box
--- @param source Box The box to copy values from
function Box:copy(source)
  self.pos:copy(source.pos)
  self.size:copy(source.size)
  self.rot = source.rot
end

--- @return string
function Box:__tostring()
  return string.format('Box(%.3f, %.3f, %.3f, %.3f)', self.x, self.y, self.w, self.h)
end

--- @param source Box
--- @param velocity Vec2
--- @return boolean
function Box:paddleCollision(source, velocity)
  local x_overlap, y_overlap = self:overlaps(source)

  if x_overlap > 0 and y_overlap > 0 then
    -- Smaller overlap = collision axis (less penetration)
    if y_overlap < x_overlap then
      -- Y-axis collision
      if source.y < self.y then
        -- Calculate hit position: -1 (left edge) to +1 (right edge)
        local hit_pos = (
          (source.x + source.w * 0.5) -- ball center x
          - (self.x + self.w * 0.5) -- self center x
        ) / (self.w * 0.5)

        velocity:set(hit_pos, -1):normalize()
      else
        -- Bottom of self - bounce downward
        velocity.y = math.abs(velocity.y)
      end

      source:clampOutsideY(self, true, true)
    else
      -- X-axis collision
      if source.x < self.x then
        velocity.x = -math.abs(velocity.x)
      else
        velocity.x = math.abs(velocity.x)
      end

      source:clampOutsideX(self, true, true)
    end

    return true
  end

  return false
end

local function clampValue(value, min, max, clampMin, clampMax)
  if clampMin and value < min then
    return min, true
  end
  if clampMax and value > max then
    return max, true
  end
  return value, false
end

--- @param other Box
--- @param left boolean
--- @param right boolean
--- @return boolean, boolean
function Box:clampWithinX(other, left, right)
  local minX = other.pos.x
  local maxX = other.pos.x + other.size.x - self.size.x

  local hitLeft = self.pos.x < minX
  local hitRight = self.pos.x > maxX

  self.pos.x = select(1, clampValue(self.pos.x, minX, maxX, left, right))
  return hitLeft, hitRight
end

--- @param other Box
--- @param top boolean
--- @param bottom boolean
--- @return boolean, boolean
function Box:clampWithinY(other, top, bottom)
  local minY = other.pos.y
  local maxY = other.pos.y + other.size.y - self.size.y

  local hitTop = self.pos.y < minY
  local hitBottom = self.pos.y > maxY

  self.pos.y = select(1, clampValue(self.pos.y, minY, maxY, top, bottom))
  return hitTop, hitBottom
end

--- @param other Box
--- @param top boolean
--- @param bottom boolean
--- @param left boolean
--- @param right boolean
--- @return boolean, boolean, boolean, boolean
function Box:clampWithin(other, top, bottom, left, right)
  local top, bottom = self:clampWithinY(other, top, bottom)
  local left, right = self:clampWithinX(other, left, right)
  return top, bottom, left, right
end

--- @param other Box
--- @param left boolean
--- @param right boolean
--- @return boolean, boolean
function Box:clampOutsideX(other, left, right)
  local otherLeft = other.pos.x
  local otherRight = other.pos.x + other.size.x
  local selfLeft = self.pos.x
  local selfRight = self.pos.x + self.size.x

  local hitLeft = selfRight > otherLeft and selfLeft < otherLeft
  local hitRight = selfLeft < otherRight and selfRight > otherRight

  if left and hitLeft then
    self.pos.x = otherLeft - self.size.x
  end
  if right and hitRight then
    self.pos.x = otherRight
  end

  return hitLeft, hitRight
end

--- @param other Box
--- @param top boolean
--- @param bottom boolean
--- @return boolean, boolean
function Box:clampOutsideY(other, top, bottom)
  local otherTop = other.pos.y
  local otherBottom = other.pos.y + other.size.y
  local selfTop = self.pos.y
  local selfBottom = self.pos.y + self.size.y

  local hitTop = selfBottom > otherTop and selfTop < otherTop
  local hitBottom = selfTop < otherBottom and selfBottom > otherBottom

  if top and hitTop then
    self.pos.y = otherTop - self.size.y
  end
  if bottom and hitBottom then
    self.pos.y = otherBottom
  end

  return hitTop, hitBottom
end

--- @param other Box
--- @param top boolean
--- @param bottom boolean
--- @param left boolean
--- @param right boolean
--- @return boolean, boolean, boolean, boolean
function Box:clampOutside(other, top, bottom, left, right)
  local top, bottom = self:clampOutsideY(other, top, bottom)
  local left, right = self:clampOutsideX(other, left, right)
  return top, bottom, left, right
end

return Box
