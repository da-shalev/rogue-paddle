--- @class Scene
--- @field update fun(dt: number)
--- @field draw fun()
--- @field exit fun()
local Scene = {}
Scene.__index = Scene

--- General input and logic-per frame is handled here
--- @param dt number
function Scene.update(dt) end

--- Used for computing physics ensuring behaviour is consistent across devices
--- @param dt number
function Scene.fixedUpdate(dt) end

function Scene.draw() end

function Scene.exit() end

--- Stores the constructor to load the next scene
--- Used as a queue to ensure the scene is loaded at an appropriate time
--- @type function?
local next = nil

return {
  --- @param scene fun(): Scene
  --- @return fun(): Scene A builder function that constructs a new Scene instance
  build = function(scene)
    return function()
      return setmetatable(scene(), Scene)
    end
  end,

  --- Retrieves the next pending scene constructor (if any) and clears the queue
  --- @return (fun(): Scene)? The next scene constructor function, or nil if none is queued
  queueNext = function()
    local init = next
    next = nil
    return init
  end,

  --- Sets the requested scene to queue
  --- @param scene fun(): Scene
  setNext = function(scene)
    next = scene
  end,
}
