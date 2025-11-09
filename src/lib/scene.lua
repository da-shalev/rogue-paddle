--- @class Scene
--- @field update fun(dt: number)
--- @field fixed fun(dt: number)
--- @field draw fun()
--- @field exit fun()
local Scene = {}
Scene.__index = Scene

--- General input and logic-per frame is handled here
--- @param dt number
function Scene.update(dt) end

--- Used for computing physics ensuring behaviour is consistent across devices
--- @param dt number
function Scene.fixed(dt) end

function Scene.draw() end

function Scene.exit() end

--- @param scene fun(): Scene
--- @return fun(): Scene A builder function that constructs a new Scene instance
Scene.build = function(scene)
  return function()
    return setmetatable(scene(), Scene)
  end
end

return Scene
