-- StoreEThroughWordInWram3 (00:26CC), the tail of $A0-$A4: the byte goes into
-- the WRAM-3 metatile plane at the word. LCD off: the later full draw shows it.
-- LCD on: only the last A cell ($C99C row, $C99D column, its WRAM-3 byte at the
-- word $C99E) is redrawn; another stored cell shows its old tiles until a seam
-- draws it. Made-up map, no ROM bytes.
--   luajit tests/engine/mn_store_redraw_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Overworld = require("mn.Overworld")
local ROM = MnRom.new(string.rep("\0", 0x200000))

local W, H = 40, 30
local function world(init)
  local cells, block = {}, {}
  for i = 1, W * H do cells[i] = 0x10; block[i] = 0 end
  local s = setmetatable({ def = { w = W, h = H, cells = cells, block = block }, patches = {}, log = {},
    objects = {}, px = 5 * 16, py = 5 * 16 }, { __index = Overworld })
  local h = Overworld.host(s)
  s.vm = VM.new(ROM, h); s.vm.init = init
  return s, h
end
local function aCell(s, x, y)
  local w = 0xD000 + y * W + x
  s.vm:wr8(0xC99C, y); s.vm:wr8(0xC99D, x); s.vm:wr8(0xC99E, w % 256); s.vm:wr8(0xC99F, math.floor(w / 256))
end
local function addr(x, y) return 0xD000 + y * W + x end
local function last(s) return s.patches[#s.patches] end

do -- LCD on, the store hits the A cell: that cell is redrawn with the new byte
  local s, h = world(false)
  aCell(s, 6, 4)
  h.setMetatile(addr(6, 4), 0x2A)
  local p = last(s)
  ok(s.def.cells[4 * W + 6 + 1] == 0x2A, "WRAM-3 plane takes the byte")
  ok(#s.patches == 1 and p.x == 6 and p.y == 4 and p.mt == 0x2A, "the A cell is redrawn with the stored byte")
  ok(s.bgStale == nil or not s.bgStale[4 * W + 6], "the redrawn cell is not stale")
end

do -- LCD on, the store hits another cell: the A cell is redrawn from WRAM 3, unchanged
  local s, h = world(false)
  aCell(s, 6, 4)
  h.setMetatile(addr(8, 4), 0x33)
  local p = last(s)
  ok(#s.patches == 1 and p.x == 6 and p.y == 4 and p.mt == 0x10, "the A cell is redrawn, not the stored one")
  ok(s.def.cells[4 * W + 8 + 1] == 0x33, "the stored cell is in WRAM 3")
  s:flushStale()
  ok(#s.patches == 1, "an on-screen stored cell keeps its old tiles")
  s.px = 30 * 16 -- the camera moves on: the cell has left the view
  s:flushStale()
  p = last(s)
  ok(#s.patches == 2 and p.x == 8 and p.y == 4 and p.mt == 0x33, "off screen, the seam shows the WRAM-3 byte")
  ok(s.bgStale == nil, "nothing stale after the seam")
end

do -- LCD off (map setup): the stored cell shows in the full draw
  local s, h = world(true)
  aCell(s, 6, 4)
  h.setMetatile(addr(8, 4), 0x33)
  local p = last(s)
  ok(#s.patches == 1 and p.x == 8 and p.y == 4 and p.mt == 0x33, "LCD off: the stored cell itself is drawn")
end

do -- LCD on, the A cell is off screen: BuildMetatilePointers (07:4C53) writes ring
  -- slot (col & 15, row & 15), which shows on the on-screen cell sharing it
  local s, h = world(false)
  s.px, s.py = 25 * 16, 5 * 16 -- camera cols 20..29, rows 0..8
  aCell(s, 6, 4) -- slot (6, 4): on screen that is cell (22, 4)
  s.def.cells[4 * W + 6 + 1] = 0x44
  h.setMetatile(addr(8, 4), 0x33)
  local p = last(s)
  ok(p and p.x == 22 and p.y == 4 and p.mt == 0x44, "the A cell's byte shows on the aliased cell (22,4)")
  ok(s.bgStale and s.bgStale[4 * W + 22], "the aliased cell is stale")
  s.px = 5 * 16 -- back west: (22,4) leaves the view, the seam redraws it from WRAM 3
  s:flushStale()
  local q
  for _, pp in ipairs(s.patches) do if pp.x == 22 and pp.y == 4 then q = pp end end
  ok(q and q.mt == 0x10, "off screen, the aliased cell is redrawn from WRAM 3")
  ok(s:ringAlias(6, 12) == nil, "a ring slot with no on-screen cell is not shown")
  ok(select("#", s:ringAlias(38, 4)) == 2 and s:ringAlias(38, 4) == 6, "slot 38 & 15 = 6 is on screen at column 6")
end

do -- LCD on, no A cell yet: $C99C-$C99F are zero, so `ld c, [hl]` reads ROM
  -- bank 0 at $0000 and that byte is drawn at ring slot (0, 0). Made-up byte.
  local bytes = "\x5B" .. string.rep("\0", 0x200000 - 1)
  local s, h = world(false)
  s.vm.rom = MnRom.new(bytes)
  s.px, s.py = 21 * 16, 20 * 16 -- camera cols 16..25, rows 16..24
  h.setMetatile(addr(18, 18), 0x33)
  local p = last(s)
  ok(p and p.x == 16 and p.y == 16 and p.mt == 0x5B, "slot (0,0) shows the ROM byte at $0000 on cell (16,16)")
  ok(s.bgStale and s.bgStale[16 * W + 16] and s.bgStale[18 * W + 18], "the aliased and the stored cell are stale")
  ok(s.def.cells[18 * W + 18 + 1] == 0x33, "the store still lands in WRAM 3")
end

print(("mn_store_redraw: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
