-- The conveyor walk family: the slot-0 pad head $5B41 (01:5B41 loads $C9A6,
-- then ResumeDownClearHead 01:5B6E). Map-entry and landing scripts plant it with
-- FillScriptRecord0808 (record handler $5B41, fine 8,8): 18:740F..7644 (271-276),
-- 19:68CE/6A12/6AA9/7D6F (250-254), 21:7821/7897 (38, 39), and the boat landings
-- 2F:4630/464E/466C and 2F:49DA. Unlike the normal family (5D81 -> 5E10 ->
-- 6167/61DE, whole-cell steps) these heads move the record by its live fine step
-- every frame and add AddCellDirectionStep (01:5E65), so $A0-$A7 cells carry Tony.
--
-- Per frame, as the heads run it:
--   StepCell82EveryFourthFrame (4212) -> 5DE1 (412F clears $C6D2/$C6D3, then one
--   frame of the record's bank-$20 script sets them) -> the held-pad tests
--   ($C9A3: bit 4 right, 5 left, 6 up, 7 down) -> 5E65 -> 05:682D -> 422E ->
--   4AF0 (camera) -> the A dispatch -> commit 5D9B.
--   Idle 5B6E:  right 5CA5, left 5C2F, up 5D1B, down 5BC8 plants, in that order;
--               otherwise motion, then a newly pressed A ($C9A4 bit 0) -> 5BA7,
--               the same facing switch as DispatchPressedAOnFacingCell (01:619A).
--   Down 5BEB:  down released -> idle script 20:5BCF and head 5B6E (5B5B);
--               left -> 5C2F; right -> 5CA5; motion; $C6D3 == 0 -> 4B7B (A).
--   Up 5D3E:    up released -> 20:5BBF; left -> 5C2F; right -> 5CA5; motion;
--               $C6D3 == 0 -> 4C6E.
--   Left 5C52:  left released -> 20:5BDF; on odd hMainLoopCounter frames up sets
--               $C6D3 = $FF, else down sets 1; motion; $C6D2 == 0 -> 4BCC.
--   Right 5CC8: right released -> 20:5BEF; same odd-frame rule; $C6D2 == 0 -> 4C1D.
-- A plant (5BC8/5C2F/5CA5/5D1B) sets the facing, the walk script (20:5B4C down,
-- 5B6F left, 5B9C right, 5B29 up) and the head, then commits: that frame's
-- script step is dropped and the new script's first frame runs next frame.
-- A release (5B5B) does the same with the idle script.
-- Translated code; script bytes are read from the player's ROM at run time.
local bit = require("bit")
local Motion = require("mn.Motion")

local M = {}

M.HEAD = 0x5B41
local IDLE = { up = 0x5BBF, down = 0x5BCF, left = 0x5BDF, right = 0x5BEF }
local WALK = { up = 0x5B29, down = 0x5B4C, left = 0x5B6F, right = 0x5B9C }
M.IDLE, M.WALK = IDLE, WALK
local BIT = { right = 0x10, left = 0x20, up = 0x40, down = 0x80 }
M.BIT = BIT

-- a bank-$20 script as a frame cursor (Sprites.frames gives { n, dx, dy, list })
local function cursor(frames, ptr)
  local list, loops = frames(0x20, ptr)
  return { list = list or {}, loops = loops, e = 1, k = 0, ptr = ptr }
end
local function nextFrame(c)
  local e = c.list[c.e]
  if not e then return 0, 0, nil end
  local dx, dy, l = e.dx or 0, e.dy or 0, e.list
  c.k = c.k + 1
  if c.k >= e.n then
    c.k = 0; c.e = c.e + 1
    if c.e > #c.list then
      -- a script that loops on itself starts over; one that ends holds its last list, no step
      if c.loops then c.e = 1 else c.list = { { n = 1, dx = 0, dy = 0, list = l } }; c.e = 1 end
    end
  end
  return bit.band(dx, 0xFF), bit.band(dy, 0xFF), l
end
M.cursor, M.nextFrame = cursor, nextFrame

-- pw = { st = Motion state, head = "idle"|"up"|"down"|"left"|"right", script = cursor }
function M.new(frames, cx, cy, stride, facing)
  return { st = Motion.new(cx, cy, stride), head = "idle", script = cursor(frames, IDLE[facing or "down"] or IDLE.down) }
end

local function setScript(pw, frames, ptr) pw.script = cursor(frames, ptr) end

-- One frame. io:
--   frames(bank, ptr), held (the $C9A3 high-nibble mask), a (newly pressed A),
--   frame (hMainLoopCounter), env { cell, gate }, grass() -> true when the
--   $82 countdown staged a script, trigger(st) -> true when 422E staged one,
--   pressA() (the facing-cell dispatch), face(dir).
-- Returns "grass", "plant", "release", "trigger" or "move".
function M.tick(pw, io)
  if io.grass and io.grass() then return "grass" end
  local st = pw.st
  -- 5DE1: 412F clears the step, the script frame writes it
  st.sx, st.sy, pw.list = nextFrame(pw.script)
  local held, h = io.held or 0, pw.head
  local function plant(d)
    pw.head = d; setScript(pw, io.frames, WALK[d]); io.face(d); return "plant"
  end
  local function release()
    setScript(pw, io.frames, IDLE[h]); pw.head = "idle"; return "release"
  end
  if h == "idle" then
    if bit.band(held, BIT.right) ~= 0 then return plant("right") end
    if bit.band(held, BIT.left) ~= 0 then return plant("left") end
    if bit.band(held, BIT.up) ~= 0 then return plant("up") end
    if bit.band(held, BIT.down) ~= 0 then return plant("down") end
  elseif h == "down" or h == "up" then
    if bit.band(held, BIT[h]) == 0 then return release() end
    if bit.band(held, BIT.left) ~= 0 then return plant("left") end
    if bit.band(held, BIT.right) ~= 0 then return plant("right") end
  else
    if bit.band(held, BIT[h]) == 0 then return release() end
    if io.frame % 2 == 1 then
      if bit.band(held, BIT.up) ~= 0 then st.sy = 0xFF
      elseif bit.band(held, BIT.down) ~= 0 then st.sy = 1 end
    end
  end
  Motion.conveyor(st, io.env)
  Motion.step(st, io.env)
  if io.trigger and io.trigger(st) then return "trigger" end
  if io.a then
    local stopped
    if h == "idle" then stopped = true
    elseif h == "up" or h == "down" then stopped = st.sy == 0
    else stopped = st.sx == 0 end
    if stopped and io.pressA then io.pressA() end
  end
  return "move"
end

-- field pixel position (the port's px = cell * 16 is fine 8)
function M.pixel(pw)
  local st = pw.st
  return st.cx * 16 + st.fx - 8, st.cy * 16 + st.fy - 8
end

return M
