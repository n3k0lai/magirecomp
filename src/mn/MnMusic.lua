-- Magi-Nation song decoder + simple chip renderer.
-- Format: mn-gfx scripts/own/music-format.md (bank $30 SongList at $6182,
-- songs in banks $32-$3C). Instruments are MusyX programs we do not decode
-- yet; slots 0/1 render as pulse, slot 2 as triangle-ish wave, slot 3 as
-- noise when its notes sit in the GM drum range.
local M = {}
M.TICK = 1 / 59.73

-- rd(bank, ptr) -> byte
local function be(rd, b, p) return rd(b, p) * 256 + rd(b, p + 1) end

function M.songCount(rd) return rd(0x30, 0x5A87) end

function M.songAddr(rd, i)
  local e = 0x6182 + i * 3
  return 0x30 + rd(0x30, e), rd(0x30, e + 1) + rd(0x30, e + 2) * 256
end

-- Returns { tempo, notes = { {t, slot, note, len, vel}... }, length }
function M.decode(rd, i, maxSec)
  maxSec = maxSec or 90
  local b, s = M.songAddr(rd, i)
  local T = s + 0x84
  local tracks, pats = T + be(rd, b, T), T + be(rd, b, T + 2)
  local tempo = be(rd, b, T + 4)
  local step = tempo * 0x66 / 0x3C          -- 24-bit count per tick
  local unit = 256 / step * M.TICK          -- seconds per delta unit
  local notes, last = {}, 0
  local startProg = { [0] = rd(b, s), rd(b, s + 1), rd(b, s + 2), rd(b, s + 3) }
  local progMap = function(pg) return rd(b, s + 4 + (pg % 128)) end
  for slot = 0, 3 do
    local to = be(rd, b, tracks + slot * 2)
    if to ~= 0 then
      local start = T + to
      local p, t, guard = start, 0, 0
      local segs = {}
      while guard < 512 and t < maxSec do
        guard = guard + 1
        t = t + be(rd, b, p) * unit -- delta adds to the high 16 bits of the count
        local act = rd(b, p + 2)
        if act == 0xFF then break
        elseif act == 0xFE then
          p = start + be(rd, b, p + 3)
          if guard > 64 then break end
        else
          segs[#segs + 1] = { t = t, pat = act % 128 }; p = p + 3
        end
      end
      local slotProg = startProg[slot]
      for k, sg in ipairs(segs) do
        local stopAt = segs[k + 1] and segs[k + 1].t or maxSec
        local q = T + be(rd, b, pats + sg.pat * 2)
        local tt, n = sg.t, 0
        local prog = slotProg
        while n < 4096 do
          n = n + 1
          local h0, h1 = rd(b, q), rd(b, q + 1)
          local tag = math.floor(h0 / 16)
          tt = tt + ((h0 % 16) * 256 + h1) * unit
          local e = rd(b, q + 2)
          if e == 0xFF and tag == 0xF then break end
          local note, len
          if e < 0x80 then note = e; q = q + 3
          elseif tag == 0 then prog = rd(b, q + 2) - 0x80; q = q + 3 -- ev_prog
          else note = e - 0x80; prog = rd(b, q + 3); q = q + 4 end -- ev_note_prog
          if note then
            local l = rd(b, q)
            if l >= 0x80 then len = (l - 0x80) * 256 + rd(b, q + 1); q = q + 2 else len = l; q = q + 1 end
            if tt >= stopAt then break end
            notes[#notes + 1] = { t = tt, slot = slot, note = note, len = math.max(len * unit, 0.03), vel = tag / 15, prog = prog, inst = progMap(prog) }
            if tt + len * unit > last then last = tt + len * unit end
          end
        end
        slotProg = prog
      end
    end
  end
  return { tempo = tempo, notes = notes, length = math.min(last, maxSec), bank = b, ptr = s }
end

-- Instruments: the program map yields a stream index into bank $30's
-- SoundStreamTable ($5A88, 50 LE offsets from $5A88). Songs use streams
-- $26-$31. We read the commands that shape a note (mn-gfx music-format.md):
-- snd_skip = hardware channel, snd_duty, snd_noise (NR43), snd_env_mix
-- (start volume), snd_envelope after a wait (decay), snd_env_level 0 (cut),
-- snd_slide (pitch slide: scaled to ~0, full-rate slides cut capture match 0.72->0.59), snd_wait $01 (hold).
local SND_LEN = { [0] = 1, 4, 6, 6, 5, 4, 3, 3, 4, 2, 2, 5, 2, 1, 2, 2, 2, 3, 2, 2, 3, 4, 4, 4, 3, 1, 2, 5, 3, 5, 5, 1, 1, 2, 1, 1, 2, 1, 3, 3, 2, 3 }
M.SND_LEN = SND_LEN

function M.instrument(rd, idx)
  local base = 0x5A88
  local so = base + rd(0x30, base + idx * 2) + rd(0x30, base + idx * 2 + 1) * 256
  local ins = { idx = idx, ch = 0, duty = 2, vol = 15, ev = {} }
  local t, q = 0, so
  for _ = 1, 40 do
    local op = rd(0x30, q); local n = SND_LEN[op]
    if not n or op == 0x00 or op == 0x23 or op == 0x0D or op == 0x06 then break end
    local a1 = rd(0x30, q + 1)
    if op == 0x0E then ins.ch = a1 % 4
    elseif op == 0x0C then ins.duty = a1 % 4
    elseif op == 0x10 then if ins.noise then ins.ev[#ins.ev + 1] = { t = t, kind = "noise", v = a1 } else ins.noise = a1 end
    elseif op == 0x09 then ins.vol = a1 % 16
    elseif op == 0x13 then ins.ev[#ins.ev + 1] = { t = t, kind = "decay", v = a1 }
    elseif op == 0x28 then ins.ev[#ins.ev + 1] = { t = t, kind = "level", v = a1 }
    elseif op == 0x08 then ins.ev[#ins.ev + 1] = { t = t, kind = "slide", mode = a1, v = rd(0x30, q + 2) * 256 + rd(0x30, q + 3) }
    elseif op == 0x01 then -- ArmChannelVibrato: step word (1/256 semitone), half-period frames
      ins.vib = { step = a1 * 256 + rd(0x30, q + 2), half = rd(0x30, q + 3), t = t }
    elseif op == 0x03 then -- ArmChannelRamp: signed step/frame, fold limit (8.8 semitones)
      local function s16(v) return v >= 32768 and v - 65536 or v end
      ins.ramps = ins.ramps or {}
      ins.ramps[#ins.ramps + 1] = { t = t, step = s16(a1 * 256 + rd(0x30, q + 2)), lim = s16(rd(0x30, q + 3) * 256 + rd(0x30, q + 4)) }
    elseif op == 0x11 then -- StartPhase: level $0F, then signed step/frame on 8.8 volume
      local v = rd(0x30, q + 1) + rd(0x30, q + 2) * 256; if v >= 32768 then v = v - 65536 end
      ins.ev[#ins.ev + 1] = { t = t, kind = "vramp", v = v }
    elseif op == 0x0A and ins.ch == 3 then ins.ev[#ins.ev + 1] = { t = t, kind = "out", v = a1 }
    elseif op == 0x20 or op == 0x1F then ins.ev[#ins.ev + 1] = { t = t, kind = "noslide" }
    elseif op == 0x04 then
      if a1 == 1 then ins.hold = true; break end
      t = t + rd(0x30, q + 4) + rd(0x30, q + 3) * 256
    elseif op == 0x1A and idx == 0x26 then ins.silent = true end
    q = q + n
  end
  return ins
end

-- 32 4-bit samples from WaveRecords ($30:$616A -> bank $31). Record 0 is a
-- 12-frame streamed sample; 1-3 are single-cycle waves for tones.
function M.wave(rd, rec)
  rec = rec or M.WAVE_REC or 3
  local r0 = 0x616A + rec * 6
  local p = rd(0x30, r0) + rd(0x30, r0 + 1) * 256
  local bank = 0x30 + rd(0x30, r0 + 5)
  local w = {}
  for k = 0, 15 do
    local v = rd(bank, p + k)
    w[2 * k] = math.floor(v / 16) / 7.5 - 1; w[2 * k + 1] = (v % 16) / 7.5 - 1
  end
  return w
end

-- WaveRecords[0]: the streamed sample SFX $20/$25 start with snd_select_wave
-- $00. FeedWaveFromTimer copies 16 bytes (32 nibbles) into wave RAM per tick
-- and retriggers; the record's word 1 (12) is the block count. A block whose
-- high nibble is 7 is a hold (next byte = repeat count, rest silence). Rate
-- here assumes one block per video frame (TMA at $DF08 not yet traced).
function M.sample(rd, rate)
  local r0 = 0x616A
  local p = rd(0x30, r0) + rd(0x30, r0 + 1) * 256
  local n = rd(0x30, r0 + 2) + rd(0x30, r0 + 3) * 256
  local bank = 0x30 + rd(0x30, r0 + 5)
  local out, per = {}, rate / 59.73 / 32
  for b = 0, n - 1 do
    for k = 0, 31 do
      local v = rd(bank, p + b * 16 + math.floor(k / 2))
      local nib = (k % 2 == 0) and math.floor(v / 16) or v % 16
      local x = (nib - 7.5) / 7.5
      for _ = 1, math.max(1, math.floor(per + 0.5)) do out[#out + 1] = x * 0.6 end
    end
  end
  return out
end

local DUTY = { [0] = 0.125, 0.25, 0.5, 0.75 }
M.WAVE_REC, M.WAVE_LEVEL, M.NOISE_GAIN = 3, 2, 0.3
M.SLIDE_SEMI = tonumber(os.getenv("MN_SLS") or "")
-- PyBoy raw (NR50=$77): AC rms 0.184 / peak 0.60 of 4ch*15 full scale; ours was 0.341
M.MASTER = tonumber(os.getenv("MN_MASTER") or "") or 0.54
M.HOLD_NEXT = os.getenv("MN_HOLD") ~= "0"
M.VIBRATO = os.getenv("MN_VIB") ~= "0"
M.RAMPS = os.getenv("MN_RAMP") ~= "0" -- tuned against PyBoy capture of song $27

-- GB-style 4-channel render: each hardware channel is monophonic (a new
-- note cuts the old one), like the real APU the driver feeds.
function M.renderGB(song, rate, put, rd)
  local N = math.floor(song.length * rate) + 1
  local buf = {}
  for i = 0, N - 1 do buf[i] = 0 end
  local insts, wave = {}, M.wave(rd, tonumber(os.getenv("MN_WAVE") or ""))
  local byCh = { [0] = {}, {}, {}, {} }
  for _, nt in ipairs(song.notes) do
    local ins = insts[nt.inst] or M.instrument(rd, nt.inst); insts[nt.inst] = ins
    if not ins.silent then local l = byCh[ins.ch]; l[#l + 1] = { nt = nt, ins = ins } end
  end
  local F = 1 / 59.73
  for ch = 0, 3 do
    local list = byCh[ch]
    table.sort(list, function(a, b) return a.nt.t < b.nt.t end)
    for k, e in ipairs(list) do
      local nt, ins = e.nt, e.ins
      local stop = nt.t + nt.len
      if ins.hold and M.HOLD_NEXT then stop = list[k + 1] and list[k + 1].nt.t or stop end
      if list[k + 1] and list[k + 1].nt.t < stop then stop = list[k + 1].nt.t end
      if not ins.hold then -- one-shot: lasts until its envelope empties (cap 1 s)
        local endT = 0; for _, ev in ipairs(ins.ev) do if ev.t * F > endT then endT = ev.t * F end end
        stop = math.min(list[k + 1] and list[k + 1].nt.t or 1e9, nt.t + math.max(endT + 0.25, 0.06))
      end
      local i0, i1 = math.floor(nt.t * rate), math.min(N - 1, math.floor(stop * rate))
      local vol0 = ins.vol / 15 * (0.35 + 0.65 * nt.vel)
      local f0 = 440 * 2 ^ ((nt.note - 69) / 12)
      local period = 2048 - 131072 / f0
      local ph, lfsr, nacc = 0, 0x7FFF, 0
      local decayAt, decayRate, cutAt, slide, vramp = nil, 0, nil, nil, nil
      local noiseEv = {}
      for _, ev in ipairs(ins.ev) do
        if ev.kind == "decay" then decayAt = ev.t * F; decayRate = math.max(1, ev.v)
        elseif ev.kind == "level" and ev.v == 0 then cutAt = ev.t * F
        elseif ev.kind == "vramp" then vramp = { at = ev.t * F, v = ev.v }
        elseif ev.kind == "noise" then noiseEv[#noiseEv + 1] = ev
        elseif ev.kind == "slide" then slide = { at = ev.t * F, d = (ev.mode == 1 and -1 or 1) * ev.v } end
      end
      local nfreq
      if ch == 3 then
        local nr = ins.noise or 0x21
        local sh, wid, dv = math.floor(nr / 16), math.floor(nr / 8) % 2, nr % 8
        nfreq = 524288 / (dv == 0 and 0.5 or dv) / 2 ^ (sh + 1); e.wid = wid
      end
      for i = i0, i1 do
        local tt = (i - i0) / rate
        if cutAt and tt >= cutAt then break end
        local v = vol0
        if vramp and tt >= vramp.at then
          local lv = 15 + (tt - vramp.at) * 59.73 * vramp.v / 256
          if lv <= 0 then break end
          v = vol0 * math.min(15, lv) / 15
        end
        if decayAt and tt >= decayAt then v = vol0 - (tt - decayAt) * 64 / decayRate / 15; if v <= 0 then break end end
        local x
        if ch == 3 and #noiseEv > 0 then
          for _, ev in ipairs(noiseEv) do if tt >= ev.t * F and not ev.done then
            local sh, dv = math.floor(ev.v / 16), ev.v % 8
            nfreq = 524288 / (dv == 0 and 0.5 or dv) / 2 ^ (sh + 1); e.wid = math.floor(ev.v / 8) % 2
          end end
        end
        if ch == 3 then
          nacc = nacc + nfreq / rate
          while nacc >= 1 do
            nacc = nacc - 1
            local bitv = (lfsr % 2) ~= (math.floor(lfsr / 2) % 2) and 1 or 0
            lfsr = math.floor(lfsr / 2) + bitv * 16384
            if e.wid == 1 then lfsr = lfsr - (math.floor(lfsr / 64) % 2) * 64 + bitv * 64 end
          end
          x = (lfsr % 2 == 0) and 1 or -1
        else
          local per = period
          local fr = tt * 59.73
          local semi = 0
          if ins.vib and M.VIBRATO and fr >= ins.vib.t then -- triangle latch (StepChannelSlides bit 0), $DF1D cleared per frame
            local h = math.max(1, ins.vib.half); local n = math.floor(fr - ins.vib.t)
            local first = math.max(1, math.floor(h / 2))
            local lat
            if n < first then lat = (n + 1) else
              local m = (n - first) % (2 * h); local dir = (math.floor((n - first) / h) % 2 == 0) and -1 or 1
              local k = m % h + 1; lat = first + dir * k
              if math.floor((n - first) / h) % 2 == 1 then lat = first - h + k end
            end
            semi = semi + lat * ins.vib.step / 256
          end
          if ins.ramps and M.RAMPS then
            local acc, base = 0, 0
            for _, r in ipairs(ins.ramps) do if fr >= r.t then
              acc = math.floor(fr - r.t) * r.step
              if (r.step > 0 and acc > r.lim) or (r.step < 0 and acc < r.lim) then acc = r.lim end
              base = acc
            end end
            semi = semi + base / 256
          end
          if slide and M.SLIDE_SEMI and tt >= slide.at then semi = semi + slide.d * (tt - slide.at) * 59.73 / 256 * M.SLIDE_SEMI
          elseif slide and tt >= slide.at then per = math.max(0, math.min(2047, period + slide.d * (tt - slide.at) * 59.73 / (tonumber(os.getenv("MN_SD") or "") or 4096))) end
          if semi ~= 0 then per = 2048 - (2048 - per) / 2 ^ (semi / 12) end
          -- the wave channel (NR33/34) runs at 65536/(2048-x): same period, one octave down
          local f = (ch == 2 and 65536 or 131072) / (2048 - per)
          ph = (ph + f / rate) % 1
          if ch == 2 then
            local wv = tonumber(os.getenv("MN_WL") or "") or M.WAVE_LEVEL or 1
            x = wave[math.floor(ph * 32) % 32] * wv
          else x = ph < DUTY[ins.duty] and 1 or -1 end
        end
        buf[i] = buf[i] + x * v * 0.2 * (ch == 3 and (tonumber(os.getenv("MN_NG") or "") or M.NOISE_GAIN or 0.5) or 1)
      end
    end
  end
  -- one-pole lowpass (cutoff MN_LP Hz, default 6000): tames naive square harmonics
  local fc = tonumber(os.getenv("MN_LP") or "") or 6000
  local a = 1 - math.exp(-2 * math.pi * fc / rate)
  local y = 0
  for i = 0, N - 1 do
    y = y + a * (buf[i] - y)
    local v = y * M.MASTER; if v > 1 then v = 1 elseif v < -1 then v = -1 end
    put(i, v)
  end
  return N
end

-- Render to a mono float buffer via put(i, sample).
function M.render(song, rate, put)
  local N = math.floor(song.length * rate) + 1
  local buf = {}
  for i = 0, N - 1 do buf[i] = 0 end
  local seed = 0x7FFF
  for _, nt in ipairs(song.notes) do
    local f = 440 * 2 ^ ((nt.note - 69) / 12)
    local i0 = math.floor(nt.t * rate)
    local i1 = math.min(N - 1, i0 + math.floor(nt.len * rate))
    local drum = nt.slot == 3
    local amp = 0.12 * (0.4 + 0.6 * nt.vel)
    local ph = 0
    for i = i0, i1 do
      local k = (i - i0) / rate
      local env = math.exp(-k * (drum and 18 or 2.5))
      local v
      if drum then
        seed = (seed * 1103515245 + 12345) % 2147483648
        v = (seed / 1073741824 - 1) * 0.8
      else
        ph = (ph + f / rate) % 1
        if nt.slot == 2 then v = (ph < 0.5 and ph * 4 - 1 or 3 - ph * 4)
        else v = (ph < (nt.slot == 0 and 0.5 or 0.25)) and 1 or -1 end
      end
      buf[i] = buf[i] + v * amp * env
    end
  end
  for i = 0, N - 1 do
    local v = buf[i]; if v > 1 then v = 1 elseif v < -1 then v = -1 end
    put(i, v)
  end
  return N
end

return M
