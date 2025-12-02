---@class UiId
---@field [table] boolean

---@alias UiChildren UiId[]

---@alias UiLayoutEvent fun(view: UiView, parent?: UiId, propagate?: boolean)
---@alias UiUpdateEvent fun(view: UiView, dt: number)
---@alias UiRemoveEvent fun(view: UiView)
---@alias UiDrawEvent fun(view: UiView)

---@class UiType
---@field node? UiId

---@class UiEvents
---@field layout? UiLayoutEvent
---@field size? UiLayoutEvent
---@field position? UiLayoutEvent
---@field update? UiUpdateEvent
---@field remove? UiRemoveEvent
---@field draw UiDrawEvent

---@class UiView
---@field root? UiId
---@field parent? UiId
---@field node UiId
---@field box Box
---@field current_axis_size number -- cached layout calculations
---@field state UiState

---@class UiState
---@field hidden? boolean
---@field name? string

---@class UiBuilder
---@field events UiEvents
---@field state? UiState

---@class UiCtx
---@field view UiView
---@field events UiEvents

---@alias UiNode<T> {
---  data: T,
---  ctx: UiCtx,
---}

local Ui = {}
local _ui_marker = {}

---@param v any
---@return boolean
function Ui.is(v)
  return type(v) == 'table' and v[_ui_marker]
end

-- weak key map, cleans up nodes when the RegIdx is garbage collected
---@type table<UiId, UiNode<any>>
local nodes = setmetatable({}, { __mode = 'k' })

---@generic T: UiType
---@class Data<T>: {
---   data: T,
--- }
---@field data Data
---@param build UiBuilder
---@return UiId
function Ui.add(data, build)
  local idx = {
    [_ui_marker] = true,
  }

  if not build.state then
    build.state = {
      hidden = false,
    }
  end

  ---@type UiLayoutEvent
  local size = function(state, parent, propagate)
    if build.events.size then
      if parent and propagate then
        assert(parent ~= state.node, 'size claimed that parent is self?')
        local parent_node = Ui.get(parent)
        assert(parent_node, 'child has no parent - missing parent in size or stale child')

        parent_node.events.size(parent_node.view, parent_node.view.parent, propagate)
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

        parent_node.events.position(parent_node.view, parent_node.view.parent, propagate)
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
      state.root = parent_node.view.root

      if propagate then
        parent_node.events.layout(parent_node.view, parent_node.view.parent, propagate)
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
      view = {
        root = nil,
        parent = nil,
        node = idx,
        box = Box.zero(),
        current_axis_size = 0,
        state = build.state,
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

  local state = Reactive.fromState(build.state)
  if state then
    state.subscribe(function()
      layout(node.ctx.view, node.ctx.view.parent, true)
    end)
  end

  data.node = idx
  nodes[idx] = node
  layout(node.ctx.view)

  return idx
end

---@param reg UiId
function Ui.assert(reg)
  assert(Ui.is(reg), 'passed an invalid idx to the UI registry')
end

---@param id UiId
function Ui.data(id)
  Ui.assert(id)
  local node = nodes[id]
  return node and node.data
end

---@param reg UiId
---@return UiCtx?
function Ui.get(reg)
  Ui.assert(reg)
  local node = nodes[reg]
  return node and node.ctx
end

---@param reg UiId
function Ui.remove(reg)
  Ui.assert(reg)

  local node = nodes[reg]
  if not node then
    return
  end

  if node.ctx.events.remove then
    node.ctx.events.remove(node.ctx.view)
  end

  nodes[reg] = nil
end

---@param reg UiId
---@return boolean
function Ui.exists(reg)
  Ui.assert(reg)
  return nodes[reg] ~= nil
end

---@param node UiCtx?
---@param dt number
function Ui.update(node, dt)
  assert(node, 'nil node passed to update')
  if not node.view.state.hidden and node.events.update then
    node.events.update(node.view, dt)
  end
end

---@param node UiCtx?
function Ui.draw(node)
  assert(node, 'nil node passed to draw')
  if not node.view.state.hidden then
    node.events.draw(node.view)
  end
end

---@param node UiCtx?
---@param parent? UiId
---@param propagate? boolean
function Ui.layout(node, parent, propagate)
  assert(node, 'nil node passed to layout')
  node.events.layout(node.view, parent, propagate)
end

return Ui
