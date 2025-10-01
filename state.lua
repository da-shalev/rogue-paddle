local aspect_ratio = 16 / 12;
local State = {
  scene = require("lib.scene"),
  -- the seed used for randomness, for a rougelike we likely want our randoms to be seeded
  seed = 0,

  canvas = {
    -- desired aspect ratio for the display
    aspect_ratio = aspect_ratio,
    -- the games viewport/camera
    vp = Box.new(0, 0,
      -- how wide virtual screen is in virtual units
      240,
      -- how tall the virtual screen is in virtual units
      -- divide width by the aspect ratio so a 16:9 screen gets a height of 135 (240/1.78) instead of 240, making it proportional
      240 / aspect_ratio),
    -- the background color of the game
    color = {
      r = 0,
      g = 0,
      b = 0,
    },
  }
};

math.randomseed(State.seed)

return State
