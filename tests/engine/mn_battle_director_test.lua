-- Director duels (opcode_25.asm starts the battle at once; opcode_2b.asm lets the
-- script step only while the engine holds $D3C2 raised). Synthetic bytes, fake host,
-- no ROM needed.
--   luajit tests/engine/mn_battle_director_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- fake battle host: records the hook calls
local function host()
  local f = { setup = nil, injected = {}, runs = 0, directs = 0, active = false, raised = false }
  f.h = {
    battleBegin = function(a) f.setup = { args = a, ops = {} } end,
    battleOp = function(op, args)
      if f.setup then table.insert(f.setup.ops, { op = op, args = args })
      elseif f.active then table.insert(f.injected, { op = op, args = args }) end
    end,
    battleRun = function() f.runs = f.runs + 1; f.active = true; f.ran = f.setup; f.setup = nil end,
    battleDirect = function() f.directs = f.directs + 1 end,
    battleActive = function() return f.active end,
    battleRaised = function() return f.raised end,
    battleClear = function() f.raised = false end,
    battleResult = function() return f.result end,
  }
  return f
end

-- a director duel: $31 tail (win -> 12:4030), $25, a summon, $2B, then a loop
-- that summons and waits on the same $2B (the shape of 1A:5F88 -> 1A:603B)
do
  local b = {
    0x31, 0x12, 0x30, 0x40, 0x12, 0x30, 0x40, -- 4000 SetTailScripts
    0x25, 0x07, 0x59, 0x0C, 0x4C, 0x23, 0x40, -- 4007 battle setup
    0x2E, 0x09, 0x42, 0x0B, 0x19, 0x00,       -- 400E summon
    0x2B,                                     -- 4014 loop: wait for $D3C2
    0x2E, 0x09, 0x28, 0x0D, 0x1E, 0x00,       -- 4015 summon each pass
    0x45, 0x12, 0x14, 0x40,                   -- 401B back to 4014
  }
  while #b < 0x30 do b[#b + 1] = 0 end
  b[#b + 1] = 0xA9; b[#b + 1] = 0x42; b[#b + 1] = 0x00; b[#b + 1] = 0x97 -- 4030 win tail
  local f = host()
  local vm = VM.new(image(b), f.h)
  vm:start(0x12, 0x4000)
  ok(f.runs == 0 and f.setup and #f.setup.ops == 1, "first $2E ends the pass: setup collected, no battle yet")
  vm:resume() -- $2B (first visit)
  vm:resume() -- the loop's $2E
  ok(f.runs == 0 and #f.setup.ops == 2, "each record op is its own pass")
  vm:resume() -- $45 back to the passed $2B
  ok(f.runs == 1 and f.directs == 1, "the loop back to a passed $2B starts the battle as a director duel")
  ok(f.ran and #f.ran.ops == 2, "the battle starts with both summons")
  vm:resume(); vm:resume()
  ok(#f.injected == 0, "the stream waits while $D3C2 is clear")
  f.raised = true
  vm:resume()
  ok(#f.injected == 1 and f.raised, "a raised $D3C2 runs the $2E pass")
  vm:resume()
  ok(#f.injected == 1 and not f.raised, "the next pass reaches $2B, which clears it")
  vm:resume()
  ok(#f.injected == 1, "one pass per raise")
  f.raised = true; vm:resume()
  ok(#f.injected == 2, "the next raise runs the next pass")
  f.active, f.result = false, "win"
  vm:resume()
  ok(vm:rd8(0xA123) == 0x42, "after the duel the stream follows the $31 win script")
  ok(vm.dir == nil, "director state cleared")
end

-- a director running in a slot's thread hands its tail to the main stream
do
  local b = {
    0x31, 0x12, 0x30, 0x40, 0x12, 0x30, 0x40,
    0x25, 0x07, 0x59, 0x0C, 0x4C, 0x23, 0x40,
    0x2B,
    0x45, 0x12, 0x0E, 0x40,
  }
  while #b < 0x30 do b[#b + 1] = 0 end
  b[#b + 1] = 0xA9; b[#b + 1] = 0x44; b[#b + 1] = 0x00; b[#b + 1] = 0x97
  local f = host()
  local main
  f.h.mainScript = function(bank, ptr) main = { bank, ptr } end
  local vm = VM.new(image(b), f.h)
  vm:spawnThread(0, 0x12, 0x4000)
  for _ = 1, 3 do vm:tickThreads(false) end
  ok(f.runs == 1 and f.directs == 1, "slot director starts the battle")
  f.active, f.result = false, "win"
  vm:tickThreads(false)
  ok(main and main[1] == 0x12 and main[2] == 0x4030, "the win tail goes to the main stream")
  ok(vm:rd8(0xA123) == 0 and vm.threads[0] == nil, "the slot thread ends without running the tail")
end

-- a $27 duel (Korg 14:4174 shape): two different $2B stops then $27; unchanged
do
  local b = {
    0x31, 0x12, 0x30, 0x40, 0x12, 0x30, 0x40,
    0x25, 0x06, 0x5D, 0x05, 0x4C, 0x23, 0x40,
    0x2B,
    0x2E, 0x09, 0x08, 0x05, 0x14, 0x02,
    0x2B,
    0x27,
  }
  while #b < 0x30 do b[#b + 1] = 0 end
  b[#b + 1] = 0xA9; b[#b + 1] = 0x43; b[#b + 1] = 0x00; b[#b + 1] = 0x97
  local f = host()
  local vm = VM.new(image(b), f.h)
  vm:start(0x12, 0x4000)
  for _ = 1, 4 do vm:resume() end
  ok(f.runs == 1 and f.directs == 0, "$27 runs the battle once, no director")
  ok(f.ran and #f.ran.ops == 1, "$27 battle gets the collected summon")
  ok(vm:rd8(0xD392) == 0x09 and vm:rd8(0xD396) == 0x02 and vm:rd8(0xC937) == 7,
    "CopyScriptToD392: $2E operands at $D392, WRAM bank 7")
  f.active, f.result = false, "win"
  vm:resume()
  ok(vm:rd8(0xA123) == 0x43, "$27 duel follows the win script")
end

-- a wild encounter (13:5F7C shape: $30, $25, $2E, $27, no $31) returns through the
-- last $31 that ran, every time (dispatch_nonzero_d016.asm -> ContinueStartup)
do
  local b = {
    0x30, 0x00, 0x00, 0x27,                   -- 4000 $C840 0000 (no wipe), battle music $27
    0x25, 0x07, 0x6C, 0x12, 0x4C, 0x23, 0x40, -- 4004 battle setup
    0x2E, 0x09, 0x08, 0x10, 0x21, 0x01,       -- 400B summon
    0x27,                                     -- 4011 run the battle
  }
  while #b < 0x30 do b[#b + 1] = 0 end
  b[#b + 1] = 0xA9; b[#b + 1] = 0x45; b[#b + 1] = 0x00; b[#b + 1] = 0x97 -- 4030 map entry tail
  while #b < 0x40 do b[#b + 1] = 0 end
  b[#b + 1] = 0xA9; b[#b + 1] = 0x46; b[#b + 1] = 0x00; b[#b + 1] = 0x97 -- 4040 loss tail
  local f = host()
  local music = {}
  f.h.music = function(v) music[#music + 1] = v end
  local vm = VM.new(image(b), f.h)
  for k, v in ipairs({ 0x12, 0x30, 0x40, 0x12, 0x40, 0x40 }) do vm:wr8(0x7D3CD + k - 1, v) end
  vm:wr8(0xC920, 0x26)
  for round = 1, 2 do
    vm:wr8(0xA123, 0)
    vm:start(0x12, 0x4000)
    ok(f.runs == round - 1, "wild battle " .. round .. ": the $2E pass ends before $27")
    vm:resume()
    ok(f.runs == round, "wild battle " .. round .. " runs")
    ok(vm:rd8(0xC923) == 0x26 and vm:rd8(0xC920) == 0x27, "$30 saves the field music at $C923")
    f.active, f.result = false, "win"
    vm:resume()
    ok(vm:rd8(0xA123) == 0x45, "wild battle " .. round .. " continues at the $D3CD script")
    ok(vm:rd8(0xC920) == 0x26 and music[#music] == 0x26, "the battle's end restores [$C923]")
  end
  vm:wr8(0xA123, 0)
  vm:start(0x12, 0x4000)
  vm:resume()
  f.active, f.result = false, "loss"
  vm:resume()
  ok(vm:rd8(0xA123) == 0x46, "a lost wild battle continues at the $D3D0 script")
end

-- after FinishStartup (LCD off) RunScriptRecord runs pass after pass in one frame:
-- the record ops end their passes without a frame between them
do
  local b = {
    0x25, 0x07, 0x6C, 0x12, 0x4C, 0x23, 0x40, -- 4000 battle setup
    0x2E, 0x09, 0x08, 0x10, 0x21, 0x01,       -- 4007 summon
    0x2E, 0x0A, 0x08, 0x10, 0x21, 0x01,       -- 400D summon
    0x27,                                     -- 4013 run the battle
  }
  while #b < 0x30 do b[#b + 1] = 0 end
  local f = host()
  local vm = VM.new(image(b), f.h)
  vm.startupPending = true
  vm:start(0x12, 0x4000)
  ok(f.runs == 1 and f.ran and #f.ran.ops == 2, "LCD off: $25, both $2E and $27 in one frame")
end

-- Battle side: engine ops and the per-round pass, without love graphics
do
  local okB, Battle = pcall(require, "mn.Battle")
  if okB then
    local e = Battle.engineOp(0x2E, { 9, 0x42, 0x0B, 0x19, 0 })
    ok(e and e.op == 0x2E and e.slot == 9 and e.species == 0x42 and e.energy == 0x19, "$2E -> engine summon")
    ok(Battle.engineOp(0x28, { 9, 0xC1, 0x70, 0x10 }) == nil, "$28 is not an engine op yet")
    local applied = {}
    package.loaded["mn.battle.Engine"].scriptOp = function(_, o) applied[#applied + 1] = o end
    local b = setmetatable({ state = {}, log = {}, t = 0, vis = {} }, Battle)
    b.refreshVis = function() end
    b:startDirector()
    b:inject(0x2E, { 9, 0x28, 0x0D, 0x1E, 0 })
    local co = coroutine.create(function() b.state.scriptPass(b.state) end)
    coroutine.resume(co)
    ok(b.d3c2 == 1 and #applied == 0, "a round raises $D3C2 and waits")
    b.d3c2 = 0
    coroutine.resume(co); coroutine.resume(co)
    ok(coroutine.status(co) == "dead" and #applied == 1, "cleared $D3C2 ends the pass and applies the ops")
  else
    print("skip Battle part: " .. tostring(Battle):sub(1, 80))
  end
end

print(("mn_battle_director: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
