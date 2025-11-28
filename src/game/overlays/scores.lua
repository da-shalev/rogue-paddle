local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

---@param status _UiStatus
return function(status)
  return Element.new {
    style = Res.styles.OVERLAY,
    status = status,
    Fragment.new { val = 'SCORES', font = Res.fonts.IBM },
    Fragment.new { val = 'Todo', font = Res.fonts.BASE },
  }
end
