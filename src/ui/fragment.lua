---@alias TextVal string | number

---@class Fragment
---@field val? TextVal
---@field font love.Font
local Fragment = {}
Fragment.__index = Fragment

---@param font love.Font
---@param text TextVal
---@return number, number
local function getSize(font, text)
  return font:getWidth(text), font:getHeight()
end

---@param val? TextVal
---@param font? love.Font
---@return RegIdx
Fragment.new = function(val, font)
  ---@type Fragment
  local self = {
    val = val,
    font = font or love.graphics.getFont(),
  }

  return Ui.add(self, {
    draw = function(ctx)
      if self.val then
        love.graphics.printf(self.val, self.font, ctx.box.pos.x, ctx.box.pos.y, ctx.box.size.x)
      end
    end,
    size = function(ctx)
      if self.val then
        local w, h = getSize(self.font, self.val)
        ctx.box.w = w
        ctx.box.h = h
      end
    end,
  })
end

return Fragment
