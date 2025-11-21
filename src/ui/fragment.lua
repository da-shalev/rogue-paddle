---@class UiFragment
---@field val? string
---@field font love.Font
local Fragment = {}
Fragment.__index = Fragment

---@param font love.Font
---@param text string
---@return number, number
local function getSize(font, text)
  return font:getWidth(text), font:getHeight()
end

---@param val? string
---@param font? love.Font
---@return UiIdx
Fragment.new = function(val, font)
  local font = font or love.graphics.getFont()

  ---@type UiFragment
  local self = {
    val = val,
    font = font,
  }

  return UiRegistry.add(self, {
    draw = function(ctx)
      if self.val then
        love.graphics.printf(self.val, self.font, ctx.box.pos.x, ctx.box.pos.y, ctx.box.size.x)
      end
    end,
    layout = function(ctx)
      local w, h = getSize(self.font, self.val)
      ctx.box.w = w
      ctx.box.h = h
      return true
    end,
  })
end

return Fragment
