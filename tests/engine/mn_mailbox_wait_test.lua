-- Mailbox waits $60-$62 and $5D-$5F resume on the frame after the match:
-- MatchScriptByteThenPlantHandler / PlantInitialScriptHandlerUnlessZero plant
-- INITIAL_SCRIPT_HANDLER and return, so the next opcode is dispatched next frame.
-- Synthetic bytes only.
--   luajit tests/engine/mn_mailbox_wait_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local function image(at)
  local t = {}
  for i = 1, 0x13 * 0x4000 do t[i] = 0 end
  for addr, bytes in pairs(at) do
    for i, v in ipairs(bytes) do t[0x12 * 0x4000 + addr - 0x4000 + i] = v end
  end
  local parts = {}
  for i = 1, #t, 4096 do parts[#parts + 1] = string.char(unpack(t, i, math.min(i + 4095, #t))) end
  local s = table.concat(parts)
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- 12:4000: wait C6FD == $07, post C6F8 $09, park
-- 12:4100: wait C6FB nonzero, post C6FA $0B, park
local rom = image({
  [0x4000] = { 0x62, 0x07, 0x56, 0x09, 0x42 },
  [0x4100] = { 0x5E, 0x57, 0x0B, 0x42 },
})
local vm = VM.new(rom, {})
vm.mem[0xC6FC] = 0x07 -- moves to C6FD at the first tick
vm.mem[0xC6FA] = 0x01
vm:spawnThread(2, 0x12, 0x4000)
vm:spawnThread(3, 0x12, 0x4100)
vm:tickThreads(false)
ok(vm:rd8(0xC6FD) == 0x07 and vm:rd8(0xC6F8) == 0, "$62 matches on frame 1 but does not post yet")
ok(vm:rd8(0xC6FA) == 0, "$5E sees the post on frame 1 but does not post yet")
vm:tickThreads(false)
ok(vm:rd8(0xC6F8) == 0x09, "$62: the next opcode runs on frame 2")
ok(vm:rd8(0xC6FA) == 0x0B, "$5E: the next opcode runs on frame 2")

print(("mn_mailbox_wait_test: %d/%d ok"):format(checks - failures, checks))
os.exit(failures == 0 and 0 or 1)
