local cursors = {
  hand = love.mouse.getSystemCursor('hand'),
}

local Res = {
  cheats = true,
  cursors = cursors,

  sprites = {
    PLAYER = Sprite.new('res/sprites/player.png'),
    BALL = Sprite.new('res/sprites/ball.png'),
    HEART = Sprite.new('res/sprites/heart.png'),
    ICONS = Sprite.new('res/sprites/lucid/IconsShadow-16.png', 10, 10),
  },

  fonts = {
    -- default font
    DEFAULT = love.graphics.newFont('res/fonts/Px437_IBM_CGA.ttf', 8),
    IBM = love.graphics.newFont('res/fonts/Px437_IBM_BIOS-2y.ttf', 16),
  },

  keybinds = {
    MOVE_RIGHT = { 'd', 'right', 'l' },
    MOVE_LEFT = { 'a', 'left', 'h' },
    MOVE_UP = { 'w', 'k', 'up' },
    MOVE_DOWN = { 's', 'j', 'down' },
    CONFIRM = 'space',
    PAUSE = 'escape',
  },

  styles = {
    ---@type UiStyle
    OVERLAY = {
      background_color = Color.BACKGROUND,
      -- border_color = Color.RESET,
      border_color = Color.RESET,
      border = 1,
      -- border_radius = 1,
      extend = { 8 },
    },

    TEXT = {
      -- content_color = Color.FOREGROUND,
      -- content_hover_color = Color.FOREGROUND,
      -- extend = { 10 },
    },

    ---@type UiStyle
    BUTTON = {
      -- extend = { 10, 0, 10, 0 },
      hover_cursor = cursors.hand,
      -- content_hover_color = Color.FOREGROUND,
    },
  },

  -- defines layouts for bricks
  layouts = {
    DEFAULT = {
      { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
      { 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
      { 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
      { 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    },
  },
}

for _, font in pairs(Res.fonts) do
  font:setFilter('nearest', 'nearest', 0)
end

return Res
