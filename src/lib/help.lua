local Help = {}

---@generic T
---@param value T The value to switch on
---@param cases table<T, function> Table mapping values to handler functions
---@param ... ... Additional parameters to pass through to the matched case handler
function Help.switch(value, cases, ...)
  local v = cases[value]
  if v then
    v(...)
  end
end

--- Creates a shallow copy of the given table.
--- A shallow copy duplicates the table structure but does not recursively copy its nested tables
---@generic T: table
---@param t T
---@return T A cloned table
function Help.shallowCopy(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  return setmetatable(copy, getmetatable(t))
end

---@class Timeout
---@field time number
---@field func fun()

---@type Timeout[]
Help.timers = {}

--- WARN; Highly unrecommended. Good for debugging. This is a crutch, not a solution.
--- Runs a function after a delay (seconds)
---@param delay number
---@param func fun()
function Help.setTimeout(delay, func)
  table.insert(Help.timers, { time = delay, func = func })
end

--- @alias Accessor<T> {
---   set: fun(v: T),
---   get: fun(): T
--- }

--- Not java :)
---@generic T
---@param init T
---@param onMutate fun(val: T)
---@return Accessor<T>
function Help.accessor(init, onMutate)
  local value = init

  return {
    set = function(v)
      value = v
      onMutate(v)
    end,
    get = function()
      return value
    end,
  }
end

--- Metamethod to watch a tables mutation, allows avoiding getters and setters
--- by enabling internal tracking without abstractions (some would disagree)
---@generic T
---@param init T
---@param onMutate fun(val: T)
---@return T
function Help.proxy(init, onMutate)
  local value = init
  onMutate(value)
  return setmetatable({}, {
    __index = function()
      return value
    end,
    __newindex = function(_, _, v)
      value = v
      onMutate(v)
    end,
    __tostring = function()
      return tostring(value)
    end,
  })
end

return Help
