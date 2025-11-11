-- types
--- @alias BrickLayout integer[][]
--- @alias BrickRow Brick[]
--- @alias BrickGrid BrickRow[]
--- @alias BrickVariants BrickVariant[]

-- events
--- @class BrickEvent
--- @field bricks BrickManager
--- @field cancel boolean
local BrickEvent = {}
BrickEvent.__index = BrickEvent

--- @param bricks BrickManager
function BrickEvent:new(bricks)
  return setmetatable({
    bricks = bricks,
    cancel = false,
  }, self)
end

--- triggers when a new brick is being generated
--- @alias BrickGenerateEvent fun(brick: Brick)
--- triggers when a new brick has been spawned
--- @alias BrickSpawnEvent fun(e: BrickEvent, brick: Brick)
--- triggers when a new brick has been removed
--- @alias BrickRemoveEvent fun(e: BrickEvent, brick: Brick)
--- triggers when there are no bricks left
--- @alias BrickResetEvent fun(e: BrickEvent)

--- @class BrickVariant

-- meta
--- @class Brick
--- @field x integer
--- @field y integer
--- @field idx integer
--- @field box Box
--- @field color? Color
--- @field variant BrickVariant

--- @class BrickGridData
--- @field grid BrickGrid
--- @field cols integer
--- @field rows integer
--- @field count integer
--- @field timer Timer

-- manager
--- @class BrickManager
--- @field _data BrickGridData
--- @field opts BrickManagerOpts
local BrickManager = {}
BrickManager.__index = BrickManager

--- @alias BrickManagerOpts {
---   layout: BrickLayout,
---   onGenerate?: BrickGenerateEvent,
---   onSpawn?: BrickSpawnEvent,
---   onRemove?: BrickRemoveEvent,
---   onReset?: BrickResetEvent,
---   viewTransitionSpeed?: number,
---   variants?: BrickVariants,
---   colors?: Color[],
--- }

--- @param opts BrickManagerOpts
--- @return BrickManager
function BrickManager.new(opts)
  return setmetatable({
    _data = BrickManager.generate(opts),
    opts = opts,
  }, BrickManager)
end

--- @param opts BrickManagerOpts
--- @return BrickGridData
function BrickManager.generate(opts)
  local grid = {}
  local rows = #opts.layout
  local cols = #opts.layout[1]
  local count = 0

  for y, row in ipairs(opts.layout) do
    assert(#row == cols, ('row %d width mismatch (expected %d, got %d)'):format(y, cols, #row))
  end

  local size = math.vec2.new(S.camera.vbox.w / cols, S.camera.vbox.h / rows)
  local color_y = 1

  for y, y_rows in ipairs(opts.layout) do
    grid[y] = {}
    local row_has_brick = false

    for x, idx in ipairs(y_rows) do
      if idx ~= 0 then
        row_has_brick = true

        --- @type Brick
        local brick = {
          x = x,
          y = y,
          idx = idx,
          color = opts.colors[color_y],
          variant = opts.variants[love.math.random(#opts.variants)],
          box = math.box.new(
            math.vec2.new((x - 1) * size.x, ((y - 1) * size.y - S.camera.vbox.h)),
            size
          ),
        }

        opts.onGenerate(brick)
        grid[y][x] = brick
        count = count + 1
      end
    end

    if row_has_brick then
      color_y = color_y + 1
    end
  end

  return {
    grid = grid,
    cols = cols,
    rows = rows,
    count = count,
    timer = Timer.new(opts.viewTransitionSpeed or 0.5),
  }
end

function BrickManager:draw()
  local timer = self._data.timer
  if not timer.finished then
    timer:update(love.timer.getDelta())

    for y, row in ipairs(self._data.grid) do
      for _, brick in pairs(row) do
        local to = (y - 1) * brick.box.h
        brick.box.y = math.lerp(to - S.camera.vbox.h, to, timer.alpha)
      end
    end
  end

  for _, row in ipairs(self._data.grid) do
    for _, brick in pairs(row) do
      love.graphics.setColor(brick.color or Res.colors.RESET)

      love.graphics.rectangle('fill', brick.box.x, brick.box.y, brick.box.w, brick.box.h)

      love.graphics.setColor(Res.colors.REGULAR0)
      love.graphics.rectangle('line', brick.box.x, brick.box.y, brick.box.w, brick.box.h)
    end
  end
end

--- @param grid_x integer
--- @param grid_y integer
--- @return Brick? brick
function BrickManager:gridAt(grid_x, grid_y)
  return self._data.grid[grid_y] and self._data.grid[grid_y][grid_x]
end

--- @param world_x number
--- @param world_y number
--- @return integer grid_x
--- @return integer grid_y
function BrickManager:gridCellCoords(world_x, world_y)
  local cell_w = S.camera.vbox.w / self._data.cols
  local cell_h = S.camera.vbox.h / self._data.rows
  local grid_x = math.floor(world_x / cell_w) + 1
  local grid_y = math.floor(world_y / cell_h) + 1
  return grid_x, grid_y
end

--- @param world_x number
--- @param world_y number
--- @return Brick? brick
function BrickManager:gridWorldAt(world_x, world_y)
  local gx, gy = self:gridCellCoords(world_x, world_y)
  return self:gridAt(gx, gy)
end

--- @class CollisionResult
--- @field top? Brick
--- @field bottom? Brick
--- @field left? Brick
--- @field right? Brick

--- @param source Box
--- @return CollisionResult result
function BrickManager:boxCollision(source)
  if not self._data.timer.finished then
    return {}
  end

  local x, y, w, h = source.pos.x, source.pos.y, source.size.x, source.size.y
  return {
    top = self:gridWorldAt(x + w * 0.5, y),
    bottom = self:gridWorldAt(x + w * 0.5, y + h),
    left = self:gridWorldAt(x, y + h * 0.5),
    right = self:gridWorldAt(x + w, y + h * 0.5),
  }
end

--- checks and applies collision logic to any moving box
--- @param source Box
--- @param velocity Vec2
function BrickManager:removeOnCollision(source, velocity)
  local col = self:boxCollision(source)
  local hit = nil

  if velocity.y < 0 and col.top then
    hit = col.top
  elseif velocity.y > 0 and col.bottom then
    hit = col.bottom
  elseif velocity.x < 0 and col.left then
    hit = col.left
  elseif velocity.x > 0 and col.right then
    hit = col.right
  end

  if hit then
    if hit == col.top or hit == col.bottom then
      velocity.y = -velocity.y
      source:clampOutsideY(hit.box, true, true)
    end
    if hit == col.left or hit == col.right then
      velocity.x = -velocity.x
      source:clampOutsideX(hit.box, true, true)
    end

    self:remove(hit)
  end
end

--- @param brick Brick
function BrickManager:remove(brick)
  if self._data.count == 1 then
    self:reset()
    return
  else
    local ev = BrickEvent:new(self)
    if self.opts.onRemove then
      self.opts.onRemove(ev, brick)
    end

    if ev.cancel then
      return
    end
  end

  self._data.grid[brick.y][brick.x] = nil
  self._data.count = self._data.count - 1
end

--- @return number
function BrickManager:getCount()
  return self._data.count
end

--- @return number
function BrickManager:getCols()
  return self._data.cols
end

--- @return number
function BrickManager:getRows()
  return self._data.rows
end

function BrickManager:reset()
  local ev = BrickEvent:new(self)

  if self.opts.onReset then
    self.opts.onReset(ev)
  end

  if ev.cancel then
    return
  end

  self._data = self.generate(self.opts)
end

--- @param layout BrickLayout
function BrickManager:setNewLayout(layout)
  self.opts.layout = layout
end

return BrickManager
