local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

---@class Stats
---@field score Accessor<number>
---@field lives Accessor<number>
---@field msg Accessor<string?>
---@field update fun(dt: number)
---@field draw fun()
local Stats = {}
local hud = {}

---@type UiStyle
local indent = {
  extend = { 3 },
}

Stats.draw = function()
  if Stats.score.get() > 0 then
    Ui.draw(hud.score)
  end

  if Stats.lives.get() > 0 then
    Ui.draw(hud.lives)
  end

  if Stats.msg.get() then
    Ui.draw(hud.info)
  end
end

Stats.score = Help.accessor(0, function(val)
  ---@type Fragment
  local data = Ui.getData(hud.score_text)
  local node = Ui.get(hud.score_text)
  if data then
    data.val = val
    assert(node)
    Ui.layout(node, node.state.parent, true)
  end
end)

Stats.msg = Help.accessor(nil, function(val)
  ---@type Fragment
  local frag = Ui.getData(hud.info_text)
  local node = Ui.get(hud.info_text)
  assert(node)
  if frag then
    frag.val = val
    Ui.layout(node, node.state.parent, true)
  end
end)

Stats.lives = Help.accessor(0, function(val)
  ---@type UiElement
  local lives = Ui.getData(hud.lives.state.node)
  lives:clearChildren()

  ---@type UiChildren
  local children = {}

  for _ = 1, val do
    children[#children + 1] = Res.sprites.HEART:ui {
      frame_idx = 1,
      color = Color.RESET,
    }
  end

  lives:addChildren(children)
end)

hud.score_text = Fragment.new(0, Res.fonts.BASE)
hud.score = Ui.get(Element.new {
  style = {
    {
      width = '100vw',
      justify_content = 'center',
    },
    indent,
  },
  hud.score_text,
})

hud.info_text = Fragment.new(nil, Res.fonts.BASE)
hud.info = Ui.get(Element.new {
  style = {
    {
      width = '100vw',
      height = '100vh',
      justify_content = 'center',
      align_items = 'center',
    },
  },
  hud.info_text,
})

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

return Stats
