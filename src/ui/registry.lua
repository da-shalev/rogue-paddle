local uid = 0

---@alias UiIdx number

---@class UiNode<T>: {
---  ctx: UiCtx<T>,
---  events: UiNodeEvents<T>,
--- }

---@class UiNodeEvents<T>: {
---  layout: (fun(self: UiCtx<T>): boolean),
---  update: fun(self: UiCtx<T>, dt: number)|nil,
---  remove: fun(self: UiCtx<T>)|nil,
---  draw: fun(self: UiCtx<T>)
---}

---@class UiCtx<T>: {
---   root?: UiIdx<T>,
---   parent?: UiIdx<T>,
---   idx: UiIdx<T>,
---   data: T,
---   box: Box,
---}

---@class UiRegistry: {
---   nodes: table<UiIdx, UiNode<any>>,
---}
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

  ---@type UiNode
  local node = {
    ctx = {
      root = nil,
      parent = nil,
      idx = uid,
      box = Box.zero(),
      data = data,
    },
    events = {
      update = e.update,
      draw = e.draw,
      remove = e.remove,
      layout = e.layout,
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
