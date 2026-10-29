-- Script sound ops $24 (opcode_20.asm, labelled Opcode20) and $20
-- (opcode_20_arm_countdown.asm) end in jp DispatchScriptOpcode: the next op runs in the
-- same pass, with no frame wait, LCD on or off. Their effect is on the sound selector:
-- $24 arms SoundSelectBit0 (music fade-out, $C92C stepped down every $C929 selector
-- calls, then wSoundIndex $FF and the music gate dropped); $20 arms SoundCountdown (save
-- driver state, install sound index $C925) or, with $C924 already set, falls into
-- Opcode21 (wSoundRequest = 1). Synthetic bytes only; the driver never plays audio.
--   luajit tests/engine/mn_sound_ops_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Sfx = require("mn.Sfx")
local Overworld = require("mn.Overworld")

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

-- each: op, post C6F8 $09, park
local rom = image({
  [0x4000] = { 0x24, 0x25, 0x56, 0x09, 0x42 },             -- $24: fade step every 3
  [0x4040] = { 0x20, 0x07, 0x56, 0x09, 0x42 },             -- $20: sound index 7
  [0x4080] = { 0x20, 0x07, 0x20, 0x08, 0x56, 0x09, 0x42 }, -- $20 twice in one pass
  [0x40C0] = { 0x40, 0x05, 0x56, 0x09, 0x42 },             -- $40 still waits
  [0x4100] = { 0x1F, 0x05, 0x24, 0x25, 0x56, 0x09, 0x42 }, -- $1F then $24
  [0x4140] = { 0x1F, 0x06, 0x56, 0x09, 0x42 },             -- $1F (cancels a fade)
})

-- a field host with the real Sfx hooks (driver WRAM, no audio source)
local function field()
  local ow = { rom = rom, log = {} }
  local h = { music = function(v) ow.log[#ow.log + 1] = ("music %02X"):format(v) end }
  local sfx = Sfx.host(ow, h)
  local vm = VM.new(rom, h)
  ow.vm = vm
  local function frame() sfx:select(); sfx:step(); vm:tickThreads(false); Overworld.musicFadeFrame(ow) end
  return ow, h, sfx, vm, frame
end

-- $24 with the LCD on and in the startup loop: same pass
for _, startup in ipairs({ false, true }) do
  local tag = startup and " (startup)" or ""
  local calls = {}
  local vm = VM.new(rom, { sfxSelect = function(...) calls[#calls + 1] = { ... } end })
  vm.startupPending = startup
  local live = vm:start(0x12, 0x4000)
  ok(not live and vm:rd8(0xC6F8) == 0x09, "$24: next op in the same pass" .. tag)
  ok(vm:rd8(0xC929) == 3 and vm:rd8(0xC928) == 0 and vm:rd8(0xC92A) == 1, "$24: C929 = hi+1, C928 = 0, C92A = 1" .. tag)
  ok(#calls == 1 and calls[1][1] == 1 and calls[1][2] == 0 and calls[1][3] == 3 and calls[1][4] == nil,
    "$24: select 1, C928 0, C929 3, driver C92C kept" .. tag)
end

-- $20 with the driver's C924 clear: arm the countdown, same pass
do
  local cd = {}
  local vm = VM.new(rom, { sfxByte = function() return 0 end, sfxCountdown = function(id) cd[#cd + 1] = id end,
    sfx = function() cd[#cd + 1] = "req" end })
  local live = vm:start(0x12, 0x4040)
  ok(not live and vm:rd8(0xC6F8) == 0x09, "$20: next op in the same pass")
  ok(vm:rd8(0xC924) == 2 and vm:rd8(0xC925) == 7, "$20: C924 = 2, C925 = operand")
  ok(#cd == 1 and cd[1] == 7, "$20: driver countdown armed for index 7")
end
-- $20 with C924 set: Opcode21 (wSoundRequest = 1), operand still consumed
do
  local cd = {}
  local vm = VM.new(rom, { sfxByte = function() return 1 end, sfxCountdown = function(id) cd[#cd + 1] = id end,
    sfx = function(k) cd[#cd + 1] = "req" .. k end })
  local live = vm:start(0x12, 0x4040)
  ok(not live and vm:rd8(0xC6F8) == 0x09, "$20 busy: next op in the same pass")
  ok(vm:rd8(0xC91F) == 1 and vm:rd8(0xC924) == 0 and vm:rd8(0xC925) == 0, "$20 busy: C91F = 1, countdown untouched")
  ok(#cd == 1 and cd[1] == "req1", "$20 busy: request 1, no countdown")
end
-- no host: the VM's own C924 decides (second $20 in the pass takes the Opcode21 path)
do
  local vm = VM.new(rom, {})
  ok(not vm:start(0x12, 0x4080) and vm:rd8(0xC6F8) == 0x09, "$20 x2: one pass")
  ok(vm:rd8(0xC925) == 7 and vm:rd8(0xC91F) == 1, "$20 x2: first arms index 7, second requests")
end
-- $40 keeps its frame wait
do
  local vm = VM.new(rom, {})
  ok(vm:start(0x12, 0x40C0) and vm:rd8(0xC6F8) == 0, "$40: still waits with the LCD on")
end

-- Driver timing: $1F (C92C = $0F) then $24 with C929 = 3. SoundSelectBit0 counts C928 to
-- 3 per step: 14 steps $0F -> $01, then one more count ends it: 45 selector frames.
do
  local ow, _, sfx, vm, frame = field()
  ow.music = { stop = function() ow.stopped = true end }
  ok(not vm:start(0x12, 0x4100), "$1F+$24: one pass")
  ok(sfx:rd(0xC92C) == 0x0F and sfx:rd(0xC92A) == 1 and sfx:rd(0xC929) == 3, "$1F+$24: driver C92C $0F, select 1, C929 3")
  ok(vm:rd8(0xC920) == 0x05, "$1F+$24: wSoundIndex unchanged in the pass")
  frame()
  ok(vm:rd8(0xC920) == 0xFF and sfx:rd(0xC920) == 0xFF, "$24: the selector frame writes wSoundIndex $FF")
  local done
  for i = 2, 100 do
    frame()
    if sfx:rd(0xC92A) == 0 then done = i; break end
  end
  ok(done == 45, "$24: fade ends after 45 selector frames (" .. tostring(done) .. ")")
  ok(sfx:rd(0xC92C) == 0 and sfx:rd(0xC929) == 1, "$24: end leaves C92C 0, C929 1")
  ok(vm:rd8(0xC92A) == 0 and vm:rd8(0xC920) == 0xFF, "$24: VM mirrors the select clear, index stays $FF")
  ok(ow.stopped and ow.music == nil, "$24: field music stops at the fade end")
  -- the same index now restarts
  local n = #ow.log
  vm:start(0x12, 0x4100)
  ok(ow.log[n + 1] == "music 05", "after the fade, $1F of the same index restarts it")
end
-- a $1F during the fade cancels it: no stop
do
  local ow, _, sfx, vm, frame = field()
  ow.music = { stop = function() ow.stopped = true end }
  vm:start(0x12, 0x4100)
  for _ = 1, 10 do frame() end
  vm:start(0x12, 0x4140)
  for _ = 1, 60 do frame() end
  ok(sfx:rd(0xC92A) == 0 and sfx:rd(0xC92C) == 0x0F, "$1F cancels the fade in the driver")
  ok(not ow.stopped and ow.music ~= nil, "$1F cancel: the field music keeps playing")
end

-- Driver countdown: SoundCountdown on the first selector frame (C924 2 -> 1, state saved
-- to $C8C9, index $C925 installed), then SoundCountdownIdle clears C924 once idle.
do
  local _, _, sfx, vm, frame = field()
  sfx:wr(0xDFA6 + 3, 0x5A)
  ok(not vm:start(0x12, 0x4040), "$20: one pass with the field host")
  ok(sfx:rd(0xC924) == 2 and sfx:rd(0xC925) == 7, "$20: driver C924 2, C925 7")
  frame()
  ok(sfx:rd(0xC924) == 1 and sfx:rd(0xC8C9 + 3) == 0x5A, "$20: SoundCountdown saved driver state")
  -- while C924 is set a second $20 is Opcode21
  vm:start(0x12, 0x4040)
  ok(sfx:rd(0xC91F) == 1 and vm:rd8(0xC91F) == 1 and sfx:rd(0xC925) == 7, "$20 while counting: Opcode21 request, C925 kept")
  for _ = 1, 4 do frame() end
  ok(sfx:rd(0xC924) == 0, "$20: SoundCountdownIdle clears C924 once the sound is idle")
end

print(("mn_sound_ops_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
