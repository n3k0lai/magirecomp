-- $9D Opcode9D -> bank-1 $4972: waits while $C6EE is 1, resumes the frame after it reads 2.
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

-- 12:4000 $9D ; AC C004 := 7 ; $94
local s = string.rep("\0", 0x12 * 0x4000) .. string.char(0x9D, 0xAC, 0x04, 0xC0, 0x07, 0x94)
local rom = MnRom.new(s .. string.rep("\0", 0x200000 - #s))
local vm = VM.new(rom, {})
vm:wr8(0xC6EE, 1)
vm:start(0x12, 0x4000)
ok(vm:rd8(0xC004) == 0, "$9D holds while $C6EE ~= 2")
vm:resume(); vm:resume()
ok(vm:rd8(0xC004) == 0, "$9D still holds a few frames later")
vm:wr8(0xC6EE, 2)
vm:resume() -- Opcode9DBody sees 2: RestoreDispatchScriptOpcode, frame ends
ok(vm:rd8(0xC004) == 0, "$9D's restore takes its own frame")
vm:resume()
ok(vm:rd8(0xC004) == 7, "$9D goes on once $C6EE is 2")
ok(not vm.logged[0x9D], "$9D is not logged unimplemented")
print(("mn_op9d: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
