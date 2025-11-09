--- @class Brick
--- @field x integer
--- @field y integer
--- @field idx integer
--- @field sprite SpriteState

--- @alias BrickRow Brick[]
--- @alias BrickGrid BrickRow[]

--- @class BrickGridData
--- @field grid BrickGrid
--- @field cols integer
--- @field rows integer

--- @class Bricks
--- @field data BrickGridData
local Bricks = {}
Bricks.__index = Bricks

--- @param level_data integer[][]
--- @return Bricks
function Bricks.new(level_data)
  return setmetatable({
    data = Bricks.generate(level_data),
  }, Bricks)
end

--- @param data integer[][]
--- @return BrickGridData
function Bricks.generate(data)
  local grid = {}
  local rows = #data
  local cols = #data[1]

  for y, row in ipairs(data) do
    assert(#row == cols, ('row %d width mismatch (expected %d, got %d)'):format(y, cols, #row))
  end

  local size = math.vec2.new(S.camera.vbox.w / cols, S.camera.vbox.h / rows)

  for y, row in ipairs(data) do
    grid[y] = {}
    for x, idx in ipairs(row) do
      if idx ~= 0 then
        grid[y][x] = {
          x = x,
          y = y,
          idx = idx,
          sprite = Res.sprites.BRICK:state {
            pos = math.vec2.new((x - 1) * size.x, (y - 1) * size.y),
            size = size,
          },
        }
      end
    end
  end

  return {
    grid = grid,
    cols = cols,
    rows = rows,
  }
end

function Bricks:draw()
  for _, row in ipairs(self.data.grid) do
    for _, brick in pairs(row) do
      brick.sprite:draw(brick.sprite.box)
    end
  end
end

function Bricks:get_cell(gx, gy)
  return self.data.grid[gy] and self.data.grid[gy][gx]
end

function Bricks:get_cell_coords(world_x, world_y)
  local cell_w = S.camera.vbox.w / self.data.cols
  local cell_h = S.camera.vbox.h / self.data.rows
  local gx = math.floor(world_x / cell_w) + 1
  local gy = math.floor(world_y / cell_h) + 1
  return gx, gy
end

function Bricks:get_cell_world_at(world_x, world_y)
  local gx, gy = self:get_cell_coords(world_x, world_y)
  return self:get_cell(gx, gy)
end

function Bricks:check_collision(source)
  local x, y, w, h = source.pos.x, source.pos.y, source.size.x, source.size.y
  return {
    top = self:get_cell_world_at(x + w * 0.5, y),
    bottom = self:get_cell_world_at(x + w * 0.5, y + h),
    left = self:get_cell_world_at(x, y + h * 0.5),
    right = self:get_cell_world_at(x + w, y + h * 0.5),
  }
end

return Bricks
