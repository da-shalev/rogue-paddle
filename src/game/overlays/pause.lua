local Text = require('ui.text')
local FBox = require('ui.flexbox')

local flexbox = FBox.new {
  flex = {
    align_items = 'center',
    justify_content = 'center',
  },
  style = {
    width = '100vw',
    height = '100vh',
  },
  children = {
    FBox.new {
      style = Res.styles.OVERLAY,
      flex = {
        dir = 'col',
        align_items = 'center',
        justify_content = 'center',
        gap = 8,
      },
      children = {
        Text.new {
          val = 'PAUSE',
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
    flexbox:update(dt)
  end,
  draw = function()
    flexbox:draw()
  end,
}
