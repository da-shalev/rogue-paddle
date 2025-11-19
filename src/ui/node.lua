local UiStyle = require('ui.style')

---@class UiFlags
---@field dirty boolean
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
---@field applyLayout? fun(e: ComputedUiNode)
---@field draw? fun(e: ComputedUiNode)
---@field onHoverEnter? fun(e: ComputedUiNode)
---@field onHoverExit? fun(e: ComputedUiNode)

---@class ComputedUiNode : UiActions
---@field root? UiIdx
---@field parent? UiIdx
---@field box Box
---@field hover? boolean
---@field events UiEvents
---@field style ComputedUiStyle
---@field name? string
---@field _children UiChildren
---@field _idx UiIdx
local ComputedUiNode = {}
ComputedUiNode.__index = ComputedUiNode

---@class UiNode : UiActions
---@field style? UiStyles
---@field children? UiChildren

---@param opts UiNode
---@param events? UiEvents
---@return UiIdx
ComputedUiNode.new = function(opts, events)
  events = events or {}
  opts.children = opts.children or {}
  opts.style = opts.style or UiStyle.new()
  events.flags = events.flags or Flags.default()

  ---@type ComputedUiNode
  local e = {
    parent = nil,
    box = Box.zero(),
    root = nil,
    hover = nil,
    style = UiStyle.normalize(opts.style),
    _children = opts.children or {},
    _idx = 0,
    events = events,
    onClick = opts.onClick,
  }

  local e = setmetatable(e, ComputedUiNode)

  UiRegistry:add(e)
  return e:getIdx()
end

---@param dt number
function ComputedUiNode:update(dt)
  local x, y = S.cursor:within(self.box)
  local hover = x and y

  if self.hover ~= hover then
    if self.style.hover_cursor then
      if hover then
        love.mouse.setCursor(self.style.hover_cursor)
        self.style.content.color = self.style.content.hover_color
        self.style.background.color = self.style.background.hover_color

        if self.events.onHoverEnter then
          self.events.onHoverEnter(self)
        end
      else
        love.mouse.setCursor()
        self.style.content.color = self.style.content.base_color
        self.style.background.color = self.style.background.base_color

        if self.events.onHoverExit then
          self.events.onHoverExit(self)
        end
      end
    end

    self.hover = hover
  end

  if love.mouse.isDown(1) and self.hover and self.onClick then
    self.onClick()
  end

  if hover then
    for _, child_idx in ipairs(self._children) do
      UiRegistry:update(child_idx, dt)
    end
  end
end

---@return UiIdx
function ComputedUiNode:getIdx()
  return self._idx
end

---@param name string
---@return ComputedUiNode
function ComputedUiNode:setName(name)
  self.name = name
  return self
end

---@return string
function ComputedUiNode:getName()
  return self.name
end

---@return UiChildren
function ComputedUiNode:children()
  return self._children
end

function ComputedUiNode:draw()
  if self.events.flags.dirty then
    self.events.flags.dirty = false

    local parent = UiRegistry:get(self.parent)
    if parent then
      self:updateLayout(parent)
    else
      self.parent = nil
    end

    local root = UiRegistry:get(self.root)
    if root then
      if root:getIdx() ~= self:getIdx() then
        root:updateLayout()
      end
    else
      self.root = self:getIdx()
    end
  end

  if self.style.background.color then
    love.graphics.setColor(self.style.background.color)
    love.graphics.rectangle(
      'fill',
      self.box.pos.x + self.style.border / 2,
      self.box.pos.y + self.style.border / 2,
      self.box.size.x - self.style.border,
      self.box.size.y - self.style.border,
      self.style.border_radius,
      self.style.border_radius
    )
  end

  if self.style.border and self.style.border_color then
    love.graphics.setColor(self.style.border_color)
    love.graphics.setLineWidth(self.style.border)
    love.graphics.rectangle(
      'line',
      self.box.pos.x + self.style.border / 2,
      self.box.pos.y + self.style.border / 2,
      self.box.size.x - self.style.border,
      self.box.size.y - self.style.border,
      self.style.border_radius,
      self.style.border_radius
    )
  end

  if self.events.draw then
    love.graphics.setColor(self.style.content.color or Color.RESET)
    self.events.draw(self)
  end

  for _, child_idx in ipairs(self._children) do
    UiRegistry:draw(child_idx)
  end
end

--- If no parent is passed, it is assumed self is root!
--- @param parent? ComputedUiNode
function ComputedUiNode:updateLayout(parent)
  if parent then
    -- local parent =
    self.parent = parent:getIdx()
    self.root = parent.root
  else
    self.root = self:getIdx()
  end

  if self.events.applyLayout then
    self.events.applyLayout(self)
  end

  self:layout()
end

-- ---@param child UiIdx
-- ---@param pos? integer
-- function ComputedUiNode:addChild(child, pos)
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
-- ---@param child UiNode
-- ---@return boolean
-- function ComputedUiNode:removeChild(child)
--   for i, c in ipairs(self._children) do
--     if c == child then
--       table.remove(self._children, i)
--       return true
--     end
--   end
--
--   return false
-- end

-- TODO: return boolean to know whether a mutation happened to avoid recalculation
function ComputedUiNode:layout()
  local style = self.style

  -- Starting cursor for placing children
  local cr_x = self.box.x + style.extend.left
  local cr_y = self.box.y + style.extend.top

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
    local child = UiRegistry:get(child_idx)
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
    self.box.w = w or (current_axis_size + style.extend.left + style.extend.right)
    self.box.h = h or (cross_axis_size + style.extend.top + style.extend.bottom)
  elseif is_col then
    self.box.w = w or (cross_axis_size + style.extend.left + style.extend.right)
    self.box.h = h or (current_axis_size + style.extend.top + style.extend.bottom)
  end

  -- Computes spare space for justify-content
  local justify_offset = 0
  local justify_space
  if is_row then
    justify_space = self.box.w - style.extend.left - style.extend.right - current_axis_size
  elseif is_col then
    justify_space = self.box.h - style.extend.top - style.extend.bottom - current_axis_size
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
      local inner_h = self.box.h - style.extend.top - style.extend.bottom
      local base_y = self.box.y + style.extend.top

      if style.align_items == 'center' then
        child.box.y = base_y + (inner_h - child.box.h) / 2
      elseif style.align_items == 'end' then
        child.box.y = base_y + (inner_h - child.box.h)
      end

      child.box.x = child.box.x + justify_offset
    elseif is_col then
      local inner_w = self.box.w - style.extend.left - style.extend.right
      local base_x = self.box.x + style.extend.left

      if style.align_items == 'center' then
        child.box.x = base_x + (inner_w - child.box.w) / 2
      elseif style.align_items == 'end' then
        child.box.x = base_x + (inner_w - child.box.w)
      end

      child.box.y = child.box.y + justify_offset
    end

    child:updateLayout(self)
    ::continue::
  end
end

ComputedUiNode.Flags = Flags

return ComputedUiNode
