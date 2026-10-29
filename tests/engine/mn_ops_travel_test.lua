-- Travel opcode handlers (src/mn/ops/Travel.lua). Synthetic bytes only.
--   luajit tests/engine/mn_ops_travel_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Travel = require("mn.ops.Travel")

local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

local function run(bytes, host, prep)
  local vm = VM.new(image(bytes), host or {})
  if prep then prep(vm) end
  vm:runInit(0x12, 0x4000)
  return vm
end

local function blank(n)
  local t = {}
  for i = 1, n do t[i] = 0 end
  return t
end

-- $86 seeds the $20 camera box, clamps, and continues
do
  local seen
  local vm = run({ 0x86, 0xAC, 0x00, 0xC0, 0x5A, 0x94 }, {
    seedCamera = function(box) seen = box end,
  }, function(vm)
    vm:wr8(0xC85F, 0x30); vm:wr8(0xC85D, 0x04)
    vm:wr8(0xC860, 3); vm:wr8(0xC85E, 8)
    vm:wr8(0xC6F8, 0x11)
  end)
  ok(seen == 0x20, "$86 tells the host the camera box")
  ok(vm:rd8(0xC845) == 0x20 and vm:rd8(0xC846) == 0x20, "$86 camera limits are $20")
  ok(vm:rd8(0xC847) == 0x20 and vm:rd8(0xC848) == 0x20, "$86 stride and C848 are $20")
  ok(vm:rd8(0xC715) == 0 and vm:rd8(0xC717) == 2 and vm:rd8(0xC718) == 0x14, "$86 quad at C715")
  ok(vm:rd8(0xC70E) == 0 and vm:rd8(0xC71E) == 2 and vm:rd8(0xC71F) == 0x14, "$86 quads at C70E and C71C")
  ok(vm:rd8(0xC6F8) == 0, "$86 clears the C6F8 mailbox")
  ok(vm:rd8(0xC85F) == 0 and vm:rd8(0xC85D) == 0, "$86 pins a column past the width to 0")
  ok(vm:rd8(0xC860) == 3 and vm:rd8(0xC85E) == 8, "$86 leaves an in-range row")
  ok(vm:rd8(0xC842) == 0x04, "$86 sets the left-edge flag and keeps the row")
  ok(vm:rd8(0xC934) == 3 * 16 + 8 and vm:rd8(0xFF42) == vm:rd8(0xC934), "$86 scroll Y")
  ok(vm:rd8(0xC000) == 0x5A, "$86 continues into the next opcode")
end

-- $63 decodes the banked pointer and does not write the palette block
do
  local got
  local vm = run({ 0x63, 0x34, 0x41, 0x12, 0x94 }, {
    travelBg = function(bank, ptr) got = { bank, ptr } end,
  })
  ok(got and got[1] == 0x12 and got[2] == 0x4134, "$63 bank and pointer")
  ok(vm:rd8(0xC72B) == 0, "$63 leaves C72B alone")
end

-- $6A copies the second record's 32 words and names the tile list
do
  local b = blank(0x140)
  b[1], b[2], b[3], b[4] = 0x6A, 0x80, 0x40, 0x12
  b[5], b[6], b[7] = 0x00, 0x41, 0x12
  b[8] = 0x94
  for i = 0, 63 do b[0x101 + i] = (i * 3 + 1) % 256 end
  local tiles
  local vm = run(b, { travelTiles = function(bank, ptr) tiles = { bank, ptr } end })
  ok(tiles and tiles[1] == 0x12 and tiles[2] == 0x4080, "$6A tile-list pointer")
  local pal = true
  for i = 0, 63 do
    local v = (i * 3 + 1) % 256
    if vm:rd8(0xC72B + i) ~= v or vm:rd8(0xC7AB + i) ~= v then pal = false end
  end
  ok(pal, "$6A copies 32 words to C72B and C7AB")
  ok(vm:rd8(0xC9D8) == 7 and vm:rd8(0xC831) == 1, "$6A panel index")
end

-- $6A with records past the script image (banks $00-$3C): map 4's battle return
-- tail 14:6029 names 7C:5C1E and 7C:4F3C; those reads come from host.fullRom
do
  local b = { 0x6A, 0x1E, 0x5C, 0x7C, 0x3C, 0x4F, 0x7C, 0x94 }
  local pre = string.rep("\0", 0x12 * 0x4000) .. string.char(unpack(b))
  -- MnImporter.scriptRom: scripts.bin stops after bank $3C
  local scripts = setmetatable({ s = pre .. string.rep("\0", 0x3D * 0x4000 - #pre) }, MnRom)
  local full = {}
  for i = 0, 63 do full[i + 1] = string.char((i * 5 + 2) % 256) end
  local at = 0x7C * 0x4000 + 0x0F3C
  local fs = string.rep("\0", at) .. table.concat(full)
  local fullRom = MnRom.new(fs .. string.rep("\0", 0x200000 - #fs))
  local vm = VM.new(scripts, { fullRom = function() return fullRom end })
  local okRun, err = pcall(vm.runInit, vm, 0x12, 0x4000)
  ok(okRun, "$6A past bank $3C runs: " .. tostring(err))
  local pal = true
  for i = 0, 63 do
    local v = (i * 5 + 2) % 256
    if vm:rd8(0xC72B + i) ~= v or vm:rd8(0xC7AB + i) ~= v then pal = false end
  end
  ok(pal, "$6A reads 7C:4F3C from the full ROM")
end

-- $88 floors an item, clears a spell, and wraps the Animite word
do
  local vm = run({
    0x88, 0x00, 0x02, 0x03,
    0x88, 0x00, 0x02, 0x09,
    0x88, 0x03, 0x04, 0x7F,
    0x88, 0x04, 0x00, 0x32,
    0x88, 0x01, 0x01, 0x02,
    0x88, 0x05, 0x09, 0x09,
    0xAC, 0x00, 0xC0, 0x11,
    0x94,
  }, {}, function(vm)
    vm:wr8(0xA3A9, 5) -- item 2
    vm:wr8(0xA5A9, 0x3C) -- spell 4
    vm:wr8(0xA3A5, 0x10); vm:wr8(0xA3A6, 0x00) -- Animite 16, count will be $32
    vm:wr8(0xA4A7, 4) -- scan C + 1
  end)
  ok(vm:rd8(0xA3A9) == 0, "$88 floors an item count at zero")
  ok(vm:rd8(0xC9FC) == 5 and vm:rd8(0xC9FD) == 9 and vm:rd8(0xC9FE) == 9, "$88 leaves the three argument bytes")
  ok(vm:rd8(0xA5A9) == 0, "$88 clears the spell byte and ignores the count")
  ok(vm:rd8(0xA3A5) == 0xDE and vm:rd8(0xA3A6) == 0xFF, "$88 stores the wrapped Animite difference")
  ok(vm:rd8(0xA4A7) == 2, "$88 floors the scan-C byte")
  ok(vm:rd8(0xC000) == 0x11, "$88 continues after the argument bytes")
end

-- a second Animite take that can pay stores zero; a zero count leaves the word
do
  local vm = run({ 0x88, 0x04, 0x00, 0x00, 0x94 }, {}, function(vm)
    vm:wr8(0xA3A5, 0x2C); vm:wr8(0xA3A6, 0x01)
  end)
  ok(vm:rd8(0xA3A5) == 0x2C and vm:rd8(0xA3A6) == 0x01, "$88 count 0 leaves the Animite word")
  vm = run({ 0x88, 0x04, 0x00, 0x10, 0x94 }, {}, function(vm)
    vm:wr8(0xA3A5, 0x20); vm:wr8(0xA3A6, 0x00)
  end)
  ok(vm:rd8(0xA3A5) == 0 and vm:rd8(0xA3A6) == 0, "$88 a payable Animite take stores zero")
  vm = run({ 0x88, 0x02, 0x03, 0x01, 0x94 }, {}, function(vm) vm:wr8(0xA01C, 1) end)
  ok(vm:rd8(0xA01C) == 0, "$88 floors the entry-scan byte")
end

-- $8B arms the tile-choice slot and continues
do
  local vm = run({ 0x8B, 0xAC, 0x34, 0x12, 0x44, 0x94 }, {}, function(vm) vm:wr8(0xC937, 4) end)
  ok(vm:rd8(0xCC42) == 0x10 and vm:rd8(0xCC43) == 0xF2 and vm:rd8(0xCC44) == 0x52, "$8B tile source")
  ok(vm:rd8(0xCC45) == 0x60 and vm:rd8(0xCC46) == 0x88, "$8B tile destination")
  ok(vm:rd8(0xCCB4) == 8 and vm:rd8(0xCCA9) == 0xF3 and vm:rd8(0xCCB8) == 4, "$8B slot index, mark, bank")
  ok(vm:rd8(0xCCB6) == 0xD6 and vm:rd8(0xCCB7) == 0xCC, "$8B slot pointer")
  ok(vm:rd8(0xCCB0) == 0x77 and vm:rd8(0xCCB1) == 0x6B, "$8B first slot word")
  ok(vm:rd8(0xCCB2) == 0xE3 and vm:rd8(0xCCB3) == 0x42, "$8B second slot word")
  ok(vm:rd8(0xCCB9) == 1 and vm:rd8(0xCCBA) == 0 and vm:rd8(0xCCA7) == 0xFF, "$8B slot flags")
  ok(vm:rd8(0xCCE3) == 3 and vm:rd8(0xCCEB) == 0xF9, "$8B choice mode bytes")
  ok(vm:rd8(0x1234) == 0x44, "$8B continues at the next opcode")
end

-- $8C copies the counted block and fills eight choice bytes
do
  local b = { 0x8C, 0x10, 0x00, 0x02 }
  b[5] = 0x11
  for i = 6, 18 do b[i] = 0x00 end
  b[19] = 0x22 -- D001 + $0E
  b[20] = 0x94
  local vm = run(b)
  ok(vm:rd8(0x6D000) == 0x02 and vm:rd8(0x6D001) == 0x11 and vm:rd8(0x6D00F) == 0x22, "$8C block at bank-6 $D000")
  ok(vm:rd8(0xCCCC) == 2 and vm:rd8(0xCCD5) == 0, "$8C record length")
  ok(vm:rd8(0xCCCD) == 0x11 and vm:rd8(0xCCCE) == 0x22, "$8C choice bytes from the records")
  local pad = true
  for i = 2, 7 do if vm:rd8(0xCCCD + i) ~= 0xFF then pad = false end end
  ok(pad, "$8C pads the rest of the choice table")
  ok(vm:rd8(0xCCC6) == 7 and vm:rd8(0xCCC9) == 7, "$8C stops on the last filled slot")
  ok(vm:rd8(0xCCE2) == 0 and vm:rd8(0xCD81) == 3 and vm:rd8(0xCCEB) == 0x0B, "$8C short-list mark")
  ok(vm:rd8(0xCCE6) == 0x01 and vm:rd8(0xCCE7) == 0xD0, "$8C data pointer")
  ok(vm:rd8(0xC937) == 6, "$8C selects WRAM bank 6")
end

-- a block whose count is past eight sets the long mark; nine records, no pad
do
  local b = { 0x8C, 0x80, 0x00 }
  for i = 4, 3 + 0x80 do b[i] = 0 end
  b[4] = 9
  for i = 0, 8 do b[5 + i * 0x0E] = 0x30 + i end
  b[4 + 0x80] = 0x94
  local vm = run(b)
  ok(vm:rd8(0xCCE2) == 1, "$8C count above eight sets CCE2")
  local rows = true
  for i = 0, 7 do if vm:rd8(0xCCCD + i) ~= 0x30 + i then rows = false end end
  ok(rows, "$8C takes the first eight record bytes")
end

-- $8D saves the SRAM mark and arms the window slot
do
  local vm = run({ 0x8D, 0x94 }, {}, function(vm)
    vm:wr8(0xA122, 0x5A); vm:wr8(0xC937, 2)
  end)
  ok(vm:rd8(0xCD58) == 0x5A, "$8D copies A122 to CD58")
  ok(vm:rd8(0xCC4E) == 1 and vm:rd8(0xCC56) == 1 and vm:rd8(0xCC59) == 1, "$8D window marks")
  ok(vm:rd8(0xC728) == 0 and vm:rd8(0xC729) == 0, "$8D clears the shadow-OAM cursors")
  ok(vm:rd8(0xCCB4) == 7 and vm:rd8(0xCCB6) == 0x4D and vm:rd8(0xCCB7) == 0xCC, "$8D slot")
  ok(vm:rd8(0xCCB9) == 0 and vm:rd8(0xCD81) == 1 and vm:rd8(0xCCB8) == 2, "$8D slot id and bank")
  ok(vm:rd8(0xC6E7) == 0xD0 and vm:rd8(0xC6E8) == 0x41, "$8D glyph source")
  ok(vm:rd8(0xCC42) == 5 and vm:rd8(0xCC43) == 0xE0 and vm:rd8(0xCC45) == 0x20, "$8D final tile list")
end

-- $8F copies the block, then replaces the length with the SRAM byte
do
  local vm = run({ 0x8F, 0x03, 0x00, 0xAA, 0xBB, 0xCC, 0x94 }, {}, function(vm)
    vm:wr8(0xA122, 0x0A)
  end)
  ok(vm:rd8(0x6D000) == 0xAA and vm:rd8(0x6D002) == 0xCC, "$8F block bytes")
  ok(vm:rd8(0xCCCC) == 0x0A, "$8F length is the SRAM byte, not the block")
  ok(vm:rd8(0xCCE2) == 1, "$8F long mark follows that length")
  ok(vm:rd8(0xCCE4) == 0x18 and vm:rd8(0xCCE5) == 0xA1, "$8F list pointer")
  ok(vm:rd8(0xCCE3) == 3 and vm:rd8(0xCCEB) == 0xF3 and vm:rd8(0xCCA7) == 0xFF, "$8F choice bytes")
end

-- $90 skips three bytes, then copies the counted block
do
  local vm = run({
    0x90, 0x1A, 0x11, 0x54, 0x04, 0x00,
    0x70, 0x71, 0x72, 0x73,
    0xAC, 0x00, 0xC0, 0x21,
    0x94,
  })
  ok(vm:rd8(0x6D000) == 0x70 and vm:rd8(0x6D003) == 0x73, "$90 block follows the skipped bytes")
  ok(vm:rd8(0x6D004) == 0, "$90 does not copy the opcode after the block")
  ok(vm:rd8(0xCCCC) == 0x70, "$90 length byte is the first copied byte")
  ok(vm:rd8(0xCCE4) == 0xA7 and vm:rd8(0xCCE5) == 0xA3, "$90 list is the item counts")
  ok(vm:rd8(0xCCE8) == 0x22 and vm:rd8(0xCCE9) == 0x0C and vm:rd8(0xCCEA) == 0x0D, "$90 record shape")
  ok(vm:rd8(0xCCB4) == 6 and vm:rd8(0xCD81) == 0 and vm:rd8(0xCCEB) == 4, "$90 slot and mark")
  ok(vm:rd8(0xC000) == 0x21, "$90 resumes after the block")
end

-- host() publishes the camera box on the overworld
do
  local ow = { def = {} }
  local h = {}
  Travel.host(ow, h)
  h.seedCamera(0x20)
  h.travelBg(0x27, 0x7179)
  h.travelTiles(0x27, 0x58FE)
  ok(ow.def.camCol == 0x20 and ow.def.camRow == 0x20 and ow.camBox == 0x20, "seedCamera sets the map camera box")
  ok(ow.travelBg[1] == 0x27 and ow.travelBg[2] == 0x7179, "travelBg records the background pointer")
  ok(ow.travelTiles[1] == 0x27 and ow.travelTiles[2] == 0x58FE, "travelTiles records the tile-list pointer")
end

print(("mn_ops_travel: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
