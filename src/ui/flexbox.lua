---@class Flexbox
---@field box Box
---@field dir FlexDirection
---@field justify_content FlexJustifyItems
---@field align_items FlexAlignItems
---@field gap number
---@field children (UiElement)[]
---@field style? UiStyle
---@field screen? boolean
---@field name? string
---@field hover boolean
local Flexbox = {}
Flexbox.__index = Flexbox

---@alias FlexDirection "row" | "col" | "row-reverse" | "col-reverse"
---@alias FlexItemOpts "start" | "end" | "center"
---@alias FlexJustifyItems FlexItemOpts
---@alias FlexAlignItems FlexItemOpts

---@class FlexOpts
---@field dir? FlexDirection
---@field justify_content? FlexJustifyItems
---@field align_items? FlexAlignItems
---@field gap? number

---@class FlexboxOpts
---@field flex? FlexOpts
---@field style? UiStyle
---@field screen? boolean
---@field children (UiElement)[]
---@field name? string

--- a simple 'nowrap' flexbox
---@param opts FlexboxOpts
---@return UiElement
function Flexbox.new(opts)
  opts.flex = opts.flex or {}

  ---@type Flexbox
  local flex = {
    name = opts.name,
    box = opts.screen and S.camera.box:clone() or Box.zero(),
    dir = opts.flex.dir or 'row',
    justify_content = opts.flex.justify_content or 'start',
    align_items = opts.flex.align_items or 'start',
    gap = opts.flex.gap or 0,
    children = opts.children or {},
    style = opts.style or {},
    screen = opts.screen,
    hover = false,
  }

  Flexbox.apply(flex)
  local flexbox = setmetatable(flex, Flexbox)

  return {
    box = flexbox.box,
    update = function(dt)
      flexbox:update(dt)
    end,
    apply = function()
      Flexbox.apply(flexbox)
      print(flexbox.name)
    end,
    draw = function()
      flexbox:draw()
    end,
    actions = {},
  }
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
  if self.style.background_hover_color and self.hover then
    self.box:draw('fill', self.style.background_hover_color)
  elseif self.style.background_color then
    self.box:draw('fill', self.style.background_color)
  end

  if self.style.outline_hover and self.style.outline_color and self.hover then
    self.box:outline(self.style.outline_hover, self.style.outline_color)
  elseif self.style.outline and self.style.outline_hover_color and self.style.outline then
    self.box:outline(self.style.outline, self.style.outline_hover_color)
  end

  for _, child in ipairs(self.children) do
    child:draw()
  end
end

---@param flex Flexbox
Flexbox.apply = function(flex)
  local cx = flex.box.x
  local cy = flex.box.y
  local is_row = flex.dir == 'row' or flex.dir == 'row-reverse'
  local is_col = flex.dir == 'col' or flex.dir == 'col-reverse'
  local max_size = 0

  local start_i, end_i, step
  if flex.dir == 'row-reverse' or flex.dir == 'col-reverse' then
    start_i = #flex.children
    end_i = 1
    step = -1
  else
    start_i = 1
    end_i = #flex.children
    step = 1
  end

  local occupied_space_axis = 0

  for i = start_i, end_i, step do
    local child = flex.children[i]
    child.box.x = cx
    child.box.y = cy

    local add
    if is_row then
      max_size = math.max(max_size, child.box.size.y)
      add = child.box.w + flex.gap
      cx = cx + add
    elseif is_col then
      max_size = math.max(max_size, child.box.size.x)
      add = child.box.h + flex.gap
      cy = cy + add
    end

    occupied_space_axis = occupied_space_axis + add
  end

  occupied_space_axis = occupied_space_axis - flex.gap

  if is_row then
    cx = cx - flex.gap
    if not flex.screen then
      flex.box.w = cx - flex.box.x
      flex.box.h = max_size
    end
  else
    cy = cy - flex.gap
    if not flex.screen then
      flex.box.w = max_size
      flex.box.h = cy - flex.box.y
    end
  end

  local offset = 0
  local axis_size

  if is_row then
    axis_size = flex.box.w - occupied_space_axis
  elseif is_col then
    axis_size = flex.box.h - occupied_space_axis
  end

  if flex.justify_content == 'center' then
    offset = axis_size / 2
  elseif flex.justify_content == 'end' then
    offset = axis_size
  end

  for _, child in pairs(flex.children) do
    if is_row then
      if flex.align_items == 'center' then
        child.box.y = flex.box.y + (flex.box.h - child.box.h) / 2
      elseif flex.align_items == 'end' then
        child.box.y = flex.box.y + flex.box.h - child.box.h
      end

      child.box.x = child.box.x + offset
    elseif is_col then
      if flex.align_items == 'center' then
        child.box.x = flex.box.x + (flex.box.w - child.box.w) / 2
      elseif flex.align_items == 'end' then
        child.box.x = flex.box.x + flex.box.w - child.box.w
      end

      child.box.y = child.box.y + offset
    end

    if child.apply then
      child.apply()
    end
  end
end

return Flexbox
