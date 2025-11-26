local Element = require 'ui.element'
local Fragment = require 'ui.fragment'
local UiManager = require 'ui.manager'

---@class Stats
---@field score Accessor<number>
---@field lives Accessor<number>
---@field msg Accessor<string?>
local Stats = {}

---@type UiStyle
local indent = {
  extend = { 3 },
}

local score_text = Fragment.new(0, Res.fonts.BASE)
local info_text = Fragment.new(nil, Res.fonts.BASE)
local lives_idx

Stats.score = Builtin.accessor(0, function(val)
  ---@type Fragment
  local data = Ui.getData(score_text)
  local node = Ui.get(score_text)
  if data then
    data.val = val
    assert(node)
    UiManager.layout(node, node.state.parent, true)
  end
end)

Stats.msg = Builtin.accessor(nil, function(val)
  ---@type Fragment
  local frag = Ui.getData(info_text)
  local node = Ui.get(info_text)
  assert(node)
  if frag then
    frag.val = val
    UiManager.layout(node, node.state.parent, true)
  end
end)

Stats.lives = Builtin.accessor(0, function(val)
  ---@type UiElement
  local lives = Ui.getData(lives_idx)
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

local score_ui = Element.new {
  style = {
    {
      width = '100vw',
      justify_content = 'center',
    },
    indent,
  },
  score_text,
}

local info_ui = Element.new {
  style = {
    {
      width = '100vw',
      height = '100vh',
      justify_content = 'center',
      align_items = 'center',
    },
  },
  info_text,
}

lives_idx = Element.new {
  style = {
    indent,
    {
      gap = 2,
      justify_content = 'start',
      width = '100vw',
    },
  },
}

Stats.ui = Element.new {
  style = {
    width = '100vw',
    height = '100vh',
  },
  score_ui,
  info_ui,
  lives_idx,
}

return Stats
