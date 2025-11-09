--- Stores the constructor to load the next scene
--- Used as a queue to ensure the scene is loaded at an appropriate time
--- @type function?
local next = nil

return {
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
