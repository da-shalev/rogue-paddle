local game_state = require('state')
local camera = game_state.camera

return game_state.scene.build(function()
  ---@enum State
  local states = {
    ATTACHED = 1,
    PLAYING = 2,
  }

  local state = states.ATTACHED

  local player = {
    box = Box.fromImage(
      Res.sprites.player,
      camera.vbox.w / 2,
      camera.vbox.h - 20,
      0,
      Origin.BOTTOM_CENTER
    ),
    sprite = Res.sprites.player,
    input_x = 0,
    speed = 100,
  }

  player.prev_box = Help.shallowCopy(player.box)
  player.render_box = Help.shallowCopy(player.box)

  local ball = {
    box = Box.fromImage(
      Res.sprites.ball,
      player.box.x + player.box.w / 2,
      player.box.y,
      0,
      Origin.BOTTOM_CENTER
    ),
    sprite = Res.sprites.ball,
    velocity = { x = 0, y = 0 },
    speed = 100,
  }

  ball.prev_box = Help.shallowCopy(ball.box)
  ball.render_box = Help.shallowCopy(ball.box)

  local on_update = {
    [states.ATTACHED] = function(_)
      if love.keyboard.isDown('space') or love.keyboard.isDown('up') then
        state = states.PLAYING
      end

      local dir = math.random() < 0.5
      ball.velocity.x = (dir and 0.5 or -0.5)
      ball.velocity.y = -1
    end,

    [states.PLAYING] = function(_dt)
      -- detects player movement
      player.input_x = 0

      if love.keyboard.isDown('d') then
        player.input_x = player.input_x + 1
      end

      if love.keyboard.isDown('a') then
        player.input_x = player.input_x - 1
      end
    end,
  }

  local on_fixed_update = {
    -- physics of the ball are updated on a fixed timer to ensure consistancy across devices
    [states.PLAYING] = function(dt)
      player.prev_box:copy(player.box)
      player.box.x = player.box.x + player.input_x * dt * player.speed
      player.box:clampWithin(camera.vbox)

      ball.prev_box:copy(ball.box)
      ball.box.x = ball.box.x + ball.velocity.x * dt * ball.speed
      ball.box.y = ball.box.y + ball.velocity.y * dt * ball.speed

      local x_within, y_within = ball.box:within(camera.vbox)

      if not x_within then
        ball.velocity.x = -ball.velocity.x
      end

      if not y_within then
        ball.velocity.y = -ball.velocity.y
      end

      ball.box:clampWithin(camera.vbox)

      -- previous approach won't work here because x is resolved before y
      -- this is more precise
      local x_overlap, y_overlap = ball.box:overlaps(player.box)

      if x_overlap > 0 and y_overlap > 0 then
        if x_overlap < y_overlap then
          ball.velocity.x = -ball.velocity.x
          ball.box:clampOutsideX(player.box)
        else
          ball.velocity.y = -ball.velocity.y
          ball.box:clampOutsideY(player.box)
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
      player.render_box
        :interpolate(player.prev_box, player.box, game_state.alpha)
        :drawImage(player.sprite)
      ball.render_box:interpolate(ball.prev_box, ball.box, game_state.alpha):drawImage(ball.sprite)
    end,

    exit = function() end,
  }
end)
