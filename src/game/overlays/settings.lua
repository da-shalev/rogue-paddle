local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

---@param status UiStatus
return function(status)
  return Element.new {
    style = Res.styles.OVERLAY,
    status = status,
    Fragment.new { val = Cell.new('SETTINGS'), font = Res.fonts.IBM },
    Fragment.new { val = Cell.new('Todo'), font = Res.fonts.BASE },
  }
end
