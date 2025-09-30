return Scene.build(function()
  local player = {
    box = Box.fromImage(Res.sprites.player, 0, Canvas.vh - 20, 0, Origin.BOTTOM_CENTER),
    sprite = Res.sprites.player,
  };

  ---@type Scene
  return {
    update = function(dt)
      local mX = 0

      if love.keyboard.isDown("d") then
        mX = mX + 1
      end

      if love.keyboard.isDown("a") then
        mX = mX - 1
      end

      player.box.x = player.box.x + (mX * dt * 100)
    end,

    draw = function()
      player.box:drawImage(player.sprite)
    end,

    exit = function()
    end,
  }
end)
