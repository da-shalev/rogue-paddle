---@alias FlexDirection "row" | "col" | "row-reverse" | "col-reverse"
---@alias FlexJustifyContent "start" | "center" | "end"
---@alias FlexAlignItems "start" | "center" | "end"

---@class UiStyleBasis
---@field border? number
---@field border_color? Color
---@field content_color? Color
---@field background_color? Color
---@field border_radius? number
---@field extend Extend?
---@field cursor? love.Cursor
---@field width? string|number
---@field height? string|number
---@field flex_dir? FlexDirection
---@field justify_content? FlexJustifyContent
---@field align_items? FlexAlignItems
---@field gap? number

---@class UiStyle : UiStyleBasis
---@field hover? UiStyleBasis

---@class ComputedUiBasis
---@field border number
---@field border_color? Color
---@field content_color? Color
---@field background_color? Color
---@field border_radius number
---@field extend ComputedExtend
---@field cursor? love.Cursor
---@field width? UiUnit
---@field height? UiUnit
---@field flex_dir FlexDirection
---@field justify_content FlexJustifyContent
---@field align_items FlexAlignItems
---@field gap number
---@field is_row boolean
---@field is_col boolean
---@field is_reverse boolean

---@class ComputedUiStyle
---@field current ComputedUiBasis
---@field base ComputedUiBasis
---@field hover ComputedUiBasis

local UiStyle = {}

---@alias UiStyles UiStyle|(UiStyle)[]

---@class UiUnit
---@field val number
---@field ext? string

---@param v string|number
---@return UiUnit
UiStyle.parse = function(v)
  if type(v) == 'number' then
    return { val = v, ext = nil }
  elseif type(v) ~= 'string' then
    return { val = nil, ext = nil }
  end

  local num, unit = v:match '^(%d+%.?%d*)(%D.*)$'
  if not num then
    print(string.format("invalid format: '%s'", v))
    return { val = nil, ext = nil }
  end

  local n = tonumber(num)
  if not n then
    print(string.format("invalid number: '%s'", num))
    return { val = nil, ext = nil }
  end

  if unit == '' then
    unit = nil
  end

  return {
    val = n,
    ext = unit,
  }
end

---@param st UiStyles
---@return UiStyle[]
function UiStyle.normalize(st)
  if not st then
    return {}
  end

  if st[1] ~= nil then
    return st
  else
    return { st }
  end
end

---@param unit UiUnit
---@return number?
function UiStyle.calculateUnit(unit)
  if unit.val == nil then
    return nil
  elseif unit.ext == nil then
    return unit.val
  elseif unit.ext == 'vw' then
    return S.camera.box.w * (unit.val / 100)
  elseif unit.ext == 'vh' then
    return S.camera.box.h * (unit.val / 100)
  end

  return unit.val
end

--- I am so interested in implementing tailwind style creation
---@param ... UiStyles
---@return ComputedUiStyle
function UiStyle.new(...)
  ---@type UiStyle
  local style = {}

  for i = 1, select('#', ...) do
    local s = select(i, ...)
    if s then
      Builtin.merge(style, s)
    end
  end

  ---@param c UiStyle|UiStyleBasis
  ---@param fb? UiStyle|UiStyleBasis
  ---@return ComputedUiBasis
  local function compute(c, fb)
    fb = fb or {}

    local flex_dir = c.flex_dir or fb.flex_dir or 'row'
    local justify_content = c.justify_content or fb.justify_content or 'start'
    local align_items = c.align_items or fb.align_items or 'start'

    ---@type ComputedUiBasis
    return {
      border = c.border or fb.border or 0,
      background_color = c.background_color or fb.background_color,
      content_color = c.content_color or fb.content_color,
      border_color = c.border_color or fb.border_color,
      border_radius = c.border_radius or fb.border_radius or 0,
      extend = Box.Extend.new(c.extend or fb.extend or 0),
      cursor = c.cursor or fb.cursor,
      width = UiStyle.parse(c.width) or UiStyle.parse(fb.width),
      height = UiStyle.parse(c.height) or UiStyle.parse(fb.height),
      flex_dir = flex_dir,
      justify_content = justify_content,
      align_items = align_items,
      gap = c.gap or fb.gap or 0,
      -- good cache yaya!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      -- FIX: except if you want to change it during runtime :( lol
      -- either proxy it or do it properly whatever flows
      is_row = flex_dir == 'row' or flex_dir == 'row-reverse',
      is_col = flex_dir == 'col' or flex_dir == 'col-reverse',
      is_reverse = flex_dir == 'row-reverse' or flex_dir == 'col-reverse',
    }
  end

  local base = compute(style)
  local hover = style.hover and compute(style.hover, style) or base
  local current = base

  ---@type ComputedUiStyle
  return {
    current = current,
    base = base,
    hover = hover,
  }
end

return UiStyle
