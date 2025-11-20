local UiStyle = require 'ui.style'
local UiNode = require 'ui.node'

---@class UiFlags
---@field queue_apply_layout boolean
local Flags = {}

---@return UiFlags
Flags.default = function()
  return {
    dirty = false,
  }
end

---@class UiActions
---@field onClick? fun()

---@alias UiIdx integer
---@alias UiChildren UiIdx[]

---@class UiEvents
---@field flags? UiFlags
---@field applyLayout? fun(e: UiElement)
---@field draw? fun(e: UiElement)
---@field onHoverEnter? fun(e: UiElement)
---@field onHoverExit? fun(e: UiElement)

---@class UiElement
---@field hover? boolean
---@field events UiEvents
---@field style ComputedUiStyle
---@field name? string
---@field actions UiActions
---@field _children UiChildren
local UiElement = {}
UiElement.__index = UiElement

---@class UiElementBuilder
---@field style? UiStyles
---@field children? UiChildren|UiIdx
---@field actions? UiActions

---@param opts UiElementBuilder
---@param events? UiEvents
---@return UiIdx
UiElement.new = function(opts, events)
  events = events or {}
  opts.actions = opts.actions or {}
  events.flags = events.flags or Flags.default()

  ---@type UiChildren
  local children = {}
  local c = opts.children
  if type(c) == 'number' then
    children = { c }
  elseif type(c) == 'table' then
    children = c
  else
    children = {}
  end

  ---@type UiElement
  local self = {
    hover = nil,
    style = UiStyle.normalize(opts.style),
    events = events,
    _children = children,
    actions = opts.actions,
  }

  ---@type UiNode
  local node = UiNode.new {
    update = function(ctx, dt)
      UiElement.update(self, ctx, dt)
    end,
    draw = function(ctx)
      UiElement.draw(self, ctx)
    end,
    remove = function()
      for _, child_idx in ipairs(self._children) do
        UiRegistry:removeIdx(child_idx)
      end
    end,
    layout = function(ctx, parent)
      UiElement.layout(self, ctx)
      return true
    end,
  }

  return UiRegistry:add(node)
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

  if love.mouse.isDown(1) and self.hover and self.actions.onClick then
    self.actions.onClick()
  end

  if hover then
    for _, child_idx in ipairs(self._children) do
      UiRegistry:update(UiRegistry:get(child_idx), dt)
    end
  end
end

---@param self UiElement
---@param ctx UiCtx
function UiElement.draw(self, ctx)
  -- if self.events.flags.queue_apply_layout then
  --   self.events.flags.queue_apply_layout = false
  --
  --   local parent = UiRegistry:get(self.parent)
  --   if parent then
  --     self:updateLayout(parent)
  --   else
  --     self.parent = nil
  --   end
  --
  --   local root = UiRegistry:get(self.root)
  --   if root then
  --     if root:getIdx() ~= self:getIdx() then
  --       root:updateLayout()
  --     end
  --   else
  --     self.root = self:getIdx()
  --   end
  -- end

  if self.style.current.background_color then
    love.graphics.setColor(self.style.current.background_color)
    love.graphics.rectangle(
      'fill',
      ctx.box.pos.x + self.style.current.border / 2,
      ctx.box.pos.y + self.style.current.border / 2,
      ctx.box.size.x - self.style.current.border,
      ctx.box.size.y - self.style.current.border,
      self.style.current.border_radius,
      self.style.current.border_radius
    )
  end

  if self.style.current.border > 0 and self.style.current.border_color then
    love.graphics.setColor(self.style.current.border_color)
    love.graphics.setLineWidth(self.style.current.border)
    love.graphics.rectangle(
      'line',
      ctx.box.pos.x + self.style.current.border / 2,
      ctx.box.pos.y + self.style.current.border / 2,
      ctx.box.size.x - self.style.current.border,
      ctx.box.size.y - self.style.current.border,
      self.style.current.border_radius,
      self.style.current.border_radius
    )
  end

  -- if self.style.current.extend and self.style.current.extend then
  --   love.graphics.setColor(0, 255, 0, 0.5)
  --   local e = self.style.current.extend.bottom
  --   love.graphics.setLineWidth(e)
  --   love.graphics.rectangle(
  --     'line',
  --     self.box.pos.x + e / 2,
  --     self.box.pos.y + e / 2,
  --     self.box.size.x - e,
  --     self.box.size.y - e,
  --     self.style.current.border_radius,
  --     self.style.current.border_radius
  --   )
  -- end

  love.graphics.setColor(self.style.current.content_color or Color.RESET)

  for _, child_idx in ipairs(self._children) do
    UiRegistry:draw(UiRegistry:get(child_idx))
  end
end

-- ---@param child UiIdx
-- ---@param pos? integer
-- function ComputedUiElement:addChild(child, pos)
--   if pos then
--     table.insert(self._children, pos, child)
--   else
--     table.insert(self._children, child)
--   end
--
--   self:updateLayout()
--   -- self.root:updateLayout()
-- end
--
-- ---@param child UiElement
-- ---@return boolean
-- function ComputedUiElement:removeChild(child)
--   for i, c in ipairs(self._children) do
--     if c == child then
--       table.remove(self._children, i)
--       return true
--     end
--   end
--
--   return false
-- end

---@param self UiElement
---@param ctx UiCtx
-- TODO: return boolean to know whether a mutation happened to avoid recalculation
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

  for i = start_i, end_i, step do
    local child_idx = self._children[i]
    local child = UiRegistry:getCtx(child_idx)
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
    local child = UiRegistry:get(child_idx)
    if not child then
      goto continue
    end

    if is_row then
      local inner_h = ctx.box.h - style.extend.top - style.extend.bottom

      if style.align_items == 'center' then
        child.ctx.box.y = child.ctx.box.y + (inner_h - child.ctx.box.h) / 2
      elseif style.align_items == 'end' then
        child.ctx.box.y = child.ctx.box.y + (inner_h - child.ctx.box.h)
      end

      child.ctx.box.x = child.ctx.box.x + justify_offset
    elseif is_col then
      local inner_w = ctx.box.w - style.extend.left - style.extend.right

      if style.align_items == 'center' then
        child.ctx.box.x = child.ctx.box.x + (inner_w - child.ctx.box.w) / 2
      elseif style.align_items == 'end' then
        child.ctx.box.x = child.ctx.box.x + (inner_w - child.ctx.box.w)
      end

      child.ctx.box.y = child.ctx.box.y + justify_offset
    end

    child.events.layout(child.ctx)
    ::continue::
  end
end

UiElement.Flags = Flags

return UiElement
