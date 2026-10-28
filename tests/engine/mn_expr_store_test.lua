-- $A5/$A6/$A7 (store an expression into SRAM) have operand sizes. MnRom:insn returned nil
-- for their "expr_w"/"expr_wb" kinds, so ScriptVM logged them unimplemented and ended the
-- record: the ferry fare (a word store of Animite - 300) never paid and the boat never left.
-- ROM-free: synthetic bytes in an otherwise empty 2 MiB image.
--   luajit tests/engine/mn_expr_store_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- 12:4000 $A7 C000 := (word C000 - 300); 12:400A $A6 C002 := imm 5;
-- 12:4011 $A5 C003 |= $80 when imm 1; 12:4019 $AC C004 := 7 (reached only if all three are sized)
local prog = {
  0xA7, 0x00, 0xC0, 0x0C, 0x02, 0x00, 0xC0, 0x06, 0x2C, 0x01,
  0xA6, 0x02, 0xC0, 0x06, 0x05, 0x00,
  0xA5, 0x03, 0xC0, 0x80, 0x06, 0x01, 0x00,
  0xAC, 0x04, 0xC0, 0x07,
}
local rom = image(prog)
local base = 0x12 * 0x4000
ok(rom:insn(base) == 10, "$A7 word store is 10 bytes")
ok(rom:insn(base + 10) == 6, "$A6 store is 6 bytes")
ok(rom:insn(base + 16) == 7, "$A5 mask store is 7 bytes")

local vm = VM.new(rom, {})
vm:wr8(0xC000, 327 % 256); vm:wr8(0xC001, math.floor(327 / 256)) -- 327 Animite
vm:runInit(0x12, 0x4000)
ok(vm:rd8(0xC000) + 256 * vm:rd8(0xC001) == 27, "fare paid: 327 - 300 = 27")
ok(vm:rd8(0xC002) == 5, "$A6 stored its low byte")
ok(vm:rd8(0xC003) == 0x80, "$A5 or-ed its mask")
ok(vm:rd8(0xC004) == 7, "the record runs on past the stores")
ok(not vm.logged[0xA7] and not vm.logged[0xA6] and not vm.logged[0xA5], "none logged unimplemented")

print(("mn_expr_store: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
