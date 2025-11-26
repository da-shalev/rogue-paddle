---@class Status
---@field init? fun(ctx: StatusCtx)
---@field update? fun(ctx: StatusCtx, dt: number)
---@field fixed? fun(ctx: StatusCtx, dt: number)
---@field draw? fun(ctx: StatusCtx)
---@field exit? fun(ctx: StatusCtx)
local Status = {}
Status.__index = Status

---@param opts Status
Status.new = function(opts)
  return {
    init = opts.init,
    update = opts.update,
    fixed = opts.fixed,
    draw = opts.draw,
    exit = opts.exit,
  }
end

return Status
