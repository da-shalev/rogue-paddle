return Scene.build(function()
  local status = {}
  local points = 0
  local lives = 3

  local paddle = require('game.entities.paddle') {
    pos = math.vec2.new(S.camera.vbox.w / 2, S.camera.vbox.h - 20),
    starting_offset = Origin.BOTTOM_CENTER,
  }

  local function getBallOnPaddlePos()
    return paddle.sprite.box:getOffsetPos(Origin.TOP_CENTER)
  end

  local ball = require('game.entities.ball') {
    pos = getBallOnPaddlePos(),
    starting_offset = Origin.BOTTOM_CENTER,
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

  local function cheats()
    if love.keyboard.isPressed('r') then
      bricks:reset()
    end

    if love.mouse.isDown(2) then
      local x, y = love.mouse.getPosition()
      ball.sprite.box:setPos(math.vec2.new(x, y), Origin.CENTER)
    end
  end

  local attach_msg = string.format('Press %s to begin', Res.keybinds.CONFIRM)

  --- @param ctx SceneCtx
  local function removeLive(ctx)
    lives = lives - 1
    ball.sprite.box:setPos(getBallOnPaddlePos(), Origin.BOTTOM_CENTER)
    ball.prev_box:copy(ball.sprite.box)
    attach_msg = string.format('Press %s to continue', Res.keybinds.CONFIRM)
    ctx.current = status.ATTACHED
  end

  --- @type Status
  status.ATTACHED = {
    update = function(ctx, dt)
      if love.keyboard.isPressed(Res.keybinds.CONFIRM) then
        ctx.current = status.PLAYING
        ball.velocity:set((math.random() < 0.5 and 1.0 or -1.0), -1.0):normalize()
      end
    end,

    draw = function()
      love.graphics.print(
        attach_msg,
        (S.camera.vbox.w - Res.font:getWidth(attach_msg)) / 2,
        S.camera.vbox.h / 2
      )
    end,
  }

  --- @type Status
  status.PLAYING = {
    update = function(ctx, dt)
      paddle.input_x = 0

      if love.keyboard.isDown(unpack(Res.keybinds.MOVE_RIGHT)) then
        paddle.input_x = paddle.input_x + 1
      end

      if love.keyboard.isDown(unpack(Res.keybinds.MOVE_LEFT)) then
        paddle.input_x = paddle.input_x - 1
      end

      if Res.cheats then
        cheats()
      end
    end,

    fixed = function(ctx, dt)
      paddle.prev_box:copy(paddle.sprite.box)
      ball.prev_box:copy(ball.sprite.box)

      paddle.sprite.box.x = paddle.sprite.box.x + paddle.input_x * dt * paddle.speed
      paddle.sprite.box:clampWithin(S.camera.vbox, true, true, true, true)

      ball.sprite.box.pos = ball.sprite.box.pos + ball.velocity * dt * ball.speed

      local x_within, y_within = ball.sprite.box:within(S.camera.vbox)

      if not x_within then
        ball.velocity.x = -ball.velocity.x
        ball.sprite.box:clampWithinX(S.camera.vbox, true, true)
      end

      if not y_within then
        local top, bottom = ball.sprite.box:clampWithinY(S.camera.vbox, true, false)

        if top then
          ball.velocity.y = 1
        end

        if bottom then
          removeLive(ctx)
        end
      end

      bricks:removeOnCollision(ball.sprite.box, ball.velocity)
      paddle.sprite.box:paddleOnCollision(ball.sprite.box, ball.velocity)
    end,
  }

  return Scene.new {
    current = status.ATTACHED,
    draw = function()
      -- render scene objects
      paddle.sprite:drawLerp(paddle.prev_box)
      ball.sprite:drawLerp(ball.prev_box)
      bricks:draw()

      love.graphics.setColor(Res.colors.RESET)

      -- hearts ui
      for live = 1, lives do
        Res.sprites.HEART:draw(3 + (live - 1) * (Res.sprites.HEART:getWidth() + 2), 3, 0)
      end

      -- points ui
      if points > 0 then
        love.graphics.print(points, (S.camera.vbox.w - Res.font:getWidth(points)) / 2, 3)
      end
    end,
  }
end)
