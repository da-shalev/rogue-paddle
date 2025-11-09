--- @class Brick
--- @field x integer
--- @field y integer
--- @field idx integer
--- @field sprite SpriteState

--- @alias Layout integer[][]
--- @alias BrickRow Brick[]
--- @alias BrickGrid BrickRow[]

--- @class BrickGridData
--- @field _grid BrickGrid
--- @field cols integer
--- @field rows integer
--- @field count integer

--- @class Bricks
--- @field data BrickGridData
local Bricks = {}
Bricks.__index = Bricks

--- @param layout Layout
--- @return Bricks
function Bricks.new(layout)
  return setmetatable({
    data = Bricks.generate(layout),
  }, Bricks)
end

--- @param layout Layout
--- @return BrickGridData
function Bricks.generate(layout)
  local grid = {}
  local rows = #layout
  local cols = #layout[1]
  local count = 0

  for y, row in ipairs(layout) do
    assert(#row == cols, ('row %d width mismatch (expected %d, got %d)'):format(y, cols, #row))
  end

  local size = math.vec2.new(S.camera.vbox.w / cols, S.camera.vbox.h / rows)

  for y, row in ipairs(layout) do
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
        count = count + 1
      end
    end
  end

  return {
    _grid = grid,
    cols = cols,
    rows = rows,
    count = count,
  }
end

function Bricks:draw()
  for _, row in ipairs(self.data._grid) do
    for _, brick in pairs(row) do
      brick.sprite:draw(brick.sprite.box)
    end
  end
end

--- @param grid_x integer
--- @param grid_y integer
--- @return Brick? brick
function Bricks:get_cell(grid_x, grid_y)
  return self.data._grid[grid_y] and self.data._grid[grid_y][grid_x]
end

--- @param world_x number
--- @param world_y number
--- @return integer grid_x
--- @return integer grid_y
function Bricks:get_cell_coords(world_x, world_y)
  local cell_w = S.camera.vbox.w / self.data.cols
  local cell_h = S.camera.vbox.h / self.data.rows
  local grid_x = math.floor(world_x / cell_w) + 1
  local grid_y = math.floor(world_y / cell_h) + 1
  return grid_x, grid_y
end

--- @param world_x number
--- @param world_y number
--- @return Brick? brick
function Bricks:get_cell_world_at(world_x, world_y)
  local gx, gy = self:get_cell_coords(world_x, world_y)
  return self:get_cell(gx, gy)
end

--- @class CollisionResult
--- @field top? Brick
--- @field bottom? Brick
--- @field left? Brick
--- @field right? Brick

--- @param source Box
--- @return CollisionResult result
function Bricks:check_collision(source)
  local x, y, w, h = source.pos.x, source.pos.y, source.size.x, source.size.y
  return {
    top = self:get_cell_world_at(x + w * 0.5, y),
    bottom = self:get_cell_world_at(x + w * 0.5, y + h),
    left = self:get_cell_world_at(x, y + h * 0.5),
    right = self:get_cell_world_at(x + w, y + h * 0.5),
  }
end

--- @param brick Brick
function Bricks:remove(brick)
  self.data._grid[brick.y][brick.x] = nil
  self.data.count = self.data.count - 1
end

return Bricks
