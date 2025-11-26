---@class RegIdx
---@field uid integer -- the registries uid
---@alias UiChildren RegIdx[]

local RegIdx = {}

function RegIdx.valid(v)
  return type(v) == 'table' and type(v.uid) == 'number'
end

---@alias UiLayoutEvent fun(state: ComputedUiState, parent?: RegIdx, propagate?: boolean)
---@alias UiUpdateEvent fun(state: ComputedUiState, dt: number)
---@alias UiRemoveEvent fun(state: ComputedUiState)
---@alias UiDrawEvent fun(state: ComputedUiState)

---@class UiType
---@field node? RegIdx

---@class UiEvents
---@field layout? UiLayoutEvent
---@field size? UiLayoutEvent
---@field position? UiLayoutEvent
---@field update? UiUpdateEvent
---@field remove? UiRemoveEvent
---@field draw UiDrawEvent

---@class ComputedUiState : UiState
---@field root? RegIdx
---@field parent? RegIdx
---@field node RegIdx
---@field box Box
---@field current_axis_size number -- cached layout calculations

---@class UiState
---@field hidden? boolean
---@field name? string

---@class UiBuilder
---@field events UiEvents
---@field state? UiState

---@class UiCtx
---@field state ComputedUiState
---@field events UiEvents

---@alias UiNode<T> {
---  data: T,
---  ctx: UiCtx,
---}

local Ui = {}
Ui.UID = 0 -- this registries uid
Ui.RegIdx = RegIdx

-- weak key map, cleans up nodes when the RegIdx is garbage collected
---@type table<RegIdx, UiNode<any>>
local nodes = setmetatable({}, { __mode = 'k' })

---@class UiBuilder

---@generic T: UiType
---@class Data<T>: {
---   data: T,
--- }
---@field data Data
---@param build UiBuilder
---@return RegIdx
function Ui.add(data, build)
  local reg_idx = {
    uid = Ui.UID,
  }

  ---@type UiLayoutEvent
  local size = function(state, parent, propagate)
    if build.events.size then
      if parent and propagate then
        assert(parent ~= state.node, 'size claimed that parent is self?')
        local parent_node = Ui.get(parent)
        assert(parent_node, 'child has no parent - missing parent in size or stale child')

        parent_node.events.size(parent_node.state, parent_node.state.parent, propagate)
      end

      build.events.size(state, parent, propagate)
    end
  end

  ---@type UiLayoutEvent
  local position = function(state, parent, propagate)
    if build.events.position then
      if parent and propagate then
        assert(parent ~= state.node, 'position claimed that parent is self?')
        local parent_node = Ui.get(parent)
        assert(parent_node, 'child has no parent - missing parent in position or stale child')

        parent_node.events.position(parent_node.state, parent_node.state.parent, propagate)
      end

      build.events.position(state, parent, propagate)
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
        parent_node.events.layout(parent_node.state, parent_node.state.parent, propagate)
      end
    else
      state.root = state.node
    end

    if build.events.layout then
      build.events.layout(state, parent, propagate)
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
        node = reg_idx,
        box = Box.zero(),
        current_axis_size = 0,
      },
      events = {
        update = build.events.update,
        draw = build.events.draw,
        remove = build.events.remove,
        layout = layout,
        size = size,
        position = position,
      },
    },
  }

  if build.state then
    Builtin.merge(node.ctx.state, build.state)
    Builtin.proxy(build.state, function(key, value, _)
      node.ctx.state[key] = value
      layout(node.ctx.state, node.ctx.state.parent, true)
    end)
  end

  data.node = reg_idx
  nodes[reg_idx] = node
  layout(node.ctx.state)

  return reg_idx
end

---@param reg RegIdx
function Ui.assert(reg)
  assert(Ui.RegIdx.valid(reg), 'passed an invalid idx to the UI registry')
  assert(
    Ui.UID == reg.uid,
    string.format("tried using a idx within a UI registry it wasn't created for id: %s", reg.uid)
  )
end

---@param reg RegIdx
function Ui.getData(reg)
  Ui.assert(reg)
  local node = nodes[reg]
  return node and node.data
end

---@param reg RegIdx
---@return UiCtx?
function Ui.get(reg)
  Ui.assert(reg)
  local node = nodes[reg]
  return node and node.ctx
end

---@param reg RegIdx
function Ui.remove(reg)
  Ui.assert(reg)

  local node = nodes[reg]
  if not node then
    return
  end

  if node.ctx.events.remove then
    node.ctx.events.remove(node.ctx.state)
  end

  nodes[reg] = nil
end

---@param reg RegIdx
---@return boolean
function Ui.exists(reg)
  Ui.assert(reg)
  return nodes[reg] ~= nil
end

return Ui
