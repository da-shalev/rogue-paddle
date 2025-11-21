local uid = 0

---@alias UiIdx number
---@alias UiChildren UiIdx[]

---@alias UiLayoutEvent fun(ctx: UiCtx, parent?: UiLayout): boolean
---@alias UiUpdateEvent fun(ctx: UiCtx, dt: number)
---@alias UiRemoveEvent fun(ctx: UiCtx)
---@alias UiDrawEvent fun(ctx: UiCtx)

---@alias UiLayout { root?: UiIdx, parent?: UiIdx, idx: UiIdx }

---@class UiNodeEvents
---@field layout UiLayoutEvent
---@field update UiUpdateEvent
---@field remove UiRemoveEvent
---@field draw UiDrawEvent

---@class UiCtx
---@field layout UiLayout
---@field box Box

---@alias UiNode<T> {
---  data: T,
---  ctx: UiCtx,
---  events: UiNodeEvents,
---}

local UiRegistry = {}

---@type table<UiIdx, UiNode<any>>
local nodes = {}

---@generic T
---@param data T
---@param e UiNodeEvents
---@return UiIdx
function UiRegistry.add(data, e)
  uid = uid + 1

  ---@type UiLayoutEvent
  local layout = function(ctx, parent)
    if parent then
      ctx.layout.parent = parent.idx
      ctx.layout.root = parent.root
    else
      ctx.layout.root = ctx.layout.idx
    end
    return e.layout(ctx, parent)
  end

  ---@generic T
  ---@type UiNode<T>
  local node = {
    data = data,
    ctx = {
      layout = { root = nil, parent = nil, idx = uid },
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

  nodes[uid] = node
  node.events.layout(node.ctx)
  return uid
end

---@param idx UiIdx
function UiRegistry.get(idx)
  return nodes[idx]
end

---@param idx UiIdx
function UiRegistry.getData(idx)
  return nodes[idx].data
end

---@param idx UiIdx
---@return UiCtx?
function UiRegistry.getCtx(idx)
  return nodes[idx].ctx
end

---@param idx UiIdx
function UiRegistry.remove(idx)
  local node = UiRegistry.get(idx)
  if not node then
    return
  end

  if node.events.remove then
    node.events.remove(node.ctx)
  end

  nodes[idx] = nil
end

---@param idx UiIdx
---@return boolean
function UiRegistry.exists(idx)
  return nodes[idx] ~= nil
end

---@generic T
---@param node UiNode<T>?
---@param dt number
function UiRegistry.update(node, dt)
  if node and node.events.update then
    node.events.update(node.ctx, dt)
  end
end

---@generic T
---@param node UiNode<T>?
function UiRegistry.draw(node)
  if node then
    node.events.draw(node.ctx)
  end
end

return UiRegistry
