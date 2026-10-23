-- Script opcode handlers kept outside ScriptVM.lua, one module per opcode group, so
-- groups can be ported in parallel without touching the same file. Each module returns
--   { handlers = { [op] = function(vm, o, n, cur) ... end }, host = function(ow, h) end }
-- A handler runs inside the script coroutine (it may coroutine.yield("wait", frames)
-- or ("text")), gets the flat ROM offset o of the opcode, its size n and cur = {bank, ptr},
-- and returns the next flat offset (o + n, or ScriptVM.off(ptr, bank) for a jump), or nil
-- to end the record. vm.init is true during the LCD-off map-setup run. ScriptVM handles
-- an opcode itself first; these only see opcodes it does not. host(ow, h) may add
-- callbacks to the Overworld host table h (handlers reach them as vm.host).
-- Nothing in these modules may hold ROM bytes: read them from vm.rom at runtime.
local M = { handlers = {}, modules = {} }

local LIST = { "Flow", "Records", "Travel", "Panels", "Save" }

for _, name in ipairs(LIST) do
  local mod = require("mn.ops." .. name)
  M.modules[name] = mod
  for op, fn in pairs(mod.handlers or {}) do
    assert(not M.handlers[op], ("mn.ops: opcode $%02X claimed twice"):format(op))
    M.handlers[op] = fn
  end
end

function M.extendHost(ow, h)
  for _, name in ipairs(LIST) do
    local mod = M.modules[name]
    if mod.host then mod.host(ow, h) end
  end
end

return M
