-- Colored gates. Synthetic plane only: a cell below $08 is solid when
-- the byte at $C12A + cell is nonzero. The bank-5 default pattern leaves
-- $04-$07 solid. Floor $00 stays open.
--   luajit tests/engine/mn_gates_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local bit = require("bit")
local World = require("mn.World")

-- One row of floor, the four gate colors, and a wall. $06 is column 3.
local function plane()
  local block = {}
  local row = { 0x00, 0x04, 0x05, 0x06, 0x07, 0x08 }
  for i = 1, #row do block[i] = row[i] end
  return { w = #row, h = 1, block = block }
end

local function pattern(c130)
  local bytes = { 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF }
  local mem = {}
  for i = 0, 7 do mem[0xC12A + i] = bytes[i + 1] end
  if c130 ~= nil then mem[0xC130] = c130 end
  return mem
end

local def = plane()

local function open(x, mem)
  return World.walkable(World.cell(def, x, 0), mem)
end

-- Unbound probe uses WriteC12APatternBank5. Do this before seedPattern
-- binds a VM, which replaces that fallback.
ok(open(0) == true, "default pattern leaves floor $00 open")
ok(open(1) == false, "default pattern blocks $04")
ok(open(2) == false, "default pattern blocks $05")
ok(open(3) == false, "default pattern blocks $06")
ok(open(4) == false, "default pattern blocks $07")
ok(open(5) == false, "wall $08 stays solid")
ok(World.walkable(0x03) == true, "default pattern leaves $03 open")
ok(World.walkable(0x01) == false, "default pattern blocks $01")
ok(World.walkable(0x81) == true, "$81 stays clear")
ok(World.walkable(0xC0) == true, "a step trigger stays walkable")

-- Explicit $C130. The other three colors keep the default $FF.
local shut = pattern(0xFF)
ok(open(3, shut) == false, "$C130=$FF blocks the $06 cell")
ok(open(0, shut) == true, "floor $00 stays open while $06 is shut")
ok(open(1, shut) == false and open(2, shut) == false and open(4, shut) == false,
  "$04 $05 $07 stay blocked under the default pattern")

local open6 = pattern(0)
ok(open(3, open6) == true, "$C130=0 lets the $06 cell through")
ok(open(1, open6) == false and open(2, open6) == false and open(4, open6) == false,
  "opening $06 does not open the other colors")
ok(open(0, open6) == true, "floor $00 is unchanged when $06 is open")
ok(World.cell(def, 3, 0) == 0x06, "the plane cell is $06")

-- Opcode $85 writes the same four bytes the probe reads.
do
  love = { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111
  local MnRom = require("mn.MnRom")
  local VM = require("mn.ScriptVM")
  local bytes = { 0x85, 0x0B, 0x97 }
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  local rom = MnRom.new(s .. string.rep("\0", 0x200000 - #s))
  local vm = VM.new(rom, {})
  World.seedPattern(vm)
  ok(vm:rd8(0xC12A) == 0x00 and vm:rd8(0xC12B) == 0xFF and vm:rd8(0xC12C) == 0xFF
    and vm:rd8(0xC12D) == 0x00, "seed writes the bank-5 pattern at $C12A")
  ok(vm:rd8(0xC12E) == 0xFF and vm:rd8(0xC131) == 0xFF, "seed leaves $04-$07 solid")
  vm:start(0x12, 0x4000)
  ok(vm:rd8(0xC12E) == 0xFF and vm:rd8(0xC12F) == 0xFF and vm:rd8(0xC130) == 0
    and vm:rd8(0xC131) == 0xFF, "opcode $85 with $0B opens only $06")
  ok(World.walkable(0x06) == true, "the live $C130=0 byte lets $06 through")
  ok(World.walkable(0x04) == false and World.walkable(0x05) == false
    and World.walkable(0x07) == false, "the other three colors stay blocked")
  ok(World.walkable(0x00) == true, "floor $00 stays open after opcode $85")
  -- a later write of $FF at $C130 shuts it again, the way a new operand would
  vm:wr8(0xC130, 0xFF)
  ok(World.walkable(0x06) == false, "a nonzero $C130 blocks $06 again")
  ok(bit.band(vm:rd8(0xC130), 0xFF) == 0xFF, "$C130 holds the blocking byte")
end

if failures == 0 then print(("ok %d checks"):format(checks))
else print(("%d FAILED / %d"):format(failures, checks)); os.exit(1) end
