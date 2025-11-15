-- local Button = require('ui.button')
local Text = require('ui.text')
local Fbox = require('ui.flexbox')

local flexbox = Fbox.new({
  box = {
    pos = S.camera.box:getOriginPos(Origin.CENTER),
    size = S.camera.box.size / Vec2.new(2.5, 2),
    starting_origin = Origin.CENTER,
  },
  flex = {
    dir = 'col',
    align_items = 'center',
    justify_content = 'center',
    gap = 3,
  },
  style = Res.styles.OVERLAY,
  children = {
    Text.new {
      text = 'GAME OVER',
      font = Res.fonts.IBM,
    }:ui(),
    Button.new {
      text = 'Restart',
      style = Res.styles.BUTTON,
      onClick = function()
        S.scene_queue.setNext(require('game.scenes.brickin'))
      end,
    }:ui(),
    Button.new {
      text = 'Scores',
      style = Res.styles.BUTTON,
    }:ui(),
    Button.new {
      text = 'Quit',
      style = Res.styles.BUTTON_QUIT,
      onClick = function()
        love.event.quit(0)
      end,
    }:ui(),
  },
})

return Status.new {
  update = function(ctx, dt)
    flexbox:update(dt)
  end,
  draw = function()
    flexbox:draw()
  end,
}
