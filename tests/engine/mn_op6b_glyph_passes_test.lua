-- $6B ArmCopyGlyphFromScript (arm_copy_glyph_from_script.asm, copy_glyph.asm): each pass
-- of the .step handler plants CopyGlyph, which moves one 16-byte tile, and counts $FFA6
-- down; the pass that reaches zero returns to INITIAL_SCRIPT_HANDLER, so the next op runs
-- one pass after the last tile. A count of 0 wraps to 256 passes. With the LCD off (map
-- setup, runInit) the tiles are all copied before the screen shows.
-- Synthetic bytes only.
--   luajit tests/engine/mn_op6b_glyph_passes_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local function image(at)
  local t = {}
  for i = 1, 0x13 * 0x4000 do t[i] = 0 end
  for addr, bytes in pairs(at) do
    for i, v in ipairs(bytes) do t[0x12 * 0x4000 + addr - 0x4000 + i] = v end
  end
  local parts = {}
  for i = 1, #t, 4096 do parts[#parts + 1] = string.char(unpack(t, i, math.min(i + 4095, #t))) end
  local s = table.concat(parts)
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- 12:4000: $6B 3 tiles from 12:4800 to 1:8200, post C6F8 $09, park
-- 12:4100: $6B count 0 (256 tiles), post C6FA $0B, park
local rom = image({
  [0x4000] = { 0x6B, 0x03, 0x12, 0x00, 0x48, 0x00, 0x82, 0x01, 0x56, 0x09, 0x42 },
  [0x4100] = { 0x6B, 0x00, 0x12, 0x00, 0x48, 0x00, 0x80, 0x00, 0x57, 0x0B, 0x42 },
})
local calls, frame = {}, 0
local h = { glyphCopy = function(count, bank, src, dest, vb, more, total)
  calls[#calls + 1] = { f = frame, count = count, bank = bank, src = src, dest = dest, vb = vb, more = more, total = total }
end }

local vm = VM.new(rom, h)
vm:spawnThread(2, 0x12, 0x4000)
frame = 1; vm:tickThreads(false)
ok(#calls == 1 and calls[1].count == 1 and calls[1].src == 0x4800 and calls[1].dest == 0x8200, "pass 1 copies the first tile")
ok(calls[1].vb == 1 and calls[1].bank == 0x12 and not calls[1].more and calls[1].total == 3, "the first tile carries the bank, VRAM bank and total")
frame = 2; vm:tickThreads(false)
frame = 3; vm:tickThreads(false)
ok(#calls == 3 and calls[2].f == 2 and calls[3].f == 3, "one tile per pass")
ok(calls[3].src == 0x4820 and calls[3].dest == 0x8220 and calls[3].more, "the pointers advance 16 bytes a tile")
ok(vm:rd8(0xC6F8) == 0, "the pass that copies the last tile ends there")
frame = 4; vm:tickThreads(false)
ok(vm:rd8(0xC6F8) == 0x09 and #calls == 3, "the next op runs one pass after the last tile")

calls = {}
local v2 = VM.new(rom, h)
v2:spawnThread(3, 0x12, 0x4100)
for f = 1, 256 do frame = f; v2:tickThreads(false) end
ok(#calls == 256 and v2:rd8(0xC6FA) == 0, "a count of 0 runs 256 passes")
frame = 257; v2:tickThreads(false)
ok(v2:rd8(0xC6FA) == 0x0B, "then the next op")

calls = {}
local v3 = VM.new(rom, h)
v3:runInit(0x12, 0x4000)
ok(#calls == 1 and calls[1].count == 3 and calls[1].src == 0x4800, "LCD off: the three tiles go in one call")

print(("mn_op6b_glyph_passes: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
