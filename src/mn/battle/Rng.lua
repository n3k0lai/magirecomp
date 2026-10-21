-- Magi-Nation battle randomness.
--
-- The original game has no PRNG: every roll reads the Game Boy divider register
-- (rDIV, $FF04) through three routines, so the outcome depends on the exact frame
-- and cycle a choice is made on. The port cannot reproduce that timing, so the
-- engine asks a source for the *values* those routines returned instead:
--
--   maskDiv(c)  MaskDivByC ($053A): rDIV & C after a short spin
--   divStep()   AddDividerStep ($054F): the signed step -3..+4 it adds to $FFA9
--   div()       JitterScaledTableByte ($53FB): one raw rDIV sample
--
-- Rng.seeded(seed) draws those from a xorshift32 stream (same seed, same battle).
-- Rng.replay(list) hands back values recorded from the real game in PyBoy
-- (tools/mn_battle/oracle.py), so one engine step can be diffed against the ROM.
local bit = require("bit")
local band, bxor, lshift, rshift, tobit = bit.band, bit.bxor, bit.lshift, bit.rshift, bit.tobit

local M = {}
M.__index = M

local function xorshift(s)
  s = bxor(s, lshift(s, 13)); s = bxor(s, rshift(s, 17)); s = bxor(s, lshift(s, 5))
  return tobit(s)
end

function M.seeded(seed)
  local s = tobit(seed or 1)
  if s == 0 then s = 0x2545F491 end
  return setmetatable({ s = s, n = 0, log = nil }, M)
end

-- recorded values: { {"m", v}, {"s", e}, {"d", v}, ... } in the order the game drew them
function M.replay(list)
  return setmetatable({ list = list, i = 0, n = 0, misses = 0 }, M)
end

function M:byte()
  self.s = xorshift(self.s)
  return band(rshift(self.s, 8), 0xFF)
end

local function take(self, kind)
  self.i = self.i + 1
  local e = self.list[self.i]
  if not e then self.misses = self.misses + 1; self.err = self.err or ("ran out at draw " .. self.i .. " (" .. kind .. ")"); return nil end
  if e[1] ~= kind then self.misses = self.misses + 1; self.err = self.err or ("draw " .. self.i .. " wanted " .. kind .. " got " .. e[1]) end
  return e[2]
end

local function note(self, kind, v)
  self.n = self.n + 1
  if self.log then self.log[#self.log + 1] = { kind, v } end
  return v
end

function M:maskDiv(c)
  if self.list then return note(self, "m", band(take(self, "m") or 0, c)) end
  return note(self, "m", band(self:byte(), c))
end

-- AddDividerStep: e = ((sra(swap(d1)) + d2) & 7) - 3 with two divider samples
function M:divStep()
  if self.list then return note(self, "s", take(self, "s") or 0) end
  local d1, d2 = self:byte(), self:byte()
  local sw = band(lshift(d1, 4), 0xF0) + rshift(d1, 4)
  local sra = band(rshift(sw, 1) + band(sw, 0x80), 0xFF)
  return note(self, "s", band(sra + d2, 7) - 3)
end

function M:div()
  if self.list then return note(self, "d", take(self, "d") or 0) end
  return note(self, "d", self:byte())
end

function M:state() return self.list and self.i or self.s end

return M
