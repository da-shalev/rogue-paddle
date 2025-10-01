-- extention of math module to include good stuff

--- @param value number
--- @param min number
--- @param max number
--- @return number
function math.clamp(value, min, max)
  return math.max(min, math.min(max, value))
end
