---@class BoxDir
---@field top? number
---@field left? number
---@field bottom? number
---@field right? number
local BoxDir = {}

---@param a number # top (or all)
---@param b? number # right/left (or horizontal)
---@param c? number # bottom
---@param d? number # left
---@return BoxDir
function BoxDir.new(a, b, c, d)
  if b == nil then
    return { top = a, right = a, bottom = a, left = a }
  end

  if c == nil then
    return { top = a, right = b, bottom = a, left = b }
  end

  if d == nil then
    return { top = a, right = b, bottom = c, left = b }
  end

  return { top = a, right = b, bottom = c, left = d }
end

BoxDir.zero = BoxDir.new(0)

return BoxDir
