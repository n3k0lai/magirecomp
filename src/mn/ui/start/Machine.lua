-- Field start menu state. HandleStartPress (bank 6) jumps to AfterStartLoop
-- ($673B), which calls QueueBlinkSprite ($03:4100) and DispatchMaskedAction
-- ($03:41E3) every frame. The cursor record is the 8 bytes CopyIndexedSlot
-- reads at $49EB + $CD81 * 8 (bank 3). A and B call StepSlotPair on the
-- 4-byte records at $493B. Both tables are read from the ROM.
local bit = require("bit")

local M = {}
M.__index = M

local PAIR = 0x493B
local SLOT = 0x49EB
local BANK = 3

local function rom8(rom, bank, addr)
  if not rom or addr < 0 then return 0 end
  return rom:u8(bank * 0x4000 + addr - 0x4000) or 0
end

function M.boot(ctx)
  local self = setmetatable({
    ctx = ctx, vm = ctx.vm, rom = ctx.rom,
    cd81 = 0, cc47 = 5, cd80 = 0, cd7f = 0, ccb9 = 1,
    cc4b = 0, cca0 = 0, phase = 0, gate = 1,
    ptrs = {}, rows = {}, flags = {}, held = {},
    col = 0, row = 0, nav = {},
  }, M)
  self:openBytes()
  self:copySlot()
  self:flush()
  return self
end

-- Bytes HandleStartPress and DrawStartScreenMap store before the loop.
function M:openBytes()
  local vm = self.vm
  vm:wr8(0xC92C, 6)
  vm:wr8(0xC928, 0)
  vm:wr8(0xC929, 0)
  vm:wr8(0xC92A, 4)
  vm:wr8(0xC728, 0)
  vm:wr8(0xC729, 0)
  vm:wr8(0xCCA9, 0xFF)
  vm:wr8(0xCCB9, 1)
  vm:wr8(0xC6F0, 7)
  vm:wr8(0xC6F1, 0)
  -- $CC4D is both the fill of selectable slots and, for a few indexes, a
  -- value copied from SRAM. Those copies are the skip flags for that slot.
  for i = 0, 0x2B do self.flags[i] = 1 end
  if self:spanZero(0xA5A6, 0xFD) then self.flags[1] = 0 end   -- $CC4E spell
  if self:spanZero(0xA3A8, 0xFD) then self.flags[3] = 0 end   -- $CC50 items
  if self:spanZero(0xA4A6, 0xFE) then self.flags[5] = 0 end   -- $CC52 list
  self.flags[2] = bit.band(vm:rd8(0xA118) + 1, 0xFF)         -- $CC4F rings
  self.flags[4] = vm:rd8(0xA3A4)                              -- $CC51 glyph
  self.flags[0x24] = vm:rd8(0xCCA5)                           -- $CC71 save
end

function M:spanZero(addr, len)
  for i = 0, len - 1 do
    if self.vm:rd8(addr + i) ~= 0 then return false end
  end
  return true
end

function M:copySlot()
  local a = SLOT + self.cd81 * 8
  local b = {}
  for i = 0, 7 do b[i + 1] = rom8(self.rom, BANK, a + i) end
  self.col, self.row = b[1], b[2]
  self.nav = { right = b[3], left = b[4], up = b[5], down = b[6] }
  self.act = { b[7], b[8] }
  self.slot = b
end

function M:pair(isA)
  local a = PAIR + self.cd81 * 4 + (isA and 0 or 2)
  return rom8(self.rom, BANK, a), rom8(self.rom, BANK, a + 1)
end

function M:flush()
  local vm = self.vm
  vm:wr8(0xCD81, self.cd81)
  vm:wr8(0xCC47, self.cc47)
  vm:wr8(0xCD80, self.cd80)
  vm:wr8(0xCD7F, self.cd7f)
  vm:wr8(0xCC4B, self.cc4b)
  vm:wr8(0xCCA0, self.cca0)
  vm:wr8(0xCC86, self.phase)
  if self.slot then
    for i = 1, 8 do vm:wr8(0xCD81 + i, self.slot[i]) end
  end
  for i = 0, 0x2B do vm:wr8(0xCC4D + i, self.flags[i] or 0) end
  if not self.havePtrs then return end
  for i = 1, 5 do
    local p = self.ptrs[i] or 0
    vm:wr8(0xCC76 + i * 2, p % 256)       -- $CC78 is slot 1
    vm:wr8(0xCC77 + i * 2, math.floor(p / 256) % 256)
  end
end

-- QueueBlinkSprite: $81 blinks, hidden while $CD7F < $0F. $CD80 == 1 holds $82.
function M:blink()
  if self.cd80 == 1 or self.ccb9 == 0 then
    self.vm:wr8(0xCCA8, 0x82)
    return
  end
  self.cd7f = self.cd7f + 1
  if self.cd7f >= 0x1F then self.cd7f = 0 end
  self.vm:wr8(0xCD7F, self.cd7f)
  self.vm:wr8(0xCCA8, 0x81)
end

function M:cursorOn()
  if self.cd80 == 1 or self.ccb9 == 0 then return true end
  return self.cd7f >= 0x0F
end

-- One just-pressed button, in DispatchMaskedAction's order.
function M:take(input)
  local dir = input("dir")
  local bits = {
    select = input("select") and true or false,
    a = input("a") and true or false,
    b = input("b") and true or false,
    right = dir == "right",
    left = dir == "left",
    up = dir == "up",
    down = dir == "down",
    start = input("start") and true or false,
  }
  local ev
  local order = { "select", "a", "b", "right", "left", "up", "down", "start" }
  for i = 1, #order do
    local k = order[i]
    if bits[k] and not self.held[k] then ev = k; break end
  end
  self.held = bits
  return ev
end

function M:press(btn)
  if not btn then return nil end
  -- AfterStartLoop rewrites Left/Right into Select when $CD81 is $1C or $1D.
  if btn == "left" or btn == "right" then
    if self.cd81 == 0x1C or self.cd81 == 0x1D then btn = "select" end
  end
  if btn == "select" then
    -- TODO(RetargetSramSlotCount): $03:42F7 reorders SRAM only for those slots
    return nil
  end
  if self.cd80 == 1 and btn ~= "a" and btn ~= "b" then return nil end
  if btn == "a" or btn == "b" then return self:action(btn == "a") end
  if btn == "start" then return "close" end
  if btn == "up" or btn == "down" or btn == "left" or btn == "right" then
    return self:dir(btn)
  end
  return nil
end

-- SelectSlotFromHighNibble. A zero byte at $CC4D + index follows the same
-- direction on the newly copied record (the candidate list was just overwritten).
function M:dir(btn)
  local idx = self.nav[btn] or 0
  for _ = 1, 8 do
    self.cd81 = idx
    self:copySlot()
    if (self.flags[idx] or 0) ~= 0 then break end
    local n = self.nav[btn] or idx
    if n == idx then break end
    idx = n
  end
  self:flush()
  return nil
end

function M:action(isA)
  local cmd, nxt = self:pair(isA)
  if cmd == 0x63 then return "close" end
  if cmd == 0x2C or cmd == 0x2D then
    self.cc4b = 1
    self:copySlot()
    self:flush()
    return "redraw"
  end
  if cmd == 0x4D then return self:toggle(nxt) end
  if cmd == 0x58 then
    if self.cd80 ~= 0 then
      self.cd80 = self.cd80 - 1
      self:copySlot()
      self:flush()
      return nil
    end
    if self.cc47 == 6 then
      -- TODO(DrawIndexedEntry): $58 from mode 6 sets mode 7, slot $19
      return nil
    end
    if self.cc47 == 3 then
      self.cd81 = 1
      self:copySlot()
      self:flush()
      return nil
    end
    if self.cc47 == 0x0B then
      self.cd81 = 5
      self:copySlot()
      self:flush()
      return nil
    end
    cmd = self.cc47
  end
  if cmd == self.cc47 then
    self.cd81 = nxt
    self:copySlot()
    self:flush()
    return nil
  end
  return self:switchMode(cmd, nxt)
end

function M:toggle(nxt)
  if self.cd80 ~= 1 then
    self.cd80 = 1
    self:copySlot()
    self:flush()
    return nil
  end
  self.cd80 = 0
  self:flush()
  if self.cd81 == 0x24 then return "save" end
  -- TODO(SetupCommand4D): a latched A on any other slot plants $C714 from the group
  self.cd81 = nxt
  self:copySlot()
  self:flush()
  return nil
end

-- StepSlotPair compare path. Mode 7 is the ring entry (DrawIndexedEntry),
-- mode 9 the glyph map. Modes other than the start screen (5), spells (3),
-- items (4), rings (7) and the glyph map (9) are left untouched.
function M:switchMode(cmd, nxt)
  -- Mode 7, command 6, $CCA4 set: store $14 at $C921 and keep the slot.
  -- A clear $CCA4 would enter mode 6 (still TODO).
  if self.cc47 == 7 and cmd == 6 and self.vm:rd8(0xCCA4) ~= 0 then
    self.vm:wr8(0xC921, 0x14)
    self:copySlot()
    self:flush()
    return nil
  end
  if cmd ~= 0 and cmd ~= 3 and cmd ~= 4 and cmd ~= 5 and cmd ~= 7 and cmd ~= 9 then
    -- TODO(DrawIndexedSlots): mode 8, A on the ring cursor
    -- TODO(IndexedSetup): mode 6 ($A019) and mode $0B (the list at $A4A6)
    return nil
  end
  self.cca0 = bit.band(self.cd81 - 0x1C, 0xFF)
  self.cc4b = 1
  self.cd81 = nxt
  self.cc47 = (cmd == 0) and 5 or cmd -- index 0 is rewritten 0 -> 1 -> 5
  self:copySlot()
  self:flush()
  if cmd == 3 then return "spell" end
  if cmd == 4 then return "items" end
  if cmd == 9 then return "glyph" end
  if cmd == 7 then return "rings" end
  return "menu"
end

function M:leave()
  self.vm:wr8(0xC92C, 0x0F)
  self.vm:wr8(0xC928, 0)
  self.vm:wr8(0xC929, 0)
  self.vm:wr8(0xC92A, 4)
end

-- FillGroupPointers + the name/count half of ScanGroupBytes / WriteGroupRowDigits.
function M:scanForward(base, from)
  local ptrs = {}
  local addr = from
  local hitEnd = false
  while #ptrs < 5 do
    addr = addr + 1
    if addr > base + 0xFE or addr > 0xBFFF then hitEnd = true; break end
    if self.vm:rd8(addr) ~= 0 then ptrs[#ptrs + 1] = addr end
  end
  if hitEnd then
    self.phase = 1
    if #ptrs == 0 then self.gate = 0; return {} end
    while #ptrs < 5 do ptrs[#ptrs + 1] = base end
  end
  self.gate = 1
  return ptrs
end

function M:scanBackward(base)
  if self.phase == 2 then self.gate = 0; return self.ptrs end
  self.phase = 0
  local addr = self.ptrs[1] or base
  local found = {}
  for _ = 1, 512 do
    addr = addr - 1
    if addr < 0xA000 then break end
    local b = self.vm:rd8(addr)
    if b ~= 0 then
      found[#found + 1] = addr
      if #found == 5 then break end
    end
    -- A zero at the SRAM base ends the walk. A nonzero byte there is kept.
    if addr == base then
      self.phase = 2
      break
    end
  end
  if #found == 0 then self.gate = 0; self.phase = 2; return self.ptrs end
  local ptrs = {}
  for i = 1, 5 do ptrs[i] = self.ptrs[i] or base end
  for i, a in ipairs(found) do ptrs[6 - i] = a end
  self.gate = 1
  return ptrs
end

function M:nameGlyphs(spec, id)
  local addr = spec.addend + id * spec.scale + 12 -- $CD9D sits 12 into the $22
  local t = {}
  for i = 0, 12 do t[i + 1] = string.char(rom8(self.rom, spec.bank, addr + i)) end
  return table.concat(t)
end

function M:markRows(spec)
  self.rows = {}
  for i = 0, 4 do
    local ptr = self.ptrs[i + 1]
    local count, id, glyphs = 0, 0, ""
    if ptr then
      count = self.vm:rd8(ptr)
      id = bit.band(ptr - spec.base, 0xFF)
      glyphs = self:nameGlyphs(spec, id)
    end
    self.flags[spec.home + i] = count ~= 0 and 1 or 0
    self.rows[i + 1] = { count = count, id = id, glyphs = glyphs, ptr = ptr }
  end
end

-- IndexedSetup tails for indexes 3 and 4: scan, then force $CD81 to the home slot.
function M:refreshList(spec, fresh)
  local idx = self.cd81
  if fresh or idx == 0x06 or idx == 0x0D then
    self.phase = 2
    self.ptrs = self:scanForward(spec.base, spec.base - 1)
  elseif idx == 0x0B or idx == 0x12 or idx == 0x17 then
    self.ptrs = self:scanBackward(spec.base)
  elseif self.phase == 1 then
    self.gate = 0 -- a forward walk already hit the limit
  else
    local fifth = self.ptrs[5] or spec.base
    self.phase = 0
    self.ptrs = self:scanForward(spec.base, fifth)
  end
  self.havePtrs = true
  self.cd81 = spec.home
  self.cc47 = spec.mode
  self.cc4b = 0
  local vm = self.vm
  vm:wr8(0xCC82, spec.base % 256)
  vm:wr8(0xCC83, math.floor(spec.base / 256) % 256)
  vm:wr8(0xCC84, spec.addend % 256)
  vm:wr8(0xCC85, math.floor(spec.addend / 256) % 256)
  vm:wr8(0xCC87, spec.home)
  vm:wr8(0xCC88, spec.scale)
  vm:wr8(0xCDD7, self.gate)
  self:markRows(spec)
  self:markArrows(spec)
  self:copySlot()
  self:flush()
end

-- ScanGroupBytes: a miss above the first row blanks the top arrow pair,
-- and a miss below the fifth row blanks the bottom pair.
function M:markArrows(spec)
  local base = spec.base
  local function off(ptr)
    if not ptr then return 0 end
    return bit.band(ptr - base, 0xFF)
  end
  local c = off(self.ptrs[1])
  local above = false
  for _ = 1, 256 do
    c = bit.band(c - 1, 0xFF)
    if c == 0xFF then break end
    if self.vm:rd8(base + c) ~= 0 then above = true; break end
  end
  c = off(self.ptrs[5])
  local below = false
  if c ~= 0 then
    for _ = 1, 256 do
      c = bit.band(c + 1, 0xFF)
      if c == 0xFF then break end
      if self.vm:rd8(base + c) ~= 0 then below = true; break end
    end
  end
  self.showAbove, self.showBelow = above, below
  self.vm:wr8(0xCC58, above and 1 or 0)
  self.vm:wr8(0xCC64, above and 1 or 0)
  self.vm:wr8(0xCC59, below and 1 or 0)
  self.vm:wr8(0xCC65, below and 1 or 0)
end

return M
