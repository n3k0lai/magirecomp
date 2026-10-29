-- mn.ops.Panels: bank-$4C battle panel / message opcodes.
--
-- FinishFrame ($08BB) runs the seven-byte record at $C71B once a frame
-- (LoadScriptBytes + MapScriptBankAndCall). Battle code in bank 2 plants
-- that record as bank $4C, pointer, handler DispatchScriptOpcode ($0A66),
-- then WaitUntilC71DClears ($05:5A1A) spins until the pointer high byte
-- is zero. The bank holds battle messages, move-effect scripts, and the
-- two screen-setup scripts at $4000 / $4023. It is not the title card or
-- the start menu.
--
-- PlantLimit* / PlantRecord30 store an index limit at $C9EC and a bank-4
-- record pointer at $C9F0, then ResumeScriptDispatch ($11D9) clears the
-- index and the inter-step wait and returns. The script keeps going.
-- StepPlantedRecord ($04:709E) walks that record once a frame from the
-- battle frame loop: three bytes are a delta for $C9C4, a delta for $C9C3
-- (clamped at $71), and the next wait, or a 00 00 00 restart. That walk
-- is a VM thread (one StepPlantedRecord, then coroutine.yield("wait", 1)),
-- the same shape as a $20/$40 countdown except it does not stall the
-- caller. $C9C3/$C9C4 are panel-scroll bytes; nothing here moves a camera.
--
-- $6C/$6D and the screen palette ops ($6E/$6F/$76/$77/$79/$7A/$7B) all
-- work on the palette blocks at $C72B (target) and $C7AB (live). The
-- overworld draws through the live block (mn.LivePalette), so these
-- are the field's fades; nothing else fades the screen.
local bit = require("bit")
local band, rshift, lshift = bit.band, bit.rshift, bit.lshift

local M = { handlers = {} }

local C72B, C7AB = 0xC72B, 0xC7AB
local recordFromId -- defined with $35
local PAL = 8

local function u8(v) return band(v, 0xFF) end

local function off(ptr, bank) return bank * 0x4000 + ptr - 0x4000 end

local function wr16(vm, a, v)
  vm:wr8(a, v)
  vm:wr8(a + 1, rshift(v, 8))
end

local function rd16(vm, a)
  return vm:rd8(a) + lshift(vm:rd8(a + 1), 8)
end

-- hScriptPtr $FFA2, hScriptHandler $FFA4 (reset.asm). Handler $0A66 is
-- DispatchScriptOpcode / INITIAL_SCRIPT_HANDLER.
local function savePtr(vm, ptr) wr16(vm, 0xFFA2, ptr) end

local function plantDispatch(vm) wr16(vm, 0xFFA4, 0x0A66) end

-- wCallback $C6E4 / wCallbackBank $C6E6 = bank 7 $4575 (step_bank7_callback_countdown.asm).
local function plantCallback(vm)
  vm:wr8(0xC6E6, 7)
  vm:wr8(0xC6E4, 0x75)
  vm:wr8(0xC6E5, 0x45)
end

local function frames(vm, n)
  if not vm.init and n > 0 then coroutine.yield("wait", n) end
end

-- SaveScriptPtrAndSplitByte ($1997): low six bits of the byte are the outer
-- count at $FFA7 (a 0 runs 256 times; `dec` of 0 is not zero). High two bits
-- plus one are the inner frame count at $FFA6. The script keeps its pointer
-- on that byte until the outer count expires, so each expiry re-reads it.
-- One yield per inner period, then `each`, matching the handler ret.
local function splitCountdown(vm, split, each)
  local inner = rshift(band(split, 0xC0), 6) + 1
  local outer = band(split, 0x3F)
  if outer == 0 then outer = 256 end
  vm:wr8(0xFFA7, outer)
  vm:wr8(0xFFA6, inner)
  for _ = 1, outer do
    if inner > 1 then frames(vm, inner - 1) end
    vm:wr8(0xFFA6, inner) -- ReloadHighBitsIntoFFA6 ($19AD)
    each()
    local left = u8(vm:rd8(0xFFA7) - 1)
    vm:wr8(0xFFA7, left)
    plantCallback(vm)
    if left == 0 then
      vm:wr8(0xCCA6, 0) -- StepBank7CallbackCountdown ($19E8)
      plantDispatch(vm)
    end
    frames(vm, 1)
  end
end

---------------------------------------------------------------------------
-- GBC color words (0bbbbbgg gggrrrrr). split_color_word.asm / pack_rgb_into_color_word.asm
---------------------------------------------------------------------------

local function splitRgb(w)
  local c, b = band(w, 0xFF), rshift(w, 8)
  local red = band(c, 0x1F)
  local function srlRr(bh, cl)
    return rshift(bh, 1), u8(bit.bor(rshift(cl, 1), lshift(band(bh, 1), 7)))
  end
  b, c = srlRr(b, c)
  b, c = srlRr(b, c)
  c = rshift(c, 3)
  return red, c, b
end

local function packRgb(red, green, blue)
  local function rlca(a)
    a = u8(a)
    return u8(bit.bor(lshift(a, 1), rshift(a, 7)))
  end
  local c = rlca(rlca(rlca(red)))
  local e = green
  for _ = 1, 3 do
    local bit0 = band(e, 1)
    e = rshift(e, 1)
    c = u8(bit.bor(rshift(c, 1), lshift(bit0, 7)))
  end
  local bh = band(blue * 4 + e, 0x7F)
  return c + lshift(bh, 8)
end

-- $C830 counts channel steps, then refills from the low byte of $C9DC.
local function burnCount(vm)
  local c = u8(vm:rd8(0xC830) - 1)
  if c == 0 then vm:wr8(0xC830, vm:rd8(0xC9DC)); return true end
  vm:wr8(0xC830, c)
  return false
end

local function towardZero(vm, red, green, blue)
  repeat
    if red ~= 0 then red = u8(red - 1) end
    if green ~= 0 then green = u8(green - 1) end
    if blue ~= 0 then blue = u8(blue - 1) end
  until burnCount(vm)
  return red, green, blue
end

local function towardWhite(vm, red, green, blue)
  local function up(a) if a < 0x1F then return u8(a + 1) end return a end
  repeat
    red, green, blue = up(red), up(green), up(blue)
  until burnCount(vm)
  return red, green, blue
end

local function towardSaved(vm, red, green, blue)
  local function one(cur, target)
    if cur == target then return cur end
    if cur > target then return u8(cur - 1) end
    return u8(cur + 1)
  end
  repeat
    red = one(red, vm:rd8(0xC82D))
    green = one(green, vm:rd8(0xC82C))
    blue = one(blue, vm:rd8(0xC82B))
  until burnCount(vm)
  return red, green, blue
end

-- StepColorWords ($46E4). `count` words at `addr` walk toward color `de`.
-- $0000/$8000 black, $7FFF/$FFFF white, anything else the split channels.
local function stepColorWords(vm, addr, de, count)
  local d, e = rshift(de, 8), band(de, 0xFF)
  local kind
  if bit.bor(d, 0x80) == 0xFF and e == 0xFF then kind = "white"
  elseif band(d, 0x7F) == 0 and e == 0 then kind = "black"
  else
    kind = "saved"
    local r, g, b = splitRgb(de)
    vm:wr8(0xC82D, r); vm:wr8(0xC82C, g); vm:wr8(0xC82B, b)
  end
  for _ = 1, count do
    local r, g, b = splitRgb(rd16(vm, addr))
    if kind == "black" then r, g, b = towardZero(vm, r, g, b)
    elseif kind == "white" then r, g, b = towardWhite(vm, r, g, b)
    else r, g, b = towardSaved(vm, r, g, b) end
    wr16(vm, addr, packRgb(r, g, b))
    addr = addr + 2
  end
end

-- PanelRowFromHighNibble ($47DD) / PanelQuadFromLowNibble ($47F8).
-- Index byte is $C9D8. Row is $C72B + 8 * high nibble. Word count is
-- 4 * (low nibble + 1).
local function panelGeom(vm)
  local idx = vm:rd8(0xC9D8)
  local row = C72B + lshift(rshift(idx, 4), 3)
  local words = lshift(band(idx, 0x0F) + 1, 2)
  return row, words
end

-- ApplyPanelRowWords.word ($48B6): `words` at `dst` step toward the words at `src`.
local function stepTowardBlock(vm, dst, src, words)
  vm:wr8(0xC9D3, words)
  for _ = 1, words do
    stepColorWords(vm, dst, rd16(vm, src), 1)
    src = src + 2
    dst = dst + 2
  end
  vm:wr8(0xC831, 1)
end

-- ApplyPanelRowWords ($489D): step the block $80 past the panel row toward the row.
local function applyPanelRowWords(vm)
  vm:wr8(0xC831, 0)
  vm:wr8(0xC830, vm:rd8(0xC9DC))
  local row, words = panelGeom(vm)
  stepTowardBlock(vm, row + 0x80, row, words)
end

-- WriteWordAtTwiceEStride8 ($4774): `count` copies of `word` at hl+2*slot, stride 8.
local function writeStride8(vm, base, slot, count, word)
  local a = base + 2 * slot
  for _ = 1, count do
    wr16(vm, a, word)
    a = a + 8
  end
end

-- WriteC9E5WordAtC7ABSlots ($5CE2).
local function writeC9E5Slots(vm)
  vm:wr8(0xC831, 0)
  local w = rd16(vm, 0xC9E5)
  writeStride8(vm, C7AB, 0x00, 2, w)
  writeStride8(vm, C7AB, 0x0C, 2, w)
  writeStride8(vm, C7AB, 0x18, 1, w)
  if vm:rd8(0xC9E2) ~= 0 then writeStride8(vm, C7AB, 0x08, 1, w) end
  if vm:rd8(0xC9E3) ~= 0 then writeStride8(vm, C7AB, 0x14, 1, w) end
  vm:wr8(0xC831, 1)
end

local function copyWordAtC7DB(vm)
  wr16(vm, 0xC9E5, rd16(vm, 0xC7DB))
end

-- StepStagedColorEightyPastRow ($48FD) + StepStagedColorAndCopyC7DB ($5C00).
-- visual: the stepped words are BG palette RAM, not drawn yet.
local function stepStagedColor(vm)
  vm:wr8(0xC831, 0)
  vm:wr8(0xC830, vm:rd8(0xC9DC))
  vm:wr8(0xC9D8, 0x61)
  local row, words = panelGeom(vm)
  stepColorWords(vm, row + 0x80, rd16(vm, 0xC9DA), words)
  vm:wr8(0xC831, 1)
  copyWordAtC7DB(vm)
  writeC9E5Slots(vm)
  vm:wr8(0xC831, 1)
end

-- ApplyPanelRowAndCopyC7DB ($5C29). visual: palette rows, not drawn yet.
local function applyPanelColor(vm)
  vm:wr8(0xC831, 0)
  vm:wr8(0xC830, vm:rd8(0xC9DC))
  vm:wr8(0xC9D8, 0x61)
  applyPanelRowWords(vm)
  copyWordAtC7DB(vm)
  writeC9E5Slots(vm)
  vm:wr8(0xC831, 1)
end

-- ComplementColorWords ($47D1).
local function complementWords(vm, addr, n)
  for _ = 1, n do
    vm:wr8(addr, bit.bxor(vm:rd8(addr), 0xFF))
    vm:wr8(addr + 1, bit.bxor(vm:rd8(addr + 1), 0xFF))
    addr = addr + 2
  end
end

-- ComplementPanelSlotPalettes ($4333). Slot 0 touches palettes 0-2, anything
-- else 3-5. Color 0 of palette 2 / 5 is included when $C9E2 / $C9E3 is zero.
-- visual: complemented BG palettes, not drawn yet.
local function complementPanelSlot(vm)
  vm:wr8(0xC831, 0)
  local slot = vm:rd8(0xC9D9)
  local function pal(i) return C7AB + i * PAL end
  if slot == 0 then
    complementWords(vm, pal(0) + 2, 3)
    complementWords(vm, pal(1) + 2, 3)
    complementWords(vm, pal(2) + 2, 3)
    if vm:rd8(0xC9E2) ~= 0 then vm:wr8(0xC831, 1); return end
    complementWords(vm, pal(2), 1)
  else
    complementWords(vm, pal(3) + 2, 3)
    complementWords(vm, pal(4) + 2, 3)
    complementWords(vm, pal(5) + 2, 3)
    if vm:rd8(0xC9E3) ~= 0 then vm:wr8(0xC831, 1); return end
    complementWords(vm, pal(5), 1)
  end
  vm:wr8(0xC831, 1)
end

-- ComplementColorsEightyPastRow ($48DC). visual: not drawn yet.
local function complementEighty(vm)
  vm:wr8(0xC831, 0)
  local row, words = panelGeom(vm)
  complementWords(vm, row + 0x80, words)
  vm:wr8(0xC831, 1)
end

-- BlendLow/HighSlotPalettes ($43BD / $440D) via DispatchPanelSlotBlend ($41BD).
-- Saved colors at $C7AB walk toward the working colors at $C72B.
-- visual: not drawn yet.
local function blendSlot(vm)
  vm:wr8(0xC831, 0)
  vm:wr8(0xC830, vm:rd8(0xC9DC))
  local function span(saved, work, n) stepTowardBlock(vm, saved, work, n) end
  if vm:rd8(0xC9D9) == 0 then
    span(C7AB + 2, C72B + 2, 3)
    span(C7AB + PAL + 4, C72B + PAL + 4, 3)
    if vm:rd8(0xC9E2) ~= 0 then span(C7AB + 2 * PAL, C72B + 2 * PAL, 4)
    else span(C7AB + 3 * PAL, C72B + 3 * PAL, 3) end
    vm:wr8(0xC831, 1)
  else
    span(C7AB + 3 * PAL + 2, C72B + 3 * PAL + 2, 3)
    vm:wr8(0xC831, 0)
    span(C7AB + 4 * PAL + 2, C72B + 4 * PAL + 2, 3)
    vm:wr8(0xC831, 0)
    if vm:rd8(0xC9E3) == 0 then span(C7AB + 5 * PAL, C72B + 5 * PAL, 4)
    else span(C7AB + 5 * PAL + 2, C72B + 5 * PAL + 2, 3) end
  end
end

---------------------------------------------------------------------------
-- Bank 4 planted record (StepPlantedRecord, $709E)
---------------------------------------------------------------------------

local function stepPlanted(vm)
  local limit, idx = vm:rd8(0xC9EC), vm:rd8(0xC9EB)
  if idx == limit then return end
  if vm:rd8(0xC9EE) ~= vm:rd8(0xC9EF) then
    vm:wr8(0xC9EE, u8(vm:rd8(0xC9EE) + 1))
    return
  end
  vm:wr8(0xC9EE, 0)
  local rec = rd16(vm, 0xC9F0)
  local base = off(rec, 4) + idx
  local d, e = vm.rom:u8(base), vm.rom:u8(base + 1)
  local c = vm.rom:u8(base + 2)
  vm:wr8(0xC9EF, c)
  if c == 0 and e == 0 and d == 0 then
    local rep = vm:rd8(0xC9ED)
    if rep == 0 then
      vm:wr8(0xC9EB, vm.rom:u8(base + 3))
      vm:wr8(0xC9ED, vm.rom:u8(base + 4))
      return
    end
    rep = u8(rep - 1)
    vm:wr8(0xC9ED, rep)
    if rep ~= 0 then vm:wr8(0xC9EB, vm.rom:u8(base + 3)); return end
    vm:wr8(0xC9EB, u8(idx + 5))
    return
  end
  vm:wr8(0xC9C4, u8(vm:rd8(0xC9C4) + d))
  local sum = u8(vm:rd8(0xC9C3) + e)
  if sum >= 0x71 then sum = 0x71 end
  vm:wr8(0xC9C3, sum)
  vm:wr8(0xC9EB, u8(idx + 3))
end

-- ResumeScriptDispatch ($11D9), then a thread that steps once a frame.
local function plantRecord(vm, limit, recPtr, nextPtr)
  vm:wr8(0xC9EC, limit)
  wr16(vm, 0xC9F0, recPtr)
  vm:wr8(0xC9EB, 0)
  vm:wr8(0xC9EE, 0)
  vm:wr8(0xC9EF, 0)
  savePtr(vm, nextPtr)
  plantDispatch(vm)
  if vm.init or vm.loop38 then return end -- inside $38 the loop's ApplyC9BCScrollThenFrame steps it
  vm.threads = vm.threads or {}
  local co = coroutine.create(function()
    while vm:rd8(0xC9EB) ~= vm:rd8(0xC9EC) do
      stepPlanted(vm)
      coroutine.yield("wait", 1)
    end
  end)
  vm.threads.panelRec = { co = co, wait = 0, slot = "panelRec" }
end

-- CopyWordPairs ($2EB6): `count` words from bank:ptr to dest+2*slot.
local function copyWords(vm, bank, ptr, dest, slot, count)
  local o, a = off(ptr, bank), dest + 2 * slot
  for i = 0, count - 1 do
    vm:wr8(a + i * 2, vm.rom:u8(o + i * 2))
    vm:wr8(a + i * 2 + 1, vm.rom:u8(o + i * 2 + 1))
  end
end

-- Replace3DE0AtSlots08And14 ($5D32), then the two stride-8 writes ($5C52).
local function writeC9E5AtC72B(vm)
  local w = rd16(vm, 0xC9E5)
  vm:wr8(0xC9E2, 0)
  vm:wr8(0xC9E3, 0)
  if rd16(vm, C72B + 0x10) == 0x3DE0 then
    vm:wr8(0xC9E2, 1)
    writeStride8(vm, C72B, 0x08, 1, w)
  end
  if rd16(vm, C72B + 0x28) == 0x3DE0 then
    vm:wr8(0xC9E3, 1)
    writeStride8(vm, C72B, 0x14, 1, w)
  end
  writeStride8(vm, C72B, 0x00, 2, w)
  writeStride8(vm, C72B, 0x0C, 2, w)
end

-- CopyTwelveWordPairsThenWriteC9E5 ($358E) / the $0C sibling ($35AD).
-- visual: the VRAM picture those words feed is not drawn yet.
local function copyTwelve(vm, bank, ptr, indexed)
  vm:wr8(0xC831, 0)
  copyWords(vm, bank, ptr, C72B, indexed and 0x0C or 0x00, 12)
  vm:wr8(0xC938, 7)
  writeC9E5AtC72B(vm)
  vm:wr8(0xC831, 1)
end

-- 17 bytes from a bank-4 pointer into the $C9xx entry fields (copy_entry_record_field.asm).
local ENTRY_DEST = {
  0xC9CD, 0xC9CE, 0xC9CF, 0xC9D0, 0xC9D1, 0xC9D2, 0xC9DA, 0xC9DB, 0xC9D8,
  0xC9DC, 0xC9DD, 0xC9D9, 0xC9BE, 0xC9BF, 0xC9D5, 0xC9D6, 0xC9D7,
}

local function copyEntryFields(vm, ptr, n, dest)
  local o = off(ptr, 4)
  for i = 1, n do vm:wr8(dest[i], vm.rom:u8(o + i - 1)) end
end

-- SeedRowMaskAndRecord ($6AFA). Bank 7 $5C9D is still unnamed.
-- visual: that bank-7 call, not run.
local function seedRowMask(vm)
  vm:wr8(0xC9F9, 0xFF)
  vm:wr8(0xC9FB, 0x7A)
  wr16(vm, 0xC9F2, 0x6ABF)
  wr16(vm, 0xC9F6, 0x9000)
  vm:wr8(0xC9F8, 1)
  wr16(vm, 0xC9F0, 0x6CB4)
  vm:wr8(0xC9EC, 0xA8)
  vm:wr8(0xC9EB, 0)
  vm:wr8(0xC9EE, 0)
  vm:wr8(0xC938, 4)
end

-- StepScrollByScriptPair ($715B). $C9EA == 0 steps $C9BC down by $C9E9
-- (floor 0); nonzero steps it up (cap $60).
local function stepScroll(vm)
  local dir, step, cur = vm:rd8(0xC9EA), vm:rd8(0xC9E9), vm:rd8(0xC9BC)
  if dir == 0 then
    if cur == 0 then return end
    -- cpl/inc/add: carry means the 8-bit difference stayed non-negative.
    -- A zero step does not set carry, so the scroll byte becomes 0.
    local sum = cur + u8(bit.bnot(step) + 1)
    vm:wr8(0xC9BC, sum >= 0x100 and u8(sum) or 0)
  else
    if cur == 0x60 then return end
    local sum = u8(cur + step)
    if sum >= 0x60 then sum = 0x60 end
    vm:wr8(0xC9BC, sum)
  end
end

-- CopyNextScriptWordOrC9E5 ($19B9). Bit 7 of the high byte selects $C9E5.
local function takeColorWord(vm, lo, hi)
  if band(hi, 0x80) ~= 0 then lo, hi = vm:rd8(0xC9E5), vm:rd8(0xC9E6) end
  vm:wr8(0xC9DA, lo)
  vm:wr8(0xC9DB, hi)
end

---------------------------------------------------------------------------
-- opcodes
---------------------------------------------------------------------------

-- FillPointedRecord0C5F ($169B): pointer, then five payload bytes. The
-- record's first byte stays. Bytes +1,+2 become $0C $5F. Two script bytes,
-- a gap, one script byte, then CopyThreeScriptBytesAndHandler ($0AA2) and
-- StoreScriptPair0214 ($0AB4).
M.handlers[0x50] = function(vm, o, n)
  local dest = vm.rom:u16(o + 1)
  local function put(i, v) vm:wr8(dest + i, v) end
  put(1, 0x0C); put(2, 0x5F)
  put(5, vm.rom:u8(o + 3)); put(6, vm.rom:u8(o + 4))
  put(9, vm.rom:u8(o + 5))
  put(10, vm.rom:u8(o + 6)); put(11, vm.rom:u8(o + 7)); put(12, vm.rom:u8(o + 8))
  put(13, 0x66); put(14, 0x0A)
  put(20, 0x02); put(21, 0x14)
  return o + n
end

local function limitOp(limit, rec)
  return function(vm, o, n, cur)
    plantRecord(vm, limit, rec, cur.ptr + n)
    return o + n
  end
end

-- PlantRecord30 ($1049) and the PlantLimit family ($1151, $1162, $11A8, $11B9, $11CA).
M.handlers[0x33] = limitOp(0x30, 0x6BDC)
M.handlers[0x3A] = limitOp(0x30, 0x6C0C)
M.handlers[0x3B] = limitOp(0x24, 0x6C3C)
M.handlers[0x3D] = limitOp(0x54, 0x6C60)
M.handlers[0x3E] = limitOp(0xA8, 0x6CB4)
M.handlers[0x3F] = limitOp(0x1D, 0x6D5C)

-- StageC9E4ThenCall704B ($105B). $C9E4 is restored after ApplyC9E4TableEntry.
-- Bank 0 $3493, which draws the copied fields, is still unnamed.
-- visual: entry-field VRAM, not drawn yet.
M.handlers[0x34] = function(vm, o, n)
  local saved = vm:rd8(0xC9E4)
  local idx = vm.rom:u8(o + 1)
  vm:wr8(0xC9E4, idx)
  vm:wr8(0xC938, 4)
  plantDispatch(vm)
  local ptr = vm.rom:u16(off(0x6F2B, 4) + idx * 2) -- TableWordForC9E4 ($6FAB)
  wr16(vm, 0xC9DE, ptr)
  copyEntryFields(vm, ptr, 17, ENTRY_DEST)
  vm:wr8(0xC9E4, saved)
  frames(vm, 1) -- INITIAL_SCRIPT_HANDLER planted, then ret: the next op runs next pass
  return o + n
end

-- RecordPtrFromId ($04:7029) then CopyEntryRecordFieldEleven ($04:7069): the record
-- for `id` is $415B + $2D * id; eleven bytes from its +$1E field go to $C9CD-$C9D7.
local ELEVEN = {}
for i = 0, 10 do ELEVEN[i + 1] = 0xC9CD + i end
recordFromId = function(vm, id)
  local base = band(0x415B + id * 0x2D, 0xFFFF)
  local field = band(base + 0x1E, 0xFFFF)
  wr16(vm, 0xC9DC, base)
  wr16(vm, 0xC9DE, field)
  copyEntryFields(vm, field, 11, ELEVEN)
end

-- StageC9D8ThenCall7055 ($1088). RecordPtrFromId ($7029) then eleven bytes
-- from the record's +$1E field. Bank 0 $338D / $340B draw that.
-- visual: entry-field VRAM, not drawn yet.
M.handlers[0x35] = function(vm, o, n, cur)
  local id = vm.rom:u8(o + 1)
  vm:wr8(0xC9D8, id)
  savePtr(vm, cur.ptr + n)
  plantDispatch(vm)
  vm:wr8(0xC9D9, 0)
  vm:wr8(0xC938, 4)
  recordFromId(vm, id)
  frames(vm, 1) -- INITIAL_SCRIPT_HANDLER planted, then ret: the next op runs next pass
  return o + n
end

-- PlantC9FA08AndPtr6DE9 ($11F6) / PlantC9FA10AndPtr6DF9 ($1207), then the
-- $1216 tail (CopyBCPlantHandlerCall6AFA) which calls SeedRowMaskAndRecord.
local function plantC9FA(tag, rec)
  return function(vm, o, n, cur)
    vm:wr8(0xC9FA, tag)
    wr16(vm, 0xC9F4, rec)
    savePtr(vm, cur.ptr + n)
    plantDispatch(vm)
    seedRowMask(vm)
    return o + n
  end
end
M.handlers[0x36] = plantC9FA(0x08, 0x6DE9)
M.handlers[0x37] = plantC9FA(0x10, 0x6DF9)

-- ScriptCountdownCall715B ($1173). The third byte is a frame count. Each
-- expiry steps $C9BC and returns; zero falls into DispatchScriptOpcode.
M.handlers[0x3C] = function(vm, o, n, cur)
  vm:wr8(0xC9EA, vm.rom:u8(o + 1))
  vm:wr8(0xC9E9, vm.rom:u8(o + 2))
  local count = vm.rom:u8(o + 3)
  vm:wr8(0xFFA6, count)
  savePtr(vm, cur.ptr + n)
  while count ~= 0 do
    count = u8(count - 1)
    vm:wr8(0xFFA6, count)
    vm:wr8(0xC938, 4)
    stepScroll(vm)
    frames(vm, 1)
  end
  plantDispatch(vm)
  return o + n
end

-- StageColorWordThenCall5C00 ($1A16). visual: palette step, not drawn yet.
M.handlers[0x6C] = function(vm, o, n, cur)
  splitCountdown(vm, vm.rom:u8(o + 1), function()
    takeColorWord(vm, vm.rom:u8(o + 2), vm.rom:u8(o + 3))
    vm:wr8(0xC9DC, 1)
    vm:wr8(0xC938, 7)
    stepStagedColor(vm)
  end)
  savePtr(vm, cur.ptr + n)
  return o + n
end

-- Call5C29AfterCountdown ($1A44). Same split-byte wait, no color word.
-- visual: panel-row palette step, not drawn yet.
M.handlers[0x6D] = function(vm, o, n, cur)
  splitCountdown(vm, vm.rom:u8(o + 1), function()
    vm:wr8(0xC9DC, 1)
    vm:wr8(0xC938, 7)
    applyPanelColor(vm)
  end)
  savePtr(vm, cur.ptr + n)
  return o + n
end

---------------------------------------------------------------------------
-- Screen palette ops. $C72B is the target block (8 BG then 8 OBJ
-- palettes, 4 words each). $C7AB, $80 past it, is the live block that
-- RefreshSavedPalettes (bank 7 $4575, the planted callback) copies to
-- the hardware: BG at $C7AB, OBJ at $C7EB. The index byte at $C9D8 picks
-- the rows: $07 is the eight BG palettes, $0F all sixteen, $87 the OBJ
-- eight, $F0 the last OBJ palette. There is no fixed fade length. A fade
-- is a split-byte countdown ($76/$77/$7A) that moves every 5-bit channel
-- one step per tick, so N ticks of P frames (see splitCountdown).
---------------------------------------------------------------------------

-- FillPanelWordsFromC9DA ($07:4850) and FillPanelWordsEightyPastRow
-- ($07:4837): every word of the rows becomes the word at $C9DA.
local function fillRows(vm, eighty)
  vm:wr8(0xC831, 0)
  local row, words = panelGeom(vm)
  if eighty then row = row + 0x80 end
  local w = rd16(vm, 0xC9DA)
  for i = 0, words - 1 do wr16(vm, row + 2 * i, w) end
  vm:wr8(0xC831, 1)
end

-- RunPanelIndexThrough2EB6 ($07:481E): CopyWordPairs from the target
-- rows into the live rows.
local function copyRowsLive(vm)
  vm:wr8(0xC831, 0)
  local row, words = panelGeom(vm)
  for i = 0, words - 1 do wr16(vm, row + 0x80 + 2 * i, rd16(vm, row + 2 * i)) end
  vm:wr8(0xC831, 1)
end
M.copyRowsLive = copyRowsLive

-- RotatePaletteColors ($07:45B2). A=4 rotates all four colors up one
-- (c0 c1 c2 c3 -> c3 c0 c1 c2). A=3 rotates colors 1-3 the same way.
-- Anything else swaps colors 2 and 3.
local function rotatePalette(vm, base, mode)
  local c = {}
  for i = 0, 3 do c[i] = rd16(vm, base + 2 * i) end
  local n
  if mode == 4 then n = { [0] = c[3], c[0], c[1], c[2] }
  elseif mode == 3 then n = { [0] = c[0], c[3], c[1], c[2] }
  else n = { [0] = c[0], c[1], c[3], c[2] } end
  for i = 0, 3 do wr16(vm, base + 2 * i, n[i]) end
end
M.rotatePalette = rotatePalette

-- RotatePalettesEightyPastRow ($07:4870): low nibble + 1 palettes of the
-- live rows, last palette first, mode from $C9D9.
local function rotateRows(vm)
  vm:wr8(0xC831, 0)
  local idx = vm:rd8(0xC9D8)
  local row = C72B + lshift(rshift(idx, 4), 3) + 0x80
  local count = band(idx, 0x0F) + 1
  for e = count - 1, 0, -1 do
    vm:wr8(0xC9DA, e)
    rotatePalette(vm, row + 8 * e, vm:rd8(0xC9D9))
  end
  vm:wr8(0xC9DA, 0)
  vm:wr8(0xC831, 1)
end

-- StageScriptByteWordThenCall4850 ($1A6F): target rows only, no callback.
M.handlers[0x6E] = function(vm, o, n, cur)
  vm:wr8(0xC9D8, vm.rom:u8(o + 1))
  takeColorWord(vm, vm.rom:u8(o + 2), vm.rom:u8(o + 3))
  savePtr(vm, cur.ptr + n)
  vm:wr8(0xC938, 7)
  fillRows(vm, false)
  plantDispatch(vm)
  frames(vm, 1)
  return o + n
end

-- StageScriptByteWordThenCall4837 ($1A88): live rows, then the callback
-- uploads them. An instant palette set.
M.handlers[0x6F] = function(vm, o, n, cur)
  vm:wr8(0xC9D8, vm.rom:u8(o + 1))
  takeColorWord(vm, vm.rom:u8(o + 2), vm.rom:u8(o + 3))
  savePtr(vm, cur.ptr + n)
  vm:wr8(0xC938, 7)
  fillRows(vm, true)
  plantCallback(vm)
  plantDispatch(vm)
  frames(vm, 1)
  return o + n
end

-- SetCCA6Countdown1C17 ($1C05): each tick, $C9D8 from the second byte,
-- $C9DC = 1, ApplyPanelRowWords: live rows step toward the target rows.
M.handlers[0x76] = function(vm, o, n, cur)
  vm:wr8(0xCCA6, 1)
  splitCountdown(vm, vm.rom:u8(o + 1), function()
    vm:wr8(0xC9D8, vm.rom:u8(o + 2))
    vm:wr8(0xC9DC, 1)
    vm:wr8(0xC938, 7)
    applyPanelRowWords(vm)
  end)
  savePtr(vm, cur.ptr + n)
  return o + n
end

-- SetCCA6Countdown1C4A ($1C38): each tick, $C9D8 and the color word, then
-- StepStagedColorEightyPastRow ($07:48FD): live rows step toward that one
-- word. $C830 is not reloaded first; the stepper carries it.
M.handlers[0x77] = function(vm, o, n, cur)
  vm:wr8(0xCCA6, 1)
  splitCountdown(vm, vm.rom:u8(o + 1), function()
    vm:wr8(0xC9D8, vm.rom:u8(o + 2))
    takeColorWord(vm, vm.rom:u8(o + 3), vm.rom:u8(o + 4))
    vm:wr8(0xC9DC, 1)
    vm:wr8(0xC938, 7)
    vm:wr8(0xC831, 0)
    local row, words = panelGeom(vm)
    stepColorWords(vm, row + 0x80, rd16(vm, 0xC9DA), words)
    vm:wr8(0xC831, 1)
  end)
  savePtr(vm, cur.ptr + n)
  return o + n
end

-- SetCCA6Countdown1BE4 ($1BD2): each tick, $C9D8 and $C9D9, then
-- RotatePalettesEightyPastRow.
M.handlers[0x7A] = function(vm, o, n, cur)
  vm:wr8(0xCCA6, 1)
  splitCountdown(vm, vm.rom:u8(o + 1), function()
    vm:wr8(0xC9D8, vm.rom:u8(o + 2))
    vm:wr8(0xC9D9, vm.rom:u8(o + 3))
    vm:wr8(0xC938, 7)
    rotateRows(vm)
  end)
  savePtr(vm, cur.ptr + n)
  return o + n
end

-- StoreScriptByteCall481E ($1CCA): target rows copied live, then uploaded.
M.handlers[0x79] = function(vm, o, n, cur)
  vm:wr8(0xC9D8, vm.rom:u8(o + 1))
  savePtr(vm, cur.ptr + n)
  vm:wr8(0xC938, 7)
  copyRowsLive(vm)
  plantCallback(vm)
  plantDispatch(vm)
  frames(vm, 1)
  return o + n
end

-- FillC72BFromBCThenBank7 ($2EC3) / FillC76BFromBCThenOBJPalettes
-- ($2EE9): 32 words into the BG ($07) or OBJ ($87) target rows, then
-- copied live and uploaded. `words` is a 0-based array of 32 RGB555 words.
function M.loadPalettes(vm, words, obj)
  local base = obj and C72B + 0x40 or C72B
  for i = 0, 31 do wr16(vm, base + 2 * i, words[i]) end
  vm:wr8(0xC9D8, obj and 0x87 or 0x07)
  copyRowsLive(vm)
end

-- Slot palettes: $C9D9 zero picks BG palettes 0-2, nonzero 3-5. These are
-- the map's animated colors (water, lava, glow): the field scripts run
-- $70 in a loop.

-- CyclePanelSlotPaletteColors ($07:416B): colors 1-3 of each of the three
-- live palettes rotate (mode 3).
local function cycleSlot(vm)
  vm:wr8(0xC831, 0)
  local first = vm:rd8(0xC9D9) == 0 and 0 or 3
  for p = first, first + 2 do rotatePalette(vm, C7AB + PAL * p, 3) end
  vm:wr8(0xC831, 1)
end
M.cycleSlot = cycleSlot

-- StepSlotPalettes ($07:41CB): colors 1-3 of the three live palettes step
-- toward the word at $C9DA. Color 0 of the last one steps too unless
-- $C9E2 (low) or $C9E3 (high) is set.
local function stepSlot(vm)
  vm:wr8(0xC831, 0)
  vm:wr8(0xC830, vm:rd8(0xC9DC))
  local de = rd16(vm, 0xC9DA)
  local high = vm:rd8(0xC9D9) ~= 0
  local first = high and 3 or 0
  for p = first, first + 2 do stepColorWords(vm, C7AB + PAL * p + 2, de, 3) end
  if vm:rd8(high and 0xC9E3 or 0xC9E2) == 0 then
    stepColorWords(vm, C7AB + PAL * (first + 2), rd16(vm, 0xC9DA), 1)
  end
  vm:wr8(0xC831, 1)
end

-- PermuteColorChannels ($07:4787) on one word, mode in E ($C9D8).
-- 1 swaps red and blue, 2 green and blue. 3 swaps red and green and then
-- falls through into the red/blue swap ($47B8 has no jump), so it is
-- (r,g,b) -> (b,r,g). Anything else is (r,g,b) -> (g,b,r).
local function permuteWord(w, mode)
  local r, g, b = splitRgb(w)
  if mode == 1 then r, b = b, r
  elseif mode == 2 then g, b = b, g
  elseif mode == 3 then
    r, g = g, r
    w = packRgb(r, g, b)
    r, g, b = splitRgb(w)
    r, b = b, r
  else r, g, b = g, b, r end
  return packRgb(r, g, b)
end
M.permuteWord = permuteWord

-- PermutePanelPaletteChannels ($07:42E3): colors 1-3 of the three live palettes.
local function permuteSlot(vm)
  vm:wr8(0xC831, 0)
  local mode = vm:rd8(0xC9D8)
  local first = vm:rd8(0xC9D9) == 0 and 0 or 3
  for p = first, first + 2 do
    for c = 1, 3 do
      local a = C7AB + PAL * p + 2 * c
      wr16(vm, a, permuteWord(rd16(vm, a), mode))
    end
  end
  vm:wr8(0xC831, 1)
end

-- StorePanelSlotThenCall416B ($1AB0): split byte, slot.
M.handlers[0x70] = function(vm, o, n, cur)
  splitCountdown(vm, vm.rom:u8(o + 1), function()
    vm:wr8(0xC9D9, vm.rom:u8(o + 2))
    vm:wr8(0xC938, 7)
    cycleSlot(vm)
  end)
  savePtr(vm, cur.ptr + n)
  return o + n
end

-- ArmCountdown1AE8AndDecFFA6 ($1ADB): split byte, color word, slot.
M.handlers[0x71] = function(vm, o, n, cur)
  splitCountdown(vm, vm.rom:u8(o + 1), function()
    takeColorWord(vm, vm.rom:u8(o + 2), vm.rom:u8(o + 3))
    vm:wr8(0xC9D9, vm.rom:u8(o + 4))
    vm:wr8(0xC9DC, 1)
    vm:wr8(0xC938, 7)
    stepSlot(vm)
  end)
  savePtr(vm, cur.ptr + n)
  return o + n
end

-- SetCountdownHandler1B7D ($1B70): split byte, mode ($C9D8), slot ($C9D9).
M.handlers[0x74] = function(vm, o, n, cur)
  splitCountdown(vm, vm.rom:u8(o + 1), function()
    vm:wr8(0xC9D8, vm.rom:u8(o + 2))
    vm:wr8(0xC9D9, vm.rom:u8(o + 3))
    vm:wr8(0xC938, 7)
    permuteSlot(vm)
  end)
  savePtr(vm, cur.ptr + n)
  return o + n
end

-- ArmCountdownHandlerAndDecFFA6 ($1B0E). At zero it falls into
-- StorePanelSlotCall41BD ($1B21), which blends and then joins the
-- bank-7 countdown tail. visual: the blend, not drawn yet.
M.handlers[0x72] = function(vm, o, n, cur)
  splitCountdown(vm, vm.rom:u8(o + 1), function()
    vm:wr8(0xC9D9, vm.rom:u8(o + 2))
    vm:wr8(0xC9DC, 1)
    vm:wr8(0xC938, 7)
    blendSlot(vm)
  end)
  savePtr(vm, cur.ptr + n)
  return o + n
end

---------------------------------------------------------------------------
-- $38 InstallScriptRecordLoopBank4 ($10AF) and $39 StageHandler1126 ($110C)
---------------------------------------------------------------------------

-- SeedScriptScrollAndRecord ($04:72ED).
local function seedScrollAndRecord(vm)
  for _, a in ipairs({ 0xC9BC, 0xC9C2, 0xC9C4, 0xC9C0, 0xC9C1, 0xC9C7, 0xC9EC, 0xC9EB,
    0xC9EF, 0xC9EE, 0xC9FB, 0xC9FA, 0xC9F9 }) do vm:wr8(a, 0) end
  vm:wr8(0xC9BD, 0x58)
  vm:wr8(0xC9C3, 0x20)
  wr16(vm, 0xC9F0, 0x6C60)
  wr16(vm, 0xC9F2, 0x6AF9)
  wr16(vm, 0xC9F4, 0x6DF9)
  wr16(vm, 0xC9F6, 0x9000)
  vm:wr8(0xC9F8, 0x04)
end

-- ApplyC9E4TableEntry (bank 4 $704B, as $34): table word at $6F2B + 2 * [$C9E4] into
-- $C9DE, seventeen bytes from it into the entry fields.
local function applyC9E4Entry(vm)
  local ptr = vm.rom:u16(off(0x6F2B, 4) + vm:rd8(0xC9E4) * 2)
  wr16(vm, 0xC9DE, ptr)
  copyEntryFields(vm, ptr, 17, ENTRY_DEST)
end

-- FillPanelWordsEightyPastRow ($07:4837) with $C9D8 / $C9DA already staged, then
-- RefreshSavedPalettes ($07:4575): the palettes go out and wCallback becomes IdleCallback.
local function fillEightyThenRefresh(vm)
  vm:wr8(0xC831, 0)
  local row, words = panelGeom(vm)
  local w = rd16(vm, 0xC9DA)
  for i = 0, words - 1 do wr16(vm, row + 0x80 + 2 * i, w) end
  vm:wr8(0xC831, 1)
  wr16(vm, 0xC6E4, 0x29A4)
end

-- ScaleEByDIntoC9C0 ($04:73AA): (E sra 2) * D, low byte, plus E. The negate path is dead
-- (`cp $00` never sets carry).
local function scaleE(e, d)
  local c = e >= 0x80 and u8(rshift(e, 2) + 0xC0) or rshift(e, 2)
  return u8(e + band(c * d, 0xFF))
end

-- ApplyC9BCScrollThenFrame ($04:734D), minus the VBlank / ArmPanelCallback plumbing and
-- FinishFrame (the VM runs the record).
local function applyScroll(vm)
  local bc = band(vm:rd8(0xC9BC), 0x7F)
  vm:wr8(0xC9BC, bc)
  vm:wr8(0xC9C0, scaleE(bc, vm:rd8(0xC9BE)))
  vm:wr8(0xC9C1, scaleE(bc, vm:rd8(0xC9BF)))
  stepPlanted(vm)
  -- $73AA leaves E alone, so this is $87 - $C9BC
  vm:wr8(0xC9C2, u8(vm:rd8(0xC9C4) + u8(0x87 - bc)))
  vm:wr8(0xC935, bc) -- wCameraPixelX
  local h = vm.host
  if h and h.panelScroll then h.panelScroll(bc, vm:rd8(0xC9C2)) end
end

-- ScriptLoopBPanelFrames ($04:72B4): fill row 0 (C9D8 = 7, 32 words) with white, then
-- eight passes of ApplyPanelRowWords at four units a pass plus a frame.
local function bPanelFrames(vm)
  vm:wr8(0xC9DE, 8)
  vm:wr8(0xC9D8, 7)
  wr16(vm, 0xC9DA, 0x7FFF)
  local row, words = panelGeom(vm) -- FillPanelWordsFromC9DA fills the row itself
  for i = 0, words - 1 do wr16(vm, row + 2 * i, 0x7FFF) end
  vm:wr8(0xC831, 1)
  vm:wr8(0xC9DC, 4)
  repeat
    applyPanelRowWords(vm)
    applyScroll(vm)
    coroutine.yield("wait", 1)
    vm:wr8(0xC9DE, u8(vm:rd8(0xC9DE) - 1))
  until vm:rd8(0xC9DE) == 0
end

-- The `.bank4` loop after InstallScriptRecordLoopBank4. It never returns: the record it
-- runs leaves through FinishStartup / ReenterReset, which reset the stack. Gate $C9C6
-- (set only by the battle entry StagePointerUnlessD0B6Matches, cleared at boot and by B):
-- B runs the eight white frames, points the record's handler at $1402 (parked after
-- opcode $12) with pointer high byte 0, and clears the gate; Start toggles $C9C7, and
-- while it is 1 the frame skips FinishFrame, so the record does not run.
local function loopThread(vm)
  return coroutine.create(function()
    while vm.loop38 do
      local h = vm.host
      if vm:rd8(0xC9C6) ~= 0 and h and h.buttonPressed then
        if h.buttonPressed("b") then
          bPanelFrames(vm)
          vm:wr8(0xC706 + 3, 0x02); vm:wr8(0xC706 + 4, 0x14); vm:wr8(0xC706 + 2, 0)
          vm:wr8(0xC9C6, 0)
          vm.co = nil -- the record is parked: nothing runs it again
        elseif h.buttonPressed("start") then
          vm:wr8(0xC9C7, vm:rd8(0xC9C7) == 0 and 1 or 0)
        end
      end
      applyScroll(vm)
      coroutine.yield("wait", 1)
    end
  end)
end

M.handlers[0x38] = function(vm, o, n, cur)
  vm:wr8(0xC9E4, vm.rom:u8(o + 1))
  vm:wr8(0xC9E0, vm.rom:u8(o + 2))
  vm:wr8(0xC9E1, vm.rom:u8(o + 3))
  vm:wr8(0xC9C5, 1)
  savePtr(vm, cur.ptr + n)
  wr16(vm, 0xFF9F, 0xC706)
  plantDispatch(vm)
  -- CopyScriptBytes: bank, pointer, handler, $FFA6, $FFA7 into wScriptRecord
  local rec = { cur.bank, band(cur.ptr + n, 0xFF), rshift(cur.ptr + n, 8), 0x66, 0x0A,
    vm:rd8(0xFFA6), vm:rd8(0xFFA7) }
  for i = 1, 7 do vm:wr8(0xC706 + i - 1, rec[i]) end
  vm:wr8(0xC938, 4)
  -- PresentInstalledScriptEntries ($04:722E)
  vm:wr8(0xC728, 0); vm:wr8(0xC729, 0)
  local h = vm.host
  if h and h.parkSprites then h.parkSprites() end
  vm:wr8(0xC9C5, 0); vm:wr8(0xC9C8, 0); vm:wr8(0xC831, 0)
  seedScrollAndRecord(vm)
  vm:wr8(0xC834, 0); vm:wr8(0xC835, 0); vm:wr8(0xC832, 0); vm:wr8(0xC833, 0x24)
  applyC9E4Entry(vm)
  vm:wr8(0xC9D8, vm:rd8(0xC9E0)); vm:wr8(0xC9D9, 0); recordFromId(vm, vm:rd8(0xC9E0))
  vm:wr8(0xC9D8, vm:rd8(0xC9E1)); vm:wr8(0xC9D9, 1); recordFromId(vm, vm:rd8(0xC9E1))
  vm:wr8(0xC9D8, 7)
  wr16(vm, 0xC9DA, 0x7FFF)
  fillEightyThenRefresh(vm)
  if h and h.scriptLoop38 then h.scriptLoop38(vm:rd8(0xC9E4), vm:rd8(0xC9E0), vm:rd8(0xC9E1)) end
  -- RunScriptRecord runs the next op this frame; the loop owns every later frame.
  if not vm.init then
    vm.loop38 = true
    vm.threads = vm.threads or {}
    vm.threads.loop38 = { co = loopThread(vm), wait = 1, slot = "loop38" }
  end
  return o + n
end

-- a bank-4 pair table may sit in ROM bank 0, bank 4 or RAM
local function rd4(vm, a)
  if a < 0x4000 then return vm.rom:u8(a) end
  if a < 0x8000 then return vm.rom:u8(off(a, 4)) end
  return vm:rd8(a)
end

-- $39 StageHandler1126: $FFA7 = 1, $FFA6 = 0, handler $1126 from the next frame.
-- ScriptHandler1126 re-reads the three bytes each frame ($C9EA direction, $C9E7/8 pair
-- table) and runs StepScriptPairCountdown ($04:711C): pair 0 applies once, every later
-- pair `first` times with $C9E9 = `second` through StepScrollByScriptPair; a zero
-- `first` plants the dispatcher with the pointer past the three bytes.
M.handlers[0x39] = function(vm, o, n, cur)
  vm:wr8(0xFFA7, 1)
  vm:wr8(0xFFA6, 0)
  wr16(vm, 0xFFA4, 0x1126)
  savePtr(vm, cur.ptr + 1)
  local guard = 0
  while guard < 0x10000 do
    guard = guard + 1
    frames(vm, 1)
    vm:wr8(0xC9EA, vm.rom:u8(o + 1))
    vm:wr8(0xC9E7, vm.rom:u8(o + 2))
    vm:wr8(0xC9E8, vm.rom:u8(o + 3))
    vm:wr8(0xC938, 4)
    local p = band(rd16(vm, 0xC9E7) + 2 * vm:rd8(0xFFA6), 0xFFFF)
    local count = vm:rd8(0xFFA7)
    if count == 0 then
      vm:wr8(0xFFA6, u8(vm:rd8(0xFFA6) + 1))
      p = band(p + 2, 0xFFFF)
      count = rd4(vm, p)
      if count == 0 then
        savePtr(vm, cur.ptr + n)
        plantDispatch(vm)
        break
      end
    end
    vm:wr8(0xFFA7, u8(count - 1))
    vm:wr8(0xC9E9, rd4(vm, band(p + 1, 0xFFFF)))
    stepScroll(vm)
    if vm.init then break end
  end
  frames(vm, 1)
  return o + n
end

-- StagePairPtrPanelThenCall35F1 ($1B3E). Slot 0 copies twelve words at
-- $C72B; a nonzero slot copies them $18 bytes later. visual: not drawn yet.
M.handlers[0x73] = function(vm, o, n, cur)
  local ptr = vm.rom:u16(o + 1)
  local bank, slot = vm.rom:u8(o + 3), vm.rom:u8(o + 4)
  wr16(vm, 0xC9D5, ptr)
  vm:wr8(0xC9D7, bank)
  vm:wr8(0xC9D9, slot)
  savePtr(vm, cur.ptr + n)
  vm:wr8(0xC938, 0)
  copyTwelve(vm, bank, ptr, slot ~= 0)
  vm:wr8(0xC938, 0) -- MapPairBankThenCopyTwelveWordPairs restores the bank
  plantDispatch(vm)
  frames(vm, 1)
  return o + n
end

-- StorePanelSlotCall4333 ($1BA0). visual: complemented palettes, not drawn yet.
M.handlers[0x75] = function(vm, o, n, cur)
  vm:wr8(0xC9D9, vm.rom:u8(o + 1))
  savePtr(vm, cur.ptr + n)
  vm:wr8(0xC938, 7)
  complementPanelSlot(vm)
  plantCallback(vm)
  plantDispatch(vm)
  frames(vm, 1)
  return o + n
end

-- StoreScriptByteCall48DC ($1CFA). visual: complemented row, not drawn yet.
M.handlers[0x7B] = function(vm, o, n, cur)
  vm:wr8(0xC9D8, vm.rom:u8(o + 1))
  savePtr(vm, cur.ptr + n)
  vm:wr8(0xC938, 7)
  complementEighty(vm)
  plantCallback(vm)
  plantDispatch(vm)
  frames(vm, 1)
  return o + n
end

-- CallScriptBank40B7 ($27C0). The callee is whatever sits at $40B7 in the
-- script bank. In bank 7 that is IncrementSramScriptWord ($40B7): the
-- little-endian word at $A123 increments and the two $7F flag runs are
-- cleared (ClearSramAfterScriptWord, $40E6). No other bank's $40B7 is that
-- routine; those calls are left alone.
M.handlers[0xA8] = function(vm, o, n, cur)
  if cur.bank == 7 then
    local w = u8(vm:rd8(0xA123) + 1)
    local hi = vm:rd8(0xA124)
    if vm:rd8(0xA123) == 0xFF then hi = u8(hi + 1) end
    vm:wr8(0xA123, w)
    vm:wr8(0xA124, hi)
    for a = 0xA125, 0xA125 + 0x7E do vm:wr8(a, 0) end
    for a = 0xA224, 0xA224 + 0x7E do vm:wr8(a, 0) end
  end
  plantDispatch(vm)
  return o + n
end

return M
