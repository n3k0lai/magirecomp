-- Ride (boat) mode, bank 1 $60E7 / $60FD / $5F25 / $6405 / $641D (mn.Ride).
-- Synthetic cells and a stub field only, no ROM bytes.
--   luajit tests/engine/mn_ride_mode_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end }, graphics = {} } -- luacheck: ignore 111
local failures, checks = 0, 0
local function ok(c, w) checks = checks + 1; if not c then failures = failures + 1; print("FAIL " .. w) end end

local World = require("mn.World")
local Ride = require("mn.Ride")

-- GateCellNearFirstRecord window, record at 10,10.
local N = Ride.near
ok(N(0, 10, 10, 10, 10) and N(1, 10, 10, 10, 10) and N(2, 10, 10, 10, 10) and N(3, 10, 10, 10, 10), "the record's own cell passes for every facing")
ok(N(0, 10, 10, 10, 11) and not N(0, 10, 10, 10, 12) and not N(0, 10, 10, 11, 11), "up: same column, the row below only")
ok(N(3, 10, 10, 10, 9) and not N(3, 10, 10, 10, 11) and not N(3, 10, 10, 9, 9), "down: same column, the row above only")
ok(N(1, 10, 10, 11, 9) and N(1, 10, 10, 11, 10) and N(1, 10, 10, 11, 11) and not N(1, 10, 10, 11, 12) and not N(1, 10, 10, 9, 10), "left: one column right, rows c-1..c+1")
ok(N(2, 10, 10, 9, 9) and N(2, 10, 10, 9, 11) and not N(2, 10, 10, 11, 10) and not N(2, 10, 10, 8, 10), "right: one column left, rows c-1..c+1")

-- Gate bytes.
local function vmStub()
  local v = { mem = {}, threads = {}, spawned = {} }
  local p = { 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF }
  for i = 0, 7 do v.mem[0xC12A + i] = p[i + 1] end
  function v:rd8(a) return self.mem[a] or 0 end
  function v:wr8(a, b) self.mem[a] = b end
  function v:spawnThread(slot, b, ptr) self.spawned[#self.spawned + 1] = { slot, b, ptr } end
  return v
end
local vm = vmStub()
World.writeGates(vm, "ride")
ok(vm.mem[0xC12A] == 0x01 and vm.mem[0xC12B] == 0x00, "60E7: $C12B = 0, $C12A = $01")
ok(World.walkable(0x01, vm) and not World.walkable(0x00, vm) and not World.walkable(0x02, vm) and World.walkable(0x03, vm), "ride: $01 floor, $00 and $02 solid, $03 open")
World.writeGates(vm, "dock")
ok(vm.mem[0xC12A] == 0x00 and vm.mem[0xC12B] == 0x01, "5F25: $C12B = $01, $C12A = 0")
ok(World.walkable(0x00, vm) and not World.walkable(0x01, vm), "docked: $00 floor, $01 solid")

-- A stub field: row 0 land, rows 1-3 water ($01), a $C1 trigger in the water.
local W, H = 5, 4
local block = {}
for y = 0, H - 1 do for x = 0, W - 1 do block[#block + 1] = (y == 0) and 0x00 or 0x01 end end
block[2 * W + 4 + 1] = 0xC1
local pad = {}
local ow = { def = { w = W, h = H, block = block }, vm = vmStub(), objects = {}, log = {}, x = 0, y = 0, facing = "down" }
function ow:snap() self.px, self.py = self.x * 16, self.y * 16 end
ow.input = function(k) local v = pad[k]; pad[k] = nil; return v end
World.writeGates(ow.vm, "exit1") -- the normal pattern ($C12A = 0, $C12B = $FF)
ow:snap()
ow.objects[4] = { x = 2, y = 2, handler = Ride.HANDLER, dormant = true, tail = { 0x22, 0x40C2 } }
ok(not Ride.tick(ow), "a sleeping $60E7 record does not ride")
ow.objects[4].dormant = nil
ok(Ride.tick(ow) and ow.riding == 4, "the woken $60E7 record takes the pad")
ok(ow.x == 2 and ow.y == 2 and ow.hidePlayer, "the field follows the boat; Tony is not drawn")
ok(ow.vm.mem[0xC12A] == 0x01 and ow.vm.mem[0xC12B] == 0x00, "riding writes the $60E7 gates")
pad.dir = "up"; Ride.tick(ow)
ok(ow.x == 2 and ow.y == 1 and ow.moving == "up", "up onto $01 water steps")
ok(ow.objects[4].anim[1] == 0x11 and ow.objects[4].anim[2] == 0x780A, "up plants anim 11:780A")
ow.moving = nil; ow:snap(); Ride.sync(ow)
pad.dir = "up"; Ride.tick(ow)
ok(ow.y == 1 and not ow.moving and ow.facing == "up", "$00 land is solid to the boat (the boat turns, no step)")
pad.dir = "left"; Ride.tick(ow); ow.moving = nil; ow:snap(); Ride.sync(ow)
ok(ow.x == 1 and ow.objects[4].anim[2] == 0x7822 and ow.objects[4].x == 1, "left plants 11:7822 and the record moves with the field")
pad.dir = "right"; Ride.tick(ow); ok(ow.objects[4].anim[2] == 0x782E, "right plants 11:782E"); ow.moving = nil; ow:snap()
pad.dir = "down"; Ride.tick(ow); ok(ow.objects[4].anim[2] == 0x7816, "down plants 11:7816"); ow.moving = nil; ow:snap()
-- facing down onto water: A does not dock
pad.a = true; Ride.tick(ow)
ok(ow.riding == 4, "A facing water keeps riding")
pad.dir = "up"; Ride.tick(ow); ow.moving = nil; ow:snap()
pad.dir = "up"; Ride.tick(ow) -- turn against the shore
ok(ow.x == 2 and ow.y == 1 and ow.facing == "up", "at 2,1 facing the shore")
-- a held direction runs the direction head, not the dock tail
pad.dir = "up"; pad.a = true; Ride.tick(ow)
ok(ow.riding == 4, "A with a direction held does not dock")
pad.a = nil
pad.a = true; Ride.tick(ow)
ok(ow.riding == nil and ow.x == 2 and ow.y == 0 and not ow.hidePlayer, "A facing $00 docks: Tony on the faced cell")
local bt = ow.objects[4]
ok(bt.handler == Ride.PARKED and bt.x == 2 and bt.y == 1, "the boat parks with head $6405 where it was")
ok(ow.vm.mem[0xC12A] == 0x00 and ow.vm.mem[0xC12B] == 0x01, "docking writes the $5F25 gates")
local sp = ow.vm.spawned[#ow.vm.spawned]
ok(sp and sp[1] == 4 and sp[2] == 0x22 and sp[3] == 0x40AD, "the boat record gets script 22:40AD")
ok(not Ride.tick(ow), "a parked boat does not ride")
-- re-mount: the boat is at 2,1, below the shore row
ow.facing = "up"; ow.x, ow.y = 2, 0
ok(not Ride.try(ow), "facing away (up) is outside the window")
ow.facing = "down"; ow.x = 3
ok(not Ride.try(ow), "one column off is outside the down window")
ow.facing = "left"; ow.x, ow.y = 1, 0
ok(not Ride.try(ow), "left from 1,0 is outside the left window (columns 2-3)")
ow.facing = "down"; ow.x = 2
ow.vm.mem[0xC6EE] = 1; ok(not Ride.try(ow), "$C6EE nonzero blocks the gate"); ow.vm.mem[0xC6EE] = 0
ok(Ride.try(ow) and bt.handler == Ride.TAIL, "A facing the boat runs $64D1")
sp = ow.vm.spawned[#ow.vm.spawned]
ok(sp[1] == 4 and sp[2] == 0x22 and sp[3] == 0x40C2, "the tail script (22:40C2) runs in the boat's slot")
bt.handler = Ride.HANDLER -- its $13 $60E7
ok(Ride.tick(ow) and ow.x == 2 and ow.y == 1 and ow.hidePlayer, "the next frame rides again from the boat's cell")
ok(ow.rec0 and ow.rec0[1] == 2 and ow.rec0[2] == 0, "Tony's record cell ($C18E/$C18F) stays where he boarded")
pad.dir = "down"; Ride.tick(ow); ow.moving = nil; ow:snap()
ok(ow.y == 2 and ow.rec0[1] == 2 and ow.rec0[2] == 0, "the boat moves, Tony's record cell does not")

-- $93 FinishStartup -> SetupDefaultState -> WriteC12APattern (05:6C08): a script that
-- reloads the scene ends the ride's gates (2F:466C -> 25:7129 lands Tony back on foot).
do
  local MnRom = require("mn.MnRom")
  local VM = require("mn.ScriptVM")
  -- made-up script at 13:4000: $93 ; AC C004 := 7 ; $94
  local s = string.rep("\0", 0x13 * 0x4000) .. string.char(0x93, 0xAC, 0x04, 0xC0, 0x07, 0x94)
  local rom = MnRom.new(s .. string.rep("\0", 0x200000 - #s))
  local calls = { gates = 0, fresh = 0 }
  local v
  local host = {
    defaultGates = function() calls.gates = calls.gates + 1; World.seedPattern(v) end,
    freshScene = function() calls.fresh = calls.fresh + 1 end,
  }
  v = VM.new(rom, host)
  World.writeGates(v, "ride")
  ok(World.walkable(0x01, v) and not World.walkable(0x00, v), "riding before the $93")
  v:start(0x13, 0x4000)
  local n = 0
  while v:rd8(0xC004) == 0 and n < 20 do v:resume(); n = n + 1 end
  ok(calls.gates == 1 and calls.fresh == 1, "$93 rewrites the gates and starts the scene over")
  ok(v:rd8(0xC12A) == 0x00 and v:rd8(0xC12B) == 0xFF and v:rd8(0xC12D) == 0x00 and v:rd8(0xC131) == 0xFF, "the 05:6C08 pattern is back at $C12A")
  ok(World.walkable(0x00, v) and not World.walkable(0x01, v), "after $93: $00 floor, $01 solid")
  v.init = true; calls.gates = 0; calls.fresh = 0
  World.writeGates(v, "ride"); v:wr8(0xC004, 0)
  v:start(0x13, 0x4000); n = 0
  while v:rd8(0xC004) == 0 and n < 20 do v:resume(); n = n + 1 end
  ok(calls.gates == 1 and calls.fresh == 0, "an init-script $93 still rewrites the gates (records are kept)")
end

if failures == 0 then print(("ok %d checks"):format(checks)) else print(("%d FAIL / %d"):format(failures, checks)) end
os.exit(failures == 0 and 0 or 1)
