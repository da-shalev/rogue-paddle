---@class Flexbox
---@field box Box
---@field dir FlexDirection
---@field justify_items FlexJustifyItems
---@field align_items FlexAlignItems
---@field gap number
---@field drawables (UiDrawable)[]
---@field style? BoxStyle
local Flexbox = {}
Flexbox.__index = Flexbox

---@class UiDrawable
---@field box Box
---@field updatePos? fun()
---@field update? fun(dt: number)
---@field draw fun()

---@alias FlexDirection "row" | "col" | "row-reverse" | "col-reverse"
---@alias FlexItemOpts "start" | "end" | "center"
---@alias FlexJustifyItems FlexItemOpts
---@alias FlexAlignItems FlexItemOpts

---@class FlexOpts
---@field dir? FlexDirection
---@field justify_items? FlexJustifyItems
---@field align_items? FlexAlignItems
---@field gap? number

---@class FlexboxOpts
---@field box BoxOpts
---@field flex? FlexOpts
---@field style? BoxStyle
---@field drawables (UiDrawable)[]

--- a simple 'nowrap' flexbox
---@param opts FlexboxOpts
---@return Flexbox
function Flexbox.new(opts)
  opts.flex = opts.flex or {}

  ---@type Flexbox
  local flex = {
    box = math.box.from(opts.box),
    dir = opts.flex.dir or 'row',
    justify_items = opts.flex.justify_items or 'start',
    align_items = opts.flex.align_items or 'start',
    gap = opts.flex.gap or 0,
    drawables = opts.drawables or {},
    style = opts.style,
  }

  Flexbox.apply(flex)

  return setmetatable(flex, Flexbox)
end

---@param dt number
function Flexbox:update(dt)
  for _, drawable in ipairs(self.drawables) do
    if drawable.update then
      drawable.update(dt)
    end
  end
end

function Flexbox:draw()
  if self.style then
    self.box:drawFrom(self.style)
  end

  for _, drawable in ipairs(self.drawables) do
    drawable.draw()
  end
end

---@param flex Flexbox
Flexbox.apply = function(flex)
  local cx = flex.box.pos.x
  local cy = flex.box.pos.y
  local is_row = flex.dir == 'row' or flex.dir == 'row-reverse'
  local is_col = flex.dir == 'col' or flex.dir == 'col-reverse'

  local start_i, end_i, step = 1, #flex.drawables, 1
  if flex.dir == 'row-reverse' or flex.dir == 'col-reverse' then
    start_i, end_i, step = #flex.drawables, 1, -1
  end

  local size = 0

  for i = start_i, end_i, step do
    local draw = flex.drawables[i]
    draw.box.pos.x = cx
    draw.box.pos.y = cy

    if is_row then
      if flex.align_items == 'center' then
        draw.box.pos.y = cy + (flex.box.size.y - draw.box.size.y) / 2
      elseif flex.align_items == 'end' then
        draw.box.pos.y = cy + flex.box.size.y - draw.box.size.y
      end

      local add = draw.box.size.x + flex.gap
      cx = cx + add
      size = size + add
    elseif is_col then
      if flex.align_items == 'center' then
        draw.box.pos.x = cx + (flex.box.size.x - draw.box.size.x) / 2
      elseif flex.align_items == 'end' then
        draw.box.pos.x = cx + flex.box.size.x - draw.box.size.x
      end

      local add = draw.box.size.y + flex.gap

      cy = cy + add
      size = size + add
    end
  end

  size = size - flex.gap

  local offset = 0
  local axis_size = is_row and flex.box.size.x or flex.box.size.y

  if flex.justify_items == 'center' then
    offset = (axis_size - size) / 2
  elseif flex.justify_items == 'end' then
    offset = axis_size - size
  end

  for _, draw in ipairs(flex.drawables) do
    if is_row then
      draw.box.pos.x = draw.box.pos.x + offset
    elseif is_col then
      draw.box.pos.y = draw.box.pos.y + offset
    end

    if draw.updatePos then
      draw.updatePos()
    end
  end
end

return Flexbox
