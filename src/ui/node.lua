local UiNode = {}

---@class UiNodeEvents
---@field layout fun(ctx: UiCtx, parent?: UiCtx): boolean
---@field update? fun(ctx: UiCtx, dt: number)
---@field remove? fun(ctx: UiCtx)
---@field draw fun(ctx: UiCtx)

---@class UiCtx
---@field root? UiIdx
---@field parent? UiIdx
---@field idx UiIdx
---@field box Box

---@class UiNode
---@field ctx UiCtx
---@field events UiNodeEvents

---@param e UiNodeEvents
---@return UiNode
function UiNode.new(e)
  ---@type UiNode
  return {
    ctx = {
      root = nil,
      parent = nil,
      idx = 0,
      box = Box.zero(),
    },
    events = {
      update = e.update,
      draw = e.draw,
      remove = e.remove,
      layout = function(self, parent)
        UiNode.layout(self, parent)
        return e.layout(self, parent)
      end,
    },
  }
end

---@param self UiCtx
---@param parent? UiCtx
function UiNode.layout(self, parent)
  if parent then
    self.parent = parent.idx
    self.root = parent.root
  else
    self.root = self.idx
  end

  -- local parent = UiRegistry:get(self.status.parent)
  -- if parent then
  --   self.events.layout(parent)
  -- else
  --   self.status.parent = nil
  -- end
  --
  -- local root = UiRegistry:get(self.root)
  -- if root then
  --   if root.idx ~= self.idx then
  --     root.layout()
  --   end
  -- else
  --   self.root = self.idx
  -- end
end

return UiNode
