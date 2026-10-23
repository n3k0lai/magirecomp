-- Window map for the bank-3 list screens.
-- PlaceWindowCopyMap ($76FA) copies an 18-by-20 tilemap into $9C00
-- (20 columns, then a pad to the 32-byte row). PaintMapAttrsSeedSlot
-- ($7463) flips the frame: column 0 of rows 0-16, the bottom row,
-- and the two arrow pairs.
-- RefreshFrameMarkPair ($7751) writes [$CCEB] at $9D89 (row 12, column 9).
-- RefreshFrameMarkWindowPair ($7777) writes it at $9C29 (row 1, column 9).
-- RefreshFrameBlankMarkPair ($779D) and RefreshFrameWindowPair ($77C2)
-- write the blank tile $80 on those same pairs.
-- Glyphs and the $80-$85 frame share Font's window.bin sheet.

local Importer = require("mn.MnImporter")
local MnRom = require("mn.MnRom")

local M = {}

local BLANK = 0x80
local TOP = 0x9C29
local BOT = 0x9D89
local MAP = { ["8c"] = 0x4CB3, ["8f"] = 0x4E1B, ["90"] = 0x4B4B }

local PAL = { [0] = { 1, 1, 1 }, { 0.75, 0.75, 0.75 }, { 0.4, 0.4, 0.4 }, { 0, 0, 0 } }
local sheetIm, sheetQ

local function sheet()
  if sheetIm then return true end
  if not love or not love.image or not love.graphics or not love.filesystem then return false end
  local raw = love.filesystem.read(Importer.CACHE .. "/window.bin")
  if not raw then return false end
  local img = love.image.newImageData(8 * 262, 8)
  for t = 0, 261 do
    for p = 0, 63 do
      local c = PAL[raw:byte(t * 64 + p + 1)] or PAL[0]
      img:setPixel(t * 8 + p % 8, math.floor(p / 8), c[1], c[2], c[3], 1)
    end
  end
  sheetIm = love.graphics.newImage(img)
  sheetIm:setFilter("nearest", "nearest")
  sheetQ = {}
  for t = 0, 261 do sheetQ[t] = love.graphics.newQuad(t * 8, 0, 8, 8, 8 * 262, 8) end
  return true
end

local function quadIndex(id, glyph)
  if glyph ~= nil then return glyph end
  if id >= 0x80 and id <= 0x85 then return 256 + (id - 0x80) end
  return id
end

local function blit(id, x, y, h, v, glyph)
  if not sheet() then return end
  local q = sheetQ[quadIndex(id, glyph)]
  if not q then return end
  local sx, sy, ox, oy = 1, 1, 0, 0
  if h then sx, ox = -1, 8 end
  if v then sy, oy = -1, 8 end
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(sheetIm, q, x + ox, y + oy, 0, sx, sy)
end

-- PaintMapAttrsSeedSlot flips. Row 17 is the bottom rule.
local function flips(row, col)
  local h = col == 0 and row <= 16
  local v = false
  if row == 17 and col == 0 then h, v = true, true
  elseif row == 17 then v = true end
  if row == 1 and col == 10 then h = true end
  if row == 12 and col == 9 then v = true end
  if row == 12 and col == 10 then h, v = true, true end
  return h, v
end

local function put(scr, addr, tile)
  scr.over[addr] = tile
end

function M.markPair(scr)
  local t = scr.vm:rd8(0xCCEB)
  put(scr, BOT, t)
  put(scr, BOT + 1, t)
end

function M.blankMark(scr)
  put(scr, BOT, BLANK)
  put(scr, BOT + 1, BLANK)
end

function M.markWindow(scr)
  local t = scr.vm:rd8(0xCCEB)
  put(scr, TOP, t)
  put(scr, TOP + 1, t)
end

function M.windowPair(scr)
  put(scr, TOP, BLANK)
  put(scr, TOP + 1, BLANK)
end

-- RefreshFrameBlankChoiceCells ($76B1): tile $80 at the three menu cells.
function M.blankChoice(scr)
  put(scr, 0x9E01, BLANK)
  put(scr, 0x9DC1, BLANK)
  put(scr, 0x9DE1, BLANK)
end

-- PaintCopiedBlockMapStrips ($5627). Rising ids on the bottom three rows.
local function strips(scr)
  local function run(addr, tile, n, step)
    for i = 0, n - 1 do put(scr, addr + i, (tile + i * step) % 256) end
  end
  run(0x9DC2, 0xEE, 0x0D, 1)
  run(0x9DE2, 0xFB, 0x09, 1)
  run(0x9E02, 0x04, 0x07, 1)
  run(0x9DEE, BLANK, 0x04, 0)
end

-- CopyRepeatedTileIndex ($772F) then the caller's index list. The repeated
-- run starts at tile $86. The caller's list continues after it.
local function replaced(scr)
  local r = {}
  local function span(tile, glyph, n, step)
    for i = 0, n - 1 do r[tile + i] = (glyph + i * step) % 256 end
  end
  if scr.mode == "90" or scr.mode == "8c" then span(0x86, 0x20, 0x68, 0) end
  if scr.mode == "90" then span(0xEE, 0x30, 0x0A, 1) end
  if not scr.rom then return r end
  local ptr = scr.mode == "8c" and 0x5302 or (scr.mode == "90" and 0x52E5 or nil)
  local n = scr.mode == "8c" and 0x1E or (scr.mode == "90" and 0x0D or 0)
  if not ptr then return r end
  -- CopyIndexedBlocks runs with bank 6 mapped, so the index list is there.
  local off = MnRom.off(ptr, 6)
  local base = scr.mode == "8c" and 0xEE or 0xF8
  for i = 0, n - 1 do r[base + i] = scr.rom:u8(off + i) end
  return r
end

function M.reset(scr)
  scr.over = {}
  if scr.mode == "8c" then strips(scr) end
  scr.replace = replaced(scr)
end

function M.tileAt(scr, row, col)
  local addr = 0x9C00 + row * 32 + col
  if scr.over and scr.over[addr] ~= nil then return scr.over[addr] end
  local base = MAP[scr.mode]
  if not scr.rom or not base then return nil end
  return scr.rom:u8(MnRom.off(base + row * 20 + col, 3))
end

function M.draw(scr)
  if not scr.rom or not sheet() then
    if sheet() and scr.over then
      for addr, tile in pairs(scr.over) do
        local off = addr - 0x9C00
        local row, col = math.floor(off / 32), off % 32
        if col < 20 and row < 18 then
          local h, v = flips(row, col)
          blit(tile, col * 8, row * 8, h, v)
        end
      end
    end
    return false
  end
  local base = MAP[scr.mode]
  local off = MnRom.off(base, 3)
  local rep = scr.replace or {}
  for row = 0, 17 do
    for col = 0, 19 do
      local addr = 0x9C00 + row * 32 + col
      local id = scr.over[addr]
      if id == nil then id = scr.rom:u8(off + row * 20 + col) end
      local h, v = flips(row, col)
      blit(id, col * 8, row * 8, h, v, rep[id])
    end
  end
  return true
end

return M
