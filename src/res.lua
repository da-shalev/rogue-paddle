--  WARN: Do not load Meta here, as it is not initialized yet.
-- If you need access to state or a resource at this point,
-- it must be handled here first (though this requirement is very uncommon).

local Res = {
  sprites = {
    player = love.graphics.newImage('res/sprites/player.png'),
    ball = love.graphics.newImage('res/sprites/ball.png'),
  },

  -- ai generated gruvbox color scheme lol
  colors = {
    RESET = { 1.0, 1.0, 1.0, 1.0 },

    -- Dark mode backgrounds
    BG0_HARD = { 0.11, 0.11, 0.11 }, -- #1d2021
    BG0 = { 0.16, 0.15, 0.14 }, -- #282828
    BG1 = { 0.23, 0.22, 0.20 }, -- #3c3836
    BG2 = { 0.31, 0.28, 0.24 }, -- #504945
    BG3 = { 0.40, 0.36, 0.29 }, -- #665c54
    BG4 = { 0.48, 0.43, 0.35 }, -- #7c6f64

    -- Dark mode foregrounds
    FG0 = { 0.98, 0.94, 0.84 }, -- #fbf1c7
    FG1 = { 0.92, 0.86, 0.70 }, -- #ebdbb2
    FG2 = { 0.85, 0.78, 0.62 }, -- #d5c4a1
    FG3 = { 0.74, 0.66, 0.53 }, -- #bdae93
    FG4 = { 0.66, 0.60, 0.49 }, -- #a89984

    -- Light mode backgrounds
    BG0_HARD_LIGHT = { 0.97, 0.93, 0.85 }, -- #f9f5d7
    BG0_LIGHT = { 0.98, 0.94, 0.84 }, -- #fbf1c7
    BG1_LIGHT = { 0.92, 0.86, 0.70 }, -- #ebdbb2
    BG2_LIGHT = { 0.85, 0.78, 0.62 }, -- #d5c4a1
    BG3_LIGHT = { 0.74, 0.66, 0.53 }, -- #bdae93
    BG4_LIGHT = { 0.66, 0.60, 0.49 }, -- #a89984

    -- Light mode foregrounds
    FG0_LIGHT = { 0.16, 0.15, 0.14 }, -- #282828
    FG1_LIGHT = { 0.23, 0.22, 0.20 }, -- #3c3836
    FG2_LIGHT = { 0.31, 0.28, 0.24 }, -- #504945
    FG3_LIGHT = { 0.40, 0.36, 0.29 }, -- #665c54
    FG4_LIGHT = { 0.48, 0.43, 0.35 }, -- #7c6f64

    -- Bright colors
    RED = { 0.80, 0.14, 0.11 }, -- #cc241d
    GREEN = { 0.60, 0.59, 0.10 }, -- #98971a
    YELLOW = { 0.84, 0.60, 0.13 }, -- #d79921
    BLUE = { 0.27, 0.52, 0.53 }, -- #458588
    PURPLE = { 0.69, 0.38, 0.53 }, -- #b16286
    AQUA = { 0.41, 0.62, 0.42 }, -- #689d6a
    ORANGE = { 0.84, 0.37, 0.06 }, -- #d65d0e
    GRAY = { 0.66, 0.60, 0.49 }, -- #a89984

    -- Bright colors (light variants)
    RED_LIGHT = { 0.61, 0.15, 0.15 }, -- #9d0006
    GREEN_LIGHT = { 0.49, 0.55, 0.05 }, -- #79740e
    YELLOW_LIGHT = { 0.69, 0.49, 0.00 }, -- #b57614
    BLUE_LIGHT = { 0.02, 0.41, 0.46 }, -- #076678
    PURPLE_LIGHT = { 0.56, 0.27, 0.52 }, -- #8f3f71
    AQUA_LIGHT = { 0.30, 0.51, 0.38 }, -- #427b58
    ORANGE_LIGHT = { 0.69, 0.26, 0.00 }, -- #af3a03
    GRAY_LIGHT = { 0.51, 0.46, 0.36 }, -- #928374
  },
}

-- defines nearest filter for all loaded sprites
for _, sprite in pairs(Res.sprites) do
  sprite:setFilter('nearest', 'nearest')
end

return Res
