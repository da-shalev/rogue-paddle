local Fragment = require 'ui.fragment'
local Tri = require 'ui.tri'

local idx = UiElement.new {
  style = {
    width = '100vw',
    height = '100vh',
    align_items = 'center',
    justify_content = 'center',
  },
  children = {
    UiElement.new {
      style = {
        Res.styles.OVERLAY,
      },
      children = {
        Fragment.new('PAUSE', Res.fonts.IBM),
        Tri.new {
          events = {
            onClick = function()
              S.scene_queue.setNext(require 'game.scenes.brickin')
            end,
          },
          body = Fragment.new('Restart', Res.fonts.BASE),
          styles = { Res.styles.BUTTON },
        },

        Tri.new {
          events = {
            onClick = function()
              love.event.quit(0)
            end,
          },
          body = Fragment.new('Quit', Res.fonts.BASE),
          styles = { Res.styles.BUTTON },
        },
      },
    },
  },
}

local ui = UiRegistry:get(idx)

return Status.new {
  update = function(_, dt)
    UiRegistry:update(ui, dt)
  end,
  draw = function()
    UiRegistry:draw(ui)
  end,
}
