local UiStyle = require('ui.style')

---@class UiActions
---@field onClick? fun()

---@class UiEvents
---@field applyLayout? fun(e: UiElement)
---@field update? fun(dt: number)
---@field draw fun(e: UiElement)
---@field onHover? fun(e: UiElement)

---@class UiElement
---@field parent? UiElement
---@field box Box
---@field hover? boolean
---@field events UiEvents
---@field style? ComputedUiStyle
---@field actions? UiActions
---@field name? string
local UiElement = {}
UiElement.__index = UiElement

---@class UiElementOpts : UiEvents
---@field box Box
---@field style? UiStyles
---@field actions? UiActions

---@param opts UiElementOpts
UiElement.new = function(opts)
  ---@type UiElement
  local drawable = {
    parent = nil,
    box = opts.box,
    hover = nil,
    events = {
      draw = opts.draw,
      update = opts.update,
      applyLayout = opts.applyLayout,
      onHover = opts.onHover,
    },
    style = UiStyle.normalize(opts.style),
    actions = opts.actions or {},
  }

  return setmetatable(drawable, UiElement)
end

---@param dt number
function UiElement:update(dt)
  local x, y = S.cursor:within(self.box)
  local hover = x and y

  if self.hover ~= hover then
    if self.style.hover_cursor then
      if hover then
        love.mouse.setCursor(self.style.hover_cursor)
      else
        love.mouse.setCursor()
      end
    end

    if self.events.onHover then
      self.events.onHover(self)
    end

    self.hover = hover
  end

  if love.mouse.isDown(1) and self.hover and self.actions.onClick then
    self.actions.onClick()
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

---@param ... UiStyle
---@return UiElement
function UiElement:setStyle(...)
  self.style = UiStyle.new(...)
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
    love.graphics.setColor(self.style.background_hover_color)
    love.graphics.rectangle(
      'fill',
      self.box.pos.x + self.style.border / 2,
      self.box.pos.y + self.style.border / 2,
      self.box.size.x - self.style.border,
      self.box.size.y - self.style.border,
      self.style.border_radius,
      self.style.border_radius
    )
  elseif self.style.background_color then
    love.graphics.setColor(self.style.background_color)
    love.graphics.rectangle(
      'fill',
      self.box.pos.x + self.style.border / 2,
      self.box.pos.y + self.style.border / 2,
      self.box.size.x - self.style.border,
      self.box.size.y - self.style.border,
      self.style.border_radius,
      self.style.border_radius
    )
  end

  if self.style.border and self.style.border_color then
    love.graphics.setColor(self.style.border_color)
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
    self.events.draw(self)
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
