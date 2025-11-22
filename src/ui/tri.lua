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
    style = {
      {
        flex_dir = 'row',
        gap = 3,
      },
      unpack(UiStyle.normalize(opts.styles)),
    },
    events = opts.events,
    opts.head,
    opts.body,
    opts.tail,
  }
end

return Tri
