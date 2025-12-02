local Element = require 'ui.element'
local Fragment = require 'ui.fragment'
return function()
  return Status.new {
    ui = Element.new {
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
        Fragment.new { val = 'GAME OVER', font = Res.fonts.IBM },
        Element.new {
          style = Res.styles.BUTTON,
          events = {
            onClick = function()
              S.scene_queue.setNext(require 'game.scenes.brickin')
            end,
          },
          Fragment.new { val = 'Restart', font = Res.fonts.BASE },
        },
        Element.new {
          style = Res.styles.BUTTON,
          events = {
            onClick = function()
              love.event.quit(0)
            end,
          },
          Fragment.new { val = 'Quit', font = Res.fonts.BASE },
        },
      },
      state = {
        name = 'Gameover Menu',
      },
    },
  }
end
