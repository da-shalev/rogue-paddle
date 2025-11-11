--- @alias Status table<string, SceneEvents>

--- @class SceneEvents
--- @field update? fun(ctx: SceneCtx, dt: number)
--- @field fixed? fun(ctx: SceneCtx, dt: number)
--- @field draw? fun(ctx: SceneCtx)
--- @field exit? fun(ctx: SceneCtx)

--- @class SceneCtx
--- @field status Status
--- @field current SceneEvents

--- @class Scene
--- @field ctx SceneCtx
--- @field update? fun(self: Scene, dt: number)
--- @field fixed? fun(self: Scene, dt: number)
--- @field draw? fun(self: Scene)
--- @field exit? fun(self: Scene)
local Scene = {}
Scene.__index = Scene

--- @class SceneOpts : SceneEvents
--- @field ctx SceneCtx

--- @param events SceneOpts
--- @return Scene
function Scene.new(events)
  local empty = function() end

  --- @type Scene
  local scene = {
    update = function(self, dt)
      (events.update or empty)(self.ctx, dt);
      (self.ctx.current.update or empty)(self.ctx, dt)
    end,
    fixed = function(self, dt)
      (events.fixed or empty)(self.ctx, dt);
      (self.ctx.current.fixed or empty)(self.ctx, dt)
    end,
    draw = function(self)
      (events.draw or empty)(self.ctx);
      (self.ctx.current.draw or empty)(self.ctx)
    end,
    exit = events.exit or empty,
    ctx = events.ctx,
  }

  return setmetatable(scene, Scene)
end

--- @param constructor fun(): Scene?
Scene.build = function(constructor)
  return function()
    return constructor()
  end
end

return Scene
