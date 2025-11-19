return function()
  local state = {}
  local hud = require('game.hud')
  -- hud.lives.val = Res.config.INITIAL_HEALTH

  local paddle = require('game.entities.paddle') {
    pos = Vec2.new(S.camera.box.w / 2, S.camera.box.h - 20),
    starting_origin = Origin.BOTTOM_CENTER,
  }

  local ball = require('game.entities.ball')({})

  local bricks = require('game.brick_manager').new {
    colors = {
      Color.REGULAR1,
      Color.REGULAR3,
      Color.REGULAR2,
      Color.REGULAR4,
    },
    layout = Res.layouts.DEFAULT,
    variants = {},
    onGenerate = function(brick) end,
    onReset = function(e)
      -- hud.score.val = hud.score.val + 100
    end,
    onRemove = function(e, brick)
      -- hud.score.val = hud.score.val + 10
    end,
    onSpawn = function(e, brick) end,
    viewTransitionSpeed = 1.0,
  }

  state.ATTACHED = Status.new {
    init = function()
      ball.sprite.box:setPos(
        paddle.sprite.box:getOriginPos(Origin.TOP_CENTER),
        Origin.BOTTOM_CENTER
      )

      ball.prev_box:copy(ball.sprite.box)
      -- hud.info.val = string.format('Press %s to continue', Res.keybinds.CONFIRM)
    end,
    update = function(ctx, dt)
      if love.keyboard.isPressed(Res.keybinds.CONFIRM) and not ctx:hasOverlay() then
        ctx:setStatus(state.PLAYING)
        ball.velocity:set((math.random() < 0.5 and 1.0 or -1.0), -1.0):normalize()
        -- hud.info.val = nil
      end
    end,

    draw = function(ctx)
      state.drawLevel()
    end,
  }

  state.PLAYING = Status.new {
    update = function(ctx, dt)
      if ctx:hasOverlay() then
        return
      end

      -- hud.update()

      paddle.input_x = 0

      if love.keyboard.isDown(unpack(Res.keybinds.MOVE_RIGHT)) then
        paddle.input_x = paddle.input_x + 1
      end

      if love.keyboard.isDown(unpack(Res.keybinds.MOVE_LEFT)) then
        paddle.input_x = paddle.input_x - 1
      end

      if Res.cheats then
        state.updateCheats()
      end
    end,

    fixed = function(ctx, dt)
      -- pause if menu
      if ctx:hasOverlay() then
        return
      end

      paddle.prev_box:copy(paddle.sprite.box)
      ball.prev_box:copy(ball.sprite.box)

      paddle.sprite.box.x = paddle.sprite.box.x + paddle.input_x * dt * paddle.speed
      paddle.sprite.box:clampWithin(S.camera.box, true, true, true, true)

      ball.sprite.box.pos = ball.sprite.box.pos + ball.velocity * dt * ball.speed

      local x_within, y_within = ball.sprite.box:within(S.camera.box)

      if not x_within then
        ball.velocity.x = -ball.velocity.x
        ball.sprite.box:clampWithinX(S.camera.box, true, true)
      end

      if not y_within then
        local top, bottom = ball.sprite.box:clampWithinY(S.camera.box, true, false)

        if top then
          ball.velocity.y = 1
        end

        if bottom then
          state.removeLife(ctx)
        end
      end

      bricks:removeOnCollision(ball.sprite.box, ball.velocity)
      paddle.sprite.box:paddleOnCollision(ball.sprite.box, ball.velocity)
    end,

    draw = function()
      state.drawLevel()
    end,
  }

  state.drawLevel = function()
    -- render scene objects
    paddle.sprite:drawLerp(paddle.prev_box)
    ball.sprite:drawLerp(ball.prev_box)
    bricks:draw()

    -- hud.draw()
  end

  ---@param ctx StatusCtx
  state.removeLife = function(ctx)
    -- hud.lives.val = hud.lives.val - 1

    -- if hud.lives.val == 0 then
    --   ctx:setOverlay(require('game.overlays.gameover'))
    -- else
    ctx:setStatus(state.ATTACHED)
    -- end
  end

  state.updateCheats = function()
    if love.keyboard.isPressed('r') then
      bricks:reset()
    end

    if love.mouse.isDown(2) then
      ball.sprite.box.pos:copy(S.cursor.pos)
    end
  end

  return Scene.new {
    status = state.ATTACHED,
    update = function(ctx)
      -- and lives ~= 0
      if love.keyboard.isPressed(Res.keybinds.PAUSE) then
        if ctx:hasOverlay() then
          ctx:popOverlay()
        else
          ctx:setOverlay(require('game.overlays.pause'))
        end
      end
    end,
  }
end
