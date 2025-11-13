local Button = require('ui.button')
local Text = require('ui.text')

return function()
  local OFFSET = 5
  local box = math.box.from({
    pos = S.camera.vbox:getOriginPos(Origin.CENTER),
    size = math.vec2.new(S.camera.vbox.w / 3, S.camera.vbox.h / 2 - 10),
    starting_origin = Origin.CENTER,
  })

  local msg = Text.new {
    text = 'PAUSE',
    pos = Res.ui.offset(-2, OFFSET),
    render_origin = Origin.CENTER,
    font = Res.fonts.IBM,
  }

  local scores = Button.new {
    text = 'Scores',
    box = {
      pos = Res.ui.offset(-1, OFFSET - 2),
      size = Res.ui.BUTTON_SIZE,
      starting_origin = Origin.CENTER,
    },
    colors = Res.ui.BUTTON_STYLE,
  }

  local settings = Button.new {
    text = 'Settings',
    box = {
      pos = Res.ui.offset(0, OFFSET - 2),
      size = Res.ui.BUTTON_SIZE,
      starting_origin = Origin.CENTER,
    },
    colors = Res.ui.BUTTON_STYLE,
  }

  local quit = Button.new {
    text = 'Quit',
    box = {
      pos = Res.ui.offset(1, OFFSET - 2),
      size = Res.ui.BUTTON_SIZE,
      starting_origin = Origin.CENTER,
    },
    colors = Res.ui.BUTTON_QUIT_STYLE,
    on_click = function()
      love.event.quit(0)
    end,
  }

  return Status.new {
    update = function(ctx, dt)
      scores:update()
      settings:update()
      quit:update()
    end,
    draw = function()
      box:draw('fill', Res.colors.REGULAR0)
      msg:draw()
      scores:draw()
      settings:draw()
      quit:draw()
    end,
  }
end
