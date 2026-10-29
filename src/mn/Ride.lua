-- Ride (boat) mode: a record that carries the pad instead of Tony.
-- ClearC12BSetC12A01 (bank 1 $60E7) writes $C12B = 0 and $C12A = $01, so
-- $01 cells are floor and $00 cells solid ($02 stays solid, $03 open), then
-- jumps to ResumePlantedHead60FD. That head reads the held pad copy $C9A3
-- and plants a direction head: up 01:608A (record facing 0, anim 11:780A),
-- left 01:5FC4 (facing 1, 11:7822), right 01:6027 (facing 2, 11:782E), down
-- 01:5F66 (facing 3, 11:7816). Each step is the one-pixel walk through
-- SaveStepThenApplyOrDispatch (05:682D, the normal cell probe), then
-- StageThirdScriptFromMarkedCell (step triggers fire from the record's cell)
-- and NudgeCameraPastFollowEdge. No hops, layers or other A actions.
-- With no direction held, the facing tails (60DE / 601E / 6081 / 5FBB) point
-- at the faced cell and call PlantBank22ScriptOnZeroByte (01:5F25): A newly
-- pressed ($C932 bit 0) on a faced $00 cell docks. It writes $C12B = $01 and
-- $C12A = 0, moves record 0 (Tony) to the faced cell, gives the boat record
-- script 22:40AD and head word $6405.
-- Head $6405 (the parked boat) runs GateCellNearFirstRecord (01:641D) and on
-- a hit plants $64D1 (RunTailScriptThenPlantTwoScripts), which runs the
-- record's tail script (22:40C2: put Tony to sleep, music $0B, head word
-- $60E7, anim 11:780A). The gate needs $FFAB bit 2 (any A dispatch by Tony,
-- whatever the faced cell), wRecordState = 0, $C6EE = 0 and $C716 = 0.
-- 22:40C2 does not move Tony's record: through the ride $C18E/$C18F stay on the
-- cell he boarded from (only Opcode00 at 01:4426 and slot 0's own commit write
-- them), and the $65A4 step-on gate compares records against that cell (ow.rec0).
-- With no direction held the head's idle tail is picked by hRecordHead & 3, the
-- boat record's opening byte. Opcode05 skips that byte, so the first idle facing
-- is whatever the slot last held (ow.recByte0, see mn.Walk.take).
local World = require("mn.World")
local Sprites = require("mn.Sprites")
local Walk = require("mn.Walk")

local M = {}

M.HANDLER = 0x60E7 -- ClearC12BSetC12A01
M.PARKED = 0x6405 -- PlantHeadWord64D1
M.TAIL = 0x64D1 -- RunTailScriptThenPlantTwoScripts
M.DOCK_SCRIPT = { 0x22, 0x40AD }
M.FACING = { up = 0, left = 1, right = 2, down = 3 }
M.ANIM = { up = { 0x11, 0x780A }, left = { 0x11, 0x7822 }, right = { 0x11, 0x782E }, down = { 0x11, 0x7816 } }
local DIRS = { up = { 0, -1 }, down = { 0, 1 }, left = { -1, 0 }, right = { 1, 0 } }

-- GateCellNearFirstRecord (01:641D) window, byte arithmetic included (mn.Walk).
M.near = Walk.near

-- The awake record whose head is $60E7, if any.
function M.rider(ow)
  for slot, ob in pairs(ow.objects or {}) do
    if type(slot) == "number" and slot ~= 0 and ob.handler == M.HANDLER and not ob.dormant then return slot, ob end
  end
end

-- The boat is the live cell: keep its record where the field position is.
function M.sync(ow)
  local ob = ow.riding and ow.objects[ow.riding]
  if not ob then return end
  ob.x, ob.y = ow.x, ow.y
  ob.ox, ob.oy = ow.px - ow.x * 16, ow.py - ow.y * 16
  ob.hx, ob.hy = nil, nil
end

local NAMES = { [0] = "up", "left", "right", "down" }

-- Record byte 0 bits 0-1 (hRecordHead & 3): the direction heads write the facing back.
function M.setByte0Facing(ow, slot, dir)
  ow.recByte0 = ow.recByte0 or {}
  local b = ow.recByte0[slot] or 0
  ow.recByte0[slot] = b - b % 4 + M.FACING[dir]
end

-- The facing the record's byte 0 holds, nil when the port never saw the slot linked.
function M.byte0Facing(ow, slot)
  local b = ow.recByte0 and ow.recByte0[slot]
  return b and NAMES[b % 4] or nil
end

-- A direction head replaces the record's script with its anim.
local function face(ow, slot, ob, dir)
  if ob.rideFacing == dir and ob.anim then return end
  ob.rideFacing = dir
  M.setByte0Facing(ow, slot, dir)
  if ow.vm.threads then ow.vm.threads[slot] = nil end
  local a = M.ANIM[dir]
  ob.anim, ob.sched = { a[1], a[2] }, nil
  if ow.obj then Sprites.build(ow, ob) end
end

-- One control frame. True when a ride owns the pad.
function M.tick(ow)
  local slot, ob = M.rider(ow)
  if not slot then ow.riding = nil; ow.rec0 = nil; return false end
  local vm = ow.vm
  if ow.riding ~= slot then
    -- $60E7's first pass: gates, then the planted head drives this record
    World.writeGates(vm, "ride")
    ow.rec0 = { ow.x, ow.y } -- $C18E/$C18F as the mount finds them
    ow.riding = slot; ob.driven = true
    ow.x, ow.y = ob.x, ob.y; ow:snap(); ow.moving = nil; ow.hidePlayer = true; ow.camFix = nil
    -- the idle tail is picked by byte 0 & 3: $40 from TakePointerSlot (up) for a newly
    -- linked record, else what the slot held last
    local res = M.byte0Facing(ow, slot)
    if res then ow.facing = res
    elseif ob.rideFacing then ow.facing = ob.rideFacing end
    ow.log[#ow.log + 1] = ("ride slot %d at %d,%d"):format(slot, ob.x, ob.y)
  end
  local dir = ow.input("dir")
  if dir then
    ow.facing = dir; face(ow, slot, ob, dir)
    local d = DIRS[dir]
    local nx, ny = ow.x + d[1], ow.y + d[2]
    if World.walkable(World.cell(ow.def, nx, ny), vm) then
      ow.x, ow.y = nx, ny; ow.moving = dir; ow.camFix = nil
    end
    M.sync(ow); return true
  end
  if ow.input("a") then
    local f = DIRS[ow.facing or "down"]
    local fx, fy = ow.x + f[1], ow.y + f[2]
    if World.cell(ow.def, fx, fy) == 0x00 then
      World.writeGates(vm, "dock")
      ob.handler = M.PARKED; ob.x, ob.y, ob.ox, ob.oy = ow.x, ow.y, 0, 0
      ow.riding = nil; ow.rec0 = nil
      ow.x, ow.y = fx, fy; ow:snap(); ow.hidePlayer = nil; ow.moving = nil
      ow.log[#ow.log + 1] = ("dock slot %d, Tony at %d,%d"):format(slot, fx, fy)
      vm:spawnThread(slot, M.DOCK_SCRIPT[1], M.DOCK_SCRIPT[2])
      return true
    end
  end
  M.sync(ow); return true
end

-- The $6405 gate, the $64D1 tail and the walk order that decides which record answers
-- an A are in mn.Walk.
return M
