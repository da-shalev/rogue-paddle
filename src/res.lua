local Res = {
  sprites = {
    PLAYER = Sprite.new('res/sprites/player.png'),
    BALL = Sprite.new('res/sprites/ball.png'),
  },

  font = love.graphics.newFont('res/prstart.ttf', 8),

  colors = {
    RESET = { 1.0, 1.0, 1.0, 1.0 },
    BACKGROUND = { 0.000, 0.000, 0.000, 1.0 },

    -- gruvbox color scheme
    BRIGHT0 = { 0.573, 0.514, 0.455, 1.0 }, -- #928374
    BRIGHT1 = { 0.984, 0.286, 0.204, 1.0 }, -- #fb4934
    BRIGHT2 = { 0.722, 0.733, 0.149, 1.0 }, -- #b8bb26
    BRIGHT3 = { 0.980, 0.741, 0.184, 1.0 }, -- #fabd2f
    BRIGHT4 = { 0.514, 0.647, 0.596, 1.0 }, -- #83a598
    BRIGHT5 = { 0.827, 0.525, 0.608, 1.0 }, -- #d3869b
    BRIGHT6 = { 0.557, 0.753, 0.486, 1.0 }, -- #8ec07c
    BRIGHT7 = { 0.922, 0.859, 0.698, 1.0 }, -- #ebdbb2

    FOREGROUND = { 0.922, 0.859, 0.698, 1.0 }, -- #ebdbb2

    REGULAR0 = { 0.157, 0.157, 0.157, 1.0 }, -- #282828 dark gray
    REGULAR1 = { 0.800, 0.141, 0.114, 1.0 }, -- #cc241d red
    REGULAR2 = { 0.596, 0.592, 0.102, 1.0 }, -- #98971a olive green
    REGULAR3 = { 0.843, 0.600, 0.129, 1.0 }, -- #d79921 yellow/orange
    REGULAR4 = { 0.271, 0.522, 0.533, 1.0 }, -- #458588 teal
    REGULAR5 = { 0.694, 0.384, 0.525, 1.0 }, -- #b16286 purple/magenta
    REGULAR6 = { 0.408, 0.616, 0.416, 1.0 }, -- #689d6a green
    REGULAR7 = { 0.659, 0.600, 0.518, 1.0 }, -- #a89984 beige/tan
  },

  keybinds = {
    MOVE_RIGHT = unpack { 'd', 'right', 'h' },
    MOVE_LEFT = unpack { 'a', 'left', 'l' },
    CONFIRM = 'space',
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

Res.font:setFilter('nearest', 'nearest')

return Res
