---@alias ValidText string | number | integer

---@param font love.Font
---@param text ValidText
---@return Vec2
local function getSize(font, text)
  return Vec2.new(font:getWidth(text), font:getHeight())
end

local EMPTY = ''

---@class Text
---@field _text ValidText
---@field _box Box
---@field _font love.Font
local Text = {}
Text.__index = Text

---@class TextOpts
---@field text? ValidText
---@field font? love.Font
---@field pos? Vec2

---@param opts TextOpts
---@return Text
function Text.new(opts)
  local font = opts.font or Res.fonts.PRSTART
  local text = opts.text or EMPTY
  return setmetatable({
    _text = text,
    _box = Box.new(opts.pos or Vec2.zero(), getSize(font, text)),
    _font = font,
  }, Text)
end

---@return UiElement
function Text:ui()
  return UiElement.new {
    box = self._box,
    draw = function()
      self:draw()
    end,
  }
end

function Text:_mutated()
  self._box.size = getSize(self._font, self._text)
end

---@param text? ValidText
---@return Text
function Text:setText(text)
  self._text = text or EMPTY
  self:_mutated()
  return self
end

---@param font love.Font
---@return Text
function Text:setFont(font)
  self._font = font
  self:_mutated()
  return self
end

---@param color? Color
function Text:draw(color)
  if self._text ~= EMPTY then
    love.graphics.setFont(self._font)
    love.graphics.setColor(color or Res.colors.RESET)
    love.graphics.print(self._text, self._box.pos.x, self._box.pos.y)
  end
end

return Text
