local uid = 0

---@class UiRegistry
---@field nodes table<UiIdx, UiNode>
local UiRegistry = {}
UiRegistry.__index = UiRegistry

local registry = setmetatable({ nodes = {} }, UiRegistry)

---@param idx UiIdx
---@return boolean
function UiRegistry:is(idx)
  return self.nodes[idx] ~= nil
end

---@param idx UiIdx
---@return UiNode?
function UiRegistry:get(idx)
  return self.nodes[idx]
end

---@param idx UiIdx
---@return UiCtx?
function UiRegistry:getCtx(idx)
  return self.nodes[idx].ctx
end

---@param node UiNode
---@return number
function UiRegistry:add(node)
  uid = uid + 1
  node.ctx.idx = uid
  self.nodes[uid] = node

  node.events.layout(node.ctx)
  return uid
end

---@param node UiNode
function UiRegistry:_removeNode(node)
  self.nodes[node.ctx.idx] = self.nodes[uid]
  self.nodes[uid] = nil
  uid = uid - 1
end

---@param idx UiIdx
---@return boolean
function UiRegistry:removeIdx(idx)
  local node = self:get(idx)
  if not node then
    return false
  end

  self:_removeNode(node)
  return true
end

---@param node UiNode
function UiRegistry:remove(node)
  self:_removeNode(node)
end

---@param node UiNode?
---@param dt number
function UiRegistry:update(node, dt)
  if node and node.events.update then
    node.events.update(node.ctx, dt)
  end
end

---@param node UiNode?
function UiRegistry:draw(node)
  if node then
    node.events.draw(node.ctx)
  end
end

return registry
