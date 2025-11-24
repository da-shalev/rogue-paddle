local UiStyle = require 'ui.style'

---@class UiElementEvents
---@field draw? fun(e: UiElement)
---@field onHoverEnter? fun(e: UiElement)
---@field onHoverExit? fun(e: UiElement)
---@field onClick? fun()

---@class UiElement : UiType
---@field hover? boolean
---@field events UiElementEvents
---@field style ComputedUiStyle
---@field name? string
---@field _children UiChildren
local UiElement = {}
UiElement.__index = UiElement

---@class UiElementBuilder
---@field style? UiStyles
---@field name? string
---@field events? UiElementEvents

---@param opts UiElementBuilder
---@return RegIdx
UiElement.new = function(opts)
  opts.events = opts.events or {}

  ---@type UiChildren
  local children = {}
  for i = 1, table.maxn(opts) do
    if opts[i] then
      children[#children + 1] = opts[i]
    end
  end

  ---@type UiElement
  local e = {
    hover = nil,
    name = opts.name or 'unnamed',
    style = UiStyle.new(unpack(UiStyle.normalize(opts.style))),
    events = opts.events,
    _children = children,
  }

  local e = setmetatable(e, UiElement)
  return Ui.add(e, {
    update = function(state, dt)
      UiElement.update(e, state, dt)
    end,

    draw = function(state)
      UiElement.draw(e, state)
    end,

    remove = function(_)
      for _, child_idx in ipairs(e._children) do
        Ui.remove(child_idx)
      end
    end,

    layout = function(state)
      UiElement.layout(e, state)
      return true
    end,
  })
end

---@param self UiElement
---@param ctx UiState
---@param dt number
function UiElement.update(self, ctx, dt)
  local x, y = S.cursor:within(ctx.box)
  local hover = x and y

  if self.hover ~= hover then
    if hover then
      self.style.current = self.style.hover
      love.mouse.setCursor(self.style.current.cursor)

      if self.events.onHoverEnter then
        self.events.onHoverEnter(self)
      end
    else
      self.style.current = self.style.base
      love.mouse.setCursor()

      if self.events.onHoverExit then
        self.events.onHoverExit(self)
      end
    end

    self.hover = hover
  end

  if love.mouse.isDown(1) and self.hover and self.events.onClick then
    self.events.onClick()
  end

  if hover then
    for _, child_idx in ipairs(self._children) do
      Ui.update(Ui.get(child_idx), dt)
    end
  end
end

---@param self UiElement
---@param state UiState
function UiElement.draw(self, state)
  local style = self.style.current

  if style.background_color then
    love.graphics.setColor(style.background_color)
    love.graphics.rectangle(
      'fill',
      state.box.pos.x + style.border / 2,
      state.box.pos.y + style.border / 2,
      state.box.size.x - style.border,
      state.box.size.y - style.border,
      style.border_radius,
      style.border_radius
    )
  end

  if style.border > 0 and style.border_color then
    love.graphics.setColor(style.border_color)
    love.graphics.setLineWidth(style.border)
    love.graphics.rectangle(
      'line',
      state.box.pos.x + style.border / 2,
      state.box.pos.y + style.border / 2,
      state.box.size.x - style.border,
      state.box.size.y - style.border,
      style.border_radius,
      style.border_radius
    )
  end

  love.graphics.setColor(style.content_color or Color.RESET)

  for _, child_idx in ipairs(self._children) do
    local child = Ui.get(child_idx)
    Ui.draw(child)
  end
end

---@param children RegIdx
function UiElement:addChildren(children)
  local node = Ui.get(self.node)
  assert(node, 'tried to add child to nil parent')

  for _, child_idx in ipairs(children) do
    local child = Ui.get(child_idx)
    table.insert(self._children, child_idx)
    assert(child, string.format('tried to add nil child to %s', self.name))
    Ui.layout(child, self.node)
  end

  Ui.layout(node, node.state.parent, true)
end

---@param child RegIdx
---@param pos integer
function UiElement:addChildAt(child, pos)
  local child = Ui.get(child)
  local node = Ui.get(self.node)
  assert(child, 'tried to add nil child')
  assert(node, 'tried to add child to nil parent')

  table.insert(self._children, pos, child)
  Ui.layout(child, node.state.parent, true)
end

function UiElement:clearChildren()
  for _, child in ipairs(self._children) do
    Ui.remove(child)
  end

  self._children = {}
end

---@param self UiElement
---@param state UiState
--  TODO: return boolean to know whether a mutation happened to avoid recalculation
function UiElement.layout(self, state)
  local style = self.style.current

  -- Starting cursor for placing children
  local cr_x = state.box.x + style.extend.left
  local cr_y = state.box.y + style.extend.top

  -- Determines which axis children flow along
  local is_row = style.flex_dir == 'row' or style.flex_dir == 'row-reverse'
  local is_col = style.flex_dir == 'col' or style.flex_dir == 'col-reverse'
  local is_reverse = style.flex_dir == 'row-reverse' or style.flex_dir == 'col-reverse'

  -- Determines iteration direction
  local start_i, end_i, step
  if is_reverse then
    start_i = #self._children
    end_i = 1
    step = -1
  else
    start_i = 1
    end_i = #self._children
    step = 1
  end

  -- Tracks total axis usage and the largest cross-size
  local current_axis_size = 0
  local cross_axis_size = 0

  local w = UiStyle.calculateUnit(style.width)
  local h = UiStyle.calculateUnit(style.height)

  for child_idx = start_i, end_i, step do
    local child = Ui.get(self._children[child_idx])
    assert(child, 'flex layout child is nil')

    child.events.layout(child.state, self.node)

    child.state.box.x = cr_x
    child.state.box.y = cr_y

    if is_row then
      cross_axis_size = math.max(cross_axis_size, child.state.box.h)
      local add = child.state.box.w + style.gap
      cr_x = cr_x + add
      current_axis_size = current_axis_size + add
    elseif is_col then
      cross_axis_size = math.max(cross_axis_size, child.state.box.w)
      local add = child.state.box.h + style.gap
      cr_y = cr_y + add
      current_axis_size = current_axis_size + add
    end
  end

  current_axis_size = current_axis_size - style.gap

  -- Sets container size based on placed children
  if is_row then
    state.box.w = w or current_axis_size + style.extend.left + style.extend.right
    state.box.h = h or cross_axis_size + style.extend.top + style.extend.bottom
  elseif is_col then
    state.box.w = w or cross_axis_size + style.extend.left + style.extend.right
    state.box.h = h or current_axis_size + style.extend.top + style.extend.bottom
  end

  -- TODO: measure() above, position() below

  -- Computes spare space for justify-content
  local justify_offset = 0
  local justify_space
  if is_row then
    justify_space = (state.box.w - style.extend.left - style.extend.right) - current_axis_size
  elseif is_col then
    justify_space = (state.box.h - style.extend.top - style.extend.bottom) - current_axis_size
  end

  --- TODO: IMPLEMENT WRAPPING HERE

  if style.justify_content == 'center' then
    justify_offset = justify_space / 2
  elseif style.justify_content == 'end' then
    justify_offset = justify_space
  end

  -- Second pass: apply cross-axis alignment and offset
  for _, child_idx in pairs(self._children) do
    local child = Ui.get(child_idx)
    assert(child, 'flex layout child is nil')

    local box = child.state.box

    if is_row then
      local inner_h = state.box.h - style.extend.top - style.extend.bottom

      if style.align_items == 'center' then
        box.y = box.y + (inner_h - box.h) / 2
      elseif style.align_items == 'end' then
        box.y = box.y + (inner_h - box.h)
      end

      box.x = box.x + justify_offset
    elseif is_col then
      local inner_w = state.box.w - style.extend.left - style.extend.right

      if style.align_items == 'center' then
        box.x = box.x + (inner_w - box.w) / 2
      elseif style.align_items == 'end' then
        box.x = box.x + (inner_w - box.w)
      end

      box.y = box.y + justify_offset
    end

    child.events.layout(child.state, self.node)
  end
end

return UiElement
