return State.scene.build(function()
  ---@enum State
  local states = {
    ATTACHED = 1,
    PLAYING = 2,
  }

  local state = states.ATTACHED;

  local player = {
    box = Box.fromImage(Res.sprites.player, State.canvas.vp.w / 2, State.canvas.vp.h - 20, 0, Origin.BOTTOM_CENTER),
    sprite = Res.sprites.player,
  };

  local ball = {
    box = Box.fromImage(Res.sprites.ball, player.box.x + player.box.w / 2, player.box.y, 0, Origin.BOTTOM_CENTER),
    sprite = Res.sprites.ball,
    velocity = { x = 0, y = 0 },
  };

  local on_update = {
    [states.ATTACHED] = function(_)
      --

      if love.keyboard.isDown("space") or love.keyboard.isDown("up") then
        state = states.PLAYING;
      end

      local dir = math.random() < 0.5;
      ball.velocity.x = (dir and 0.5 or -0.5);
      ball.velocity.y = -1;

      --
    end,
    [states.PLAYING] = function(dt)
      --

      local mX = 0

      if love.keyboard.isDown("d") then
        mX = mX + 1
      end

      if love.keyboard.isDown("a") then
        mX = mX - 1
      end

      mX = player.box.x + mX * dt * 100

      player.box.x = math.clamp(mX, 0, State.canvas.vp.w - player.box.w);

      ball.box.x = math.clamp(ball.box.x, 0, State.canvas.vp.w - ball.box.w)
      ball.box.y = math.clamp(ball.box.y, 0, State.canvas.vp.h - ball.box.h)
      ball.box.x = ball.box.x + ball.velocity.x * dt * 100
      ball.box.y = ball.box.y + ball.velocity.y * dt * 100

      local xWithin, yWithin = ball.box:withinAxes(State.canvas.vp)

      if not xWithin then
        ball.velocity.x = -ball.velocity.x
      end

      if not yWithin then
        ball.velocity.y = -ball.velocity.y
      end

      local xCollide, yCollide = ball.box:collidesAxes(player.box)
      if xCollide and yCollide then
        if xCollide then
          ball.velocity.x = -ball.velocity.x
        end

        if yCollide then
          ball.velocity.y = -ball.velocity.y
        end
      end

      --
    end,
  };


  ---@type Scene
  return {
    update = function(dt)
      Help.switch(state, on_update, dt)
    end,

    draw = function()
      ball.box:drawImage(ball.sprite)
      player.box:drawImage(player.sprite)
    end,

    exit = function()
    end,
  }
end)
