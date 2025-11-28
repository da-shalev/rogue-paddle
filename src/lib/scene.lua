---@class StatusCtx
---@field _status Status
---@field _overlay? Status
local StatusCtx = {}
StatusCtx.__index = StatusCtx

---@param ctx StatusCtx
StatusCtx.new = function(ctx)
  return setmetatable(ctx, StatusCtx)
end

---@param status Status
function StatusCtx:setStatus(status)
  if self._status.exit then
    self._status.exit(self)
  end

  self._status = status

  if status.init then
    status.init(self)
  end
end

function StatusCtx:popOverlay()
  -- reset cursor state in case a button or other was hovered
  love.mouse.setCursor()

  if self._overlay.exit then
    self._overlay.exit(self)
  end

  self._overlay = nil
end

---@param status Status
function StatusCtx:setOverlay(status)
  self._overlay = status

  if status.init then
    status.init(self)
  end
end

---@return boolean
function StatusCtx:hasStatus()
  return self._status ~= nil
end

---@return boolean
function StatusCtx:hasOverlay()
  return self._overlay ~= nil
end

---@class Scene
---@field ctx StatusCtx
---@field update fun(self: Scene, dt: number)
---@field fixed fun(self: Scene, dt: number)
---@field draw fun(self: Scene)
---@field exit fun()
local Scene = {}
Scene.__index = Scene

---@class SceneBuilder : Status
---@field status Status
---@field overlay? Status
---@field exit? fun()

---@param events SceneBuilder
---@return Scene
function Scene.new(events)
  local empty = function() end

  ---@type Scene
  local scene = {
    update = function(self, dt)
      (self.ctx._status.update or empty)(self.ctx, dt);
      (events.update or empty)(self.ctx, dt)

      if self.ctx._overlay then
        (self.ctx._overlay.update or empty)(self.ctx, dt)
      end
    end,
    fixed = function(self, dt)
      (self.ctx._status.fixed or empty)(self.ctx, dt);
      (events.fixed or empty)(self.ctx, dt)

      if self.ctx._overlay then
        (self.ctx._overlay.fixed or empty)(self.ctx, dt)
      end
    end,
    draw = function(self)
      (self.ctx._status.draw or empty)(self.ctx);
      (events.draw or empty)(self.ctx)

      if self.ctx._overlay then
        (self.ctx._overlay.draw or empty)(self.ctx)
      end
    end,
    exit = function()
      S.ctx = nil
      (events.exit or empty)()
    end,
    ctx = StatusCtx.new {
      _status = events.status,
      _overlay = events.overlay,
    },
  }

  S.ctx = scene.ctx
  events.status.init(scene.ctx)
  return setmetatable(scene, Scene)
end

return Scene
