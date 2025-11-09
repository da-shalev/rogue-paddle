return Scene.build(function()
  --- @enum Status
  local status = {
    ATTACHED = 1,
    PLAYING = 2,
  }

  local current = status.ATTACHED

  local player = {
    sprite = Res.sprites.player:state({
      pos = math.Vec2.new(S.camera.vbox.w / 2, S.camera.vbox.h - 20),
      starting_offset = Origin.BOTTOM_CENTER,
    }),
    prev_box = Box.zero(),
    input_x = 0,
    speed = 0.55 * S.camera.vbox.w,
  }

  local ball = {
    sprite = Res.sprites.ball:state({
      pos = math.Vec2.new(player.sprite.box.x + player.sprite.box.w / 2, player.sprite.box.y),
      starting_offset = Origin.BOTTOM_CENTER,
    }),
    prev_box = Box.zero(),
    velocity = math.Vec2.zero(),
    speed = 0.5 * S.camera.vbox.w,
  }

  local on_update = {
    [status.ATTACHED] = function(_)
      if love.keyboard.isPressed('space') or love.keyboard.isPressed('up') then
        current = status.PLAYING
        ball.velocity:set((math.random() < 0.5 and 1.0 or -1.0), -1.0):normalize()
      end
    end,

    [status.PLAYING] = function(_dt)
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
    [status.PLAYING] = function(dt)
      player.prev_box:copy(player.sprite.box)
      player.sprite.box.x = player.sprite.box.x + player.input_x * dt * player.speed
      player.sprite.box:clampWithin(S.camera.vbox)

      ball.prev_box:copy(ball.sprite.box)
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

      -- Paddle collision
      local x_overlap, y_overlap = ball.sprite.box:overlaps(player.sprite.box)

      if x_overlap > 0 and y_overlap > 0 then
        -- Smaller overlap = collision axis (less penetration)
        if y_overlap < x_overlap then
          -- Y-axis collision
          if ball.sprite.box.pos.y < player.sprite.box.pos.y then
            -- stylua: ignore start

            -- Calculate hit position: -1 (left edge) to +1 (right edge)
            local hit_pos = (
            -- ball center x
              ball.sprite.box.x + ball.sprite.box.w * 0.5
              -- paddle center x
              - (player.sprite.box.x + player.sprite.box.w * 0.5)
            ) / (player.sprite.box.w * 0.5)

            -- stylua: ignore end

            -- hit_pos = math.clamp(hit_pos, -1, 1)
            -- Feels closest to my memory of the original game with unmodified hit_pos
            ball.velocity:set(hit_pos, -1):normalize()
          else
            -- Bottom of paddle - bounce downward
            ball.velocity.y = math.abs(ball.velocity.y)
          end

          ball.sprite.box:clampOutsideY(player.sprite.box)
        else
          -- X-axis collision
          if ball.sprite.box.x < player.sprite.box.x then
            ball.velocity.x = -math.abs(ball.velocity.x)
          else
            ball.velocity.x = math.abs(ball.velocity.x)
          end

          ball.sprite.box:clampOutsideX(player.sprite.box)
        end
      end
    end,
  }

  --- @type Scene
  return {
    update = function(dt)
      Help.switch(current, on_update, dt)
    end,

    fixed = function(dt)
      Help.switch(current, on_fixed_update, dt)
    end,

    draw = function()
      player.sprite:draw(player.prev_box:lerp(player.prev_box, player.sprite.box, S.alpha))
      ball.sprite:draw(ball.prev_box:lerp(ball.prev_box, ball.sprite.box, S.alpha))
    end,

    exit = function() end,
  }
end)
