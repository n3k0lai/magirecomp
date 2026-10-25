-- NPC sprites from opcode $05 spawns: (slot, handler, x, y, word, tile base,
-- anim bank, anim ptr, ...). The anim script's first $4C record
-- (QueueRepeatedSpriteList: frames, dx, dy, list) or $4D table entry
-- (StepScriptSpritePointerTable) names a QueueSpriteList list in the same bank;
-- records are (Y, X, tile, attr), tile + base ($FF95), attr bit 3 = VRAM bank,
-- bits 0-2 = OBJ palette (opcode $66 block, default $21:$5CC0).
local bit = require("bit")
local M = {}

local function firstList(rom, bank, ptr)
  local o = bank * 0x4000 + ptr - 0x4000
  for _ = 1, 8 do
    local op = rom:u8(o)
    if op == 0x4C then return rom:u16(o + 4)
    elseif op == 0x4D then return rom:u16(o + 5)
    elseif op == 0x46 then o = bank * 0x4000 + rom:u16(o + 1) - 0x4000
    elseif op == 0x4E then o = o + 4 -- RepeatTwoScriptBytes prefix (rock fall 11:74F4)
    else return nil end
  end
end

-- Full anim sequence: $4C/$4F records (count, b1, b2, list) until a $00
-- count, $4D tables (n, count, b1, b2, n list words), $46 loops back.
-- Returns { {n=frames, dx, dy, list}... }, loops
function M.frames(rom, bank, ptr)
  local o = bank * 0x4000 + ptr - 0x4000
  local out, seen, rep = {}, {}, nil
  for _ = 1, 32 do
    if seen[o] then return out, true end
    seen[o] = true
    local op = rom:u8(o)
    if op == 0x4E then -- RepeatTwoScriptBytes (count, 2 bytes): the next record repeats count times
      rep = rom:u8(o + 1); o = o + 4
    elseif op == 0x4C or op == 0x4F then
      local q = o + 1
      while rom:u8(q) ~= 0 and #out < 64 do
        local a, b = rom:u8(q + 1), rom:u8(q + 2)
        if a >= 128 then a = a - 256 end; if b >= 128 then b = b - 256 end
        -- b1/b2 go to $C6D2/$C6D3, the fine X/Y deltas (ApplyFineXThenFineY). PyBoy: Tony's
        -- inn get-up 20:5B0B (FE,F8 / FE,01 / ...) moves him one cell left, 17,5 -> 16,5
        local dx, dy = a, b
        out[#out + 1] = { n = rom:u8(q) * (rep or 1), dx = dx, dy = dy, list = rom:u16(q + 3) }; rep = nil
        q = q + 5
      end
      o = q + 1
    elseif op == 0x4D then
      local n, c, a, b = rom:u8(o + 1), rom:u8(o + 2), rom:u8(o + 3), rom:u8(o + 4)
      if a >= 128 then a = a - 256 end; if b >= 128 then b = b - 256 end
      -- n is the table size in bytes (SpriteAnim0E_6866: $08 = 4 lists); a/b = dx, dy
      -- a/b = per-frame dx, dy (SpriteAnim0E_6866: 00,FF walks up 1 px/frame)
      for k = 0, n / 2 - 1 do out[#out + 1] = { n = c, dx = a, dy = b, list = rom:u16(o + 5 + 2 * k) } end
      o = o + 5 + n
    elseif op == 0x46 then o = bank * 0x4000 + rom:u16(o + 1) - 0x4000
    else return out, false end
  end
  return out, false
end

local SPRITE_BANKS = { [0x0E] = 1, [0x0F] = 1, [0x10] = 1, [0x11] = 1, [0x20] = 1, [0x25] = 1 }
M.SPRITE_BANKS = SPRITE_BANKS

-- Walk an object's behaviour script: $15 records (key, ptr, bank) name the
-- facing anims (Script14_5E33: "sc_op15 $10, $F0, $56, $10, ..."), and $5B
-- FillScriptRecordC71BUnlessC6EEIs1 (bank, ptr) plants the talk script in
-- the third record (wThirdScriptRecord+7, $C71B).
function M.behaviour(rom, bank, ptr)
  local out, seen, q = {}, {}, { { bank, ptr } }
  local h = 1
  while h <= #q and h < 12 do
    local b, p = q[h][1], q[h][2]; h = h + 1
    if p >= 0x4000 and p < 0x8000 and b < 0x31 and not seen[b * 65536 + p] then
      seen[b * 65536 + p] = true
      local o = b * 0x4000 + p - 0x4000
      for _ = 1, 24 do
        local op = rom:u8(o); local n, t = rom:insn(o)
        if not n then break end
        -- $14 Opcode14 (bank, ptr): one anim. $15 Opcode15: schedule of
        -- (bank, anim ptr, frames) records until $00 = the movement script.
        if op == 0x14 and not out.anim and SPRITE_BANKS[rom:u8(o + 1)] then out.anim = { rom:u8(o + 1), rom:u16(o + 2) } end
        if op == 0x15 and not out.sched then
          local sc, q = {}, o + 1
          while rom:u8(q) ~= 0 and #sc < 32 do
            if SPRITE_BANKS[rom:u8(q)] then sc[#sc + 1] = { rom:u8(q), rom:u16(q + 1), rom:u8(q + 3) } end
            q = q + 4
          end
          if #sc > 0 then out.sched = sc; out.anim = out.anim or { sc[1][1], sc[1][2] } end
        end
        if op == 0x5B and not out.talk then out.talk = { rom:u8(o + 1), rom:u16(o + 2) } end
        if op == 0x46 then q[#q + 1] = { b, rom:u16(o + 1) }; break end
        for _, x in ipairs(t) do q[#q + 1] = x end
        if op == 0x42 or op == 0x94 or op == 0x12 then break end
        o = o + n
      end
    end
  end
  return out
end

function M.npc(ow, x, y, base, abank, aptr, sbank, sptr)
  local o = { x = x, y = y }
  local rom = ow.vm.rom
  local beh = M.behaviour(rom, sbank or 0, sptr or 0)
  if not SPRITE_BANKS[abank] then
    local b2 = M.behaviour(rom, abank, aptr); beh.talk = beh.talk or b2.talk
    -- the spawn's anim script wins: it is what the object runs first
    if b2.anim then beh.anim, beh.sched = b2.anim, b2.sched or (not b2.anim and beh.sched or nil) end
  else beh.anim = beh.anim or { abank, aptr } end
  if not SPRITE_BANKS[abank] then beh.sched = beh.sched end
  o.talk = beh.talk; o.anim = beh.anim; o.sched = beh.sched; o.base = base
  if beh.anim then M.build(ow, o) end
  return o
end

-- (Re)build an NPC image from the live OBJ tile memory (map VRAM records plus
-- any $6B glyph copies the entry script made).
function M.build(ow, o)
  if not o.anim then return end
  local rom, vr, base = ow.vm.rom, ow.obj, o.base
  local abank, aptr = o.anim[1], o.anim[2]
  local seq = M.frames(rom, abank, aptr)
  if #seq == 0 then local lp = firstList(rom, abank, aptr); if not lp then return o end; seq = { { n = 1, dx = 0, dy = 0, list = lp } } end
  o.seq, o.imgs, o.fi, o.ft, o.ox, o.oy = seq, o.imgs or {}, 1, 0, o.ox or 0, o.oy or 0
  for _, f in ipairs(seq) do
    local key = abank * 65536 + f.list
    if not o.imgs[key] then o.imgs[key] = M.drawList(ow, rom, abank, f.list, base) end
    f.img = o.imgs[key]
  end
  o.image = seq[1].img
  if o.sched then
    o.seqs, o.si, o.st = {}, 1, 0
    for k, e in ipairs(o.sched) do
      local sq = M.frames(rom, e[1], e[2])
      if #sq == 0 then local lp = firstList(rom, e[1], e[2]); sq = lp and { { n = 1, dx = 0, dy = 0, list = lp } } or seq end
      for _, f in ipairs(sq) do
        local key = e[1] * 65536 + f.list
        if not f.img then
          if not o.imgs[key] then o.imgs[key] = M.drawList(ow, rom, e[1], f.list, base) end
          f.img = o.imgs[key]
        end
      end
      o.seqs[k] = sq
    end
    o.seq = o.seqs[1]; o.image = o.seq[1].img or o.image
  end
  return o
end

-- Animate: advance frame counters at 60 Hz; dx/dy motion accumulates as a
-- pixel offset that snaps to whole 16-px cells (movement scripts).
function M.tick(o, canEnter)
  if o.seq and #o.seq >= 1 then
    local f = o.seq[o.fi]
    if not o.still then -- $16 walkers animate in place; the scroll carries them
      local nx, ny = o.ox + (f.dx or 0), o.oy + (f.dy or 0)
      -- objects stop at blocked cells (Tavel Gorge kids halt at the cave wall)
      local tx = o.x + (nx >= 16 and 1 or nx <= -16 and -1 or 0)
      local ty = o.y + (ny >= 16 and 1 or ny <= -16 and -1 or 0)
      if (tx ~= o.x or ty ~= o.y) and canEnter and not canEnter(tx, ty) then nx, ny = o.ox, o.oy end
      o.ox, o.oy = nx, ny
    end
    while o.ox >= 16 do o.ox = o.ox - 16; o.x = o.x + 1 end
    while o.ox <= -16 do o.ox = o.ox + 16; o.x = o.x - 1 end
    while o.oy >= 16 do o.oy = o.oy - 16; o.y = o.y + 1 end
    while o.oy <= -16 do o.oy = o.oy + 16; o.y = o.y - 1 end
    o.ft = o.ft + 1
    if o.ft >= math.max(1, f.n) then o.ft = 0; o.fi = o.fi % #o.seq + 1; o.image = o.seq[o.fi].img or o.image end
  end
  -- a $15 record lasts its full frame count, motion included (16 frames of 20:4FB3 at
  -- 1 px = one cell up), so the schedule steps after this frame's motion
  if o.seqs then
    o.st = o.st + 1
    -- a script-driven $15 schedule holds its last record (the script goes on, e.g. to a
    -- $5F wait; PyBoy: training-grounds Tony walks 2 cells then idles, 13:58A0); a
    -- statically decoded behaviour loop wraps around like its script's jump back
    local hold = o.driven and o.si == #o.sched
    if #o.sched > 1 and not hold and o.st >= math.max(1, o.sched[o.si][3]) then
      o.st = 0; o.si = o.si % #o.sched + 1; o.seq = o.seqs[o.si]; o.fi, o.ft = 1, 0
      o.image = o.seq[1].img or o.image
    end
  end
end

function M.drawList(ow, rom, abank, lp, base)
  local vr = ow.obj
  local po = 0x21 * 0x4000 + 0x5CC0 - 0x4000
  local img = love.image.newImageData(64, 64) -- origin 32,32: list offsets reach -40 (rock fall 11:54BC)
  local q = abank * 0x4000 + lp - 0x4000
  local n = 0
  while rom:u8(q) ~= 0x80 and n < 24 do
    local yy, xx, t, at = rom:u8(q), rom:u8(q + 1), rom:u8(q + 2), rom:u8(q + 3)
    if yy >= 128 then yy = yy - 256 end; if xx >= 128 then xx = xx - 256 end
    t = (t + base) % 256
    local vb = bit.band(at, 8) ~= 0 and 0x1000 or 0
    local pal = bit.band(at, 7)
    for ty = 0, 7 do
      local sy = bit.band(at, 0x40) ~= 0 and 7 - ty or ty
      local lo, hi = vr[vb + t * 16 + sy * 2] or 0, vr[vb + t * 16 + sy * 2 + 1] or 0
      for tx = 0, 7 do
        local sx = bit.band(at, 0x20) ~= 0 and tx or 7 - tx
        local ci = bit.band(bit.rshift(lo, sx), 1) + 2 * bit.band(bit.rshift(hi, sx), 1)
        local px, py = 32 + xx + tx, 32 + yy + ty
        if ci ~= 0 and px >= 0 and px < 64 and py >= 0 and py < 64 then
          local w = rom:u16(po + 2 * (pal * 4 + ci))
          img:setPixel(px, py, bit.band(w, 31) / 31, bit.band(bit.rshift(w, 5), 31) / 31, bit.band(bit.rshift(w, 10), 31) / 31, 1)
        end
      end
    end
    q = q + 4; n = n + 1
  end
  if os.getenv("MN_DUMP") then
    M.dumpN = (M.dumpN or 0) + 1
    img:encode("png", ("dump_%02X_%04X_%03d.png"):format(abank, lp, M.dumpN))
  end
  local im = love.graphics.newImage(img); im:setFilter("nearest", "nearest")
  return im
end

-- One step per frame of a QueueRepeatedSpriteList tail (00:1560).
-- x,y are the fine deltas summed so far ($C6D2 then $C6D3). list is the
-- sprite-list pointer in the same bank; 0 means the record named none,
-- and the walker stays up. The kick and push lunges both use this.
function M.lunge(rom, bank, ptr)
  if not rom or not ptr then return {} end
  local frames = M.frames(rom, bank or 0x20, ptr)
  local steps, x, y = {}, 0, 0
  for i = 1, #frames do
    local fr = frames[i]
    for _ = 1, fr.n do
      x, y = x + fr.dx, y + fr.dy
      steps[#steps + 1] = { x, y, list = fr.list or 0 }
      if #steps >= 32 then return steps end
    end
  end
  return steps
end

-- Apply the next lunge frame. Nil when the records are finished.
-- kind ("kick" / "push") is only for the MN_DEBUG_POSE line.
function M.lungeAdvance(ow, state, kind)
  state.i = (state.i or 0) + 1
  local step = state.steps[state.i]
  if not step then return nil end
  ow.px = ow.x * 16 + step[1]
  ow.py = ow.y * 16 + step[2]
  if os.getenv("MN_DEBUG_POSE") then
    local lp = step.list or 0
    local f = ow.vm and ow.vm.tk or 0
    if lp == 0 then print(("[pose] f%d %s walker"):format(f, kind))
    else print(("[pose] f%d %s %04X"):format(f, kind, lp)) end
  end
  return step
end

-- List pointer the lunge is showing, or nil so the walker is drawn.
function M.lungeList(state)
  if not state or not state.steps then return nil end
  local step = state.steps[state.i or 0]
  local lp = step and step.list or 0
  if lp == 0 then return nil end
  return lp
end

-- Tony's walker tiles: OBJ VRAM bank 1 $8000-$87FF is ROM $60:$7000.
-- The script ROM stops at bank $3C, so the pixels come from the cached
-- full ROM (the same bytes the walker sheet was built from).
function M.walkerTiles()
  if M._walker ~= nil then return M._walker or nil end
  local Importer = require("mn.MnImporter")
  local bytes = love.filesystem.read(Importer.CACHE .. "/rom.bin")
  local base = require("mn.MnRom").off(0x7000, 0x60)
  if not bytes or #bytes < base + 0x800 then M._walker = false; return nil end
  M._walker = bytes:sub(base + 1, base + 0x800)
  return M._walker
end

-- Draw one bank-$20 player list (tile base 0). Nil keeps the walker:
-- a zero pointer, an empty list, or no tile source.
function M.playerList(ow, lp)
  if not lp or lp == 0 or not ow or not ow.vm or not ow.vm.rom then return nil end
  ow.poseImgs = ow.poseImgs or {}
  if ow.poseImgs[lp] ~= nil then return ow.poseImgs[lp] or nil end
  local rom = ow.vm.rom
  local q = 0x20 * 0x4000 + lp - 0x4000
  if rom:u8(q) == 0x80 then ow.poseImgs[lp] = false; return nil end
  local obj, tiles = {}, M.walkerTiles()
  if tiles then
    for k = 1, #tiles do obj[0x1000 + k - 1] = tiles:byte(k) end
  elseif ow.obj then
    for k = 0, 0x7FF do obj[0x1000 + k] = ow.obj[0x1000 + k] end
  else
    return nil
  end
  local img = M.drawList({ obj = obj }, rom, 0x20, lp, 0)
  ow.poseImgs[lp] = img or false
  return img
end

return M
