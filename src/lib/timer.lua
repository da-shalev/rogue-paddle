---@class Timer
---@field duration number
---@field time number
---@field finished boolean
---@field alpha number
local Timer = {}
Timer.__index = Timer

---@class Timeout
---@field time number
---@field func fun()

---@type Timeout[]
Timer.delayed = {}

--- WARN; Highly unrecommended. Good for debugging. This is a crutch, not a solution.
--- Runs a function after a delay (seconds)
---@param time number
---@param func fun()
function Timer.setTimeout(time, func)
  table.insert(Timer.delayed, { time = time, func = func })
end

--- Create a new timer
---@param duration number seconds until finished
---@return Timer
function Timer.new(duration)
  return setmetatable({
    duration = duration,
    time = 0,
    finished = false,
    alpha = 0,
  }, Timer)
end

--- Update the timer by delta time
---@param dt number
function Timer:update(dt)
  if not self.finished then
    self.time = self.time + dt

    if self.time >= self.duration then
      self.time = self.duration
      self.finished = true
    end

    self.alpha = self.time / self.duration
  end
end

--- Reset timer
function Timer:reset()
  self.time = 0
  self.finished = false
end

return Timer
