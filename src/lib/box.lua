---@class Box
---@field x number -- alias to pos.x
---@field y number -- alias to pos.y
---@field w number -- alias to size.x
---@field h number -- alias to size.y
---@field pos Vec2
---@field size Vec2
---@field rot number
local Box = {}

---@class ComputedExtend
---@field top number
---@field left number
---@field bottom number
---@field right number
local Extend = {}
Box.Extend = Extend

---@param t ComputedExtend
Extend.debugExtend = function(t)
  return string.format(
    'ComputedExtend(top=%s, left=%s, bottom=%s, right=%s)',
    t.top,
    t.left,
    t.bottom,
    t.right
  )
end

---@class ExtendBasis
---@field [1]? number  -- top (or all)
---@field [2]? number  -- right/left (or horizontal)
---@field [3]? number  -- bottom
---@field [4]? number  -- left

---@alias Extend ExtendBasis|number

---@param extend Extend
---@return ComputedExtend
function Extend.new(extend)
  if type(extend) == 'number' then
    return {
      top = extend,
      right = extend,
      bottom = extend,
      left = extend,
    }
  else
    return {
      top = extend[1] or 0,
      right = extend[2] or extend[1] or 0,
      bottom = extend[3] or extend[1] or 0,
      left = extend[4] or extend[2] or extend[1] or 0,
    }
  end
end

---@param extend ComputedExtend
---@param e Extend
function Extend.add(extend, e)
  local e = Extend.new(e)
  extend.top = extend.top + e.top
  extend.left = extend.left + e.left
  extend.right = extend.right + e.right
  extend.bottom = extend.bottom + e.bottom
end

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

---@class BoxOpts
---@field pos Vec2
---@field size Vec2
---@field starting_origin? Vec2
---@field rot? number

---@param opts BoxOpts
---@return Box
function Box.from(opts)
  return Box.new(opts.pos, opts.size, opts.rot, opts.starting_origin)
end

---@param pos Vec2
---@param size Vec2
---@param rot? number
---@param starting_origin? Vec2
---@return Box
function Box.new(pos, size, rot, starting_origin)
  pos = pos - (size * (starting_origin or Origin.TOP_LEFT))

  return setmetatable({
    pos = pos,
    size = size,
    rot = rot or 0,
  }, Box)
end

function Box.zero()
  return Box.new(Vec2.zero(), Vec2.zero(), 0, Vec2.zero())
end

---@param other Box
---@return boolean xCollide
---@return boolean yCollide
function Box:collides(other)
  return not (other.pos.x >= self.pos.x + self.size.x or other.pos.x + other.size.x <= self.pos.x),
    not (other.pos.y >= self.pos.y + self.size.y or other.pos.y + other.size.y <= self.pos.y)
end

---@param other Box
---@return boolean xWithin
---@return boolean yWithin
function Box:within(other)
  return self.pos.x >= other.pos.x and self.pos.x + self.size.x <= other.pos.x + other.size.x,
    self.pos.y >= other.pos.y and self.pos.y + self.size.y <= other.pos.y + other.size.y
end

---@param other Box
---@return number xOverlap Percentage
---@return number yOverlap Percentage
function Box:overlaps(other)
  return math.min(self.pos.x + self.size.x - other.pos.x, other.pos.x + other.size.x - self.pos.x),
    math.min(self.pos.y + self.size.y - other.pos.y, other.pos.y + other.size.y - self.pos.y)
end

---@param prev Box Previous frame's box
---@param current Box Current frame's box
---@param alpha number Interpolation factor (0=prev, 1=current)
---@return Box self
function Box:lerp(prev, current, alpha)
  self.pos = prev.pos:lerp(current.pos, alpha)
  self.size = prev.size:lerp(current.size, alpha)
  self.rot = math.lerp(prev.rot, current.rot, alpha)
  return self
end

---@param source Box
---@param velocity Vec2
---@return boolean
function Box:paddleOnCollision(source, velocity)
  local x_overlap, y_overlap = self:overlaps(source)

  if x_overlap <= 0 or y_overlap <= 0 then
    return false
  end

  -- Smaller overlap = collision axis (less penetration)
  if y_overlap < x_overlap then
    -- Y-axis collision
    if source.y < self.y then
      -- Calculate hit position: -1 (left edge) to +1 (right edge)
      local hit_pos = (
        (source.x + source.w * 0.5) -- ball center x
        - (self.x + self.w * 0.5) -- paddle center x
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

---@param starting_origin? Vec2
function Box:setPos(pos, starting_origin)
  self.pos = pos - self.size * (starting_origin or Origin.TOP_LEFT)
end

---@param origin Vec2
---@return Vec2
function Box:getOriginPos(origin)
  return self.pos:clone() + self.size * origin
end

---@param value number
---@param min number
---@param max number
---@param clampMin boolean
---@param clampMax boolean
---@return number, boolean
local function clampValue(value, min, max, clampMin, clampMax)
  if clampMin and value < min then
    return min, true
  end
  if clampMax and value > max then
    return max, true
  end
  return value, false
end

---@param other Box
---@param left boolean
---@param right boolean
---@return boolean, boolean
function Box:clampWithinX(other, left, right)
  local hitLeft = self.pos.x < other.pos.x
  local hitRight = self.pos.x > other.pos.x + other.size.x - self.size.x

  self.pos.x =
    clampValue(self.pos.x, other.pos.x, other.pos.x + other.size.x - self.size.x, left, right)
  return hitLeft, hitRight
end

---@param other Box
---@param top boolean
---@param bottom boolean
---@return boolean, boolean
function Box:clampWithinY(other, top, bottom)
  local hitTop = self.pos.y < other.pos.y
  local hitBottom = self.pos.y > other.pos.y + other.size.y - self.size.y

  self.pos.y =
    clampValue(self.pos.y, other.pos.y, other.pos.y + other.size.y - self.size.y, top, bottom)
  return hitTop, hitBottom
end

---@param other Box
---@param top boolean
---@param bottom boolean
---@param left boolean
---@param right boolean
---@return boolean, boolean, boolean, boolean
function Box:clampWithin(other, top, bottom, left, right)
  local top, bottom = self:clampWithinY(other, top, bottom)
  local left, right = self:clampWithinX(other, left, right)
  return top, bottom, left, right
end

---@param other Box
---@param left boolean
---@param right boolean
---@return boolean, boolean
function Box:clampOutsideX(other, left, right)
  local hitLeft = self.pos.x + self.size.x > other.pos.x and self.pos.x < other.pos.x
  local hitRight = self.pos.x < other.pos.x + other.size.x
    and self.pos.x + self.size.x > other.pos.x + other.size.x

  if hitLeft and left then
    self.pos.x = other.pos.x - self.size.x
  end
  if hitRight and right then
    self.pos.x = other.pos.x + other.size.x
  end

  return hitLeft, hitRight
end

---@param other Box
---@param top boolean
---@param bottom boolean
---@return boolean, boolean
function Box:clampOutsideY(other, top, bottom)
  local hitTop = self.pos.y + self.size.y > other.pos.y and self.pos.y < other.pos.y
  local hitBottom = self.pos.y < other.pos.y + other.size.y
    and self.pos.y + self.size.y > other.pos.y + other.size.y

  if hitTop and top then
    self.pos.y = other.pos.y - self.size.y
  end
  if hitBottom and bottom then
    self.pos.y = other.pos.y + other.size.y
  end

  return hitTop, hitBottom
end

---@param other Box
---@param top boolean
---@param bottom boolean
---@param left boolean
---@param right boolean
---@return boolean, boolean, boolean, boolean
function Box:clampOutside(other, top, bottom, left, right)
  local top, bottom = self:clampOutsideY(other, top, bottom)
  local left, right = self:clampOutsideX(other, left, right)
  return top, bottom, left, right
end

--- Copies position and transform values from another box
---@param source Box The box to copy values from
function Box:copy(source)
  self.pos:copy(source.pos)
  self.size:copy(source.size)
  self.rot = source.rot
end

function Box:clone()
  return Box.new(self.pos:clone(), self.size:clone(), self.rot)
end

---@return string
function Box:__tostring()
  return string.format('Box(%.3f, %.3f, %.3f, %.3f)', self.x, self.y, self.w, self.h)
end

return Box
