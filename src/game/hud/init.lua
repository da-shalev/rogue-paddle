local Text = require 'ui.text'

return function()
  local Hud = {}
  local ui = {}

  ---@type UiStyle
  local indent = {
    extend = { 3 },
  }

  Hud.update = function(dt)
    ui.score:update(dt)
  end

  Hud.draw = function()
    if Hud.score.val > 0 then
      ui.score:draw()
    end

    -- if Hud.lives.val > 0 then
    ui.lives:draw()
    -- end

    ui.info:draw()
  end

  Hud.score = Text.new { val = 0, font = Res.fonts.BASE }
  Hud.info = Text.new {
    val = string.format('Press %s to begin', Res.keybinds.CONFIRM),
    font = Res.fonts.BASE,
  }

  Hud.lives = Help.proxy({ val = 0 }, function(self)
    ui.lives:clear()
    for _ = 1, self.val do
      ui.lives:addChild(Res.sprites.HEART:ui({}))
    end
  end)

  ui.score = UiElement.new {
    style = {
      {
        width = '100vw',
        justify_content = 'center',
      },
      indent,
    },
    children = {
      Hud.score:ui(),
    },
  }

  ui.info = UiElement.new {
    style = {
      {
        width = '100vw',
        height = '100vh',
        justify_content = 'center',
        align_items = 'center',
      },
    },
    children = {
      Hud.info:ui(),
    },
  }

  ui.lives = UiElement.new {
    style = {
      indent,
      {
        gap = 2,
      },
    },
    children = {},
  }

  return Hud
end
