local UiManager = require 'ui.manager'

---@class Status
---@field init? fun(ctx: StatusCtx)
---@field update? fun(ctx: StatusCtx, dt: number)
---@field fixed? fun(ctx: StatusCtx, dt: number)
---@field draw? fun(ctx: StatusCtx)
---@field exit? fun(ctx: StatusCtx)
---@field ui? RegIdx
local Status = {}
Status.__index = Status

---@param opts Status
Status.new = function(opts)
  local ui_ctx = opts.ui and Ui.get(opts.ui)

  return {
    init = opts.init,
    update = function(ctx, dt)
      if ui_ctx then
        UiManager.update(ui_ctx, dt)
      end

      if opts.update then
        opts.update(ctx, dt)
      end
    end,
    fixed = opts.fixed,
    draw = function(ctx)
      if opts.draw then
        opts.draw(ctx)
      end

      if ui_ctx then
        UiManager.draw(ui_ctx)
      end
    end,
    exit = function(ctx)
      if opts.ui then
        Ui.remove(opts.ui)
      end
      if opts.exit then
        opts.exit(ctx)
      end
    end,
  }
end

return Status
