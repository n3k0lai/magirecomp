-- 01:5B07, the player record held in place: 4AF0, StepCell82EveryFourthFrame (01:4212),
-- DispatchCellAboveOnButtonA (01:4C6E), CommitScriptRecord (01:5D9B). And the A order
-- against a parked boat: every A dispatch sets $FFAA bit 2; GateCellNearFirstRecord
-- (01:641D) runs a frame later and a staged list script ($C716) blocks it.
-- Made-up cells and script bytes only, no ROM bytes.
--   luajit tests/engine/mn_frozen_head_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end }, graphics = {} } -- luacheck: ignore 111
local failures, checks = 0, 0
local function ok(c, w) checks = checks + 1; if not c then failures = failures + 1; print("FAIL " .. w) end end

local Overworld = require("mn.Overworld")
local MnRom = require("mn.MnRom")
local Ride = require("mn.Ride")
local Grass = require("mn.Grass")

-- a made-up sprite loop at 20:5BDF so the anim field reads as a sprite anim:
-- $4C (1 frame, list $5000), $46 back to itself
local at = 0x20 * 0x4000 + 0x5BDF - 0x4000
local img = string.rep("\0", at) .. string.char(0x4C, 0x01, 0x00, 0x00, 0x00, 0x50, 0x00, 0x46, 0xDF, 0x5B)
local rom = MnRom.new(img .. string.rep("\0", 0x200000 - #img))

local function vmStub()
  local v = { mem = {}, threads = {}, spawned = {}, rom = rom }
  function v:rd8(a) return self.mem[a] or 0 end
  function v:wr8(a, b) self.mem[a] = b end
  function v:spawnThread(slot, b, ptr) self.spawned[#self.spawned + 1] = { slot, b, ptr } end
  return v
end

-- 21:78EB-style record: $00,$5B07,cell with script 20:5BDF, after a cutscene stand-in
local s = setmetatable({ x = 4, y = 4, objects = { [0] = { x = 1, y = 1 } }, hidePlayer = true, log = {}, vm = vmStub() },
  { __index = Overworld })
pcall(s:host().spawn, 0, 4, 4, 0x5B07, 0, 0x20, 0x5BDF, 0x22, 0x4005)
ok(s.objects[0] == nil and s.hidePlayer == false, "$5B07 slot-0 record is the player, the stand-in goes")
ok(s.padHead == 0x5B07, "the $5B07 head is kept")

-- a 7x7 field: Tony at 3,3; $41 list cell above, a $82 grass cell under him
local W, H = 7, 7
local block = {}
for i = 1, W * H do block[i] = 0x00 end
local function set(x, y, v) block[y * W + x + 1] = v end
set(3, 2, 0x41); set(3, 3, 0x82)
local ran = {}
local function field()
  local o = setmetatable({ def = { w = W, h = H, block = block }, vm = vmStub(), objects = {}, log = {},
    x = 3, y = 3, facing = "left", padHead = 0x5B07, aList = 0x5000 }, { __index = Overworld })
  o.listEntry = function(_, ptr, idx) return nil, 0x15, 0x6000 + idx end
  o.runScript = function(_, b, p, why) ran[#ran + 1] = { b, p, why } end
  function o:snap() self.px, self.py = self.x * 16, self.y * 16 end
  return o
end

-- no pad walk: a held direction neither moves nor turns
local o = field()
o.input = function(k) return k == "dir" and "right" or nil end
o:frozenPass()
ok(o.x == 3 and o.y == 3 and o.facing == "left" and not o.moving, "a held direction does nothing")

-- A tests the cell above whatever the facing, and the facing is not rewritten
ran = {}
o.input = function(k) return k == "a" or nil end
o:frozenPass()
ok(#ran == 1 and ran[1][1] == 0x15 and ran[1][2] == 0x6001, "A runs list entry $41-$40 from the cell above")
ok(o.vm.mem[0xC99C] == 2 and o.vm.mem[0xC99D] == 3, "4B61 saves the cell above (row 2, column 3)")
ok(o.facing == "left", "hRecordHead keeps its facing")

-- aCool still gates A
ran = {}; o.aCool = 2; o:frozenPass(); ok(#ran == 0, "A is ignored while aCool is running")

-- 4212 is the plain every-fourth-pass gate: a held B does not swap in 4221
o = field(); o.input = function() return nil end; o.bHeld = true
o.vm.mem[Grass.ENABLE] = 1; o.vm.mem[Grass.COUNT] = 5; o.vm.mem[Grass.FRAME] = 3
o:frozenPass()
ok(o.vm.mem[Grass.COUNT] == 4 and o.bHeld == true, "standing on $82 ticks the countdown on pass n&3 == 3")
o.vm.mem[Grass.FRAME] = 2; o:frozenPass()
ok(o.vm.mem[Grass.COUNT] == 4, "other passes do not tick")

-- A order with a parked boat in the window (record at 3,4 below Tony, facing down)
local function withBoat(cellBelow)
  local f = field(); f.padHead = nil; f.facing = "down"
  f.objects[4] = { x = 3, y = 4, handler = Ride.PARKED, tail = { 0x22, 0x40C2 } }
  set(3, 4, cellBelow)
  return f
end
ran = {}
o = withBoat(0x41); o:pressA()
ok(#ran == 1 and o.objects[4].handler == Ride.PARKED, "a list script staged by the A dispatch blocks the re-board ($C716)")
ran = {}
o = withBoat(0x01); o:pressA()
ok(#ran == 0 and o.objects[4].handler == Ride.TAIL, "no list script: the parked boat runs its tail")
-- the latch is set by any A: the faced cell is not tested (diagonal left window)
o = withBoat(0x01); o.facing = "left"; o.x, o.y = 4, 3; set(3, 3, 0x00)
ok(Ride.find(o) == 4, "left window from 4,3 (faced cell open land) still passes 641D")
set(3, 3, 0x82)

print(("mn_frozen_head_test: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
