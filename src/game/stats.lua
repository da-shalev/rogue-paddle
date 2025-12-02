local Element = require 'ui.element'
local Fragment = require 'ui.fragment'
local Ui = require 'ui.registry'

---@class Stats
local Stats = {
  score = Reactive.useCell(0),
  lives = Reactive.useCell(0),
  msg = Reactive.useCell '',
}

---@type UiStyle
local indent = {
  extend = { 3 },
}

local r = Reactive.fromState(Stats.lives)
if r then
  r.subscribe(function()
    ---@type UiElement
    local lives = Ui.data(Stats.lives_ui)
    lives:clearChildren()

    ---@type UiChildren
    local children = {}

    for _ = 1, Stats.lives.get() do
      children[#children + 1] = Res.sprites.HEART:ui {
        frame_idx = 1,
        color = Color.RESET,
      }
    end

    lives:addChildren(children)
  end)
end

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

Stats.lives_ui = Element.new {
  style = {
    {
      gap = 2,
      width = '33.33333333vw',
    },
  },
}

Stats.hud = Element.new {
  style = indent,
  Stats.lives_ui,
  Element.new {
    style = {
      width = '33.3333333vw',
      justify_content = 'center',
    },
    Fragment.new { val = Stats.score, font = Res.fonts.BASE },
  },
}

return Stats
