local UiStyle = require('ui.style')

---@class UiActions
---@field onClick? fun()

---@class UiEvents
---@field applyLayout? fun(self: UiElement)
---@field update? fun(dt: number)
---@field draw fun()

---@class UiElement
---@field parent? UiElement
---@field box Box
---@field hover boolean
---@field events UiEvents
---@field style? ComputedUiStyle
---@field actions? UiActions
---@field name? string
local UiElement = {}
UiElement.__index = UiElement

---@class UiElementOpts : UiEvents
---@field box Box
---@field style? UiStyle
---@field actions? UiActions

---@param opts UiElementOpts
UiElement.new = function(opts)
  ---@type UiElement
  local drawable = {
    parent = nil,
    box = opts.box,
    hover = false,
    events = {
      draw = opts.draw,
      update = opts.update,
      applyLayout = opts.applyLayout,
    },
    style = UiStyle.new(opts.style),
    actions = opts.actions or {},
  }

  return setmetatable(drawable, UiElement)
end

---@param dt number
function UiElement:update(dt)
  local x, y = S.cursor:within(self.box)

  local hover = x and y
  if self.hover ~= hover then
    self.hover = hover
  end

  if self.actions.onClick then
    if love.mouse.isDown(1) and self.hover then
      self.actions.onClick()
    end
  end

  if self.events.update then
    self.events.update(dt)
  end
end

---@param actions UiActions
---@return UiElement
function UiElement:setActions(actions)
  self.actions = actions
  return self
end

---@param style UiStyle
---@return UiElement
function UiElement:setStyle(style)
  self.style = UiStyle.new(style)
  return self
end

---@return ComputedUiStyle
function UiElement:getStyle()
  return self.style
end

---@param name string
---@return UiElement
function UiElement:setName(name)
  self.name = name
  return self
end

---@return string
function UiElement:getName()
  return self.name
end

function UiElement:draw()
  if self.style.background_hover_color and self.hover then
    love.graphics.setColor(self.style.background_hover_color or Res.colors.RESET)
    love.graphics.rectangle(
      'fill',
      self.box.pos.x,
      self.box.pos.y,
      self.box.size.x,
      self.box.size.y,
      self.style.border_radius,
      self.style.border_radius
    )
  elseif self.style.background_color then
    love.graphics.setColor(self.style.background_color or Res.colors.RESET)
    love.graphics.rectangle(
      'fill',
      self.box.pos.x,
      self.box.pos.y,
      self.box.size.x,
      self.box.size.y,
      self.style.border_radius,
      self.style.border_radius
    )
  end

  if self.style.border and self.style.border_color then
    love.graphics.setColor(self.style.border_color or Res.colors.RESET)
    love.graphics.setLineWidth(self.style.border)
    love.graphics.rectangle(
      'line',
      self.box.pos.x + self.style.border / 2,
      self.box.pos.y + self.style.border / 2,
      self.box.size.x - self.style.border,
      self.box.size.y - self.style.border,
      self.style.border_radius,
      self.style.border_radius
    )
  end

  if self.events.draw then
    self.events.draw()
  end
end

--- @param parent UiElement
function UiElement:updateLayout(parent)
  self.parent = parent

  -- if parent ~= nil then
  --   print(self:getName(), parent:getName())
  -- elseif self:getName() ~= nil then
  --   print(self:getName())
  -- end

  if self.events.applyLayout then
    self.events.applyLayout(self)
  end
end

return UiElement
