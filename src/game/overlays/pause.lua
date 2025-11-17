-- local Button = require('ui.button')
local Text = require('ui.text')
local FBox = require('ui.flexbox')

local icons = FBox.new {
  name = 'icons',
  flex = {
    dir = 'row',
    align_items = 'center',
    justify_content = 'center',
    gap = 3,
  },
  children = {
    Res.sprites.ICONS
      :ui {
        -- restart arrow
        frame_idx = 90,
      }
      :setActions {
        onClick = function()
          S.scene_queue.setNext(require('game.scenes.brickin'))
        end,
      }
      :setStyle(Res.styles.BUTTON),

    Res.sprites.ICONS
      :ui {
        -- power off
        frame_idx = 88,
      }
      :setActions {
        onClick = function()
          love.event.quit(0)
        end,
      }
      :setStyle(Res.styles.BUTTON),

    Res.sprites.ICONS:ui {
      -- timer
      frame_idx = 76,
    },

    Res.sprites.ICONS
      :ui {
        -- settings
        frame_idx = 86,
      }
      :setStyle(Res.styles.BUTTON),
  },
}

local flexbox = FBox.new {
  flex = {
    align_items = 'center',
    justify_content = 'center',
  },
  style = { {
    width = '100vw',
    height = '100vh',
  } },
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
          text = 'PAUSE',
          font = Res.fonts.IBM,
        }:ui(),

        Text.new {
          text = 'Restart',
          font = Res.fonts.DEFAULT,
        }
          :ui()
          :setActions({
            onClick = function()
              S.scene_queue.setNext(require('game.scenes.brickin'))
            end,
          })
          :setStyle(Res.styles.TEXT, Res.styles.BUTTON),

        Text.new {
          text = 'Times',
          font = Res.fonts.DEFAULT,
        }
          :ui()
          :setActions({
            onClick = function() end,
          })
          :setStyle(Res.styles.TEXT, Res.styles.BUTTON),

        Text.new {
          text = 'Settings',
          font = Res.fonts.DEFAULT,
        }
          :ui()
          :setActions({
            onClick = function() end,
          })
          :setStyle(Res.styles.TEXT, Res.styles.BUTTON),

        Text.new {
          text = 'Quit',
          font = Res.fonts.DEFAULT,
        }
          :ui()
          :setActions({
            onClick = function()
              love.event.quit(0)
            end,
          })
          :setStyle(Res.styles.TEXT, Res.styles.BUTTON),

        icons,
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
