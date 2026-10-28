-- Map 250's pirate wake (story $0E -> $0F). 250's live trigger list (bank $21)
-- is two kind-2 step triggers: $C0 (9-10,19, exit) and $C1 (9-10,16, the
-- wake). Kind 2 fires only when Tony steps onto the cell moving down. The
-- $C1 script is SRAMLookupInstallScript ($43) on
-- AND($A224 == 3, story word == $0E), whose target takes slot 2 ($0B 02).
-- Slot 2 (the pirate) only exists after a fresh entry into 250, so the wake
-- needs: chest ($A224 = 3), leave, re-enter, then walk down onto row 16.
-- Synthetic bytes in the same shape; no ROM data.
--   luajit tests/engine/mn_down_trigger_wake_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local World = require("mn.World")

-- bank $12 at $4000: the trigger script; $4020: the wake target
local cond = { 0x08, 0x0F, 0x01, 0x24, 0xA2, 0x05, 0x03, 0x0F, 0x04, 0x05, 0x0E }
local function image()
  local b = {}
  b[1] = 0x43
  for _, v in ipairs(cond) do b[#b + 1] = v end
  b[#b + 1] = 0x12; b[#b + 1] = 0x20; b[#b + 1] = 0x40 -- -> 12:4020
  b[#b + 1] = 0x42 -- park
  while #b < 0x20 do b[#b + 1] = 0 end
  b[#b + 1] = 0x0B; b[#b + 1] = 0x02; b[#b + 1] = 0x42 -- take slot 2, park
  local s = string.rep("\0", 0x12 * 0x4000) .. string.char(unpack(b))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

local function eval(a224, story)
  local vm = VM.new(image(), {})
  vm.mem[0xA224] = a224; vm.mem[0xA123] = story; vm.mem[0xA124] = 0
  return (vm:expr(VM.off(0x4001, 0x12)))
end

ok(eval(3, 0x0E) ~= 0, "wake condition holds at $A224 = 3, story $0E")
ok(eval(2, 0x0E) == 0, "no wake before the chest ($A224 = 2)")
ok(eval(4, 0x0E) == 0, "no second wake once talked ($A224 = 4)")
ok(eval(3, 0x0F) == 0, "no wake after the horn (story $0F)")

-- kind 2 is down-only: walking up from the 9,19 entry over 9,16 must not fire
ok(World.gate(2, 0, 1), "kind 2 fires stepping down")
ok(not World.gate(2, 0, -1), "kind 2 does not fire stepping up")
ok(not World.gate(2, 1, 0) and not World.gate(2, -1, 0), "kind 2 does not fire sideways")

print(("mn_down_trigger_wake: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
