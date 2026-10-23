-- Spell list, IndexedSetup index 3. Harness name: start.Spell
local Group = require("mn.ui.start.GroupList")

local M = {}

function M.new(ctx)
  return Group.new(ctx, Group.spell)
end

return M
