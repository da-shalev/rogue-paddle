local aspect_ratio = 16 / 11
local S = {
  scene = require('lib.scene_queue'),
  seed = 0,
  alpha = 0,

  camera = {
    -- desired aspect ratio for the display
    aspect_ratio = aspect_ratio,
    -- the games viewport/camera
    vbox = Box.new(
      math.Vec2.zero(),
      -- how tall the virtual screen is in virtual units
      -- divide width by the aspect ratio so a 16:9 screen gets a height of 135
      -- (240/1.78) instead of 240, making it proportional
      math.Vec2.new(240, 240 / aspect_ratio)
    ),
    -- the background color of the game
    color = { 0, 0, 0 },
  },
}

math.randomseed(S.seed)

return S
