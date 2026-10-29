-- WalkPointerSlots (01:407D) and the talk heads it calls.
--
-- Pointer list. InitPointerList (01:40D3, from SetupDefaultState) clears the 16 position
-- words at $C154, fills the free stack at $C134 with them in order (cursor $C132), and
-- marks all $31 records sleeping (byte 0 bit 7 set, bit 6 clear; the low bits stay).
-- Opcode0B takes a position (TakePointerSlot, 00:0C07) for a record whose bit 6 is
-- clear: byte 0 := $40, the position popped off the free stack, none when all 16 are
-- out. FinishFrame walks the positions in order once a frame:
--   * an empty word is skipped;
--   * a record with bit 7 set (slept by $05 / $0C / $19) is retired: bit 6 cleared,
--     its position pushed back (ReturnPointerSlot, 01:4062), the word cleared;
--   * otherwise its head (record bytes 1-2) is called. QueueSpriteList copies $FF97
--     to $FF98, sets $FF97 = $FF and, when the cell is inside [col-2, col+11] x
--     [row-2, row+10] of $C85F/$C860, $FF97 = (cellY*16 + 16 + fineY - $C934) & $FF.
--     After the call, $FF98 < $FF97 swaps this word with the previous kept position
--     (DE, which starts at the first position even when it is empty): one bubble
--     pass a frame toward descending screen Y. A head that queues nothing leaves both
--     bytes alone; RunTwoScriptsThenStoreScreenY ($5F04) stores $C8 into $FF97.
-- Then RestoreScratchRecord (01:4000): wRecordState ($C188) 3 -> 0, and the $1B-byte
-- scratch at $C1A4 is copied back over the record saved at $C174.
--
-- Talk. Only two heads read the A latch ($FFAB bit 2, FinishFrame's copy of the $FFAA
-- bit every A dispatch sets): $63ED (StageScratchThenPlantHeadWord64D1) and $6405
-- (PlantHeadWord64D1, the parked boat). Both call GateCellNearFirstRecord (01:641D):
-- latch, $C188 = 0, $C6EE = 0, $C716 = 0 and Tony's record cell in the window (M.near).
-- $63ED then copies the record to the scratch (CopyRecordToScratch: $C188 = 1, $C174 =
-- the record) and plants $64D1; $6405 plants $64D1 alone. $64D1 (01:64D1,
-- RunTailScriptThenPlantTwoScripts) runs on the record's next pass: the tail script
-- (record + $0E) as the record's script, head := $4A6B, then FillFirstRecordScriptSlots
-- (01:651A): $FFAA = $FFAB = 0, Tony's head := $4A6B (no pad), his first script slot
-- the bank-$20 idle by facing. Opcode12 writes $C188 = 3 and Tony's head $5E10
-- (DispatchHeldDirectionFromHead, the normal family) and parks.
-- So an A press in frame N is gated in N+1 (after that frame's list script slice) and
-- the tail starts in N+2, the first record in walk order wins, and a talk in progress
-- ($C188 = 1) blocks every other talk until its $12.
local M = {}

M.COUNT = 16
M.TALK = 0x63ED
M.PARKED = 0x6405
M.TAIL = 0x64D1
M.FROZEN = 0x4A6B -- RunTwoScriptsFromRecord: the record only runs its two scripts
M.COMMIT = 0x5E10 -- Opcode12's head for Tony
M.SCREEN_Y_C8 = 0x5F04
M.FACING = { up = 0, left = 1, right = 2, down = 3 }

-- InitPointerList
function M.init(ow)
  ow.ptrPos, ow.ptrFree, ow.ptrCur, ow.linked = {}, {}, 1, {}
  for i = 1, M.COUNT do ow.ptrPos[i] = false; ow.ptrFree[i] = i end
end

-- TakePointerSlot. Byte 0 := $40: the low two bits (the facing hRecordHead & 3 reads)
-- are cleared for a newly linked record; an already linked one keeps them.
function M.take(ow, slot)
  if not ow.ptrPos then M.init(ow) end
  if ow.linked[slot] then return false end
  if ow.ptrCur > M.COUNT then return false end
  local p = ow.ptrFree[ow.ptrCur]; ow.ptrCur = ow.ptrCur + 1
  ow.ptrPos[p] = slot; ow.linked[slot] = true
  ow.recByte0 = ow.recByte0 or {}
  ow.recByte0[slot] = 0x40
  return true
end

-- ReturnPointerSlot
function M.giveBack(ow, p)
  local slot = ow.ptrPos[p]
  ow.ptrCur = ow.ptrCur - 1; ow.ptrFree[ow.ptrCur] = p
  if slot then ow.linked[slot] = nil end
  ow.ptrPos[p] = false
end

-- GateCellNearFirstRecord (01:641D) window: b,c the record's cell, d,e Tony's, all
-- bytes; the subtractions wrap, so a record on row 0 / 1 (or column 0 / 1 facing
-- right) cannot be reached from the side the wrap closes.
function M.near(facing, b, c, d, e)
  b, c, d, e = b % 256, c % 256, d % 256, e % 256
  if d == b and e == c then return true end
  local function rowsLR() return e <= (c + 1) % 256 and e > (c - 2) % 256 end
  if facing == 0 then return d == b and e > (c - 1) % 256 and e <= (c + 1) % 256 end
  if facing == 3 then return d == b and e > (c - 2) % 256 and e <= c end
  if facing == 1 then return d > (b - 1) % 256 and d <= (b + 1) % 256 and rowsLR() end
  if facing == 2 then return d > (b - 2) % 256 and d <= b and rowsLR() end
  return false
end

local function record(ow, slot)
  local ob = ow.objects[slot] or (ow.asleep and ow.asleep[slot])
  return ob
end

local function sleeping(ow, slot, ob)
  if slot == 0 then return ob ~= nil and ob.dormant == true end
  return ob == nil or ob.dormant == true
end

-- Tony's record cell ($C18E/$C18F): during a ride the cell he boarded from.
function M.tonyCell(ow)
  if ow.rec0 then return ow.rec0[1], ow.rec0[2] end
  return ow.x, ow.y
end

-- $FF97 after this record's head: a screen Y byte, $FF outside the keep window, or nil
-- when the head queues no sprite list (port: a record with no anim, a blank or a
-- hidden one; one list per record).
function M.screenY(ow, slot, ob)
  if ob and ob.handler == M.SCREEN_Y_C8 then return 0xC8 end
  local cx, cy, fy
  if slot == 0 and not ow.objects[0] then
    if ow.hidePlayer then return nil end
    cx, cy = ow.x, ow.y; fy = (ow.py or cy * 16) - cy * 16
  else
    if not ob or ob.blank or ob.hidden or ob.picking or not (ob.anim or ob.sched or ob.image) then return nil end
    cx, cy, fy = ob.x, ob.y, ob.oy or 0
  end
  local camX, camY = 0, 0
  if ow.cameraXY and ow.def and ow.def.w then camX, camY = ow:cameraXY() end
  local col, row = math.floor(camX / 16), math.floor(camY / 16)
  if cx < col - 2 or cx > col + 11 or cy < row - 2 or cy > row + 10 then return 0xFF end
  return (cy * 16 + 16 + fy - camY) % 256
end

-- CopyRecordToScratch: what the port keeps of the record's $1B bytes.
local KEEP = { "handler", "x", "y", "ox", "oy", "anim", "sched", "still", "blank", "driven", "dormant", "talkFrom" }
local function scratch(ow, slot, ob)
  local s = { slot = slot, thread = ow.vm.threads and ow.vm.threads[slot] or false }
  for _, k in ipairs(KEEP) do s[k] = ob[k] end
  ow.recScratch = s
  ow.vm:wr8(0xC188, 1)
end

-- RestoreScratchRecord
function M.restore(ow)
  local vm = ow.vm
  if vm:rd8(0xC188) ~= 3 then return end
  vm:wr8(0xC188, 0)
  local s = ow.recScratch
  if not s then return end
  local ob = record(ow, s.slot)
  if not ob then return end
  local animChanged = ob.anim ~= s.anim or ob.sched ~= s.sched or ob.blank ~= s.blank
  for _, k in ipairs(KEEP) do ob[k] = s[k] end
  ob.hx, ob.hy = nil, nil
  -- the record's script slots go back too; a thread the talk started is gone
  if vm.threads and vm.threads[s.slot] and vm.threads[s.slot] ~= s.thread
    and vm.threads[s.slot].co ~= coroutine.running() then vm.threads[s.slot] = nil end
  if animChanged and ow.obj and ob.anim then require("mn.Sprites").build(ow, ob) end
  ow.log[#ow.log + 1] = ("restore scratch -> slot %d at %d,%d"):format(s.slot, ob.x, ob.y)
end

-- The gate's live $C716: the third (list) script record. The port runs it as the main
-- script (ow.c714Live while it has not ended).
local function c716(ow)
  if ow.vm:rd8(0xC716) ~= 0 then return true end
  if ow.c714Live and not ow.scriptWaiting then ow.c714Live = nil end
  return ow.c714Live == true
end

local function gate(ow, ob, latch)
  if not latch then return false end
  local vm = ow.vm
  if vm:rd8(0xC188) ~= 0 or vm:rd8(0xC6EE) ~= 0 or c716(ow) then return false end
  local tx, ty = M.tonyCell(ow)
  return M.near(M.FACING[ow.facing or "down"] or 3, ob.x, ob.y, tx, ty)
end

-- $64D1 for record `slot`: its tail, then FillFirstRecordScriptSlots.
local function runTail(ow, slot, ob)
  local from = ob.talkFrom; ob.talkFrom = nil
  ob.handler = M.FROZEN
  ow.tonyHead = M.FROZEN
  ow.aPress = nil
  if from == M.PARKED then
    if ob.tail then
      ow.log[#ow.log + 1] = ("board slot %d -> %02X:%04X"):format(slot, ob.tail[1], ob.tail[2])
      ow.vm:spawnThread(slot, ob.tail[1], ob.tail[2])
    end
    return
  end
  -- a tail that only plants its talk ($5B bank ptr, $42) is the talk itself; one that
  -- carries on after the $5B runs as the slot's thread (257 boatman 1B:509A)
  local rom = ow.vm.rom
  if ob.beh and ow.useRunsRecord(rom, ob.beh[1], ob.beh[2]) then
    ow.log[#ow.log + 1] = ("use slot %d -> %02X:%04X"):format(slot, ob.beh[1], ob.beh[2])
    ow.vm:spawnThread(slot, ob.beh[1], ob.beh[2])
  elseif ob.talk then
    ow:runScript(ob.talk[1], ob.talk[2], ("talk to slot %d"):format(slot))
  elseif ob.tail then
    -- 22:4004 and other tails with no talk: the record's script only
    ow.log[#ow.log + 1] = ("tail slot %d -> %02X:%04X"):format(slot, ob.tail[1], ob.tail[2])
    ow.vm:spawnThread(slot, ob.tail[1], ob.tail[2])
  end
end

-- One WalkPointerSlots pass. latch: $FFAB bit 2 this frame.
function M.pass(ow, latch)
  if not ow.ptrPos then M.init(ow) end
  local thr, met = 0xFF, 0xFF
  local de = 1
  for p = 1, M.COUNT do
    local slot = ow.ptrPos[p]
    if slot then
      local ob = record(ow, slot)
      if sleeping(ow, slot, ob) then
        M.giveBack(ow, p)
      else
        if ob and slot ~= 0 then
          local h = ob.handler
          if h == M.TAIL then
            runTail(ow, slot, ob); latch = nil
          elseif h == M.TALK and gate(ow, ob, latch) then
            scratch(ow, slot, ob)
            ob.handler = M.TAIL; ob.talkFrom = M.TALK
            ow.log[#ow.log + 1] = ("641D slot %d at %d,%d"):format(slot, ob.x, ob.y)
          elseif h == M.PARKED and ob.tail and gate(ow, ob, latch) then
            ob.handler = M.TAIL; ob.talkFrom = M.PARKED
          end
        end
        local y = M.screenY(ow, slot, ob)
        if y then met = thr; thr = y end
        if met < thr then ow.ptrPos[de], ow.ptrPos[p] = ow.ptrPos[p], ow.ptrPos[de] end
        de = p
      end
    end
  end
  M.restore(ow)
  return latch
end

-- Walk order of the linked slots (tests, debug).
function M.order(ow)
  local t = {}
  for p = 1, M.COUNT do if ow.ptrPos and ow.ptrPos[p] then t[#t + 1] = ow.ptrPos[p] end end
  return t
end

return M
