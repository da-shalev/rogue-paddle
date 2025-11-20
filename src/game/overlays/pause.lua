local Fragment = require 'ui.fragment'

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
        Res.styles.BUTTON,
      },
      children = {
        Fragment.new('PAUSE', Res.fonts.IBM),
        --   Text.new({
        --     val = 'Restart',
        --     font = Res.fonts.BASE,
        --   }):ui {
        --     actions = {
        --       onClick = function()
        --         S.scene_queue.setNext(require 'game.scenes.brickin')
        --       end,
        --     },
        --
        --     style = Res.styles.BUTTON,
        --   },
        --
        --   Text.new({
        --     val = 'Quit',
        --     font = Res.fonts.BASE,
        --   }):ui {
        --     actions = {
        --       onClick = function()
        --         love.event.quit(0)
        --       end,
        --     },
        --
        --     style = Res.styles.BUTTON,
        --   },
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
