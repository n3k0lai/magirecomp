-- Armed choice ($8B) and window choice ($8D).
-- StageTilesArmSlot (bank 3 $50D0) jumps to DispatchArmedChoice ($4F83).
-- StageWindowTilesArmSlot ($5AAE) jumps to ServiceWindowChoice ($58CB).
-- Each frame is RefreshChoiceCursor ($4141) or PrepWindowChoiceFrame ($415D):
-- QueueBlinkSprite ($4100), then DispatchMaskedAction ($41E3). Directions
-- are SelectSlotFromHighNibble ($4000) over the 8-byte records CopyIndexedSlot
-- ($4274) copies from the SlotListBaseTable ($4524) list for $CCB4.
-- A and B are MaskedActionSlotTable ($42A9) indexes 4 and 5: $CD81 into
-- $CCA7, or $FE. The opener's $CCA9 mask is $F3, and $C932 is the new-press
-- byte from ReadJoypadSample.
local bit = require("bit")
local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift
local Font = require("mn.Font")
local MnRom = require("mn.MnRom")

local M = {}
M.__index = M

local PAL = { [0] = { 1, 1, 1 }, { 0.75, 0.75, 0.75 }, { 0.4, 0.4, 0.4 }, { 0, 0, 0 } }
local SLOT_TABLE = 0x4524
local ARMED_MAP = 0x4CB3
local LIST_LEN = { [7] = 13, [8] = 14 }

-- PrepareChoice012 ($5158): the three bottom slots of the armed menu.
-- The item submenu that follows (StageIndexedChoiceTiles) is not run.
local CHOICE_012 = {
  [0] = { fd = 0x00, e9 = 0x0C, e8 = 0x22, e6 = 0x5DFF, e4 = 0xA3A7 },
  [1] = { fd = 0x03, e9 = 0x0C, e8 = 0x22, e6 = 0x6FF5, e4 = 0xA5A5 },
  [2] = { fd = 0x02, e9 = 0x06, e8 = 0x13, e6 = 0x6916, e4 = 0xA019 },
}

local function put16(vm, a, w)
  vm:wr8(a, w % 256)
  vm:wr8(a + 1, math.floor(w / 256))
end

-- Same stores as opcode $8D (StageWindowTilesArmSlot, bank 3 $5AAE).
function M.demo(vm)
  vm:wr8(0xC728, 0); vm:wr8(0xC729, 0)
  vm:wr8(0xC6EB, 1)
  put16(vm, 0xC6E7, 0x41D0)
  put16(vm, 0xC6E9, 0x8900)
  vm:wr8(0xCC42, 0x05)
  put16(vm, 0xCC43, 0x52E0)
  put16(vm, 0xCC45, 0x8920)
  vm:wr8(0xCD58, vm:rd8(0xA122))
  vm:wr8(0xCC4E, 1)
  for i = 0, 3 do vm:wr8(0xCC56 + i, 1) end
  vm:wr8(0xCD81, 1)
  vm:wr8(0xCCB4, 7)
  vm:wr8(0xCCA9, 0xF3)
  vm:wr8(0xCCB8, vm:rd8(0xC937))
  put16(vm, 0xCCB6, 0xCC4D)
  put16(vm, 0xCCB0, 0x42E3)
  put16(vm, 0xCCB2, 0x42E3)
  vm:wr8(0xCCB9, 0)
  vm:wr8(0xCCBA, 0)
  vm:wr8(0xCCA7, 0xFF)
end

function M.new(ctx)
  ctx = ctx or {}
  local vm = ctx.vm
  if vm and vm:rd8(0xCCB4) ~= 7 and vm:rd8(0xCCB4) ~= 8 then M.demo(vm) end
  local kind = (vm and vm:rd8(0xCCB4) == 8) and "armed" or "window"
  local self = setmetatable({
    ctx = ctx, kind = kind, replace = {}, tiles = {},
    show = false, tile = 0x82, lastDir = nil, col = 0, row = 0,
  }, M)
  if vm and kind == "armed" then self:seedArmed() end
  if vm and kind == "window" then self:loadPage() end
  if vm and ctx.rom then self:buildReplace() end
  if vm and ctx.rom then self:copySlot() end
  return self
end

-- PaintMapAttrsSeedSlot ($7463) plants the armed record, then the opener
-- stores 3 at $CCE3. $CD81 starts at 0, so the cursor is record 0.
function M:seedArmed()
  local vm = self.ctx.vm
  vm:wr8(0xCCD6, 1); vm:wr8(0xCCD7, 1); vm:wr8(0xCCD8, 1)
  for a = 0xCCD9, 0xCCE2 do vm:wr8(a, 0) end
  vm:wr8(0xCD81, 0)
  vm:wr8(0xCD7F, 0)
  vm:wr8(0xCD80, 0)
  vm:wr8(0xCCA8, 0x81)
end

function M:sram(bank, addr)
  local vm = self.ctx.vm
  local banks = vm.sramBanks
  if addr < 0xA000 or addr > 0xBFFF then return 0 end
  if banks and banks[bank] then
    return banks[bank]:byte(addr - 0xA000 + 1) or 0
  end
  if not banks or vm.sramBank == bank then return vm:rd8(addr) end
  return 0
end

-- LoadPagedSRAMChoicePairs ($6400). $CD81 picks the page: 0 back, 8 forward,
-- anything else the first page. Pairs land at $CD59; $CC4E marks shown rows.
function M:loadPage()
  local vm = self.ctx.vm
  for i = 0, 8 do vm:wr8(0xCC4D + i, 0) end
  for i = 0, 13 do vm:wr8(0xCD59 + i, 0xFF) end
  local dir = vm:rd8(0xCD81)
  if dir == 0 then vm:wr8(0xCD57, (vm:rd8(0xCD57) - 7) % 256)
  elseif dir == 8 then vm:wr8(0xCD57, (vm:rd8(0xCD57) + 7) % 256)
  else vm:wr8(0xCD57, 0) end
  local start = vm:rd8(0xCD57)
  local limit = vm:rd8(0xCD58)
  local bank = (vm:rd8(0xC727) + 1) % 256
  local step, count, dest = 0, 0, 0xCD59
  while true do
    count = (count + 1) % 256
    local index = (start + step) % 256
    local hl = (0xA025 + index * 0x25) % 65536
    vm:wr8(dest, self:sram(bank, hl))
    vm:wr8(dest + 1, self:sram(bank, (hl + 2) % 65536))
    dest = dest + 2
    step = (step + 1) % 256
    if step == 7 then break end
    if (step + start) % 256 == limit then break end
  end
  vm:wr8(0xCD67, count)
  vm:wr8(0xCC89, step)
  vm:wr8(0xCC4D, start)
  if (start + count) % 256 < limit then vm:wr8(0xCC55, 1) end
  for i = 0, count - 1 do vm:wr8(0xCC4E + i, 1) end
  self:stampRowMarks()
end

-- PaintWindowIndexedRows ($5744): a hit in the ten $A118 bytes marks the row.
function M:stampRowMarks()
  local vm = self.ctx.vm
  local bank = vm:rd8(0xC727)
  for i = 0, 6 do
    local b = (vm:rd8(0xCD57) + i + 1) % 256
    for d = 0, 9 do
      if self:sram(bank, 0xA118 + d) == b then vm:wr8(0xCC4E + i, 0x0A); break end
    end
  end
end

function M:addReplace(srcPtr, count, destAddr)
  local rom = self.ctx.rom
  if not rom then return end
  local tile = math.floor((destAddr - 0x8000) / 16)
  local o = MnRom.off(srcPtr, 6)
  for i = 0, count - 1 do self.replace[tile + i] = rom:u8(o + i) end
end

-- CopyIndexedBlocks ($4000 in bank 6) plants glyph indexes at a VRAM tile.
function M:buildReplace()
  local vm = self.ctx.vm
  if self.kind == "armed" then
    local n = vm:rd8(0xCC42)
    local src = vm:rd8(0xCC43) + vm:rd8(0xCC44) * 256
    local dest = vm:rd8(0xCC45) + vm:rd8(0xCC46) * 256
    self:addReplace(src, n, dest)
  else
    -- stage_window_tiles_arm_slot.asm / paint_window_indexed_rows.asm
    self:addReplace(0x5275, 0x0A, 0x8860)
    self:addReplace(0x52E0, 0x05, 0x8920)
    self:addReplace(0x52C0, 0x11, 0x8DD0)
    self:addReplace(0x52D1, 0x0F, 0x8EE0)
  end
end

function M:copySlot()
  local vm, rom = self.ctx.vm, self.ctx.rom
  local list = vm:rd8(0xCCB4)
  local base = rom:u16(MnRom.off(SLOT_TABLE + list * 2, 3))
  if base < 0x4000 then return end
  local rec = vm:rd8(0xCD81)
  local n = LIST_LEN[list] or 1
  if rec >= n then rec = 0 end
  local o = MnRom.off(base + rec * 8, 3)
  for i = 0, 7 do vm:wr8(0xCD82 + i, rom:u8(o + i)) end
  self.col, self.row = vm:rd8(0xCD82), vm:rd8(0xCD83)
end

-- A zero mark at [$CCB6]+index makes SelectSlotFromHighNibble repeat the
-- same candidate. That does not return, so the cursor stays.
function M:takeSlot(dest)
  local vm = self.ctx.vm
  local p = vm:rd8(0xCCB6) + vm:rd8(0xCCB7) * 256
  if p ~= 0 and vm:rd8((p + dest) % 65536) == 0 then return end
  vm:wr8(0xCD81, dest % 256)
  if self.ctx.rom then self:copySlot() end
end

function M:moveHigh(hi)
  local vm = self.ctx.vm
  local which = 3
  for i = 0, 2 do
    if band(hi, lshift(1, i)) ~= 0 then which = i; break end
  end
  self:takeSlot(vm:rd8(0xCD84 + which))
end

function M:runAction(i)
  local vm = self.ctx.vm
  if i == 4 then vm:wr8(0xCCA7, vm:rd8(0xCD81)) -- StoreSelectedSlotIndex ($42B7)
  elseif i == 5 then vm:wr8(0xCCA7, 0xFE) -- StoreFeSlotIndex ($42BE)
  elseif i == 1 then -- LatchSelectedSlot ($42C4)
    if vm:rd8(0xCD80) == 0 then vm:wr8(0xCD80, 1)
    else vm:wr8(0xCCA7, vm:rd8(0xCD81)) end
  elseif i == 2 then -- DecrementSlotLatch ($42D4)
    local n = vm:rd8(0xCD80)
    if n == 0 then vm:wr8(0xCCA7, 0xFE) else vm:wr8(0xCD80, (n - 1) % 256) end
  end
  -- TODO(step_slot_pair): action 0. TODO(hold_lcd_off): action 3.
end

function M:dispatch(mask)
  local vm = self.ctx.vm
  if band(mask, 0x04) ~= 0 then return end -- bit 2 jumps through $CCB2
  if band(mask, 0x01) ~= 0 then self:runAction(vm:rd8(0xCD88)); return end
  if band(mask, 0x02) ~= 0 then self:runAction(vm:rd8(0xCD89)); return end
  if vm:rd8(0xCD80) == 1 then return end
  local hi = rshift(band(mask, 0xF0), 4)
  if hi ~= 0 then self:moveHigh(hi) end
end

-- QueueBlinkSprite ($4100). $CCB9 of 0, or $CD80 of 1, holds tile $82 on.
-- Otherwise tile $81 is hidden while $CD7F is below $0F, period $1F.
function M:tickBlink()
  local vm = self.ctx.vm
  vm:wr8(0xCCA8, 0x82)
  if vm:rd8(0xCD80) == 1 or vm:rd8(0xCCB9) == 0 then
    self.tile, self.show = 0x82, true
    return
  end
  vm:wr8(0xCCA8, 0x81)
  local n = (vm:rd8(0xCD7F) + 1) % 256
  if n == 0x1F then n = 0 end
  vm:wr8(0xCD7F, n)
  self.tile, self.show = 0x81, n >= 0x0F
end

function M:poll()
  local vm = self.ctx.vm
  local inp = self.ctx.input or function() return false end
  local d = inp("dir")
  local fresh = d and d ~= self.lastDir
  self.lastDir = d
  local bits = 0
  if inp("a") then bits = bor(bits, 0x01) end
  if inp("b") then bits = bor(bits, 0x02) end
  if fresh and d == "right" then bits = bor(bits, 0x10)
  elseif fresh and d == "left" then bits = bor(bits, 0x20)
  elseif fresh and d == "up" then bits = bor(bits, 0x40)
  elseif fresh and d == "down" then bits = bor(bits, 0x80) end
  self:dispatch(band(bits, vm:rd8(0xCCA9)))
end

local function apply012(vm, c)
  local rec = CHOICE_012[c]
  vm:wr8(0xCCD5, 0)
  vm:wr8(0xCCCB, c)
  vm:wr8(0xCCFD, rec.fd)
  vm:wr8(0xCCE9, rec.e9)
  vm:wr8(0xCCE8, rec.e8)
  put16(vm, 0xCCE6, rec.e6)
  vm:wr8(0xCCEA, 0x0D)
  put16(vm, 0xCCE4, rec.e4)
end

function M:commitArmed(c)
  local vm = self.ctx.vm
  if c == 0xFE then
    -- StepFeChoiceByCce3 ($5238): $CCE3 of 3 stores $FF at $CCFC and $CCFD
    -- and leaves through ReloadChoiceFrame ($7637).
    if vm:rd8(0xCCE3) ~= 3 then
      -- TODO(step_fe_choice_by_cce3): other $CCE3 values re-arm the slot
      vm:wr8(0xCCA7, 0xFF)
      return nil
    end
    vm:wr8(0xCCFC, 0xFF); vm:wr8(0xCCFD, 0xFF)
    return { pick = c, cancelled = true }
  end
  if c == 0x0B or c == 0x0C then
    -- TODO(step_choice_0b_by_ccc8): $0B/$0C scroll and return to the wait
    vm:wr8(0xCCA7, 0xFF)
    return nil
  end
  if CHOICE_012[c] then
    apply012(vm, c)
    -- TODO(prepare_choice_012): StageIndexedChoiceTiles stays in the loop
    return { pick = c, cancelled = false }
  end
  -- CopyOtherChoiceByte ($521A). $0D blanks both result bytes.
  if c == 0x0D then
    vm:wr8(0xCCFC, 0xFF); vm:wr8(0xCCFD, 0xFF)
    return { pick = c, cancelled = true }
  end
  vm:wr8(0xCCFC, vm:rd8(0xCCCD + (c - 3) % 256))
  return { pick = c, cancelled = false }
end

function M:commitWindow(c)
  local vm = self.ctx.vm
  vm:wr8(0xCD74, c) -- ServiceWindowChoice saves the choice before it branches
  if c == 0 or c == 8 then
    self:loadPage()
    vm:wr8(0xCD81, 1)
    vm:wr8(0xCCB9, 0)
    vm:wr8(0xCCBA, 0)
    vm:wr8(0xCCA7, 0xFF)
    if self.ctx.rom then self:copySlot() end
    return nil
  end
  if c == 0xFE then return { pick = c, cancelled = true } end
  -- TODO(resolve_armed_list_choice): confirm strips, $CD69, and the $A118 edit
  return { pick = c, cancelled = false }
end

function M:update()
  local vm = self.ctx.vm
  if not vm then return { pick = 0, cancelled = true } end
  self:tickBlink()
  if vm:rd8(0xCCA7) == 0xFF then self:poll() end
  local c = vm:rd8(0xCCA7)
  if c == 0xFF then return nil end
  if self.kind == "armed" then return self:commitArmed(c) end
  return self:commitWindow(c)
end

-- BG ids $80-$85 are the frame at bank 6 $50B0 (Font.lua). The cursor
-- sprite uses the glyph at $4000 + id*16 (QueueBlinkSprite).
local function glyphPtr(gid, sprite)
  if not sprite and gid >= 0x80 and gid <= 0x85 then return MnRom.off(0x50B0 + (gid - 0x80) * 16, 6) end
  return MnRom.off(0x4000 + (gid % 256) * 16, 6)
end

function M:tileImage(gid, sprite)
  local key = sprite and gid + 256 or gid
  local im = self.tiles[key]
  if im then return im end
  local rom = self.ctx.rom
  local ptr = glyphPtr(gid, sprite)
  local img = love.image.newImageData(8, 8)
  for y = 0, 7 do
    local lo, hi = rom:u8(ptr + y * 2), rom:u8(ptr + y * 2 + 1)
    for x = 0, 7 do
      local sh = 7 - x
      local ci = rshift(lo, sh) % 2 + 2 * (rshift(hi, sh) % 2)
      local c = PAL[ci]
      img:setPixel(x, y, c[1], c[2], c[3], 1)
    end
  end
  im = love.graphics.newImage(img)
  im:setFilter("nearest", "nearest")
  self.tiles[key] = im
  return im
end

function M:blit(vram, x, y, h, v)
  local gid = self.replace[vram]
  if gid == nil then gid = vram end
  local im = self:tileImage(gid, false)
  if h or v then
    love.graphics.draw(im, x + (h and 8 or 0), y + (v and 8 or 0), 0, h and -1 or 1, v and -1 or 1)
  else
    love.graphics.draw(im, x, y)
  end
end

-- PaintMapAttrsSeedSlot attribute flips on the $9C00 map.
local function flips(row, col)
  local h = col == 0 and row <= 16
  local v = false
  if row == 1 and col == 10 then h = true end
  if row == 17 and col == 19 then v = true end
  if row == 12 and col == 9 then v = true end
  if row == 17 and col == 0 then h, v = true, true end
  if row == 12 and col == 10 then h, v = true, true end
  if row == 17 and col >= 1 and col <= 18 then v = true end
  return h, v
end

function M:drawArmed()
  local rom = self.ctx.rom
  local base = MnRom.off(ARMED_MAP, 3)
  for row = 0, 17 do
    for col = 0, 19 do
      local h, v = flips(row, col)
      self:blit(rom:u8(base + row * 20 + col), col * 8, row * 8, h, v)
    end
  end
end

local function runOf(rom, ptr, n)
  local t, o = {}, MnRom.off(ptr, 6)
  for i = 0, n - 1 do t[i + 1] = string.char(rom:u8(o + i)) end
  return table.concat(t)
end

function M:drawWindow()
  local vm, rom = self.ctx.vm, self.ctx.rom
  for row = 0, 17 do for col = 0, 19 do self:blit(0x80, col * 8, row * 8) end end
  for col = 1, 18 do self:blit(0x83, col * 8, 0); self:blit(0x83, col * 8, 17 * 8, false, true) end
  self:blit(0x85, 0, 0, true, false)
  self:blit(0x85, 19 * 8, 0)
  self:blit(0x85, 0, 17 * 8, true, true)
  self:blit(0x85, 19 * 8, 17 * 8, false, true)
  for row = 1, 16 do self:blit(0x84, 0, row * 8, true, false); self:blit(0x84, 19 * 8, row * 8) end
  local upper = vm:rd8(0xCC4D) ~= 0 and 0x91 or 0x80
  local lower = vm:rd8(0xCC55) ~= 0 and 0x91 or 0x80
  self:blit(upper, 9 * 8, 1 * 8); self:blit(upper, 10 * 8, 1 * 8)
  self:blit(lower, 9 * 8, 11 * 8); self:blit(lower, 10 * 8, 11 * 8)
  -- $92-$94 at $9C4D, $95 at $9C51: the second index list (paint_window_tilemap.asm).
  Font.drawText(runOf(rom, 0x52E0, 3), 13 * 8, 2 * 8)
  Font.drawText(runOf(rom, 0x52E0 + 3, 1), 17 * 8, 2 * 8)
  for i = 0, 6 do
    if vm:rd8(0xCC4E + i) ~= 0 then
      -- TODO(paint_window_indexed_rows): name tiles at bank 6 $5A60 and
      -- FormatStartDigits at columns 14-15 are not decoded yet.
      self:blit(0x90, 2 * 8, (3 + i) * 8)
      if vm:rd8(0xCC4E + i) == 0x0A then
        Font.drawText(runOf(rom, 0x52E0 + 4, 1), 17 * 8, (3 + i) * 8)
      end
    end
  end
  -- Ascending tiles from $DD at $9DA1 and $9DC1 (paint_window_indexed_rows.asm).
  Font.drawText(runOf(rom, 0x52C0, 0x11), 8, 13 * 8)
  Font.drawText(runOf(rom, 0x52D1, 0x0F), 8, 14 * 8)
end

function M:draw()
  if not love or not love.graphics or not self.ctx.rom then return end
  love.graphics.setColor(1, 1, 1, 1)
  if self.kind == "armed" then self:drawArmed() else self:drawWindow() end
  if self.show then love.graphics.draw(self:tileImage(self.tile, true), self.col * 8, self.row * 8) end
end

return M
