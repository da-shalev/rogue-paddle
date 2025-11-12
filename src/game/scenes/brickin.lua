local UI_INSET = 3
local Text = require('ui.text')
return Scene.build(function()
  local state = {}
  local points = 0

  local points_text = Text.new {
    text = points,
    pos = S.camera.vbox:getOriginPos(Origin.TOP_CENTER) + math.vec2.new(0, UI_INSET),
    render_origin = Origin.TOP_CENTER,
  }

  local info_text = Text.new {
    text = string.format('Press %s to begin', Res.keybinds.CONFIRM),
    pos = S.camera.vbox:getOriginPos(Origin.CENTER),
    render_origin = Origin.CENTER,
  }

  local lives = 3

  local paddle = require('game.entities.paddle') {
    pos = math.vec2.new(S.camera.vbox.w / 2, S.camera.vbox.h - 20),
    starting_origin = Origin.BOTTOM_CENTER,
  }

  local function getBallOnPaddlePos()
    return paddle.sprite.box:getOriginPos(Origin.TOP_CENTER)
  end

  local ball = require('game.entities.ball') {
    pos = getBallOnPaddlePos(),
    starting_origin = Origin.BOTTOM_CENTER,
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
    onReset = function(e)
      points = points + 100
      points_text:setText(points)
    end,
    onRemove = function(e, brick)
      points = points + 10
      points_text:setText(points)
    end,
    onSpawn = function(e, brick) end,
    viewTransitionSpeed = 1.0,
  }

  state.ATTACHED = Status.new {
    update = function(ctx, dt)
      if love.keyboard.isPressed(Res.keybinds.CONFIRM) then
        ctx.current = state.PLAYING
        ball.velocity:set((math.random() < 0.5 and 1.0 or -1.0), -1.0):normalize()
      end
    end,

    draw = function()
      state.drawLevel()
      info_text:draw()
    end,
  }

  state.PLAYING = Status.new {
    update = function(ctx, dt)
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

    -- hearts ui
    for live = 1, lives do
      Res.sprites.HEART:draw(
        UI_INSET + (live - 1) * (Res.sprites.HEART:getWidth() + 2),
        UI_INSET,
        0
      )
    end

    -- points ui
    if points > 0 then
      points_text:draw()
    end
  end

  --- @param ctx StatusCtx
  state.removeLife = function(ctx)
    lives = lives - 1
    ball.sprite.box:setPos(getBallOnPaddlePos(), Origin.BOTTOM_CENTER)
    ball.prev_box:copy(ball.sprite.box)
    info_text:setText(string.format('Press %s to continue', Res.keybinds.CONFIRM))

    if lives == 0 then
      ctx.current = require('game.status.gameover')()
    else
      ctx.current = state.ATTACHED
    end
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
    current = state.ATTACHED,
    -- current = require('game.status.gameover')(),
  }
end)
