-- Item list, IndexedSetup index 4. Harness name: start.Items
local Group = require("mn.ui.start.GroupList")

local M = {}

function M.new(ctx)
  return Group.new(ctx, Group.items)
end

return M
