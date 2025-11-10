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

  local points = 0
  local lives = 3

  local function ballOnPlayer()
    return math.vec2.new(player.sprite.box.x + player.sprite.box.w / 2, player.sprite.box.y)
  end

  local ball = {
    sprite = Res.sprites.BALL:state {
      pos = ballOnPlayer(),
      starting_offset = Origin.BOTTOM_CENTER,
    },
    prev_box = math.box.zero(),
    velocity = math.vec2.zero(),
    speed = 0.4 * S.camera.vbox.w,
  }

  local bricks = require('game.brick_manager').new {
    colors = {
      Res.colors.REGULAR1,
      Res.colors.REGULAR3,
      Res.colors.REGULAR2,
      Res.colors.REGULAR4,
    },
    layout = Res.layouts.DEFAULT,
    variants = {},
    onGenerate = function(brick) end,
    onReset = function(self)
      points = points + 100
    end,
    onRemove = function(self, brick)
      points = points + 10
    end,
    onSpawn = function(self, brick) end,
    viewTransitionSpeed = 1.0,
  }

  local begin_msg = string.format('Press %s to begin', Res.keybinds.CONFIRM)

  --- @type Status
  local status = {
    ATTACHED = {
      update = function(self, dt)
        if love.keyboard.isPressed(Res.keybinds.CONFIRM) then
          self.current = self.status.PLAYING
          ball.velocity:set((math.random() < 0.5 and 1.0 or -1.0), -1.0):normalize()
        end
      end,

      draw = function(self)
        love.graphics.print(
          begin_msg,
          (S.camera.vbox.w - Res.font:getWidth(begin_msg)) / 2,
          S.camera.vbox.h / 2
        )
      end,
    },

    PLAYING = {
      update = function(self, dt)
        player.input_x = 0

        if love.keyboard.isDown(unpack(Res.keybinds.MOVE_RIGHT)) then
          player.input_x = player.input_x + 1
        end

        if love.keyboard.isDown(unpack(Res.keybinds.MOVE_LEFT)) then
          player.input_x = player.input_x - 1
        end

        if Res.cheats then
          if love.keyboard.isPressed('r') then
            bricks:reset()
          end

          if love.mouse.isDown(1) then
            local x, y = love.mouse.getPosition()
            local brick = bricks:gridWorldAt(x, y)

            if brick then
              bricks:remove(brick)
            end
          end
        end
      end,

      fixed = function(self, dt)
        player.prev_box:copy(player.sprite.box)
        ball.prev_box:copy(ball.sprite.box)

        player.sprite.box.x = player.sprite.box.x + player.input_x * dt * player.speed
        player.sprite.box:clampWithin(S.camera.vbox, true, true, true, true)

        ball.sprite.box.pos:addScaled(ball.velocity, dt * ball.speed)

        local x_within, y_within = ball.sprite.box:within(S.camera.vbox)

        if not x_within then
          ball.velocity.x = -ball.velocity.x
          ball.sprite.box:clampWithinX(S.camera.vbox, true, true)
        end

        if not y_within then
          local top, bottom = ball.sprite.box:clampWithinY(S.camera.vbox, true, false)

          if top then
            ball.velocity.y = -ball.velocity.y
          end

          if bottom then
            lives = lives - 1
            ball.sprite.box.pos = ballOnPlayer():subScaled(ball.sprite.box.size, Origin.CENTER)
            self.current = self.status.ATTACHED
          end
        end

        bricks:removeOnCollision(ball.sprite.box, ball.velocity)
        player.sprite.box:paddleCollision(ball.sprite.box, ball.velocity)
      end,

      draw = function() end,
    },
  }

  return Scene.new {
    status = status,
    current = status.ATTACHED,
    fixed = function(self, dt) end,
    draw = function(self)
      player.sprite:drawLerp(player.prev_box)
      ball.sprite:drawLerp(ball.prev_box)
      love.graphics.print(points, (S.camera.vbox.w - Res.font:getWidth(points)) / 2, 3)
      bricks:draw()

      for live = 1, lives do
        Res.sprites.HEART:draw(3 + (live - 1) * (Res.sprites.HEART:getWidth() + 2), 3, 0)
      end
    end,
  }
end)
