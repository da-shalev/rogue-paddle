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

---@generic T: table
---@param tbl T
---@param onMutate fun(key: any, value: any, old_value: any)
---@return T
function Help.proxy(tbl, onMutate)
  if getmetatable(tbl) and getmetatable(tbl).__is_proxy then
    return tbl
  end

  local data = {}
  for k, v in pairs(tbl) do
    data[k] = v
  end

  for k in pairs(tbl) do
    tbl[k] = nil
  end

  setmetatable(tbl, {
    __is_proxy = true,
    __index = function(_, key)
      return data[key]
    end,
    __newindex = function(_, key, value)
      local old_value = data[key]
      data[key] = value
      onMutate(key, value, old_value)
    end,
    __pairs = function()
      return pairs(data)
    end,
  })

  return tbl
end

---@param base table
---@param add table
function Help.merge(base, add)
  for k, v in pairs(add) do
    if type(v) == 'table' and type(base[k]) == 'table' then
      Help.merge(base[k], v)
    else
      base[k] = v
    end
  end
end

---@generic T
---@param map table<T, boolean>
---@param ... T
---@return boolean
function Help.any(map, ...)
  for i = 1, select('#', ...) do
    local key = select(i, ...)
    if map[key] then
      return true
    end
  end

  return false
end

return Help
