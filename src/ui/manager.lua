local UiManager = {}

---@param node UiCtx?
---@param dt number
function UiManager.update(node, dt)
  if node and not node.state.hidden and node.events.update then
    node.events.update(node.state, dt)
  end
end

---@param node UiCtx?
function UiManager.draw(node)
  if node and not node.state.hidden then
    node.events.draw(node.state)
  end
end

---@param node UiCtx?
---@param parent? RegIdx
---@param propagate? boolean
function UiManager.layout(node, parent, propagate)
  if node then
    node.events.layout(node.state, parent, propagate)
  end
end

return UiManager
