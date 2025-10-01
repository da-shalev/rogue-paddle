--- @class Scene
--- @field update fun(dt: number)
--- @field draw fun()
--- @field exit fun()
local Scene = {}
Scene.__index = Scene

---@param dt number
function Scene.update(dt) end

---@param dt number
function Scene.fixedUpdate(dt) end

function Scene.draw() end

function Scene.exit() end

--- @type function?
local next = nil

return {
  Scene = Scene,

  ---@param scene fun(): Scene
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

  --- @param scene fun(): Scene
  setNext = function(scene)
    next = scene
  end
}
