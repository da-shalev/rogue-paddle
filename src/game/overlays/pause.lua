local Button = require('ui.button')
local Text = require('ui.text')
local Fbox = require('ui.flexbox')

local flexbox = Fbox.new({
  box = {
    pos = S.camera.box:getOriginPos(Origin.CENTER),
    size = S.camera.box.size / math.vec2.new(3, 1.5),
    starting_origin = Origin.CENTER,
  },
  flex = {
    dir = 'col',
    align_items = 'center',
    justify_items = 'center',
    gap = 3,
  },
  style = {
    background = Res.colors.REGULAR0,
    border_radius = math.vec2.splat(5),
  },
  drawables = {
    Text.new {
      text = 'PAUSE',
      font = Res.fonts.IBM,
    }:ui(),
    Button.new {
      text = 'Restart',
      style = Res.ui.BUTTON_STYLE,
      onClick = function()
        S.scene_queue.setNext(require('game.scenes.brickin'))
      end,
    }:ui(),
    Button.new {
      text = 'Scores',
      style = Res.ui.BUTTON_STYLE,
    }:ui(),
    Button.new {
      text = 'Settings',
      style = Res.ui.BUTTON_STYLE,
    }:ui(),
    Button.new {
      text = 'Quit',
      style = Res.ui.BUTTON_QUIT_STYLE,
      onClick = function()
        love.event.quit(0)
      end,
    }:ui(),
  },
})

return Status.new {
  update = function(_, dt)
    flexbox:update(dt)
  end,
  draw = function()
    flexbox:draw()
  end,
}
