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

---@param table ComputedText
local data = Help.watchTable(Text, function(table, key, _)
  -- only if val or font is mutated
  if key == 'val' or key == 'font' then
    table._box.size = getSize(table.font, table.val)
    table._box._dirty = true
  end
end)

---@class Text
---@field val? ValidText
---@field font? love.Font

---@param opts Text
---@return ComputedText
function Text.new(opts)
  local self = setmetatable({}, Text)
  local font = opts.font or love.graphics.getFont()
  local val = opts.val or EMPTY

  ---@type Text
  data[self] = {
    val = val,
    font = font,
    _box = Box.new(Vec2.zero(), getSize(font, val)),
  }

  return self
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

function Text:draw()
  if self.val ~= EMPTY then
    love.graphics.printf(self.val, self.font, self._box.pos.x, self._box.pos.y, self._box.size.x)
  end
end

return Text
