---@class UiActions
---@field onClick? fun()

---@class UiEvents
---@field apply? fun()
---@field update? fun(dt: number)
---@field draw fun()

---@class UiElement
---@field box Box
---@field hover boolean
---@field events UiEvents
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

---@param opts UiElementOpts
UiElement.new = function(opts)
  ---@type UiElement
  local drawable = {
    box = opts.box,
    hover = false,
    events = {
      draw = opts.draw,
      update = opts.update,
      apply = opts.apply,
    },
    _actions = {},
  }

  return setmetatable(drawable, UiElement)
end

---@param dt number
function UiElement:update(dt)
  if self._actions.onClick then
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

    if love.mouse.isDown(1) and self.hover then
      self._actions.onClick()
      love.mouse.setCursor(love.mouse.getSystemCursor('arrow'))
    end
  end

  if self.events.update then
    self.events.update(dt)
  end
end

---@param actions UiActions
---@return UiElement
function UiElement:actions(actions)
  self._actions = actions
  return self
end

function UiElement:draw()
  if self.events.draw then
    self.events.draw()
  end
end

return UiElement
