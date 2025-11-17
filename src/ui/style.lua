---@class UiStyle
---@field border? number
---@field border_color? Color
---@field background_color? Color
---@field background_hover_color? Color
---@field border_radius? number
---@field extend Extend?

---@class UiBorderStyle

---@class ComputedUiStyle
---@field border? number
---@field border_color? Color
---@field background_color? Color
---@field background_hover_color? Color
---@field border_radius number
---@field extend ComputedExtend

local UiStyle = {}

---@param opts UiStyle?
---@return ComputedUiStyle
UiStyle.new = function(opts)
  opts = opts or {}

  local extend = Box.Extend.new(opts.extend or opts.border or 0)
  if opts.border then
    Box.Extend.add(extend, opts.border)
  end

  ---@type ComputedUiStyle
  return {
    border = opts.border,
    border_color = opts.border_color,
    border_radius = opts.border_radius or 0,
    background_color = opts.background_color,
    background_hover_color = opts.background_hover_color,
    extend = extend,
  }
end

return UiStyle
