local Res = {}

-- load sprites from `./res/sprites` dir here
Res.sprites = {
  player = love.graphics.newImage("res/sprites/player.png")
}

for _, sprite in pairs(Res.sprites) do
  sprite:setFilter("nearest", "nearest")
end

return Res
