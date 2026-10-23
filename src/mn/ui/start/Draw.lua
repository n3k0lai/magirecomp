-- Start-menu pixels. Glyphs are bank 6 indexes drawn by mn.Font (the same
-- $4000 tile set). Frame tiles $80-$85 are the window frame in that cache
-- (draw_start_screen_map.asm). Label runs are the lists at $525A-$528B.
local Font = require("mn.Font")
local Importer = require("mn.MnImporter")
local MnRom = require("mn.MnRom")
local Digits = require("mn.ui.start.Digits")

local M = {}
local DEFAULT = { [0] = { 1, 1, 1 }, { 0.75, 0.75, 0.75 }, { 0.4, 0.4, 0.4 }, { 0, 0, 0 } }
local frameCache = {}

local function palOf(ctx)
  local ow = ctx.ow
  if ow and ow.def and ow.def.pal7 then return ow.def.pal7 end
  return DEFAULT
end

local function sheet(pal)
  local key = pal[0][1] .. "," .. pal[3][1] .. "," .. pal[3][3]
  if frameCache[key] then return frameCache[key] end
  local raw = love.filesystem.read(Importer.CACHE .. "/window.bin")
  local img = love.image.newImageData(8 * 6, 8)
  for t = 0, 5 do
    for p = 0, 63 do
      local c = pal[raw:byte((256 + t) * 64 + p + 1)]
      img:setPixel(t * 8 + p % 8, math.floor(p / 8), c[1], c[2], c[3], 1)
    end
  end
  local im = love.graphics.newImage(img)
  im:setFilter("nearest", "nearest")
  local q = {}
  for t = 0, 5 do q[t] = love.graphics.newQuad(t * 8, 0, 8, 8, 8 * 6, 8) end
  frameCache[key] = { im = im, q = q }
  return frameCache[key]
end

local function frameTile(id, x, y, pal)
  local s = sheet(pal)
  love.graphics.draw(s.im, s.q[id - 0x80], x, y)
end

local function glyphs(rom, addr, n)
  local t = {}
  for i = 0, n - 1 do
    t[i + 1] = string.char(rom:u8(MnRom.off(addr + i, 6)) or 0)
  end
  return table.concat(t)
end

local function sramAt(vm, delta, addr)
  if delta == 0 then return vm:rd8(addr) end
  local banks = vm.sramBanks
  local b = (vm.sramBank or 0) + delta
  if not banks or not banks[b] then return 0 end
  return banks[b]:byte(addr - 0xA000 + 1) or 0
end

local function digitStr(rom, h, tens, ones, skipHigh)
  local function one(n)
    return string.char(rom:u8(MnRom.off(0x5275 + n, 6)) or 0)
  end
  if skipHigh then return one(tens) .. one(ones) end
  return one(h) .. one(tens) .. one(ones)
end

-- Full-screen window: corners $85, bars $83/$84, fill $80. DrawStartScreenMap.
function M.chrome(ctx)
  local pal = palOf(ctx)
  love.graphics.setColor(1, 1, 1)
  for y = 0, 17 do
    for x = 0, 19 do frameTile(0x80, x * 8, y * 8, pal) end
  end
  for x = 1, 18 do
    frameTile(0x83, x * 8, 0, pal)
    frameTile(0x83, x * 8, 11 * 8, pal)
    frameTile(0x83, x * 8, 17 * 8, pal)
  end
  for y = 1, 10 do
    frameTile(0x84, 0, y * 8, pal)
    frameTile(0x84, 19 * 8, y * 8, pal)
  end
  for y = 12, 16 do
    frameTile(0x84, 0, y * 8, pal)
    frameTile(0x84, 19 * 8, y * 8, pal)
  end
  local corners = { { 0, 0 }, { 19, 0 }, { 0, 11 }, { 19, 11 }, { 0, 17 }, { 19, 17 } }
  for i = 1, #corners do frameTile(0x85, corners[i][1] * 8, corners[i][2] * 8, pal) end
  M.labels(ctx, pal)
  M.values(ctx, pal)
end

-- menu_tile_labels_524e.asm. Glyph row is blank when $A3A4 is zero.
-- Save is the four indexes at $5284 when $CCA5 is nonzero, else four spaces.
function M.labels(ctx, pal)
  local rom, vm = ctx.rom, ctx.vm
  local rows = {
    { 2, 12, 0x525A, 5 },
    { 2, 13, 0x525F, 5 },
    { 2, 14, 0x5264, 5 },
    { 2, 15, 0x5269, 5 },
  }
  if vm:rd8(0xA3A4) ~= 0 then rows[#rows + 1] = { 2, 16, 0x526E, 5 } end
  rows[#rows + 1] = { 14, 16, 0x527F, 5 }
  local saveAt = vm:rd8(0xCCA5) ~= 0 and 0x5284 or 0x5288
  rows[#rows + 1] = { 14, 15, saveAt, 4 }
  rows[#rows + 1] = { 13, 12, 0x5274, 1 }
  rows[#rows + 1] = { 11, 13, 0x5273, 1 }
  -- TODO(DrawStartScreenMap): the tile at row 13 col 15 is not drawn.
  for i = 1, #rows do
    local r = rows[i]
    Font.drawText(glyphs(rom, r[3], r[4]), r[1] * 8, r[2] * 8, pal)
  end
end

-- The three words DrawStartScreenMap prints, plus the two Index-5 numbers.
function M.values(ctx, pal)
  local rom, vm = ctx.rom, ctx.vm
  local function put(col, row, d, e, skipHigh)
    local h, tens, ones = Digits.format(d, e)
    Font.drawText(digitStr(rom, h, tens, ones, skipHigh), col * 8, row * 8, pal)
  end
  local lo, hi = vm:rd8(0xA3A5), vm:rd8(0xA3A6)
  put(14, 12, hi, lo, false)
  put(12, 13, sramAt(vm, 1, 0xA005), sramAt(vm, 1, 0xA006), false)
  put(16, 13, sramAt(vm, 1, 0xA007), sramAt(vm, 1, 0xA008), false)
  put(11, 2, 0, sramAt(vm, 1, 0xA002), true)
  put(11, 3, sramAt(vm, 1, 0xA003), sramAt(vm, 1, 0xA004), false)
end

-- TODO(CopyIndex5VRAMTiles): the four 3x3 party pictures at $9CE1 and the
-- bank-8 strip at $7070 are not drawn. A zero count in $A3A3 stamps them blank.

-- CopyIndexedMap's 20x10 map for this mode (table at 06:51C1), on window
-- rows 1-10. Name cells are the $AB-$EB picture strips; the 13 glyphs for
-- that row replace them. A missed scan blanks the $7F pair on that end.
local function cell(pal, t, x, y, mach)
  if t >= 0xAB and t <= 0xEB then
    local n = t - 0xAB
    local row = mach.rows[math.floor(n / 13) + 1]
    local b = 0x20
    if row and row.glyphs ~= "" then b = row.glyphs:byte((n % 13) + 1) or 0x20 end
    t = b
  end
  if t >= 0x80 and t <= 0x85 then frameTile(t, x, y, pal)
  else Font.drawText(string.char(t), x, y, pal) end
end

function M.group(ctx, mach)
  local pal = palOf(ctx)
  local rom = ctx.rom
  local src = rom:u16(MnRom.off(0x51C1 + mach.cc47 * 2, 6))
  if src ~= 0 then
    local n = 0
    for row = 0, 9 do
      for col = 0, 19 do
        local t = rom:u8(MnRom.off(src + n, 6)) or 0
        n = n + 1
        local top = row == 0 and (col == 9 or col == 10)
        local bot = row == 8 and (col == 9 or col == 10)
        if (top and not mach.showAbove) or (bot and not mach.showBelow) then t = 0x80 end
        cell(pal, t, col * 8, (row + 1) * 8, mach)
      end
    end
  end
  for i = 1, 5 do
    local row = mach.rows[i]
    if row and row.ptr and row.count ~= 0 then
      local h, tens, ones = Digits.format(0, row.count)
      Font.drawText(digitStr(rom, h, tens, ones, false), 8, (2 + i) * 8, pal)
    end
  end
end

function M.cursor(ctx, mach)
  if not mach:cursorOn() then return end
  local pal = palOf(ctx)
  local tile = (mach.cd80 == 1 or mach.ccb9 == 0) and 0x82 or 0x81
  frameTile(tile, mach.col * 8, mach.row * 8, pal)
end

return M
