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

--- creates a cell from a optional `Cell<T>|T`
--- requires casting for the LSP to understand
---@generic T
---@param t T
---@return T
function Cell.optional(t)
  if t[1] ~= nil and t[2] == nil then
    assert(not Cell.invalid(t), 'passed a table as a cell')
  else
    assert(not Cell.invalid(t), 'passed a regular table as a cell')
  end

  return Cell.is(t) and t or Cell.new(t)
end

---@param t any
---@return boolean
function Cell.invalid(t)
  return type(t) == 'table' and not Cell.is(t)
end

return Cell
