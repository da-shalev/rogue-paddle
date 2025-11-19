---@alias ValidText string | number | integer

---@param font love.Font
---@param text ValidText
---@return Vec2
local function getSize(font, text)
  return Vec2.new(font:getWidth(text), font:getHeight())
end

local EMPTY = ''

---@class ComputedText
---@field val ValidText
---@field font love.Font
---@field _box Box
local Text = {}
Text.__index = Text

---@class Text
---@field val? ValidText
---@field font? love.Font

---@param opts Text
---@return ComputedText
function Text.new(opts)
  local font = opts.font or love.graphics.getFont()
  local val = opts.val or EMPTY

  return Help.proxy(
    setmetatable({
      val = val,
      font = font,
      _box = Box.new(Vec2.zero(), getSize(font, val)),
    }, Text),
    function(t, k)
      if k == 'val' or k == 'font' then
        t._box.size = getSize(t.font, t.val)
        t._box._dirty = true
      end
    end
  )
end

---@return UiElement
function Text:ui()
  return UiElement.new {
    box = self._box,
    applyLayout = function(ui)
      ui.style.width.val = self._box.w
      ui.style.width.ext = 'px'
      ui.style.height.val = self._box.h
      ui.style.height.ext = 'px'
    end,
    update = function()
      -- print(self._box.w, self.val)
    end,
    draw = function()
      self:draw()
    end,
  }
end

function Text:draw()
  if self.val ~= EMPTY then
    love.graphics.printf(self.val, self.font, self._box.pos.x, self._box.pos.y, self._box.size.x)
  end
end

return Text
