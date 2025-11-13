local colors = {
  -- BACKGROUND = { 0.05, 0.05, 0.05, 1.0 },
  BACKGROUND = { 0.0, 0.0, 0.0, 1.0 },
  RESET = { 1.0, 1.0, 1.0, 1.0 },
  FOREGROUND = { 0.922, 0.859, 0.698, 1.0 }, -- #ebdbb2

  -- gruvbox color scheme
  BRIGHT0 = { 0.573, 0.514, 0.455, 1.0 }, -- #928374
  BRIGHT1 = { 0.984, 0.286, 0.204, 1.0 }, -- #fb4934
  BRIGHT2 = { 0.722, 0.733, 0.149, 1.0 }, -- #b8bb26
  BRIGHT3 = { 0.980, 0.741, 0.184, 1.0 }, -- #fabd2f
  BRIGHT4 = { 0.514, 0.647, 0.596, 1.0 }, -- #83a598
  BRIGHT5 = { 0.827, 0.525, 0.608, 1.0 }, -- #d3869b
  BRIGHT6 = { 0.557, 0.753, 0.486, 1.0 }, -- #8ec07c
  BRIGHT7 = { 0.922, 0.859, 0.698, 1.0 }, -- #ebdbb2

  REGULAR0 = { 0.157, 0.157, 0.157, 1.0 }, -- #282828 gray
  REGULAR1 = { 0.800, 0.141, 0.114, 1.0 }, -- #cc241d red
  REGULAR2 = { 0.596, 0.592, 0.102, 1.0 }, -- #98971a olive green
  REGULAR3 = { 0.843, 0.600, 0.129, 1.0 }, -- #d79921 yellow/orange
  REGULAR4 = { 0.271, 0.522, 0.533, 1.0 }, -- #458588 teal
  REGULAR5 = { 0.694, 0.384, 0.525, 1.0 }, -- #b16286 purple/magenta
  REGULAR6 = { 0.408, 0.616, 0.416, 1.0 }, -- #689d6a green
  REGULAR7 = { 0.659, 0.600, 0.518, 1.0 }, -- #a89984 beige/tan
}
local Res = {
  sprites = {
    PLAYER = Sprite.new('res/sprites/player.png'),
    BALL = Sprite.new('res/sprites/ball.png'),
    HEART = Sprite.new('res/sprites/heart.png'),
  },

  fonts = {
    -- default font
    PRSTART = love.graphics.newFont('res/fonts/prstart.ttf', 8),
    IBM = love.graphics.newFont('res/fonts/Px437_IBM_BIOS-2y.ttf', 16),
  },

  colors = colors,

  keybinds = {
    MOVE_RIGHT = { 'd', 'right', 'l' },
    MOVE_LEFT = { 'a', 'left', 'h' },
    MOVE_UP = { 'w', 'k', 'up' },
    MOVE_DOWN = { 's', 'j', 'down' },
    CONFIRM = 'space',
    PAUSE = 'escape',
  },

  ui = {
    BUTTON_SPACING = math.vec2.new(0, 0.125),
    BUTTON_SIZE = math.vec2.new(80, 18),

    --- @type ButtonColors
    BUTTON_STYLE = {
      outline_hover = colors.RESET,
    },

    --- @type ButtonColors
    BUTTON_QUIT_STYLE = {
      outline_hover = colors.REGULAR1,
    },

    --- @param gap number
    --- @param offset number
    offset = function(gap, offset)
      local offset = math.vec2.new(0, offset)
      if gap then
        return S.camera.vbox:getOriginPos(Origin.CENTER + Res.ui.BUTTON_SPACING * gap) + offset
      else
        return S.camera.vbox:getOriginPos(Origin.CENTER) + offset
      end
    end,
  },

  cheats = true,

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
  font:setFilter('nearest', 'nearest')
end

return Res
