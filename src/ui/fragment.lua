local Ui = require 'ui.registry'

---@alias TextAccepted string | number | nil
---@alias TextFont love.Font

---@class Fragment : UiType
---@field val Cell<TextAccepted>
---@field font TextFont
local Fragment = {}
Fragment.__index = Fragment

---@param font love.Font
---@param val TextAccepted
---@return number, number
local function getSize(val, font)
  if not val then
    return 0, 0
  end

  return font:getWidth(val), font:getHeight()
end

---@class FragmentBuilder
---@field val Cell<TextAccepted>|TextAccepted
---@field font? TextFont
---@field state? UiState

---@param build FragmentBuilder
---@return UiId<Fragment>
Fragment.new = function(build)
  ---@type Fragment
  local self = {
    font = build.font or love.graphics.getFont(),
    val = Cell.optional(build.val) --[[@as Cell<TextAccepted>]],
  }

  local reactiveVal = Reactive.fromState(self.val)
  if reactiveVal then
    reactiveVal.subscribe(function()
      local node = Ui.get(self.node)
      if node then
        Ui.layout(node, node.view.parent, true)
      end
    end)
  end

  return Ui.add(self, {
    status = build.state,
    events = {
      draw = function(view)
        local val = self.val.get()
        if val then
          love.graphics.printf(val, self.font, view.box.pos.x, view.box.pos.y, view.box.size.x)
        end
      end,
      size = function(view)
        local w, h = getSize(self.val.get(), self.font)
        view.box.w = w
        view.box.h = h
      end,
    },
  })
end

return Fragment
