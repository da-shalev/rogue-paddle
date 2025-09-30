return Scene.build(function()
  return {
    name = "Brickin",
    player = {
      box = Box.fromImage(Res.sprites.player, 0, Canvas.vh - 20, 0, Origin.BOTTOM_CENTER),
      sprite = Res.sprites.player,
    },

    update = function(self, dt)
      local mX = 0

      if love.keyboard.isDown("d") then
        mX = mX + 1
      end

      if love.keyboard.isDown("a") then
        mX = mX - 1
      end

      self.player.box.x = self.player.box.x + (mX * dt * 100)
    end,

    draw = function(self)
      love.graphics.setColor(1, 1, 1, 1)

      self.player.box:drawImage(self.player.sprite)
    end,

    exit = function(self)
    end
  }
end)
