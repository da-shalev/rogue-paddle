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
--- @param starting_offset? Origin Offset origin. Defaults to Origin.TOP_LEFT
--- @return Box
function Box.new(x, y, w, h, r, starting_offset)
  assert(type(x) == "number", "Box.new: x must be a number, got " .. type(x))
  assert(type(y) == "number", "Box.new: y must be a number, got " .. type(y))
  assert(type(w) == "number", "Box.new: width must be a number, got " .. type(w))
  assert(type(h) == "number", "Box.new: height must be a number, got " .. type(h))

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
--- @param starting_offset? Origin Origin offset. Defaults to Origin.top_left
--- @return Box
function Box.fromImage(image, x, y, r, starting_offset)
  return Box.new(x, y, image:getWidth(), image:getHeight(), r, starting_offset)
end

--- Draws the box dimensions as a rect.
--- @param mode love.DrawMode # How to draw the rectangle.
--- @param color? Color # The color of the rectangle
function Box:drawRectangle(mode, color)
  assert(
    mode == "fill" or mode == "line",
    ("Did not specifiy valid mode to drawRectangle, got %s"):format(mode)
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
  love.graphics.draw(image, self.x, self.y, math.rad(self.r), self.w / image:getWidth(), self.h / image:getHeight())
end

--- Checks if this box collides with another box on the X axis
--- @param other Box The other box to check collision with
--- @return boolean
function Box:collidesX(other)
  return not (
    other.x >= self.x + self.w or
    other.x + other.w <= self.x
  )
end

--- Checks this box against another and returns collision state for both axes
--- @param other Box the other box to check against
--- @return boolean xCollide collision on X axis
--- @return boolean yCollide collision on Y axis
function Box:collidesAxes(other)
  return not (other.x >= self.x + self.w or other.x + other.w <= self.x),
      not (other.y >= self.y + self.h or other.y + other.h <= self.y)
end

--- Checks if this box is within another and returns containment state for both axes
--- @param other Box the other box to check containment in
--- @return boolean xWithin within on X axis
--- @return boolean yWithin within on Y axis
function Box:withinAxes(other)
  return self.x >= other.x and self.x + self.w <= other.x + other.w,
      self.y >= other.y and self.y + self.h <= other.y + other.h
end

return Box
