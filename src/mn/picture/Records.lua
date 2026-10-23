-- CopyMapRecords ($2FC0) and CopyOneVRAMRecord ($2FE5).
--
-- The list is two counted runs of 7-byte records. The first count is how
-- many records to write while VRAM bank 0 is selected. The second count
-- is the bank 1 run. A zero count skips that bank.
--
--   dw destination   VRAM address. The next row starts $100 bytes later.
--   dw source        address in the record's ROM bank
--   db tiles         tiles in the row, 16 bytes each. Bit 4 set: the next
--                    source row is $100 bytes later. Bit 4 clear: the next
--                    source row is swap(tiles) bytes later.
--   db rows
--   db bank
--
-- A row is copied with inc c, so it stays inside one $100-byte page.
-- A count of zero in the tiles or rows byte wraps to 256 (dec / jr nz).
local bit = require("bit")
local band, rshift, lshift, bor = bit.band, bit.rshift, bit.lshift, bit.bor

local M = {}

-- Source distance from the start of one row to the next.
function M.stride(tiles)
  if band(tiles, 0x10) ~= 0 then return 0x100 end
  return bor(lshift(band(tiles, 0x0F), 4), rshift(tiles, 4))
end

local function incC(addr)
  return addr - (addr % 256) + ((addr + 1) % 256)
end

local function readBank(rom, bank, addr)
  if addr < 0x4000 or addr > 0x7FFF then return 0 end
  return rom:u8(bank * 0x4000 + addr - 0x4000) or 0
end

local function writeVram(mem, addr, v)
  if addr >= 0x8000 and addr < 0xA000 then mem[addr - 0x8000] = v end
end

-- Copy one record into mem (one VRAM bank, indexed by addr - $8000).
function M.copyOne(rom, mem, dest, src, tiles, rows, bank)
  local sp, dp = src % 0x10000, dest % 0x10000
  local row = rows % 256
  local step = M.stride(tiles)
  repeat
    local s, d = sp, dp
    local e = tiles % 256
    repeat
      for _ = 1, 16 do
        writeVram(mem, d, readBank(rom, bank, s))
        s = (s + 1) % 0x10000
        d = incC(d)
      end
      e = (e - 1) % 256
    until e == 0
    sp = (sp + step) % 0x10000
    dp = (dp + 0x100) % 0x10000
    row = (row - 1) % 256
  until row == 0
end

-- o is the file offset of the two counted lists. vram[0] and vram[1] are
-- the banks. Returns the offset just past the lists.
function M.copyLists(rom, vram, o)
  local function u8()
    local v = rom:u8(o) or 0
    o = o + 1
    return v
  end
  local function u16()
    local lo = u8()
    return lo + u8() * 256
  end
  for vb = 0, 1 do
    local n = u8()
    for _ = 1, n do
      local dest, src, tiles, rows, bank = u16(), u16(), u8(), u8(), u8()
      M.copyOne(rom, vram[vb], dest, src, tiles, rows, bank)
    end
  end
  return o
end

return M
