-- GB APU sample model for the channels the sound driver writes.
-- Duty widths, pulse clock 131072/(2048-period), wave clock one octave
-- down, and the noise LFSR match MnMusic.renderGB. This is not that
-- note renderer: registers here are the ones update_sound.asm's helpers
-- store (NR10-NR44, wave RAM).
local bit = require("bit")
local band, bor, rshift, lshift = bit.band, bit.bor, bit.rshift, bit.lshift

local M = {}
M.__index = M

local DUTY = { [0] = 0.125, 0.25, 0.5, 0.75 }
-- Frame sequencer is 512 Hz on the 4.194304 MHz APU clock (normal speed
-- even when the CPU is doubled). Envelope steps every 8 ticks (64 Hz).
local SEQ_CYCLES = 8192
local CPU_HZ = 4194304

local function u8(sfx, a) return sfx.mem[a] or 0 end

function M.new()
  return setmetatable({
    phase = { [0] = 0, 0, 0, 0 },
    envVol = { [0] = 0, 0, 0, 0 },
    envT = { [0] = 0, 0, 0, 0 },
    envP = { [0] = 0, 0, 0, 0 },
    envAdd = { [0] = false, false, false, false },
    dac = { [0] = false, false, false, false },
    lfsr = 0x7FFF,
    nacc = 0,
    seq = 0,
    step = 0,
    len = { [0] = 0, 0, 0, 0 },
    lenOn = { [0] = false, false, false, false },
  }, M)
end

-- NRx4 write with the trigger bit. Reload the envelope from NRx2 the way
-- the hardware does when WriteChannelEnvelope / RestartChannel pulse it.
function M:trigger(sfx, ch)
  local nrx2 = ({ [0] = 0xFF12, 0xFF17, 0xFF1C, 0xFF21 })[ch]
  local nrx4 = ({ [0] = 0xFF14, 0xFF19, 0xFF1E, 0xFF23 })[ch]
  local v = u8(sfx, nrx2)
  if ch == 2 then
    self.dac[2] = band(u8(sfx, 0xFF1A), 0x80) ~= 0
    local lvl = band(rshift(v, 5), 3)
    self.envVol[2] = ({ [0] = 0, 1, 0.5, 0.25 })[lvl]
  else
    self.envVol[ch] = rshift(v, 4)
    self.envAdd[ch] = band(v, 0x08) ~= 0
    self.envP[ch] = band(v, 7)
    self.envT[ch] = self.envP[ch]
    self.dac[ch] = band(v, 0xF8) ~= 0
  end
  self.lenOn[ch] = band(u8(sfx, nrx4), 0x40) ~= 0
  self.phase[ch] = 0
end

function M:write(sfx, addr, val)
  if addr == 0xFF26 and band(val, 0x80) == 0 then
    for ch = 0, 3 do self.dac[ch] = false; self.envVol[ch] = 0 end
    return
  end
  if addr == 0xFF14 or addr == 0xFF19 or addr == 0xFF1E or addr == 0xFF23 then
    if band(val, 0x80) ~= 0 then
      local ch = addr == 0xFF14 and 0 or addr == 0xFF19 and 1 or addr == 0xFF1E and 2 or 3
      self:trigger(sfx, ch)
    end
  elseif addr == 0xFF1A then
    self.dac[2] = band(val, 0x80) ~= 0
    if not self.dac[2] then self.envVol[2] = 0 end
  end
end

local function period(sfx, lo, hi)
  return bor(u8(sfx, lo), lshift(band(u8(sfx, hi), 7), 8))
end

local function clockSeq(self)
  self.step = (self.step + 1) % 8
  if self.step % 2 == 0 then
    for ch = 0, 3 do
      if self.lenOn[ch] and self.len[ch] > 0 then
        self.len[ch] = self.len[ch] - 1
        if self.len[ch] == 0 then self.envVol[ch] = 0 end
      end
    end
  end
  if self.step == 7 then
    for ch = 0, 3 do
      if ch ~= 2 and self.dac[ch] and self.envP[ch] ~= 0 then
        if self.envT[ch] > 0 then self.envT[ch] = self.envT[ch] - 1 end
        if self.envT[ch] == 0 then
          self.envT[ch] = self.envP[ch]
          local vol = self.envVol[ch]
          if self.envAdd[ch] then
            if vol < 15 then self.envVol[ch] = vol + 1 end
          elseif vol > 0 then
            self.envVol[ch] = vol - 1
          end
        end
      end
    end
  end
end

-- One mono sample in -1..1. NR51 pans by averaging the two terminals.
-- NR50 is the master (ResetApu leaves $77).
function M:sample(sfx, rate)
  self.seq = self.seq + CPU_HZ / rate
  while self.seq >= SEQ_CYCLES do
    self.seq = self.seq - SEQ_CYCLES
    clockSeq(self)
  end
  if band(u8(sfx, 0xFF26), 0x80) == 0 then return 0 end
  local nr51 = u8(sfx, 0xFF25)
  local nr50 = u8(sfx, 0xFF24)
  local master = (band(nr50, 7) + band(rshift(nr50, 4), 7)) / 14
  if master == 0 then master = 1 end
  local acc = 0
  for ch = 0, 3 do
    local bitR, bitL = lshift(1, ch), lshift(1, ch + 4)
    local pan = 0
    if band(nr51, bitL) ~= 0 then pan = pan + 1 end
    if band(nr51, bitR) ~= 0 then pan = pan + 1 end
    if pan ~= 0 and self.dac[ch] and self.envVol[ch] ~= 0 then
      local x
      if ch == 3 then
        local nr = u8(sfx, 0xFF22)
        local sh, wid, dv = rshift(nr, 4), band(rshift(nr, 3), 1), band(nr, 7)
        local nfreq = 524288 / (dv == 0 and 0.5 or dv) / 2 ^ (sh + 1)
        self.nacc = self.nacc + nfreq / rate
        while self.nacc >= 1 do
          self.nacc = self.nacc - 1
          local bitv = band(self.lfsr, 1) ~= band(rshift(self.lfsr, 1), 1) and 1 or 0
          self.lfsr = rshift(self.lfsr, 1) + bitv * 16384
          if wid == 1 then
            self.lfsr = self.lfsr - band(rshift(self.lfsr, 6), 1) * 64 + bitv * 64
          end
        end
        x = band(self.lfsr, 1) == 0 and 1 or -1
        x = x * (self.envVol[3] / 15) * 0.45
      elseif ch == 2 then
        local per = period(sfx, 0xFF1D, 0xFF1E)
        local f = 65536 / math.max(1, 2048 - per)
        self.phase[2] = (self.phase[2] + f / rate) % 1
        local k = math.floor(self.phase[2] * 32) % 32
        local b = u8(sfx, 0xFF30 + math.floor(k / 2))
        local nib = (k % 2 == 0) and rshift(b, 4) or band(b, 15)
        x = ((nib - 7.5) / 7.5) * self.envVol[2]
      else
        local per = period(sfx, ch == 0 and 0xFF13 or 0xFF18, ch == 0 and 0xFF14 or 0xFF19)
        local f = 131072 / math.max(1, 2048 - per)
        self.phase[ch] = (self.phase[ch] + f / rate) % 1
        local duty = DUTY[rshift(u8(sfx, ch == 0 and 0xFF11 or 0xFF16), 6)] or 0.5
        x = (self.phase[ch] < duty) and 1 or -1
        x = x * (self.envVol[ch] / 15)
      end
      acc = acc + x * (pan / 2)
    end
  end
  local v = acc * master * 0.45
  if v > 1 then v = 1 elseif v < -1 then v = -1 end
  return v
end

function M:audible(sfx)
  if band(u8(sfx, 0xFF26), 0x80) == 0 then return false end
  local nr51 = u8(sfx, 0xFF25)
  for ch = 0, 3 do
    local bits = bor(lshift(1, ch), lshift(1, ch + 4))
    if band(nr51, bits) ~= 0 and self.dac[ch] and self.envVol[ch] ~= 0 then return true end
  end
  return false
end

return M
