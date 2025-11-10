---@class Origin
local Origin = {
  TOP_LEFT = math.vec2.new(0, 0),
  TOP_CENTER = math.vec2.new(0.5, 0),
  TOP_RIGHT = math.vec2.new(1, 0),
  LEFT = math.vec2.new(0, 0.5),
  CENTER = math.vec2.new(0.5, 0.5),
  RIGHT = math.vec2.new(1, 0.5),
  BOTTOM_LEFT = math.vec2.new(0, 1),
  BOTTOM_CENTER = math.vec2.new(0.5, 1),
  BOTTOM_RIGHT = math.vec2.new(1, 1),
}

return Origin
