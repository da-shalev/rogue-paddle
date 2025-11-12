--- @class Status
--- @field update? fun(ctx: StatusCtx, dt: number)
--- @field fixed? fun(ctx: StatusCtx, dt: number)
--- @field draw? fun()
local Status = {}
Status.__index = Status

--- @param opts Status
Status.new = function(opts)
  return {
    update = opts.update,
    fixed = opts.fixed,
    draw = opts.draw,
  }
end

--- @alias StatusBuilder fun(): Status?
--- @param constructor StatusBuilder
Status.build = function(constructor)
  return function()
    return constructor()
  end
end

return Status
