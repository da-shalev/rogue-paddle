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
      :ui({
        -- restart arrow
        frame_idx = 90,
      })
      :actions({
        onClick = function()
          S.scene_queue.setNext(require('game.scenes.brickin'))
        end,
      }),
    Res.sprites.ICONS:ui({
      -- power off
      frame_idx = 88,
    }),
    Res.sprites.ICONS:ui({
      -- settings
      frame_idx = 86,
    }),
    Res.sprites.ICONS:ui({
      -- timer
      frame_idx = 76,
    }),
  },
}

local flexbox = FBox.new {
  name = 'wrapper',
  flex = {
    align_items = 'center',
    justify_content = 'center',
  },
  screen = true,
  children = {
    FBox.new {
      name = 'children',
      style = Res.styles.OVERLAY,
      flex = {
        dir = 'col',
        align_items = 'center',
        justify_content = 'center',
        gap = 3,
      },
      children = {
        Text.new {
          text = 'PAUSE',
          font = Res.fonts.IBM,
        }:ui(),

        -- Button.new {
        --   drawable = restart,
        --   style = Res.styles.BUTTON,
        --   onClick = function()
        --     S.scene_queue.setNext(require('game.scenes.brickin'))
        --   end,
        -- }:ui(),
        --
        -- Button.new {
        --   drawable = Text.new {
        --     text = 'Scores',
        --   }:ui(),
        --   style = Res.styles.BUTTON,
        -- }:ui(),
        --
        -- Button.new {
        --   drawable = Text.new {
        --     text = 'Settings',
        --   }:ui(),
        --   style = Res.styles.BUTTON,
        -- }:ui(),
        --
        -- Button.new {
        --   drawable = Text.new {
        --     text = 'Quit',
        --   }:ui(),
        --   style = Res.styles.BUTTON_QUIT,
        --   onClick = function()
        --     love.event.quit(0)
        --   end,
        -- }:ui(),
        icons,
      },
    },
  },
}

return Status.new {
  update = function(_, dt)
    flexbox.update(dt)
  end,
  draw = function()
    flexbox.draw()
  end,
}
