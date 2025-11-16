---@class UiStyle
---@field outline? Extend
---@field outline_color? Color
---@field outline_hover? Extend
---@field outline_hover_color? Extend
---@field background_color? Color
---@field background_hover_color? Color
---@field extend Extend?

---@class ComputedUiStyle
---@field outline? ComputedExtend
---@field outline_color? Color
---@field outline_hover? ComputedExtend
---@field outline_hover_color? ComputedExtend
---@field background_color? Color
---@field background_hover_color? Color
---@field extend ComputedExtend

local UiStyle = {}

---@param opts UiStyle?
---@return ComputedUiStyle
UiStyle.new = function(opts)
  opts = opts or {}

  return {
    outline = opts.outline and Box.Extend.new(opts.outline) or nil,
    outline_color = opts.outline_color,
    outline_hover = opts.outline_hover and Box.Extend.new(opts.outline_hover) or nil,
    outline_hover_color = opts.outline_hover_color,
    background_color = opts.background_color,
    background_hover_color = opts.background_hover_color,
    extend = Box.Extend.new(opts.extend or {}),
  }
end

return UiStyle
