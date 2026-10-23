-- Glyph map from the field Start menu. Synthetic SRAM and a synthetic
-- index-9 tilemap. The MN_ROM block prints pass/fail only.
--   luajit tests/engine/mn_ui_start_glyph_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local StartMenu = require("mn.ui.StartMenu")
local Glyph = require("mn.ui.start.Glyph")

local SLOT, PAIR = 0x49EB, 0x493B
local BANK = 6

local function buildRom(patches)
  table.sort(patches, function(a, b) return a[1] < b[1] end)
  local parts, at = {}, 0
  for i = 1, #patches do
    local off, s = patches[i][1], patches[i][2]
    if off > at then parts[#parts + 1] = string.rep("\0", off - at) end
    parts[#parts + 1] = s
    at = off + #s
  end
  if at < 0x200000 then parts[#parts + 1] = string.rep("\0", 0x200000 - at) end
  return MnRom.new(table.concat(parts))
end

local patches = {}
local function put(bank, addr, bytes)
  patches[#patches + 1] = { MnRom.off(addr, bank), bytes }
end
local function slot(idx, col, row, right, left, up, down)
  put(3, SLOT + idx * 8, string.char(col, row, right, left, up, down, 0, 0))
end
local function pair(idx, ac, an, bc, bn)
  put(3, PAIR + idx * 4, string.char(ac, an, bc, bn))
end

slot(0, 1, 12, 0, 0, 4, 1); pair(0, 0x05, 0x00, 0x63, 0x00)
slot(1, 1, 13, 0, 0, 0, 2); pair(1, 0x03, 0x06, 0x00, 0x00)
slot(2, 1, 14, 0, 0, 1, 3); pair(2, 0x07, 0x19, 0x00, 0x00)
slot(3, 1, 15, 0, 0, 2, 4); pair(3, 0x04, 0x0D, 0x00, 0x00)
slot(4, 1, 16, 0, 0, 3, 0); pair(4, 0x09, 0x14, 0x00, 0x00)
slot(0x14, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14); pair(0x14, 0x09, 0x14, 0x00, 0x04)

-- 20x10 map of blanks, with one marked cell where the first stamp lands.
local map = string.rep(string.char(0x80), 200)
local mark = 5 * 20 + 9
map = map:sub(1, mark) .. string.char(0x01) .. map:sub(mark + 2)
put(BANK, 0x6200, map)
put(BANK, 0x51C1 + 9 * 2, string.char(0x00, 0x62))
put(BANK, 0x6F92, string.char(0x21):rep(20))
put(BANK, 0x6FA6, string.char(0x11, 0x12, 0x13, 0x14, 0x15, 0x16))
-- Attribute block: flip on the first picture cell and on the flag>=2 cell.
local attrs = string.rep(string.char(0x0F), 96)
attrs = string.char(0x2F) .. attrs:sub(2)
local clearAt = 4 * 12 + 6 -- source row 5, column 10
attrs = attrs:sub(1, clearAt) .. string.char(0x2F) .. attrs:sub(clearAt + 2)
put(BANK, 0x6FAC, attrs)
put(BANK, 0x700C, string.char(0x2F, 0x0F, 0x0F, 0x0F) .. string.rep(string.char(0x0F), 16))

local rom = buildRom(patches)

local function fresh()
  local keys = {}
  local function input(kind)
    if kind == "dir" then return keys.dir end
    return keys[kind]
  end
  local vm = VM.new(rom, {})
  vm:wr8(0xFFAB, 3)
  local ctx = { rom = rom, vm = vm, input = input, log = {} }
  return vm, ctx, keys
end

local function tap(scr, keys, btn)
  keys.dir, keys.a, keys.b, keys.start, keys.select = nil, nil, nil, nil, nil
  if btn == "up" or btn == "down" or btn == "left" or btn == "right" then
    keys.dir = btn
  else
    keys[btn] = true
  end
  local r = scr:update()
  keys.dir, keys.a, keys.b, keys.start, keys.select = nil, nil, nil, nil, nil
  local r2 = scr:update()
  if r ~= nil then return r end
  return r2
end

local function at(tiles, row, col) return tiles[row * 20 + col] end

do
  local g1, h1 = Glyph.layout(rom, 1)
  ok(at(g1, 5, 9) == 0x01, "flag 1 keeps the map cell")
  ok(at(g1, 5, 10) == 0x80, "flag 1 does not stamp the neighbour")
  ok(h1[1 * 20 + 4] == true, "the attribute block flips its first cell")
  ok(h1[5 * 20 + 10] == true, "flag 1 leaves the later flip in place")
  local g2, h2 = Glyph.layout(rom, 2)
  ok(at(g2, 5, 9) == 0x11 and at(g2, 5, 10) == 0x12, "flag 2 writes the first pair")
  ok(at(g2, 6, 9) == 0x80, "flag 2 stops before the next stamp")
  ok(h2[5 * 20 + 10] == false, "flag 2 clears the flip at $9CCA")
  local g3 = Glyph.layout(rom, 3)
  ok(at(g3, 6, 9) == 0x13 and at(g3, 6, 10) == 0x80, "flag 3 adds one cell")
  local g4 = Glyph.layout(rom, 4)
  ok(at(g4, 6, 10) == 0x14 and at(g4, 7, 9) == 0x80, "flag 4 adds the next cell")
  local g5, h5 = Glyph.layout(rom, 5)
  ok(at(g5, 7, 9) == 0x15 and at(g5, 7, 10) == 0x16, "flag 5 writes the last pair")
  ok(at(g5, 0, 8) == 0x80, "flag 5 does not copy the row strip")
  ok(h5[8] == false, "flag 5 does not copy the attribute strip")
  local g0 = Glyph.layout(rom, 0)
  ok(at(g0, 5, 9) == 0x11 and at(g0, 0, 8) == 0x21, "flag 0 takes every stamp and the strip")
  local g6, h6 = Glyph.layout(rom, 6)
  ok(at(g6, 0, 8) == 0x21 and at(g6, 2, 8) == 0x21, "flag 6 copies five strip rows")
  ok(h6[8] == true and h6[9] == false, "flag 6 copies the attribute strip")
  local _, h7 = Glyph.layout(rom, 7)
  ok(at(Glyph.layout(rom, 7), 0, 8) == 0x21, "flag 7 still copies the tile strip")
  ok(h7[8] == false, "flag 7 skips the attribute strip")
end

do
  local vm, ctx, keys = fresh()
  vm:wr8(0xA5A6, 1); vm:wr8(0xA3A8, 1); vm:wr8(0xA3A4, 4)
  local menu = StartMenu.new(ctx)
  ok(vm:rd8(0xCC51) == 4, "opening the menu copies $A3A4 to $CC51")
  tap(menu, keys, "down"); tap(menu, keys, "down")
  tap(menu, keys, "down"); tap(menu, keys, "down")
  ok(menu.mach.cd81 == 4, "four downs reach the glyph row")
  ok(tap(menu, keys, "a") == nil and menu.child and vm:rd8(0xCC47) == 9, "A opens the map")
  ok(vm:rd8(0xCD81) == 0x14 and vm:rd8(0xCC4B) == 0, "the map homes on slot $14 with $CC4B clear")
  ok(vm:rd8(0xCCA0) == 0xE8, "$CCA0 is the glyph slot minus $1C")
  ok(menu.child.mach.col == 0x14 and menu.child.mach.row == 0x14, "the cursor cell is past the window")
  ok(tap(menu, keys, "down") == nil and vm:rd8(0xCD81) == 0x14, "down stays on the map slot")
  ok(tap(menu, keys, "left") == nil and vm:rd8(0xCD81) == 0x14, "left stays on the map slot")
  ok(tap(menu, keys, "a") == nil and vm:rd8(0xCC47) == 9, "A on the map stays in mode 9")
  ok(tap(menu, keys, "b") == nil and menu.child == nil, "B returns to the menu")
  ok(vm:rd8(0xCD81) == 4 and vm:rd8(0xCC47) == 5, "B lands on the glyph row")
  ok(vm:rd8(0xCCA0) == 0xF8, "leaving stores slot $14 minus $1C")
end

do
  local vm, ctx, keys = fresh()
  vm:wr8(0xA3A4, 3)
  local scr = Glyph.new(ctx)
  ok(scr.mach.cc47 == 9 and scr.mach.cd81 == 0x14, "the harness screen starts on the map")
  ok(vm:rd8(0xCC82) == 0 and vm:rd8(0xA3A4) == 3, "the map does not rewrite SRAM")
  local back = tap(scr, keys, "b")
  ok(back and back.action == "back", "B from the harness screen goes back")
  local again = Glyph.new(ctx)
  local closed = tap(again, keys, "start")
  ok(closed and closed.action == "close", "Start closes the map")
  ok(vm:rd8(0xC92C) == 0x0F and vm:rd8(0xC92A) == 4, "close restores the field sound bytes")
end

local romPath = os.getenv("MN_ROM")
if romPath and romPath ~= "" then
  local f = io.open(romPath, "rb")
  if not f then
    ok(false, "MN_ROM could not be opened")
  else
    local bytes = f:read("*a")
    f:close()
    local real = MnRom.new(bytes)
    local function live()
      local keys = {}
      local function input(kind)
        if kind == "dir" then return keys.dir end
        return keys[kind]
      end
      local vm = VM.new(real, {})
      vm:wr8(0xFFAB, 3)
      vm:wr8(0xA5A6, 1); vm:wr8(0xA3A8, 1); vm:wr8(0xA3A4, 1)
      return StartMenu.new({ rom = real, vm = vm, input = input, log = {} }), keys, vm
    end
    local src = real:u16(MnRom.off(0x51C1 + 9 * 2, BANK))
    ok(src ~= 0, "the index 9 map pointer is set")
    local g1 = Glyph.layout(real, 1)
    local g2 = Glyph.layout(real, 2)
    local g5 = Glyph.layout(real, 5)
    local g6 = Glyph.layout(real, 6)
    local function mapByte(row, col) return real:u8(MnRom.off(src + row * 20 + col, BANK)) end
    local function romByte(addr) return real:u8(MnRom.off(addr, BANK)) end
    ok(at(g1, 5, 9) == mapByte(5, 9), "rom flag 1 keeps the map cell")
    ok(at(g2, 5, 9) == romByte(0x6FA6) and at(g2, 5, 10) == romByte(0x6FA7),
      "rom flag 2 writes the first stamp pair")
    ok(at(g2, 6, 9) == mapByte(6, 9), "rom flag 2 stops before the next stamp")
    ok(at(g5, 7, 9) == romByte(0x6FAA) and at(g5, 7, 10) == romByte(0x6FAB),
      "rom flag 5 writes the last stamp pair")
    ok(at(g5, 0, 8) == mapByte(0, 8), "rom flag 5 leaves the row strip")
    ok(at(g6, 0, 8) == romByte(0x6F92) and at(g6, 4, 11) == romByte(0x6F92 + 19),
      "rom flag 6 copies the row strip")
    local scr, keys, vm = live()
    tap(scr, keys, "down"); tap(scr, keys, "down")
    tap(scr, keys, "down"); tap(scr, keys, "down")
    ok(scr.mach.cd81 == 4, "rom four downs reach glyph")
    ok(tap(scr, keys, "a") == nil and scr.child and vm:rd8(0xCC47) == 9
      and vm:rd8(0xCD81) == 0x14, "rom A opens the map")
    ok(scr.child.mach.col == 0x14 and scr.child.mach.row == 0x14, "rom cursor sits off the window")
    ok(tap(scr, keys, "down") == nil and vm:rd8(0xCD81) == 0x14, "rom down does not move")
    ok(tap(scr, keys, "b") == nil and scr.child == nil and vm:rd8(0xCD81) == 4
      and vm:rd8(0xCC47) == 5, "rom B returns to the glyph row")
  end
end

print(("mn_ui_start_glyph: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
