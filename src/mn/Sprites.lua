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

-- First drawn image of a sequence: $4E steps carry no list, so a sequence that opens
-- with one shows the image of its first list record. $4C/$4F queue their first record's
-- list in the op's own frame (the count is read and .step falls through), so that list
-- is what shows first.
function M.firstImage(seq)
  for _, f in ipairs(seq) do if f.img then return f.img end end
end

-- Full anim sequence: $4C/$4F records (count, b1, b2, list) until a $00
-- count, $4D tables (n, count, b1, b2, n list words), $46 loops back.
-- Returns { {n=frames, dx, dy, list}... }, loops
function M.frames(rom, bank, ptr)
  local o = bank * 0x4000 + ptr - 0x4000
  local out, seen = {}, {}
  for _ = 1, 32 do
    if seen[o] then return out, true end
    seen[o] = true
    local op = rom:u8(o)
    if op == 0x4E then
      -- RepeatTwoScriptBytes ($15AB): count frames of the fine step (b1 -> $C6D2 X,
      -- b2 -> $C6D3 Y) with no new sprite list; a zero count is only the count byte
      local c = rom:u8(o + 1)
      if c == 0 then o = o + 2
      else
        local a, b = rom:u8(o + 2), rom:u8(o + 3)
        if a >= 128 then a = a - 256 end; if b >= 128 then b = b - 256 end
        -- hide: the step queues no sprite list. FinishFrame's HideLeftoverSprites ($0625)
        -- resets wShadowOAMCursor ($C728) every frame and parks the slots nobody rewrote,
        -- and the record callbacks (RunOneScriptThenWriteHead etc.) draw only through the
        -- script's own QueueSpriteList calls, so the object is not drawn on these frames
        out[#out + 1] = { n = c, dx = a, dy = b, hide = true }
        o = o + 4
      end
    elseif op == 0x4C or op == 0x4F then
      local q = o + 1
      while rom:u8(q) ~= 0 and #out < 64 do
        local a, b = rom:u8(q + 1), rom:u8(q + 2)
        if a >= 128 then a = a - 256 end; if b >= 128 then b = b - 256 end
        -- b1/b2 go to $C6D2/$C6D3, the fine X/Y deltas (ApplyFineXThenFineY). PyBoy: Tony's
        -- inn get-up 20:5B0B (FE,F8 / FE,01 / ...) moves him one cell left, 17,5 -> 16,5
        local dx, dy = a, b
        -- $4F (queue_repeated_offset_sprite_list.asm) is different: it clears $C6D2/$C6D3
        -- and adds dx/dy to hObjectCellX/Y itself, then QueueSpriteListAtCell ($0610 ->
        -- $0618) uses those bytes as raw screen X/Y: dx/dy px a frame in screen space,
        -- with no cell window and no wall test. The first step (and its list) is drawn on
        -- the op's own frame, so the first list is the start image.
        out[#out + 1] = { n = rom:u8(q), dx = dx, dy = dy, list = rom:u16(q + 3), screen = op == 0x4F or nil }
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

-- Banks whose $14/$15 anim records the behaviour walker trusts as sprite anims.
local SPRITE_BANKS = { [0x0E] = 1, [0x0F] = 1, [0x10] = 1, [0x11] = 1, [0x20] = 1, [0x25] = 1 }
M.SPRITE_BANKS = SPRITE_BANKS

-- opcode_05.asm: CopyThreeScriptBytesAndHandler stores DispatchScriptOpcode as the
-- record's handler next to the anim field, so the game always runs that field as a
-- script; a "sprite anim" is only a script made of sprite-list ops. The game has no
-- bank test, so the port decides by content: the static frame decoder may stand in
-- for the VM only when every op it would reach is $4C/$4D/$4E/$4F (with $46 jumps)
-- up to a loop or a $42/$94/$12 end. Anything else (25:7211's $5A/$5C/$0B
-- choreography, 11:7039's $47 random pick, 0E:5EA8's $45/$4B, 11:75C8's $48 waits)
-- is a script the VM runs, its sprite ops drawing through host.animAt.
local ANIM_OPS = { [0x4C] = 1, [0x4D] = 1, [0x4E] = 1, [0x4F] = 1 }
local animMemo = setmetatable({}, { __mode = "k" })
function M.isAnim(rom, bank, ptr)
  if not (ptr and ptr >= 0x4000 and ptr < 0x8000) then return false end
  local memo = animMemo[rom]; if not memo then memo = {}; animMemo[rom] = memo end
  local key = bank * 65536 + ptr
  if memo[key] ~= nil then return memo[key] end
  local o, seen, any, res = bank * 0x4000 + ptr - 0x4000, {}, false, nil
  for _ = 1, 256 do
    if seen[o] then res = any; break end
    seen[o] = true
    local op = rom:u8(o)
    if op == 0x46 then o = bank * 0x4000 + rom:u16(o + 1) - 0x4000
    elseif op == 0x42 or op == 0x94 or op == 0x12 then res = any; break
    elseif ANIM_OPS[op] then
      local n = rom:insn(o); if not n then res = false; break end
      any = true; o = o + n
    else res = false; break end
  end
  memo[key] = res or false
  return memo[key]
end

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
  if not M.isAnim(rom, abank, aptr) then
    local b2 = M.behaviour(rom, abank, aptr); beh.talk = beh.talk or b2.talk
    -- the spawn's anim script wins: it is what the object runs first
    if b2.anim then beh.anim, beh.sched = b2.anim, b2.sched or (not b2.anim and beh.sched or nil)
    elseif ANIM_OPS[rom:u8(abank * 0x4000 + aptr - 0x4000)] then
      -- a script that opens on a sprite op shows that list first (0E:5EA8, 11:7596)
      beh.anim, beh.sched = { abank, aptr }, nil
    end
  else beh.anim = beh.anim or { abank, aptr } end
  o.talk = beh.talk; o.anim = beh.anim; o.sched = beh.sched; o.base = base
  if beh.anim then M.build(ow, o) end
  return o
end

-- (Re)build an NPC image from the live OBJ tile memory (map VRAM records plus
-- any $6B glyph copies the entry script made).
function M.build(ow, o)
  -- a $4C-$4F anim (animAt) or a ride head replaces the $15 schedule (sched = nil): drop
  -- its per-record lists too, or tick keeps stepping a schedule that is gone (181 ferry)
  if not o.sched then o.seqs, o.si, o.st = nil, nil, nil end
  if not o.anim then return end
  local rom, vr, base = ow.vm.rom, ow.obj, o.base
  local abank, aptr = o.anim[1], o.anim[2]
  local seq, loops = M.frames(rom, abank, aptr)
  if #seq == 0 then local lp = firstList(rom, abank, aptr); if not lp then return o end; seq = { { n = 1, dx = 0, dy = 0, list = lp } } end
  seq.once = not loops
  o.seq, o.imgs, o.fi, o.ft, o.ox, o.oy, o.spent = seq, o.imgs or {}, 1, 0, o.ox or 0, o.oy or 0, nil
  for _, f in ipairs(seq) do
    if f.list then
      local key = abank * 65536 + f.list
      if not o.imgs[key] then o.imgs[key] = M.drawList(ow, rom, abank, f.list, base) end
      f.img = o.imgs[key]
    end
  end
  o.image = M.firstImage(seq) or o.image
  o.hidden = seq[1].hide or nil
  if o.sched then
    o.seqs, o.si, o.st = {}, 1, 0
    for k, e in ipairs(o.sched) do
      local sq, lo = M.frames(rom, e[1], e[2])
      if #sq == 0 then local lp = firstList(rom, e[1], e[2]); sq = lp and { { n = 1, dx = 0, dy = 0, list = lp } } or seq
      else sq.once = not lo end
      for _, f in ipairs(sq) do
        local key = e[1] * 65536 + (f.list or 0)
        if not f.img and f.list then
          if not o.imgs[key] then o.imgs[key] = M.drawList(ow, rom, e[1], f.list, base) end
          f.img = o.imgs[key]
        end
      end
      o.seqs[k] = sq
    end
    o.seq = o.seqs[1]; o.image = M.firstImage(o.seq) or o.image
    o.hidden = o.seq[1] and o.seq[1].hide or nil
  end
  return o
end

-- Walk gate for script motion: objects enter only open cells ("cell == 0"); the slot-0
-- stand-in walks like the player and may end on a trigger cell ($C0+). A stand-in the
-- scene placed inside a wall is not gated: 180's 2A:5D42 puts Tony at 22,9 and 2A:5DBD
-- hops him over row 10 down to the floor row 11.
function M.walkGate(cell, standIn, fx, fy, x, y)
  local v = cell(x, y)
  if standIn then
    local here = cell(fx, fy)
    if here ~= 0 and here < 0xC0 then return true end
    return v == 0 or v >= 0xC0
  end
  return v == 0
end

-- Animate: advance frame counters at 60 Hz; dx/dy motion accumulates as a
-- pixel offset that snaps to whole 16-px cells (movement scripts).
function M.tick(o, canEnter)
  if o.seq and #o.seq >= 1 then
    local f = o.seq[o.fi]
    -- a list that does not loop back ($46) moves once: 20:5738 (Tony's hop off the 180
    -- ledge, -2..+4 px/frame) ends in a jump to an idle, so the arc must not repeat
    if not o.still and not o.spent then -- $16 walkers animate in place; the scroll carries them
      local nx, ny = o.ox + (f.dx or 0), o.oy + (f.dy or 0)
      -- objects stop at blocked cells (Tavel Gorge kids halt at the cave wall)
      local tx = o.x + (nx >= 16 and 1 or nx <= -16 and -1 or 0)
      local ty = o.y + (ny >= 16 and 1 or ny <= -16 and -1 or 0)
      if (tx ~= o.x or ty ~= o.y) and canEnter and not f.screen and not canEnter(tx, ty) then nx, ny = o.ox, o.oy end
      o.ox, o.oy = nx, ny
    end
    while o.ox >= 16 do o.ox = o.ox - 16; o.x = o.x + 1 end
    while o.ox <= -16 do o.ox = o.ox + 16; o.x = o.x - 1 end
    while o.oy >= 16 do o.oy = o.oy - 16; o.y = o.y + 1 end
    while o.oy <= -16 do o.oy = o.oy + 16; o.y = o.y - 1 end
    o.ft = o.ft + 1
    if o.ft >= math.max(1, f.n) then
      local wasSpent = o.spent
      if o.fi == #o.seq and o.seq.once and #o.seq > 1 then o.spent = true end
      o.ft = 0; o.fi = o.fi % #o.seq + 1; o.image = o.seq[o.fi].img or o.image
      -- a spent one-shot keeps its last frame's visibility (the script has moved on)
      if not o.spent then o.hidden = o.seq[o.fi].hide or nil
      elseif not wasSpent then o.hidden = f.hide or nil end
    end
  end
  -- a $15 record lasts its full frame count, motion included (16 frames of 20:4FB3 at
  -- 1 px = one cell up), so the schedule steps after this frame's motion
  if o.seqs and o.sched then
    o.st = o.st + 1
    -- a script-driven $15 schedule holds its last record (the script goes on, e.g. to a
    -- $5F wait; PyBoy: training-grounds Tony walks 2 cells then idles, 13:58A0); a
    -- statically decoded behaviour loop wraps around like its script's jump back
    local hold = o.driven and o.si == #o.sched
    if #o.sched > 1 and not hold and o.st >= math.max(1, o.sched[o.si][3]) then
      o.st = 0; o.si = o.si % #o.sched + 1; o.seq = o.seqs[o.si]; o.fi, o.ft, o.spent = 1, 0, nil
      o.image = o.seq[1].img or o.image
      o.hidden = o.seq[1].hide or nil
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
