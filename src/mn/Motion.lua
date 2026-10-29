-- Fine-step motion of the player record: the bank-5 engine
-- SaveStepThenApplyOrDispatch (05:682D), its eight cell probes and handler
-- table, AddCellDirectionStep (01:5E65, the $A0-$A7 conveyors) and
-- StageThirdScriptFromMarkedCell (01:422E, the once-per-entry trigger rule).
--
-- State (`st`), all bytes 0-255 as in WRAM/HRAM:
--   sx, sy   live step $C6D2 (X) / $C6D3 (Y), written by the record script
--   ox, oy   saved step $C6D0 / $C6D1 (682D copies the live step there first)
--   c6d6     the diagonal corner countdown
--   fx, fy   fine X/Y inside the cell ($FF8F / $FF90), 8 = cell centre
--   cx, cy   cell X/Y; ptr = cy * stride + cx (hMapCellPointer as an index)
--   stride   map width ($C6CF)
-- env: cell(ptr) -> cell byte (the WRAM-5 plane; out of range reads $08),
--      gate(v)   -> the $C12A + v gate byte (v < 8).
-- Translated from the decomp; no ROM data lives here.
local bit = require("bit")
local band = bit.band

local M = {}

local function u8(v) return band(v, 0xFF) end
local function neg(v) return v >= 0x80 end

-- ProbeCells* solid test: >= $80 open, >= $08 solid, else the gate byte
local function solid(env, ptr)
  local v = env.cell(ptr)
  if v >= 0x80 then return false end
  if v >= 0x08 then return true end
  return env.gate(v) ~= 0
end
M.solid = solid

-- ApplyFineXDelta / ApplyFineYDelta: bit 4 of the sum moves one cell
function M.fineX(st)
  local b = st.sx
  if b == 0 then return end
  local a = u8(st.fx + b)
  if band(a, 0x10) == 0 then st.fx = a; return end
  st.fx = band(a, 0x0F)
  if neg(b) then st.ptr = st.ptr - 1; st.cx = u8(st.cx - 1)
  else st.ptr = st.ptr + 1; st.cx = u8(st.cx + 1) end
end
function M.fineY(st)
  local b = st.sy
  if b == 0 then return end
  local a = u8(st.fy + b)
  if band(a, 0x10) == 0 then st.fy = a; return end
  st.fy = band(a, 0x0F)
  if neg(b) then st.ptr = st.ptr - st.stride; st.cy = u8(st.cy - 1)
  else st.ptr = st.ptr + st.stride; st.cy = u8(st.cy + 1) end
end

-- AddXStepOrSnapFineXToEight (05:6717)
function M.snapX(st)
  local b = st.sx
  local a = u8(st.fx + b)
  if neg(b) then
    if a >= 8 then st.fx = a else st.sx = 0; st.fx = 8 end
  else
    if a < 8 then st.fx = a else st.sx = 0; st.fx = 8 end
  end
end
-- ApplyYStepIntoFineY (05:675A): the sum is also stored as the step
function M.snapY(st)
  local b = st.sy
  local a = u8(st.fy + b)
  st.sy = a
  if neg(b) then
    if a >= 8 then st.fy = a else st.sy = 0; st.fy = 8 end
  else
    if a < 8 then st.fy = a else st.sy = 0; st.fy = 8 end
  end
end
-- SeedXStepFromFineXEnds (05:673E) and its Y twin
local function seedX(st) st.sx = (st.fx == 0 and 0xFF) or (st.fx == 0x0F and 1) or 0 end
local function seedY(st) st.sy = (st.fy == 0 and 0xFF) or (st.fy == 0x0F and 1) or 0 end

local fineX, fineY, snapX, snapY = M.fineX, M.fineY, M.snapX, M.snapY

-- the handlers, by address
local H = {}
H[0x65AE] = function(st) fineX(st); fineY(st) end
H[0x65B5] = function(st) fineX(st); snapY(st) end
H[0x65BC] = function(st) snapX(st); fineY(st) end
H[0x65C3] = function(st) snapX(st); snapY(st) end
H[0x65CA] = function(st)
  if st.sy ~= 0 then fineY(st); fineX(st)
  elseif st.fy < 9 then fineX(st)
  else st.sy = 0xFF; fineY(st); fineX(st) end
end
H[0x65E4] = function(st)
  if st.sy ~= 0 then fineY(st)
  elseif st.fy >= 8 then fineX(st)
  else st.sy = 1; fineY(st) end
end
H[0x65FF] = function(st)
  if st.sy ~= 0 then fineY(st)
  elseif st.fy == 8 then fineX(st)
  elseif st.fy > 8 then st.sy = 0xFF; fineY(st)
  else st.sy = 1; fineY(st) end
end
H[0x6625] = function(st) snapX(st); if st.sy == 0 then seedY(st) end; fineY(st) end
H[0x6636] = function(st)
  if st.c6d6 ~= 0 then st.c6d6 = st.c6d6 - 1; fineY(st); return end
  snapX(st); if st.sy == 0 then st.sy = 0xFF end; fineY(st)
end
H[0x6653] = function(st)
  if st.c6d6 ~= 0 then st.c6d6 = st.c6d6 - 1; fineY(st); return end
  snapX(st); if st.sy == 0 then st.sy = 1 end; fineY(st)
end
H[0x6670] = function(st)
  if st.sx ~= 0 then fineX(st)
  elseif st.fx < 9 then fineY(st)
  else st.sx = 0xFF; fineX(st) end
end
H[0x668B] = function(st)
  if st.sx ~= 0 then fineX(st)
  elseif st.fx >= 8 then fineY(st)
  else st.sx = 1; fineX(st) end
end
H[0x66A6] = function(st)
  if st.sx ~= 0 then fineX(st)
  elseif st.fx == 8 then fineY(st)
  elseif st.fx < 8 then st.sx = 1; fineX(st)
  else st.sx = 0xFF; fineX(st) end
end
H[0x66CC] = function(st) if st.sx == 0 then seedX(st) end; fineX(st); snapY(st) end
H[0x66DD] = function(st)
  if st.c6d6 ~= 0 then st.c6d6 = st.c6d6 - 1; fineX(st); return end
  snapY(st); if st.sx == 0 then st.sx = 0xFF end; fineX(st)
end
H[0x66FA] = function(st)
  if st.c6d6 ~= 0 then st.c6d6 = st.c6d6 - 1; fineX(st); return end
  snapY(st); if st.sx == 0 then st.sx = 1 end; fineX(st)
end
M.HANDLERS = H

-- handler table 05:652E, row per class, column = probe occupancy 0-7
local CORNER = { 0x65AE, 0x65B5, 0x65B5, 0x65B5, 0x65BC, 0x65C3, 0x65BC, 0x65C3 }
local SIDE = { 0x65AE, 0x65CA, 0x65E4, 0x65FF, 0x6625, 0x6636, 0x6653, 0x65BC }
local VERT = { 0x65AE, 0x6670, 0x668B, 0x66A6, 0x66CC, 0x66DD, 0x66FA, 0x65B5 }
M.TABLE = { [0] = CORNER, CORNER, SIDE, CORNER, CORNER, SIDE, VERT, VERT }

-- the probes (05:651E order: UpLeft, DownLeft, Left, UpRight, DownRight, Right, Up, Down)
local function diag(env, p, side, vert)
  local o = 0
  if solid(env, p + side) then o = o + 4 end
  if solid(env, p + side + vert) then o = o + 2 end
  if solid(env, p + vert) then o = o + 1 end
  return o
end
local function straight(env, p, ahead, across, fine)
  local o = solid(env, p + ahead) and 4 or 0
  if fine == 8 then return o + 3 end
  if solid(env, p + ahead + (fine < 8 and -across or across)) then o = o + 3 end
  return o
end
local PROBES = {
  [0] = function(st, env) return diag(env, st.ptr, -1, -st.stride) end,
  function(st, env) return diag(env, st.ptr, -1, st.stride) end,
  function(st, env) return straight(env, st.ptr, -1, st.stride, st.fy) end,
  function(st, env) return diag(env, st.ptr, 1, -st.stride) end,
  function(st, env) return diag(env, st.ptr, 1, st.stride) end,
  function(st, env) return straight(env, st.ptr, 1, st.stride, st.fy) end,
  function(st, env) return straight(env, st.ptr, -st.stride, 1, st.fx) end,
  function(st, env) return straight(env, st.ptr, st.stride, 1, st.fx) end,
}
M.PROBES = PROBES

-- 05:6884: X part 1 / 4 / 7 plus Y part -1 / 0 / +1; 8 = no centre line crossed
function M.classify(st)
  local x, y
  local sx, sy = st.sx, st.sy
  if neg(sx) then x = (u8(st.fx + sx) < 8) and 1 or 7
  elseif sx ~= 0 and u8(st.fx + sx) >= 9 then x = 4 else x = 7 end
  if neg(sy) then y = (u8(st.fy + sy) < 8) and -1 or 1
  elseif sy ~= 0 and u8(st.fy + sy) >= 9 then y = 0 else y = 1 end
  return x + y
end

-- SaveStepThenApplyOrDispatch (05:682D). Returns class, occupancy, handler.
function M.step(st, env)
  st.ox, st.oy = st.sx, st.sy
  if st.sx == 0 and st.sy == 0 then return end
  -- "ld a,[C6D3] / and b": a bitwise AND, so (+1,-2) does not arm the countdown
  if band(st.sy, st.sx) ~= 0 then st.c6d6 = 2 end
  local cls = M.classify(st)
  if cls == 8 then fineX(st); fineY(st); return 8 end
  local occ = PROBES[cls](st, env)
  local h = M.TABLE[cls][occ + 1]
  H[h](st)
  return cls, occ, h
end

-- AddCellDirectionStep (01:5E65): the cell under the record adds to the step
M.CONVEYOR = {
  [0xA0] = { 0x00, 0xFD }, [0xA1] = { 0x02, 0xFE }, [0xA2] = { 0x03, 0x00 }, [0xA3] = { 0x02, 0x02 },
  [0xA4] = { 0x00, 0x03 }, [0xA5] = { 0xFE, 0x02 }, [0xA6] = { 0xFD, 0x00 }, [0xA7] = { 0xFE, 0xFE },
}
function M.conveyor(st, env)
  local d = M.CONVEYOR[env.cell(st.ptr)]
  if not d then return end
  st.sx = u8(st.sx + d[1]); st.sy = u8(st.sy + d[2])
end

-- StageThirdScriptFromMarkedCell (01:422E). mem: rd8/wr8 table or vm; busy =
-- a staged third script ($C716 nonzero). entry(idx) -> kind, bank, ptr, or nil
-- when idx is past the list count ($C6E1). Returns bank, ptr when it stages.
function M.trigger(st, env, mem, entry, busy)
  if busy then return end
  local c = u8(st.sx + st.ox)
  local b = u8(st.sy + st.oy)
  if b == 0 and c == 0 then return end
  local v = env.cell(st.ptr)
  if band(v, 0xC0) ~= 0xC0 then mem:wr8(0xC6DE, 0xFF); return end
  local idx = band(v, 0x3F)
  local kind, bank, ptr = entry(idx)
  if not kind then return end
  if mem:rd8(0xC6DE) == idx then return end
  local pass
  if kind == 1 then pass = neg(b)
  elseif kind == 2 then pass = b ~= 0 and not neg(b)
  elseif kind == 3 then pass = c ~= 0 and not neg(c)
  elseif kind == 4 then pass = neg(c)
  else pass = true end
  if not pass then return end
  mem:wr8(0xC6DE, idx)
  return bank, ptr, idx
end

-- a fresh record at a cell centre
function M.new(cx, cy, stride, fx, fy)
  return { sx = 0, sy = 0, ox = 0, oy = 0, c6d6 = 0, fx = fx or 8, fy = fy or 8,
           cx = cx, cy = cy, stride = stride, ptr = cy * stride + cx }
end

return M
