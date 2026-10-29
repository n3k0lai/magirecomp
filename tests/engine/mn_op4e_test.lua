-- $4E RepeatTwoScriptBytes ($15AB, repeat_two_script_bytes.asm): count, b1, b2. Each frame for
-- count frames b1 -> $C6D2 and b2 -> $C6D3 (fine X/Y step), then the script goes on past b2.
-- A zero count resumes right after the count byte. Sprites.frames used to read it as "repeat the
-- next record count times" (a 10x longer $4C fall).
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
local Sprites = require("mn.Sprites")

local pre = string.rep("\0", 0x12 * 0x4000)
-- 12:4000 $4E 3,(02,FE) ; $AC C004 := 7 ; $94
local a = string.char(0x4E, 3, 0x02, 0xFE, 0xAC, 0x04, 0xC0, 0x07, 0x94)
-- 12:4020 $4E 0 ; then AC C005 := 9 runs as the next op ; $94
local b = string.char(0x4E, 0, 0xAC, 0x05, 0xC0, 0x09, 0x94)
-- 12:4060 $4F (2,01,00,5000)(3,00,01,5000)(0) ; AC C006 := 5 ; $94
local d = string.char(0x4F, 2, 1, 0, 0, 0x50, 3, 0, 1, 0, 0x50, 0, 0xAC, 0x06, 0xC0, 0x05, 0x94)
-- 12:4040 anim: $4E 2,(00,F0) ; $4C (5, 00, 04, list 5000) (0)
local c = string.char(0x4E, 2, 0x00, 0xF0, 0x4C, 5, 0x00, 0x04, 0x00, 0x50, 0)
local s = pre .. a .. string.rep("\0", 0x20 - #a) .. b .. string.rep("\0", 0x20 - #b) .. c .. string.rep("\0", 0x20 - #c) .. d
local rom = MnRom.new(s .. string.rep("\0", 0x200000 - #s))
ok(rom:insn(0x12 * 0x4000) == 4, "$4E with a count is 4 bytes")
ok(rom:insn(0x12 * 0x4000 + 0x20) == 2, "$4E with a zero count is 2 bytes")

local vm = VM.new(rom, {})
ok(vm:start(0x12, 0x4000) == true, "$4E blocks the script")
ok(vm.wait == 3, "$4E waits its count")
ok(vm:rd8(0xC6D2) == 0x02 and vm:rd8(0xC6D3) == 0xFE, "$4E stores b1/b2 at $C6D2/$C6D3")
ok(vm:rd8(0xC004) == 0, "ops after $4E have not run yet")
vm:resume()
ok(vm:rd8(0xC004) == 7, "ops after $4E run once it is done")
ok(not vm.logged[0x4E], "$4E is not logged unimplemented")

local v2 = VM.new(rom, {})
v2:start(0x12, 0x4020)
ok(v2:rd8(0xC005) == 9, "a zero count runs the next bytes as opcodes")

local seq = Sprites.frames(rom, 0x12, 0x4040)
ok(#seq == 2, "$4E + one $4C record = two steps")
ok(seq[1].n == 2 and seq[1].dx == 0 and seq[1].dy == -16 and seq[1].list == nil, "$4E step: count frames of (0,-16), no list")
ok(seq[2].n == 5 and seq[2].dy == 4 and seq[2].list == 0x5000, "the $4C record keeps its own count")
local v3 = VM.new(rom, {})
v3:start(0x12, 0x4060)
ok(v3.wait == 5, "$4F waits the sum of its record counts")
ok(v3:rd8(0xC006) == 0, "ops after $4F wait for it")
v3:resume()
ok(v3:rd8(0xC006) == 5 and not v3.logged[0x4F], "$4F goes on after its zero count")
print(("mn_op4e: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
