-- mn.OpExt: the opcode-module contract (src/mn/ops/*.lua). ROM-free: the scripts here
-- are a few synthetic bytes in an otherwise empty 2 MiB image.
--   luajit tests/engine/mn_vm_ext_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Op = require("mn.Opcodes")
local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Ext = require("mn.OpExt")

-- no module claims an opcode ScriptVM already handles or one with no operand size
for op in pairs(Ext.handlers) do ok(Op.LEN[op] ~= nil, ("ext $%02X has a size"):format(op)) end

-- an image with `bytes` at 12:4000
local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- a handler registered for an opcode ScriptVM leaves alone is reached with (vm, o, n, cur)
-- and its return value is the next offset; nil ends the record
do
  -- $9D: a 0-operand opcode no retail script uses and ScriptVM does not handle
  local op = 0x9D
  ok(Op.LEN[op] == 0 and not Op.END[op] and not Ext.handlers[op], "$9D is free for the probe")
  if op then
    local seen = {}
    Ext.handlers[op] = function(vm, o, n, cur)
      seen[#seen + 1] = { o = o, n = n, bank = cur.bank, ptr = cur.ptr }
      vm.mem[0xC000] = (vm.mem[0xC000] or 0) + 1
      if #seen == 2 then return nil end
      return o + n
    end
    local rom = image({ op, op, op })
    local vm = VM.new(rom, {})
    vm:runInit(0x12, 0x4000)
    ok(#seen == 2, "handler ran twice, then ended the record")
    ok(seen[1] and seen[1].bank == 0x12 and seen[1].ptr == 0x4000 and seen[1].n == 1, "cur and n passed")
    ok(seen[2] and seen[2].ptr == 0x4001, "returned offset continues the script")
    ok(vm.mem[0xC000] == 2, "handler writes VM memory")
    ok(VM.off(0x4000, 0x12) == 0x12 * 0x4000, "ScriptVM.off maps (ptr, bank) to a flat offset")
    Ext.handlers[op] = nil
  end
end

-- extendHost hands every module the overworld and its host table
do
  local h = {}
  Ext.extendHost({}, h)
  ok(type(h) == "table", "extendHost runs on an empty host")
end

print(("mn_vm_ext: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
