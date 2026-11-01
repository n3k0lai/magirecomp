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

do -- real loadArea: $2F37 clears, no snap, ring kept when the atlases match
  love.graphics = { newImage = function() return { setFilter = function() end } end }
  love.filesystem = {
    read = function(path)
      if path:find("%.obj$") then return "\1\2" end
      local id = path:match("(%d%d%d)_meta_idx")
      if id == "001" or id == "002" then return "SAME" end
      if id == "003" then return "DIFF" end
      return ""
    end,
    getInfo = function() return true end,
  }
  local Importer = require("mn.MnImporter")
  local function plane(mt, w, h)
    local cells = {}
    for i = 1, w * h do cells[i] = mt end
    return cells
  end
  local function defFor(mt, col, row)
    local bg = {}
    for k = 1, 32 do bg[k] = k end
    return { w = 20, h = 15, camCol = col, camRow = row, cells = plane(mt, 20, 15), bgWords = bg, index = true }
  end
  Importer.loadMap = function(i)
    if i == 3 then return defFor(9, 0, 4) end
    if i == 2 then return defFor(9, 8, 4) end
    return defFor(3, 8, 4)
  end
  local function area()
    local s = setmetatable({ objects = {}, log = {}, x = 4, y = 5, facing = "left", aList = 0x4321,
      px = 4 * 16 + 7, py = 5 * 16 + 3, camOff = { 9, 4 }, camFix = { 10, 20 },
      colLatch = 2, rowLatch = 2, pans = { { 2, 1, -1 } }, map = 1,
      def = defFor(3, 8, 4) }, { __index = Overworld })
    s.vm = VM.new(MnRom.new(string.rep("\0", 0x200000)), {})
    s.objects[3] = { x = 2, y = 3 }
    s.vm.threads = { [3] = { co = "other" } }
    s.vm:wr8(0xC6F8, 6)
    s.vm:wr8(0xC85F, 9); s.vm:wr8(0xC6D2, 4); s.vm:wr8(0xC6D3, 5)
    return s
  end
  local on = area()
  on:loadArea(2)
  ok(on.px == 4 * 16 + 7 and on.py == 5 * 16 + 3, "LCD-on $65 does not snap the player")
  ok(on.x == 4 and on.y == 5 and on.facing == "left", "cell and facing stay")
  ok(on.objects[3] and on.vm.threads[3] and on.aList == 0x4321, "records, threads and the A list stay")
  ok(on.vm:rd8(0xC6F8) == 6, "mailbox stays")
  ok(on.camOff[1] == 9 and on.camOff[2] == 4 and on.camFix[1] == 10, "LCD-on keeps camOff and camFix")
  ok(on.pans and on.pans[1][1] == 2, "a multi-frame pan is not the $C843 byte")
  ok(on.vm:rd8(0xC85F) == 0 and on.vm:rd8(0xC860) == 0, "$2F37 zeroes the map column and row")
  ok(on.vm:rd8(0xC85D) == 0 and on.vm:rd8(0xC843) == 0 and on.vm:rd8(0xC844) == 0, "$2F37 zeroes fine scroll and deltas")
  ok(on.vm:rd8(0xC842) == 0x44, "$C842 is $44")
  ok(on.colLatch == 0 and on.rowLatch == 0, "load latches clear with $C86A/$C892")
  ok(on.vm:rd8(0xC86A) == 0 and on.vm:rd8(0xC892) == 0, "latch bytes clear")
  ok(on.vm:rd8(0xC6D2) == 0 and on.vm:rd8(0xC6D3) == 0, "$2DDC clears the live step")
  ok(on.vm:rd8(0xC847) == 20 and on.vm:rd8(0xC6CF) == 20, "stride lands at $C847 and $C6CF")
  ok(on.vm:rd8(0xC845) == 8 and on.vm:rd8(0xC846) == 4 and on.vm:rd8(0xC848) == 14, "camera limits and row+$0A")
  ok(on.vm:rd8(0xC84D) == 20 and on.vm:rd8(0xC84E) == 0, "stride table starts at 1 x width")
  ok(on:shownAt(1, 1) == 3, "matching atlases keep the old ring cell")
  local diff = area()
  diff:loadArea(3)
  local differed = false
  for _, line in ipairs(diff.log) do if line:find("tile set differs", 1, true) then differed = true end end
  ok(differed and diff:shownAt(1, 1) == 9, "a different atlas draws the new plane")
  ok(diff.px == 4 * 16 + 7 and diff.camOff[1] == 9, "that draw still does not snap or drop camOff")
  local off = area()
  off.vm:wr8(0xC936, 0)
  off:loadArea(3)
  ok(off.px == 4 * 16 + 7 and off.py == 5 * 16 + 3, "LCD-off $65 does not snap either")
  ok(off.camOff == nil and off.camFix == nil, "LCD-off drops the old camera overrides")
  ok(off.vm:rd8(0xC845) == 0 and off.vm:rd8(0xC842) == 0x44, "camCol 0 is stored, flags stay $44")
  local boot = area()
  boot.def = nil
  boot:enterMap(2, 4, 5)
  ok(boot.px == 4 * 16 and boot.py == 5 * 16, "a port-only start still snaps")
end

print(("mn_load65: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
