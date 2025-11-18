local UiStyle = require('ui.style')

---@class UiActions
---@field onClick? fun()

---@class UiEvents
---@field applyLayout? fun(e: UiElement)
---@field update? fun(dt: number)
---@field draw fun(e: UiElement)
---@field onHover? fun(e: UiElement)

---@class UiElement
---@field root? UiElement
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
  local e = {
    parent = nil,
    box = opts.box,
    root = nil,
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

  local e = setmetatable(e, UiElement)

  e:updateLayout()
  return e
end

---@param dt number
function UiElement:update(dt)
  local x, y = S.cursor:within(self.box)
  local hover = x and y

  if self.hover ~= hover then
    if self.style.hover_cursor then
      if hover then
        love.mouse.setCursor(self.style.hover_cursor)
        self.style.content.color = self.style.content.hover_color
        self.style.background.color = self.style.background.hover_color
      else
        love.mouse.setCursor()
        self.style.content.color = self.style.content.base_color
        self.style.background.color = self.style.background.base_color
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
  if self.box._dirty then
    self.box._dirty = false

    if self.root then
      self.root:updateLayout()
    end
  end

  if self.style.background.color then
    love.graphics.setColor(self.style.background.color)
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
    love.graphics.setColor(self.style.content.color or Color.RESET)
    self.events.draw(self)
  end
end

--- If no parent is passed, it is assumed self is root!
--- @param parent? UiElement
function UiElement:updateLayout(parent)
  if parent then
    self.parent = parent
    self.root = parent.root
  else
    self.root = self
  end

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
