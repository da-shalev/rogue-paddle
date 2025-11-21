local UiStyle = require 'ui.style'
---@class Tri
local Tri = {}

---@class TriBuilder
---@field head? UiIdx
---@field body? UiIdx
---@field tail? UiIdx
---@field events? UiElementEvents
---@field styles? UiStyles

---@param opts TriBuilder
---@return UiIdx
function Tri.new(opts)
  return UiElement.new {
    style = UiStyle.normalize {
      {
        flex_dir = 'row',
        gap = 3,
      },
      unpack(UiStyle.normalize(opts.styles)),
    },
    children = { opts.head, opts.body, opts.tail },
    events = opts.events,
  }
end

return Tri
