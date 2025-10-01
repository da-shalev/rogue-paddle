--- @class Box
--- @field x number The x-coordinate
--- @field y number The y-coordinate
--- @field w number The width
--- @field h number The height
--- @field r number The rotation, in degrees
local Box = {}
Box.__index = Box

--- Creates a box
--- @param x number The x-coordinate
--- @param y number The y-coordinate
--- @param w number The width
--- @param h number The height
--- @param r? number The rotation, in degrees
--- @param starting_offset? Origin Offset origin. Defaults to `Origin.TOP_LEFT`
--- @return Box
function Box.new(x, y, w, h, r, starting_offset)
  assert(type(x) == 'number', 'Box.new: x must be a number, got ' .. type(x))
  assert(type(y) == 'number', 'Box.new: y must be a number, got ' .. type(y))
  assert(type(w) == 'number', 'Box.new: width must be a number, got ' .. type(w))
  assert(type(h) == 'number', 'Box.new: height must be a number, got ' .. type(h))

  starting_offset = starting_offset or Origin.TOP_LEFT
  return setmetatable({
    x = x - starting_offset[1] * w,
    y = y - starting_offset[2] * h,
    w = w,
    h = h,
    r = r or 0,
  }, Box)
end

--- Creates a box equal to the size of a image.
--- @param image love.Image The texture to get dimensions from.
--- @param x number The x-coordinate of the box's reference poin
--- @param y number The y-coordinate of the box's reference point
--- @param r? number The rotation, in degrees
--- @param starting_offset? Origin offset. Defaults to Origin.TOP_LEFT
--- @return Box
function Box.fromImage(image, x, y, r, starting_offset)
  return Box.new(x, y, image:getWidth(), image:getHeight(), r, starting_offset)
end

--- Draws the box dimensions as a rect.
--- @param mode love.DrawMode # How to draw the rectangle.
--- @param color? Color # The color of the rectangle
function Box:drawRectangle(mode, color)
  assert(
    mode == 'fill' or mode == 'line',
    ('Did not specifiy valid mode to drawRectangle, got %s'):format(mode)
  )

  -- ensure color is reset to white, inheriting previous color state is confusing
  love.graphics.setColor(color or Res.colors.RESET)
  love.graphics.rectangle(mode, self.x, self.y, self.w, self.h, math.rad(self.r))
end

--- Draws the box dimensions as a image
--- @param image love.Image The texture to get dimensions from.
--- @param color? Color # The color of the rectangle
function Box:drawImage(image, color)
  -- ensure color is reset to white, inheriting previous color state is confusing
  love.graphics.setColor(color or Res.colors.RESET)
  love.graphics.draw(
    image,
    self.x,
    self.y,
    math.rad(self.r),
    self.w / image:getWidth(),
    self.h / image:getHeight()
  )
end

--- Checks this box against another and returns collision state for both axes
--- @param other Box The other box to check against
--- @return boolean xCollide Collision on X axis
--- @return boolean yCollide Collision on Y axis
function Box:collides(other)
  Box:_validate(self)
  Box:_validate(other)

  return not (other.x >= self.x + self.w or other.x + other.w <= self.x),
    not (other.y >= self.y + self.h or other.y + other.h <= self.y)
end

--- Checks if this box is within another and returns containment state for both axes
--- @param other Box The other box to check containment in
--- @return boolean xWithin Within on X axis
--- @return boolean yWithin Within on Y axis
function Box:within(other)
  Box:_validate(self)
  Box:_validate(other)

  return self.x >= other.x and self.x + self.w <= other.x + other.w,
    self.y >= other.y and self.y + self.h <= other.y + other.h
end

--- Determines which axis had the primary collision with another box
--- based on penetration depth (less overlap = collision axis)
--- @param other Box The other box
--- @return number xWithin Percentage within on X axis
--- @return number yWithin Percentage within on Y axis
function Box:overlaps(other)
  Box:_validate(self)
  Box:_validate(other)

  local overlapX = math.min(self.x + self.w - other.x, other.x + other.w - self.x)
  local overlapY = math.min(self.y + self.h - other.y, other.y + other.h - self.y)

  return overlapX, overlapY
end

--- Clamps this box outside another box on X axis
--- @param other Box The box to clamp outside of
function Box:clampOutsideX(other)
  Box:_validate(other)
  self.x = self.x < other.x and other.x - self.w or other.x + other.w
end

--- Clamps this box outside another box on Y axis
--- @param other Box The box to clamp outside of
function Box:clampOutsideY(other)
  Box:_validate(other)
  self.y = self.y < other.y and other.y - self.h or other.y + other.h
end

--- Clamps this box outside another box on both axes
--- @param other Box The box to clamp inside of
function Box:clampOutside(other)
  Box:_validate(other)
  self:clampOutsideX(other)
  self:clampOutsideY(other)
end

--- Clamps this box inside another box on X axis
--- @param other Box The box to clamp inside of
function Box:clampWithinX(other)
  Box:_validate(other)
  self.x = math.clamp(self.x, other.x, other.x + other.w - self.w)
end

--- Clamps this box inside another box on Y axis
--- @param other Box The box to clamp inside of
function Box:clampWithinY(other)
  Box:_validate(other)
  self.y = math.clamp(self.y, other.y, other.y + other.h - self.h)
end

--- Clamps this box inside another box on both axes
--- @param other Box The box to clamp inside of
function Box:clampWithin(other)
  Box:_validate(other)
  self:clampWithinX(other)
  self:clampWithinY(other)
end

--- Updates this box with interpolated values (chainable)
--- @param prev Box Previous frame's box
--- @param current Box Current frame's box
--- @param alpha number Interpolation factor (0=prev, 1=current)
--- @return Box self This box (for chaining)
function Box:interpolate(prev, current, alpha)
  Box:_validate(prev)
  Box:_validate(current)
  self.x = math.lerp(prev.x, current.x, alpha)
  self.y = math.lerp(prev.y, current.y, alpha)
  self.r = math.lerp(prev.r, current.r, alpha)
  self.w = math.lerp(prev.w, current.w, alpha)
  self.h = math.lerp(prev.h, current.h, alpha)
  return self
end

--- Copies position and transform values from another box
--- @param source Box The box to copy values from
function Box:copy(source)
  Box:_validate(source)
  self.x = source.x
  self.y = source.y
  self.w = source.w
  self.h = source.h
  self.r = source.r
end

--- Asserts that this box is valid
--- @param box Box Box to validate
function Box:_validate(box)
  assert(
    box.w > 0 and box.h > 0,
    string.format(
      'Box invalid: x=%.2f, y=%.2f, w=%.2f, h=%.2f (w and h must be > 0)',
      box.x,
      box.y,
      box.w,
      box.h
    )
  )
end

return Box
