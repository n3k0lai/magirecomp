-- SFX half of the bank $30 driver (update_sound.asm, select_sound_command.asm).
-- Pure Lua. No love.audio. The host queues sfx:render(n).
local bit = require("bit")
local Apu = require("mn.sfx.Apu")
local Driver = require("mn.sfx.Driver")

local M = {}
M.__index = M

-- 44100 Hz samples. One driver frame is a vblank (4194304/70224).
M.RATE = 44100
M.FRAME_HZ = 4194304 / 70224

-- Timer divider for TAC bits 1-0 (normal-speed APU clock).
local TAC_DIV = { [0] = 1024, 16, 64, 256 }

function M.new(rom)
  local s = setmetatable({
    rom = rom,
    mem = {},
    bank = 0x30,
    carry = false,
    apu = Apu.new(),
  }, M)
  Driver.init(s)
  return s
end

function M:rd(a) return self.mem[a] or 0 end

function M:wr(a, v)
  v = v % 256
  if v < 0 then v = v + 256 end
  self.mem[a] = v
  if a >= 0xFF10 and a <= 0xFF3F then self.apu:write(self, a, v) end
end

function M:r16(a) return self:rd(a) + self:rd(a + 1) * 256 end

function M:w16(a, v)
  v = v % 65536
  if v < 0 then v = v + 65536 end
  self:wr(a, v % 256)
  self:wr(a + 1, math.floor(v / 256) % 256)
end

-- Banked read. Bank 0 for addresses below $4000; s.bank otherwise
-- (CallBankedHL / wave copies switch it). MnRom.off is a function.
function M:rom8(addr)
  addr = addr % 65536
  local o = addr < 0x4000 and addr or self.rom.off(addr, self.bank)
  return self.rom:u8(o) or 0
end

function M:request(kind, id) Driver.request(self, kind, id) end
function M:select() Driver.select(self) end
function M:step() Driver.step(self) end
function M:busy() return Driver.busy(self) end

-- NR51. A host that also runs MnMusic can duck channels this byte routes.
function M:routed() return self:rd(0xFF25) end

-- TimerOverflow while StartSoundTimer has the timer unmasked and bit 6 of
-- $DF74 set (feed_wave_from_timer.asm). Stock snd_select_wave does not.
function M:_timer()
  local ie, tac = self:rd(0xFFFF), self:rd(0xFF07)
  if bit.band(ie, 4) == 0 or bit.band(tac, 4) == 0 then return end
  if bit.band(self:rd(0xDF74), 0x40) == 0 then return end
  local div = TAC_DIV[bit.band(tac, 3)]
  local span = 256 - self:rd(0xFF06)
  if span <= 0 then span = 256 end
  local hz = 4194304 / (div * span)
  self._tacc = (self._tacc or 0) + hz / M.RATE
  while self._tacc >= 1 do
    self._tacc = self._tacc - 1
    Driver.timerIrq(self)
  end
end

-- n mono floats in -1..1. Selects and steps once per vblank, starting on
-- the first sample so the attack is not delayed a frame.
function M:render(n)
  local out = {}
  local left = self._left
  if not left then
    self:select()
    self:step()
    left = M.RATE / M.FRAME_HZ
  end
  for i = 1, n do
    while left <= 0 do
      self:select()
      self:step()
      left = left + M.RATE / M.FRAME_HZ
    end
    self:_timer()
    out[i] = self.apu:sample(self, M.RATE)
    left = left - 1
  end
  self._left = left
  return out
end

-- Overworld host hooks. ow.vm.rom or ow.rom. Reuses SfxOut's driver when
-- the field already built one, so requests and playback are the same Sfx.
-- Driver WRAM is not the VM's: opcodes copy the bytes the selector reads.
function M.host(ow, h)
  local rom = (ow.vm and ow.vm.rom) or ow.rom
  local sfx = (ow.sfxOut and ow.sfxOut.sfx) or M.new(rom)
  ow.sfx = sfx
  h.sfx = function(kind) sfx:request("request", kind) end
  h.sfxSlot = function(slot, id)
    sfx:request(slot == 1 and "slotA" or "slotB", id)
  end
  h.sfxRequest = function(id) sfx:request("request", id) end
  -- opcode_22.asm / opcode_23.asm. SoundSelectOther and SoundSelectBit1
  -- read $C928 / $C929 / $C92C; request("select") writes $C92A.
  h.sfxSelect = function(sel, c928, c929, c92c)
    sfx:wr(0xC928, c928 or 0)
    sfx:wr(0xC929, c929 or 0)
    sfx:wr(0xC92C, c92c or 0)
    sfx:request("select", sel)
  end
  return sfx
end

return M
