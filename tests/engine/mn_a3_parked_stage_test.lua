-- Opcode $A3 PlantParkedHandlerThenStage ($25B4) and its LCD-on half
-- LCDOnBCSplitAfterParkedHandler ($25D0): record (flag word, mask), then the
-- (bank, ptr) script, the metatile and the WRAM-3 cell word.
--   LCD off: flag clear -> InstallParkedScript; flag set -> plant the parked
--            handler, StageBytePastThree stores the metatile, park.
--   LCD on:  flag clear -> OrBCIntoSramBeforeStage (flag |= mask), store the
--            metatile, continue at record + 9 (INITIAL_SCRIPT_HANDLER);
--            flag set -> EnterScriptFromLookup on (bank, ptr).
-- Made-up bytes only.
--   luajit tests/engine/mn_a3_parked_stage_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local function plant(s, bank, ptr, bytes)
  local off = bank * 0x4000 + ptr - 0x4000
  return s:sub(1, off) .. string.char(unpack(bytes)) .. s:sub(off + #bytes + 1)
end

local s = string.rep("\0", 0x200000)
-- $A3 flag $A140 mask $04, script 13:4100, metatile $5A, cell $D123; then a marker.
s = plant(s, 0x12, 0x4000, { 0xA3, 0x40, 0xA1, 0x04, 0x13, 0x00, 0x41, 0x5A, 0x23, 0xD1,
  0xAC, 0x00, 0xC0, 0x11, 0x94 })
s = plant(s, 0x13, 0x4100, { 0xAC, 0x00, 0xC0, 0x22, 0x94 })
local ROM = MnRom.new(s)

local function run(lcdOff, flag)
  local cells = {}
  local h = { setMetatile = function(a, mt) cells[#cells + 1] = { a, mt } end }
  local vm = VM.new(ROM, h)
  vm:wr8(0xA140, flag)
  if lcdOff then vm:runInit(0x12, 0x4000) else vm:start(0x12, 0x4000) end
  return vm, cells
end

do
  local vm, cells = run(true, 0x00)
  ok(#cells == 0, "LCD off, flag clear: no store")
  ok(vm:rd8(0xC000) == 0x00, "LCD off, flag clear: parked, the script after the record does not run")
  ok(vm:rd8(0xA140) == 0x00, "LCD off: the flag is not written")
end
do
  local vm, cells = run(true, 0x04)
  ok(#cells == 1 and cells[1][1] == 0xD123 and cells[1][2] == 0x5A, "LCD off, flag set: the metatile is staged")
  ok(vm:rd8(0xC000) == 0x00, "LCD off, flag set: parked after the store")
end
do
  local vm, cells = run(false, 0x01)
  ok(vm:rd8(0xA140) == 0x05, "LCD on, flag clear: B OR C goes back to the flag byte")
  ok(#cells == 1 and cells[1][1] == 0xD123 and cells[1][2] == 0x5A, "LCD on, flag clear: the metatile is staged")
  ok(vm:rd8(0xC000) == 0x11, "LCD on, flag clear: the script continues at record + 9")
end
do
  local vm, cells = run(false, 0x04)
  ok(#cells == 0, "LCD on, flag set: no store")
  ok(vm:rd8(0xC000) == 0x22, "LCD on, flag set: EnterScriptFromLookup runs 13:4100")
end

print(("mn_a3_parked_stage: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
