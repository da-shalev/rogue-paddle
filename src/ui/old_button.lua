---@class Button
---@field box Box
---@field internal UiElement
---@field style ButtonStyle
---@field hover? boolean
---@field onClick? fun()
local Button = {}
Button.__index = Button

---@class ButtonOpts
---@field drawable UiElement
---@field style? ButtonStyle
---@field onClick? fun()

---@param opts ButtonOpts
---@return Button
function Button.new(opts)
  opts.style = opts.style or {}
  opts.style.outline = opts.style.outline or {}
  opts.style.outline_hover = opts.style.outline_hover or {}
  opts.style.extend = opts.style.extend or {}

  ---@type Button
  local button = {
    box = opts.drawable.box:clone():extend(opts.style.extend),
    internal = opts.drawable,
    style = opts.style,
    hover = nil,
    onClick = opts.onClick or function() end,
  }

  return setmetatable(button, Button)
end

function Button:draw()
  if self.style.background_hover and self.hover then
    self.box:draw('fill', self.style.background_hover)
  elseif self.style.background then
    self.box:draw('fill', self.style.background)
  end

  if self.style.outline_hover and self.hover then
    self.box:outline(self.style.outline_hover)
  elseif self.style.outline then
    self.box:outline(self.style.outline)
  end

  self.internal.draw()
end

function Button:updateHover()
  local x, y = S.cursor:within(self.box)
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

---@return UiElement
function Button:ui()
  ---@type UiElement
  return {
    box = self.box,
    apply = function()
      self.internal.box = self.box:clone()
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
