local Box = {}
Box.__index = Box

--- @class Box
--- @field x number The x-coordinate
--- @field y number The y-coordinate
--- @field w number The width
--- @field h number The height
--- @field r number The rotation

--- Creates a box
--- @param x number The x-coordinate
--- @param y number The y-coordinate
--- @param w number The width
--- @param h number The height
--- @param r number The rotation, in degrees
--- @param starting_offset? Origin Offset origin. Defaults to Origin.top_left
--- @return Box
function Box.new(x, y, w, h, r, starting_offset)
  assert(type(x) == "number", "Box.new: x must be a number, got " .. type(x))
  assert(type(y) == "number", "Box.new: y must be a number, got " .. type(y))
  assert(type(w) == "number", "Box.new: width must be a number, got " .. type(w))
  assert(type(h) == "number", "Box.new: height must be a number, got " .. type(h))
  assert(type(r) == "number", "Box.new: rotation must be a number, got " .. type(r))

  starting_offset = starting_offset or Origin.top_left
  return setmetatable({
    x = x - starting_offset[1] * w,
    y = y - starting_offset[2] * h,
    w = w,
    h = h,
    r = r,
  }, Box)
end

--- Creates a box equal to the size of a image.
--- @param image love.Image The texture to get dimensions from.
--- @param x number The x-coordinate of the box's reference poin
--- @param y number The y-coordinate of the box's reference point
--- @param starting_offset? Origin Origin offset. Defaults to Origin.top_left
function Box.fromImage(image, x, y, r, starting_offset)
  return Box.new(x, y, image:getWidth(), image:getHeight(), r, starting_offset)
end

--- Draws the box dimensions as a rect.
---@param mode love.DrawMode # How to draw the rectangle.
function Box:drawRectangle(mode)
  love.graphics.rectangle(mode, self.x, self.y, self.w, self.h)
end

--- Draws the box dimensions as a image
--- @param image love.Image The texture to get dimensions from.
function Box:drawImage(image)
  love.graphics.draw(image, self.x, self.y, math.rad(self.r), self.w / image:getWidth(), self.h / image:getHeight())
end

return Box
