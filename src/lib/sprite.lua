local Ui = require 'ui.registry'

---@class ComputedSpriteState
---@field box Box
---@field data Sprite
---@field style SpriteRenderState
local SpriteState = {}
SpriteState.__index = SpriteState

---@class Sprite
---@field image love.Image
---@field cell_size Vec2
---@field cells love.Quad[]
local Sprite = {}
Sprite.__index = Sprite

---@param image_path string
---@param split_x? number
---@param split_y? number
---@return Sprite
function Sprite.new(image_path, split_x, split_y)
  local image = love.graphics.newImage(image_path)
  image:setFilter('nearest', 'nearest')

  local w, h = image:getDimensions()

  ---@type love.Quad[]
  local cells = {}

  split_x = math.max(split_x or 1, 1)
  split_y = math.max(split_y or 1, 1)
  local cw = w / split_x
  local ch = h / split_y

  for row = 0, split_y - 1 do
    for col = 0, split_x - 1 do
      cells[#cells + 1] = love.graphics.newQuad(col * cw, row * ch, cw, ch, w, h)
    end
  end

  return setmetatable({
    image = image,
    cell_size = Vec2.new(cw, ch),
    cells = cells,
  }, Sprite)
end

---@return number
function Sprite:getWidth()
  return self.cell_size.x
end

---@return number
function Sprite:getHeight()
  return self.cell_size.y
end

---@return Vec2
function Sprite:getDimensions()
  return self.cell_size
end

---@class SpriteFragment : UiType
---@field sprite Sprite
---@field style SpriteRenderState

---@class SpriteRenderState
---@field frame_idx? number
---@field flip_x? boolean
---@field flip_y? boolean
---@field color? Color

---@param opts? SpriteRenderState
---@param state? UiState
---@return RegIdx
function Sprite:ui(opts, state)
  opts = opts or {}
  opts.frame_idx = opts.frame_idx or 1

  local sprite = self

  ---@type SpriteFragment
  local data = {
    sprite = sprite,
    style = opts,
  }

  return Ui.add(data, {
    state = state,
    events = {
      layout = function(ctx)
        local size = sprite:getDimensions()
        ctx.box.w = size.x
        ctx.box.h = size.y
      end,
      draw = function(ctx)
        sprite:drawFrom(ctx.box, data.style)
      end,
    },
  })
end

---@class SpriteState: SpriteRenderState
---@field pos? Vec2
---@field size? Vec2
---@field starting_origin? Vec2
---@field rot? number

--- Stores render data directly on the sprite by
--- referencing to the original sprite
---@param opts? SpriteState
---@return ComputedSpriteState
function Sprite:state(opts)
  opts = opts or {}

  return setmetatable({
    data = self,
    box = Box.new(
      opts.pos or Vec2.zero(),
      opts.size or self.cell_size,
      opts.rot or 0,
      opts.starting_origin or Origin.TOP_LEFT
    ),
    style = {
      frame_idx = opts.frame_idx or 1,
      flip_x = opts.flip_x or false,
      flip_y = opts.flip_y or false,
    },
  }, SpriteState)
end

---@param prev_box Box
function SpriteState:drawLerp(prev_box)
  self.data:drawFrom(prev_box:lerp(prev_box, self.box, S.alpha), self.style)
end

function SpriteState:draw()
  self.data:drawFrom(self.box, self.style)
end

---@param x? number
---@param y? number
---@param rot? number
---@param opts? SpriteRenderState
function Sprite:draw(x, y, rot, opts)
  opts = opts or {}
  love.graphics.setColor(opts.color or Color.RESET)

  local quad = self.cells[opts.frame_idx or 1]
  local _, _, w, h = quad:getViewport()
  local sx = (opts.flip_x and -1 or 1)
  local sy = (opts.flip_y and -1 or 1)

  love.graphics.draw(
    self.image,
    quad,
    x + (opts.flip_x and w or 0),
    y + (opts.flip_y and h or 0),
    rot and math.rad(rot) or 0,
    sx,
    sy
  )
end

---@param box Box
---@param opts SpriteRenderState
function Sprite:drawFrom(box, opts)
  love.graphics.setColor(opts.color or Color.RESET)

  local quad = self.cells[opts.frame_idx]
  local _, _, w, h = quad:getViewport()
  local sx = (box.size.x / w) * (opts.flip_x and -1 or 1)
  local sy = (box.size.y / h) * (opts.flip_y and -1 or 1)

  love.graphics.draw(
    self.image,
    quad,
    box.pos.x + (opts.flip_x and box.size.x or 0),
    box.pos.y + (opts.flip_y and box.size.y or 0),
    math.rad(box.rot),
    sx,
    sy
  )
end

return Sprite
