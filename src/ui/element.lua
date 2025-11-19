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

---@class UiEvents
---@field applyLayout? fun(e: UiElement)
---@field draw? fun(e: UiElement)
---@field onHoverEnter? fun(e: UiElement)
---@field onHoverExit? fun(e: UiElement)

---@class UiElement
---@field root? UiElement
---@field parent? UiElement
---@field box Box
---@field hover? boolean
---@field events UiEvents
---@field style? ComputedUiStyle
---@field actions? UiActions
---@field name? string
---@field children (UiElement)[]
---@field flags UiFlags
local UiElement = {}
UiElement.__index = UiElement

---@class UiElementOpts : UiEvents
---@field style? UiStyles
---@field flags? UiFlags
---@field actions? UiActions
---@field children? (UiElement)[]

---@param opts UiElementOpts
UiElement.new = function(opts)
  ---@type UiElement
  local e = {
    parent = nil,
    box = Box.zero(),
    root = nil,
    hover = nil,
    events = {
      draw = opts.draw,
      applyLayout = opts.applyLayout,
      onHoverEnter = opts.onHoverEnter,
    },
    style = UiStyle.normalize(opts.style),
    flags = opts.flags or Flags.default(),
    actions = opts.actions or {},
    children = opts.children or {},
  }

  local e = setmetatable(e, UiElement)
  e:updateLayout()
  return e
end

---@param dt number
function UiElement:update(dt)
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

  if love.mouse.isDown(1) and self.hover and self.actions.onClick then
    self.actions.onClick()
  end

  if hover then
    for _, child in ipairs(self.children) do
      if child.update then
        child:update(dt)
      end
    end
  end
end

---@param actions UiActions
---@return UiElement
function UiElement:setActions(actions)
  self.actions = actions
  return self
end

---@param ... UiStyle
---@return UiElement
function UiElement:setStyle(...)
  self.style = UiStyle.new(...)
  return self
end

---@return ComputedUiStyle
function UiElement:getStyle()
  return self.style
end

---@param name string
---@return UiElement
function UiElement:setName(name)
  self.name = name
  return self
end

---@return string
function UiElement:getName()
  return self.name
end

function UiElement:draw()
  if self.flags.dirty then
    self.flags.dirty = false
    self:updateLayout(self.parent)
    if self.root ~= self then
      self.root:updateLayout()
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

  for _, child in ipairs(self.children) do
    child:draw()
  end
end

--- If no parent is passed, it is assumed self is root!
--- @param parent? UiElement
function UiElement:updateLayout(parent)
  if parent then
    self.parent = parent
    self.root = parent.root
  else
    self.root = self
  end

  if self.events.applyLayout then
    self.events.applyLayout(self)
  end

  self:layout()
end

---@param child UiElement
---@param pos? integer
function UiElement:addChild(child, pos)
  if pos then
    table.insert(self.children, pos, child)
  else
    table.insert(self.children, child)
  end
end

---@param child UiElement
---@return boolean
function UiElement:removeChild(child)
  for i, c in ipairs(self.children) do
    if c == child then
      table.remove(self.children, i)
      return true
    end
  end

  return false
end

-- -TODO: return boolean to know wheather a mutation happened to avoid recalculation
function UiElement:layout()
  local style = self:getStyle()

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
    start_i = #self.children
    end_i = 1
    step = -1
  else
    start_i = 1
    end_i = #self.children
    step = 1
  end

  -- Tracks total axis usage and the largest cross-size
  local current_axis_size = 0
  local cross_axis_size = 0

  local w = UiStyle.calculateUnit(style.width)
  local h = UiStyle.calculateUnit(style.height)

  for i = start_i, end_i, step do
    local child = self.children[i]
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
  for _, child in pairs(self.children) do
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
  end
end

UiElement.Flags = Flags

return UiElement
