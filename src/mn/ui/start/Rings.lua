-- Ring entry, IndexedSetup index 7 (DrawIndexedEntry, bank 6 $6A39).
-- Harness name: start.Rings.
--
-- $CD81 chooses how $CC4C walks the ten ids at SRAM $A118 in bank $C727.
-- $19, $1C and $1D read that id. $1B steps forward and skips $FF, wrapping
-- from $A122 back to $A118. Anything else steps backward and wraps from
-- $A117 to $A121. The id times $25 is a record at $A000 in the next SRAM
-- bank. Its first byte is the name id (CopyIndexedName, bank 6 $5AA6,
-- ten glyphs; $FF is the blank at $5A9C) and the picture id
-- (LoadEntryGlyphSource, bank 4 $648D).
local bit = require("bit")
local Machine = require("mn.ui.start.Machine")
local Draw = require("mn.ui.start.Draw")
local Commit = require("mn.ui.start.Commit")
local Font = require("mn.Font")
local Digits = require("mn.ui.start.Digits")
local MnRom = require("mn.MnRom")

local M = {}
M.__index = M

local DEFAULT = { [0] = { 1, 1, 1 }, { 0.75, 0.75, 0.75 }, { 0.4, 0.4, 0.4 }, { 0, 0, 0 } }
local iconCache, picCache = {}, {}

local function palOf(ctx)
  local ow = ctx.ow
  if ow and ow.def and ow.def.pal7 then return ow.def.pal7 end
  return DEFAULT
end

local function rom8(rom, bank, addr)
  if not rom or addr < 0x4000 or addr > 0x7FFF then return 0 end
  return rom:u8(MnRom.off(addr, bank)) or 0
end

-- vm.mem is the active SRAM bank. The id list is bank $C727; the record
-- is the next bank (DrawIndexedEntry's `add a, $01`).
local function sramByte(vm, bank, addr)
  if addr < 0xA000 or addr > 0xBFFF then return 0 end
  if vm.sramBank == nil or bank == vm.sramBank then return vm:rd8(addr) end
  local banks = vm.sramBanks
  if banks and banks[bank] then return banks[bank]:byte(addr - 0xA000 + 1) or 0 end
  return 0
end

local function glyphs(rom, bank, addr, n)
  local t = {}
  for i = 0, n - 1 do t[i + 1] = string.char(rom8(rom, bank, addr + i)) end
  return table.concat(t)
end

-- CopyIndexedName. Id $FF is ten spaces at $5A9C; any other id is $5AA6 + id*10.
local function entryName(rom, id)
  if id == 0xFF then return glyphs(rom, 6, 0x5A9C, 10) end
  return glyphs(rom, 6, 0x5AA6 + id * 10, 10)
end

-- CopyRecordByteBlocks. A zero id copies the twelve indexes at bank 6 $524E.
-- Any other id is the 19-byte record at bank 7 $6916; the twelve glyphs
-- start seven bytes in (CopyIndexedRecord).
local function abilityName(rom, id)
  if id == 0 then return glyphs(rom, 6, 0x524E, 12) end
  return glyphs(rom, 7, 0x6916 + id * 0x13 + 7, 12)
end

-- LoadEntryGlyphSource. Id >= $F0 uses bank $45 at $5B80. A lower id reads
-- the $2D-byte record at bank 4 $415B; the pointer sits at offset $29.
local function glyphSource(rom, id)
  if id >= 0xF0 then return 0x5B80, 0x45, 0x05 end
  local base = 0x415B + id * 0x2D
  local ptr = rom8(rom, 4, base + 0x29) + rom8(rom, 4, base + 0x2A) * 256
  local bank = rom8(rom, 4, base + 0x2B)
  local field = bit.band(rom8(rom, 4, base + 0x2C), 7)
  return ptr, bank, field
end

-- $CD81 $19/$1C/$1D read once. $1B scans forward. Every other slot scans back.
-- A list of only $FF would not return; stop after one pass over the ten ids.
local function walkId(vm, bank, kind)
  local cc = vm:rd8(0xCC4C)
  local function at(i)
    return sramByte(vm, bank, 0xA118 + bit.band(i, 0xFF))
  end
  if kind == "direct" then return at(cc), cc end
  for _ = 1, 10 do
    local hl, nxt
    if kind == "forward" then
      hl = 0xA118 + cc + 1
      nxt = bit.band(cc + 1, 0xFF)
      if hl == 0xA122 then nxt, hl = 0, 0xA118 end
    else
      hl = 0xA118 + cc - 1
      nxt = bit.band(cc - 1, 0xFF)
      if hl == 0xA117 then nxt, hl = 9, 0xA121 end
    end
    cc = nxt
    local b = sramByte(vm, bank, hl)
    if b ~= 0xFF then return b, cc end
  end
  return 0xFF, cc
end

local function recordBytes(vm, bank, id)
  local base = 0xA000 + id * 0x25
  local t = {}
  for i = 0, 0x24 do t[i] = sramByte(vm, bank, base + i) end
  return t
end

-- OR of $FE bytes at $A019 in the list bank. Zero sets $CCA4 and copies
-- the record's pair over $CC69/$CC6A; otherwise those two bytes stay 1.
local function scanA019(vm, bank)
  for i = 0, 0xFD do
    if sramByte(vm, bank, 0xA019 + i) ~= 0 then return false end
  end
  return true
end

function M.new(ctx, mach)
  if not mach then
    mach = Machine.boot(ctx)
    mach.cc47 = 7
    mach.cd81 = 0x19
    mach:copySlot()
    mach:flush()
  end
  local self = setmetatable({ ctx = ctx, mach = mach, entry = {} }, M)
  self:loadEntry()
  return self
end

-- DrawIndexedEntry's SRAM and WRAM half. The six stat bytes are what the
-- map shows. TODO(RunPairIdScripts): bank 5 $4109 can change them first.
function M:loadEntry()
  local vm, rom = self.ctx.vm, self.ctx.rom
  local slot = self.mach.cd81
  local kind = "back"
  if slot == 0x19 or slot == 0x1C or slot == 0x1D then kind = "direct"
  elseif slot == 0x1B then kind = "forward" end
  local listBank = vm:rd8(0xC727)
  local listId, cc = walkId(vm, listBank, kind)
  vm:wr8(0xCC4C, cc)
  local rec = recordBytes(vm, bit.band(listBank + 1, 0xFF), listId)
  local nameId = rec[0]
  local name = entryName(rom, nameId)
  local stats = { rec[9], rec[10], rec[11], rec[12], rec[13], rec[14] }
  local ab = { rec[0x22], rec[0x23] }
  local ptr, gbank, field = glyphSource(rom, nameId)
  local empty = scanA019(vm, listBank)
  -- $CC69/$CC6A are also the skip flags for slots $1C and $1D ($CC4D + index).
  local cc69 = empty and ab[1] or 1
  local cc6a = empty and ab[2] or 1
  self.mach.flags[0x1C] = cc69
  self.mach.flags[0x1D] = cc6a
  vm:wr8(0xCCA4, empty and 1 or 0)
  vm:wr8(0xCC69, cc69)
  vm:wr8(0xCC6A, cc6a)
  for i = 1, 10 do vm:wr8(0xCC89 + i, name:byte(i) or 0) end -- $CC8A
  vm:wr8(0xCC89, 0)
  for i = 1, 6 do vm:wr8(0xD11A + i, stats[i]) end -- $D11B
  vm:wr8(0xD134, ab[1])
  vm:wr8(0xD135, ab[2])
  local cd8c = nameId
  if ab[1] ~= 0 then cd8c = ab[1] end
  if ab[2] ~= 0 then cd8c = ab[2] end
  vm:wr8(0xCD8C, cd8c)
  vm:wr8(0xCD91, ab[2])
  vm:wr8(0xC9D8, nameId)
  vm:wr8(0xC9B1, field)
  vm:wr8(0xC6E6, gbank)
  local adv = bit.band(ptr + 20 * 16, 0xFFFF)
  vm:wr8(0xC6E7, adv % 256)
  vm:wr8(0xC6E8, math.floor(adv / 256) % 256)
  local dest = 0x8D60 + 20 * 16
  vm:wr8(0xC6E9, dest % 256)
  vm:wr8(0xC6EA, math.floor(dest / 256) % 256)
  self.mach.cc4b = 0
  self.mach:flush()
  self.entry = {
    cc4c = cc, listId = listId, nameId = nameId, name = name, stats = stats,
    left = rec[2], right = rec[4], wordH = rec[7], wordL = rec[8],
    ability = ab,
    abilityName = { abilityName(rom, ab[1]), abilityName(rom, ab[2]) },
    glyphPtr = ptr, glyphBank = gbank, glyphField = field,
  }
end

function M:update()
  self.mach:blink()
  local btn = self.mach:take(self.ctx.input)
  local ev = btn and self.mach:press(btn)
  if ev == "redraw" then self:loadEntry() end
  if ev == "menu" then return { action = "back" } end
  if ev == "close" then
    self.mach:leave()
    return { action = "close" }
  end
  if ev == "save" then return Commit.run(self.ctx) end
  return nil
end

local function blit(img, rom, off, dx, dy, pal)
  for y = 0, 7 do
    local lo, hi = rom:u8(off + y * 2) or 0, rom:u8(off + y * 2 + 1) or 0
    for x = 0, 7 do
      local sh = 7 - x
      local ci = math.floor(lo / 2 ^ sh) % 2 + 2 * (math.floor(hi / 2 ^ sh) % 2)
      local c = pal[ci] or pal[0]
      img:setPixel(dx + x, dy + y, c[1], c[2], c[3], 1)
    end
  end
end

-- CopyIndex7VRAMTiles: 32 tiles at bank 6 $77A6, shown as $15-$34.
local function icons(rom, pal)
  local key = pal[0][1] .. ":" .. pal[3][1] .. ":" .. pal[3][3]
  if iconCache[key] then return iconCache[key] end
  local img = love.image.newImageData(32 * 8, 8)
  local base = MnRom.off(0x77A6, 6)
  for t = 0, 31 do blit(img, rom, base + t * 16, t * 8, 0, pal) end
  local im = love.graphics.newImage(img)
  im:setFilter("nearest", "nearest")
  local q = {}
  for t = 0, 31 do q[t] = love.graphics.newQuad(t * 8, 0, 8, 8, 32 * 8, 8) end
  iconCache[key] = { im = im, q = q }
  return iconCache[key]
end

-- Twenty tiles, four across, from the glyph source. Map cells $D6-$E9.
local function picture(rom, bank, ptr, pal)
  if ptr < 0x4000 or ptr > 0x7FFF or bank <= 0 then return nil end
  local key = bank .. ":" .. ptr .. ":" .. pal[0][1] .. ":" .. pal[3][1]
  if picCache[key] then return picCache[key] end
  local img = love.image.newImageData(32, 40)
  local base = MnRom.off(ptr, bank)
  for t = 0, 19 do
    blit(img, rom, base + t * 16, (t % 4) * 8, math.floor(t / 4) * 8, pal)
  end
  local im = love.graphics.newImage(img)
  im:setFilter("nearest", "nearest")
  local q = {}
  for t = 0, 19 do
    q[t] = love.graphics.newQuad((t % 4) * 8, math.floor(t / 4) * 8, 8, 8, 32, 40)
  end
  picCache[key] = { im = im, q = q }
  return picCache[key]
end

local function putDigits(rom, pal, x, y, d, e, skipHigh)
  local h, tens, ones = Digits.format(d, e)
  local function one(n)
    return string.char(rom:u8(MnRom.off(0x5275 + n, 6)) or 0)
  end
  local s = skipHigh and (one(tens) .. one(ones)) or (one(h) .. one(tens) .. one(ones))
  Font.drawText(s, x, y, pal)
end

-- indexed_map_07_*.asm, then the cells DrawIndexedEntry writes on top.
-- TODO(IndexedSetup): the icon tiles outside $15-$34 ($C3, $BC-$C2, $9F)
-- come from the block copy before this tail and are not drawn.
function M:paint(pal)
  local rom, e = self.ctx.rom, self.entry
  if not rom or not e.name then return end
  local src = rom:u16(MnRom.off(0x51C1 + 7 * 2, 6)) or 0
  local pic = picture(rom, e.glyphBank, e.glyphPtr, pal)
  local ico = icons(rom, pal)
  love.graphics.setColor(1, 1, 1)
  if src ~= 0 then
    for row = 0, 9 do
      for col = 0, 19 do
        local t = rom:u8(MnRom.off(src + row * 20 + col, 6)) or 0
        local x, y = col * 8, (row + 1) * 8
        if t >= 0x15 and t <= 0x34 then
          love.graphics.draw(ico.im, ico.q[t - 0x15], x, y)
        elseif t == 0x7F then
          Font.drawText(string.char(t), x, y, pal)
        elseif t >= 0xAB and t <= 0xB4 then
          Font.drawText(string.char(e.name:byte(t - 0xAB + 1) or 0x20), x, y, pal)
        elseif t >= 0xD6 and t <= 0xE9 and pic then
          love.graphics.draw(pic.im, pic.q[t - 0xD6], x, y)
        elseif row == 6 and col >= 3 and col <= 14 then
          Font.drawText(string.char(e.abilityName[1]:byte(col - 2) or 0x20), x, y, pal)
        elseif row == 7 and col >= 3 and col <= 14 then
          Font.drawText(string.char(e.abilityName[2]:byte(col - 2) or 0x20), x, y, pal)
        end
      end
    end
  end
  putDigits(rom, pal, 10 * 8, 3 * 8, 0, e.left, true)
  putDigits(rom, pal, 17 * 8, 3 * 8, 0, e.right, true)
  local st = e.stats
  putDigits(rom, pal, 10 * 8, 4 * 8, 0, st[1], true)
  putDigits(rom, pal, 17 * 8, 4 * 8, 0, st[2], true)
  putDigits(rom, pal, 10 * 8, 5 * 8, 0, st[4], true)
  putDigits(rom, pal, 17 * 8, 5 * 8, 0, st[5], true)
  putDigits(rom, pal, 10 * 8, 6 * 8, 0, st[3], true)
  putDigits(rom, pal, 17 * 8, 6 * 8, 0, st[6], true)
  putDigits(rom, pal, 15 * 8, 9 * 8, e.wordH, e.wordL, false)
end

function M:draw()
  Draw.chrome(self.ctx)
  self:paint(palOf(self.ctx))
  Draw.cursor(self.ctx, self.mach)
end

return M
