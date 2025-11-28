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
  if val == nil then
    return 0, 0
  end

  return font:getWidth(val), font:getHeight()
end

---@class FragmentBuilder
---@field val Cell<TextAccepted>
---@field font? TextFont
---@field status? UiStatus

---@param build FragmentBuilder
---@return RegIdx
Fragment.new = function(build)
  ---@type Fragment
  local self = {
    font = build.font or love.graphics.getFont(),
    val = build.val,
  }

  local function layout()
    local node = Ui.get(self.node)
    if node then
      Ui.layout(node, node.state.parent, true)
    end
  end

  local r = Reactive.fromState(self.val)
  print(r)
  if r then
    print 'helloo'
    r.subscribe(layout)
  end

  return Ui.add(self, {
    status = build.status,
    events = {
      draw = function(ctx)
        local val = self.val.get()
        if val then
          love.graphics.printf(val, self.font, ctx.box.pos.x, ctx.box.pos.y, ctx.box.size.x)
        end
      end,
      size = function(ctx)
        local val = self.val.get()
        if val then
          local w, h = getSize(val, self.font)
          ctx.box.w = w
          ctx.box.h = h
        end
      end,
    },
  })
end

return Fragment
