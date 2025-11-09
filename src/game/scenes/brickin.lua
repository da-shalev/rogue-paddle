return Scene.build(function()
  local player = {
    sprite = Res.sprites.PLAYER:state {
      pos = math.vec2.new(S.camera.vbox.w / 2, S.camera.vbox.h - 20),
      starting_offset = Origin.BOTTOM_CENTER,
    },
    prev_box = math.box.zero(),
    input_x = 0,
    speed = 0.55 * S.camera.vbox.w,
  }

  local ball = {
    sprite = Res.sprites.BALL:state {
      pos = math.vec2.new(player.sprite.box.x + player.sprite.box.w / 2, player.sprite.box.y),
      starting_offset = Origin.BOTTOM_CENTER,
    },
    prev_box = math.box.zero(),
    velocity = math.vec2.zero(),
    speed = 0.5 * S.camera.vbox.w,
  }

  local bricks = require('game.bricks').new(Res.levels.DEFAULT)

  --- @type Status
  local status = {
    ATTACHED = {
      update = function(self, dt)
        if love.keyboard.isPressed('space') or love.keyboard.isPressed('up') then
          self.current = self.status.PLAYING
          ball.velocity:set((math.random() < 0.5 and 1.0 or -1.0), -1.0):normalize()
        end
      end,
    },

    PLAYING = {
      update = function(self, dt)
        -- detects player movement
        player.input_x = 0

        if love.keyboard.isDown('d') then
          player.input_x = player.input_x + 1
        end

        if love.keyboard.isDown('a') then
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

        local brick_col = bricks:check_collision(ball.sprite.box)

        if brick_col.top then
          ball.velocity.y = -ball.velocity.y
          ball.sprite.box:clampOutsideY(brick_col.top.sprite.box)
          bricks.data.grid[brick_col.top.y][brick_col.top.x] = nil
        elseif brick_col.bottom then
          ball.velocity.y = -ball.velocity.y
          ball.sprite.box:clampOutsideY(brick_col.bottom.sprite.box)
          bricks.data.grid[brick_col.bottom.y][brick_col.bottom.x] = nil
        end

        if brick_col.left then
          ball.velocity.x = -ball.velocity.x
          ball.sprite.box:clampOutsideX(brick_col.left.sprite.box)
          bricks.data.grid[brick_col.left.y][brick_col.left.x] = nil
        elseif brick_col.right then
          ball.velocity.x = -ball.velocity.x
          ball.sprite.box:clampOutsideX(brick_col.right.sprite.box)
          bricks.data.grid[brick_col.right.y][brick_col.right.x] = nil
        end

        player.sprite.box:paddle(ball.sprite.box, ball.velocity)
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
