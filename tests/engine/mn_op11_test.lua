-- $11 Opcode11 -> MapBank1AndJump ($0C8F) -> PickMapCellFromDiv (01:4456) ->
-- MatchWRAM5ScriptByte ($0C9A): one pass picks a cell in view from two rDIV reads,
-- the next pass keeps it only when it is not the $C190 cell and its WRAM-5 byte equals
-- the operand; otherwise Opcode11 runs again on the pass after.
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

-- made-up tables at 01:638E: column addends 0..15 = nibble, rows: nibble n -> addend n % 4,
-- pointer $C84B + 2 * (n % 4)
local cols, rows = {}, {}
for n = 0, 15 do cols[#cols + 1] = string.char(n) end
for n = 0, 15 do local k = n % 4; local p = 0xC84B + 2 * k; rows[#rows + 1] = string.char(k, p % 256, math.floor(p / 256)) end
local b = string.rep("\0", 0x638E) .. table.concat(cols) .. table.concat(rows)
-- 13:4000 $11 $B0 ; AC C004 := 7 ; $94
local s = b .. string.rep("\0", 0x13 * 0x4000 - #b) .. string.char(0x11, 0xB0, 0xAC, 0x04, 0xC0, 0x07, 0x94)
local rom = MnRom.new(s .. string.rep("\0", 0x200000 - #s))

local blocks, moved = {}, {}
local seq, i = {}, 0
local host = {
  div = function() i = i + 1; return seq[i] end,
  mapView = function() return 10, 20, 40 end,
  blockByte = function(a) return blocks[a] or 0 end,
  scatter = function(slot, c, r, f) moved[#moved + 1] = { slot, c, r, f } end,
}
-- attempt 1: low nibble 2 (row +2, k 2), high nibble 7 (col +7): byte $00 -> retry
-- attempt 2: low nibble 1 (row +1, k 1), high nibble 3 (col +3): byte $B0 -> keep
seq = { 0x02, 0x70, 0x31, 0x31 }
local hit = 0xD000 + 20 * 40 + 10 + 1 * 40 + 3
blocks[hit] = 0xB0
local vm = VM.new(rom, host)
vm.curSlot = 4
vm:start(0x13, 0x4000)
local passes = 0
while vm:rd8(0xC004) == 0 and passes < 50 do vm:resume(); passes = passes + 1 end
ok(vm:rd8(0xC004) == 7, "$11 continues after a match")
-- pick, check, Opcode11, pick, check, next op = 6 passes after the $11 pass
ok(passes == 6, "three passes per attempt (got " .. passes .. ")")
ok(vm:rd8(0xFF91) == 13 and vm:rd8(0xFF92) == 21, "record cell is camera + addends")
ok(vm:rd16(0xFF93) == hit, "cell pointer is wMapPointer + k * stride + column addend")
ok(#moved == 3 and moved[3][4] == true and not moved[2][4] and moved[2][1] == 4 and moved[2][2] == 13 and moved[2][3] == 21, "each attempt moves the record")

-- the $C190 cell is refused even when its byte matches
seq = { 0x31, 0x31, 0x02, 0x70 }; i = 0
blocks[0xD000 + 20 * 40 + 10 + 2 * 40 + 7] = 0xB0
local vm2 = VM.new(rom, host)
vm2:wr8(0xC190, hit % 256); vm2:wr8(0xC191, math.floor(hit / 256))
vm2:start(0x13, 0x4000)
passes = 0
while vm2:rd8(0xC004) == 0 and passes < 50 do vm2:resume(); passes = passes + 1 end
ok(vm2:rd8(0xFF91) == 17 and vm2:rd8(0xFF92) == 22, "$C190 cell skipped, second pick kept")

-- the cell table helper alone
seq = { 0x0F, 0xF0 }; i = 0
local c, r, p = VM.pickCell(VM.new(rom, host))
ok(c == 25 and r == 23 and p == 0xD000 + 20 * 40 + 10 + 3 * 40 + 15, "pickCell nibble F/F")
print(("mn_op11: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
