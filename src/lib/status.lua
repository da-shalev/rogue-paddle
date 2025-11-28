local Ui = require 'ui.registry'

---@class Status
---@field init? fun(ctx: StatusCtx)
---@field update? fun(ctx: StatusCtx, dt: number)
---@field fixed? fun(ctx: StatusCtx, dt: number)
---@field draw? fun(ctx: StatusCtx)
---@field exit? fun(ctx: StatusCtx)
---@field ui? RegIdx
local Status = {}
Status.__index = Status

---@param status Status
Status.new = function(status)
  local ui_ctx = status.ui and Ui.get(status.ui)
  local update
  print(ui_ctx)

  if ui_ctx and status.update then
    update = function(ctx, dt)
      Ui.update(ui_ctx, dt)
      status.update(ctx, dt)
    end
  elseif ui_ctx then
    update = function(_, dt)
      Ui.update(ui_ctx, dt)
    end
  else
    update = status.update
  end

  local draw

  if status.draw and ui_ctx then
    draw = function(ctx)
      status.draw(ctx)
      Ui.draw(ui_ctx)
    end
  elseif ui_ctx then
    draw = function(_)
      Ui.draw(ui_ctx)
    end
  else
    draw = status.draw
  end

  return {
    update = update,
    draw = draw,
    init = status.init,
    fixed = status.fixed,
    exit = status.exit,
  }
end

return Status
