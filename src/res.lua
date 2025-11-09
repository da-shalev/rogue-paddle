local Res = {
  sprites = {
    PLAYER = Sprite.new('./res/sprites/player.png'),
    BALL = Sprite.new('./res/sprites/ball.png'),
    BRICK = Sprite.new('./res/sprites/brick.png'),
  },

  colors = {
    RESET = { 1.0, 1.0, 1.0, 1.0 },
  },

  levels = {
    DEFAULT = {
      { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 1, 1, 1, 1, 1, 1, 1, 0 },
      { 0, 1, 1, 1, 1, 1, 1, 1, 0 },
      { 0, 1, 1, 1, 1, 1, 1, 1, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 1, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
      { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    },
  },
}

return Res
