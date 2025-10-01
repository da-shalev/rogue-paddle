local Help = {}

--- Executes a case based on the value (switch/case) becuase Lua doesn't have it :(
--- Primarly abstracted for the assertion
--- @generic T
--- @param value T The value to switch on
--- @param cases table<T, function> Table mapping values to handler functions
--- @param ... ... Additional parameters to pass through to the matched case handler
function Help.switch(value, cases, ...)
  local case = cases[value]
  assert(case, "Help.switch: invalid case '" .. tostring(value) .. "'")
  case(...)
end

return Help
