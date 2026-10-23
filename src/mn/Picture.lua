-- Full-screen picture for the travel cards and the attract slideshow.
-- $63 unpacks two packed streams onto the $9800 map (UnpackScriptMapsAt9800,
-- $2D14). $6A copies tile lists into both VRAM banks (CopyMapRecords, $2FC0)
-- and loads the eight BG palettes (FillC72BFromBCThenBank7 then
-- CopyC7ABToBGPalettes). draw() paints the 160x144 background the way
-- LCDC $E3 does (turn_on_lcd.asm): map $9800, tiles in the $8800 method,
-- window map $9C00 kept just off the bottom (setup_window.asm, WY $90).
-- Attribute bits follow paint_map_attrs_seed_slot.asm: palette in bits 0-2,
-- VRAM bank in bit 3, horizontal flip in bit 5, vertical flip in bit 6.
local bit = require("bit")
local band, rshift = bit.band, bit.rshift
local MnRom = require("mn.MnRom")
local Unpack = require("mn.picture.Unpack")
local Records = require("mn.picture.Records")

local Picture = {}
Picture.__index = Picture

-- LCD on, BG map $9800, BG tiles at $8800 (bit 4 clear), window on at $9C00.
local LCDC_PLAY = 0xE3

local function blankBank()
  local m = {}
  for i = 0, 0x1FFF do m[i] = 0 end
  return m
end

local function blankPal()
  local pal = {}
  for p = 0, 7 do
    pal[p] = { [0] = { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } }
  end
  return pal
end

function Picture.new()
  return setmetatable({
    vram = { [0] = blankBank(), [1] = blankBank() },
    pal = blankPal(),
    scx = 0, scy = 0,
    lcdc = LCDC_PLAY,
    wx = 7, wy = 0x90, -- setup_window.asm: window sits on the line below the picture
  }, Picture)
end

function Picture:touch() self._im = nil end

-- clamp_map_camera.asm writes SCX to $FF43 and SCY to $FF42. $63/$6A do not.
-- A picture that still has its vm reads those live bytes at draw time.
function Picture:scroll()
  if self.vm then return self.vm:rd8(0xFF43) % 256, self.vm:rd8(0xFF42) % 256 end
  return (self.scx or 0) % 256, (self.scy or 0) % 256
end

local function readFn(rom)
  return function(o) return rom:u8(o) or 0 end
end

-- UnpackScriptMapsAt9800 ($2D14). First stream is the attribute plane
-- (VRAM bank 1 at $9800). The next stream is the tile-id plane (bank 0).
function Picture:unpackMaps(rom, bank, ptr)
  local o = MnRom.off(ptr, bank)
  local read = readFn(rom)
  local function into(vb, addr)
    local mem, dest = self.vram[vb], addr
    o = Unpack.unpack(read, o, function(v)
      if dest >= 0x8000 and dest < 0xA000 then mem[dest - 0x8000] = v end
      dest = dest + 1
    end)
  end
  into(1, 0x9800)
  into(0, 0x9800)
  self:touch()
  return o
end

-- CopyMapRecords ($2FC0) from the banked list $6A names.
function Picture:copyRecords(rom, bank, ptr)
  Records.copyLists(rom, self.vram, MnRom.off(ptr, bank))
  self:touch()
end

local function rgb555(w)
  return { band(w, 31) / 31, band(rshift(w, 5), 31) / 31, band(rshift(w, 10), 31) / 31 }
end

-- The $40 bytes CopyC7ABToBGPalettes writes to rBCPD. Eight palettes,
-- four colours, little-endian RGB555. $6A's second record is that block.
function Picture:loadPalettes(rom, bank, ptr)
  local o = MnRom.off(ptr, bank)
  for p = 0, 7 do
    local row = {}
    for c = 0, 3 do
      local w = rom:u16(o)
      o = o + 2
      row[c] = rgb555(w)
    end
    self.pal[p] = row
  end
  self:touch()
end

-- Nonzero bytes in the tile pattern ($8000-$97FF) and in both map planes
-- ($9800-$9FFF). Counts only; the bytes stay in the picture.
function Picture:counts()
  local map, tiles = 0, 0
  for b = 0, 1 do
    local mem = self.vram[b]
    for i = 0, 0x17FF do if mem[i] ~= 0 then tiles = tiles + 1 end end
    for i = 0x1800, 0x1FFF do if mem[i] ~= 0 then map = map + 1 end end
  end
  return map, tiles
end

-- $8800 method (LCDC bit 4 clear): id 0 at $9000, id 128 at $8800.
-- $8000 method (bit 4 set): id 0 at $8000. Offset is from $8000.
local function tileOff(id, lcdc)
  id = id % 256
  if band(lcdc, 0x10) ~= 0 then return id * 16 end
  if id < 128 then return 0x1000 + id * 16 end
  return id * 16
end

function Picture:colorAt(mapBase, mx, my)
  mx, my = mx % 256, my % 256
  local rel = mapBase - 0x8000 + math.floor(my / 8) * 32 + math.floor(mx / 8)
  local tid = self.vram[0][rel] or 0
  local attr = self.vram[1][rel] or 0
  local xf, yf = band(attr, 0x20) ~= 0, band(attr, 0x40) ~= 0
  local tx, ty = mx % 8, my % 8
  local sy = yf and (7 - ty) or ty
  local sh = xf and tx or (7 - tx)
  local mem = self.vram[band(attr, 0x08) ~= 0 and 1 or 0]
  local base = tileOff(tid, self.lcdc or LCDC_PLAY)
  local lo = mem[base + sy * 2] or 0
  local hi = mem[base + sy * 2 + 1] or 0
  local ci = band(rshift(lo, sh), 1) + 2 * band(rshift(hi, sh), 1)
  local c = self.pal[band(attr, 7)][ci]
  return c[1], c[2], c[3]
end

-- One screen pixel. The window (LCDC bit 5) uses WY/WX; WX 7 is screen x 0
-- and WY $90 is the first line off the bottom, so a card shows the BG.
function Picture:sample(x, y)
  local lcdc = self.lcdc or LCDC_PLAY
  local sx, sy = self:scroll()
  local winOn = band(lcdc, 0x20) ~= 0
  local wx = (self.wx or 7) - 7
  local wy = self.wy or 0x90
  if winOn and y >= wy and x >= wx and wx < 160 then
    local base = band(lcdc, 0x40) ~= 0 and 0x9C00 or 0x9800
    return self:colorAt(base, x - wx, y - wy)
  end
  local base = band(lcdc, 0x08) ~= 0 and 0x9C00 or 0x9800
  return self:colorAt(base, x + sx, y + sy)
end

function Picture:render(put)
  for y = 0, 143 do
    for x = 0, 159 do
      local r, g, b = self:sample(x, y)
      put(x, y, r, g, b)
    end
  end
end

function Picture:draw()
  if not love or not love.image or not love.graphics then return end
  local sx, sy = self:scroll()
  if not self._im or self._sx ~= sx or self._sy ~= sy or self._wx ~= self.wx or self._wy ~= self.wy then
    local img = love.image.newImageData(160, 144)
    self:render(function(x, y, r, g, b) img:setPixel(x, y, r, g, b, 1) end)
    local im = love.graphics.newImage(img)
    im:setFilter("nearest", "nearest")
    self._im, self._sx, self._sy, self._wx, self._wy = im, sx, sy, self.wx, self.wy
  end
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self._im, 0, 0)
end

return Picture
