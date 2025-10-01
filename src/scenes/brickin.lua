local game_state = require('state')
local camera = game_state.camera;

return game_state.scene.build(function()
  ---@enum State
  local states = {
    ATTACHED = 1,
    PLAYING = 2,
  }

  local state = states.ATTACHED;

  local player = {
    box = Box.fromImage(Res.sprites.player, camera.vp.w / 2, camera.vp.h - 20, 0,
      Origin.BOTTOM_CENTER),
    sprite = Res.sprites.player,
    move_x = 0,
    speed = 100,
  };

  local ball = {
    box = Box.fromImage(Res.sprites.ball, player.box.x + player.box.w / 2, player.box.y, 0, Origin.BOTTOM_CENTER),
    sprite = Res.sprites.ball,
    velocity = { x = 0, y = 0 },
    speed = 100,
  };

  ball.prev_box = Help.shallow_copy(ball.box)
  ball.render_box = Help.shallow_copy(ball.box)

  local on_update = {
    [states.ATTACHED] = function(_)
      if love.keyboard.isDown("space") or love.keyboard.isDown("up") then
        state = states.PLAYING;
      end

      local dir = math.random() < 0.5;
      ball.velocity.x = (dir and 0.5 or -0.5);
      ball.velocity.y = -1;
    end,

    [states.PLAYING] = function(_dt)
      -- detects player movement
      player.move_x = 0

      if love.keyboard.isDown("d") then
        player.move_x = player.move_x + 1
      end

      if love.keyboard.isDown("a") then
        player.move_x = player.move_x - 1
      end
    end,
  };

  local on_fixed_update = {
    -- physics of the ball are updated on a fixed timer to ensure consistancy across devices
    [states.PLAYING] = function(dt)
      ball.prev_box.x = ball.box.x
      ball.prev_box.y = ball.box.y

      local move_x = player.box.x + player.move_x * dt * player.speed
      player.box.x = math.clamp(move_x, 0, camera.vp.w - player.box.w)

      -- yes everything below this is just for a ball
      -- not to mention the other things I do

      ball.box.x = ball.box.x + ball.velocity.x * dt * ball.speed
      ball.box.y = ball.box.y + ball.velocity.y * dt * ball.speed

      -- overlap check not needed because of clamping
      local x_within, y_within = ball.box:within(camera.vp)
      if not x_within then ball.velocity.x = -ball.velocity.x end
      if not y_within then ball.velocity.y = -ball.velocity.y end
      ball.box.x = math.clamp(ball.box.x, 0, camera.vp.w - ball.box.w)
      ball.box.y = math.clamp(ball.box.y, 0, camera.vp.h - ball.box.h)

      local x_overlap, y_overlap = ball.box:collisionOverlap(player.box)

      -- checks for a collision
      if x_overlap > 0 and y_overlap > 0 then
        if x_overlap < y_overlap then
          if (ball.box.x - player.box.x) * ball.velocity.x < 0 then
            ball.velocity.x = -ball.velocity.x
          end
        else
          if (ball.box.y - player.box.y) * ball.velocity.y < 0 then
            ball.velocity.y = -ball.velocity.y
          end
        end
      end
    end,
  }

  ---@type Scene
  return {
    update = function(dt)
      Help.switch(state, on_update, dt)
    end,

    fixedUpdate = function(dt)
      Help.switch(state, on_fixed_update, dt)
    end,

    draw = function()
      player.box:drawImage(player.sprite)

      ball.render_box:interpolateTo(ball.prev_box, ball.box, game_state.alpha):drawImage(ball.sprite)
    end,

    exit = function()
    end,
  }
end)
