local tlfres = require("lib.tlfres")
local canvas, w, h

--- @type Scene?
local current_scene

function love.load()
  -- creates global Res from file `./res.lua`
  -- all resources are loaded and accessed from the global 'Res'
  -- in fashion, you will not be able to accces any global
  -- defined here before `love.load' executes or it'll explode
  Res = require("res")
  Meta = require("meta")

  love.resize()
end

---@param dt number
function love.update(dt)
  -- update current scene
  if current_scene then
    current_scene:update(dt)
  end

  local next_scene = Scene.takeNext()

  if next_scene then
    -- build the scene
    local scene = next_scene();
    if current_scene then
      current_scene:exit()
    end

    current_scene = scene
  end
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.push()

  --[]--

  -- define virtual scaling
  love.graphics.scale(w / Canvas.vw, h / Canvas.vh)
  -- center camera on the x axis
  love.graphics.translate(Canvas.vw / 2, 0)
  -- clear the screen
  love.graphics.clear(Canvas.viewport_color.r, Canvas.viewport_color.g, Canvas.viewport_color.b, 1)

  -- render scene
  if current_scene then
    current_scene:draw()
  end

  --[]--

  love.graphics.pop()
  love.graphics.setCanvas()

  -- render the canvas as a letterbox
  tlfres.beginRendering(w, h)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(canvas, 0, 0)

  tlfres.endRendering()
end

function love.resize()
  -- resize the canvas to fit on the display within the aspect_ratio
  local width, height = love.graphics.getDimensions()

  if width / height > Canvas.aspect_ratio then
    w = height * Canvas.aspect_ratio
    h = height
  else
    w = width
    h = width / Canvas.aspect_ratio
  end

  canvas = love.graphics.newCanvas(w, h)
end
