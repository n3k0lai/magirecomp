-- $76/$77/$7A SetCCA6Countdown tails (src/mn/ops/Panels.lua). Synthetic bytes only.
--   luajit tests/engine/mn_panel_tails_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Op = require("mn.Opcodes")
local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local function flat(bank, ptr) return bank * 0x4000 + ptr - 0x4000 end

-- patches: { fileOffset, byte-list }
local function image(patches)
  table.sort(patches, function(a, b) return a[1] < b[1] end)
  local chunks, pos = {}, 0
  for _, p in ipairs(patches) do
    if p[1] < pos then error("overlapping patch") end
    if p[1] > pos then chunks[#chunks + 1] = string.rep("\0", p[1] - pos) end
    chunks[#chunks + 1] = string.char(unpack(p[2]))
    pos = p[1] + #p[2]
  end
  if pos < 0x200000 then chunks[#chunks + 1] = string.rep("\0", 0x200000 - pos) end
  return MnRom.new(table.concat(chunks))
end

-- runs the record, returns the frames it waited (sum of "wait" yields)
local function run(s, bank, ptr)
  s.wait = nil
  s:start(bank, ptr)
  local g, waited = 0, (s.co and s.wait) or 0
  while s.co and g < 4000 do
    s.wait = nil
    s:resume(); g = g + 1
    if s.co and s.wait then waited = waited + s.wait end
  end
  ok(s.co == nil, ("script %02X:%04X finished"):format(bank, ptr))
  return waited
end

local function wr16(s, a, v) s:wr8(a, v % 256); s:wr8(a + 1, math.floor(v / 256)) end
local function rd16(s, a) return s:rd8(a) + 256 * s:rd8(a + 1) end
local function rgb(r, g, b) return r + 32 * g + 1024 * b end

local B = 0x12
local function at(ptr, ...) return { flat(B, ptr), { ... } } end

local rom = image({
  -- $76: split $43 = inner 2 frames (high bits 01 + 1), outer 3; row byte $10 = row 1, 4 words
  at(0x4000, 0x76, 0x43, 0x10, 0x12),
  -- $76: split $02 = inner 1, outer 2; row byte $00
  at(0x4010, 0x76, 0x02, 0x00, 0x12),
  -- $77: inner 1, outer 1; row $00; word $7FFF (white)
  at(0x4020, 0x77, 0x01, 0x00, 0xFF, 0x7F, 0x12),
  -- $77: bit 7 of the high byte takes the $C9E5 word
  at(0x4030, 0x77, 0x01, 0x00, 0x34, 0x80, 0x12),
  -- $7A: one pass, row $01 (two palettes), modes 3 / 4 / 0
  at(0x4040, 0x7A, 0x01, 0x01, 0x03, 0x12),
  at(0x4050, 0x7A, 0x01, 0x01, 0x04, 0x12),
  at(0x4060, 0x7A, 0x01, 0x00, 0x00, 0x12),
  -- $7A: two passes, mode 3, one palette: three rotations bring it back after 3 passes
  at(0x4070, 0x7A, 0x03, 0x00, 0x03, 0x12),
})

local function vm() return VM.new(rom, {}) end

-- $76: displayed words ($C7AB + row) step one unit per pass toward $C72B + row.
do
  local s = vm()
  wr16(s, 0xC72B + 8, rgb(10, 0, 31))
  wr16(s, 0xC7AB + 8, rgb(31, 31, 31))
  wr16(s, 0xC7AB + 16, rgb(31, 31, 31)) -- word 4 of row 1 is outside the 4-word block
  local w = run(s, B, 0x4000)
  ok(rd16(s, 0xC7AB + 8) == rgb(28, 28, 31), "$76 three passes step each channel three units toward the row")
  ok(rd16(s, 0xC7AB + 16) == rgb(31, 31, 31), "$76 touches only 4 * (low nibble + 1) words")
  ok(w == 6, "$76 inner 2 x outer 3 waits six frames, got " .. w)
  ok(s:rd8(0xCCA6) == 0 and rd16(s, 0xFFA4) == 0x0A66, "$76 clears $CCA6 and plants the dispatcher at expiry")
  ok(s:rd8(0xC9D8) == 0x10 and s:rd8(0xC9DC) == 1 and s:rd8(0xC831) == 1, "$76 stores $C9D8, $C9DC and $C831")
  ok(s:rd8(0xC6E6) == 7 and rd16(s, 0xC6E4) == 0x4575, "$76 plants the bank-7 $4575 callback")
end

do
  local s = vm()
  wr16(s, 0xC72B, rgb(0, 5, 0))
  wr16(s, 0xC7AB, rgb(3, 3, 3))
  local w = run(s, B, 0x4010)
  ok(rd16(s, 0xC7AB) == rgb(1, 5, 1), "$76 walks up and down per channel and stops at the target")
  ok(w == 2, "$76 inner 1 x outer 2 waits two frames, got " .. w)
end

-- $77: the block steps toward the script word; $C9D8 is not rewritten to $61.
-- $77 does not seed $C830 (only ApplyPanelRowWords and BlendLowSlotPalettes do); the
-- steppers refill it from $C9DC, so after any earlier stepper it is 1.
do
  local s = vm()
  s:wr8(0xC830, 1)
  wr16(s, 0xC7AB, rgb(0, 10, 30))
  wr16(s, 0xC72B, rgb(1, 2, 3))
  run(s, B, 0x4020)
  ok(rd16(s, 0xC7AB) == rgb(1, 11, 31), "$77 steps the $80-past row toward white")
  ok(rd16(s, 0xC72B) == rgb(1, 2, 3), "$77 leaves the row itself alone")
  ok(rd16(s, 0xC9DA) == 0x7FFF and s:rd8(0xC9D8) == 0x00, "$77 stores the word and keeps $C9D8")
end

do
  local s = vm()
  s:wr8(0xC830, 1)
  wr16(s, 0xC9E5, rgb(0, 0, 0))
  wr16(s, 0xC7AB, rgb(4, 4, 4))
  run(s, B, 0x4030)
  ok(rd16(s, 0xC9DA) == 0 and rd16(s, 0xC7AB) == rgb(3, 3, 3), "$77 bit 7 takes the $C9E5 word (black)")
end

-- $7A: RotatePaletteColors on palettes 1 and 0 of the $80-past row.
local function pal(s, base, p, a, b, c, d)
  wr16(s, base + 8 * p, a); wr16(s, base + 8 * p + 2, b); wr16(s, base + 8 * p + 4, c); wr16(s, base + 8 * p + 6, d)
end
local function getpal(s, base, p)
  return rd16(s, base + 8 * p), rd16(s, base + 8 * p + 2), rd16(s, base + 8 * p + 4), rd16(s, base + 8 * p + 6)
end
do
  local s = vm()
  pal(s, 0xC7AB, 0, 0x100, 0x101, 0x102, 0x103)
  pal(s, 0xC7AB, 1, 0x200, 0x201, 0x202, 0x203)
  pal(s, 0xC7AB, 2, 0x300, 0x301, 0x302, 0x303)
  run(s, B, 0x4040)
  local a, b, c, d = getpal(s, 0xC7AB, 0)
  ok(a == 0x100 and b == 0x103 and c == 0x101 and d == 0x102, "$7A mode 3 rotates colors 1-3 of palette 0")
  a, b, c, d = getpal(s, 0xC7AB, 1)
  ok(a == 0x200 and b == 0x203 and c == 0x201 and d == 0x202, "$7A mode 3 rotates palette 1")
  a = getpal(s, 0xC7AB, 2)
  ok(a == 0x300 and select(2, getpal(s, 0xC7AB, 2)) == 0x301, "$7A leaves palettes past the count")
  ok(s:rd8(0xC9D9) == 3 and s:rd8(0xC9DA) == 0 and s:rd8(0xC831) == 1, "$7A stores the mode in wPanelSlot and counts $C9DA down")
end

do
  local s = vm()
  pal(s, 0xC7AB, 0, 0x100, 0x101, 0x102, 0x103)
  run(s, B, 0x4050)
  local a, b, c, d = getpal(s, 0xC7AB, 0)
  ok(a == 0x103 and b == 0x100 and c == 0x101 and d == 0x102, "$7A mode 4 rotates all four colors")
  local s2 = vm()
  pal(s2, 0xC7AB, 0, 0x100, 0x101, 0x102, 0x103)
  run(s2, B, 0x4060)
  a, b, c, d = getpal(s2, 0xC7AB, 0)
  ok(a == 0x100 and b == 0x101 and c == 0x103 and d == 0x102, "$7A other modes swap colors 2 and 3")
end

do
  local s = vm()
  pal(s, 0xC7AB, 0, 0x100, 0x101, 0x102, 0x103)
  local w = run(s, B, 0x4070)
  local a, b, c, d = getpal(s, 0xC7AB, 0)
  ok(a == 0x100 and b == 0x101 and c == 0x102 and d == 0x103, "$7A three mode-3 passes cycle back")
  ok(w == 3, "$7A outer 3 waits three frames, got " .. w)
end

-- $77 with $C830 = 0 (cleared WRAM): `dec` wraps, so the first word walks 256 units.
do
  local s = vm()
  wr16(s, 0xC7AB, rgb(0, 10, 30))
  run(s, B, 0x4020)
  ok(rd16(s, 0xC7AB) == rgb(31, 31, 31) and s:rd8(0xC830) == 1, "$77 with $C830 = 0 runs to white and refills from $C9DC")
end

print(("mn_panel_tails_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
