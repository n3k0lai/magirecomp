-- Picture layer for opcodes $63 and $6A (src/mn/Picture.lua).
-- Synthetic streams and tile lists only, plus a ROM-gated count of the
-- title script's first two cards (2A:7248). Nothing from the ROM is printed
-- except those counts.
--   luajit tests/engine/mn_picture_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local function near(a, b) return math.abs(a - b) < 1e-6 end

local Unpack = require("mn.picture.Unpack")
local Records = require("mn.picture.Records")
local Picture = require("mn.Picture")
local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Travel = require("mn.ops.Travel")

local function reader(bytes)
  return function(o) return bytes[o] end
end

-- UnpackBytes: short copy, short repeat, both terminators, long copy, long repeat
do
  local bytes = {
    [0] = 0x03, 0x11, 0x22, 0x33, -- short copy 3
    0x82, 0xAB,                   -- short repeat 2
    0x40, 0x02, 0x7E, 0x7F,       -- long copy 2
    0xC0, 0x03, 0x55,             -- long repeat 3
    0x80,                         -- short repeat of length 0 ends the stream
    0x99,
  }
  local out = {}
  local nxt = Unpack.unpack(reader(bytes), 0, function(v) out[#out + 1] = v end)
  local want = { 0x11, 0x22, 0x33, 0xAB, 0xAB, 0x7E, 0x7F, 0x55, 0x55, 0x55 }
  local same = #out == #want
  for i = 1, #want do if out[i] ~= want[i] then same = false end end
  ok(same, "packed stream decodes to the four command shapes")
  ok(nxt == 14 and bytes[nxt] == 0x99, "terminator $80 leaves the next byte unread")
  out = {}
  nxt = Unpack.unpack(reader({ [0] = 0x01, 0x42, 0x00, 0x77 }), 0, function(v) out[#out + 1] = v end)
  ok(#out == 1 and out[1] == 0x42 and nxt == 3, "terminator $00 ends a short copy")
end

-- stride: bit 4 selects $100, otherwise swap(tiles)
do
  ok(Records.stride(0x10) == 0x100, "16 tiles (bit 4) steps the source by $100")
  ok(Records.stride(0x0A) == 0xA0, "10 tiles step the source by swap($0A)")
  ok(Records.stride(0x02) == 0x20, "2 tiles step the source by $20")
end

local function romFrom(bytes)
  return {
    u8 = function(_, o) return bytes[o] or 0 end,
    u16 = function(_, o) return (bytes[o] or 0) + (bytes[o + 1] or 0) * 256 end,
  }
end

-- CopyOneVRAMRecord: two rows, bit 4 clear, dest page step $100, inc c
do
  local base = MnRom.off(0x4200, 0x12)
  local bytes = {}
  bytes[base] = 0xA1
  bytes[base + 1] = 0xA2
  bytes[base + 0x20] = 0xB1
  bytes[base + 0x21] = 0xB2
  local mem = {}
  for i = 0, 0x1FFF do mem[i] = 0 end
  Records.copyOne(romFrom(bytes), mem, 0x9000, 0x4200, 0x02, 0x02, 0x12)
  ok(mem[0x1000] == 0xA1 and mem[0x1001] == 0xA2, "row 0 lands at $9000")
  ok(mem[0x1100] == 0xB1 and mem[0x1101] == 0xB2, "next row starts $100 later, source advanced by the stride")
  ok(mem[0x1002] == 0 and mem[0x1020] == 0, "bytes past the two tiles stay clear")
end

-- a destination that does not start on a page: 2 tiles at $8EE0 fill $E0-$FF
-- and do not wrap (inc c only wraps on the 256th byte)
do
  local base = MnRom.off(0x4400, 0x03)
  local bytes = {}
  bytes[base] = 0xC3
  bytes[base + 31] = 0xC5
  local mem = {}
  for i = 0, 0x1FFF do mem[i] = 0 end
  Records.copyOne(romFrom(bytes), mem, 0x8EE0, 0x4400, 0x02, 0x01, 0x03)
  ok(mem[0x0EE0] == 0xC3 and mem[0x0EFF] == 0xC5, "a row at $8EE0 stays in that page")
  ok(mem[0x0E00] == 0, "inc c does not wrap a short row back to the page start")
end

-- 16 tiles exactly fill one page; the next row is +$100 in both planes
do
  local b0 = MnRom.off(0x5000, 0x04)
  local bytes = {}
  bytes[b0] = 0x11
  bytes[b0 + 0x100] = 0x22
  bytes[b0 + 255] = 0x33
  local mem = {}
  for i = 0, 0x1FFF do mem[i] = 0 end
  Records.copyOne(romFrom(bytes), mem, 0x9000, 0x5000, 0x10, 0x02, 0x04)
  ok(mem[0x1000] == 0x11 and mem[0x10FF] == 0x33, "16 tiles fill the destination page")
  ok(mem[0x1100] == 0x22, "bit 4 row 1 reads $100 later and writes $100 later")
  ok(mem[0x1000] ~= 0x22, "the page wrap of the last inc c does not eat the first byte")
end

-- CopyMapRecords: bank 0 count, then bank 1 count, each a 7-byte record
do
  local list = MnRom.off(0x4000, 0x12)
  local s0 = MnRom.off(0x4100, 0x12)
  local s1 = MnRom.off(0x4300, 0x07)
  local bytes = {}
  -- count 1, dest $9000, src $4100, 1 tile, 1 row, bank $12
  bytes[list] = 1
  bytes[list + 1], bytes[list + 2] = 0x00, 0x90
  bytes[list + 3], bytes[list + 4] = 0x00, 0x41
  bytes[list + 5], bytes[list + 6], bytes[list + 7] = 0x01, 0x01, 0x12
  -- count 1, dest $8800, src $4300, 1 tile, 1 row, bank $07
  bytes[list + 8] = 1
  bytes[list + 9], bytes[list + 10] = 0x00, 0x88
  bytes[list + 11], bytes[list + 12] = 0x00, 0x43
  bytes[list + 13], bytes[list + 14], bytes[list + 15] = 0x01, 0x01, 0x07
  bytes[s0] = 0x44
  bytes[s1] = 0x55
  local vram = { [0] = {}, [1] = {} }
  for b = 0, 1 do for i = 0, 0x1FFF do vram[b][i] = 0 end end
  Records.copyLists(romFrom(bytes), vram, list)
  ok(vram[0][0x1000] == 0x44 and vram[0][0x0800] == 0, "bank 0 record stays out of bank 1's address")
  ok(vram[1][0x0800] == 0x55 and vram[1][0x1000] == 0, "bank 1 record uses the second count")
end

-- zero count skips a bank and still consumes the count byte
do
  local bytes = { [0] = 0, 1, 0x00, 0x90, 0x00, 0x40, 0x01, 0x01, 0x01 }
  bytes[MnRom.off(0x4000, 1)] = 0x66
  local vram = { [0] = {}, [1] = {} }
  for b = 0, 1 do for i = 0, 0x1FFF do vram[b][i] = 0 end end
  Records.copyLists(romFrom(bytes), vram, 0)
  ok(vram[0][0x1000] == 0 and vram[1][0x1000] == 0x66, "a zero bank-0 count skips to bank 1")
end

-- Two streams onto $9800: attributes first (bank 1), then tile ids (bank 0)
do
  local off = MnRom.off(0x6F2D, 0x27)
  local bytes = {}
  bytes[off] = 0x02
  bytes[off + 1], bytes[off + 2] = 0x07, 0x28 -- two attribute bytes
  bytes[off + 3] = 0x80                       -- end
  bytes[off + 4] = 0x02
  bytes[off + 5], bytes[off + 6] = 0x01, 0x80 -- tile ids
  bytes[off + 7] = 0x00
  local pic = Picture.new()
  pic:unpackMaps(romFrom(bytes), 0x27, 0x6F2D)
  ok(pic.vram[1][0x1800] == 0x07 and pic.vram[1][0x1801] == 0x28, "first stream is the attribute plane")
  ok(pic.vram[0][0x1800] == 0x01 and pic.vram[0][0x1801] == 0x80, "second stream is the tile-id plane")
  ok(pic.vram[0][0x1802] == 0 and pic.vram[1][0x1802] == 0, "the streams stop at their terminators")
end

-- Palettes are eight RGB555 quads. Scroll shifts the BG. Flips and the
-- tile bank come from the attribute byte. The window stays off at WY $90.
do
  local pal = MnRom.off(0x6E65, 0x27)
  local bytes = {}
  bytes[pal] = 0x1F -- colour 0 = red
  bytes[pal + 1] = 0x00
  bytes[pal + 2] = 0xE0 -- colour 1 = green (31 << 5)
  bytes[pal + 3] = 0x03
  bytes[pal + 8] = 0x00 -- palette 1 colour 0 = blue (31 << 10) at byte offset 8
  bytes[pal + 9] = 0x7C
  local pic = Picture.new()
  pic:loadPalettes(romFrom(bytes), 0x27, 0x6E65)
  ok(near(pic.pal[0][0][1], 1) and near(pic.pal[0][0][2], 0) and near(pic.pal[0][0][3], 0), "palette 0 colour 0 is red")
  ok(near(pic.pal[0][1][2], 1) and near(pic.pal[0][1][1], 0), "palette 0 colour 1 is green")
  ok(near(pic.pal[1][0][3], 1), "palette 1 colour 0 is blue")

  -- tile 0 at $9000: leftmost pixel is colour 1 (bit 7 of the low plane)
  pic.vram[0][0x1000] = 0x80
  pic.vram[0][0x1800] = 0x00 -- map tile 0
  pic.vram[1][0x1800] = 0x00
  local function rgb(x, y)
    local r, g, b = pic:sample(x, y)
    return r, g, b
  end
  local r, g, b = rgb(0, 0)
  ok(near(r, 0) and near(g, 1) and near(b, 0), "screen origin uses palette colour 1")
  r, g = rgb(1, 0)
  ok(near(r, 1) and near(g, 0), "the next pixel is colour 0")

  pic.scx = 1
  r = rgb(0, 0)
  ok(near(r, 1), "SCX 1 shifts the background left by one pixel")
  pic.scx = 0

  pic.vram[1][0x1800] = 0x20 -- horizontal flip
  g = select(2, rgb(7, 0))
  ok(near(g, 1), "attribute bit 5 flips the tile horizontally")
  pic.vram[1][0x1800] = 0x40 -- vertical flip
  pic.vram[0][0x1000] = 0x00
  pic.vram[0][0x100E] = 0x80 -- bottom row, leftmost pixel, colour 1
  g = select(2, rgb(0, 0))
  ok(near(g, 1), "attribute bit 6 flips the tile vertically")

  pic.vram[1][0x1800] = 0x08 -- VRAM bank 1, palette 0
  pic.vram[1][0x1000] = 0x80
  pic.vram[0][0x100E] = 0x00
  g = select(2, rgb(0, 0))
  ok(near(g, 1), "attribute bit 3 reads the tile from VRAM bank 1")

  pic.vram[1][0x1800] = 0x01 -- palette 1, no flip, bank 0
  pic.vram[0][0x1000] = 0x00 -- colour 0
  g, b = select(2, rgb(0, 0))
  ok(near(b, 1) and near(g, 0), "attribute bits 0-2 select the BG palette")

  -- window map would cover the screen if WY were 0; the default keeps it off.
  -- Window tile 1 is colour 0 (palette 1 blue). BG tile 0 stays colour 1 green.
  pic.vram[0][0x1C00] = 0x01
  pic.vram[1][0x1C00] = 0x01
  pic.vram[0][0x1010] = 0x00
  pic.vram[0][0x1000] = 0x80
  pic.vram[1][0x1800] = 0x00
  g = select(2, rgb(0, 0))
  ok(near(g, 1) and pic.wy == 0x90, "WY $90 leaves the $9C00 window off the picture")
  pic.wy = 0
  b = select(3, rgb(0, 0))
  ok(near(b, 1), "WY 0 shows the window map instead of the BG")
end

-- $8000 tile method (LCDC bit 4) reads tile 0 from $8000, not $9000
do
  local pic = Picture.new()
  pic.lcdc = 0xF3 -- $E3 with bit 4 set
  pic.pal[0][1] = { 0, 0, 1 }
  pic.vram[0][0] = 0x80 -- $8000
  pic.vram[0][0x1000] = 0x00
  pic.vram[0][0x1800] = 0
  local _, _, b = pic:sample(0, 0)
  ok(near(b, 1), "LCDC bit 4 takes tile 0 from $8000")
end

-- $63 and $6A publish one picture and leave the state bytes alone
do
  local bytes = {}
  local function put(o, ...)
    local n = 0
    for _, v in ipairs({ ... }) do bytes[o + n] = v; n = n + 1 end
  end
  -- script at file 0: $6A list $4100 bank 3, palettes $4280 bank 3, then $63 map $4300 bank 3
  put(0, 0x6A, 0x00, 0x41, 0x03, 0x80, 0x42, 0x03, 0x63, 0x00, 0x43, 0x03)
  local list = MnRom.off(0x4100, 3)
  put(list, 1, 0x00, 0x90, 0x00, 0x44, 0x01, 0x01, 0x03, 0)
  local src = MnRom.off(0x4400, 3)
  bytes[src] = 0x5A
  local pal = MnRom.off(0x4280, 3)
  for i = 0, 63 do bytes[pal + i] = (i * 3 + 1) % 256 end
  local map = MnRom.off(0x4300, 3)
  put(map, 0x01, 0x3C, 0x00) -- one tile id, then end; attributes are an immediate end
  -- fix: first stream is attributes. Make attributes a one-byte stream too.
  put(map, 0x01, 0x04, 0x00, 0x01, 0x3C, 0x00)

  local got
  local vm = VM.new(romFrom(bytes), {
    picture = function(pic) got = pic end,
    travelTiles = function() end,
    travelBg = function() end,
  })
  vm:wr8(0xFF43, 4)
  vm:wr8(0xFF42, 6)
  Travel.handlers[0x6A](vm, 0, 7)
  ok(got ~= nil and got.vram[0][0x1000] == 0x5A, "$6A fills the picture tile")
  ok(got.scx == 4 and got.scy == 6, "$6A snapshots SCX/SCY")
  local palOk = true
  for i = 0, 63 do
    local v = (i * 3 + 1) % 256
    if vm:rd8(0xC72B + i) ~= v or vm:rd8(0xC7AB + i) ~= v then palOk = false end
  end
  ok(palOk, "$6A still copies the 32 words to C72B and C7AB")
  ok(vm:rd8(0xC9D8) == 7 and vm:rd8(0xC831) == 1, "$6A panel index is unchanged")
  local same = got
  Travel.handlers[0x63](vm, 7, 4)
  ok(got == same, "$63 updates the same picture")
  ok(got.vram[0][0x1800] == 0x3C and got.vram[1][0x1800] == 0x04, "$63 writes both map planes")
  ok(vm:rd8(0xC72B) == (0 * 3 + 1) % 256, "$63 does not touch the palette block")
  vm:wr8(0xFF43, 9)
  ok(got:scroll() == 9, "draw reads the live SCX after the picture is published")
end

-- a host with no picture callback still decodes, and does not require one
do
  local bytes = { [0] = 0x63, 0x00, 0x40, 0x02 }
  local vm = VM.new(romFrom(bytes), {})
  local nx = Travel.handlers[0x63](vm, 0, 4)
  ok(nx == 4 and vm.travelPicture ~= nil, "$63 with no host callback still builds a picture")
  ok(vm.travelPicture.vram[0][0x1800] == 0, "a zero control byte leaves the map clear")
end

local romPath = os.getenv("MN_ROM")
if romPath then
  local rom = MnRom.fromFile(romPath)
  local Op = require("mn.Opcodes")
  local function cardAt(o)
    local pic = Picture.new()
    if rom:u8(o) ~= 0x6A then return nil end
    pic:copyRecords(rom, rom:u8(o + 3), rom:u16(o + 1))
    pic:loadPalettes(rom, rom:u8(o + 6), rom:u16(o + 4))
    local m = o + 1 + (Op.LEN[0x6A] or 6)
    if rom:u8(m) ~= 0x63 then return pic, 0, 0 end
    pic:unpackMaps(rom, rom:u8(m + 3), rom:u16(m + 1))
    return pic
  end
  local o = MnRom.off(0x7248, 0x2A)
  local pic = cardAt(o)
  local map, tiles = pic:counts()
  local pixels = 0
  pic:render(function(_, _, r, g, b) if r + g + b > 0 then pixels = pixels + 1 end end)
  print(("mn_picture: title card 1 map %d tiles %d pixels %d"):format(map, tiles, pixels))
  ok(map > 0 and tiles > 0 and pixels > 0, "title first card (2A:7248) decodes a nonempty picture")

  local second
  local guard = 0
  o = o + rom:insn(o)
  while guard < 40 do
    guard = guard + 1
    if rom:u8(o) == 0x6A and o ~= MnRom.off(0x7248, 0x2A) then second = o; break end
    local n = rom:insn(o)
    if not n or n < 1 then break end
    o = o + n
  end
  ok(second ~= nil, "title script has a second card")
  if second then
    pic = cardAt(second)
    map, tiles = pic:counts()
    pixels = 0
    pic:render(function(_, _, r, g, b) if r + g + b > 0 then pixels = pixels + 1 end end)
    print(("mn_picture: title card 2 map %d tiles %d pixels %d"):format(map, tiles, pixels))
    ok(map > 0 and tiles > 0 and pixels > 0, "title second card decodes a nonempty picture")
  end
else
  print("mn_picture: MN_ROM not set, title cards skipped")
end

print(("mn_picture: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
