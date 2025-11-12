local Button = require('ui.button')
local Text = require('ui.text')

return Status.build(function()
  local function continueFn()
    S.scene_queue.setNext(require('game.scenes.brickin'))
  end

  local button_size = math.vec2.new(80, 17)

  local msg = Text.new {
    text = 'GAME OVER',
    pos = S.camera.vbox:getOriginPos(Origin.CENTER - math.vec2.new(0, 0.15)),
    render_origin = Origin.CENTER,
    font = Res.fonts.IBM,
  }

  local continue = Button.new {
    text = 'Try again',
    box = {
      pos = S.camera.vbox:getOriginPos(Origin.CENTER),
      size = button_size,
      starting_origin = Origin.CENTER,
    },
    on_click = continueFn,
  }

  return Status.new {
    update = function(ctx, dt)
      if love.keyboard.isPressed(Res.keybinds.CONFIRM) then
        continueFn()
      end

      continue:update()
    end,
    draw = function()
      love.graphics.setColor(Res.colors.FOREGROUND)

      msg:draw()
      continue:draw()
    end,
  }
end)
