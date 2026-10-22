-- Headless CGB machine for the battle-scene generator (mn.fx.Gen). It runs the game's own routines,
-- translated instruction by instruction to Lua (mn.fx.Blocks), against the player's ROM. Nothing from
-- the ROM is stored here.
--
-- The CPU/PPU/timer/DMA timing follows the PyBoy emulator rule for rule, so a run can be checked frame
-- for frame against it: interrupts are taken at the same instruction boundaries, IO reads see the same
-- mid-instruction state, and a snapshot holds what PyBoy reports for the frame (VRAM, palettes, OAM,
-- per-line scroll and window). PyBoy is (C) Mads Ynddal and contributors, LGPL-3.0-only,
-- https://github.com/Baekalfen/PyBoy; this timing logic is adapted from its core/{cpu,mb,lcd,timer}.py
-- (see NOTICE.md).
local band, bor, bxor, lshift, rshift, bnot = bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift, bit.bnot
local floor, min, max = math.floor, math.min, math.max
local byte = string.byte
local MAXC = 2 ^ 31
local FRAME = 70224
local ST_NONE, ST_ADV, ST_M2, ST_PRE = 0, 1, 2, 3
local M = {}
M.__index = M

local function zeros(n) local t = {} for i = 0, n - 1 do t[i] = 0 end return t end

local function daa(a, n, h, c)
  if not n then
    if c or a > 0x99 then a = a + 0x60; c = true end
    if h or band(a, 0x0F) > 0x09 then a = a + 0x06 end
  else
    if c then a = a - 0x60 end
    if h then a = a - 0x06 end
  end
  a = band(a, 0xFF)
  return a, a == 0, false, c
end

function M.new(rom, blocksfactory)
  local m = setmetatable({}, M)
  m.rom = rom; m.nromb = floor(#rom / 0x4000); m.nramb = 4
  m.rombank, m.ramg, m.srambank = 1, false, 0
  m.sram = {}; for b = 0, 15 do m.sram[b] = zeros(0x2000) end
  m.wram = {}; for b = 0, 7 do m.wram[b] = zeros(0x1000) end
  m.wsel = 0
  m.vram = { [0] = zeros(0x2000), [1] = zeros(0x2000) }; m.vbk = 0
  m.oam = zeros(0xA0); m.hram = zeros(0x7F); m.nonio = zeros(0x60); m.io = zeros(0x80)
  m.undoc = { [0] = 0, 0, 0, 0 }
  -- cpu
  m.PC, m.IME, m.eidelay, m.halted, m.hde, m.queued, m.IE, m.IF = 0x100, false, 0, false, false, false, 0, 0
  m.bail = false; m.key1 = 0; m.double = false; m.SB, m.SC = 0, 0
  -- lcd
  m.LCDC, m.STAT, m.mode, m.irqline = 0, 0x80, 0, false
  m.LY, m.LYC, m.SCY, m.SCX, m.WY, m.WX = 0, 0, 0, 0, 0, 0
  m.BGP, m.OBP0, m.OBP1, m.opm = 0xFC, 0xFF, 0xFF, 0xFF
  m.clock, m.ctarget, m.llast, m.shift = 0, FRAME, 0, 0
  m.frame_done, m.first_frame, m.reset, m.smo, m.lycdis = false, false, false, false, false
  m.nextmode, m.strans, m.m3adj = 2, ST_NONE, 0
  m.lcti, m.lctf = 0, FRAME
  m.scan = {}; for y = 0, 143 do m.scan[y] = { 0, 0, -7, 0 } end
  -- palettes (word memories, index registers)
  m.bmem, m.omem = {}, {}
  local c4 = { 0x1CE7, 0x1E19, 0x7E31, 0x217B }
  for i = 0, 31 do m.bmem[i] = c4[i % 4 + 1]; m.omem[i] = c4[i % 4 + 1] end
  m.bcps, m.ocps = 0, 0
  -- timer
  m.DIVc, m.TIMA, m.TMA, m.TAC, m.reload, m.TIMAc, m.tlast, m.tcti = 0, 0, 0, 0, 0, 0, 0, MAXC
  -- dma
  m.dma_active, m.dma_reading, m.dma_src, m.dma_idx, m.dma_start = false, false, 0, 0, 0
  m.h1, m.h2, m.h3, m.h4, m.h5, m.hact, m.hsrc, m.hdst = 0, 0, 0, 0, 0xFF, false, 0, 0
  -- joypad
  m.jdir, m.jstd, m.P1 = 0xF, 0xF, 0
  m.frames = 0
  local env = { daa = daa }
  env.R = function(a, c, o) return m:R(a, c, o) end
  env.W = function(a, v, c, o) return m:W(a, v, c, o) end
  env.halt = function() m.halted = true; m.hde = m.eidelay == 1; m:dobail() end
  env.stop = function(c) m:stopins(c) end
  env.di = function() m.IME = false; m.eidelay = 0 end
  env.ei = function() if m.eidelay == 0 then m.eidelay = 2 end; m.eiset = true end
  env.reti = function() m.IME = true; m.eidelay = 0; if band(band(m.IF, m.IE), 0x1F) ~= 0 then m:dobail() end end
  m.env = env
  m.K = blocksfactory(env)
  m.E = env.entry or {}
  return m
end

function M:dobail() self.bail = true; self.env.lim(-1) end
function M:write(a, v) self:W(a, v, self.env.cy(), 0) end

-- ------------------------------------------------------------------ timer
local DIVIDERS = { [0] = 10, 4, 6, 8 }
local function tbit(tac) return lshift(1, DIVIDERS[band(tac, 3)] - 1) end
function M:incTIMA()
  self.TIMA = self.TIMA + 1
  if self.TIMA > 0xFF then self.TIMA = self.TMA; self.reload = 1; self.TIMAc = 4 end
end
function M:ttick(c)
  local d = c - self.tlast
  if d == 0 then return false end
  self.tlast = c
  local tb = tbit(self.TAC)
  if self.reload == 0 then
    if band(self.TAC, 4) ~= 0 then
      local period = tb * 2
      local s = self.DIVc; local e = s + d
      local inc = floor((e - 1 - (period - 1) + period) / period) - floor((s - 1 - (period - 1) + period) / period)
      if self.TIMA + inc <= 0xFF then
        self.TIMA = self.TIMA + inc
        self.DIVc = e % 0x10000
        local ne = (self.DIVc - self.DIVc % period + period) - self.DIVc
        self.tcti = ne + (0xFF - self.TIMA) * period
        return false
      end
    else
      self.DIVc = (self.DIVc + d) % 0x10000
      self.tcti = MAXC
      return false
    end
  end
  local ret = false
  while d > 0 do
    if self.reload ~= 0 then
      self.TIMAc = self.TIMAc - 1
      if self.TIMAc == 0 then
        if self.reload == 1 then self.reload = 2; self.TIMAc = 4; ret = true else self.reload = 0 end
      end
    end
    local cnt = self.DIVc; local nc = (cnt + 1) % 0x10000
    if band(self.TAC, 4) ~= 0 and band(cnt, tb) ~= 0 and band(nc, tb) == 0 then self:incTIMA() end
    self.DIVc = nc
    d = d - 1
  end
  if band(self.TAC, 4) ~= 0 then
    local period = tb * 2
    local ne = (self.DIVc - self.DIVc % period + period) - self.DIVc
    self.tcti = ne + (0xFF - self.TIMA) * period
  end
  return ret
end

-- ------------------------------------------------------------------ STAT / LCD
function M:irqupdate()
  local mode = self.mode
  local mirq = mode ~= 3 and band(self.STAT, lshift(1, mode + 3)) ~= 0
  local lirq = band(self.STAT, 0x44) == 0x44
  local line = mirq or lirq
  local r = (line and not self.irqline) and 2 or 0
  self.irqline = line
  return r
end
function M:setmode(mode)
  if self.mode == mode then return 0 end
  self.mode = mode; self.STAT = bor(band(self.STAT, 0xFC), mode)
  return self:irqupdate()
end
function M:updLYC()
  if self.LYC == self.LY then self.STAT = bor(self.STAT, 4) else self.STAT = band(self.STAT, 0xFB) end
  return self:irqupdate()
end
function M:lcdon() return band(self.LCDC, 0x80) ~= 0 end
function M:pretrig()
  return band(self.LCDC, 0x80) ~= 0 and self.LY == 143 and self.mode == 0 and self.nextmode == 1
    and band(self.STAT, 0x20) ~= 0 and not self.irqline
end
function M:m3penalty(ly)
  if band(self.LCDC, 2) == 0 then return 0 end
  local h = band(self.LCDC, 4) ~= 0 and 16 or 8
  local count, groups, pen = 0, 0, 0
  local seen = {}
  local oam = self.oam
  for i = 0, 0x9F, 4 do
    local y = oam[i] - 16
    if y <= ly and ly < y + h then
      local x = oam[i + 1]
      if x < 168 then
        pen = pen + 6
        if not seen[x] then
          seen[x] = true; groups = groups + 1
          local al = 5 - band(x + self.SCX - 8, 7)
          if al > 0 then pen = pen + al end
        end
      end
      count = count + 1
      if count == 10 then break end
    end
  end
  if count > 0 and groups == 0 then return -4 end
  if count == 0 then return 0 end
  pen = max(0, pen - 7)
  pen = floor((pen + 3) / 4) * 4
  return pen
end
function M:cyclesToMode0()
  local mode = self.mode; local rem = self.ctarget - self.clock
  if mode == 0 then return 0 elseif mode == 3 then return rem end
  local adj = self:m3penalty(mode == 1 and 0 or self.LY)
  local normal = 170 + adj
  if mode == 2 then return rem + (self.first_frame and (172 + adj) or normal) end
  return rem + 456 * (153 - self.LY) + 80 + normal
end
function M:ltick(c)
  local d = c - self.llast
  if d == 0 then return 0 end
  self.llast = c
  local intr = 0
  self.clock = self.clock + floor(d / (self.shift == 1 and 2 or 1))
  local vpre = false
  if self:pretrig() and self.clock >= self.ctarget - 4 then self.strans = ST_PRE; intr = bor(intr, 2) end
  local on = band(self.LCDC, 0x80) ~= 0
  if self.clock >= self.ctarget then
    if on and self.reset then
      self.reset = false; self.frame_done = true; self.LY = 0; self.clock = 0; self.ctarget = 76
      self.nextmode = 3; self.strans = ST_NONE
      intr = bor(intr, self:setmode(0)); intr = bor(intr, self:updLYC())
    elseif on and self.LY == 153 then
      if self.first_frame and self.ctarget < FRAME then self.ctarget = FRAME
      else
        self.frame_done = true; self.LY = 0; self.clock = self.clock % FRAME; self.first_frame = false
        self.ctarget = self.ctarget % FRAME + 80; self.nextmode = 3; self.strans = ST_NONE
        intr = bor(intr, self:setmode(2)); intr = bor(intr, self:updLYC())
      end
    elseif on and self.strans == ST_ADV then
      self.LY = self.LY + 1
      if self.first_frame then self.STAT = band(self.STAT, 0xFB); intr = bor(intr, self:irqupdate())
      else intr = bor(intr, self:updLYC()) end
      self.ctarget = self.ctarget + 4; self.strans = ST_M2
    elseif on and self.strans == ST_M2 then
      intr = bor(intr, self:setmode(2))
      if self.first_frame then intr = bor(intr, self:updLYC()) end
      self.ctarget = self.ctarget + 80; self.nextmode = 3; self.strans = ST_NONE
    elseif on then
      if self.strans == ST_PRE then self.strans = ST_NONE; vpre = true end
      intr = bor(intr, self:setmode(self.nextmode))
      local mode = self.mode
      if mode == 2 then
        self.LY = self.LY + 1; self.ctarget = self.ctarget + 80; self.nextmode = 3; self.strans = ST_NONE
        intr = bor(intr, self:updLYC())
      elseif mode == 3 then
        self.m3adj = self:m3penalty(self.LY)
        self.ctarget = self.ctarget + (self.first_frame and 172 or 170) + self.m3adj
        self.nextmode = 0; self.strans = ST_NONE
      elseif mode == 0 then
        if self.first_frame then
          self.ctarget = self.ctarget + 200 - self.m3adj
          if self.LY < 143 then self.nextmode = 2; self.strans = ST_ADV else self.nextmode = 1; self.strans = ST_NONE end
        else
          self.ctarget = self.ctarget + 206 - self.m3adj
          self.nextmode = self.LY < 143 and 2 or 1; self.strans = ST_NONE
        end
        local s = self.scan[self.LY]
        if s then s[1], s[2], s[3], s[4] = self.SCX, self.SCY, self.WX - 7, self.WY end
      elseif mode == 1 then
        self.ctarget = self.ctarget + 456; self.nextmode = 1; self.strans = ST_NONE
        self.LY = self.LY + 1
        intr = bor(intr, self:updLYC())
        if self.LY == 144 then
          if band(self.STAT, 0x20) ~= 0 and not self.irqline and not vpre then intr = bor(intr, 2) end
          intr = bor(intr, 1)
        end
      end
    else
      self.frame_done = true; self.clock = self.clock % FRAME; self.ctarget = FRAME
    end
  end
  local cti = self.ctarget - self.clock
  if self:pretrig() then cti = cti - 4 end
  local mul = self.shift == 1 and 2 or 1
  self.lcti = cti * mul
  self.lctf = (FRAME - self.clock) * mul
  return intr
end
function M:lsync(c) local f = self:ltick(c); if f ~= 0 then self.IF = bor(self.IF, f) end end
function M:setLCDC(v)
  local wason = band(self.LCDC, 0x80) ~= 0
  self.LCDC = v
  local on = band(v, 0x80) ~= 0
  if wason and not on then
    self.clock = 0; self.ctarget = 0; self.lctf = 0
    self:setmode(0); self.LY = 0
  elseif not wason and on then
    self.ctarget = 0; self.first_frame = true; self.reset = true
    if self.lycdis then self.lycdis = false end
    if band(self.STAT, 0x40) ~= 0 then return self:updLYC() end
  end
  return 0
end

-- ------------------------------------------------------------------ OAM DMA / HDMA
function M:dmasync(c, o, ro)
  if not self.dma_active or self.dma_reading then return end
  if ro == nil then ro = o end
  local el = c + o - self.dma_start
  if el < 4 then return end
  local tgt = min(0xA0, floor(el / 4))
  while self.dma_idx < tgt do
    self.dma_reading = true
    local v = self:R(self.dma_src * 256 + self.dma_idx, c, ro)
    self.dma_reading = false
    self.oam[self.dma_idx] = v
    self.dma_idx = self.dma_idx + 1
  end
  if self.dma_idx == 0xA0 then self.dma_active = false end
end
function M:hdmatick(c, o)
  o = o or 0
  local src = band(self.hsrc, 0xFFF0); local dst = bor(band(self.hdst, 0x1FF0), 0x8000)
  for i = 0, 15 do self:W(dst + i, self:R(src + i, c, o), c, o) end
  self.hdst = self.hdst + 0x10; self.hsrc = self.hsrc + 0x10
  if self.hdst == 0xA000 then self.hdst = 0x8000 end
  if self.hsrc == 0x8000 then self.hsrc = 0xA000 end
  self.h1, self.h2 = rshift(band(self.hsrc, 0xFF00), 8), band(self.hsrc, 0xFF)
  self.h3, self.h4 = rshift(band(self.hdst, 0xFF00), 8), band(self.hdst, 0xFF)
  if self.h5 == 0 then self.hact = false; self.h5 = 0xFF else self.h5 = self.h5 - 1 end
  return 206
end
function M:sethdma5(v, c, o)
  if self.hact then
    if band(v, 0x80) == 0 then self.hact = false; self.h5 = 0x80 else self.h5 = band(v, 0x7F) end
  else
    self.h5 = v
    local n = band(v, 0x7F) * 16 + 16
    if band(v, 0x80) == 0 then
      local src, dst = self.hsrc, self.hdst
      for i = 0, n - 1 do self:W(band(dst + i, 0xFFFF), self:R(band(src + i, 0xFFFF), c, o), c, o) end
      self.hsrc = band(src + n, 0xFFFF); self.hdst = band(dst + n, 0xFFFF)
      self.h5 = 0xFF
    else
      self.h5 = band(self.h5, 0x7F); self.hact = true
      if band(self.LCDC, 0x80) == 0 then self:hdmatick(c, o) end
    end
  end
end

-- ------------------------------------------------------------------ memory
function M:R(a, c, o)
  if a < 0x4000 then return byte(self.rom, a + 1) end
  if a < 0x8000 then return byte(self.rom, self.rombank * 0x4000 + a - 0x4000 + 1) end
  if a < 0xA000 then
    if o ~= 0 then
      self:lsync(c + o)
      if band(self.LCDC, 0x80) ~= 0 and (self.mode == 3 or (self.mode == 2 and self.clock <= self.ctarget and self.ctarget - self.clock <= 4)) then return 0xFF end
    end
    return self.vram[self.vbk][a - 0x8000]
  end
  if a < 0xC000 then if not self.ramg then return 0xFF end return self.sram[self.srambank][a - 0xA000] end
  if a < 0xD000 then return self.wram[0][a - 0xC000] end
  if a < 0xE000 then local b = self.wsel; if b == 0 then b = 1 end return self.wram[b][a - 0xD000] end
  if a < 0xFE00 then return self:R(a - 0x2000, c, o) end
  if a < 0xFEA0 then
    if o ~= 0 and not self.dma_reading then
      self:lsync(c + o)
      if band(self.LCDC, 0x80) ~= 0 and (self.mode == 2 or self.mode == 3 or (self.first_frame and self.strans == ST_M2)) then return 0xFF end
    end
    if self.dma_active and not self.dma_reading then self:dmasync(c, o) end
    local started = c + o >= self.dma_start
    if self.dma_active and not self.dma_reading and started and self.env.hl() == a then
      self:dmasync(c, max(o, 4), o); started = c + o >= self.dma_start
    end
    if self.dma_active and started and not self.dma_reading then return 0xFF end
    return self.oam[a - 0xFE00]
  end
  if a < 0xFF00 then return self.nonio[a - 0xFEA0] end
  return self:Rio(a, c, o)
end

function M:palget(mem, ps) local w = mem[band(rshift(ps, 1), 31)]; if band(ps, 1) == 1 then return rshift(band(w, 0xFF00), 8) end return band(w, 0xFF) end
function M:palset(mem, ps, v)
  local i = band(rshift(ps, 1), 31); local w = mem[i]
  if band(ps, 1) == 1 then mem[i] = bor(band(w, 0xFF), lshift(v, 8)) else mem[i] = bor(band(w, 0xFF00), v) end
  if band(ps, 0x80) ~= 0 then ps = bor(0x80, ps + 1) end
  return band(ps, 0xFF)
end

function M:Rio(a, c, o)
  if self.dma_active and not self.dma_reading then self:dmasync(c, o) end
  if a < 0xFF4C then
    if a == 0xFF00 then return self.P1 end
    if a == 0xFF01 then return self.SB end
    if a == 0xFF02 then return self.SC end
    if a == 0xFF03 then return 0xFF end
    if a <= 0xFF07 then
      if self:ttick(c) then self.IF = bor(self.IF, 4) end
      if a == 0xFF04 then return rshift(self.DIVc, 8) end
      if a == 0xFF05 then return self.reload == 1 and 0 or self.TIMA end
      if a == 0xFF06 then return self.TMA end
      return bor(self.TAC, 0xF8)
    end
    if a <= 0xFF0E then return 0xFF end
    if a == 0xFF0F then return bor(self.IF, 0xE0) end
    if a < 0xFF40 then return 0 end
    self:lsync(c + o)
    if a == 0xFF40 then return self.LCDC end
    if a == 0xFF41 then local v = self.STAT; if self.smo then self.smo = false; v = band(v, 0xFC) end return v end
    if a == 0xFF42 then return self.SCY end
    if a == 0xFF43 then return self.SCX end
    if a == 0xFF44 then return self.LY end
    if a == 0xFF45 then return self.LYC end
    if a == 0xFF46 then return self.dma_src end
    if a == 0xFF47 then return self.BGP end
    if a == 0xFF48 then return self.OBP0 end
    if a == 0xFF49 then return self.OBP1 end
    if a == 0xFF4A then return self.WY end
    return self.WX
  end
  if a < 0xFF80 then
    if a == 0xFF4C then return 0xFB end
    if a == 0xFF4D then return self.key1 end
    if a == 0xFF4F then return bor(self.vbk, 0xFE) end
    if a == 0xFF68 then return bor(self.bcps, 0x40) end
    if a == 0xFF69 then return self:palget(self.bmem, self.bcps) end
    if a == 0xFF6A then return bor(self.ocps, 0x40) end
    if a == 0xFF6B then return self:palget(self.omem, self.ocps) end
    if a == 0xFF55 then return band(self.h5, 0xFF) end
    if a == 0xFF76 or a == 0xFF77 then return 0 end
    if a == 0xFF6C then return bor(self.opm, 0xFE) end
    if a == 0xFF70 then return bor(self.wsel, 0xF8) end
    if a == 0xFF72 or a == 0xFF73 then return self.undoc[a - 0xFF72] end
    if a == 0xFF74 then return self.undoc[2] end
    if a == 0xFF75 then return self.undoc[3] end
    return 0xFF
  end
  if a < 0xFFFF then return self.hram[a - 0xFF80] end
  return self.IE
end

function M:W(a, v, c, o)
  if a < 0x8000 then
    if a < 0x2000 then self.ramg = v == 0x0A
    elseif a < 0x3000 then self.rombank = (bor(band(self.rombank, 0x100), v)) % self.nromb
    elseif a < 0x4000 then self.rombank = (bor(lshift(band(v, 1), 8), band(self.rombank, 0xFF))) % self.nromb
    elseif a < 0x6000 then self.srambank = band(v, 0xF) % self.nramb end
    self:dobail(); return
  end
  if a < 0xA000 then
    if o ~= 0 then
      self:lsync(c + o)
      if band(self.LCDC, 0x80) ~= 0 and self.mode == 3 then return end
    end
    self.vram[self.vbk][a - 0x8000] = v
    return
  end
  if a < 0xC000 then if self.ramg then self.sram[self.srambank][a - 0xA000] = v end return end
  if a < 0xD000 then self.wram[0][a - 0xC000] = v; return end
  if a < 0xE000 then local b = self.wsel; if b == 0 then b = 1 end self.wram[b][a - 0xD000] = v; return end
  if a < 0xFE00 then return self:W(a - 0x2000, v, c, o) end
  if a < 0xFEA0 then
    if o ~= 0 then
      self:lsync(c + o)
      if band(self.LCDC, 0x80) ~= 0 and (self.mode == 3 or (self.mode == 2 and not (self.first_frame and self.clock <= self.ctarget and self.ctarget - self.clock <= 4))) then return end
    end
    if self.dma_active and not self.dma_reading then self:dmasync(c, o) end
    if not self.dma_active then self.oam[a - 0xFE00] = v end
    return
  end
  if a < 0xFF00 then self.nonio[a - 0xFEA0] = v; return end
  return self:Wio(a, v, c, o)
end

function M:pull(v)
  local p14, p15 = band(rshift(v, 4), 1), band(rshift(v, 5), 1)
  local j = band(bor(v, 0xCF), 0xFF)
  if p14 == 1 and p15 == 1 then j = 0xF
  elseif p14 == 0 and p15 == 0 then
  elseif p14 == 0 then j = band(j, self.jdir)
  else j = band(j, self.jstd) end
  return bor(j, 0xC0)
end

function M:Wio(a, v, c, o)
  if self.dma_active and not self.dma_reading then self:dmasync(c, o) end
  if a < 0xFF4C then
    if a == 0xFF00 then self.P1 = self:pull(v)
    elseif a == 0xFF01 then self.SB = v
    elseif a == 0xFF02 then self.SC = v
    elseif a >= 0xFF04 and a <= 0xFF07 then
      if self:ttick(c) then self.IF = bor(self.IF, 4) end
      if a == 0xFF04 then
        local tb = tbit(self.TAC)
        if band(self.TAC, 4) ~= 0 and band(self.DIVc, tb) ~= 0 then self:incTIMA() end
        self.DIVc = 0
      elseif a == 0xFF05 then if self.reload ~= 2 then self.TIMA = v end
      elseif a == 0xFF06 then self.TMA = v; if self.reload ~= 0 then self.TIMA = v end
      else
        local ob, nb = tbit(self.TAC), tbit(v)
        if band(self.TAC, 4) ~= 0 and band(self.DIVc, ob) ~= 0 then
          if band(v, 4) == 0 or band(self.DIVc, nb) == 0 then self:incTIMA() end
        end
        self.TAC = band(v, 7)
      end
    elseif a == 0xFF0F then self.IF = band(v, 0x1F)
    elseif a >= 0xFF10 and a < 0xFF40 then -- sound: not emulated by the reference
    elseif a >= 0xFF40 then
      self:lsync(c)
      if a == 0xFF40 then local f = self:setLCDC(v); if f ~= 0 then self.IF = bor(self.IF, f) end
      elseif a == 0xFF41 then
        self.STAT = bor(band(self.STAT, 0x87), band(v, 0x78)); local f = self:irqupdate(); if f ~= 0 then self.IF = bor(self.IF, f) end
      elseif a == 0xFF42 then self.SCY = v
      elseif a == 0xFF43 then self.SCX = v
      elseif a == 0xFF44 then return
      elseif a == 0xFF45 then
        self.LYC = v
        if band(self.LCDC, 0x80) ~= 0 then local f = self:updLYC(); if f ~= 0 then self.IF = bor(self.IF, f) end
        else self.lycdis = true end
      elseif a == 0xFF46 then
        if self.dma_active and self.dma_idx == 0 then self.dma_start = c + 8 else self.dma_start = c + 12 end
        self.dma_active = true; self.dma_reading = false; self.dma_src = v; self.dma_idx = 0
      elseif a == 0xFF47 then self.BGP = v
      elseif a == 0xFF48 then self.OBP0 = v
      elseif a == 0xFF49 then self.OBP1 = v
      elseif a == 0xFF4A then self.WY = v
      elseif a == 0xFF4B then self.WX = v end
    else self.io[a - 0xFF00] = v end
    self:dobail()
    return
  end
  if a < 0xFF80 then
    if a == 0xFF4D then self.key1 = v; self:dobail()
    elseif a == 0xFF4F then self.vbk = band(v, 1)
    elseif a == 0xFF51 then self.h1 = v; self.hsrc = bor(lshift(v, 8), band(self.hsrc, 0xFF))
    elseif a == 0xFF52 then self.h2 = v; self.hsrc = bor(band(self.hsrc, 0xFF00), band(v, 0xF0))
    elseif a == 0xFF53 then self.h3 = v; self.hdst = bor(bor(lshift(band(v, 0x1F), 8), band(self.hdst, 0xFF)), 0x8000)
    elseif a == 0xFF54 then self.h4 = v; self.hdst = bor(band(self.hdst, 0xFF00), band(v, 0xF0))
    elseif a == 0xFF55 then self:sethdma5(v, c, o); self:dobail()
    elseif a == 0xFF68 then self.bcps = v
    elseif a == 0xFF69 then self.bcps = self:palset(self.bmem, self.bcps, v)
    elseif a == 0xFF6A then self.ocps = v
    elseif a == 0xFF6B then self.ocps = self:palset(self.omem, self.ocps, v)
    elseif a == 0xFF6C then self.opm = band(v, 1)
    elseif a == 0xFF70 then self.wsel = band(v, 7)
    elseif a == 0xFF72 or a == 0xFF73 then self.undoc[a - 0xFF72] = v
    elseif a == 0xFF74 then self.undoc[2] = v
    elseif a == 0xFF75 then self.undoc[3] = bor(v, 0x8F) end
    return
  end
  if a < 0xFFFF then self.hram[a - 0xFF80] = v; return end
  self.IE = v; self:dobail()
end

function M:stopins(c)
  if band(self.key1, 1) ~= 0 then
    self.double = not self.double
    self:ltick(c)
    self.shift = self.double and 1 or 0
    self.key1 = bxor(self.key1, 0x81)
  end
  self:W(0xFF04, 0, c, 0)
end

-- ------------------------------------------------------------------ RAM-resident code (OAM DMA stub)
function M:ramstep(pc)
  local env = self.env
  local cy = env.cy()
  local op = self:R(pc, cy, 0)
  local r
  if op == 0x3E then local n = self:R(pc + 1, cy, 4); r = env.regs(); r.A = n; env.setregs(r); env.cy(cy + 8); return pc + 2
  elseif op == 0xE0 then local n = self:R(pc + 1, cy, 4); r = env.regs(); self:W(0xFF00 + n, r.A, cy + 4, 0); env.cy(cy + 12); return pc + 2
  elseif op == 0x3D then r = env.regs(); local v = band(r.A - 1, 255); r.FH = band(v, 15) == 15; r.FZ = v == 0; r.FN = true; r.A = v; env.setregs(r); env.cy(cy + 4); return pc + 1
  elseif op == 0x20 then local e = self:R(pc + 1, cy, 4); if e > 127 then e = e - 256 end
    r = env.regs(); if not r.FZ then env.cy(cy + 12); return pc + 2 + e end; env.cy(cy + 8); return pc + 2
  elseif op == 0xC9 then r = env.regs(); local lo = self:R(r.SP, cy + 4, 0); local hi = self:R(band(r.SP + 1, 0xFFFF), cy + 8, 0); r.SP = band(r.SP + 2, 0xFFFF); env.setregs(r); env.cy(cy + 16); return hi * 256 + lo
  elseif op == 0x00 then env.cy(cy + 4); return pc + 1 end
  error(("RAM code at %04X: %02X"):format(pc, op))
end

-- ------------------------------------------------------------------ CPU tick / main loop
function M:dispatch()
  local env = self.env
  local sp = env.sp(); local cy = env.cy()
  self:W(band(sp - 1, 0xFFFF), rshift(self.PC, 8), cy, 0)
  local p = band(band(self.IF, self.IE), 0x1F)
  if p == 0 then self.PC = 0; self.IME = false; return end
  local flag, addr
  if band(p, 1) ~= 0 then flag, addr = 1, 0x40 elseif band(p, 2) ~= 0 then flag, addr = 2, 0x48
  elseif band(p, 4) ~= 0 then flag, addr = 4, 0x50 elseif band(p, 8) ~= 0 then flag, addr = 8, 0x58 else flag, addr = 16, 0x60 end
  self.IF = bxor(self.IF, flag)
  self:W(band(sp - 2, 0xFFFF), band(self.PC, 0xFF), cy, 0)
  env.sp(band(sp - 2, 0xFFFF))
  self.PC = addr
  env.cy(cy + 20)
  self.IME = false
end
function M:checkints()
  if self.queued or self.eidelay ~= 0 then return false end
  local p = band(band(self.IF, self.IE), 0x1F)
  if p ~= 0 then
    if self.halted and not self.hde then self.PC = band(self.PC + 1, 0xFFFF) end
    self.hde = false
    if self.IME then self:dispatch() end
    self.queued = true
    return true
  end
  return false
end

function M:key(pc)
  if pc < 0x4000 then return pc end
  return self.rombank * 0x10000 + pc
end

function M:posti()
  if self.eidelay > 0 then
    self.eidelay = self.eidelay - 1
    if self.eidelay == 0 then
      self.IME = true
      self.bail = band(band(self.IF, self.IE), 0x1F) ~= 0
    end
  end
end

function M:cputick(target)
  local env = self.env
  local tgt = env.cy() + target
  if self:checkints() then self.halted = false end
  if self.halted then env.cy(env.cy() + target) end
  self.queued = false
  self.bail = false
  local K = self.K
  while env.cy() < tgt do
    local pc = self.PC
    if pc == self.stopAt then self.stopped = true; self.bail = true; break end
    if self.hookpcs and self.hookpcs[pc] and self.skiphook ~= pc then
      -- breakpoint: zero-cycle instruction that ends the tick; the hook runs after this step
      self.brk = pc
      self:posti()
      self.bail = true
      break
    end
    self.skiphook = nil
    local one = self.eidelay > 0
    env.lim(one and -1 or tgt)
    if pc < 0x8000 then
      local k = pc < 0x4000 and pc or self.rombank * 0x10000 + pc
      local f = K[k]
      if not f then
        self.missing = (pc < 0x4000 and 0 or self.rombank) * 0x10000 + pc
        error(("missing block %02X:%04X"):format(pc < 0x4000 and 0 or self.rombank, pc))
      end
      if self.seen then self.seen[k] = true end
      if self.watch then local w = self.watch[k]; if w then w(self, k) end end
      self.PC = f(self.E[k] or 0)
    else
      self.PC = self:ramstep(pc)
    end
    self:posti()
    if self.bail then break end
  end
end

function M:step()
  local env = self.env
  local single = self.single
  if not self.halted and self.hact and band(self.LCDC, 0x80) ~= 0 and self.mode == 0 then
    local c = env.cy()
    env.cy(c + self:hdmatick(c, 0))
  else
    local t
    if single then t = 4 else
      local m0 = MAXC
      if self.hact then m0 = self:cyclesToMode0() end
      t = max(4, min(self.tcti, self.lcti, self.lctf, m0))
    end
    self:cputick(t)
  end
  local c = env.cy()
  if self.dma_active and not self.dma_reading then self:dmasync(c, 0) end
  if self:ttick(c) then self.IF = bor(self.IF, 4) end
  local f = self:ltick(c); if f ~= 0 then self.IF = bor(self.IF, f) end
  if single then self.single = false; self.skiphook = nil; return true end
  if self.brk then
    local pc = self.brk; self.brk = nil
    if self.frame_done then error("breakpoint on a frame boundary") end
    self.hook(self, pc)
    self.single = true; self.skiphook = pc
    return true
  end
end

-- run a routine of the game to its return (a sentinel return address on the stack)
function M:call(bank, addr, maxsteps)
  local env = self.env
  if bank ~= 0 then self:W(0x2000, bank, env.cy(), 0) end
  local SENT = 0xFFF0
  local sp = band(env.sp() - 2, 0xFFFF)
  self:W(sp, band(SENT, 0xFF), env.cy(), 0); self:W(sp + 1, rshift(SENT, 8), env.cy(), 0)
  env.sp(sp)
  self.PC = addr; self.stopAt = SENT; self.stopped = false
  local hp = self.hookpcs; self.hookpcs = nil
  local n = 0
  while not self.stopped do
    self:step(); n = n + 1
    if n > (maxsteps or 2000000) then error(("routine %02X:%04X did not return"):format(bank, addr)) end
  end
  self.stopAt = nil; self.hookpcs = hp
end

-- one emulator frame (until the PPU reports a finished frame)
function M:frame()
  self.frame_done = false
  repeat self:step() until self.frame_done
  self.frames = self.frames + 1
end

-- what the reference reports for this frame
function M:snapshot(keepvram)
  local f = { l = self.LCDC, lines = {}, n = self.frames }
  local on = band(self.LCDC, 0x80) ~= 0
  for y = 0, 143 do local s = self.scan[y]; f.lines[y] = on and { s[1], s[2], s[3], s[4] } or { 0, 0, 0, 0 } end
  f.bgp, f.obp = {}, {}
  for i = 0, 31 do f.bgp[i] = self.bmem[i]; f.obp[i] = self.omem[i] end
  if keepvram ~= false then
    f.v0, f.v1 = {}, {}
    local a, b = self.vram[0], self.vram[1]
    for i = 0, 0x1FFF do f.v0[i] = a[i]; f.v1[i] = b[i] end
  end
  f.oam = {}; local c = self.env.cy(); for i = 0, 0x9F do f.oam[i] = self:R(0xFE00 + i, c, 0) end
  return f
end

local KEYS = { right = { "jdir", 0 }, left = { "jdir", 1 }, up = { "jdir", 2 }, down = { "jdir", 3 },
  a = { "jstd", 0 }, b = { "jstd", 1 }, select = { "jstd", 2 }, start = { "jstd", 3 } }
function M:button(k, down)
  local d = KEYS[k]; local old = self[d[1]]
  local bitv = lshift(1, d[2])
  if down then self[d[1]] = band(old, bnot(bitv)) else self[d[1]] = bor(old, bitv) end
  if down and band(old, bitv) ~= 0 then self.IF = bor(self.IF, 16) end
end

return M
