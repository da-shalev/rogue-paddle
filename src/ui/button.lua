local DEFAULT_BACKGROUND = Res.colors.REGULAR0
local DEFAULT_FOREGROUND = Res.colors.RESET
local Text = require('ui.text')

--- @class Button
--- @field box Box
--- @field hover boolean
--- @field background Color
--- @field foreground Color
--- @field text Text
--- @field on_click? fun()
local Button = {}
Button.__index = Button

--- @class ButtonOpts
--- @field box BoxOpts
--- @field text string
--- @field background? Color
--- @field foreground? Color
--- @field on_click? fun()

--- @param opts ButtonOpts
--- @return Button
function Button.new(opts)
  local box = math.box.from(opts.box)
  return setmetatable({
    box = box,
    background = opts.background or DEFAULT_BACKGROUND,
    foreground = opts.foreground or DEFAULT_FOREGROUND,
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
  self.box:draw('fill', self.background)
  self.text:draw()
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

  if love.mouse.isDown(1) then
    self:on_click()
    love.mouse.setCursor(love.mouse.getSystemCursor('arrow'))
  end
end

return Button
