--- @class SpriteState
--- @field box Box
--- @field data Sprite
--- @field flip_x boolean
--- @field flip_y boolean
--- @field frame_idx number
local SpriteState = {}
SpriteState.__index = SpriteState

--- @class Sprite
--- @field image love.Image
--- @field cell_size Vec2
--- @field cells love.Quad[]
local Sprite = {}
Sprite.__index = Sprite

--- @param image_path string
--- @param sx? number
--- @param sy? number
--- @return Sprite
function Sprite.new(image_path, sx, sy)
  -- strips ./ if it's there, should be for LSP conformation of correctness
  if image_path:sub(1, 2) == './' then
    image_path = image_path:sub(3)
  end

  local image = love.graphics.newImage(image_path)
  image:setFilter('nearest', 'nearest')

  local w, h = image:getDimensions()

  --- @type love.Quad[]
  local cells = {}

  sx = math.max(sx or 1, 1)
  sy = math.max(sy or 1, 1)
  local cw, ch = w / sx, h / sy

  for row = 0, sy - 1 do
    for col = 0, sx - 1 do
      cells[#cells + 1] = love.graphics.newQuad(col * cw, row * ch, cw, ch, w, h)
    end
  end

  return setmetatable({
    image = image,
    cell_size = math.vec2.new(cw, ch),
    cells = cells,
  }, Sprite)
end

--- @param opts? {
---   pos?: Vec2,
---   size?: Vec2,
---   starting_offset?: Origin,
---   rot?: number,
---   frame_idx?: number,
---   flip_x?: boolean,
---   flip_y?: boolean,
--- }
--- @return SpriteState
function Sprite:state(opts)
  opts = opts or {}

  return setmetatable({
    data = self,
    box = math.box.new(
      opts.pos or math.vec2.zero(),
      opts.size or self.cell_size,
      opts.rot or 0,
      opts.starting_offset or Origin.TOP_LEFT
    ),
    frame_idx = opts.frame_idx or 1,
    flip_x = opts.flip_x or false,
    flip_y = opts.flip_y or false,
  }, SpriteState)
end

--- @param box Box
--- @param mode love.DrawMode
--- @param color? Color
function SpriteState:drawRectangle(box, mode, color)
  assert(
    mode == 'fill' or mode == 'line',
    ('Did not specifiy valid mode to drawRectangle, got %s'):format(mode)
  )

  love.graphics.setColor(color or Res.colors.RESET)
  love.graphics.rectangle(
    mode,
    box.pos.x,
    box.pos.y,
    self.data.cell_size.x,
    self.data.cell_size.y,
    math.rad(box.rot)
  )
end

--- @param box? Box
--- @param color? Color
function SpriteState:draw(box, color)
  box = box or self.box
  love.graphics.setColor(color or Res.colors.RESET)

  local quad = self.data.cells[self.frame_idx]
  local _, _, w, h = quad:getViewport()
  local sx = (self.box.size.x / w) * (self.flip_x and -1 or 1)
  local sy = (self.box.size.y / h) * (self.flip_y and -1 or 1)

  love.graphics.draw(
    self.data.image,
    quad,
    box.pos.x + (self.flip_x and self.box.size.x or 0),
    box.pos.y + (self.flip_y and self.box.size.y or 0),
    math.rad(box.rot),
    sx,
    sy
  )
end

return Sprite
