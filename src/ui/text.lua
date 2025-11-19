---@alias ValidText string | number | integer

---@param font love.Font
---@param text ValidText
---@return number, number
local function getSize(font, text)
  return font:getWidth(text), font:getHeight()
end

local EMPTY = ''

---@class ComputedText
---@field val ValidText
---@field font love.Font
---@field flags UiFlags
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
      flags = UiElement.Flags.default(),
    }, Text),
    function(t, k)
      -- any time val or font mutates
      -- mark for layout recalculation
      if k == 'val' or k == 'font' then
        t.flags.dirty = true
      end
    end
  )
end

---@return UiElement
function Text:ui()
  return UiElement.new {
    flags = self.flags,
    applyLayout = function(ui)
      local w, h = getSize(self.font, self.val)
      ui.style.width.val = w
      ui.style.height.val = h
    end,
    draw = function(ui)
      if self.val ~= EMPTY then
        love.graphics.printf(self.val, self.font, ui.box.pos.x, ui.box.pos.y, ui.box.size.x)
      end
    end,
  }
end

return Text
