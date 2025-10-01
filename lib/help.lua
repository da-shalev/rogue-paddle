local Help = {}

--- Executes a case based on the value (switch/case) becuase Lua doesn't have it :(
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

function Help.shallow_copy(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  return setmetatable(copy, getmetatable(t))
end

return Help
