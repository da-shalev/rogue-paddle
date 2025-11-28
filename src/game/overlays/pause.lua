local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

---@type UiState
local settings = {
  hidden = true,
}

---@type UiState
local score = {
  hidden = true,
}

local ui = Ui.get(Element.new {
  style = {
    width = '100vw',
    height = '100vh',
    align_items = 'center',
    justify_content = 'center',
    gap = 4,
  },
  events = {
    onClick = function()
    end,
  },
  Element.new {
    style = Res.styles.OVERLAY,
    Fragment.new('PAUSE', Res.fonts.IBM),
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
          settings.hidden = not settings.hidden
          score.hidden = true
        end,
      },
      Fragment.new('Settings', Res.fonts.BASE),
    },
    Element.new {
      style = Res.styles.BUTTON,
      events = {
        onClick = function()
          score.hidden = not score.hidden
          settings.hidden = true
        end,
      },
      Fragment.new('Scores', Res.fonts.BASE),
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
  require 'game.overlays.settings'(settings),
  require 'game.overlays.scores'(score),
})

return Status.new {
  update = function(_, dt)
    Ui.update(ui, dt)
  end,
  draw = function()
    Ui.draw(ui)
  end,
  exit = function()
    settings.hidden = true
    score.hidden = true
  end,
}
