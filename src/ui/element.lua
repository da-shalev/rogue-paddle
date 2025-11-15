---@class UiActions
---@field onClick? fun()

---@class UiEvents
---@field layout? fun()
---@field update? fun(dt: number)
---@field draw fun()

---@class UiElement
---@field box Box
---@field hover boolean
---@field events UiEvents
---@field _style? UiStyle
---@field _actions? UiActions
local UiElement = {}
UiElement.__index = UiElement

---@class UiStyle
---@field outline? BoxDirection
---@field outline_color? Color
---@field outline_hover? BoxDirection
---@field outline_hover_color? BoxDirection
---@field background_color? Color
---@field background_hover_color? Color
---@field extend? BoxDirection

---@class UiElementOpts : UiEvents
---@field box Box
---@field actions? UiActions
---@field style? UiStyle

---@param opts UiElementOpts
UiElement.new = function(opts)
  ---@type UiElement
  local drawable = {
    box = opts.box,
    hover = false,
    events = {
      draw = opts.draw,
      update = opts.update,
      layout = opts.layout,
    },
    _actions = opts.actions or {},
    _style = opts.style or {},
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

  if self._actions.onClick then
    if love.mouse.isDown(1) and self.hover then
      self._actions.onClick()
      -- love.mouse.setCursor(love.mouse.getSystemCursor('arrow'))
    end
  end

  if self.events.update then
    self.events.update(dt)
  end
end

---@param actions UiActions
---@return UiElement
function UiElement:setActions(actions)
  self._actions = actions
  return self
end

---@param style UiStyle
---@return UiElement
function UiElement:setStyle(style)
  self._style = style
  return self
end

function UiElement:draw()
  if self._style.background_hover_color and self.hover then
    self.box:draw('fill', self._style.background_hover_color)
  elseif self._style.background_color then
    self.box:draw('fill', self._style.background_color)
  end

  if self._style.outline_hover and self._style.outline_hover_color and self.hover then
    self.box:outline(self._style.outline_hover, self._style.outline_hover_color)
  elseif self._style.outline and self._style.outline_color then
    self.box:outline(self._style.outline, self._style.outline_color)
  end

  if self.events.draw then
    self.events.draw()
  end
end

function UiElement:layout()
  if self.events.layout then
    self.events.layout()
  end
end

return UiElement
