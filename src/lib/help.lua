local Help = {}

--- @generic T
--- @param value T The value to switch on
--- @param cases table<T, function> Table mapping values to handler functions
--- @param ... ... Additional parameters to pass through to the matched case handler
function Help.switch(value, cases, ...)
  local v = cases[value]
  if v then
    v(...)
  end
end

--- @generic T: table
--- Creates a shallow copy of the given table.
---
--- A shallow copy duplicates the table structure but does not recursively copy nested tables or other references.
--- Only the top-level key-value pairs are copied, preserving references to any nested tables or user data.
---
--- @param t T The table to create a shallow copy of
--- @return T A new table containing a shallow copy of the input table, with the same metatable as the original (if any)
function Help.shallowCopy(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  return setmetatable(copy, getmetatable(t))
end

--- @class Timeout
--- @field time number
--- @field func fun()

---@type Timeout[]
Help.timers = {}

--- Runs a function after a delay (seconds)
--- @param delay number
--- @param func fun()
function Help.setTimeout(delay, func)
  table.insert(Help.timers, { time = delay, func = func })
end

return Help
