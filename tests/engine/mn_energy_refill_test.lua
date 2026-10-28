-- $87 categories 5 and 6 (bank 7 AddC9FEClampMapWord1/2): Tony's energy words
-- sMapWord1 ($A005, current) and sMapWord2 ($A007, max), big-endian in the next
-- SRAM bank. The town-duel loss tail 1A:6FEA opens with $87 05 05 C8 five times.
--   luajit tests/engine/mn_energy_refill_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local SaveFile = require("mn.SaveFile")

local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

local ZERO = string.rep("\0", SaveFile.BANK_SIZE)
local function run(bytes, cur, max)
  local vm = VM.new(image(bytes), {})
  local b = ZERO
  for a, v in pairs({ [0xA005] = math.floor(cur / 256), [0xA006] = cur % 256,
                      [0xA007] = math.floor(max / 256), [0xA008] = max % 256 }) do
    b = SaveFile.poke(b, a, v)
  end
  vm.sramBank = 0
  vm.sramBanks = { [0] = ZERO, [1] = b, [2] = ZERO, [3] = ZERO }
  vm:start(0x12, 0x4000)
  local nb = vm.sramBanks[1]
  local function word(a) return SaveFile.peek(nb, a) * 256 + SaveFile.peek(nb, a + 1) end
  return vm, word(0xA005), word(0xA007)
end

local refill = {}
for _ = 1, 5 do for _, v in ipairs({ 0x87, 0x05, 0x05, 0xC8 }) do refill[#refill + 1] = v end end
refill[#refill + 1] = 0x94

do -- 1A:6FEA: five +200 steps clamp the current energy to the max (300, $012C)
  local vm, cur, max = run(refill, 3, 300)
  ok(cur == 300, "$87 05 refills current energy to the max, got " .. cur)
  ok(max == 300, "$87 05 leaves the max alone")
  ok(not vm.logged[0x87], "$87 05 is not logged as unimplemented")
end

do -- below the max no clamp: 10 + 200 = 210 of 500
  local _, cur = run({ 0x87, 0x05, 0x05, 0xC8, 0x94 }, 10, 500)
  ok(cur == 210, "$87 05 adds the count, got " .. cur)
end

do -- category 6 raises the max, capped at 999 ($03E7)
  local _, cur, max = run({ 0x87, 0x06, 0x00, 0x20, 0x87, 0x06, 0x00, 0xFF,
                            0x87, 0x06, 0x00, 0xFF, 0x87, 0x06, 0x00, 0xFF,
                            0x87, 0x06, 0x00, 0xFF, 0x94 }, 7, 950)
  ok(max == 999, "$87 06 caps the max at 999, got " .. max)
  ok(cur == 7, "$87 06 leaves the current energy alone")
end

print(("mn_energy_refill_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
