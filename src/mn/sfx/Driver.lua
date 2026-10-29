-- Bank $30 sound driver, SFX side. Addresses and routine names follow the
-- decomp (update_sound.asm, run_sound_stream.asm, open_slot_channel.asm,
-- the sound_command_*.asm handlers). Stream bytes and the period / nibble
-- tables are read from the ROM; nothing from them is stored here.
local bit = require("bit")
local band, bor, bxor, rshift, lshift = bit.band, bit.bor, bit.bxor, bit.rshift, bit.lshift

local D = {}

local function rd(s, a) return s:rd(a) end
local function wr(s, a, v) s:wr(a, v) end
local function r16(s, a) return s:r16(a) end
local function w16(s, a, v) s:w16(a, v) end
local function rom(s, a) return s:rom8(a) end

local function add16(a, b) return (a + b) % 65536 end
local function sub16(a, b) return (a - b) % 65536 end

-- Channel n's NR51 terminals: left is bit n+4, right is bit n.
-- ChannelOwnMasks / ChannelNr51ClearMask / the pan bytes at $46DE are
-- those bits (open_channel_for_tag.asm, restart_channel.asm,
-- update_channel_output_mask.asm).
local function term(ch) return bor(lshift(1, ch), lshift(1, ch + 4)) end
local function clearMask(ch) return band(bxor(0xFF, term(ch)), 0xFF) end
local function panByte(ch, op)
  local l, r = lshift(1, ch + 4), lshift(1, ch)
  if op == 0 then return l elseif op == 1 then return bor(l, r) else return r end
end

-- WriteChannelEnvelope's NR32 level codes (unk_0c10da.asm): mute, full,
-- half, quarter in bits 6-5.
local WAVE_LEVEL = { [0] = 0x00, 0x60, 0x40, 0x20 }
local ENV_PORT = { [0] = 0x12, 0x17, 0x1C, 0x21 }
local TRIG_PORT = { [0] = 0x14, 0x19, 0x1E, 0x23 }
local PER_LO = { [0] = 0x13, 0x18, 0x1D }
local DUTY_PORT = { [0] = 0x11, 0x16 }

local function setbit(s, a, bitn, on)
  local v = rd(s, a)
  if on then wr(s, a, bor(v, lshift(1, bitn))) else wr(s, a, band(v, bxor(0xFF, lshift(1, bitn)))) end
end
local function testbit(s, a, bitn) return band(rd(s, a), lshift(1, bitn)) ~= 0 end

-- LookupChannelNibble ($5632). Table is 128 bytes at $564B.
local function lookupNibble(s, a, e)
  local packed = bor(lshift(band(a, 15), 4), band(e, 15))
  local idx = rshift(packed, 1)
  local b = rom(s, 0x564B + idx)
  if band(packed, 1) == 1 then return band(b, 15) else return rshift(b, 4) end
end

-- MultiplyAByC ($4000): 8-bit product, high byte in the upper half.
local function mul8(a, c) return band(a, 255) * band(c, 255) end

-- Unsigned HL/BC quotient. ArmChannelGlide uses DivideHlByBc ($40AA).
local function divu(hl, bc)
  if bc == 0 then return 0 end
  if hl == bc then return 1 end
  return math.floor(hl / bc) % 65536
end

-- StepDf03 ($41A3). Carry is the rotate-through bit.
local function stepDf03(s)
  local a = rd(s, 0xDF03)
  local oldHi = a >= 128
  local carryIn = s.carry and 1 or 0
  a = (band(a, 127) * 2 + carryIn) % 256
  s.carry = oldHi
  if not oldHi then a = bxor(a, 0xE9) end
  wr(s, 0xDF03, a)
  return a
end

local function stepDf03Mod(s, b)
  b = band(b, 255)
  local a = stepDf03(s)
  if b == 0 then return a end
  while a >= b do a = a - b end
  return a
end

-- FoldDf03StepIntoHl ($41B9). Returns the folded word.
local function foldDf03(s, hl)
  local h, l = rshift(hl, 8), band(hl, 255)
  if h ~= 0 then
    local orig = h
    local a = stepDf03Mod(s, h)
    h = a
    if a < orig then
      l = stepDf03(s)
    else
      l = stepDf03Mod(s, l)
    end
  elseif l ~= 0 then
    l = stepDf03Mod(s, l)
  end
  return h * 256 + l
end

-- Compare for FoldSlideStep: carry when hl < de (CompareHlWithDe).
local function hlBelow(hl, de) return hl < de end

-- WriteChannelPeriod ($5184). HL is the summed 8.8 note. Channels 0-2.
local function writePeriod(s, ch, hl)
  if ch >= 3 then return end
  local h, l = rshift(hl, 8), band(hl, 255)
  while h >= 128 do h = (h + 0x54) % 256 end
  while h >= 0x54 do h = h - 0x54 end
  local per
  if l == 0 then
    per = rom(s, 0x51D8 + h * 2) + rom(s, 0x51D8 + h * 2 + 1) * 256
  else
    local scale = rom(s, 0x5282 + h)
    local frac = rshift(mul8(l, scale), 8)
    per = rom(s, 0x51D8 + h * 2) + rom(s, 0x51D8 + h * 2 + 1) * 256
    per = add16(per, frac)
  end
  wr(s, 0xDF12 + ch, rshift(per, 8))
  wr(s, 0xFF00 + PER_LO[ch], band(per, 255))
  wr(s, 0xFF00 + PER_LO[ch] + 1, rshift(per, 8))
end

-- WriteChannelEnvelope ($5070). B bit 0 replaces the register; otherwise
-- only the high nibble changes. Wave (channel 2) rewrites NR32 levels.
local function writeEnvelope(s, ch, a, bBit0)
  a = band(a, 255)
  if ch == 2 then
    local d = band(a, 0x0C)
    local prev = band(rd(s, 0xDF31), 0x0C)
    wr(s, 0xDF31, a)
    if prev == d then return end
    if testbit(s, 0xDF74, 0) then return end
    local idx = rshift(a, 2)
    local lvl = WAVE_LEVEL[idx] or 0
    local nr = band(rd(s, 0xFF1C), 0x9F)
    wr(s, 0xFF1C, bor(nr, lvl))
    local hi = rd(s, 0xDF12 + ch)
    wr(s, 0xFF1E, bor(0x80, hi))
    return
  end
  wr(s, 0xDF2F + ch, a)
  local port = 0xFF00 + ENV_PORT[ch]
  if bBit0 then
    wr(s, port, bor(lshift(band(a, 15), 4), rshift(a, 4)))
  else
    local old = rd(s, port)
    wr(s, port, bor(band(old, 0x0F), lshift(band(a, 15), 4)))
  end
  local trig = 0xFF00 + TRIG_PORT[ch]
  if ch == 3 then wr(s, trig, 0x80) else wr(s, trig, bor(0x80, rd(s, 0xDF12 + ch))) end
end

-- DropChannelOutput ($505C): clear the channel in NR51 and silence it.
local function dropOutput(s, ch)
  setbit(s, 0xDF09 + ch, 7, false)
  wr(s, 0xFF25, band(rd(s, 0xFF25), clearMask(ch)))
  writeEnvelope(s, ch, 0, true)
end

local function copyWave(s, addr)
  wr(s, 0xFF1A, 0)
  for i = 0, 15 do wr(s, 0xFF30 + i, rom(s, addr + i)) end
  wr(s, 0xFF1A, 0x80)
  return addr + 16
end

-- CopyMappedWaveform / StageWaveOrFlat. A header nibble of 7 is a hold:
-- next byte is a repeat count, wave RAM filled with $88.
local function stageWave(s, addr)
  s.bank = rd(s, 0xDF75)
  local head = rom(s, addr)
  if band(head, 0xF0) == 0x70 then
    local rep = rom(s, addr + 1)
    wr(s, 0xDF7D, rep)
    wr(s, 0xFF1A, 0)
    for i = 0, 15 do wr(s, 0xFF30 + i, 0x88) end
    wr(s, 0xFF1A, 0x80)
    addr = addr + 16
  else
    wr(s, 0xDF7D, 0)
    addr = copyWave(s, addr)
  end
  s.bank = rd(s, 0xDF00)
  return addr
end

-- LookupWaveRecord ($515A). Returns pointer, count word, flag byte, bank.
local function lookupWave(s, idx)
  local base = add16(0x5A79, rom(s, 0x5A7E) + rom(s, 0x5A7F) * 256)
  local rec = base + band(idx, 255) * 6
  local ptr = rom(s, rec) + rom(s, rec + 1) * 256
  local cnt = rom(s, rec + 2) + rom(s, rec + 3) * 256
  local flag = rom(s, rec + 4)
  local bank = band(rd(s, 0xDF00) + rom(s, rec + 5), 255)
  return ptr, cnt, flag, bank
end

-- RestartChannel ($50E6).
local function restartChannel(s, ch, a)
  a = band(a, 255)
  if ch == 3 then
    -- route only
  elseif ch == 2 then
    if a ~= 0xFF then
      local ptr, _, _, bank = lookupWave(s, a)
      wr(s, 0xDF75, bank)
      s.bank = bank
      copyWave(s, ptr)
      s.bank = rd(s, 0xDF00)
    end
    local hi = rd(s, 0xDF14)
    wr(s, 0xFF1E, bor(hi, 0x80))
    wr(s, 0xFF1E, band(hi, 0x7F))
  else
    if a < 4 then
      -- two rrc of the duty nibble land in NR11/NR21 bits 7-6.
      local duty = ({ [0] = 0x00, 0x40, 0x80, 0xC0 })[a]
      wr(s, 0xFF00 + DUTY_PORT[ch], duty)
    end
    local hi = rd(s, 0xDF12 + ch)
    wr(s, 0xFF00 + TRIG_PORT[ch], bor(0x80, hi))
  end
  setbit(s, 0xDF09 + ch, 7, true)
  local mask = clearMask(ch)
  local nr = band(rd(s, 0xFF25), mask)
  local own = band(rd(s, 0xDF11), bxor(0xFF, mask))
  wr(s, 0xFF25, bor(nr, own))
end

-- UpdateChannelOutputMask ($469A). Operand selects left / both / right.
local function outputMask(s, ch, operand)
  local cleared = band(rd(s, 0xDF11), clearMask(ch))
  local en = panByte(ch, band(operand, 255))
  wr(s, 0xDF11, bor(cleared, en))
  if testbit(s, 0xDF09 + ch, 7) then
    local nr = band(rd(s, 0xFF25), clearMask(ch))
    wr(s, 0xFF25, bor(nr, en))
  end
end

-- InstallTagStream ($4EDE). Returns false when priority loses.
local function installStream(s, ch, pri, addr)
  ch = band(ch, 0x7F)
  local cur = rd(s, 0xDF9D + ch)
  if pri < cur then return false end
  wr(s, 0xDF9D + ch, pri)
  w16(s, 0xDF7E + ch * 2, addr)
  w16(s, 0xDF86 + ch * 2, 0)
  w16(s, 0xDF92 + ch * 2, 0)
  wr(s, 0xDF8E + ch, 0)
  wr(s, 0xDFA1 + ch, 0)
  return true
end

-- OpenChannelForTag ($4DFA). Returns channel or nil on reject; C (the
-- channel with bit 7 cleared by InstallTagStream) comes back second then.
local function openForTag(s, tag, pri, ch, dsave)
  wr(s, 0xDFFE, dsave)
  local off = rom(s, 0x5A88 + tag * 2) + rom(s, 0x5A88 + tag * 2 + 1) * 256
  local addr = add16(0x5A88, off)
  if rom(s, addr) == 0x0E then
    local a = rom(s, addr + 1)
    addr = addr + 2
    if band(a, 0x10) ~= 0 then
      local e = band(a, 0x80)
      local flags = rd(s, 0xDFA6)
      if not testbit(s, 0xDFA6, 6) then
        local bit0 = band(ch, 1)
        flags = bor(flags, 0x40, lshift(bit0, 5))
        wr(s, 0xDFA6, flags)
      end
      local swapped = band(rshift(flags, 5), 1)
      ch = bor(e, swapped)
      wr(s, 0xDFA6, bxor(flags, 0x20))
    elseif a == 0xFF then
      ch = bor(0x80, ch)
    else
      ch = a
    end
  end
  if band(ch, 0x80) ~= 0 then
    if not installStream(s, ch, pri, addr) then return nil, band(ch, 0x7F) end
    return band(ch, 0x7F), true
  end
  if ch == 2 and pri >= rd(s, 0xDF9F) then
    if testbit(s, 0xDF74, 6) then
      wr(s, 0xFF07, 0)
      wr(s, 0xFFFF, band(rd(s, 0xFFFF), 0x1B))
      wr(s, 0xFF0F, band(rd(s, 0xFF0F), 0x1B))
    end
    wr(s, 0xDF74, 0)
  end
  if not installStream(s, ch, pri, addr) then return nil, band(ch, 0x7F) end
  wr(s, 0xDF70 + ch, 0x0F)
  wr(s, 0xDF09 + ch, 0)
  wr(s, 0xDF0D + ch, 0)
  if ch ~= 3 then
    local ix = ch * 2
    if dsave == 0 then
      local sum = add16(r16(s, 0xDF15 + ix), r16(s, 0xDF23 + ix))
      w16(s, 0xDF29 + ix, sum)
    end
    w16(s, 0xDF1D + ix, 0)
    w16(s, 0xDF23 + ix, 0)
  end
  w16(s, 0xDF15 + ch * 2, 0)
  wr(s, 0xDF11, bor(rd(s, 0xDF11), term(ch)))
  dropOutput(s, ch)
  return ch, false
end

local function nextCompanion(s, ch)
  local a = rd(s, 0xDFA5)
  local function taken(v)
    for i = 0, 3 do if rd(s, 0xDFA1 + i) == v then return true end end
    return false
  end
  repeat a = band(a + 1, 255) until a ~= 0 and not taken(a)
  wr(s, 0xDFA5, a)
  wr(s, 0xDFA1 + ch, a)
  return a
end

-- OpenSlotChannel ($4F44). B is the envelope nibble source, C the pan
-- operand (SoundSlotA passes B=$0F, C=$01).
local function openSlot(s, id, b, c)
  if id >= rom(s, 0x5A7D) then return 0 end
  local off = rom(s, 0x5A7B) + rom(s, 0x5A7C) * 256
  local rec = add16(0x5A79, off) + id * 4
  local tag, pri = rom(s, rec), rom(s, rec + 1)
  local perHi, nib = rom(s, rec + 2), rom(s, rec + 3)
  local ch = openForTag(s, tag, pri, 0, 1)
  if not ch then return 0 end
  setbit(s, 0xDF09 + ch, 1, true)
  setbit(s, 0xDF09 + ch, 5, true)
  setbit(s, 0xDF0D + ch, 5, true)
  wr(s, 0xDF15 + ch * 2, 0)
  wr(s, 0xDF16 + ch * 2, perHi)
  local nibble = band(b, 0x80) ~= 0 and nib or b
  nibble = band(nibble, 15)
  local mix = rshift(rd(s, 0xDFF8), 4)
  local packed = lookupNibble(s, mix, nibble)
  wr(s, 0xDFF4 + ch, packed)
  wr(s, 0xDF9C, ch)
  if c ~= 0xFF then outputMask(s, ch, c) end
  nextCompanion(s, ch)
  return ch
end

-- PrimeChannelFromTag ($4F1A) and the D=1 entry at $4F15. hint is the C
-- the caller passes in (0 when omitted); a reject returns nil, C.
local function primeFromTag(s, tag, dHi, envE, pri, dIs1, hint)
  local ch, c = openForTag(s, tag, pri or 0, hint or 0, dIs1 and 1 or 0)
  if not ch then return nil, c end
  setbit(s, 0xDF09 + ch, 1, false)
  setbit(s, 0xDF09 + ch, 5, true)
  setbit(s, 0xDF0D + ch, 5, true)
  wr(s, 0xDFF4 + ch, envE or 0)
  wr(s, 0xDF15 + ch * 2, 0)
  wr(s, 0xDF16 + ch * 2, dHi or 0)
  return ch
end

local function cursor(s) return r16(s, 0xDF9A) end
local function setCursor(s, a) w16(s, 0xDF9A, a) end
local function slot(s) return rd(s, 0xDF9C) end

-- SoundCommand00 / snd_end_23. A zero cursor ends RunSoundStream.
local function cmdEnd(s)
  local i = slot(s)
  wr(s, 0xDF9D + i, 0)
  wr(s, 0xDFA1 + i, 0)
  setCursor(s, 0)
end

local function advance(s, n)
  setCursor(s, add16(cursor(s), n))
end

-- ArmChannelVibrato ($536D). DE step, B half-period. Command $01.
local function armVibrato(s, ch, step, half)
  if ch >= 3 then return end
  local ix = ch * 2
  wr(s, 0xDF40 + ix, half)
  local h = rshift(half, 1)
  if h == 0 then h = 1 end
  wr(s, 0xDF3A + ix, h)
  w16(s, 0xDF34 + ix, step)
  w16(s, 0xDF46 + ix, 0)
  wr(s, 0xDF09 + ch, bor(band(rd(s, 0xDF09 + ch), 0xE2), 0x01))
end

-- ArmChannelRamp ($539C).
local function armRamp(s, a, step, lim)
  local hi = band(a, 0x80) ~= 0
  a = band(a, 0x7F)
  local flags = rd(s, 0xDF09 + a)
  local ix
  if flags == 0 and not hi then
    wr(s, 0xDF09 + a, band(flags, 0xF2))
    ix = a * 2
  else
    -- secondary slot when the flag byte is nonzero, or bit 7 of A
    if flags ~= 0 then wr(s, 0xDF09 + a, band(flags, 0xEA)) end
    ix = (a + 3) * 2
  end
  if flags == 0 and not hi then
    -- already stored ix
  elseif flags == 0 and hi then
    wr(s, 0xDF09 + a, band(rd(s, 0xDF09 + a), 0xF2))
    ix = a * 2
  end
  w16(s, 0xDF34 + ix, step)
  w16(s, 0xDF40 + ix, lim)
  w16(s, 0xDF4C + ix, 0)
  if hi then setbit(s, 0xDF09 + a, 4, true) else setbit(s, 0xDF09 + a, 3, true) end
end

-- ArmChannelGlide ($52D6). A is index ORed with the fifth operand.
local function armGlide(s, a, dist, count)
  local carry = band(a, 0x80) ~= 0
  local doubled = band(lshift(a, 1), 0xFF)
  -- sla dropped bit 7; the flag byte comes from the shifted low bits.
  local flagAt
  if band(doubled, 0x02) ~= 0 then flagAt = 0xDF0A
  elseif band(doubled, 0x04) ~= 0 then flagAt = 0xDF0B
  else flagAt = 0xDF09 end
  local fv = rd(s, flagAt)
  wr(s, flagAt, band(fv, bxor(0xFF, bor(0x01, 0x04, 0x08, 0x10))))
  local ix = doubled
  w16(s, 0xDF3A + ix, count)
  local sum = r16(s, 0xDF15 + ix)
  local bc = dist
  if carry then
    local latch = add16(sum, bc)
    w16(s, 0xDF46 + ix, latch)
  else
    w16(s, 0xDF46 + ix, bc)
    bc = sub16(bc, sum)
  end
  local neg = bc >= 0x8000
  local mag = neg and sub16(0, bc) or bc
  local q = divu(mag, count == 0 and 1 or count)
  if neg then q = sub16(0, q) end
  w16(s, 0xDF34 + ix, q)
  local ch = rshift(ix, 1)
  setbit(s, 0xDF09 + ch, 2, true)
end

-- FoldSlideStep ($54B6). Returns the word added into the vibrato sum.
local function foldSlide(s, ix)
  local step = r16(s, 0xDF34 + ix)
  local acc = add16(r16(s, 0xDF4C + ix), step)
  w16(s, 0xDF4C + ix, acc)
  local lim = r16(s, 0xDF40 + ix)
  local de = acc
  if band(lim, 0x8000) == 0 then
    if not hlBelow(de, lim) and de ~= lim then
      -- sum above the limit: the asm returns carry when HL < limit, and
      -- folds when that compare carries. Equal is kept (ret nc includes z).
    end
    if de > lim then
      de = sub16(de, lim)
      w16(s, 0xDF4C + ix, de)
    end
  else
    local limM = sub16(lim, 1)
    if de < limM or de == lim then
      -- lower bound: keep while sum >= limit. Compare is HL < (limit-1).
    end
    if de < lim then
      de = sub16(de, lim)
      w16(s, 0xDF4C + ix, de)
    end
  end
  return de
end

local function addInto(s, addr, delta)
  w16(s, addr, add16(r16(s, addr), delta))
end

-- StepChannelSlides ($53DE), channels 2, 1, 0.
local function stepSlides(s)
  for ch = 2, 0, -1 do
    local f = rd(s, 0xDF09 + ch)
    local ix = (ch) * 2
    if band(f, 0x04) ~= 0 then
      setbit(s, 0xDF09 + ch, 5, true)
      local cnt = r16(s, 0xDF3A + ix)
      if cnt == 0 then
        w16(s, 0xDF15 + ix, r16(s, 0xDF46 + ix))
        setbit(s, 0xDF09 + ch, 2, false)
      else
        cnt = sub16(cnt, 1)
        w16(s, 0xDF3A + ix, cnt)
        addInto(s, 0xDF15 + ix, r16(s, 0xDF34 + ix))
      end
    elseif band(f, 0x01) ~= 0 then
      setbit(s, 0xDF09 + ch, 5, true)
      local step = r16(s, 0xDF34 + ix)
      local lat = add16(r16(s, 0xDF46 + ix), step)
      w16(s, 0xDF46 + ix, lat)
      addInto(s, 0xDF1D + ix, lat)
      local left = rd(s, 0xDF3A + ix)
      left = band(left - 1, 255)
      wr(s, 0xDF3A + ix, left)
      if left == 0 then
        wr(s, 0xDF3A + ix, rd(s, 0xDF40 + ix))
        w16(s, 0xDF34 + ix, sub16(0, step))
      end
    else
      if band(f, 0x08) ~= 0 then
        local d = foldSlide(s, ix)
        addInto(s, 0xDF1D + ix, d)
        setbit(s, 0xDF09 + ch, 5, true)
        f = rd(s, 0xDF09 + ch)
      end
      if band(f, 0x10) ~= 0 then
        local six = (ch + 3) * 2
        local d = foldSlide(s, six)
        addInto(s, 0xDF1D + ix, d)
        setbit(s, 0xDF09 + ch, 5, true)
      end
    end
  end
end

-- StartPhaseScript ($54EC).
local function startPhaseScript(s, ch, addr)
  local step = rom(s, addr) + rom(s, addr + 1) * 256
  local script = addr + 2
  w16(s, 0xDF58 + ch * 2, script)
  w16(s, 0xDF68 + ch * 2, step)
  w16(s, 0xDF60, 0)
  wr(s, 0xDF70 + ch, 0)
  wr(s, 0xDF0D + ch, bor(band(rd(s, 0xDF0D + ch), 0xF0), 0x21))
end

-- StepChannelPhases ($551E).
local function stepPhases(s)
  for ch = 3, 0, -1 do
    local f = rd(s, 0xDF0D + ch)
    local mode = band(f, 0x0B)
    if mode ~= 0 then
      local ix = ch * 2
      local function level(new)
        local old = rd(s, 0xDF70 + ch)
        wr(s, 0xDF70 + ch, new)
        if new ~= old then setbit(s, 0xDF0D + ch, 5, true) end
      end
      if band(mode, 0x02) ~= 0 then
        local sp = r16(s, 0xDF58 + ix)
        local target = rom(s, sp)
        local hi = rd(s, 0xDF61 + ix)
        local function integrate()
          local st = r16(s, 0xDF68 + ix)
          local ph = add16(r16(s, 0xDF60 + ix), st)
          w16(s, 0xDF60 + ix, ph)
          level(rshift(ph, 8))
        end
        if hi < 128 and hi < target then
          integrate()
        else
          w16(s, 0xDF60 + ix, target * 256)
          local st = rom(s, sp + 1) + rom(s, sp + 2) * 256
          w16(s, 0xDF68 + ix, st)
          level(target)
          wr(s, 0xDF0D + ch, bor(band(rd(s, 0xDF0D + ch), 0xF0), 0x04))
        end
      elseif band(mode, 0x08) ~= 0 then
        local st = r16(s, 0xDF68 + ix)
        local ph = add16(r16(s, 0xDF60 + ix), st)
        w16(s, 0xDF60 + ix, ph)
        local hi = rshift(ph, 8)
        if hi >= 128 or ph == 0 then
          local old = rd(s, 0xDF70 + ch)
          wr(s, 0xDF70 + ch, 0)
          wr(s, 0xDF0D + ch, band(rd(s, 0xDF0D + ch), 0xF0))
          if old ~= 0 then setbit(s, 0xDF0D + ch, 5, true) end
        else
          level(hi)
        end
      else
        local hi = rd(s, 0xDF61 + ix)
        if hi < 0x0F then
          local st = r16(s, 0xDF68 + ix)
          local ph = add16(r16(s, 0xDF60 + ix), st)
          w16(s, 0xDF60 + ix, ph)
          level(rshift(ph, 8))
        else
          w16(s, 0xDF60 + ix, 0x0F00)
          level(0x0F)
          local fl = rd(s, 0xDF0D + ch)
          if band(fl, 0x10) ~= 0 then
            setbit(s, 0xDF0D + ch, 4, false)
          else
            wr(s, 0xDF0D + ch, bor(band(fl, 0xF0), 0x02))
            local sp = r16(s, 0xDF58 + ix)
            w16(s, 0xDF68 + ix, rom(s, sp) + rom(s, sp + 1) * 256)
            w16(s, 0xDF58 + ix, add16(sp, 2))
          end
        end
      end
    end
  end
end

-- UpdateWaveDuty ($43E0). Software pulse width on channel 2.
local function updateWaveDuty(s)
  local step = r16(s, 0xDF76)
  local pos = add16(r16(s, 0xDF7B), step)
  local d = rshift(step, 8)
  local reflectFrom
  if d < 128 then
    -- CompareHlWithBc: carry (reflect) when limit*256 is below the new position
    if rd(s, 0xDF7A) * 256 < pos then reflectFrom = rd(s, 0xDF7A) end
  else
    local floorB, hi = rd(s, 0xDF78), rshift(pos, 8)
    if hi >= 128 or hi < floorB then reflectFrom = floorB end
  end
  if reflectFrom then
    -- .reflect: position = (bound sla 1) * 256 - position, and the step is negated
    pos = add16(band(reflectFrom * 2, 0xFF) * 256, sub16(0, pos))
    step = sub16(0, step)
    w16(s, 0xDF76, step)
  end
  w16(s, 0xDF7B, pos)
  local width = rshift(pos, 8)
  if width == rd(s, 0xDF75) and rd(s, 0xDF31) == rd(s, 0xDF7D) then return end
  -- .rewrite: $FF30 gets the sample, then (width >> 1) bytes of swap(sample) | sample
  -- (the jump into .pulse), a high-nibble byte when width is odd, then seven zeros.
  wr(s, 0xDF75, width)
  local sample = rd(s, 0xDF31)
  wr(s, 0xDF7D, sample)
  wr(s, 0xFF1A, 0)
  wr(s, 0xFF30, sample)
  local both = bor(sample, bor(band(lshift(sample, 4), 0xF0), rshift(sample, 4)))
  local at = 0xFF31
  local function put(v) if at <= 0xFF3F then wr(s, at, v) end; at = at + 1 end
  for _ = 1, math.min(rshift(width, 1), 7) do put(both) end
  if band(width, 1) == 1 then put(band(both, 0xF0)) end
  for _ = 1, 7 do put(0) end
  wr(s, 0xFF1A, 0x80)
  wr(s, 0xFF1B, 0)
  wr(s, 0xFF1C, 0x20)
  local hi = rd(s, 0xDF14)
  wr(s, 0xFF1E, bor(hi, 0x80))
  wr(s, 0xFF1E, band(hi, 0x7F))
end

-- AdvanceWaveStream ($56CB). One 16-byte frame per tick while bit 7 is set.
local function advanceWave(s)
  local cnt = sub16(r16(s, 0xDF78), 1)
  w16(s, 0xDF78, cnt)
  if cnt == 0 then
    setbit(s, 0xDF74, 7, false)
    dropOutput(s, 2)
    return
  end
  local ptr = r16(s, 0xDF76)
  s.bank = rd(s, 0xDF75)
  local head = rom(s, ptr)
  if band(head, 0xF0) == 0x70 then
    ptr = stageWave(s, ptr)
  else
    ptr = copyWave(s, ptr)
    local hi = rd(s, 0xDF14)
    wr(s, 0xFF1E, bor(hi, 0x80))
    wr(s, 0xFF1E, band(hi, 0x7F))
    s.bank = rd(s, 0xDF00)
  end
  if rshift(ptr, 8) >= 0x80 then
    ptr = bor(band(ptr, 255), 0x4000)
    wr(s, 0xDF75, band(rd(s, 0xDF75) + 1, 255))
  end
  w16(s, 0xDF76, ptr)
end

-- SetWavePeriodDelta ($4BA9).
local function setWavePeriodDelta(s)
  setbit(s, 0xDF0B, 5, true)
  local base = 0x2A88
  if rd(s, 0xDF04) == 0x81 and band(rd(s, 0xFF4D), 0x80) ~= 0 then base = 0x2A7B end
  local delta = sub16(base, r16(s, 0xDF19))
  w16(s, 0xDF27, delta)
end

-- StageWaveAndRestart ($4B7E).
local function stageAndRestart(s, bank, ptr, cnt)
  wr(s, 0xDF75, bank)
  local nextPtr = stageWave(s, ptr)
  if rshift(nextPtr, 8) >= 0x80 then
    nextPtr = bor(band(nextPtr, 255), 0x4000)
    wr(s, 0xDF75, band(rd(s, 0xDF75) + 1, 255))
  end
  w16(s, 0xDF78, cnt)
  wr(s, 0xDF7A, 0)
  w16(s, 0xDF76, nextPtr)
  restartChannel(s, 2, 0xFF)
end

-- StartSoundTimer ($4BD2). Enables the timer IRQ (sample streams).
local function startSoundTimer(s)
  setbit(s, 0xDF0B, 5, true)
  local base = 0x47B4
  local delta = sub16(base, r16(s, 0xDF19))
  w16(s, 0xDF27, delta)
  local tma, tac
  if rd(s, 0xDF04) == 0x81 and band(rd(s, 0xFF4D), 0x80) ~= 0 then
    tac, tma = 0x07, 0x80
  else
    tac, tma = 0x06, 0x00
  end
  wr(s, 0xFF07, tac)
  wr(s, 0xDF08, tma)
  wr(s, 0xFF05, tma)
  wr(s, 0xFF06, tma)
  wr(s, 0xFF0F, band(rd(s, 0xFF0F), 0x1B))
  wr(s, 0xFFFF, bor(rd(s, 0xFFFF), 0x04))
end

-- FeedWaveFromTimer ($3AC0). One frame each timer tick while bit 6 is set.
local function feedWave(s)
  if not testbit(s, 0xDF74, 6) then return end
  local tma = rd(s, 0xDF08)
  wr(s, 0xFF05, tma)
  wr(s, 0xFF06, tma)
  local rep = rd(s, 0xDF7D)
  if rep ~= 0 then wr(s, 0xDF7D, band(rep - 1, 255)); return end
  local cnt = sub16(r16(s, 0xDF78), 1)
  w16(s, 0xDF78, cnt)
  if cnt == 0 then
    setbit(s, 0xDF74, 6, false)
    wr(s, 0xDF9F, 0)
    wr(s, 0xFFFF, band(rd(s, 0xFFFF), 0x1B))
    wr(s, 0xFF0F, band(rd(s, 0xFF0F), 0x1B))
    wr(s, 0xFF1A, 0)
    wr(s, 0xFF07, 0)
    wr(s, 0xFF1A, 0x80)
    wr(s, 0xFF25, band(rd(s, 0xFF25), 0xBB))
    return
  end
  local ptr = r16(s, 0xDF76)
  s.bank = rd(s, 0xDF75)
  local head = rom(s, ptr)
  if band(head, 0xF0) == 0x70 then
    local n = rom(s, ptr + 1)
    wr(s, 0xDF7D, n)
    ptr = ptr + 16
    for i = 0, 15 do wr(s, 0xFF30 + i, 0x88) end
  else
    ptr = copyWave(s, ptr)
  end
  wr(s, 0xFF1A, 0x80)
  local hi = rd(s, 0xDF14)
  wr(s, 0xFF1E, bor(hi, 0x80))
  wr(s, 0xFF1E, band(hi, 0x7F))
  if rshift(ptr, 8) >= 0x80 then
    ptr = bor(band(ptr, 255), 0x4000)
    wr(s, 0xDF75, band(rd(s, 0xDF75) + 1, 255))
  end
  w16(s, 0xDF76, ptr)
end

local function selectWave(s, idx)
  local ptr, cnt, flag, bank = lookupWave(s, idx)
  if band(flag, 1) == 0 then
    stageAndRestart(s, bank, ptr, cnt)
    setWavePeriodDelta(s)
    setbit(s, 0xDF74, 7, true)
  else
    stageAndRestart(s, bank, ptr, cnt)
    wr(s, 0xDF7B, 0)
    wr(s, 0xDF7C, 0)
    startSoundTimer(s)
    setbit(s, 0xDF74, 6, true)
  end
end

local function armCountdownIndex(s, a)
  local ix = band(a, 255) * 2
  local w = r16(s, 0xDF86 + ix)
  if w ~= 0 then
    setCursor(s, w)
    w16(s, 0xDF7E + ix, w)
    w16(s, 0xDF92, 0)
  end
  local ch = rshift(ix, 1)
  local f = bor(rd(s, 0xDF0D + ch), 0x80)
  wr(s, 0xDF0D + ch, f)
  if band(f, 0x17) == 0 or band(f, 0x10) ~= 0 then return end
  if band(f, 0x04) ~= 0 then
    wr(s, 0xDF0D + ch, bor(band(0, 0xF0), 0x08))
    return
  end
  wr(s, 0xDF0D + ch, bor(band(f, 0xF0), 0x08))
  local sp = r16(s, 0xDF58 + ix)
  local add = band(f, 1) == 0 and 1 or 3
  w16(s, 0xDF68 + ix, rom(s, sp + add) + rom(s, sp + add + 1) * 256)
end

-- ContinueClearedChannel ($4710).
local function releaseChannel(s)
  dropOutput(s, slot(s))
end

local function jumpTarget(s, bc)
  local off = rom(s, bc) * 256 + rom(s, bc + 1)
  setCursor(s, add16(0x5A88, off))
end

-- Command handlers. BC is the address just past the opcode. Each one
-- leaves the next cursor at $DF9A. RunSoundStream stops after $04.
local function cmd01(s, bc)
  local step = rom(s, bc) * 256 + rom(s, bc + 1)
  local half = rom(s, bc + 2)
  setCursor(s, bc + 3)
  local ch = slot(s)
  if ch < 3 then armVibrato(s, ch, step, half) end
end

local function cmdGlideOp(s, bc, fifth)
  local b = rom(s, bc) * 256 + rom(s, bc + 1)
  local de = rom(s, bc + 2) * 256 + rom(s, bc + 3)
  local ch = slot(s)
  if ch < 3 then armGlide(s, bor(ch, fifth), b, de) end
end

local function cmd02(s, bc)
  cmdGlideOp(s, bc, rom(s, bc + 4))
  -- cursor was the opcode+1; the handler adds 5 to that saved word.
  -- RunSoundStream stored bc before the call, so adding 5 lands past operands.
  setCursor(s, bc + 5)
end

local function cmd03(s, bc)
  local step = rom(s, bc) * 256 + rom(s, bc + 1)
  local lim = rom(s, bc + 2) * 256 + rom(s, bc + 3)
  local ch = slot(s)
  if ch < 3 then armRamp(s, bor(ch, rom(s, bc + 4)), step, lim) end
  setCursor(s, bc + 5)
end

local function cmd04(s, bc)
  local ch = slot(s)
  local ix = ch * 2
  if r16(s, 0xDF92 + ix) == 0 then
    local src = rom(s, bc + 1)
    if src == 0 then
      wr(s, 0xDF93 + ix, rom(s, bc + 2))
      wr(s, 0xDF92 + ix, rom(s, bc + 3))
    else
      local hl = foldDf03(s, rom(s, bc + 2) * 256 + rom(s, bc + 3))
      hl = add16(hl, 1)
      w16(s, 0xDF92 + ix, hl)
    end
  end
  if rom(s, bc) ~= 0 and testbit(s, 0xDF0D + ch, 7) then
    w16(s, 0xDF92 + ix, 0)
    setCursor(s, bc + 4)
    return
  end
  local left = sub16(r16(s, 0xDF92 + ix), 1)
  w16(s, 0xDF92 + ix, left)
  if left ~= 0 then setCursor(s, bc - 1); return end
  if rom(s, bc + 2) == 0 and rom(s, bc + 3) == 0 then setCursor(s, bc - 1)
  else setCursor(s, bc + 4) end
end

local function cmd05(s, bc)
  local ch = slot(s)
  local limit = rom(s, bc)
  local count = rd(s, 0xDF8E + ch)
  if limit ~= 0 and limit == count then
    wr(s, 0xDF8E + ch, 0)
    setCursor(s, bc + 3)
    return
  end
  wr(s, 0xDF8E + ch, band(count + 1, 255))
  local rel = rom(s, bc + 1) * 256 + rom(s, bc + 2)
  setCursor(s, add16(bc + 3, rel))
end

local function cmd06(s, bc) jumpTarget(s, bc) end

local function cmd07(s, bc)
  local target = rom(s, bc) * 256 + rom(s, bc + 1)
  setCursor(s, bc + 2)
  local ch = slot(s)
  if ch >= 3 then return end
  setbit(s, 0xDF09 + ch, 5, true)
  local delta = sub16(target, r16(s, 0xDF15 + ch * 2))
  w16(s, 0xDF23 + ch * 2, delta)
end

local function cmd08(s, bc)
  local ch = slot(s)
  setCursor(s, bc + 3)
  if ch >= 3 then return end
  setbit(s, 0xDF09 + ch, 5, true)
  local mode = rom(s, bc)
  local word = rom(s, bc + 1) * 256 + rom(s, bc + 2)
  if mode == 0 then
    w16(s, 0xDF23 + ch * 2, word)
  else
    w16(s, 0xDF23 + ch * 2, 0)
    local sum = add16(r16(s, 0xDF15 + ch * 2), word)
    local hi = rshift(sum, 8)
    if hi >= 128 then hi = (hi + 0x54) % 256
    elseif hi >= 0x54 then hi = hi - 0x54 end
    w16(s, 0xDF15 + ch * 2, bor(band(sum, 255), lshift(hi, 8)))
  end
end

local function cmd09(s, bc)
  local e = rom(s, bc)
  setCursor(s, bc + 1)
  local ch = slot(s)
  local mix = rd(s, 0xDFF8)
  if testbit(s, 0xDF09 + ch, 1) then mix = rshift(mix, 4) end
  wr(s, 0xDFF4 + ch, lookupNibble(s, band(mix, 15), e))
  setbit(s, 0xDF0D + ch, 5, true)
end

local function cmd0A(s, bc)
  outputMask(s, slot(s), rom(s, bc))
  advance(s, 1)
end

local function cmd0B(s, bc)
  local ch = slot(s)
  setCursor(s, bc + 4)
  if ch >= 3 then return end
  -- The handler sets bit 5 of $DF09, not of the indexed flag (the add is
  -- missing). Match that store.
  setbit(s, 0xDF09, 5, true)
  local mode = rom(s, bc)
  local ix = ch * 2
  if band(mode, 0x80) == 0 then
    if mode == 0 then
      local lo = rom(s, bc + 1)
      local span = band(rom(s, bc + 2) - lo, 255)
      local a = band(stepDf03Mod(s, span) + lo, 255)
      wr(s, 0xDF16 + ix, a)
      wr(s, 0xDF15 + ix, rom(s, bc + 3))
    else
      local c = rom(s, bc + 1)
      local b = rom(s, bc + 2)
      local cur = rd(s, 0xDF16 + ix)
      local sum = band(cur + c, 255)
      if sum >= 128 then sum = 0 end
      local span = band(b + cur - sum, 255)
      local a = band(stepDf03Mod(s, span) - cur, 255)
      wr(s, 0xDF24 + ix, a)
      wr(s, 0xDF23 + ix, rom(s, bc + 3))
    end
  elseif band(mode, 0x7F) == 0 then
    local b = band(bxor(rom(s, bc + 1), 0xFF) + 1, 255)
    local hl = add16(rom(s, bc + 2) * 256 + rom(s, bc + 3), b * 256)
    hl = foldDf03(s, hl)
    b = band(bxor(b, 0xFF) + 1, 255)
    hl = add16(hl, b * 256)
    w16(s, 0xDF15 + ix, hl)
  else
    local b = rom(s, bc + 1)
    local base = add16(r16(s, 0xDF15 + ix), b * 256)
    local span = rom(s, bc + 2) * 256 + rom(s, bc + 3)
    local hi = add16(r16(s, 0xDF15 + ix), span)
    local neg = sub16(0, base)
    local folded = foldDf03(s, add16(hi, neg))
    folded = add16(folded, base)
    local rel = sub16(folded, r16(s, 0xDF15 + ix))
    w16(s, 0xDF23 + ix, rel)
  end
end

local function cmd0C(s, bc)
  local e = rom(s, bc)
  setCursor(s, bc + 1)
  local ch = slot(s)
  if ch < 2 and e == 0xFF then e = rshift(rd(s, 0xDFF4 + ch), 2) end
  restartChannel(s, ch, e)
end

local function cmd0E(s, bc) setCursor(s, bc + 1) end

local function cmd0F(s, bc)
  local idx = rom(s, bc)
  local base = add16(0x5A79, rom(s, 0x5A79) + rom(s, 0x5A7A) * 256)
  local ent = base + idx * 2
  local off = rom(s, ent) + rom(s, ent + 1) * 256
  startPhaseScript(s, slot(s), add16(base, off))
  advance(s, 1)
end

local function cmd10(s, bc)
  local v = rom(s, bc)
  setCursor(s, bc + 1)
  wr(s, 0xFF22, v)
end

local function storeSwappedStep(s, ch, bc)
  local lo = rom(s, bc + 1)
  local hi = rom(s, bc)
  w16(s, 0xDF68 + ch * 2, hi * 256 + lo)
end

local function cmd11(s, bc)
  local ch = slot(s)
  wr(s, 0xDF0D + ch, bor(band(rd(s, 0xDF0D + ch), 0xF0), 0x28))
  wr(s, 0xDF70 + ch, 0x0F)
  w16(s, 0xDF60 + ch * 2, 0x0F00)
  storeSwappedStep(s, ch, bc)
  advance(s, 2)
end

local function cmd12(s, bc)
  local a = rom(s, bc)
  setCursor(s, bc + 1)
  if a == 0xFF then armCountdownIndex(s, slot(s)) else armCountdownIndex(s, a) end
end

local function cmd13(s, bc)
  local e = rom(s, bc)
  setCursor(s, bc + 1)
  local ch = slot(s)
  if ch == 2 then return end
  wr(s, 0xDF0D + ch, bor(band(rd(s, 0xDF0D + ch), 0xF0), 0x20))
  local v = bor(lshift(rd(s, 0xDF2F + ch), 4), band(e, 15))
  if band(v, 0x08) ~= 0 then wr(s, 0xDFF4 + ch, 0) end
  if ENV_PORT[ch] then wr(s, 0xFF00 + ENV_PORT[ch], band(v, 255)) end
end

local function cmd14(s, bc)
  local d = rom(s, bc)
  local e = rom(s, bc + 1)
  setCursor(s, bc + 2)
  local ch = slot(s)
  if ch >= 3 then return end
  setbit(s, 0xDF09 + ch, 5, true)
  d = band(d + rd(s, 0xDF2A + ch), 255)
  local target = d * 256 + e
  w16(s, 0xDF23 + ch * 2, sub16(target, r16(s, 0xDF15 + ch * 2)))
end

local function branch(s, bc, take)
  if take then jumpTarget(s, bc) else setCursor(s, bc + 2) end
end

local function cmd15(s, bc)
  local ch = slot(s)
  local thr = rom(s, bc)
  branch(s, bc + 1, rd(s, 0xDF16 + ch * 2) >= thr)
end

local function cmd16(s, bc)
  local thr = rom(s, bc)
  branch(s, bc + 1, stepDf03(s) >= thr)
end

local function cmd17(s, bc)
  local ch = slot(s)
  local thr = rom(s, bc)
  branch(s, bc + 1, rd(s, 0xDFF4 + ch) >= thr)
end

local function cmd18(s, bc)
  local off = rom(s, bc) * 256 + rom(s, bc + 1)
  w16(s, 0xDF86 + slot(s) * 2, add16(0x5A88, off))
  advance(s, 2)
end

local function cmd19(s)
  w16(s, 0xDF86 + slot(s) * 2, 0)
end

local function cmd1A(s, bc)
  local idx = band(rom(s, bc), 7)
  wr(s, 0xDF33, bor(rd(s, 0xDF33), lshift(1, idx)))
  setCursor(s, bc + 1)
end

local function cmd1B(s, bc)
  local ch = slot(s)
  setCursor(s, bc + 4)
  if ch >= 3 then return end
  local addW = rom(s, bc) * 256 + rom(s, bc + 1)
  local de = rom(s, bc + 2) * 256 + rom(s, bc + 3)
  local sum = add16(r16(s, 0xDF15 + ch * 2), addW)
  w16(s, 0xDF15 + ch * 2, r16(s, 0xDF29 + ch * 2))
  armGlide(s, ch, sum, de)
end

local function cmd1C(s, bc)
  local ch = slot(s)
  local mode, val = rom(s, bc), rom(s, bc + 1)
  if mode == 0 then
    local cur = rd(s, 0xDF9D + ch)
    if band(val, 0x80) == 0 then
      local sum = cur + val
      val = sum > 255 and 255 or sum
    else
      local diff = cur - val
      val = diff < 0 and 0 or diff
    end
  end
  wr(s, 0xDF9D + ch, val)
  advance(s, 2)
end

-- snd_wave_sweep enters StartDefaultWaveSweep one byte in, so the four
-- operand bytes are the sweep record (music-format.md).
local function startSweep(s, addr)
  wr(s, 0xDF78, rom(s, addr))
  wr(s, 0xDF7C, rom(s, addr))
  wr(s, 0xDF7B, 0)
  wr(s, 0xDF7A, rom(s, addr + 1))
  wr(s, 0xDF77, rom(s, addr + 2))
  wr(s, 0xDF76, rom(s, addr + 3))
  setCursor(s, addr + 4)
  wr(s, 0xDF75, 0xFF)
  wr(s, 0xDF7D, 0xFF)
  for i = 0xFF39, 0xFF3F do wr(s, i, 0) end
  wr(s, 0xFF1A, 0)
  wr(s, 0xFF1A, 0x80)
  wr(s, 0xDF74, 1)
  updateWaveDuty(s)
  restartChannel(s, 2, 0xFF)
end

local function cmd1E(s, bc)
  if not testbit(s, 0xDF74, 0) then setCursor(s, bc + 4); return end
  wr(s, 0xDF78, rom(s, bc))
  wr(s, 0xDF7A, rom(s, bc + 1))
  wr(s, 0xDF77, rom(s, bc + 2))
  wr(s, 0xDF76, rom(s, bc + 3))
  setCursor(s, bc + 4)
  updateWaveDuty(s)
end

local function clearFx(s)
  local ch = slot(s)
  if ch == 2 then wr(s, 0xDF74, band(rd(s, 0xDF74), 0xFE)) end
  local f = rd(s, 0xDF09 + ch)
  wr(s, 0xDF09 + ch, bor(band(f, 0xE2), 0x20))
end

local function cmd21(s, bc)
  setCursor(s, bc + 1)
  if slot(s) ~= 2 then return end
  wr(s, 0xDF74, 0)
  selectWave(s, rom(s, bc))
end

local function cmd22(s)
  if slot(s) ~= 2 then return end
  wr(s, 0xDF74, 0)
  local count = rom(s, 0x5A84)
  local idx = rd(s, 0xDF1A)
  local function load(a)
    selectWave(s, a)
    restartChannel(s, 2, 0xFF)
  end
  if count == 0 then
    local lim = rom(s, 0x5A80)
    if lim ~= 0 and idx < lim then load(idx) end
    return
  end
  if idx >= count then return end
  local tableAt = add16(0x5A79, rom(s, 0x5A82) + rom(s, 0x5A83) * 256)
  local lim = rom(s, 0x5A80)
  local a = rom(s, tableAt + idx)
  if lim ~= 0 and a < lim then load(a) end
end

local function cmd24(s, bc)
  local a = rom(s, bc)
  setCursor(s, bc + 1)
  wr(s, 0xDF7C, a)
  wr(s, 0xDF7B, 0)
  wr(s, 0xDF78, 0)
  w16(s, 0xDF76, 0)
  wr(s, 0xDF7A, 0x0F)
  wr(s, 0xDF75, 0xFF)
  wr(s, 0xDF7D, 0xFF)
  for i = 0xFF39, 0xFF3F do wr(s, i, 0) end
  wr(s, 0xFF1A, 0x80)
  wr(s, 0xDF74, 1)
  updateWaveDuty(s)
  restartChannel(s, 2, 0xFF)
end

local function cmd25(s)
  wr(s, 0xDF7C, rd(s, 0xDFF6))
  wr(s, 0xDF7B, 0)
  wr(s, 0xDF78, 0)
  w16(s, 0xDF76, 0)
  wr(s, 0xDF7A, 0x0F)
  wr(s, 0xDF75, 0xFF)
  wr(s, 0xDF7D, 0xFF)
  for i = 0xFF39, 0xFF3F do wr(s, i, 0) end
  wr(s, 0xFF1A, 0x80)
  wr(s, 0xDF74, 1)
  updateWaveDuty(s)
  restartChannel(s, 2, 0xFF)
end

local function cmd26(s, bc)
  local e, d = rom(s, bc), rom(s, bc + 1)
  setCursor(s, bc + 2)
  local ch = slot(s)
  -- Period high passed into PrimeChannelFromTag. OpenSlotChannel stored it
  -- at $DF16 (open_slot_channel.asm).
  local dHi = rd(s, 0xDF16 + ch * 2)
  local pri = rd(s, 0xDF9D + ch)
  local env = rd(s, 0xDFF4 + ch)
  local opened
  if testbit(s, 0xDF09 + ch, 1) then
    opened = openForTag(s, d, pri, e, 1)
    if opened then setbit(s, 0xDF09 + opened, 1, true) end
  else
    opened = primeFromTag(s, d, dHi, env, 0, false)
  end
  if opened and opened == ch then
    setCursor(s, r16(s, 0xDF7E + ch * 2))
  end
end

local function cmd27(s, bc)
  local ch = slot(s)
  wr(s, 0xDF0D + ch, bor(band(rd(s, 0xDF0D + ch), 0xF0), 0x31))
  wr(s, 0xDF70 + ch, 0)
  w16(s, 0xDF60 + ch * 2, 0)
  storeSwappedStep(s, ch, bc)
  advance(s, 2)
end

local function cmd28(s, bc)
  cmd09(s, bc)
  local ch = slot(s)
  local a = lookupNibble(s, rd(s, 0xDFF4 + ch), rd(s, 0xDF70 + ch))
  wr(s, 0xDF2F + ch, a)
end

local CMDS = {
  [0x00] = function(s, _) cmdEnd(s) end,
  [0x01] = cmd01,
  [0x02] = cmd02,
  [0x03] = cmd03,
  [0x04] = cmd04,
  [0x05] = cmd05,
  [0x06] = cmd06,
  [0x07] = cmd07,
  [0x08] = cmd08,
  [0x09] = cmd09,
  [0x0A] = cmd0A,
  [0x0B] = cmd0B,
  [0x0C] = cmd0C,
  [0x0D] = function(s, _) releaseChannel(s) end,
  [0x0E] = cmd0E,
  [0x0F] = cmd0F,
  [0x10] = cmd10,
  [0x11] = cmd11,
  [0x12] = cmd12,
  [0x13] = cmd13,
  [0x14] = cmd14,
  [0x15] = cmd15,
  [0x16] = cmd16,
  [0x17] = cmd17,
  [0x18] = cmd18,
  [0x19] = function(s, _) cmd19(s) end,
  [0x1A] = cmd1A,
  [0x1B] = cmd1B,
  [0x1C] = cmd1C,
  [0x1D] = function(s, bc) startSweep(s, bc) end,
  [0x1E] = cmd1E,
  [0x1F] = function(s, _) clearFx(s) end,
  [0x20] = function(s, _)
    clearFx(s)
    local ch = slot(s)
    if ch < 3 then w16(s, 0xDF1D + ch * 2, 0) end
  end,
  [0x21] = cmd21,
  [0x22] = function(s, _) cmd22(s) end,
  [0x23] = function(s, _) cmdEnd(s) end,
  [0x24] = cmd24,
  [0x25] = function(s, _) cmd25(s) end,
  [0x26] = cmd26,
  [0x27] = cmd27,
  [0x28] = cmd28,
  [0x29] = cmd1C,
}

-- RunSoundStream ($5032). Command $04 yields the tick. A zero cursor stops.
local function runStream(s, addr)
  local guard = 0
  while addr ~= 0 and guard < 64 do
    guard = guard + 1
    local op = rom(s, addr)
    local bc = band(addr + 1, 0xFFFF)
    setCursor(s, bc)
    local fn = CMDS[op]
    if fn then fn(s, bc) else setCursor(s, 0); break end
    if op == 0x04 then return end
    addr = cursor(s)
  end
end

-- StepSoundStreams ($5006).
local function stepStreams(s)
  for i = 0, 3 do
    local addr = r16(s, 0xDF7E + i * 2)
    if addr ~= 0 then
      wr(s, 0xDF9C, i)
      runStream(s, addr)
      w16(s, 0xDF7E + i * 2, cursor(s))
    end
  end
end

-- ResetApu ($449D).
local function resetApu(s)
  wr(s, 0xFF24, 0)
  wr(s, 0xFF25, 0)
  wr(s, 0xFF26, 0)
  wr(s, 0xFF26, 0x80)
  wr(s, 0xFF10, 0x08)
  wr(s, 0xFF11, 0x80)
  wr(s, 0xFF12, 0)
  wr(s, 0xFF13, 0)
  wr(s, 0xFF14, 0x80)
  wr(s, 0xFF16, 0x80)
  wr(s, 0xFF17, 0)
  wr(s, 0xFF18, 0)
  wr(s, 0xFF19, 0x80)
  wr(s, 0xFF1A, 0)
  wr(s, 0xFF1B, 0)
  wr(s, 0xFF1C, 0)
  wr(s, 0xFF1D, 0)
  wr(s, 0xFF1E, 0x80)
  for i = 0, 15 do wr(s, 0xFF30 + i, 0) end
  wr(s, 0xFF20, 0)
  wr(s, 0xFF21, 0)
  wr(s, 0xFF22, 0)
  wr(s, 0xFF23, 0x80)
  wr(s, 0xFF24, 0x77)
end

-- InitSoundWorkArea ($44EF). A is the bank CallBankedHL left ($30).
local function initWork(s)
  for a = 0xDF00, 0xDFFE do s.mem[a] = 0 end
  wr(s, 0xDF01, 0)
  resetApu(s)
  wr(s, 0xDF11, 0xFF)
  wr(s, 0xDF04, 0x30)
  wr(s, 0xDF00, 0x30)
  wr(s, 0xDF03, 0xDE)
  wr(s, 0xDFF8, 0xFF)
  wr(s, 0xDF02, 0xF5)
  s.bank = 0x30
end

-- Store0FAtC92C ($0659), the command InitSoundState installs.
local function store0F(s)
  wr(s, 0xFF24, 0x77)
  wr(s, 0xC92C, 0x0F)
  wr(s, 0xDFF8, bor(band(rd(s, 0xDFF8), 0xF0), 0x0F))
  wr(s, 0xC92B, 0x0F)
  wr(s, 0xDFF8, bor(band(rd(s, 0xDFF8), 0x0F), 0xF0))
end

-- ApplyC92C ($0652): low nibble of the mix follows $C92C.
local function applyC92C(s)
  local a = band(rd(s, 0xC92C), 15)
  wr(s, 0xDFF8, bor(band(rd(s, 0xDFF8), 0xF0), a))
end

-- DropCountdownGate ($57A0).
local function dropGate(s)
  setbit(s, 0xDFA6, 7, false)
  for ch = 0, 3 do
    if not testbit(s, 0xDF09 + ch, 1) then
      wr(s, 0xDF9C, ch)
      w16(s, 0xDF7E + ch * 2, 0)
      armCountdownIndex(s, ch)
      releaseChannel(s)
    end
  end
end

-- Music countdown sequencer (bank $30 $57FC and its bank-0 helpers).
-- The tables live in bank [$DFA9]; every read maps that bank, as
-- MapRomBank does around each helper, and bank $30 is mapped back.
local function crd(s, a)
  local save = s.bank
  s.bank = rd(s, 0xDFA9)
  local v = rom(s, a % 65536)
  s.bank = save
  return v
end
local function cbe(s, a) return crd(s, a) * 256 + crd(s, a + 1) end
local function ctab(s) return r16(s, 0xDFA7) end

local function r24(s, a) return rd(s, a) + rd(s, a + 1) * 256 + rd(s, a + 2) * 65536 end
local function w24(s, a, v)
  v = v % 0x1000000
  wr(s, a, v % 256)
  wr(s, a + 1, math.floor(v / 256) % 256)
  wr(s, a + 2, math.floor(v / 65536))
end
-- The walkers fire when the 24-bit count is zero or bit 23 is set.
local function spent(v) return v == 0 or v >= 0x800000 end
local function tick24(s, a, step)
  local v = (r24(s, a) - step) % 0x1000000
  w24(s, a, v)
  return spent(v)
end

-- FillCountdownStep ($577F). ReadCountdownScaleWord ($3D4A) is the
-- big-endian word at [$DFA7] + 4. MultiplyAByBc wraps at 16 bits.
local function fillStep(s)
  local hl = (0x66 * cbe(s, ctab(s) + 4)) % 65536
  w16(s, 0xDFAA, divu(hl, 0x3C))
end

-- SeedCountdownFromTable ($3D65).
local function seedCountdowns(s)
  local t = ctab(s)
  local head = (t - 0x84) % 65536
  for i = 0, 3 do wr(s, 0xDFAD + i, crd(s, head + i)) end
  w16(s, 0xDFB1, head + 4)
  local list = (t + cbe(s, t)) % 65536
  for n = 0, 3 do
    local off = cbe(s, list + n * 2)
    if off ~= 0 then
      w16(s, 0xDFB3 + n * 2, (t + off) % 65536)
      setbit(s, 0xDFA6, n, true)
    end
  end
  for n = 0, 3 do
    wr(s, 0xDFF9, n)
    local p = r16(s, 0xDFB3 + n * 2)
    if p ~= 0 then
      wr(s, 0xDFC1 + n * 3, crd(s, p))
      wr(s, 0xDFC0 + n * 3, crd(s, p + 1))
      local act = crd(s, p + 2)
      wr(s, 0xDFFA, act)
      wr(s, 0xDFBB + n, act)
    end
  end
end

-- AdvanceCountdownRecord ($3E3A): the record moves 3 bytes; a big-endian
-- delta is added to the top two count bytes and the next action is read.
local function advanceRecord(s, n)
  local p = (r16(s, 0xDFB3 + n * 2) + 3) % 65536
  w16(s, 0xDFB3 + n * 2, p)
  local delta, act = cbe(s, p), crd(s, p + 2)
  wr(s, 0xDFBB + n, act)
  w16(s, 0xDFC0 + n * 3, add16(r16(s, 0xDFC0 + n * 3), delta))
end

-- StepIndexedCountdown ($3E78), action $FE.
local function stepIndexed(s, n)
  local p = r16(s, 0xDFB3 + n * 2)
  local addend, delta = cbe(s, p + 3), cbe(s, p + 5)
  w16(s, 0xDFC0 + n * 3, add16(r16(s, 0xDFC0 + n * 3), delta))
  local t = ctab(s)
  local w = cbe(s, t + cbe(s, t) + n * 2)
  local np = (t + w + addend) % 65536
  w16(s, 0xDFB3 + n * 2, np)
  wr(s, 0xDFBB + n, crd(s, np + 2))
end

-- LoadLowerCountdownStream ($3ED4). sla c drops bit 7 of the action.
local function loadLowerStream(s, n, c)
  local t = ctab(s)
  local w = cbe(s, t + cbe(s, t + 2) + band(c * 2, 0xFF))
  w16(s, 0xDFCB + n * 2, (t + w) % 65536)
end

-- AddLowerCountdownDelta ($3F7D). The pointer does not move.
local function addLowerDelta(s, n)
  local p = r16(s, 0xDFCB + n * 2)
  local d = band(crd(s, p), 0x0F) * 256 + crd(s, p + 1)
  w16(s, 0xDFD5 + n * 3, add16(r16(s, 0xDFD5 + n * 3), d))
end

-- ReadExpiredLowerCountdown ($3F0E). Returns A (the $DFFA latch), D, E
-- (the tag nibble) and the span (nil when none is read).
local function readExpired(s, n)
  local p = r16(s, 0xDFCB + n * 2)
  wr(s, 0xDFFA, 0)
  local tag = rshift(crd(s, p), 4)
  local third = crd(s, p + 2)
  p = p + 3
  local d, span, readSpan = third, nil, false
  if band(third, 0x80) == 0 then
    readSpan = true
  elseif not (third == 0xFF and tag == 0x0F) then
    d = band(third, 0x7F)
    if tag == 0 then
      d = bor(d, 0x80)
      wr(s, 0xDFFA, d)
    else
      wr(s, 0xDFFA, bor(crd(s, p), 0x80))
      p = p + 1
      readSpan = true
    end
  end
  if readSpan then
    local x = crd(s, p)
    p = p + 1
    if band(x, 0x80) ~= 0 then
      span = band(x, 0x7F) * 256 + crd(s, p)
      p = p + 1
    else
      span = x
    end
  end
  p = p % 65536
  wr(s, 0xDFFC, rshift(p, 8))
  w16(s, 0xDFCB + n * 2, p)
  return rd(s, 0xDFFA), d, tag, span
end

-- ReadIndexedCountdownByte ($3FB0).
local function indexedByte(s, i)
  return crd(s, add16(r16(s, 0xDFB1), i))
end

-- ServiceLowerCountdownExpiry ($599D). True is its Z return (the caller
-- pumps again). The end mark returns through rlca, which clears Z on
-- the SM83, so that path is false whatever $DFD3 holds.
local function serviceLower(s, n)
  if not spent(r24(s, 0xDFD4 + n * 3)) then return false end
  local a, d, tag, span = readExpired(s, n)
  if band(d, 0x80) ~= 0 then
    if band(a, 0x80) == 0 then
      wr(s, 0xDFD3, band(rd(s, 0xDFD3), bxor(0xFF, lshift(1, n))))
      return false
    end
  end
  if band(a, 0x80) ~= 0 then
    local i = band(a, 0x7F)
    if i < 2 then setbit(s, 0xDFA6, 6, false) end
    wr(s, 0xDFAD + n, indexedByte(s, i))
    if band(d, 0x80) ~= 0 then return true end
  end
  wr(s, 0xDFFD, tag)
  local old = rd(s, 0xDFE4 + n)
  wr(s, 0xDFE4 + n, d)
  wr(s, 0xDFE0 + n, old)
  span = span or 0
  wr(s, 0xDFE8 + n * 3, 0)
  wr(s, 0xDFE9 + n * 3, band(span, 0xFF))
  wr(s, 0xDFEA + n * 3, rshift(span, 8))
  wr(s, 0xDFD3, bor(rd(s, 0xDFD3), lshift(0x10, n)))
  local env = lookupNibble(s, tag, band(rd(s, 0xDFF8), 0x0F))
  wr(s, 0xDFFD, n)
  local ch, c = primeFromTag(s, rd(s, 0xDFAD + n), rd(s, 0xDFE4 + n), env, 0, false, n)
  c = band(ch or c or 0, 0xFF)
  local pack = band(rd(s, 0xDFAC), rom(s, 0x5A75 + n))
  if band(n, 2) ~= 0 then c = bor(band(lshift(c, 4), 0xF0), rshift(c, 4)) end
  if band(n, 1) ~= 0 then c = band(lshift(c, 2), 0xFF) end
  wr(s, 0xDFAC, bor(pack, c))
  return true
end

-- A walker that keeps refilling an expired count from data would spin in
-- the asm; the port stops after this many refills in one frame.
D.SEQ_GUARD = 4096

-- Count guard hits (s.seqGuardHits) and log the first; the asm has no cap.
local function guardHit(s, where)
  s.seqGuardHits = (s.seqGuardHits or 0) + 1
  if s.seqGuardHits == 1 then
    io.stderr:write(("[mn] sound sequencer guard at %s: the asm keeps looping here (outlier)\n"):format(where))
  end
end

-- StartLowerSoundCountdown ($596A).
local function startLower(s, n, c)
  wr(s, 0xDFFB, n)
  wr(s, 0xDFD3, bor(rd(s, 0xDFD3), lshift(1, n)))
  w24(s, 0xDFD4 + n * 3, 0)
  loadLowerStream(s, n, c)
  local g = 0
  repeat
    addLowerDelta(s, n)
    g = g + 1
  until not serviceLower(s, n) or g >= D.SEQ_GUARD
  if g >= D.SEQ_GUARD then guardHit(s, "$596A") end
end

-- StepUpperSoundCountdowns ($58AF).
local function stepUpper(s, step)
  for n = 0, 3 do
    wr(s, 0xDFF9, n)
    local m = lshift(0x10, n)
    if band(rd(s, 0xDFD3), m) ~= 0 and tick24(s, 0xDFE8 + n * 3, step) then
      wr(s, 0xDFD3, band(rd(s, 0xDFD3), bxor(0xFF, m)))
      local ch = band(rshift(rd(s, 0xDFAC), n * 2), 3)
      if not testbit(s, 0xDF09 + ch, 1) then
        wr(s, 0xDF9C, ch)
        armCountdownIndex(s, ch)
      end
    end
  end
end

-- StepLowerSoundCountdowns ($5921).
local function stepLower(s, step)
  for n = 0, 3 do
    wr(s, 0xDFF9, n)
    if testbit(s, 0xDFD3, n) and tick24(s, 0xDFD4 + n * 3, step) then
      local g = 0
      while serviceLower(s, n) and g < D.SEQ_GUARD do
        addLowerDelta(s, n)
        g = g + 1
      end
      if g >= D.SEQ_GUARD then guardHit(s, "$5921") end
    end
  end
end

-- StepSoundCountdowns ($57FC). Bit 7 of $DFA6 is the gate; $DFAA is the
-- per-frame step. Action $FF ends a slot, $FE re-indexes it, anything
-- else starts that slot's lower countdown and moves to the next record.
local function stepCountdowns(s)
  if not testbit(s, 0xDFA6, 7) then return end
  local step = r16(s, 0xDFAA)
  stepUpper(s, step)
  stepLower(s, step)
  for n = 0, 3 do
    wr(s, 0xDFF9, n)
    local a = 0xDFBF + n * 3
    if testbit(s, 0xDFA6, n) and tick24(s, a, step) then
      local g = 0
      while g < D.SEQ_GUARD do
        g = g + 1
        local act = rd(s, 0xDFBB + n)
        if act == 0xFF then setbit(s, 0xDFA6, n, false); break end
        if act == 0xFE then
          stepIndexed(s, n)
        else
          startLower(s, n, act)
          advanceRecord(s, n)
        end
        if not spent(r24(s, a)) then break end
      end
      if g >= D.SEQ_GUARD then guardHit(s, "$57FC") end
    end
  end
end

-- InstallSoundIndex ($5702).
local function installIndex(s, idx)
  if idx >= rom(s, 0x5A87) then return end
  local listOff = rom(s, 0x5A85) + rom(s, 0x5A86) * 256
  local ent = add16(0x5A79, listOff) + idx * 3
  local bank = band(rd(s, 0xDF00) + rom(s, ent), 255)
  local ptr = add16(rom(s, ent + 1) + rom(s, ent + 2) * 256, 0x84)
  wr(s, 0xDFA9, bank)
  w16(s, 0xDFA7, ptr)
  wr(s, 0xDFA6, 0)
  for i = 0, 0x44 do wr(s, 0xDFB3 + i, 0) end
  fillStep(s)
  seedCountdowns(s)
  wr(s, 0xDFAC, 0xE4)
  setbit(s, 0xDFA6, 7, true)
end

local function cmdActive(s)
  wr(s, 0xC91E, 0)
  wr(s, 0xC924, 0)
  dropGate(s)
  installIndex(s, rd(s, 0xC920))
  applyC92C(s)
end

local function cmdSlot(s, which)
  local addr = which == 1 and 0xC921 or 0xC922
  openSlot(s, rd(s, addr), 0x0F, 0x01)
  wr(s, addr, 0xFF)
end

local function latchGate(s)
  if not testbit(s, 0xDFA6, 4) then return end
  setbit(s, 0xDFA6, 4, false)
  setbit(s, 0xDFA6, 7, true)
end

local function cmdSelect0(s)
  local n = band(rd(s, 0xC928) + 1, 255)
  wr(s, 0xC928, n)
  if n ~= rd(s, 0xC929) then applyC92C(s); return end
  wr(s, 0xC928, 0)
  local c = rd(s, 0xC92C)
  if c == 0 or c == 1 then
    wr(s, 0xC920, 0xFF)
    wr(s, 0xC92C, 0)
    wr(s, 0xC92A, 0)
    wr(s, 0xC929, 1)
    applyC92C(s)
    dropGate(s)
  else
    wr(s, 0xC92C, c - 1)
    applyC92C(s)
  end
end

local function cmdSelect1(s)
  local n = band(rd(s, 0xC928) + 1, 255)
  wr(s, 0xC928, n)
  if n ~= rd(s, 0xC929) then applyC92C(s); return end
  wr(s, 0xC928, 0)
  local c = band(rd(s, 0xC92C) + 1, 255)
  if c == 0x0F then
    wr(s, 0xC92C, c)
    wr(s, 0xC92A, 0)
    wr(s, 0xC929, 1)
  else
    wr(s, 0xC92C, c)
  end
  applyC92C(s)
end

local ROM0 = {
  [0x0659] = store0F,
  [0x066F] = function() end,
  [0x0670] = cmdActive,
  [0x0684] = cmdSelect0,
  [0x06C1] = cmdSelect1,
  [0x06F4] = function(s) applyC92C(s); wr(s, 0xC92A, 0) end,
  [0x06FC] = function(s) wr(s, 0xC920, 0xFF); dropGate(s) end,
  [0x0705] = function(s)
    if testbit(s, 0xDFA6, 7) then setbit(s, 0xDFA6, 4, true); dropGate(s) end
  end,
  [0x0709] = latchGate,
  [0x070D] = function(s) cmdSlot(s, 1) end,
  [0x071D] = function(s) cmdSlot(s, 2) end,
  [0x072D] = function(s)
    if testbit(s, 0xDFA6, 7) then setbit(s, 0xDFA6, 4, true); dropGate(s) end
    for i = 0, 0x51 do wr(s, 0xC8C9 + i, rd(s, 0xDFA6 + i)) end
    installIndex(s, rd(s, 0xC925))
  end,
  [0x074F] = function(s)
    local running = band(rd(s, 0xDFA6), 0x0F) ~= 0 or rd(s, 0xDFD3) ~= 0
    if running then return end
    wr(s, 0xC924, 0)
    for i = 0, 0x51 do wr(s, 0xDFA6 + i, rd(s, 0xC8C9 + i)) end
    latchGate(s)
  end,
}

-- SelectSoundCommand ($5897). One command is armed for the next vblank.
function D.select(s)
  local req = rd(s, 0xC91F)
  local function arm(addr) w16(s, 0xC91B, addr) end
  if req ~= 0 then
    wr(s, 0xC91F, 0)
    if band(req, 0x02) ~= 0 then wr(s, 0xC920, 0xFF); arm(0x06FC)
    elseif band(req, 0x04) ~= 0 then arm(0x0709)
    else arm(0x06FC) end
    return
  end
  if rd(s, 0xC91E) ~= 0 then arm(0x0670); return end
  if rd(s, 0xC921) ~= 0xFF then arm(0x070D); return end
  if rd(s, 0xC922) ~= 0xFF then arm(0x071D); return end
  local cd = rd(s, 0xC924)
  if cd ~= 0 then
    if band(cd, 0x02) ~= 0 then
      wr(s, 0xC924, band(cd - 1, 255))
      arm(0x072D)
    elseif rd(s, 0xC92A) == 0 then arm(0x074F) end
    if band(cd, 0x02) ~= 0 or rd(s, 0xC92A) == 0 then return end
  end
  local sel = rd(s, 0xC92A)
  if sel == 0 then arm(0x066F); return end
  if band(sel, 0x01) ~= 0 then wr(s, 0xC920, 0xFF); arm(0x0684); return end
  if band(sel, 0x02) ~= 0 then arm(0x06C1); return end
  arm(0x06F4)
end

-- UpdateSound ($4356). One driver frame after the command.
function D.update(s)
  if rd(s, 0xDF02) ~= 0xF5 then return end
  for i = 0, 5 do wr(s, 0xDF1D + i, 0) end
  if testbit(s, 0xDF74, 7) then advanceWave(s) end
  stepStreams(s)
  stepSlides(s)
  stepPhases(s)
  if testbit(s, 0xDF74, 0) then updateWaveDuty(s) end
  for ch = 2, 0, -1 do
    if testbit(s, 0xDF09 + ch, 5) then
      setbit(s, 0xDF09 + ch, 5, false)
      setbit(s, 0xDF09 + ch, 6, true)
      local ix = ch * 2
      local hl = r16(s, 0xDF15 + ix)
      hl = add16(hl, r16(s, 0xDF1D + ix))
      hl = add16(hl, r16(s, 0xDF23 + ix))
      writePeriod(s, ch, hl)
    end
  end
  for ch = 3, 0, -1 do
    if testbit(s, 0xDF0D + ch, 5) then
      setbit(s, 0xDF0D + ch, 5, false)
      local a = lookupNibble(s, rd(s, 0xDFF4 + ch), rd(s, 0xDF70 + ch))
      writeEnvelope(s, ch, a, false)
    end
  end
  stepCountdowns(s)
end

function D.step(s)
  local cmd = r16(s, 0xC91B)
  local fn = ROM0[cmd]
  if fn then fn(s) end
  s.bank = 0x30
  D.update(s)
end

-- TimerOverflow only. The vblank slice is D.step; calling both from the
-- timer would run scripts at the timer rate.
function D.timerIrq(s)
  if testbit(s, 0xDF74, 6) then feedWave(s) end
end

function D.timerStep(s)
  D.timerIrq(s)
  D.step(s)
end

-- InitSoundState ($5854 in bank 7).
function D.init(s)
  wr(s, 0xC91E, 0)
  wr(s, 0xC926, 0)
  wr(s, 0xC927, 0)
  wr(s, 0xC91F, 0)
  wr(s, 0xC925, 0)
  wr(s, 0xC924, 0)
  wr(s, 0xC92A, 0)
  wr(s, 0xC91D, 0)
  wr(s, 0xC921, 0xFF)
  wr(s, 0xC922, 0xFF)
  wr(s, 0xC920, 0xFF)
  initWork(s)
  wr(s, 0xC91D, 0x55)
  w16(s, 0xC91B, 0x0659)
  store0F(s)
  -- Reset leaves the timer running and the CPU doubled, and TurnOnLCD
  -- enables vblank plus STAT only, so the driver is the vblank slice.
  wr(s, 0xFF07, 0x04)
  wr(s, 0xFF06, 0xBF)
  wr(s, 0xFF4D, 0x80)
  wr(s, 0xFFFF, 0x03)
  s.carry = false
end

function D.busy(s)
  for i = 0, 3 do
    if r16(s, 0xDF7E + i * 2) ~= 0 then return true end
    local f = rd(s, 0xDF0D + i)
    if band(f, 0x0B) ~= 0 and rd(s, 0xDF70 + i) ~= 0 then return true end
  end
  if testbit(s, 0xDF74, 6) or testbit(s, 0xDF74, 7) or testbit(s, 0xDF74, 0) then
    return true
  end
  return s.apu:audible(s)
end

function D.request(s, kind, id)
  id = band(id or 0, 255)
  if kind == "slotA" or kind == 1 or kind == "a" then wr(s, 0xC921, id)
  elseif kind == "slotB" or kind == 2 or kind == "b" then wr(s, 0xC922, id)
  elseif kind == "request" then wr(s, 0xC91F, id)
  elseif kind == "active" then wr(s, 0xC920, id); wr(s, 0xC91E, 1)
  elseif kind == "select" then wr(s, 0xC92A, id)
  elseif kind == "countdown" then wr(s, 0xC924, id)
  end
end

return D
