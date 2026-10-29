-- A $15 schedule replaced by a single anim ($4C-$4F animAt, a ride head) sets
-- sched = nil; the per-record lists (seqs) must go with it, or Sprites.tick
-- steps a schedule that no longer exists (crash on #o.sched, 181 ferry leg r4).
-- Synthetic objects only, no ROM.
--   luajit tests/engine/mn_sched_clear_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Sprites = require("mn.Sprites")

-- build with no schedule clears stale per-record lists (anim nil: no ROM read)
local o = { seqs = { { { n = 1 } }, { { n = 1 } } }, si = 2, st = 5, sched = nil, anim = nil }
Sprites.build({}, o)
ok(o.seqs == nil and o.si == nil and o.st == nil, "build without sched drops seqs/si/st")

-- tick on a stale object (seqs left, sched gone) does not touch the schedule
local f = { n = 2, dx = 0, dy = 0 }
local t = { x = 3, y = 4, ox = 0, oy = 0, fi = 1, ft = 0, seq = { f },
  seqs = { { f }, { f } }, si = 1, st = 0, sched = nil, driven = true }
local good = pcall(Sprites.tick, t)
ok(good, "tick with seqs but no sched does not error")
ok(t.si == 1 and t.st == 0, "stale schedule is not stepped")

-- a live schedule still steps: two records of 1 frame each
local s1, s2 = { { n = 1, dx = 0, dy = 0 } }, { { n = 1, dx = 0, dy = 0 } }
local u = { x = 0, y = 0, ox = 0, oy = 0, fi = 1, ft = 0, seq = s1, seqs = { s1, s2 }, si = 1, st = 0,
  sched = { { 0x20, 0x4000, 1 }, { 0x20, 0x4010, 1 } } }
Sprites.tick(u)
ok(u.si == 2 and u.seq == s2, "live schedule moves to record 2 after its frame count")

if failures == 0 then print(("ok %d checks"):format(checks))
else print(("%d FAILED / %d"):format(failures, checks)); os.exit(1) end
