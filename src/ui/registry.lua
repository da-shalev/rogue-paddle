---@class RegIdx
---@field idx integer -- the index in the registry
---@field uid integer -- the registries uid

---@alias UiChildren RegIdx[]

--TODO: UiLayoutEvent returns boolean on mutation

---@alias UiLayoutEvent fun(state: UiState, parent?: RegIdx, propagate?: boolean)
---@alias UiUpdateEvent fun(state: UiState, dt: number)
---@alias UiRemoveEvent fun(state: UiState)
---@alias UiDrawEvent fun(state: UiState)

---@class UiType
---@field node? RegIdx

---@class UiEvents
---@field size? UiLayoutEvent
---@field position? UiLayoutEvent
---@field update? UiUpdateEvent
---@field remove? UiRemoveEvent
---@field draw UiDrawEvent

---@class ComputedUiEvents
---@field layout? UiLayoutEvent
---@field size? UiLayoutEvent
---@field position? UiLayoutEvent
---@field update? UiUpdateEvent
---@field remove? UiRemoveEvent
---@field draw UiDrawEvent

---@class UiState
---@field root? RegIdx
---@field parent? RegIdx
---@field node RegIdx
---@field box Box
--- cached layout calculations
---@field current_axis_size number

---@class UiCtx
---@field state UiState
---@field events ComputedUiEvents

---@alias UiNode<T> {
---  data: T,
---  ctx: UiCtx,
---}

local Ui = {}
Ui.UID = 0 -- this registries uid
local uid = 0

---@type table<RegIdx, UiNode<any>>
local nodes = {}

---@generic T: UiType
---@class Data<T>: {
---   data: T,
--- }
---@field data Data
---@param e UiEvents
---@return RegIdx
function Ui.add(data, e)
  uid = uid + 1

  ---@type UiLayoutEvent
  local size = function(state, parent, propagate)
    if e.size then
      if parent then
        assert(parent ~= state.node, 'size claimed that parent is self?')
        local parent_node = Ui.get(parent)
        assert(parent_node, 'child has no parent - missing parent in size or stale child')

        if propagate then
          parent_node.events.size(parent_node.state, parent_node.state.parent, propagate)
        end
      end

      e.size(state, parent, propagate)
    end
  end

  ---@type UiLayoutEvent
  local position = function(state, parent, propagate)
    if e.position then
      if parent then
        assert(parent ~= state.node, 'position claimed that parent is self?')
        local parent_node = Ui.get(parent)
        assert(parent_node, 'child has no parent - missing parent in position or stale child')

        if propagate then
          parent_node.events.position(parent_node.state, parent_node.state.parent, propagate)
        end
      end

      e.position(state, parent, propagate)
    end
  end

  ---@type UiLayoutEvent
  local layout = function(state, parent, propagate)
    if parent then
      assert(parent ~= state.node, 'layout claimed that parent is self?')
      local parent_node = Ui.get(parent)
      assert(parent_node, 'child has no parent - missing parent in layout or stale child')
      state.parent = parent
      state.root = parent_node.state.root

      if propagate then
        print 'propgation!!!'
        parent_node.events.layout(parent_node.state, parent_node.state.parent, propagate)
      end
    else
      state.root = state.node
    end

    size(state, parent, propagate)
    position(state, parent, propagate)
  end

  ---@generic T
  ---@type UiNode<T>
  local node = {
    data = data,
    ctx = {
      state = {
        root = nil,
        parent = nil,
        node = {
          idx = uid,
          uid = Ui.UID,
        },
        box = Box.zero(),
        current_axis_size = 0,
      },
      events = {
        update = e.update,
        draw = e.draw,
        remove = e.remove,
        layout = layout,
        size = size,
        position = position,
      },
    },
  }

  data.node = node.ctx.state.node
  nodes[uid] = node
  layout(node.ctx.state)
  return node.ctx.state.node
end

---@param reg RegIdx
function Ui.assert(reg)
  assert(Ui.UID == reg.uid, "tried using a idx in a registry it wasn't created for")
end

---@param reg RegIdx
function Ui.getData(reg)
  Ui.assert(reg)
  return nodes[reg.idx].data
end

---@param reg RegIdx
---@return UiCtx?
function Ui.get(reg)
  Ui.assert(reg)

  return nodes[reg.idx].ctx
end

---@param reg RegIdx
function Ui.remove(reg)
  Ui.assert(reg)

  local node = Ui.get(reg)
  if not node then
    return
  end

  if node.events.remove then
    node.events.remove(node.state)
  end

  local target_idx = node.state.node.idx
  assert(nodes[uid], 'uid should always point to a valid node')
  nodes[target_idx] = nodes[uid]
  nodes[uid].ctx.state.node.idx = target_idx
  nodes[uid] = nil
  uid = uid - 1
end

---@param reg RegIdx
---@return boolean
function Ui.exists(reg)
  Ui.assert(reg)
  return nodes[reg.idx] ~= nil
end

---@param node UiCtx?
---@param dt number
function Ui.update(node, dt)
  if node and node.events.update then
    node.events.update(node.state, dt)
  end
end

---@param node UiCtx?
function Ui.draw(node)
  if node then
    node.events.draw(node.state)
  end
end

---@param node UiCtx?
---@param parent? RegIdx
---@param propagate? boolean
function Ui.layout(node, parent, propagate)
  if node then
    node.events.layout(node.state, parent, propagate)
  end
end

return Ui
