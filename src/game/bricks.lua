--- @class Brick
--- @field x integer
--- @field y integer
--- @field idx integer
--- @field sprite SpriteState

--- @class Bricks
--- @field bricks Brick[]
local Bricks = {}
Bricks.__index = Bricks

--- @param level_data integer[][]
--- @return Bricks
function Bricks.new(level_data)
  return setmetatable({
    bricks = Bricks.generate(level_data),
  }, Bricks)
end

--- @param data integer[][]
--- @return Brick[]
function Bricks.generate(data)
  local bricks = {}
  local y_len = #data

  for y, row in ipairs(data) do
    local x_len = #row
    local size = math.vec2.new(S.camera.vbox.w / x_len, S.camera.vbox.h / y_len)

    for x, idx in ipairs(row) do
      if idx == 0 then
        goto continue
      end

      table.insert(bricks, {
        x = x,
        y = y,
        idx = idx,
        sprite = Res.sprites.BRICK:state {
          pos = math.vec2.new((x - 1) * size.x, (y - 1) * size.y),
          size = size,
        },
      })

      ::continue::
    end
  end

  return bricks
end

function Bricks:draw()
  for _, brick in ipairs(self.bricks) do
    brick.sprite:draw(brick.sprite.box)
  end
end

return Bricks
