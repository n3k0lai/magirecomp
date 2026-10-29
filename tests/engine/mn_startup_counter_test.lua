-- hMainLoopCounter ($FFA8) during FinishStartup's RunScriptLoop: MainLoop ($02E6) is its
-- only writer and does not run until the loop ends (finish_startup.asm), so Grass.frame
-- holds it while the VM is in startup. $41 (bank1_nibble_phase_countdown.asm) in that
-- loop sees the frozen phase: phase 3 dispatches after cnt + 1 back-to-back passes, no
-- frame. Synthetic bytes only (bank 1 is zeros, so the table count is 0).
--   luajit tests/engine/mn_startup_counter_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Grass = require("mn.Grass")

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
  [0x4000] = { 0x93, 0x41, 0x00, 0x50, 0x56, 0x09, 0x42 }, -- $93, $41 table 01:5000, C6F8 = 09, park
  [0x4020] = { 0x41, 0x00, 0x50, 0x56, 0x09, 0x42 },       -- $41 with the LCD on
})

do -- the counter ticks once per field pass, and holds in the startup loop
  local vm = VM.new(rom, {})
  local ow = { vm = vm }
  Grass.frame(ow)
  ok(vm:rd8(0xFFA8) == 1, "field pass: hMainLoopCounter + 1")
  vm.startupPending = true
  Grass.frame(ow); Grass.frame(ow)
  ok(vm:rd8(0xFFA8) == 1, "startup loop: hMainLoopCounter holds")
  vm.startupPending = nil
  Grass.frame(ow)
  ok(vm:rd8(0xFFA8) == 2, "after startup: ticks again")
end

do -- $41 in the startup loop, frozen phase 3: same pass, no frame
  local vm
  vm = VM.new(rom, { frame = function() return vm:rd8(0xFFA8) end })
  vm:wr8(0xFFA8, 0x43)
  local live = vm:start(0x12, 0x4000)
  ok(not live and vm:rd8(0xC6F8) == 0x09, "$41 startup phase 3, count 0: dispatches in the same pass")
end

do -- $41 in the startup loop off phase 3: the asm spins; the port waits and logs it
  local vm
  vm = VM.new(rom, { frame = function() return vm:rd8(0xFFA8) end })
  vm:wr8(0xFFA8, 0x40)
  local live = vm:start(0x12, 0x4000)
  local logged = false
  for _, l in ipairs(vm.log) do if l:find("$41 in the startup loop", 1, true) then logged = true end end
  ok(live and vm:rd8(0xC6F8) ~= 0x09 and logged, "$41 startup off phase: outlier logged, record waits")
end

do -- $41 with the LCD on still waits for the phase: (3 - f) % 4 + 4 * cnt frames
  local vm
  vm = VM.new(rom, { frame = function() return vm:rd8(0xFFA8) end })
  vm:wr8(0xFFA8, 0x40)
  local live = vm:start(0x12, 0x4020)
  ok(live and vm.wait == 3 and vm:rd8(0xC6F8) ~= 0x09, "$41 field, phase 0, count 0: three frames")
end

print(("mn_startup_counter: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
