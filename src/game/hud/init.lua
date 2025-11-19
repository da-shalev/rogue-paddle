local Text = require 'ui.text'
local FBox = require 'ui.flexbox'

return function()
  local Hud = {}
  local ui = {}

  ---@type UiStyle
  local indent = {
    extend = { 3 },
  }

  Hud.update = function(dt)
    ui.score:update(dt)
  end

  Hud.draw = function()
    if Hud.score.val > 0 then
      ui.score:draw()
    end
  end

  Hud.score = Text.new { val = 0, font = Res.fonts.BASE }
  Hud.lives = Help.proxy({ val = Res.config.INITIAL_HEALTH }, function(val)
    print('hi')
  end)

  ui.score = FBox.new {
    flex = {
      justify_content = 'center',
    },
    style = {
      {
        width = '100vw',
      },
      indent,
    },
    children = {
      Hud.score:ui(),
    },
  }

  ui.lives = FBox.new {
    children = {},
  }

  return Hud
end
