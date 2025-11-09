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
--- @param starting_offset? Origin Offset origin. Defaults to `Origin.TOP_LEFT`
--- @return Box
function Box.new(pos, size, rot, starting_offset)
  starting_offset = starting_offset or Origin.TOP_LEFT
  pos.x = pos.x - starting_offset[1] * size.x
  pos.y = pos.y - starting_offset[2] * size.y

  return setmetatable({
    pos = pos,
    size = size,
    rot = rot or 0,
  }, Box)
end

function Box.zero()
  return Box.new(math.vec2.zero(), math.vec2.zero(), 0, { 0, 0 })
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

--- @param other Box
function Box:clampOutsideX(other)
  self.pos.x = self.pos.x < other.pos.x and other.pos.x - self.size.x or other.pos.x + other.size.x
end

--- @param other Box
function Box:clampOutsideY(other)
  self.pos.y = self.pos.y < other.pos.y and other.pos.y - self.size.y or other.pos.y + other.size.y
end

--- @param other Box
function Box:clampOutside(other)
  self:clampOutsideX(other)
  self:clampOutsideY(other)
end

--- @param other Box
function Box:clampWithinX(other)
  self.pos.x = math.clamp(self.pos.x, other.pos.x, other.pos.x + other.size.x - self.size.x)
end

--- @param other Box
function Box:clampWithinY(other)
  self.pos.y = math.clamp(self.pos.y, other.pos.y, other.pos.y + other.size.y - self.size.y)
end

--- @param other Box
function Box:clampWithin(other)
  self:clampWithinX(other)
  self:clampWithinY(other)
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

--- @param other Box
--- @param velocity Vec2
function Box:paddle(other, velocity)
  local x_overlap, y_overlap = self:overlaps(other)

  if x_overlap > 0 and y_overlap > 0 then
    -- Smaller overlap = collision axis (less penetration)
    if y_overlap < x_overlap then
      -- Y-axis collision
      if other.y < self.y then
        -- Calculate hit position: -1 (left edge) to +1 (right edge)
        local hit_pos = (
          (other.x + other.w * 0.5) -- ball center x
          - (self.x + self.w * 0.5) -- self center x
        ) / (self.w * 0.5)

        velocity:set(hit_pos, -1):normalize()
      else
        -- Bottom of self - bounce downward
        velocity.y = math.abs(velocity.y)
      end

      other:clampOutsideY(self)
    else
      -- X-axis collision
      if other.x < self.x then
        velocity.x = -math.abs(velocity.x)
      else
        velocity.x = math.abs(velocity.x)
      end

      other:clampOutsideX(self)
    end
  end
end

return Box
