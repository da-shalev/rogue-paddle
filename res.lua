-- WARN: Do not load Meta, as it is not initialized yet.
-- If you need access to a form of state and resource here,
-- it must go through here first, though that being a requirement is very uncommon.

local Res = {
  sprites = {
    player = love.graphics.newImage("res/sprites/player.png")
  }
}

-- defines nearest filter for all loaded sprites
for _, sprite in pairs(Res.sprites) do
  sprite:setFilter("nearest", "nearest")
end

return Res
