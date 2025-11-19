local Text = require('ui.text')

local flexbox = UiElement.new {
  style = {
    width = '100vw',
    height = '100vh',
    align_items = 'center',
    justify_content = 'center',
  },
  children = {
    UiElement.new {
      style = Res.styles.OVERLAY,
      children = {
        Text.new {
          value = 'GAME OVER',
          font = Res.fonts.IBM,
        }:ui(),

        Text.new {
          value = 'Restart',
          font = Res.fonts.BASE,
        }
          :ui()
          :setActions({
            onClick = function()
              S.scene_queue.setNext(require('game.scenes.brickin'))
            end,
          })
          :setStyle(Res.styles.BUTTON),

        Text.new {
          value = 'Quit',
          font = Res.fonts.BASE,
        }
          :ui()
          :setActions({
            onClick = function()
              love.event.quit(0)
            end,
          })
          :setStyle(Res.styles.BUTTON),
      },
    },
  },
}

return Status.new {
  update = function(_, dt)
    flexbox:update(dt)
  end,
  draw = function()
    flexbox:draw()
  end,
}
