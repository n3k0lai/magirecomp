-- Opcode $A4 chest grants (PlantOffset7ThenStoreFF / CopyThreeBank7).
-- Synthetic bytes only.
--   luajit tests/engine/mn_chest_test.lua
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

local COST = 0x2A

local function poke(s, off, bytes)
  return s:sub(1, off) .. string.char(unpack(bytes)) .. s:sub(off + #bytes + 1)
end

local function plant(s, bank, ptr, bytes)
  return poke(s, bank * 0x4000 + ptr - 0x4000, bytes)
end

-- Branch scripts planted where LCDOnAfterOffset7Record sends the chest.
local function rom()
  local s = string.rep("\0", 0x200000)
  s = plant(s, 0x22, 0x4048, { 0xAC, 0x00, 0xC0, 0x48, 0x94 }) -- granted
  s = plant(s, 0x22, 0x405B, { 0xAC, 0x00, 0xC0, 0x5B, 0x94 }) -- flag already set
  s = plant(s, 0x22, 0x4074, { 0xAC, 0x00, 0xC0, 0x74, 0x94 }) -- full
  local probe = VM.new(MnRom.new(s), {})
  s = poke(s, probe:recordOff(3, 1) - 8, { COST })
  -- $A4 flag $A328 mask $01, category, id, cell $D010. Then $87 twins.
  s = plant(s, 0x12, 0x4000, {
    0xA4, 0x28, 0xA3, 0x01, 0x03, 0x01, 0x10, 0xD0,
  })
  s = plant(s, 0x12, 0x4010, {
    0xA4, 0x28, 0xA3, 0x02, 0x02, 0x03, 0x20, 0xD0,
  })
  s = plant(s, 0x12, 0x4020, {
    0xA4, 0x28, 0xA3, 0x04, 0x02, 0x04, 0x30, 0xD0,
  })
  s = plant(s, 0x12, 0x4030, { 0x87, 0x03, 0x01, 0x07, 0x94 })
  s = plant(s, 0x12, 0x4038, { 0x87, 0x02, 0x05, 0x02, 0x94 })
  return MnRom.new(s)
end

local ROM = rom()

local function run(ptr, prep)
  local cells = {}
  local s = { items = {}, log = {}, rom = ROM }
  local h = Overworld.host(s)
  h.setMetatile = function(addr, mt) cells[#cells + 1] = { addr, mt } end
  h.sound = function() end
  local vm = VM.new(ROM, h)
  s.vm = vm
  if prep then prep(vm) end
  vm:start(0x12, ptr)
  return vm, cells
end

-- Category 3: spell byte and flag. A second open takes 22:405B.
do
  local vm, cells = run(0x4000)
  ok(vm:rd8(0xA5A6) == COST, "$A4 category 3 stores the spell byte at $A5A5+id")
  ok(vm:rd8(0xC9FD) == 1, "$A4 category 3 leaves $C9FD set")
  ok(vm:rd8(0xA328) == 0x01, "$A4 category 3 sets the flag bit")
  ok(cells[1] and cells[1][1] == 0xD010 and cells[1][2] == 0xFF, "$A4 category 3 clears the cell")
  ok(#cells == 1, "$A4 category 3 writes the cell once")
  ok(vm:rd8(0xC000) == 0x48, "$A4 category 3 continues at 22:4048")
  vm, cells = run(0x4000, function(m) m:wr8(0xA328, 0x01); m:wr8(0xA5A6, COST) end)
  ok(vm:rd8(0xC000) == 0x5B, "a second open takes the empty branch 22:405B")
  ok(vm:rd8(0xA328) == 0x01, "the empty branch leaves the flag")
  ok(vm:rd8(0xA5A6) == COST, "the empty branch does not rewrite the spell")
  ok(#cells == 0, "the empty branch does not change the cell")
end

-- Category 2 (Bank7CopyIndexedName -> AddByteToScanC): the relic count at
-- sEntryScan $A019 + id gains $C9FE = 1; a carry stores $FF and takes 22:4074.
do
  local vm, cells = run(0x4010)
  ok(vm:rd8(0xA01C) == 1, "$A4 category 2 adds one to $A019+id")
  ok(vm:rd8(0xC9FD) == 1 and vm:rd8(0xC9FE) == 1, "$A4 category 2 leaves $C9FD = 1, $C9FE = 1")
  ok(vm:rd8(0xA328) == 0x02, "$A4 category 2 sets the flag bit")
  ok(cells[1] and cells[1][1] == 0xD020 and cells[1][2] == 0xFF, "$A4 category 2 clears the cell")
  ok(vm:rd8(0xC000) == 0x48, "$A4 category 2 continues at 22:4048")
  vm, cells = run(0x4020, function(m) m:wr8(0xA01D, 0xFF) end)
  ok(vm:rd8(0xA01D) == 0xFF and vm:rd8(0xC9FD) == 0, "a full relic count stays $FF and clears $C9FD")
  ok(vm:rd8(0xA328) == 0 and #cells == 0, "the full branch leaves the flag and the cell")
  ok(vm:rd8(0xC000) == 0x74, "the full branch continues at 22:4074")
  vm = run(0x4020, function(m) m:wr8(0xA01D, 0x05) end)
  ok(vm:rd8(0xA01D) == 0x06, "a held relic count goes up by one")
end

-- The same helpers serve opcode $87.
do
  local vm = run(0x4030)
  ok(vm:rd8(0xA5A6) == COST, "$87 category 3 stores the same spell byte")
  ok(vm:rd8(0xC9FD) == 1, "$87 category 3 sets $C9FD")
end

print(("mn_chest: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
