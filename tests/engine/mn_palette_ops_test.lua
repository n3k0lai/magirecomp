-- Screen palette ops ($6E/$6F/$70/$71/$74/$76/$77/$79/$7A) on the $C72B
-- target and $C7AB live blocks, plus mn.LivePalette's OBJ map. Made-up bytes
-- only; no ROM.
--   luajit tests/engine/mn_palette_ops_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Op = require("mn.Opcodes")
local Panels = require("mn.ops.Panels")
local LivePalette = require("mn.LivePalette")

local function rgb(r, g, b) return r + g * 32 + b * 1024 end
local WHITE, BLACK = 0x7FFF, 0
local C72B, C7AB = 0xC72B, 0xC7AB

-- one op's bytes at file offset 0x100; returns (vm, frames waited)
local function op(bytes, setup)
  local img = string.rep("\0", 0x100) .. string.char(unpack(bytes))
  img = img .. string.rep("\0", 0x200000 - #img)
  local vm = VM.new(MnRom.new(img), {})
  if setup then setup(vm) end
  local h = assert(Panels.handlers[bytes[1]], ("handler $%02X"):format(bytes[1]))
  local n = Op.LEN[bytes[1]]
  ok(n == #bytes - 1, ("$%02X operand count %d"):format(bytes[1], #bytes - 1))
  local waited = 0
  local co = coroutine.create(function() return h(vm, 0x100, n, { ptr = 0x4100 }) end)
  while true do
    local okr, kind, w = coroutine.resume(co)
    assert(okr, kind)
    if coroutine.status(co) == "dead" then
      ok(kind == 0x100 + n, ("$%02X returns past its operands"):format(bytes[1]))
      break
    end
    if kind == "wait" then waited = waited + (w or 1) end
  end
  return vm, waited
end

local function rd(vm, a) return vm:rd8(a) + 256 * vm:rd8(a + 1) end
local function wr(vm, a, w) vm:wr8(a, w % 256); vm:wr8(a + 1, math.floor(w / 256)) end
local function fill(vm, base, n, w) for k = 0, n - 1 do wr(vm, base + 2 * k, w) end end
local function all(vm, base, n, w)
  for k = 0, n - 1 do if rd(vm, base + 2 * k) ~= w then return false end end
  return true
end

-- $6E: target rows only (no upload). $0F = all sixteen palettes.
do
  local vm = op({ 0x6E, 0x0F, 0xFF, 0x7F }, function(v) fill(v, C7AB, 64, 0x1234) end)
  ok(all(vm, C72B, 64, WHITE), "$6E fills the 64 target words")
  ok(all(vm, C7AB, 64, 0x1234), "$6E leaves the live block")
  ok(vm:rd8(0xC6E4) ~= 0x75, "$6E plants no palette callback")
end

-- $6F: live rows; $07 = BG only; bit 7 of the hi byte takes $C9E5.
do
  local vm, f = op({ 0x6F, 0x07, 0x00, 0x80 }, function(v)
    wr(v, 0xC9E5, rgb(0, 2, 0)); fill(v, C7AB, 64, WHITE)
  end)
  ok(all(vm, C7AB, 32, rgb(0, 2, 0)), "$6F sets the BG live words from $C9E5")
  ok(all(vm, C7AB + 0x40, 32, WHITE), "$6F $07 leaves the OBJ live words")
  ok(vm:rd8(0xC6E4) == 0x75 and vm:rd8(0xC6E6) == 7, "$6F plants RefreshSavedPalettes")
  ok(f == 1, "$6F takes one frame")
end

-- $6F $87: OBJ rows; $F0: last OBJ palette only.
do
  local vm = op({ 0x6F, 0x87, 0x1F, 0x00 })
  ok(all(vm, C7AB + 0x40, 32, rgb(31, 0, 0)) and all(vm, C7AB, 32, 0), "$6F $87 is the OBJ eight")
  vm = op({ 0x6F, 0xF0, 0x1F, 0x00 })
  ok(all(vm, C7AB + 0x78, 4, rgb(31, 0, 0)) and all(vm, C7AB, 60, 0), "$6F $F0 is the last OBJ palette")
end

-- $76: split $85 = 2 frames per tick, 5 ticks; each channel moves one step
-- per tick toward the target rows.
do
  local vm, f = op({ 0x76, 0x45, 0x07 }, function(v)
    fill(v, C72B, 32, rgb(10, 20, 30)); fill(v, C7AB, 32, BLACK)
  end)
  ok(f == 10, "$76 split $45 waits 5 ticks of 2 frames (" .. f .. ")")
  ok(all(vm, C7AB, 32, rgb(5, 5, 5)), "$76 steps each channel 5 times")
  ok(vm:rd8(0xCCA6) == 0, "$76 clears $CCA6 when the count ends")
end
do
  local vm = op({ 0x76, 0x20, 0x07 }, function(v)
    fill(v, C72B, 32, rgb(31, 31, 31)); fill(v, C7AB, 32, rgb(0, 0, 0))
  end)
  ok(all(vm, C7AB, 32, WHITE), "$76 $20 (32 ticks) reaches the target from black")
end
do
  local _, f = op({ 0x76, 0xE0, 0x07 })
  ok(f == 128, "$76 $E0 waits 32 ticks of 4 frames (" .. f .. ")")
end

-- $77: live rows step toward one word. $07:48FD does not reload $C830, so
-- the step count is what the last stepper left (1 after any $C9DC = 1 op).
do
  local vm, f = op({ 0x77, 0x03, 0x07, 0xFF, 0x7F }, function(v) v:wr8(0xC830, 1); fill(v, C7AB, 32, rgb(1, 2, 3)) end)
  ok(f == 3, "$77 split $03 waits 3 frames")
  ok(all(vm, C7AB, 32, rgb(4, 5, 6)), "$77 steps toward white three times")
end

-- rotate modes (RotatePaletteColors $07:45B2)
do
  local vm = VM.new(MnRom.new(string.rep("\0", 0x200000)), {})
  local function set() for i = 0, 3 do wr(vm, 0xD000 + 2 * i, i + 1) end end
  local function got() local t = {} for i = 0, 3 do t[#t + 1] = rd(vm, 0xD000 + 2 * i) end return table.concat(t, ",") end
  set(); Panels.rotatePalette(vm, 0xD000, 4); ok(got() == "4,1,2,3", "rotate mode 4 moves all four up")
  set(); Panels.rotatePalette(vm, 0xD000, 3); ok(got() == "1,4,2,3", "rotate mode 3 keeps color 0")
  set(); Panels.rotatePalette(vm, 0xD000, 1); ok(got() == "1,2,4,3", "other modes swap colors 2 and 3")
end

-- $7A: two ticks of mode 4 on BG palette 0 only ($00 = one palette).
do
  local vm = op({ 0x7A, 0x02, 0x00, 0x04 }, function(v)
    for i = 0, 3 do wr(v, C7AB + 2 * i, i + 1) end
    for i = 0, 3 do wr(v, C7AB + 8 + 2 * i, i + 1) end
  end)
  ok(rd(vm, C7AB) == 3 and rd(vm, C7AB + 2) == 4 and rd(vm, C7AB + 4) == 1, "$7A rotates palette 0 twice")
  ok(rd(vm, C7AB + 8) == 1, "$7A leaves palette 1")
end

-- $79: target rows copied live.
do
  local vm = op({ 0x79, 0x87 }, function(v) fill(v, C72B + 0x40, 32, 0x0ABC) end)
  ok(all(vm, C7AB + 0x40, 32, 0x0ABC) and all(vm, C7AB, 32, 0), "$79 $87 copies the OBJ target live")
end

-- $70: slot 0 cycles colors 1-3 of BG palettes 0-2, slot 1 palettes 3-5.
do
  local function setup(v) for p = 0, 7 do for c = 0, 3 do wr(v, C7AB + 8 * p + 2 * c, c) end end end
  local vm = op({ 0x70, 0x01, 0x00 }, setup)
  ok(rd(vm, C7AB + 2) == 3 and rd(vm, C7AB + 4) == 1 and rd(vm, C7AB + 6) == 2, "$70 slot 0 cycles palette 0")
  ok(rd(vm, C7AB + 16 + 2) == 3 and rd(vm, C7AB + 24 + 2) == 1, "$70 slot 0 covers palette 2 and not 3")
  vm = op({ 0x70, 0x01, 0x01 }, setup)
  ok(rd(vm, C7AB + 2) == 1 and rd(vm, C7AB + 24 + 2) == 3 and rd(vm, C7AB + 40 + 2) == 3 and rd(vm, C7AB + 48 + 2) == 1,
    "$70 slot 1 is palettes 3-5")
end

-- $71: colors 1-3 step; color 0 of the slot's last palette steps unless $C9E2.
do
  local vm = op({ 0x71, 0x01, 0xFF, 0x7F, 0x00 })
  ok(rd(vm, C7AB + 2) == rgb(1, 1, 1) and rd(vm, C7AB) == 0, "$71 steps colors 1-3, not color 0 of palette 0")
  ok(rd(vm, C7AB + 16) == rgb(1, 1, 1), "$71 steps color 0 of palette 2")
  vm = op({ 0x71, 0x01, 0xFF, 0x7F, 0x00 }, function(v) v:wr8(0xC9E2, 1) end)
  ok(rd(vm, C7AB + 16) == 0, "$C9E2 holds color 0 of palette 2")
end

-- PermuteColorChannels: mode 3 swaps r/g then falls into the r/b swap.
do
  local w = rgb(1, 2, 3)
  ok(Panels.permuteWord(w, 1) == rgb(3, 2, 1), "permute mode 1 swaps red and blue")
  ok(Panels.permuteWord(w, 2) == rgb(1, 3, 2), "permute mode 2 swaps green and blue")
  ok(Panels.permuteWord(w, 3) == rgb(3, 1, 2), "permute mode 3 is (b, r, g)")
  ok(Panels.permuteWord(w, 0) == rgb(2, 3, 1), "other modes are (g, b, r)")
  local vm = op({ 0x74, 0x01, 0x01, 0x00 }, function(v) wr(v, C7AB + 2, w); wr(v, C7AB, w) end)
  ok(rd(vm, C7AB + 2) == rgb(3, 2, 1) and rd(vm, C7AB) == w, "$74 permutes colors 1-3 only")
end

-- map load: 32 BG words to the target and live blocks at once
do
  local vm = VM.new(MnRom.new(string.rep("\0", 0x200000)), {})
  local w = {}; for k = 0, 31 do w[k] = k * 3 end
  Panels.loadPalettes(vm, w, false)
  ok(rd(vm, C72B + 62) == 93 and rd(vm, C7AB + 62) == 93 and rd(vm, C7AB + 64) == 0, "BG load fills $C72B and $C7AB")
  Panels.loadPalettes(vm, w, true)
  ok(rd(vm, C72B + 64 + 2) == 3 and rd(vm, C7AB + 64 + 2) == 3, "OBJ load fills $C76B and $C7EB")
end

-- LivePalette OBJ map: the first palette with a base color wins.
do
  local base, live = {}, {}
  for k = 0, 31 do base[k] = k; live[k] = 100 + k end
  base[9] = 1 -- palette 2 color 1 shares palette 0 color 1
  local m = LivePalette.objMap(base, live)
  ok(m[1] == 101, "a shared base color maps to the lower palette's live word")
  ok(m[31] == 131, "each base color maps to its live word")
end

print(("mn_palette_ops: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
