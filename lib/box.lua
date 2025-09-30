local Box = {}
Box.__index = Box

--- @class Box
--- @field x number The x-coordinate
--- @field y number The y-coordinate
--- @field w number The width
--- @field h number The height

--- Creates a box
--- @param x number The x-coordinate
--- @param y number The y-coordinate
--- @param w number The width
--- @param h number The height
--- @param starting_offset Origin|nil Offset origin. Defaults to Origin.top_left
--- @return Box
function Box.new(x, y, w, h, starting_offset)
  starting_offset = starting_offset or Origin.top_left
  return setmetatable({
    x = x - starting_offset[1] * w,
    y = y - starting_offset[2] * h,
    w = w,
    h = h,
  }, Box)
end

--- Creates a box equal to the size of a image.
--- @param image love.Image The texture to get dimensions from.
--- @param x number The x-coordinate of the box's reference poin
--- @param y number The y-coordinate of the box's reference point
--- @param origin Origin|nil Origin offset. Defaults to Origin.top_left
function Box.fromImage(image, x, y, origin)
  return Box.new(x, y, image:getWidth(), image:getHeight(), origin)
end

--- Draws the box dimensions as a rect.
---@param mode love.DrawMode # How to draw the rectangle.
function Box:drawRectangle(mode)
  love.graphics.rectangle(mode, self.x, self.y, self.w, self.h)
end

--- Draws the box as a image
--- @param image love.Image The texture to get dimensions from.
function Box:drawImage(image)
  love.graphics.draw(image, self.x, self.y, 0, self.w / image:getWidth(), self.h / image:getHeight())
end

return Box
