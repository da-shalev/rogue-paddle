local _reactive_marker = {}
local _proxy_marker = {}
local _registry = setmetatable({}, { __mode = 'k' })

---@alias Observer fun()

---@generic T: table
---@alias Set fun(v: T)

---@generic T: table
---@class Reactive<T>: {
---  __subscriptions: Observer[],
---  set: Set<T>,
---  get: T,
---  subscribe: fun(o: Observer): fun() -- returns a unsubscriber
---}
local Reactive = {}

---@generic T: table
---@param t T
---@return T, Set<T>
function Reactive.useState(t)
  local r = Reactive._mk(t)
  _registry[r.get] = r
  return r.get, r.set
end

---@generic T: NotTable
---@param t T
---@return Cell<T>, Set<T>
function Reactive.useCell(t)
  local r
  local cell = Cell.new(t, function(v)
    -- guaranteed to exist :)
    r.set(v)
  end)

  r = Reactive._mk(cell)
  _registry[r.get] = r
  return r.get, r.set
end

---@generic T
---@param get T
---@return Reactive<T>?
function Reactive.fromState(get)
  return _registry[get]
end

---@generic T: table
---@param t T
---@return Reactive<T>
function Reactive._mk(t)
  -- proxied accessor reactive

  ---@type table<Observer, true>
  local subscriptions = {}

  local function doObservation()
    for observer, _ in pairs(subscriptions) do
      observer()
    end
  end

  ---@param t table
  local function observeTable(t)
    Reactive._proxy(t, function(_, v, _)
      doObservation()
    end)
  end

  observeTable(t)

  return {
    [_reactive_marker] = true,
    get = t,
    set = function(val)
      if type(val) ~= 'table' then
        val = { val }
      end

      observeTable(val)
      t = val
      doObservation()
    end,
    subscribe = function(o)
      subscriptions[o] = true

      return function()
        subscriptions[o] = nil
      end
    end,
    __subscriptions = subscriptions,
  }
end

---@param t any
---@return boolean
function Reactive.is(t)
  return type(t) == 'table' and t[_reactive_marker]
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
