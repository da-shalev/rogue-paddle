local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

local overlay = Element.new {
  style = Res.styles.OVERLAY,
  name = 'overlay',
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
      onClick = function() end,
    },
    Fragment.new('Settings', Res.fonts.BASE),
  },
  Element.new {
    style = Res.styles.BUTTON,
    events = {
      onClick = function() end,
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
}

local ui = Ui.get(Element.new {
  name = 'overlay_wrapper',
  style = {
    width = '100vw',
    height = '100vh',
    align_items = 'center',
    justify_content = 'center',
  },
  overlay,
})

print(overlay.idx)
assert(ui)

return Status.new {
  update = function(_, dt)
    Ui.update(ui, dt)
  end,
  draw = function()
    Ui.draw(ui)
  end,
}
