local Text = require('ui.text')

---@class ButtonStyle
---@field background? Color
---@field foreground? Color
---@field outline? BoxThickness
---@field outline_hover? BoxThickness
---@field background_hover? Color
---@field foreground_hover? Color
---@field extend? Vec2

---@class Button
---@field _box Box
---@field style ButtonStyle
---@field hover? boolean
---@field text Text
---@field onClick? fun()
local Button = {}
Button.__index = Button

---@class ButtonOpts
---@field text string
---@field pos? Vec2
---@field style? ButtonStyle
---@field onClick? fun()

---@param opts ButtonOpts
---@return Button
function Button.new(opts)
  opts.style = opts.style or {}
  opts.style.outline = opts.style.outline or {}
  opts.style.outline_hover = opts.style.outline_hover or {}
  opts.style.extend = opts.style.extend or math.vec2.zero()

  ---@type Text
  local text = Text.new {
    pos = opts.pos,
    text = opts.text,
    render_origin = Origin.CENTER,
  }

  ---@type Button
  local button = {
    _box = text._box:clone():extend(opts.style.extend),
    style = opts.style or {},
    text = text,
    hover = nil,
    onClick = opts.onClick or function() end,
  }

  return setmetatable(button, Button)
end

function Button:draw()
  if self.style.background_hover and self.hover then
    self._box:draw('fill', self.style.background_hover)
  elseif self.style.background then
    self._box:draw('fill', self.style.background)
  end

  if self.style.outline_hover and self.hover then
    self._box:outline(self.style.outline_hover)
  elseif self.style.outline then
    self._box:outline(self.style.outline)
  end

  if self.style.foreground_hover and self.hover then
    self.text:draw(self.style.foreground_hover)
  else
    self.text:draw(self.style.foreground or Res.colors.RESET)
  end
end

function Button:updateHover()
  local x, y = S.cursor:within(self._box)
  local hover = x and y

  if self.hover ~= hover then
    if hover then
      love.mouse.setCursor(love.mouse.getSystemCursor('hand'))
    else
      love.mouse.setCursor(love.mouse.getSystemCursor('arrow'))
    end

    self.hover = hover
  end
end

function Button:update()
  self:updateHover()

  if love.mouse.isDown(1) and self.hover then
    self:onClick()
    love.mouse.setCursor(love.mouse.getSystemCursor('arrow'))
  end
end

---@return UiDrawable
function Button:ui()
  ---@type UiDrawable
  return {
    box = self._box,
    updatePos = function()
      self.text._box = self._box:clone():extend(-self.style.extend)
    end,
    draw = function()
      self:draw()
    end,
    update = function()
      self:update()
    end,
  }
end

return Button
