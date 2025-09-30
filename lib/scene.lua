--- @class Scene
--- @field update fun(self: table, dt: number)
--- @field draw fun(self: table)
--- @field exit fun(self: table)
local Scene = {}
Scene.__index = Scene
Scene.name = "UnnamedScene"

---@param dt number
function Scene:update(dt) end

function Scene:draw() end

function Scene:exit() end

--- @type function|nil
local next = nil

return {
  Scene = Scene,

  --- @param scene fun():Scene
  build = function(scene)
    return function()
      return setmetatable(scene(), Scene)
    end
  end,

  takeNext = function()
    local init = next
    next = nil
    return init
  end,

  --- @param scene fun():Scene
  setNext = function(scene)
    next = scene
  end
}
