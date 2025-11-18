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

--- Runs a function after a delay (seconds)
---@param delay number
---@param func fun()
function Help.setTimeout(delay, func)
  table.insert(Help.timers, { time = delay, func = func })
end

--- Metamethod to watch a tables mutation, allows avoiding getters and setters
--- by allowing internal tracking without abstractions
---@param metatable table
---@param onMutate fun(tbl: table, key: any, val: any)
---@return table data
function Help.watchTable(metatable, onMutate)
  local data = setmetatable({}, { __mode = 'k' })

  metatable.__newindex = function(table, key, val)
    data[table][key] = val
    onMutate(table, key, val)
  end
  metatable.__index = function(table, key)
    if data[table] and data[table][key] ~= nil then
      return data[table][key]
    end
    return metatable[key]
  end

  return data
end

return Help
