--- @class Timer
--- @field duration number
--- @field time number
--- @field finished boolean
--- @field alpha number
local Timer = {}
Timer.__index = Timer

---  Create a new timer
---  @param duration number seconds until finished
---  @return Timer
function Timer.new(duration)
  return setmetatable({
    duration = duration,
    time = 0,
    finished = false,
    alpha = 0,
  }, Timer)
end

--- Update the timer by delta time
--- @param dt number
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
