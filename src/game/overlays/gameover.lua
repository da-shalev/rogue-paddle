local Element = require 'ui.element'
local Fragment = require 'ui.fragment'
return function()
  local ui = Element.new {
    style = {
      width = '100vw',
      height = '100vh',
      align_items = 'center',
      justify_content = 'center',
    },
    Element.new {
      style = {
        Res.styles.OVERLAY,
      },
      Fragment.new('GAME OVER', Res.fonts.IBM),
      Element.new {
        style = Res.styles.BUTTON,
        events = {
          onClick = function()
            S.scene_queue.setNext(require 'game.scenes.brickin')
          end,
        },
        Fragment.new('Restart', Res.fonts.BASE),
      },
      Element.new {
        style = Res.styles.BUTTON,
        events = {
          onClick = function()
            love.event.quit(0)
          end,
        },
        Fragment.new('Quit', Res.fonts.BASE),
      },
    },
  }

  return Status.new {
    ui = ui,
  }
end
