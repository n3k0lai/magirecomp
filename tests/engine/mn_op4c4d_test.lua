-- $4C QueueRepeatedSpriteList ($1560) and $4D StepScriptSpritePointerTable ($15E8) plant
-- themselves as hScriptHandler and step once per frame; the script only goes on after the
-- last record ($4C: sum of the record counts) or the last table entry ($4D: entries x count).
-- ScriptVM skipped both ("unimplemented") so a thread ran ahead with no wait.
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
-- 12:4000 $4C (2,dx,dy,list)(3,dx,dy,list)(0) ; $AC C004 := 7 ; $94
local a = string.char(0x4C, 2, 0, 0, 0x00, 0x50, 3, 0, 0, 0x00, 0x50, 0, 0xAC, 0x04, 0xC0, 0x07, 0x94)
-- 12:4040 $4D size 4 (2 lists), count 3, dx, dy, w, w ; $AC C005 := 9 ; $94
local b = string.char(0x4D, 4, 3, 0, 0, 0x00, 0x50, 0x10, 0x50, 0xAC, 0x05, 0xC0, 0x09, 0x94)
local s = pre .. a .. string.rep("\0", 0x40 - #a) .. b
local rom = MnRom.new(s .. string.rep("\0", 0x200000 - #s))
ok(rom:insn(0x12 * 0x4000) == 12, "$4C size runs to the zero count")
ok(rom:insn(0x12 * 0x4000 + 0x40) == 9, "$4D size is 5 + table bytes")

local vm = VM.new(rom, {})
ok(vm:start(0x12, 0x4000) == true, "$4C blocks the script")
ok(vm.wait == 5, "$4C waits the sum of its record counts (2+3)")
ok(vm:rd8(0xC004) == 0, "ops after $4C have not run yet")
vm:resume()
ok(vm:rd8(0xC004) == 7, "ops after $4C run once it is done")
ok(not vm.logged[0x4C], "$4C is not logged unimplemented")

local v2 = VM.new(rom, {})
ok(v2:start(0x12, 0x4040) == true, "$4D blocks the script")
ok(v2.wait == 6, "$4D waits entries x count (2 x 3)")
ok(v2:rd8(0xC005) == 0, "ops after $4D have not run yet")
v2:resume()
ok(v2:rd8(0xC005) == 9, "ops after $4D run once it is done")
ok(not v2.logged[0x4D], "$4D is not logged unimplemented")

-- map setup (LCD off) never yields: the op is passed over
local v3 = VM.new(rom, {})
v3:runInit(0x12, 0x4000)
ok(v3:rd8(0xC004) == 7, "$4C during map setup does not stall init")
print(("mn_op4c4d: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
