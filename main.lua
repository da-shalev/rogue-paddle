-- game management related code is written here
local tlfres = require("lib.tlfres")
local canvas, canvas_w, canvas_h

local keys_pressed = {}
local keys_released = {}

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
  if current_scene then
    current_scene.update(dt)
  end

  -- if a new scene has been set to load next
  -- this will acquire it
  local next_scene = State.scene.takeNext()

  if next_scene then
    -- invokes the scene and generates its data
    local scene = next_scene()

    -- runs any logic required when the scene unloads like saving data
    if current_scene then
      current_scene.exit()
    end

    current_scene = scene
  end

  keys_pressed = {}
  keys_released = {}
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.push()

  -- define virtual scaling
  love.graphics.scale(canvas_w / State.canvas.vp.w, canvas_h / State.canvas.vp.h)
  love.graphics.translate(State.canvas.vp.x, State.canvas.vp.y)

  -- clear the screen
  love.graphics.clear(State.canvas.color.r, State.canvas.color.g, State.canvas.color.b, 1)

  -- render scene
  if current_scene then
    current_scene.draw()
  end

  love.graphics.pop()
  love.graphics.setCanvas()

  -- render the canvas as a letterbox
  tlfres.beginRendering(canvas_w, canvas_h)

  love.graphics.setColor(Res.colors.RESET)
  love.graphics.draw(canvas, 0, 0)

  tlfres.endRendering()
end

function love.resize()
  -- resize the canvas to fit on the display within the aspect_ratio
  local width, height = love.graphics.getDimensions()

  if width / height > State.canvas.aspect_ratio then
    canvas_w = height * State.canvas.aspect_ratio
    canvas_h = height
  else
    canvas_w = width
    canvas_h = width / State.canvas.aspect_ratio
  end

  canvas = love.graphics.newCanvas(canvas_w, canvas_h)
end

--- @return boolean
function love.keyboard.isAnyPressed()
  return next(keys_pressed) ~= nil
end

--- @return boolean
function love.keyboard.isAnyReleased()
  return next(keys_released) ~= nil
end

---@param key love.KeyConstant
function love.keyboard.isPressed(key)
  return keys_pressed[key]
end

---@param key love.KeyConstant
function love.keyboard.isReleased(key)
  return keys_released[key]
end

---@param key love.KeyConstant
function love.keypressed(key, _scancode, _isrepeat)
  keys_pressed[key] = true
end

---@param key love.KeyConstant
function love.keyreleased(key)
  keys_released[key] = true
end
