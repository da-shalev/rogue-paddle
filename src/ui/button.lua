local Text = require('ui.text')

--- @class ButtonColors
--- @field background? Color
--- @field foreground? Color
--- @field outline? Color
--- @field outline_hover? Color
--- @field background_hover? Color
--- @field foreground_hover? Color

--- @class Button
--- @field box Box
--- @field colors ButtonColors
--- @field hover boolean
--- @field text Text
--- @field on_click? fun()
local Button = {}
Button.__index = Button

--- @class ButtonOpts
--- @field text string
--- @field box BoxOpts
--- @field colors? ButtonColors
--- @field on_click? fun()

--- @param opts ButtonOpts
--- @return Button
function Button.new(opts)
  local box = math.box.from(opts.box)
  return setmetatable({
    box = box,
    colors = opts.colors or {},
    text = Text.new({
      text = opts.text,
      pos = box:getOriginPos(Origin.CENTER),
      render_origin = Origin.CENTER,
    }),
    hover = false,
    on_click = opts.on_click or function() end,
  }, Button)
end

function Button:draw()
  if self.colors.background_hover and self.hover then
    self.box:draw('fill', self.colors.background_hover)
  elseif self.colors.background then
    self.box:draw('fill', self.colors.background)
  end

  if self.colors.outline_hover and self.hover then
    self.box:draw('line', self.colors.outline_hover)
  elseif self.colors.outline then
    self.box:draw('line', self.colors.outline)
  end

  if self.colors.foreground_hover and self.hover then
    self.text:draw(self.colors.foreground_hover)
  else
    self.text:draw(self.colors.foreground or Res.colors.RESET)
  end
end

function Button:update()
  local x, y = S.cursor:within(self.box)
  local hover = x and y

  if self.hover ~= hover then
    self.hover = hover
    if self.hover then
      love.mouse.setCursor(love.mouse.getSystemCursor('hand'))
    else
      love.mouse.setCursor(love.mouse.getSystemCursor('arrow'))
    end
  end

  if love.mouse.isDown(1) and hover then
    self:on_click()
    love.mouse.setCursor(love.mouse.getSystemCursor('arrow'))
  end
end

return Button
