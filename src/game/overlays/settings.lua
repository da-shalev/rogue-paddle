local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

---@param state UiState
return function(state)
  return Element.new {
    style = Res.styles.OVERLAY,
    state = state,
    Fragment.new('SETTINGS', Res.fonts.IBM),
    Fragment.new('Todo', Res.fonts.BASE),
  }
end
