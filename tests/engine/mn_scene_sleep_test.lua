-- $93 (InitPointerList, 01:40D3): every record gets bit 7 set and bit 6 cleared and
-- the sixteen pointer slots are emptied. Nothing else is touched, so a record's
-- script position survives and $0B (clear bit 7, TakePointerSlot) resumes it where
-- it stopped (map 40 river scene: 2A:4975's $93 sleeps records 3 and 5, its later
-- $0B 03 / $0B 05 wake them and record 5 hands Tony the pad). The record whose own
-- pass ran the $93 finishes that pass (map 219 2A:4769: $93, then the map-40 load).
-- Talk and stand-in threads start over. Made-up records and threads, no ROM bytes.
--   luajit tests/engine/mn_scene_sleep_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end }, graphics = {} } -- luacheck: ignore 111
local failures, checks = 0, 0
local function ok(c, w) checks = checks + 1; if not c then failures = failures + 1; print("FAIL " .. w) end end

local Overworld = require("mn.Overworld")

local function vmStub()
  local v = { mem = {}, threads = {}, spawned = {} }
  function v:rd8(a) return self.mem[a] or 0 end
  function v:wr8(a, b) self.mem[a] = b end
  function v:spawnThread(slot, b, ptr) self.spawned[#self.spawned + 1] = { slot, b, ptr } end
  return v
end

local function scene()
  local ob3, ob5, ob7 = { x = 9, y = 10 }, { x = 6, y = 24 }, { x = 8, y = 35 }
  local s = setmetatable({ x = 9, y = 28, log = {}, vm = vmStub(),
    objects = { [0] = { x = 9, y = 28 }, [3] = ob3, [5] = ob5, [7] = ob7 } }, { __index = Overworld })
  local h = s:host()
  local idle = function() while true do coroutine.yield() end end
  for _, k in ipairs({ 0, 3, 5 }) do s.vm.threads[k] = { co = coroutine.create(idle), slot = k, wait = 0 } end
  s.vm.threads.talk = { co = coroutine.create(idle), wait = 0 }
  -- record 7's own pass runs the $93
  s.vm.threads[7] = { co = coroutine.create(function() h.freshScene(); coroutine.yield() end), slot = 7, wait = 0 }
  local okr, err = coroutine.resume(s.vm.threads[7].co)
  ok(okr, "freshScene from a record pass: " .. tostring(err))
  return s, h, ob3, ob5
end

local s, h, ob3 = scene()
ok(next(s.objects) == nil, "no record is linked after $93")
ok(s.vm.threads[3] and s.vm.threads[5], "slept records keep their script threads")
ok(s.vm.threads.talk == nil, "the talk thread starts over")
ok(s.vm.threads[0] == nil, "the stand-in's thread starts over")
ok(s.vm.threads[7] ~= nil, "the record that ran $93 keeps its thread")
ok(not h.slotActive(3) and not h.slotActive(5), "slept records do not run")
ok(h.slotActive(7), "the running record finishes its pass")
local pc = s.vm.threads[3].co
pcall(h.slotFlag, 3)
ok(s.objects[3] == ob3 and not ob3.dormant, "$0B 03 relinks the same record")
ok(h.slotActive(3) and s.vm.threads[3].co == pc, "and its script resumes where it stopped")
ok(not h.slotActive(5), "records not woken stay asleep")

print(("mn_scene_sleep: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
