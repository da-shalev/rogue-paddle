local UiStyle = require('ui.style')

---@class ComputedFlexbox
---@field box Box
---@field dir FlexDirection
---@field justify_content FlexJustifyContent
---@field align_items FlexAlignItems
---@field gap number
---@field children (UiElement)[]
local Flexbox = {}
Flexbox.__index = Flexbox

---@alias FlexDirection "row" | "col" | "row-reverse" | "col-reverse"
---@alias FlexJustifyContent "start" | "center" | "end"
---@alias FlexAlignItems "start" | "center" | "end"

---@class FlexOpts
---@field dir? FlexDirection
---@field justify_content? FlexJustifyContent
---@field align_items? FlexAlignItems
---@field gap? number

---@class Flexbox
---@field flex? FlexOpts
---@field children (UiElement)[]
---@field name? string
---@field style? UiStyles
---@field actions? UiActions

---A simple 'nowrap' flexbox
---@param opts Flexbox
---@return UiElement
function Flexbox.new(opts)
  opts.flex = opts.flex or {}

  ---@type ComputedFlexbox
  local flex = {
    box = Box.zero(),
    dir = opts.flex.dir or 'row',
    justify_content = opts.flex.justify_content or 'start',
    align_items = opts.flex.align_items or 'start',
    gap = opts.flex.gap or 0,
    children = opts.children or {},
  }

  local flexbox = setmetatable(flex, Flexbox)
  local e = UiElement.new {
    box = flexbox.box,
    update = function(dt)
      flexbox:update(dt)
    end,
    applyLayout = function(self)
      flexbox:applyLayout(self)
    end,
    draw = function()
      flexbox:draw()
    end,
    name = opts.name,
    actions = opts.actions,
    style = opts.style,
  }:setName(opts.name)

  flexbox:applyLayout(e)
  return e
end

---@param dt number
function Flexbox:update(dt)
  for _, child in ipairs(self.children) do
    if child.update then
      child:update(dt)
    end
  end
end

function Flexbox:draw()
  for _, child in ipairs(self.children) do
    child:draw()
  end
end

---@param e UiElement
function Flexbox:applyLayout(e)
  local style = e:getStyle()

  -- Starting cursor for placing children
  local cr_x = self.box.x + style.extend.left
  local cr_y = self.box.y + style.extend.top

  -- Determines which axis children flow along
  local is_row = self.dir == 'row' or self.dir == 'row-reverse'
  local is_col = self.dir == 'col' or self.dir == 'col-reverse'
  local is_reverse = self.dir == 'row-reverse' or self.dir == 'col-reverse'

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

  -- First pass: place children
  for i = start_i, end_i, step do
    local child = self.children[i]
    child.box.x = cr_x
    child.box.y = cr_y

    if is_row then
      cross_axis_size = math.max(cross_axis_size, child.box.h)
      local add = child.box.w + self.gap
      cr_x = cr_x + add
      current_axis_size = current_axis_size + add
    elseif is_col then
      cross_axis_size = math.max(cross_axis_size, child.box.w)
      local add = child.box.h + self.gap
      cr_y = cr_y + add
      current_axis_size = current_axis_size + add
    end
  end

  current_axis_size = current_axis_size - self.gap

  local w = UiStyle.calculateUnit(style.width)
  local h = UiStyle.calculateUnit(style.height)

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

  if self.justify_content == 'center' then
    justify_offset = justify_space / 2
  elseif self.justify_content == 'end' then
    justify_offset = justify_space
  end

  -- Cache checks
  local is_align_end = self.align_items == 'end'
  local is_align_center = self.align_items == 'center'

  -- Second pass: apply cross-axis alignment and offset
  for _, child in pairs(self.children) do
    if is_row then
      local inner_h = self.box.h - style.extend.top - style.extend.bottom
      local base_y = self.box.y + style.extend.top

      if is_align_center then
        child.box.y = base_y + (inner_h - child.box.h) / 2
      elseif is_align_end then
        child.box.y = base_y + (inner_h - child.box.h)
      end

      child.box.x = child.box.x + justify_offset
    elseif is_col then
      local inner_w = self.box.w - style.extend.left - style.extend.right
      local base_x = self.box.x + style.extend.left

      if is_align_center then
        child.box.x = base_x + (inner_w - child.box.w) / 2
      elseif is_align_end then
        child.box.x = base_x + (inner_w - child.box.w)
      end

      child.box.y = child.box.y + justify_offset
    end

    child:updateLayout(e)
  end
end

return Flexbox
