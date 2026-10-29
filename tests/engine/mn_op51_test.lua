-- $51 JumpDispatchScriptOpcode ($16BE) is `jp DispatchScriptOpcode`: no operands, the
-- next op runs in the same pass. ScriptVM logged it "unimplemented" (map 73 uses it).
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

local pre = string.rep("\0", 0x12 * 0x4000)
-- 12:4000 $51 ; $51 ; $AC C004 := 7 ; $94
local s = pre .. string.char(0x51, 0x51, 0xAC, 0x04, 0xC0, 0x07, 0x94)
local rom = MnRom.new(s .. string.rep("\0", 0x200000 - #s))
ok(rom:insn(0x12 * 0x4000) == 1, "$51 is one byte")
local vm = VM.new(rom, {})
vm:runInit(0x12, 0x4000)
ok(vm:rd8(0xC004) == 7, "ops after $51 run")
ok(not vm.logged[0x51], "$51 is not logged unimplemented")
print(("mn_op51: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
