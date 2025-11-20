local e = UiNode.new {
  style = {
    width = '100vw',
    height = '100vh',
    align_items = 'center',
    justify_content = 'center',
  },
  children = {
    UiNode.new {
      style = Res.styles.OVERLAY,
      children = {
        Text.new({
          val = 'GAME OVER',
          font = Res.fonts.IBM,
        }):ui(),

        Text.new({
          val = 'Restart',
          font = Res.fonts.BASE,
        }):ui {
          onClick = function()
            S.scene_queue.setNext(require 'game.scenes.brickin')
          end,
          style = Res.styles.BUTTON,
        },

        Text.new({
          val = 'Quit',
          font = Res.fonts.BASE,
        }):ui {
          onClick = function()
            love.event.quit(0)
          end,
          style = Res.styles.BUTTON,
        },
      },
    },
  },
}

return Status.new {
  update = function(_, dt)
    UiRegistry:update(e, dt)
  end,
  draw = function()
    UiRegistry:draw(e)
  end,
}
