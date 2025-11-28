local Element = require 'ui.element'
local Fragment = require 'ui.fragment'

---@class Stats
---@field score Reactive<number>
local Stats = {
  score = Reactive.new(0),
}

---@type UiStyle
local indent = {
  extend = { 3 },
}

-- local info_text = Reactive.new { val = nil, font = Res.fonts.BASE }
-- local lives_wrapper = Element.new {
--   style = {
--     indent,
--     {
--       gap = 2,
--       justify_content = 'start',
--       width = '100vw',
--     },
--   },
-- }

-- Stats.msg = Builtin.accessor(nil, function(val)
--   info_text.val = val
-- end)

-- Stats.lives = Builtin.accessor(0, function(val)
--   ---@type UiElement
--   local lives = Ui.getData(lives_wrapper)
--   lives:clearChildren()
--
--   ---@type UiChildren
--   local children = {}
--
--   for _ = 1, val do
--     children[#children + 1] = Res.sprites.HEART:ui {
--       frame_idx = 1,
--       color = Color.RESET,
--     }
--   end
--
--   lives:addChildren(children)
-- end)
--
local score_ui = Element.new {
  style = {
    {
      width = '100vw',
      justify_content = 'center',
    },
    indent,
  },
  Fragment.new { val = Stats.score, font = Res.fonts.BASE },
}
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

Stats.ui = score_ui

return Stats
