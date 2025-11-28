---@alias Observer fun()
---@type Observer[]
local _reactive_marker = {}
local _proxy_marker = {}

---@class Reactive<T>: {
---  __subscriptions: Observer[],
---  subscribe: fun(o: Observer),
---  set: fun(v: T),
---  get: fun(): T
---}
local Reactive = {}

---@generic T
---@param t T
---@return Reactive<T>
function Reactive.new(t)
  ---@type Observer[]
  local subscriptions = {}

  local function doObservation()
    for _, observer in ipairs(subscriptions) do
      observer()
    end
  end

  if type(t) == 'table' then
    -- proxied accessor reactive

    ---@param t table
    local function proxy(t)
      Reactive._proxy(t, function(_, v, _)
        doObservation()
      end)
    end

    proxy(t)

    return {
      [_reactive_marker] = true,
      get = function()
        return t
      end,
      set = function(val)
        assert(type(val) == 'table', 'PROXY reactive requires a table, got ' .. type(val))
        proxy(val)
        t = val
        doObservation()
      end,
      subscribe = function(o)
        subscriptions[#subscriptions + 1] = o
      end,
      __subscriptions = subscriptions,
    }
  else
    -- accessor reactive
    local v = { val = t }

    return {
      [_reactive_marker] = true,
      get = function()
        return v.val
      end,
      set = function(val)
        assert(type(val) ~= 'table', 'ACCESSOR reactive requires a non-table, got table')
        v.val = val
        doObservation()
      end,
      subscribe = function(o)
        subscriptions[#subscriptions + 1] = o
      end,
      __subscriptions = subscriptions,
    }
  end
end

---@param t any
---@return boolean
function Reactive.is(t)
  return type(t) == 'table' and t[_reactive_marker]
end

---@generic T
---@param t T|Reactive<T>
---@return T
function Reactive.get(t)
  if Reactive.is(t) then
    return t.get()
  else
    return t
  end
end

---@generic T: table
---@param t T
---@param onMutate fun(key: any, value: any, old: any)
---@return T
function Reactive._proxy(t, onMutate)
  local mt = getmetatable(t)
  assert(not (mt and mt[_proxy_marker]), 'attempted to proxy an already proxied table')

  local data = {}
  for k, v in pairs(t) do
    data[k] = v
  end

  for k in pairs(t) do
    t[k] = nil
  end

  setmetatable(t, {
    [_proxy_marker] = true,
    __index = function(_, key)
      return data[key]
    end,
    __newindex = function(_, key, value)
      local old_value = data[key]
      data[key] = value
      onMutate(key, value, old_value)
    end,
  })

  return t
end

return Reactive
