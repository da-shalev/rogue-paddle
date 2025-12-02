local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

local lives_ui = Element.new {
  style = {
    gap = 2,
    width = '33.3333333333vw',
  },
  state = {
    name = 'Lives HUD',
  },
}

---@class Stats
local Stats = {
  score = Reactive.useCell(0),
  msg = Reactive.useCell '',

  lives = Cell.new(0, function(v)
    local lives = lives_ui.getData()
    lives:clearChildren()

    ---@type UiChildren
    local children = {}

    for _ = 1, v do
      children[#children + 1] = Res.sprites.HEART:ui {
        frame_idx = 1,
        color = Color.RESET,
      }
    end

    lives:addChildren(children)
  end),
}

---@type UiStyle
local indent = {
  extend = { 3 },
}

-- local info_text = Reactive.new { val = nil, font = Res.fonts.BASE }

-- Stats.msg = Builtin.accessor(nil, function(val)
--   info_text.val = val
-- end)

-- Stats.lives = Builtin.accessor(0, function(val)
-- end)
--
-- local info_ui = Element.new {
--   style = {
--     {
--       width = '100vw',
--       height = '100vh',
--       justify_content = 'center',
--       align_items = 'center',
--     },
--   },
--   Fragment.new(info_text),
-- }

Stats.hud = Element.new {
  style = indent,
  lives_ui,
  Element.new {
    style = {
      width = '33.3333333333vw',
      justify_content = 'center',
    },
    Fragment.new { val = Stats.score, font = Res.fonts.BASE },
    state = {
      name = 'Score HUD',
    },
  },
  state = {
    name = 'HUD Wrapper',
  },
}

return Stats
