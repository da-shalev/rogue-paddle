---@alias StatusMap table<string, SceneStatus>

--- @class SceneStatus
--- @field update? fun(self: Scene, dt: number)
--- @field fixed? fun(self: Scene, dt: number)
--- @field draw? fun(self: Scene)
--- @field exit? fun(self: Scene)

--- @class Scene : SceneStatus
--- @field status StatusMap
--- @field current SceneStatus
local Scene = {}
Scene.__index = Scene

--- @param config Scene?
--- @return Scene
function Scene.new(config)
  config = config or {}
  local empty = function() end

  --- @type Scene
  local scene = {
    update = function(self, dt)
      (config.update or empty)(self, dt);
      (self.current.update or empty)(self, dt)
    end,
    fixed = function(self, dt)
      (config.fixed or empty)(self, dt);
      (self.current.fixed or empty)(self, dt)
    end,
    draw = function(self)
      (config.draw or empty)(self);
      (self.current.draw or empty)(self)
    end,
    exit = config.exit or empty,
    status = config.status,
    current = config.current,
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
