---@alias ValidText string | number | integer

---@param font love.Font
---@param text ValidText
---@return number, number
local function getSize(font, text)
  return font:getWidth(text), font:getHeight()
end

---@class ComputedText
---@field val? ValidText
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

  return Help.proxy(
    setmetatable({
      val = opts.val,
      font = font,
      flags = UiNode.Flags.default(),
    }, Text),
    function(self, key, val)
      -- any time val or font mutates
      -- mark for layout recalculation
      if key == 'val' or key == 'font' then
        -- ensures a empty string is treated the same
        if val == '' then
          val = nil
        end

        self.flags.queue_apply_layout = true
      end
    end
  )
end

---@return UiIdx
---@param opts? UiNode
function Text:ui(opts)
  opts = opts or {}
  return UiNode.new(opts, {
    flags = self.flags,
    applyLayout = function(ui)
      if self.val then
        local w, h = getSize(self.font, self.val)
        ui.style.width.val = w
        ui.style.height.val = h
      end
    end,
    draw = function(ui)
      if self.val then
        love.graphics.printf(
          self.val,
          self.font,
          ui.box.pos.x + ui.style.extend.left,
          ui.box.pos.y + ui.style.extend.top,
          ui.box.size.x
        )
      end
    end,
  })
end

return Text
