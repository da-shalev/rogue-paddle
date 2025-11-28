local Ui = require 'ui.registry'

---@alias AcceptedVals string | number | nil
---@alias TextVal AcceptedVals | Reactive<AcceptedVals>
---@alias TextFont love.Font | Reactive<love.Font>

---@class Fragment : UiType
---@field val TextVal
---@field font TextFont
local Fragment = {}
Fragment.__index = Fragment

---@param font love.Font
---@param val AcceptedVals
---@return number, number
local function getSize(font, val)
  if val == nil then
    return 0, 0
  end

  return font:getWidth(val), font:getHeight()
end

---@class FragmentBuilder
---@field val TextVal
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

  local val = Reactive.get(self.val)
  ---@cast val AcceptedVals
  local font = Reactive.get(self.font)
  ---@cast font love.Font

  local function layout()
    val = Reactive.get(self.val)
    font = Reactive.get(self.font)

    local node = Ui.get(self.node)
    if node then
      Ui.layout(node, node.state.parent, true)
    end
  end

  if Reactive.is(self.val) then
    self.val.subscribe(layout)
  end

  if Reactive.is(self.font) then
    self.font.subscribe(layout)
  end

  return Ui.add(self, {
    status = build.status,
    events = {
      draw = function(ctx)
        if val then
          love.graphics.printf(val, font, ctx.box.pos.x, ctx.box.pos.y, ctx.box.size.x)
        end
      end,
      size = function(ctx)
        if val then
          local w, h = getSize(font, val)
          ctx.box.w = w
          ctx.box.h = h
        end
      end,
    },
  })
end

return Fragment
