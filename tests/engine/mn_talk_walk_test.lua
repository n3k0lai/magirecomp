-- WalkPointerSlots (01:407D), the talk heads $63ED / $6405 / $64D1, GateCellNearFirstRecord
-- (01:641D), CopyRecordToScratch / RestoreScratchRecord through Opcode12, and the $07 / $12
-- writes of Tony's head (mn.Walk). Made-up records and cells only, no ROM bytes.
--   luajit tests/engine/mn_talk_walk_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end }, graphics = {} } -- luacheck: ignore 111
local failures, checks = 0, 0
local function ok(c, w) checks = checks + 1; if not c then failures = failures + 1; print("FAIL " .. w) end end

local Overworld = require("mn.Overworld")
local Walk = require("mn.Walk")
local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local ROM = MnRom.new(string.rep("\0", 0x200000))

local function field()
  local block = {}
  for i = 1, 100 do block[i] = 0 end
  local s = setmetatable({ def = { w = 10, h = 10, block = block, triggers = {} }, x = 5, y = 5, px = 80, py = 80,
    facing = "up", objects = {}, log = {}, map = 1, talks = {}, sfxOut = { update = function() end } },
    { __index = Overworld })
  s.vm = VM.new(ROM, s:host())
  s.runScript = function(self, b, p, why) self.talks[#self.talks + 1] = why end
  s.cameraXY = function() return 0, 0 end
  return s
end
local function talker(s, slot, x, y, h)
  s.objects[slot] = { x = x, y = y, oy = 0, talk = { 0x12, 0x4000 + slot }, handler = h or Walk.TALK, anim = { 0x11, 0x7000 } }
  Walk.take(s, slot)
  return s.objects[slot]
end

-- 641D window by facing, the record at 10,10
local N = Walk.near
ok(N(0, 10, 10, 10, 11) and N(0, 10, 10, 10, 10) and not N(0, 10, 10, 10, 9) and not N(0, 10, 10, 10, 12), "up: rows c..c+1")
ok(N(3, 10, 10, 10, 9) and not N(3, 10, 10, 10, 8) and not N(3, 10, 10, 10, 11), "down: rows c-1..c")
ok(N(1, 10, 10, 11, 9) and N(1, 10, 10, 11, 11) and not N(1, 10, 10, 9, 10) and not N(1, 10, 10, 12, 10), "left: columns b..b+1")
ok(N(2, 10, 10, 9, 9) and not N(2, 10, 10, 11, 10) and not N(2, 10, 10, 8, 10), "right: columns b-1..b")
ok(not N(0, 10, 0, 10, 1) and N(0, 10, 0, 10, 0), "up at row 0: (0 - 1) & $FF < e never holds, only the exact cell")

-- walk order decides: the first linked record in the window answers, wRecordState blocks the rest
do
  local s = field()
  talker(s, 6, 5, 4); talker(s, 3, 5, 5) -- linked 6 then 3; both in the up window
  ok(table.concat(Walk.order(s), ",") == "6,3", "positions taken in $0B order")
  s.aPress = true
  s.vm:resume() -- nothing
  local l = s.aPress; s.aPress = nil; Walk.pass(s, l)
  ok(s.objects[6].handler == Walk.TAIL and s.objects[3].handler == Walk.TALK, "slot 6 passes 641D first; $C188 = 1 blocks slot 3")
  ok(s.vm:rd8(0xC188) == 1 and s.recScratch and s.recScratch.slot == 6, "CopyRecordToScratch: $C188 = 1, slot 6 saved")
  ok(#s.talks == 0, "the tail does not run in the gate pass")
  Walk.pass(s, nil)
  ok(#s.talks == 1 and s.talks[1] == "talk to slot 6", "$64D1 on the next pass runs slot 6's talk")
  ok(s.objects[6].handler == Walk.FROZEN and s.tonyHead == Walk.FROZEN, "$64D1: record and Tony heads $4A6B")
  -- the talk moves the record; Opcode12 commits, the next walk restores the snapshot
  s.objects[6].x = 8; s.objects[6].anim = { 0x11, 0x7100 }
  s:host().commitRecord()
  ok(s.vm:rd8(0xC188) == 3 and s.vm:rd8(0xC18A) == 0x10 and s.vm:rd8(0xC18B) == 0x5E, "Opcode12: $C188 = 3, Tony head $5E10")
  ok(s.tonyHead == Walk.COMMIT and s.padHead == nil, "Tony back on the normal family")
  Walk.pass(s, nil)
  local o = s.objects[6]
  ok(s.vm:rd8(0xC188) == 0 and o.x == 5 and o.handler == Walk.TALK and o.anim[2] == 0x7000,
    "RestoreScratchRecord: cell, head $63ED and anim back")
  -- the bubble moved slot 3 (lower on screen) ahead of 6: it answers the next A
  ok(Walk.order(s)[1] == 3, "the bubble put slot 3 (row 5) before slot 6 (row 4)")
  Walk.pass(s, true)
  ok(s.objects[3].handler == Walk.TAIL and s.objects[6].handler == Walk.TALK, "the first record in walk order answers")
end

-- a record with head $4A6B never answers; $C716 and $C6EE block the gate
do
  local s = field()
  talker(s, 3, 5, 4, Walk.FROZEN)
  Walk.pass(s, true)
  ok(s.objects[3].handler == Walk.FROZEN and s.vm:rd8(0xC188) == 0, "$4A6B: no gate")
  s.objects[3].handler = Walk.TALK
  s.vm:wr8(0xC716, 1); Walk.pass(s, true)
  ok(s.objects[3].handler == Walk.TALK, "$C716 nonzero blocks")
  s.vm:wr8(0xC716, 0); s.c714Live = true; s.scriptWaiting = true; Walk.pass(s, true)
  ok(s.objects[3].handler == Walk.TALK, "a list script still running ($C714 live) blocks")
  s.scriptWaiting = nil; s.vm:wr8(0xC6EE, 1); Walk.pass(s, true)
  ok(s.objects[3].handler == Walk.TALK, "$C6EE nonzero blocks")
  s.vm:wr8(0xC6EE, 0); Walk.pass(s, nil)
  ok(s.objects[3].handler == Walk.TALK, "no latch, no gate")
  s.facing = "down"; Walk.pass(s, true)
  ok(s.objects[3].handler == Walk.TALK, "facing away (down) from the row above: outside the window")
  s.facing = "up"; Walk.pass(s, true)
  ok(s.objects[3].handler == Walk.TAIL and s.c714Live == nil, "the list script ended: the gate passes")
end

-- the bubble pass: one swap a frame toward descending screen Y; retire on sleep
do
  local s = field()
  talker(s, 2, 1, 1); talker(s, 4, 1, 6); talker(s, 7, 1, 3)
  Walk.pass(s, nil)
  ok(table.concat(Walk.order(s), ",") == "4,2,7", "y 1,6,3: 4 swaps ahead of 2; 7 is compared with 4's Y, no swap")
  Walk.pass(s, nil)
  ok(table.concat(Walk.order(s), ",") == "4,7,2", "next frame 7 passes 2")
  Walk.pass(s, nil)
  ok(table.concat(Walk.order(s), ",") == "4,7,2", "sorted: no swap")
  s.objects[7].dormant = true
  Walk.pass(s, nil)
  ok(table.concat(Walk.order(s), ",") == "4,2" and not s.linked[7] and s.ptrCur == 3, "a sleeping record is retired, its position freed")
  s.objects[7].dormant = nil; s:host().slotFlag(7)
  ok(s.linked[7] and s.recByte0[7] == 0x40, "$0B relinks it: byte 0 = $40")
  s.objects[2].handler = Walk.SCREEN_Y_C8
  Walk.pass(s, nil)
  ok(Walk.order(s)[1] == 4, "$5F04 stores $C8 into $FF97")
end

-- $07 slot 0: $4A6B holds Tony's pad, $5D81 gives it back; A presses latch for next frame
do
  local s = field()
  local keys = {}
  s.input = function(k) local v = keys[k]; keys[k] = nil; return v end
  s:host().slotFields(0, 0x6B, 0x4A)
  ok(s.tonyHead == Walk.FROZEN, "$07 00 6B 4A: Tony's head $4A6B")
  keys.dir = "left"; s:update()
  ok(s.x == 5 and not s.moving, "held: no step")
  s:host().slotFields(0, 0x81, 0x5D)
  ok(s.tonyHead == 0x5D81 and s.padHead == 0x5D81, "$07 00 81 5D: the pad head")
  keys.dir = "left"; s:update()
  ok(s.moving == "left", "the pad walks again")
  local o = field(); talker(o, 3, 5, 4)
  o:host().slotFields(3, 0x6B, 0x4A)
  ok(o.objects[3].handler == Walk.FROZEN, "$07 on another slot writes its head word")
end

print(("mn_talk_walk_test: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
