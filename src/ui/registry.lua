local uid = 0

---@class UiRegistry
---@field elements table<UiIdx, ComputedUiNode>
local UiRegistry = {}
UiRegistry.__index = UiRegistry

local registry = setmetatable({ elements = {} }, UiRegistry)

---@param idx UiIdx
---@return ComputedUiNode
function UiRegistry:get(idx)
  return self.elements[idx]
end

---@param node ComputedUiNode
function UiRegistry:add(node)
  node:updateLayout()
  uid = uid + 1
  node._idx = uid
  self.elements[uid] = node
end

---@param node ComputedUiNode
function UiRegistry:_removeNode(node)
  self.elements[node:getIdx()] = self.elements[uid]
  self.elements[uid] = nil
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

---@param node ComputedUiNode
function UiRegistry:remove(node)
  for _, child_idx in ipairs(node:children()) do
    self:removeIdx(child_idx)
  end

  self:_removeNode(node)
end

---@param idx UiIdx
---@param dt number
---@return boolean
function UiRegistry:update(idx, dt)
  local node = self:get(idx)
  if node then
    node:update(dt)
    return true
  end

  return false
end

---@param idx UiIdx
function UiRegistry:draw(idx)
  local node = self:get(idx)

  if node then
    node:draw()
    return true
  end

  return false
end

return registry
