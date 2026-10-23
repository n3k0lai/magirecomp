-- Glyph map, IndexedSetup index 9. A on slot 4 is command $09, next slot
-- $14 (slot_pair_records_from_0.asm). DrawIndex9Map (06:659C) stamps the
-- CopyIndexedMap tilemap from $A3A4 (sMapFlag). Slot $14's record is at
-- $4A8B: column and row are both $14, and every direction stays there, so
-- the cursor sits past the window. B is command $00, next slot 4, which
-- returns to the glyph row. Harness name: start.Glyph
local bit = require("bit")
local Machine = require("mn.ui.start.Machine")
local Draw = require("mn.ui.start.Draw")
local Commit = require("mn.ui.start.Commit")
local MnRom = require("mn.MnRom")

local M = {}
M.__index = M

local BANK = 6
local MAP_TABLE = 0x51C1
local STAMP = 0x6FA6
local STRIP = 0x6F92
local ATTR = 0x6FAC
local ATTR_STRIP = 0x700C
local TILES = 0x79A6
local TILE_COUNT = 70 -- CopyIndex9VRAMTiles copies $460 bytes from $79A6
local ATTR_FILL = 0x0F

local sheets = {}

local function rom8(rom, addr)
  if not rom then return 0 end
  return rom:u8(MnRom.off(addr, BANK)) or 0
end

local function cellAt(addr)
  local off = addr - 0x9C20
  return math.floor(off / 0x20), off % 0x20
end

-- DrawIndex9Map's compares. Flag 1 leaves the tilemap alone. Each higher
-- value adds the next stamp and returns. Anything else also copies the
-- five-row strip at $6F92 (CopyFiveMapRows).
local function stampTiles(rom, flag, tiles)
  if flag == 1 then return end
  local function poke(addr, n, src)
    local row, col = cellAt(addr)
    for i = 0, n - 1 do
      tiles[row * 20 + col + i] = rom8(rom, src + i)
    end
  end
  poke(0x9CC9, 2, STAMP)
  if flag == 2 then return end
  poke(0x9CE9, 1, STAMP + 2)
  if flag == 3 then return end
  poke(0x9CEA, 1, STAMP + 3)
  if flag == 4 then return end
  poke(0x9D09, 2, STAMP + 4)
  if flag == 5 then return end
  for row = 0, 4 do
    poke(0x9C28 + row * 0x20, 4, STRIP + row * 4)
  end
end

-- StampSetupAttributes index 9. Eight rows of twelve bytes from $6FAC
-- land at $9C44. Later $0F stores clear the flip on single cells, and
-- flag 6 also copies the attribute strip at $700C.
local function stampAttrs(rom, flag, h, v)
  local function poke(addr, n, src, const)
    local row, col = cellAt(addr)
    for i = 0, n - 1 do
      local a = const or rom8(rom, src + i)
      local k = row * 20 + col + i
      h[k] = bit.band(a, 0x20) ~= 0
      v[k] = bit.band(a, 0x40) ~= 0
    end
  end
  for row = 0, 7 do
    poke(0x9C44 + row * 0x20, 12, ATTR + row * 12)
  end
  if flag < 2 then return end
  poke(0x9CCA, 1, 0, ATTR_FILL)
  if flag < 4 then return end
  poke(0x9CEA, 1, 0, ATTR_FILL)
  if flag < 5 then return end
  poke(0x9D0A, 1, 0, ATTR_FILL)
  if flag ~= 6 then return end
  for row = 0, 4 do
    poke(0x9C28 + row * 0x20, 4, ATTR_STRIP + row * 4)
  end
end

-- Tile ids and flip bits for one frame. Index 9's map word is at 06:51D3.
function M.layout(rom, flag)
  local tiles, h, v = {}, {}, {}
  for i = 0, 199 do
    tiles[i] = 0x80
    h[i] = false
    v[i] = false
  end
  flag = flag or 0
  local src = rom8(rom, MAP_TABLE + 9 * 2) + rom8(rom, MAP_TABLE + 9 * 2 + 1) * 256
  if src ~= 0 then
    for i = 0, 199 do tiles[i] = rom8(rom, src + i) end
  end
  stampTiles(rom, flag, tiles)
  stampAttrs(rom, flag, h, v)
  return tiles, h, v
end

local function palOf(ctx)
  local ow = ctx.ow
  if ow and ow.def and ow.def.pal7 then return ow.def.pal7 end
  return { [0] = { 1, 1, 1 }, { 0.75, 0.75, 0.75 }, { 0.4, 0.4, 0.4 }, { 0, 0, 0 } }
end

local function sheet(rom, pal)
  local key = tostring(rom) .. pal[0][1] .. pal[3][1] .. pal[3][3]
  if sheets[key] then return sheets[key] end
  local img = love.image.newImageData(8 * TILE_COUNT, 8)
  local base = MnRom.off(TILES, BANK)
  for t = 0, TILE_COUNT - 1 do
    for y = 0, 7 do
      local lo = rom:u8(base + t * 16 + y * 2) or 0
      local hi = rom:u8(base + t * 16 + y * 2 + 1) or 0
      for x = 0, 7 do
        local sh = 7 - x
        local ci = bit.band(bit.rshift(lo, sh), 1) + 2 * bit.band(bit.rshift(hi, sh), 1)
        local c = pal[ci]
        img:setPixel(t * 8 + x, y, c[1], c[2], c[3], 1)
      end
    end
  end
  local im = love.graphics.newImage(img)
  im:setFilter("nearest", "nearest")
  local q = {}
  for t = 0, TILE_COUNT - 1 do
    q[t] = love.graphics.newQuad(t * 8, 0, 8, 8, 8 * TILE_COUNT, 8)
  end
  sheets[key] = { im = im, q = q }
  return sheets[key]
end

function M.new(ctx, mach)
  if not mach then
    mach = Machine.boot(ctx)
    -- Same pair A on the glyph row uses (slot_pair_records_from_0.asm).
    mach.cd81 = 4
    mach:copySlot()
    mach:action(true)
  end
  -- IndexedSetup stores 0 at $CC4B on the way out of DrawIndex9Map.
  mach.cc4b = 0
  mach:flush()
  return setmetatable({ ctx = ctx, mach = mach }, M)
end

function M:update()
  self.mach:blink()
  local btn = self.mach:take(self.ctx.input)
  local ev = btn and self.mach:press(btn)
  if ev == "menu" then return { action = "back" } end
  if ev == "close" then
    self.mach:leave()
    return { action = "close" }
  end
  if ev == "save" then return Commit.run(self.ctx) end
  return nil
end

function M:draw()
  local ctx = self.ctx
  Draw.chrome(ctx)
  local pal = palOf(ctx)
  local tiles, h, v = M.layout(ctx.rom, ctx.vm:rd8(0xA3A4))
  local pic = sheet(ctx.rom, pal)
  love.graphics.setColor(1, 1, 1)
  for row = 0, 9 do
    for col = 0, 19 do
      local k = row * 20 + col
      local t = tiles[k]
      if t < TILE_COUNT then
        local sx, sy, ox, oy = 1, 1, 0, 0
        if h[k] then sx, ox = -1, 8 end
        if v[k] then sy, oy = -1, 8 end
        local x, y = col * 8 + ox, (row + 1) * 8 + oy
        love.graphics.draw(pic.im, pic.q[t], x, y, 0, sx, sy)
      end
    end
  end
  Draw.cursor(ctx, self.mach)
end

return M
