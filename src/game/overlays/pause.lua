local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

return function()
  ---@type UiState
  local settings = Reactive.useState {
    hidden = true,
  }

  ---@type UiState
  local scores = Reactive.useState {
    hidden = true,
  }

  return Status.new {
    ui = Element.new {
      style = {
        width = '100vw',
        height = '100vh',
        align_items = 'center',
        justify_content = 'center',
        gap = 4,
      },
      Element.new {
        style = Res.styles.OVERLAY,
        Fragment.new { val = 'PAUSE', font = Res.fonts.IBM },
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
              settings.hidden = not settings.hidden
              scores.hidden = true
            end,
          },
          Fragment.new { val = 'Settings', font = Res.fonts.BASE },
        },
        Element.new {
          style = Res.styles.BUTTON,
          events = {
            onClick = function()
              scores.hidden = not scores.hidden
              settings.hidden = true
            end,
          },
          Fragment.new { val = 'Scores', font = Res.fonts.BASE },
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
      require 'game.overlays.settings'(settings),
      require 'game.overlays.scores'(scores),
    },
  }
end
