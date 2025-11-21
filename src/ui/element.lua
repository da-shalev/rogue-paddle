local UiStyle = require 'ui.style'

---@class UiElementEvents
---@field draw? fun(e: UiElement)
---@field onHoverEnter? fun(e: UiElement)
---@field onHoverExit? fun(e: UiElement)
---@field onClick? fun()

---@class UiElement
---@field hover? boolean
---@field events UiElementEvents
---@field style ComputedUiStyle
---@field name? string
---@field _children UiChildren
local UiElement = {}
UiElement.__index = UiElement

---@class UiElementBuilder
---@field style? UiStyles
---@field children? UiChildren|UiIdx
---@field events? UiElementEvents

---@param opts UiElementBuilder
---@return UiIdx
UiElement.new = function(opts)
  opts.events = opts.events or {}

  -- normalize children

  ---@type UiChildren
  local children = {}
  local c = opts.children
  if type(c) == 'number' then
    children = { c }
  elseif type(c) == 'table' then
    -- ensures it iterates through all values including nil
    -- max length to appropriately add the UiNode
    for i = 1, table.maxn(c) do
      if c[i] then
        children[#children + 1] = c[i]
      end
    end
  else
    children = {}
  end

  ---@type UiElement
  local e = {
    hover = nil,
    style = UiStyle.new(unpack(UiStyle.normalize(opts.style))),
    events = opts.events,
    _children = children,
  }

  local e = setmetatable(e, UiElement)

  return UiRegistry.add(e, {
    update = function(ctx, dt)
      UiElement.update(e, ctx, dt)
    end,

    draw = function(ctx)
      UiElement.draw(e, ctx)
    end,

    remove = function(_)
      for _, child_idx in ipairs(e._children) do
        UiRegistry.remove(child_idx)
      end
    end,

    layout = function(ctx)
      UiElement.layout(e, ctx)
      return true
    end,
  })
end

---@param self UiElement
---@param ctx UiCtx
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
      UiRegistry.update(UiRegistry.get(child_idx), dt)
    end
  end
end

---@param self UiElement
---@param ctx UiCtx
function UiElement.draw(self, ctx)
  local style = self.style.current
  if style.background_color then
    love.graphics.setColor(style.background_color)
    love.graphics.rectangle(
      'fill',
      ctx.box.pos.x + style.border / 2,
      ctx.box.pos.y + style.border / 2,
      ctx.box.size.x - style.border,
      ctx.box.size.y - style.border,
      style.border_radius,
      style.border_radius
    )
  end

  if style.border > 0 and style.border_color then
    love.graphics.setColor(style.border_color)
    love.graphics.setLineWidth(style.border)
    love.graphics.rectangle(
      'line',
      ctx.box.pos.x + style.border / 2,
      ctx.box.pos.y + style.border / 2,
      ctx.box.size.x - style.border,
      ctx.box.size.y - style.border,
      style.border_radius,
      style.border_radius
    )
  end

  -- if self.style.extend and self.style.extend then
  --   love.graphics.setColor(0, 255, 0, 0.5)
  --   local e = self.style.extend.bottom
  --   love.graphics.setLineWidth(e)
  --   love.graphics.rectangle(
  --     'line',
  --     self.box.pos.x + e / 2,
  --     self.box.pos.y + e / 2,
  --     self.box.size.x - e,
  --     self.box.size.y - e,
  --     self.style.border_radius,
  --     self.style.border_radius
  --   )
  -- end

  love.graphics.setColor(style.content_color or Color.RESET)

  for _, child_idx in ipairs(self._children) do
    UiRegistry.draw(UiRegistry.get(child_idx))
  end
end

---@param child UiIdx
---@param pos? integer
function UiElement:addChild(child, pos)
  if pos then
    table.insert(self._children, pos, child)
  else
    table.insert(self._children, child)
  end
end

function UiElement:clearChildren()
  for child in self._children do
    UiRegistry.remove(child)
  end
end

---@param self UiElement
---@param ctx UiCtx
--  TODO: return boolean to know whether a mutation happened to avoid recalculation
function UiElement.layout(self, ctx)
  local style = self.style.current

  -- Starting cursor for placing children
  local cr_x = ctx.box.x + style.extend.left
  local cr_y = ctx.box.y + style.extend.top

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
    local child = UiRegistry.getCtx(self._children[child_idx])
    if not child then
      goto continue
    end

    child.box.x = cr_x
    child.box.y = cr_y

    if is_row then
      cross_axis_size = math.max(cross_axis_size, child.box.h)
      local add = child.box.w + style.gap
      cr_x = cr_x + add
      current_axis_size = current_axis_size + add
    elseif is_col then
      cross_axis_size = math.max(cross_axis_size, child.box.w)
      local add = child.box.h + style.gap
      cr_y = cr_y + add
      current_axis_size = current_axis_size + add
    end

    ::continue::
  end

  current_axis_size = current_axis_size - style.gap

  -- Sets container size based on placed children
  if is_row then
    ctx.box.w = (w or current_axis_size) + style.extend.left + style.extend.right
    ctx.box.h = (h or cross_axis_size) + style.extend.top + style.extend.bottom
  elseif is_col then
    ctx.box.w = (w or cross_axis_size) + style.extend.left + style.extend.right
    ctx.box.h = (h or current_axis_size) + style.extend.top + style.extend.bottom
  end

  -- Computes spare space for justify-content
  local justify_offset = 0
  local justify_space
  if is_row then
    justify_space = (ctx.box.w - style.extend.left - style.extend.right) - current_axis_size
  elseif is_col then
    justify_space = (ctx.box.h - style.extend.top - style.extend.bottom) - current_axis_size
  end

  --- TODO: IMPLEMENT WRAPPING HERE

  if style.justify_content == 'center' then
    justify_offset = justify_space / 2
  elseif style.justify_content == 'end' then
    justify_offset = justify_space
  end

  -- Second pass: apply cross-axis alignment and offset
  for _, child_idx in pairs(self._children) do
    local child = UiRegistry.get(child_idx)
    if not child then
      goto continue
    end

    local box = child.ctx.box

    if is_row then
      local inner_h = ctx.box.h - style.extend.top - style.extend.bottom

      if style.align_items == 'center' then
        box.y = box.y + (inner_h - box.h) / 2
      elseif style.align_items == 'end' then
        box.y = box.y + (inner_h - box.h)
      end

      box.x = box.x + justify_offset
    elseif is_col then
      local inner_w = ctx.box.w - style.extend.left - style.extend.right

      if style.align_items == 'center' then
        box.x = box.x + (inner_w - box.w) / 2
      elseif style.align_items == 'end' then
        box.x = box.x + (inner_w - box.w)
      end

      box.y = box.y + justify_offset
    end

    child.events.layout(child.ctx, ctx.layout)
    ::continue::
  end
end

return UiElement
