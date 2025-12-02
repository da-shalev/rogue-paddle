local _cell_marker = {}

---@class Cell<T>: {
---  set: fun(val: T),
---  get: fun(): T
---}
local Cell = {}

---@generic T
---@param val T
---@return Cell<T>
function Cell.new(val)
  local val = { val }

  return {
    [_cell_marker] = true,
    get = function()
      return val[1]
    end,

    ---@generic T
    ---@param v T
    set = function(v)
      val[1] = v
    end,
  }
end

---@param t any
---@return boolean
function Cell.is(t)
  return type(t) == 'table' and t[_cell_marker]
end

return Cell
