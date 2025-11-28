local Builtin = {}

---@generic T
---@param value T The value to switch on
---@param cases table<T, function> Table mapping values to handler functions
---@param ... ... Additional parameters to pass through to the matched case handler
function Builtin.switch(value, cases, ...)
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
function Builtin.shallowCopy(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end

  return setmetatable(copy, getmetatable(t))
end

---@param base table
---@param add table
function Builtin.merge(base, add)
  for k, v in pairs(add) do
    if type(v) == 'table' and type(base[k]) == 'table' then
      Builtin.merge(base[k], v)
    else
      base[k] = v
    end
  end
end

---@generic T
---@param map table<T, boolean>
---@param ... T
---@return boolean
function Builtin.any(map, ...)
  for i = 1, select('#', ...) do
    local key = select(i, ...)
    if map[key] then
      return true
    end
  end

  return false
end

return Builtin
