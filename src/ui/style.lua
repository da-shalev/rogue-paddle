---@alias FlexDirection "row" | "col" | "row-reverse" | "col-reverse"
---@alias FlexJustifyContent "start" | "center" | "end"
---@alias FlexAlignItems "start" | "center" | "end"

---@class UiStyle
---@field border? number
---@field border_color? Color
---@field content_color? Color
---@field content_hover_color? Color
---@field background_color? Color
---@field background_hover_color? Color
---@field border_radius? number
---@field extend Extend?
---@field hover_cursor? love.Cursor
---@field width? string
---@field height? string
---@field flex_dir? FlexDirection
---@field justify_content? FlexJustifyContent
---@field align_items? FlexAlignItems
---@field gap? number

---@class ComputedUiColor
---@field color Color
---@field base_color Color
---@field hover_color Color

---@class ComputedUiStyle
---@field border? number
---@field border_color? Color
---@field content ComputedUiColor
---@field background ComputedUiColor
---@field border_radius number
---@field extend ComputedExtend
---@field hover_cursor? love.Cursor
---@field width UiUnit
---@field height UiUnit
---@field flex_dir FlexDirection
---@field justify_content FlexJustifyContent
---@field align_items FlexAlignItems
---@field gap number

local UiStyle = {}

---@alias UiStyles UiStyle|(UiStyle)[]

---@class UiUnit
---@field val number
---@field ext? string

---@param str string
---@return UiUnit?
UiStyle.parse = function(str)
  if type(str) ~= 'string' then
    return nil
  end

  local num, unit = str:match('^(%d+%.?%d*)(%D.*)$')
  if not num then
    print(string.format("invalid format: '%s'", str))
    return nil
  end

  local n = tonumber(num)
  if not n then
    print(string.format("invalid number: '%s'", num))
    return nil
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
---@return ComputedUiStyle
function UiStyle.normalize(st)
  if not st then
    return UiStyle.new()
  end

  if st[1] ~= nil then
    return UiStyle.new(unpack(st))
  end

  return UiStyle.new(st)
end

---@param unit? UiUnit
---@return number?
function UiStyle.calculateUnit(unit)
  if not unit then
    return nil
  elseif not unit.ext then
    return nil
  elseif unit.ext == 'px' then
    return unit.val
  elseif unit.ext == 'vw' then
    return S.camera.box.w * (unit.val / 100)
  elseif unit.ext == 'vh' then
    return S.camera.box.h * (unit.val / 100)
  end

  return unit.val
end

---@param ... UiStyles
---@return ComputedUiStyle
UiStyle.new = function(...)
  ---@type UiStyle
  local s = {}
  for _, style in ipairs({ ... }) do
    if style then
      for k, v in pairs(style) do
        s[k] = v
      end
    end
  end

  ---@type ComputedUiStyle
  return {
    border = s.border,
    border_color = s.border_color,
    border_radius = s.border_radius or 0,
    background = {
      color = s.background_color,
      base_color = s.background_color,
      hover_color = s.background_hover_color,
    },
    content = {
      color = s.content_color,
      base_color = s.content_color,
      hover_color = s.content_hover_color,
    },
    extend = Box.Extend.new(s.extend or 0),
    hover_cursor = s.hover_cursor,
    width = UiStyle.parse(s.width) or {
      val = 0,
      ext = nil,
    },
    height = UiStyle.parse(s.height) or {
      val = 0,
      ext = nil,
    },
    flex_dir = s.flex_dir or 'row',
    justify_content = s.justify_content or 'start',
    align_items = s.align_items or 'start',
    gap = s.gap or 0,
  }
end

return UiStyle
