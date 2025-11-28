local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

---@param state _UiStateBuilder
return function(state)
  return Element.new {
    style = Res.styles.OVERLAY,
    state = state,
    Fragment.new { val = 'SCORES', font = Res.fonts.IBM },
    Fragment.new { val = 'Todo', font = Res.fonts.BASE },
  }
end
