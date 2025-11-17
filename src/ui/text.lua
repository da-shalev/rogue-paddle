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
  local font = opts.font or love.graphics.getFont()
  local text = opts.text or EMPTY
  return setmetatable({
    _text = text,
    _box = Box.new(opts.pos or Vec2.zero(), getSize(font, text)),
    _font = font,
  }, Text)
end

---@return UiElement
function Text:ui()
  local color
  return UiElement.new {
    box = self._box,
    applyLayout = function(e)
      color = e.style.content_color
    end,
    onHover = function(e)
      if e.hover then
        color = e.style.content_hover_color
      else
        color = e.style.content_color
      end
    end,
    draw = function()
      self:draw(color)
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

---@param align? love.AlignMode
---@param color? Color
function Text:draw(align, color)
  if self._text ~= EMPTY then
    love.graphics.setColor(color or Color.RESET)
    love.graphics.printf(
      self._text,
      self._font,
      self._box.pos.x,
      self._box.pos.y,
      self._box.size.x,
      align or 'left'
    )
  end
end

return Text
