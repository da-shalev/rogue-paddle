local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

---@param state UiState
return function(state)
  return Element.new {
    style = Res.styles.OVERLAY,
    state = state,
    Fragment.new { val = Cell.new 'SCORES', font = Res.fonts.IBM },
    Fragment.new { val = Cell.new 'Todo', font = Res.fonts.BASE },
  }
end
