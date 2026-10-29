-- How FinishStartup's RunScriptLoop ends (run_script_record.asm): only a nonzero
-- wScriptDone ($C705). $94 (MarkScriptDone21B2) sets it. A park ($42, $12, and the LCD-off
-- parks of $A1/$A2) does not: InstallParkedScript re-runs every pass, so the asm spins.
-- The port runs those passes up to VM.PARK_GUARD, logs the outlier, then ends startup as
-- wScriptDone would. A park by a thread leaves $C705 alone and startup goes on.
-- Synthetic bytes only.
--   luajit tests/engine/mn_startup_park_test.lua
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

local rom = image({
  [0x4000] = { 0x93, 0x42 },                         -- $93, park
  [0x4010] = { 0x93, 0x94, 0x42 },                   -- $93, $94, park (in the field)
  -- $93, $A2: SRAM A000 mask 01 (clear), branch 12:4050, cell byte 07 at D100
  [0x4020] = { 0x93, 0xA2, 0x00, 0xA0, 0x01, 0x12, 0x50, 0x40, 0x07, 0x00, 0xD1 },
  -- $93, $A1: SRAM A000 mask 01 (clear), set/clear bytes 05/06 at D101
  [0x4030] = { 0x93, 0xA1, 0x00, 0xA0, 0x01, 0x12, 0x50, 0x40, 0x05, 0x06, 0x01, 0xD1 },
  [0x4040] = { 0x42 },                               -- a thread that parks
  [0x4050] = { 0x42 },
})

local function logged(vm, s)
  for _, l in ipairs(vm.log) do if l:find(s, 1, true) then return true end end
  return false
end

local function ended(vm) return not vm.startupPending and vm:rd8(0xC705) == 1 and vm:rd8(0xC6F3) == 1 and vm:rd8(0xC936) == 0xE3 end

do
  local vm = VM.new(rom, {})
  vm:start(0x12, 0x4000)
  ok(vm.parkSpin == VM.PARK_GUARD and logged(vm, "park $42 in the startup loop"), "$42 in startup: spins to the guard, outlier logged")
  ok(ended(vm), "$42 in startup: guard ends startup as wScriptDone")
end

do
  local vm = VM.new(rom, {})
  vm:start(0x12, 0x4010)
  ok(ended(vm) and not logged(vm, "startup loop"), "$94 in startup: wScriptDone ends it, no outlier")
  ok(vm.parkSpin == nil, "$42 after $94: a field park, no spin")
end

do
  local vm = VM.new(rom, {})
  vm:start(0x12, 0x4020)
  ok(vm.parkSpin == VM.PARK_GUARD and logged(vm, "park $A2 in the startup loop") and ended(vm), "$A2 LCD-off park in startup: spin, guard, end")
  ok(vm:rd8(0xFFA4) == 0x02 and vm:rd8(0xFFA5) == 0x14 and vm:rd8(0xC6F4) == 1, "$A2 park: InstallParkedScript planted")
end

do
  local vm = VM.new(rom, {})
  vm:start(0x12, 0x4030)
  ok(vm.parkSpin == VM.PARK_GUARD and logged(vm, "park $A1 in the startup loop") and ended(vm), "$A1 LCD-off park in startup: spin, guard, end")
  ok(vm:rd8(0xD101) == 0x06, "$A1 park: clear byte stored")
end

do -- a thread parking while startup is pending leaves wScriptDone alone
  local vm = VM.new(rom, {})
  vm.startupPending = true; vm:wr8(0xC936, 0); vm:wr8(0xC705, 0)
  vm:spawnThread(1, 0x12, 0x4040)
  vm:tickThreads()
  ok(vm.startupPending and vm:rd8(0xC705) == 0 and vm.parkSpin == nil, "thread park: startup still pending")
end

print(("mn_startup_park: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
