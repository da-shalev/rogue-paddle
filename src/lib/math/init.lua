-- Extension of the math module to include extra utils

--- @param value number
--- @param min number
--- @param max number
--- @return number
function math.clamp(value, min, max)
  return math.max(min, math.min(max, value))
end

--- Linear interpolation between two values
--- @param a number Start value
--- @param b number End value
--- @param t number Interpolation factor (0=return a, 1=return b)
--- @return number Interpolated value
function math.lerp(a, b, t)
  return a + (b - a) * t
end

math.vec2 = require('lib.math.vec2')
math.box = require('lib.math.box')
