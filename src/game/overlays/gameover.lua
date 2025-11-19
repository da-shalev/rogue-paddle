local Text = require('ui.text')

local e = UiElement.new {
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
          val = 'GAME OVER',
          font = Res.fonts.IBM,
        }:ui(),

        Text.new {
          val = 'Restart',
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
          val = 'Quit',
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
    e:update(dt)
  end,
  draw = function()
    e:draw()
  end,
}
