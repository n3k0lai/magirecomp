-- $65 (call_script_banked_ptr_then_resume.asm -> load_five_banked_map_sources.asm)
-- loads map data only: palettes, tiles, the WRAM planes. Records, threads, the
-- mailboxes, the A list and the player cell are left alone. $93 (finish_startup.asm
-- -> InitQuadRecords, write_quad_records.asm) clears $C6F5-$C6F8, $C6FA, $C6FC and
-- leaves $C6F9, $C6FB, $C6FD; its SetupDefaultState
-- (default_state.asm) clears the cell-$82 enable $C6D8. Made-up bytes, no ROM.
--   luajit tests/engine/mn_load65_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Overworld = require("mn.Overworld")

local function image(bytes)
  local s = string.rep("\0", 0x12 * 0x4000) .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

do -- $93 InitQuadRecords
  local vm = VM.new(image({ 0x93 }), { loadMap = function() end, centerCamera = function() end })
  for m = 0xC6F5, 0xC6FD do vm:wr8(m, 0x11) end
  vm:wr8(0xC6D8, 1); vm:wr8(0xC716, 0x40)
  vm:start(0x12, 0x4000)
  for _, m in ipairs({ 0xC6F5, 0xC6F6, 0xC6F7, 0xC6F8, 0xC6FA, 0xC6FC }) do
    ok(vm:rd8(m) == 0, ("$93 clears %04X"):format(m))
  end
  ok(vm:rd8(0xC6D8) == 0, "$93 (SetupDefaultState) turns the cell-$82 countdown off")
  ok(vm:rd8(0xC716) == 0, "$93 clears wThirdScriptRecord's pointer high byte")
  ok(vm:rd8(0xFFAA) == 3 and vm:rd8(0xFFAB) == 3, "$93 sets $FFAA/$FFAB to 3")
  for _, m in ipairs({ 0xC6F9, 0xC6FB, 0xC6FD }) do
    ok(vm:rd8(m) == 0x11, ("$93 leaves %04X"):format(m))
  end
end

do -- host.loadMap ($65) from the main script, no $93 before it
  local s = setmetatable({ objects = {}, log = {}, x = 4, y = 5, facing = "left", aList = 0x4321 },
    { __index = Overworld })
  s.vm = VM.new(MnRom.new(string.rep("\0", 0x200000)), {})
  local ob = { x = 2, y = 3 }
  s.objects[3] = ob
  local th = { co = "other" }
  s.vm.threads = { [3] = th }
  s.vm:wr8(0xC6F8, 6)
  local loaded
  s.loadArea = function(self, i) loaded = i; self.map = i end
  local h = Overworld.host(s)
  h.loadMap(7)
  ok(loaded == 7 and s.map == 7, "$65 loads the area")
  ok(s.objects[3] == ob, "records stay")
  ok(s.vm.threads[3] == th, "record threads stay")
  ok(s.vm:rd8(0xC6F8) == 6, "mailboxes stay")
  ok(s.aList == 0x4321, "the $69 A list stays")
  ok(s.x == 4 and s.y == 5 and s.facing == "left", "the player cell and facing stay")
end

print(("mn_load65: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
