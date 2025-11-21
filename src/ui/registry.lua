local uid = 0

---@alias UiIdx number
---@alias UiChildren UiIdx[]

---@alias UiLayoutEvent<T> fun(self: UiCtx<T>, parent?: UiLayout<T>): boolean
---@alias UiUpdateEvent<T> fun(self: UiCtx<T>, dt: number)?
---@alias UiRemoveEvent<T> fun(self: UiCtx<T>)?
---@alias UiDrawEvent<T> fun(self: UiCtx<T>)

---@class UiNode<T>: {
---  ctx: UiCtx<T>,
---  events: UiNodeEvents<T>,
--- }

---@class UiNodeEvents<T>: {
---  layout: UiLayoutEvent<T>,
---  update: UiUpdateEvent<T>,
---  remove: UiRemoveEvent<T>,
---  draw: UiDrawEvent<T>,
---}

---@class UiLayout<T>: {
---   root?: UiIdx<T>,
---   parent?: UiIdx<T>,
---   idx: UiIdx<T>,
---}

---@class UiCtx<T>: {
---   layout: UiLayout<T>,
---   data: T,
---   box: Box,
---}

---@class UiRegistry
---@field nodes table<UiIdx, UiNode<any>>
local UiRegistry = {}
UiRegistry.__index = UiRegistry

local registry = setmetatable({
  nodes = {},
}, UiRegistry)

---@generic T
---@param data T
---@param e UiNodeEvents<T>
---@return UiIdx
function UiRegistry:add(data, e)
  uid = uid + 1

  ---@generic T
  ---@type UiLayoutEvent<T>
  local layout = function(ctx, layout)
    if layout then
      ctx.layout.parent = layout.idx
      ctx.layout.root = layout.root
    else
      ctx.layout.root = ctx.layout.idx
    end

    return e.layout(ctx, layout)
  end

  ---@type UiNode
  local node = {
    ctx = {
      layout = {
        root = nil,
        parent = nil,
        idx = uid,
      },
      box = Box.zero(),
      data = data,
    },
    events = {
      update = e.update,
      draw = e.draw,
      remove = e.remove,
      layout = layout,
    },
  }

  self.nodes[uid] = node
  node.events.layout(node.ctx)

  return uid
end

---@generic T
---@param idx UiIdx<T>
---@return UiNode<T>?
function UiRegistry:get(idx)
  return self.nodes[idx]
end

---@generic T
---@param idx UiIdx<T>
---@return UiCtx<T>?
function UiRegistry:getCtx(idx)
  return self.nodes[idx].ctx
end

---@param idx UiIdx
function UiRegistry:remove(idx)
  local node = self:get(idx)
  if not node then
    return
  end

  if node.events.remove then
    node.events.remove(node.ctx)
  end

  self.nodes[idx] = nil
end

---@param idx UiIdx
---@return boolean
function UiRegistry:exists(idx)
  return self.nodes[idx] ~= nil
end

---@generic T
---@param node UiNode<T>?
---@param dt number
function UiRegistry:update(node, dt)
  if node and node.events.update then
    node.events.update(node.ctx, dt)
  end
end

---@generic T
---@param node UiNode<T>?
function UiRegistry:draw(node)
  if node then
    node.events.draw(node.ctx)
  end
end

return registry
