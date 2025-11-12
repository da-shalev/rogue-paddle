--- @class StatusCtx
--- @field current Status

--- @class Scene
--- @field ctx StatusCtx
--- @field update fun(self: Scene, dt: number)
--- @field fixed fun(self: Scene, dt: number)
--- @field draw fun(self: Scene)
--- @field exit fun()
local Scene = {}
Scene.__index = Scene

--- @class SceneOpts : Status
--- @field current Status
--- @field exit? fun()

--- @param events SceneOpts
--- @return Scene
function Scene.new(events)
  local empty = function() end

  --- @type Scene
  local scene = {
    update = function(self, dt)
      (self.ctx.current.update or empty)(self.ctx, dt);
      (events.update or empty)(self.ctx, dt)
    end,
    fixed = function(self, dt)
      (self.ctx.current.fixed or empty)(self.ctx, dt);
      (events.fixed or empty)(self.ctx, dt)
    end,
    draw = function(self)
      (self.ctx.current.draw or empty)();
      (events.draw or empty)()
    end,
    exit = events.exit or empty,
    ctx = {
      current = events.current,
    },
  }

  return setmetatable(scene, Scene)
end

--- @alias SceneBuilder fun(): Scene?
--- @param constructor SceneBuilder
Scene.build = function(constructor)
  return function()
    return constructor()
  end
end

return Scene
