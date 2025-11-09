return Scene.build(function()
  local player = {
    sprite = Res.sprites.PLAYER:state {
      pos = math.vec2.new(S.camera.vbox.w / 2, S.camera.vbox.h - 20),
      starting_offset = Origin.BOTTOM_CENTER,
    },
    prev_box = math.box.zero(),
    input_x = 0,
    speed = 0.4 * S.camera.vbox.w,
  }

  local ball = {
    sprite = Res.sprites.BALL:state {
      pos = math.vec2.new(player.sprite.box.x + player.sprite.box.w / 2, player.sprite.box.y),
      starting_offset = Origin.BOTTOM_CENTER,
    },
    prev_box = math.box.zero(),
    velocity = math.vec2.zero(),
    speed = 0.4 * S.camera.vbox.w,
  }

  local bricks = require('game.brick_manager').new {
    layout = Res.layouts.DEFAULT,
    onGenerate = function(brick) end,
    onRemove = function(self, brick) end,
    onSpawn = function(self, brick) end,
  }

  --- @type Status
  local status = {
    ATTACHED = {
      update = function(self, dt)
        if love.keyboard.isPressed(Res.keybinds.CONFIRM) then
          self.current = self.status.PLAYING
          ball.velocity:set((math.random() < 0.5 and 1.0 or -1.0), -1.0):normalize()
        end
      end,
    },

    PLAYING = {
      update = function(self, dt)
        -- detects player movement
        player.input_x = 0

        if love.keyboard.isDown(Res.keybinds.RIGHT) then
          player.input_x = player.input_x + 1
        end

        if love.keyboard.isDown(Res.keybinds.LEFT) then
          player.input_x = player.input_x - 1
        end
      end,

      fixed = function(self, dt)
        player.prev_box:copy(player.sprite.box)
        ball.prev_box:copy(ball.sprite.box)

        player.sprite.box.x = player.sprite.box.x + player.input_x * dt * player.speed
        player.sprite.box:clampWithin(S.camera.vbox)

        ball.sprite.box.pos:addScaled(ball.velocity, dt * ball.speed)

        local x_within, y_within = ball.sprite.box:within(S.camera.vbox)

        if not x_within then
          ball.velocity.x = -ball.velocity.x
          ball.sprite.box:clampWithinX(S.camera.vbox)
        end

        if not y_within then
          ball.velocity.y = -ball.velocity.y
          ball.sprite.box:clampWithinY(S.camera.vbox)
        end

        bricks:collision(ball.sprite.box, ball.velocity)
        player.sprite.box:paddleCollision(ball.sprite.box, ball.velocity)
      end,
    },
  }

  return Scene.new {
    status = status,
    current = status.ATTACHED,
    fixed = function(self, dt) end,
    draw = function(self)
      player.sprite:draw(player.prev_box:lerp(player.prev_box, player.sprite.box, S.alpha))
      ball.sprite:draw(ball.prev_box:lerp(ball.prev_box, ball.sprite.box, S.alpha))
      bricks:draw()
    end,
  }
end)
