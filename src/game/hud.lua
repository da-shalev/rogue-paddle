local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

local M = {}
local hud = {}

---@type UiStyle
local indent = {
  extend = { 3 },
}

M.update = function(dt)
  Ui.update(hud.score, dt)
  Ui.update(hud.lives, dt)
  Ui.update(hud.info, dt)
end

M.draw = function()
  if M.score.val > 0 then
    Ui.draw(hud.score)
  end

  if M.lives.val > 0 then
    Ui.draw(hud.lives)
  end

  if M.info.val then
    Ui.draw(hud.info)
  end
end

local score = Fragment.new('0', Res.fonts.BASE)

hud.score = Ui.get(Element.new {
  style = {
    {
      width = '100vw',
      justify_content = 'center',
    },
    indent,
  },
  score,
})

M.score = Help.proxy({ val = 0 }, function(self, key, val)
  ---@type Fragment
  local data = Ui.getData(score)
  local node = Ui.get(score)
  if data then
    data.val = val
    assert(node)
    Ui.layout(node, node.state.parent, true)
  end
end)

local info = Fragment.new(nil, Res.fonts.BASE)

hud.info = Ui.get(Element.new {
  style = {
    {
      width = '100vw',
      height = '100vh',
      justify_content = 'center',
      align_items = 'center',
    },
  },
  info,
})

M.info = Help.proxy({
  val = 'wasd lemons',
}, function(self, key, val)
  ---@type Fragment
  local frag = Ui.getData(info)
  local node = Ui.get(info)
  if frag then
    frag.val = val

    Ui.layout(node, node.state.parent, true)
  end
end)

M.info.val = 'wasd'

hud.lives = Ui.get(Element.new {
  style = {
    indent,
    {
      gap = 2,
      justify_content = 'start',
      width = '100vw',
    },
  },
})

M.lives = Help.proxy({ val = 0 }, function(self, key, _)
  ---@type UiElement
  local lives = Ui.getData(hud.lives.state.node)
  lives:clearChildren()
  local children = {}

  for _ = 1, self.val do
    children[#children + 1] = Res.sprites.HEART:ui {
      frame_idx = 1,
      color = Color.RESET,
    }
  end

  lives:addChildren(children)
end)

return M
