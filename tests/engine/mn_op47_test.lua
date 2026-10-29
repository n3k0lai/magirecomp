-- $47 PickScriptRecordByDividerMod ($1484) + AddDividerStep: hDividerAccum ($FFA9) +=
-- ((swap(DIV1) sra 1) + DIV2) & 7 - 3, record = (accum & $0F) mod count, in every thread
-- (the port used to pick record 0 outside slot threads and a uniform random in them).
-- ROM-free: synthetic bytes in an otherwise empty 2 MiB image.
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

-- swap($12)=$21, sra -> $10; +$05 = $15 & 7 = 5; -3 = +2
ok(VM.dividerStep(0x40, 0x12, 0x05) == 0x42, "step +2")
-- swap($80)=$08, sra -> $04; +$00 = 4; -3 = +1
ok(VM.dividerStep(0xFF, 0x80, 0x00) == 0x00, "step wraps at $FF")
-- swap($08)=$80, sra -> $C0; +$00 = $C0 & 7 = 0; -3 = -3
ok(VM.dividerStep(0x02, 0x08, 0x00) == 0xFF, "step -3 wraps below zero")

local pre = string.rep("\0", 0x12 * 0x4000)
-- 12:4000 $47 3, (12:4010) (12:4018) (12:4020)
local a = string.char(0x47, 3, 0x12, 0x10, 0x40, 0x12, 0x18, 0x40, 0x12, 0x20, 0x40)
local function store(v) return string.char(0xAC, 0x04, 0xC0, v, 0x94) end
local s = pre .. a .. string.rep("\0", 0x10 - #a) .. store(1) .. string.rep("\0", 3) .. store(2) .. string.rep("\0", 3) .. store(3)
local rom = MnRom.new(s .. string.rep("\0", 0x200000 - #s))

local function run(acc, d1, d2)
  local seq = { d1, d2 }; local i = 0
  local vm = VM.new(rom, { div = function() i = i + 1; return seq[i] end })
  vm:wr8(0xFFA9, acc)
  vm:start(0x12, 0x4000)
  return vm:rd8(0xC004), vm:rd8(0xFFA9)
end
-- acc $40 +2 = $42: nibble 2 mod 3 = 2 -> third record
local v, acc = run(0x40, 0x12, 0x05)
ok(v == 3 and acc == 0x42, "nibble 2 picks record 2 and keeps the accumulator")
-- acc $0C +1 = $0D: nibble 13 mod 3 = 1 -> second record
v = run(0x0C, 0x80, 0x00)
ok(v == 2, "nibble 13 mod 3 picks record 1")
-- acc $02 -3 = $FF: nibble 15 mod 3 = 0 -> first record
v = run(0x02, 0x08, 0x00)
ok(v == 1, "nibble 15 mod 3 picks record 0")
print(("mn_op47: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
