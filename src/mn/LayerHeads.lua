-- The $01 and $02 layer head families (bank 1), as fine-step records.
--
-- $02 layer (head byte 0 up, 1 left, 2 right, 3 down): ResumeHead00Record 510B,
-- ResumeHead01Record 4FB7, ResumeHead02Record 5061, ResumeHead03Record 4F0D.
-- Per frame: head byte; 5DE1 (LoadRecordHead clears $C6D2/$C6D3, one bank-$20
-- script frame sets them); 4ECB ($C12C = 0, $C12A = $FF); a newly pressed
-- other direction ($C9A4) plants that direction's slide (4EF2 down 20:5CB3,
-- 4F9C left 5D2E, 5046 right 5DA9, 50F0 up 5C38) and commits; 5E65; a zero
-- live step on the head's axis commits; 05:682D, 422E, camera; a zero saved
-- step ($C6D1 / $C6D0) or a nonzero live step commits. Otherwise the record
-- has stopped: the cell beyond is $02 -> commit, $00 -> 4EC2 and the one-cell
-- exit (5A9A down, 59E7 left, 5A21 right, 5A5B up) under head 5DB5, anything
-- else -> the bump script (5CC3 down, 5D3E left, 5DB9 right, 5C48 up), same head.
-- Switch order: down head up/left/right, left head right/up/down, right head
-- left/down/up, up head down/right/left.
-- Entered from the normal heads at count 3 and $C9A6 >= 5 (4ED4 down 5C7A,
-- 4F7E left 5CF5, 5028 right 5D70, 50D2 up 5BFF), straight onto the head.
--
-- $01 layer: idle head 56DC (5DE1, 56C0, then held $C9A3: right 5888, left
-- 57F9, up 5917, down 5779 plant the walk head; otherwise 5E65 + 682D + 422E
-- and commit). Walk heads 5798 down, 5818 left, 58A7 right, 5936 up: a
-- released direction plants the idle script (51B3 down, 518F left, 519B
-- right, 51A7 up) under 56DC (56C9 keeps the head byte); down/up held with
-- left -> 57F9, with right -> 5888; left/right on odd hMainLoopCounter set
-- the Y step $FF with up held, else 1 with down held. Then 5E65 + 682D + 422E;
-- the same stop test; a $00 cell beyond -> 56B7 and the exit anim under 5DB5.
-- Entered by 570D/5728/5743/575E (56C0, 59A8 down, 58F5 left, 592F right,
-- 5969 up) under 5DB5. Walk scripts: 526E down, 531D left, 53CC right, 51BF up.
--
-- RunHeadWordScript 5DB5: LoadRecordHead, $C187 = 0, one script frame, then
-- 05:67A3 (fine X then fine Y, no wall test), camera; a nonzero $C187 makes
-- $C186/$C187 the head word ($10 in the script: 5D81 normal, 56DC layer 1).
--
-- Script frames are the bank-$20 ops these scripts use: $4C (00:1560), $4D
-- (StepScriptSpritePointerTable), $46 and $10. Translated code; the script
-- bytes are read from the player's ROM at run time (rd).
local bit = require("bit")
local Motion = require("mn.Motion")
local band = bit.band

local M = {}

M.RUN, M.IDLE1, M.NORMAL = 0x5DB5, 0x56DC, 0x5D81
M.FACE = { [0] = "up", "left", "right", "down" }
M.BYTE = { up = 0, left = 1, right = 2, down = 3 }
local BIT = { [0] = 0x40, 0x20, 0x10, 0x80 }
M.BIT = BIT

-- $02 layer, by head byte
local L2 = {
  [0] = { head = 0x510B, axis = "y", d = -1, slide = 0x5C38, entry = 0x5BFF, bump = 0x5C48, exit = 0x5A5B, sw = { 3, 2, 1 } },
  [1] = { head = 0x4FB7, axis = "x", d = -1, slide = 0x5D2E, entry = 0x5CF5, bump = 0x5D3E, exit = 0x59E7, sw = { 2, 0, 3 } },
  [2] = { head = 0x5061, axis = "x", d = 1, slide = 0x5DA9, entry = 0x5D70, bump = 0x5DB9, exit = 0x5A21, sw = { 1, 3, 0 } },
  [3] = { head = 0x4F0D, axis = "y", d = 1, slide = 0x5CB3, entry = 0x5C7A, bump = 0x5CC3, exit = 0x5A9A, sw = { 0, 1, 2 } },
}
-- $01 layer, by head byte
local L1 = {
  [0] = { head = 0x5936, axis = "y", d = -1, walk = 0x51BF, rel = 0x51A7, entry = 0x5969, exit = 0x5A5B },
  [1] = { head = 0x5818, axis = "x", d = -1, walk = 0x531D, rel = 0x518F, entry = 0x58F5, exit = 0x59E7 },
  [2] = { head = 0x58A7, axis = "x", d = 1, walk = 0x53CC, rel = 0x519B, entry = 0x592F, exit = 0x5A21 },
  [3] = { head = 0x5798, axis = "y", d = 1, walk = 0x526E, rel = 0x51B3, entry = 0x59A8, exit = 0x5A9A },
}
M.L1, M.L2 = L1, L2
local HEADS = {}
for b, t in pairs(L2) do HEADS[t.head] = { layer = 2, b = b } end
for b, t in pairs(L1) do HEADS[t.head] = { layer = 1, b = b } end
HEADS[M.IDLE1] = { layer = 1 }

local function word(rd, a) return rd(a) + rd(a + 1) * 256 end

-- plant a script from its start (handler INITIAL_SCRIPT_HANDLER)
local function plant(lw, ptr) lw.scr = { h = "disp", ptr = ptr } end
M.plant = plant

-- One script frame. Sets st.sx / st.sy ($C6D2 / $C6D3) and lw.list.
function M.frame(lw)
  local rd, c, st = lw.rd, lw.scr, lw.st
  for _ = 1, 256 do
    if c.h == "disp" then
      local op = rd(c.ptr)
      if op == 0x4C then c.ptr = c.ptr + 1; c.h = "4c"
      elseif op == 0x4D then c.base = c.ptr + 1; c.count = rd(c.base + 1); c.off = 0; c.h = "4d"
      elseif op == 0x46 then c.ptr = word(rd, c.ptr + 1)
      elseif op == 0x10 then lw.queued = word(rd, c.ptr + 1); c.ptr = c.ptr + 3
      else error(("LayerHeads: op $%02X at 20:%04X"):format(op, c.ptr)) end
    elseif c.h == "4c" then
      -- a zero count ends the records and dispatches the next op in the same pass
      local n = rd(c.ptr); c.ptr = c.ptr + 1
      if n == 0 then c.h = "disp" else c.count = n; c.h = "4cstep" end
    elseif c.h == "4cstep" then
      st.sx, st.sy, lw.list = rd(c.ptr), rd(c.ptr + 1), word(rd, c.ptr + 2)
      c.count = band(c.count - 1, 0xFF)
      if c.count == 0 then c.ptr = c.ptr + 4; c.h = "4c" end
      return
    else -- "4d": table of n/2 list words, each shown count frames with the one step
      local b = c.base
      st.sx, st.sy, lw.list = rd(b + 2), rd(b + 3), word(rd, b + 4 + c.off)
      c.count = band(c.count - 1, 0xFF)
      if c.count == 0 then
        c.off = c.off + 2
        if c.off == rd(b) then c.ptr = b + 4 + rd(b); c.h = "disp" -- next pass dispatches
        else c.count = rd(b + 1) end
      end
      return
    end
  end
  error("LayerHeads: script without a frame")
end

-- rd(addr): a bank-$20 byte. The record starts at cell cx,cy, fine 8,8.
function M.new(rd, cx, cy, stride)
  return { rd = rd, st = Motion.new(cx, cy, stride), hb = 3, head = M.IDLE1, prevHeld = 0 }
end


-- The normal head's blocked step plants an entry (4ED4.. for 2, 570D.. for 1).
function M.enter(lw, layer, dir, io)
  local b = M.BYTE[dir]
  lw.hb, lw.layer = b, layer
  if layer == 2 then
    plant(lw, L2[b].entry); lw.head = L2[b].head
  else
    if io and io.gates then io.gates("enter1") end -- 56C0
    plant(lw, L1[b].entry); lw.head = M.RUN
  end
end

local function axisStep(st, axis) return axis == "y" and st.sy or st.sx end
local function saved(st, axis) return axis == "y" and st.oy or st.ox end
local function beyond(st, t) return t.axis == "y" and st.ptr + t.d * st.stride or st.ptr + t.d end

local function motion(lw, io)
  local st = lw.st
  Motion.conveyor(st, io.env)
  Motion.step(st, io.env)
  if io.trigger and io.trigger(st) then lw.fired = true end
end

local function head2(lw, io, b, pressed)
  local t, st = L2[b], lw.st
  lw.hb = b
  M.frame(lw)
  io.gates("enter2") -- 4ECB
  for _, o in ipairs(t.sw) do
    if band(pressed, BIT[o]) ~= 0 then plant(lw, L2[o].slide); lw.head = L2[o].head; return end
  end
  Motion.conveyor(st, io.env)
  if axisStep(st, t.axis) == 0 then return end
  Motion.step(st, io.env)
  if io.trigger and io.trigger(st) then lw.fired = true end -- 422E only stages; the head goes on
  if saved(st, t.axis) == 0 or axisStep(st, t.axis) ~= 0 then return end
  local v = io.env.cell(beyond(st, t))
  if v == 0x02 then return end
  if v == 0x00 then io.gates("exit2"); plant(lw, t.exit); lw.head, lw.layer = M.RUN, nil; return "exit" end -- 4EC2
  plant(lw, t.bump); return "bump"
end

local function plant1(lw, b) lw.hb = b; plant(lw, L1[b].walk); lw.head = L1[b].head end

local function idle1(lw, io, held)
  M.frame(lw)
  io.gates("enter1") -- 56C0
  if band(held, 0x10) ~= 0 then return plant1(lw, 2) end
  if band(held, 0x20) ~= 0 then return plant1(lw, 1) end
  if band(held, 0x40) ~= 0 then return plant1(lw, 0) end
  if band(held, 0x80) ~= 0 then return plant1(lw, 3) end
  motion(lw, io)
end

local function head1(lw, io, b, held)
  local t, st = L1[b], lw.st
  M.frame(lw)
  io.gates("enter1")
  if band(held, BIT[b]) == 0 then plant(lw, t.rel); lw.head = M.IDLE1; return end
  if t.axis == "y" then
    if band(held, 0x20) ~= 0 then return plant1(lw, 1) end
    if band(held, 0x10) ~= 0 then return plant1(lw, 2) end
  elseif band(io.frame or 0, 1) ~= 0 then
    if band(held, 0x40) ~= 0 then st.sy = 0xFF elseif band(held, 0x80) ~= 0 then st.sy = 1 end
  end
  motion(lw, io)
  if saved(st, t.axis) == 0 or axisStep(st, t.axis) ~= 0 then return end
  if io.env.cell(beyond(st, t)) ~= 0x00 then return end
  io.gates("exit1") -- 56B7
  plant(lw, t.exit); lw.head, lw.layer = M.RUN, nil
  return "exit"
end

local function run(lw)
  local st = lw.st
  lw.queued = nil
  M.frame(lw)
  Motion.fineX(st); Motion.fineY(st)
  if lw.queued then
    lw.head = lw.queued
    local k = HEADS[lw.head]
    lw.layer = k and k.layer or nil
  end
end

-- One frame. io: held ($C9A3 bits), frame (hMainLoopCounter), env (Motion env),
-- gates(name) (World.writeGates), trigger(st) -> true when a step script fired.
-- Returns "normal" once the head word is the normal family (5D81), else a tag.
function M.tick(lw, io)
  local held = io.held or 0
  local pressed = band(held, bit.bnot(lw.prevHeld or 0))
  lw.prevHeld = held
  lw.fired = nil
  local h = lw.head
  if h == M.RUN then
    run(lw)
    if lw.head == M.NORMAL then return "normal" end
    if lw.head ~= M.RUN and not HEADS[lw.head] then return "unknown" end
    return "run"
  end
  if h == M.IDLE1 then idle1(lw, io, held); return "idle" end
  local k = HEADS[h]
  if not k then return "unknown" end
  if k.layer == 2 then return head2(lw, io, k.b, pressed) or "step" end
  return head1(lw, io, k.b, held) or "step"
end

function M.pixel(lw)
  local st = lw.st
  return st.cx * 16 + st.fx - 8, st.cy * 16 + st.fy - 8
end

return M
