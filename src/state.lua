--- Stores the constructor to load the next scene
--- Used as a queue to ensure the scene is loaded at an appropriate time
---@type function?
local next = nil

local aspect_ratio = 16 / 11
local S = {
  scene_queue = {
    --- Retrieves the next pending scene constructor (if any) and clears the queue
    ---@return (fun(): Scene)? The next scene constructor function, or nil if none is queued
    queueNext = function()
      local init = next
      next = nil
      return init
    end,

    --- Sets the requested scene to queue
    ---@param scene fun(): Scene
    setNext = function(scene)
      next = scene
    end,
  },
  seed = 0,
  alpha = 0,
  -- mouse position
  cursor = Box.zero(),

  camera = {
    -- desired aspect ratio for the display
    aspect_ratio = aspect_ratio,
    -- the games viewport/camera
    box = Box.new(
      Vec2.zero(),
      -- how tall the virtual screen is in virtual units
      -- divide width by the aspect ratio so a 16:9 screen gets a height of 135
      -- (240/1.78) instead of 240, making it proportional
      Vec2.new(240, 240 / aspect_ratio)
    ),
  },
}

-- status ctx
S.ctx = nil

S.left_touch_box =
  Box.new(S.camera.box.pos:clone(), Vec2.new(S.camera.box.size.x / 2, S.camera.box.size.y))

S.right_touch_box = Box.new(
  S.camera.box.pos + Vec2.new(S.camera.box.size.x / 2, 0),
  Vec2.new(S.camera.box.size.x / 2, S.camera.box.size.y)
)

math.randomseed(S.seed)

return S
