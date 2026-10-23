-- mn.ops.Flow: synthetic-byte tests for the script-control opcodes.
--   luajit tests/engine/mn_ops_flow_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Ext = require("mn.OpExt")

local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

local function run(bytes, opt)
  opt = opt or {}
  local cells = {}
  local battles = {}
  local resets = 0
  local host = {
    setMetatile = function(addr, mt) cells[#cells + 1] = { addr, mt } end,
    battleOp = function(op, args) battles[#battles + 1] = { op, args } end,
    reenterReset = function() resets = resets + 1 end,
  }
  local vm = VM.new(image(bytes), host)
  if opt.mem then for a, v in pairs(opt.mem) do vm:wr8(a, v) end end
  if opt.init then vm:runInit(0x12, 0x4000) else vm:start(0x12, 0x4000) end
  return vm, cells, battles, resets
end

-- $9D stays free: mn_vm_ext_test.lua uses it as the probe opcode.
ok(Ext.handlers[0x9D] == nil, "$9D is not claimed")

local claimed = {
  0x32, 0xA2, 0xA0, 0xA1, 0x2F, 0x59, 0x95, 0x85, 0x4A, 0x97, 0x22, 0x23, 0x2A, 0x1E,
}
for _, op in ipairs(claimed) do ok(Ext.handlers[op] ~= nil, ("$%02X claimed"):format(op)) end

-- $32 SetThirdScript: five operands land in $C6D7-$C6DD, script continues.
do
  local vm = run({ 0x32, 0x11, 0x22, 0x33, 0x44, 0x55, 0x1E, 0x97 })
  ok(vm:rd8(0xC6D8) == 1 and vm:rd8(0xC6D7) == 0xFF, "$32 arms $C6D8 and $C6D7")
  ok(vm:rd8(0xC6DB) == 0x11 and vm:rd8(0xC6DC) == 0x22 and vm:rd8(0xC6DD) == 0x33, "$32 script bytes at $C6DB")
  ok(vm:rd8(0xC6D9) == 0x44 and vm:rd8(0xC6DA) == 0x55, "$32 table word at $C6D9")
  ok(vm:rd8(0xC714) == 0, "$32 does not write the third-script record yet")
  ok(vm:rd8(0xC91F) == 4 and vm.flow and vm.flow.reset, "$32 continues into the next opcode")
end

-- $A0 BranchWhenLCDOff. Operands: SRAM $A137, mask $0F, script 12:4020,
-- set-byte $11, clear-byte $22, cell $D010. 0x1E follows; 0x21 sits at 12:4020.
local A0 = {
  0xA0, 0x37, 0xA1, 0x0F, 0x12, 0x20, 0x40, 0x11, 0x22, 0x10, 0xD0, 0x1E, 0x97,
}
local function withTarget(head)
  local t = {}
  for i = 1, #head do t[i] = head[i] end
  for _ = #t + 1, 0x20 do t[#t + 1] = 0 end
  t[0x21] = 0x21 -- flat index 0x20 is ptr 0x4020; lua is 1-based so slot 0x21
  t[0x22] = 0x97
  return t
end

do
  local vm, cells = run(withTarget(A0), { init = true, mem = { [0xA137] = 0xA0 } })
  ok(vm:rd8(0xD010) == 0x22 and cells[1][1] == 0xD010 and cells[1][2] == 0x22, "$A0 LCD off, mask clear stores the clear byte")
  ok(vm:rd8(0xA137) == 0xA0 and vm:rd8(0xC91F) == 4, "$A0 LCD off, mask clear continues and leaves SRAM")
  ok(vm:rd8(0xC937) == 3, "$A0 selects WRAM bank 3 for the store")
end
do
  local vm, cells = run(withTarget(A0), { init = true, mem = { [0xA137] = 0xA5 } })
  ok(vm:rd8(0xD010) == 0x11 and cells[1][2] == 0x11, "$A0 LCD off, mask set stores the set byte")
  ok(vm:rd8(0xC91F) == 1 and vm:rd8(0xFFA1) == 0x12, "$A0 LCD off, mask set enters the script")
  ok(vm:rd8(0xFFA2) == 0x20 and vm:rd8(0xFFA3) == 0x40 and vm:rd16(0xFFA4) == 0x0A66, "$A0 plants the handler at the new pointer")
end
do
  local vm = run(withTarget(A0), { mem = { [0xA137] = 0xA0 } })
  ok(vm:rd8(0xA137) == 0xAF and vm:rd8(0xD010) == 0x11 and vm:rd8(0xC91F) == 1, "$A0 LCD on, mask clear ORs and enters")
end
do
  local vm = run(withTarget(A0), { mem = { [0xA137] = 0xA5 } })
  ok(vm:rd8(0xA137) == 0xAA and vm:rd8(0xD010) == 0x22 and vm:rd8(0xC91F) == 4, "$A0 LCD on, mask set XORs and continues")
end

-- $A1 parks on LCD off after the same store split. LCD on matches $A0.
local A1 = {
  0xA1, 0x37, 0xA1, 0x0F, 0x12, 0x20, 0x40, 0x11, 0x22, 0x10, 0xD0, 0x1E, 0x97,
}
do
  local vm = run(withTarget(A1), { init = true, mem = { [0xA137] = 0xA5 } })
  ok(vm:rd8(0xD010) == 0x11 and vm:rd8(0xC91F) == 0 and not (vm.flow and vm.flow.reset), "$A1 LCD off, mask set stores and parks")
  ok(vm:rd16(0xFFA4) == 0x1402 and vm:rd8(0xC6F4) == 0, "$A1 plants InstallParkedScript; its body has not run")
  ok(vm:rd16(0xFFA2) == 0x400A, "$A1 mask-set park leaves the pointer on the early plant")
end
do
  local vm = run(withTarget(A1), { init = true, mem = { [0xA137] = 0xA0 } })
  ok(vm:rd8(0xD010) == 0x22 and vm:rd8(0xC91F) == 0, "$A1 LCD off, mask clear stores the clear byte and parks")
  ok(vm:rd16(0xFFA2) == 0x400B, "$A1 mask-clear park leaves the pointer past the record")
end
do
  local vm = run(withTarget(A1), { mem = { [0xA137] = 0xA0 } })
  ok(vm:rd8(0xA137) == 0xAF and vm:rd8(0xC91F) == 1 and vm:rd8(0xD010) == 0x11, "$A1 LCD on, mask clear matches $A0")
end
do
  local vm = run(withTarget(A1), { mem = { [0xA137] = 0xA5 } })
  ok(vm:rd8(0xA137) == 0xAA and vm:rd8(0xC91F) == 4 and vm:rd8(0xD010) == 0x22, "$A1 LCD on, mask set matches $A0")
end

-- $A2 nine operands: SRAM $A200, mask $04, script 12:4020, cell byte $3C, cell $D020.
local A2 = { 0xA2, 0x00, 0xA2, 0x04, 0x12, 0x20, 0x40, 0x3C, 0x20, 0xD0, 0x1E, 0x97 }
do
  local vm = run(withTarget(A2), { init = true })
  ok(vm:rd8(0xC6F4) == 1 and vm:rd16(0xFFA2) == 0 and vm:rd16(0xFFA4) == 0x1402, "$A2 LCD off, mask clear runs InstallParkedScript")
  ok(vm:rd8(0xC91F) == 0 and vm:rd8(0xD020) == 0 and vm:rd8(0xA200) == 0, "$A2 LCD off, mask clear does not store or continue")
end
do
  local vm, cells = run(withTarget(A2), { init = true, mem = { [0xA200] = 0x04 } })
  ok(vm:rd8(0xD020) == 0x3C and cells[1][1] == 0xD020, "$A2 LCD off, mask set stores the cell byte")
  ok(vm:rd8(0xA200) == 0x04 and vm:rd8(0xC91F) == 4, "$A2 LCD off, mask set continues")
end
do
  local vm = run(withTarget(A2), { mem = { [0xA200] = 0x80 } })
  ok(vm:rd8(0xA200) == 0x84 and vm:rd8(0xD020) == 0x3C and vm:rd8(0xC91F) == 4, "$A2 LCD on, mask clear ORs, stores, and continues")
end
do
  local vm = run(withTarget(A2), { mem = { [0xA200] = 0x04 } })
  ok(vm:rd8(0xA200) == 0x04 and vm:rd8(0xD020) == 0 and vm:rd8(0xC91F) == 1, "$A2 LCD on, mask set enters the script")
end

-- $59 fills wScriptRecord and, once the LCD is on, runs it as the c706 thread.
do
  local script = { 0x59, 0x12, 0x08, 0x40, 0x97, 0, 0, 0, 0x21, 0x97 }
  local vm = run(script, { init = true })
  ok(vm:rd8(0xC706) == 0x12 and vm:rd16(0xC707) == 0x4008 and vm:rd16(0xC709) == 0x0A66, "$59 writes the record and handler")
  ok(not (vm.threads and vm.threads.c706) and vm:rd8(0xC91F) == 0, "$59 during setup does not start the record")
  vm = run(script)
  ok(vm.threads and vm.threads.c706 and vm.threads.c706.slot == "c706", "$59 plants the c706 thread")
  ok(vm:rd8(0xC91F) == 0, "$59 does not run the record inline")
  vm:tickThreads(false)
  ok(vm:rd8(0xC91F) == 1 and vm.threads.c706 == nil, "$59 record runs on the next thread pass")
end

-- $95 copies the fallback triple and continues.
do
  local vm = run({ 0x95, 0x05, 0x06, 0x07, 0x1E, 0x97 })
  ok(vm:rd8(0xC9FF) == 0x05 and vm:rd8(0xCA00) == 0x06 and vm:rd8(0xCA01) == 0x07, "$95 writes the fallback record")
  ok(vm:rd8(0xC91F) == 4, "$95 continues")
end

-- $85: bits 0 and 3 of the operand write $FF at $C12E and $C131.
do
  local vm = run({ 0x85, 0x19, 0x97 })
  ok(vm:rd8(0xC12E) == 0xFF and vm:rd8(0xC12F) == 0 and vm:rd8(0xC130) == 0 and vm:rd8(0xC131) == 0xFF, "$85 maps bits 0-3 onto $C12E")
  ok(vm:rd16(0xFFA4) == 0x0A66 and vm.flow and vm.flow.reset, "$85 plants the initial handler and continues")
end

-- $4A installs bank:ptr, sets $C6F4, and enters that script on the next pass.
do
  local vm = run({ 0x4A, 0x12, 0x04, 0x40, 0x21, 0x97 })
  ok(vm:rd8(0xC6F4) == 1 and vm:rd8(0xFFA1) == 0x12 and vm:rd16(0xFFA2) == 0x4004, "$4A installs the record")
  ok(vm.wait == 1 and vm:rd8(0xC91F) == 0, "$4A yields one frame before the new script")
  vm:resume()
  ok(vm:rd8(0xC91F) == 1 and vm.flow and vm.flow.reset, "$4A enters the installed script on resume")
  vm = run({ 0x4A, 0x12, 0x04, 0x40, 0x21, 0x97 }, { init = true })
  ok(vm:rd8(0xC91F) == 1 and vm:rd8(0xC6F4) == 1, "$4A during setup enters the script immediately")
end

-- $97 ends the record and asks the host to reset. The next opcode does not run.
do
  local vm, _, _, resets = run({ 0x97, 0x1E })
  ok(vm.flow and vm.flow.reset and resets == 1, "$97 requests a reset")
  ok(vm:rd8(0xC91F) == 0 and vm.co == nil, "$97 ends the record")
end

-- $1E / $22 / $23: sound-request bytes. The driver is not run.
do
  local vm = run({ 0x1E, 0x97 })
  ok(vm:rd8(0xC91F) == 4, "$1E sets wSoundRequest to 4")
  vm = run({ 0x22, 0x2F, 0x97 })
  ok(vm:rd8(0xC92C) == 0x0F and vm:rd8(0xC928) == 0 and vm:rd8(0xC929) == 0 and vm:rd8(0xC92A) == 4, "$22 keeps the low nibble and selects sound 4")
  vm = run({ 0x23, 0x2F, 0x97 })
  ok(vm:rd8(0xC929) == 3 and vm:rd8(0xC928) == 0 and vm:rd8(0xC92C) == 0 and vm:rd8(0xC92A) == 2, "$23 stores the high nibble plus one")
end

-- $2F / $2A copy operands to $D392 and hand them to the battle host.
do
  local vm, _, battles = run({ 0x2F, 0x01, 0x02, 0x03, 0x04, 0x97 })
  ok(vm:rd8(0xD392) == 0x01 and vm:rd8(0xD393) == 0x02 and vm:rd8(0xD394) == 0x03 and vm:rd8(0xD395) == 0x04, "$2F copies four bytes to $D392")
  ok(vm:rd8(0xC937) == 7 and battles[1] and battles[1][1] == 0x2F and battles[1][2][4] == 0x04, "$2F selects WRAM bank 7 and notifies battle")
  vm, _, battles = run({ 0x2F, 0x01, 0x02, 0x03, 0x04, 0x97 }, { init = true })
  ok(#battles == 0 and vm:rd8(0xD392) == 0x01, "$2F during setup still copies, and does not call battle")
  vm, _, battles = run({ 0x2A, 0x3C, 0x97 })
  ok(vm:rd8(0xD392) == 0x3C and battles[1] and battles[1][1] == 0x2A and battles[1][2][1] == 0x3C, "$2A copies one byte to $D392")
end

print(("mn_ops_flow: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
