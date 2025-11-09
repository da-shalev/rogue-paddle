local tlfres = require('lib.tlfres')
local state = require('state')
local canvas, canvas_w, canvas_h

local keys_pressed = {}
local keys_released = {}

local t = 0.0
local FIXED_DT = 1. / 64.
local accumulator = 0.0
local current_time = love.timer.getTime()

--- @type Scene?
local current_scene

function love.load()
  -- All resources are loaded and accessed from the global 'Res'
  -- In fashion, you will not be able to accces anything loaded here before love.load executes
  Res = require('res')

  love.resize()
end

---@param dt number
function love.update(dt)
  -- https://gafferongames.com/post/fix_your_timestep/
  -- We have 'freed the physics'

  local new_time = love.timer.getTime()
  local frame_time = new_time - current_time

  if frame_time > 0.25 then
    frame_time = 0.25
  end

  current_time = new_time
  accumulator = accumulator + frame_time

  if current_scene then
    current_scene:update(dt)
  end

  while accumulator >= FIXED_DT do
    if current_scene then
      current_scene:fixed(FIXED_DT)
    end

    t = t + FIXED_DT
    accumulator = accumulator - FIXED_DT
  end

  state.alpha = accumulator / FIXED_DT

  local next_scene = state.scene_queue.queueNext()

  if next_scene then
    local scene = next_scene()

    if current_scene then
      current_scene:exit()
    end

    current_scene = scene
  end

  keys_pressed = {}
  keys_released = {}
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.push()

  love.graphics.scale(canvas_w / state.camera.vbox.w, canvas_h / state.camera.vbox.h)
  love.graphics.translate(state.camera.vbox.x, state.camera.vbox.y)
  love.graphics.clear(state.camera.color, 1)

  if current_scene then
    current_scene:draw()
  end

  love.graphics.pop()
  love.graphics.setCanvas()

  tlfres.beginRendering(canvas_w, canvas_h)

  love.graphics.setColor(Res.colors.RESET)
  love.graphics.draw(canvas, 0, 0)

  tlfres.endRendering()
end

function love.resize()
  local width, height = love.graphics.getDimensions()

  if width / height > state.camera.aspect_ratio then
    canvas_w = height * state.camera.aspect_ratio
    canvas_h = height
  else
    canvas_w = width
    canvas_h = width / state.camera.aspect_ratio
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
