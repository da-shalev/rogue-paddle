local UiNode = require 'ui.node'

---@class UiFragement
---@field val? string
---@field font love.Font
local Fragment = {}

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

  ---@type UiFragement
  local self = {
    val = val,
    font = font,
  }

  local node = UiNode.new {
    draw = function(ctx)
      if self.val then
        love.graphics.printf(self.val, self.font, ctx.box.pos.x, ctx.box.pos.y, ctx.box.size.x)
      end
    end,
    remove = function() end,
    layout = function(ctx)
      local w, h = getSize(self.font, self.val)
      ctx.box.w = w
      ctx.box.h = h
      return true
    end,
  }

  return UiRegistry:add(node)
end

return Fragment
