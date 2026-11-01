-- AddAndShiftUnknown ($28E5) copies C6F8->C6F9, C6FA->C6FB, C6FC->C6FD and
-- clears the source, zeros included, once per FinishFrame before the records.
-- A post written on frame N is readable on frame N+1 only.
-- 1F:5982 arms C6F8, counts down, then $5D: the expired post must not satisfy it.
-- 2A:42A4's $60 $2A is the other shape: the waiter is already polling when
-- 2A:4C5A posts, so that one frame is seen and the next frame is 0.
-- Synthetic bytes only.
--   luajit tests/engine/mn_mailbox_frame_test.lua
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

local function alive(vm, key)
  local t = vm.threads and vm.threads[key]
  return t and coroutine.status(t.co) ~= "dead"
end

-- Overworld:update resumes a main-script frame wait after tickThreads.
local function field(vm)
  vm:tickThreads(false)
  if vm.wait then
    vm.wait = vm.wait - 1
    if vm.wait <= 0 then vm.wait = nil; vm:resume() end
  end
end

-- zeros copy: a stale shadow is cleared when the source is 0
local vm = VM.new(image({}), {})
vm.mem[0xC6F9], vm.mem[0xC6FB], vm.mem[0xC6FD] = 0x55, 0x66, 0x77
vm:tickThreads(false)
ok(vm:rd8(0xC6F9) == 0 and vm:rd8(0xC6FB) == 0 and vm:rd8(0xC6FD) == 0, "a 0 source clears the shadow")
ok(vm:rd8(0xC6F8) == 0 and vm:rd8(0xC6FA) == 0 and vm:rd8(0xC6FC) == 0, "the source stays 0")

-- 1F:5982 shape: $53, countdown, $5D, then a marker post that must not run
local rom = image({
  [0x4000] = { 0x53, 0x40, 0x02, 0x5D, 0x56, 0x3C, 0x42 },
  -- one store per frame: a full box returns without dispatch
  [0x4100] = { 0x58, 0x06, 0x58, 0x3E, 0x58, 0x3F, 0x42 },
  -- waiter already polling; partner posts on the next frame
  [0x4200] = { 0x60, 0x2A, 0xAC, 0x00, 0xA1, 0x22, 0x42 },
  [0x4300] = { 0x40, 0x01, 0x56, 0x2A, 0x42 },
  -- same value again after a gap, no second post
  [0x4400] = { 0x60, 0x01, 0x40, 0x02, 0x60, 0x01, 0xAC, 0x00, 0xA1, 0x33, 0x42 },
  [0x4500] = { 0x56, 0x01, 0x42 },
  -- same value again, partner posts a second time
  [0x4600] = { 0x60, 0x01, 0x40, 0x02, 0x60, 0x01, 0xAC, 0x00, 0xA1, 0x44, 0x42 },
  [0x4700] = { 0x56, 0x01, 0x40, 0x04, 0x56, 0x01, 0x42 },
  -- post, then install the waiter after the visible frame
  [0x4800] = { 0x56, 0x07, 0x42 },
  [0x4900] = { 0x5D, 0xAC, 0x00, 0xA1, 0x55, 0x42 },
  -- main script polls; partner is a record thread
  [0x4A00] = { 0x60, 0x2A, 0xAC, 0x00, 0xA1, 0x66, 0x42 },
})

local gap = VM.new(rom, {})
gap:spawnThread(1, 0x12, 0x4000)
gap:tickThreads(false)
ok(gap:rd8(0xC6F8) == 0xFF and gap:rd8(0xC6F9) == 0, "$53 fills the source; the shadow is still the old one")
gap:tickThreads(false)
ok(gap:rd8(0xC6F9) == 0xFF and gap:rd8(0xC6F8) == 0, "the armed $FF is visible on the next frame")
gap:tickThreads(false)
ok(gap:rd8(0xC6F9) == 0 and gap:rd8(0xC6F8) ~= 0x3C, "the countdown's next frame has cleared it, so $5D does not pass")
for _ = 1, 4 do gap:tickThreads(false) end
ok(gap:rd8(0xC6F8) ~= 0x3C and alive(gap, 1), "a post, a gap, then $5D keeps waiting")

local stream = VM.new(rom, {})
stream:spawnThread(1, 0x12, 0x4100)
stream:tickThreads(false)
ok(stream:rd8(0xC6FC) == 0x06 and stream:rd8(0xC6FD) == 0, "the first $58 lands; the next stalls on a full box")
stream:tickThreads(false)
ok(stream:rd8(0xC6FD) == 0x06 and stream:rd8(0xC6FC) == 0x3E, "frame 2 shows $06 and stores $3E")
stream:tickThreads(false)
ok(stream:rd8(0xC6FD) == 0x3E and stream:rd8(0xC6FC) == 0x3F, "frame 3 shows $3E and stores $3F")
stream:tickThreads(false)
ok(stream:rd8(0xC6FD) == 0x3F and stream:rd8(0xC6FC) == 0, "frame 4 shows $3F and the source is clear")

local poll = VM.new(rom, {})
poll:spawnThread(1, 0x12, 0x4200)
poll:spawnThread(2, 0x12, 0x4300)
poll:tickThreads(false)
poll:tickThreads(false)
ok(poll:rd8(0xC6F8) == 0x2A and poll:rd8(0xA100) == 0, "the partner posts while the waiter is polling")
poll:tickThreads(false)
ok(poll:rd8(0xC6F9) == 0x2A and poll:rd8(0xA100) == 0, "the waiter sees $2A on its one frame and does not continue yet")
poll:tickThreads(false)
ok(poll:rd8(0xC6F9) == 0 and poll:rd8(0xA100) == 0x22, "the next opcode runs on the following frame, and the shadow is 0")

local rewait = VM.new(rom, {})
rewait:spawnThread(1, 0x12, 0x4400)
rewait:spawnThread(2, 0x12, 0x4500)
for _ = 1, 8 do rewait:tickThreads(false) end
ok(rewait:rd8(0xA100) == 0 and alive(rewait, 1), "a second $60 of the same value waits for a new post")

local refresh = VM.new(rom, {})
refresh:spawnThread(1, 0x12, 0x4600)
refresh:spawnThread(2, 0x12, 0x4700)
for _ = 1, 10 do refresh:tickThreads(false) end
ok(refresh:rd8(0xA100) == 0x44, "a second post of the same value releases the re-wait")

local early = VM.new(rom, {})
early:spawnThread(1, 0x12, 0x4800)
for _ = 1, 4 do early:tickThreads(false) end
ok(early:rd8(0xC6F9) == 0 and early:rd8(0xC6F8) == 0, "the post has expired before the waiter exists")
early:spawnThread(2, 0x12, 0x4900)
for _ = 1, 4 do early:tickThreads(false) end
ok(early:rd8(0xA100) == 0 and alive(early, 2), "a waiter installed after the visible frame does not see the post")

local main = VM.new(rom, {})
main:spawnThread(2, 0x12, 0x4300)
ok(main:start(0x12, 0x4A00) and main.wait == 1, "the main waiter parks on $60 before the first shift")
field(main)
field(main)
field(main)
ok(main:rd8(0xC6F9) == 0x2A and main:rd8(0xA100) == 0, "the main script, resumed after the shift, sees the one frame")
field(main)
ok(main:rd8(0xC6F9) == 0 and main:rd8(0xA100) == 0x66, "and the shadow is 0 when its next opcode runs")

print(("mn_mailbox_frame_test: %d/%d ok"):format(checks - failures, checks))
os.exit(failures == 0 and 0 or 1)
