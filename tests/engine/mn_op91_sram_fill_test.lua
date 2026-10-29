-- $91 BranchBank1OnScriptByte (branch_bank1_on_script_byte.asm): new-game SRAM fills.
-- Zero byte (fill_sram_after_zero_script_byte.asm): $00 over $A019-$A6A3, $FF over the
-- ten sEntryIds ($A118-$A121), $FF over $A025-$BE34 in SRAM bank +1, then
-- Copy7646IntoNextSRAMBank puts the $1F bytes at 02:7646 at $A000 of bank +1.
-- Nonzero byte (fill_sram_after_nonzero_script_byte.asm): $00 over $A123-$A6A3 only.
-- The port used to skip the op ("our SRAM table starts zeroed"), so story flags and rings
-- from a loaded save survived the new-game scripts (2A:6D3B, 2A:6E1B).
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

local t = {}
for i = 0, 0x1E do t[#t + 1] = string.char(0x40 + i) end
local s = string.rep("\0", 2 * 0x4000 + 0x3646) .. table.concat(t)
s = s .. string.rep("\0", 0x12 * 0x4000 - #s)
s = s .. string.char(0x91, 0x00, 0x94) .. string.rep("\0", 13) .. string.char(0x91, 0x01, 0x94)
local rom = MnRom.new(s .. string.rep("\0", 0x200000 - #s))

local function seeded()
  local vm = VM.new(rom, {})
  for _, a in ipairs({ 0xA010, 0xA019, 0xA118, 0xA121, 0xA122, 0xA123, 0xA3A5, 0xA6A3, 0xA6A4 }) do
    vm:wr8(a, 0x5A)
  end
  vm.sramBank = 0
  vm.sramBanks = { [1] = string.rep("\7", 0x2000) }
  return vm
end

local vm = seeded()
vm:start(0x12, 0x4000)
ok(vm:rd8(0xA010) == 0x5A, "zero fill starts at $A019")
ok(vm:rd8(0xA019) == 0 and vm:rd8(0xA3A5) == 0 and vm:rd8(0xA6A3) == 0, "zero fill clears $A019-$A6A3")
ok(vm:rd8(0xA6A4) == 0x5A, "zero fill stops at $A6A3")
ok(vm:rd8(0xA118) == 0xFF and vm:rd8(0xA121) == 0xFF, "sEntryIds are $FF")
ok(vm:rd8(0xA122) == 0, "the ring count is cleared")
local img = vm.sramBanks[1]
ok(img:byte(1) == 0x40 and img:byte(0x1F) == 0x5E, "02:7646 is copied to $A000 of the next bank")
ok(img:byte(0x20) == 7 and img:byte(0x25) == 7, "$A01F-$A024 of the next bank are untouched")
ok(img:byte(0x26) == 0xFF and img:byte(0x25 + 0x1E10) == 0xFF, "$A025-$BE34 of the next bank are $FF")
ok(img:byte(0x26 + 0x1E10) == 7 and #img == 0x2000, "the next-bank fill stops at $BE34")

local v2 = seeded()
v2:start(0x12, 0x4010)
ok(v2:rd8(0xA118) == 0x5A and v2:rd8(0xA122) == 0x5A, "a nonzero byte keeps the rings")
ok(v2:rd8(0xA123) == 0 and v2:rd8(0xA6A3) == 0 and v2:rd8(0xA6A4) == 0x5A, "a nonzero byte clears $A123-$A6A3")
ok(v2.sramBanks[1] == string.rep("\7", 0x2000), "a nonzero byte leaves the next bank alone")
print(("mn_op91_sram_fill: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
