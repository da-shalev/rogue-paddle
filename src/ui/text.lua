--- @alias ValidText string | number | integer

--- @param font love.Font
--- @param text ValidText
--- @return Vec2
local function getSize(font, text)
  return math.vec2.new(font:getWidth(text), font:getHeight())
end

local EMPTY = ''

--- @class Text
--- @field _text ValidText
--- @field _box Box
--- @field _font love.Font
--- @field _render_origin Vec2
local Text = {}
Text.__index = Text

--- @class TextOpts
--- @field text? ValidText
--- @field font? love.Font
--- @field pos Vec2
--- @field render_origin? Vec2

--- @param opts TextOpts
function Text.new(opts)
  local font = opts.font or Res.fonts.PRSTART
  local origin = opts.render_origin or Origin.TOP_LEFT
  local text = opts.text or EMPTY
  return setmetatable({
    _text = text,
    _box = math.box.new(opts.pos, getSize(font, text)),
    _font = font,
    _render_origin = origin,
  }, Text)
end

function Text:_mutated()
  self._box.size = getSize(self._font, self._text)
end

--- @param text? ValidText
--- @return Text
function Text:setText(text)
  self._text = text or EMPTY
  self:_mutated()
  return self
end

--- @param font love.Font
--- @return Text
function Text:setFont(font)
  self._font = font
  self:_mutated()
  return self
end

--- @param origin Vec2
--- @return Text
function Text:setOrigin(origin)
  self._render_origin = origin
  return self
end

--- @param color? Color
function Text:draw(color)
  if self._text ~= EMPTY then
    love.graphics.setFont(self._font)
    love.graphics.setColor(color or Res.colors.RESET)
    love.graphics.print(
      self._text,
      self._box.pos.x - self._box.size.x * self._render_origin.x,
      self._box.pos.y - self._box.size.y * self._render_origin.y
    )
  end
end

return Text
