-- Rings entry (DrawIndexedEntry). Synthetic SRAM and name bytes.
--   luajit tests/engine/mn_ui_start_rings_test.lua
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
local Rings = require("mn.ui.start.Rings")

local SLOT, PAIR = 0x49EB, 0x493B

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
local function put(bank, addr, s)
  patches[#patches + 1] = { MnRom.off(addr, bank), s }
end
local function slot(idx, col, row, right, left, up, down)
  put(3, SLOT + idx * 8, string.char(col, row, right, left, up, down, 0, 0))
end
local function pair(idx, ac, an, bc, bn)
  put(3, PAIR + idx * 4, string.char(ac, an, bc, bn))
end

slot(0, 1, 12, 0x24, 0x24, 4, 1); pair(0, 0x05, 0x00, 0x63, 0x00)
slot(1, 1, 13, 0, 0, 0, 2); pair(1, 0x03, 0x06, 0x00, 0x00)
slot(2, 1, 14, 0, 0, 1, 3); pair(2, 0x07, 0x19, 0x00, 0x00)
slot(0x19, 1, 9, 0x19, 0x19, 0x1D, 0x1B); pair(0x19, 0x08, 0x2B, 0x07, 0x02)
slot(0x1A, 8, 1, 0x1A, 0x1A, 0x1B, 0x1C); pair(0x1A, 0x2C, 0x19, 0x07, 0x02)
slot(0x1B, 8, 10, 0x1B, 0x1B, 0x1A, 0x1D); pair(0x1B, 0x2D, 0x19, 0x07, 0x02)
slot(0x1C, 1, 7, 0x1C, 0x1C, 0x1A, 0x1D); pair(0x1C, 0x06, 0x0D, 0x07, 0x02)
slot(0x1D, 1, 8, 0x1D, 0x1D, 0x1C, 0x19); pair(0x1D, 0x06, 0x0D, 0x07, 0x02)

put(6, 0x5AA6 + 5 * 10, string.char(0x41):rep(10))
put(6, 0x5AA6 + 6 * 10, string.char(0x42):rep(10))
put(6, 0x5A9C, string.char(0x20):rep(10))
put(6, 0x524E, string.char(0x44):rep(12))
put(7, 0x6916 + 2 * 0x13 + 7, string.char(0x43):rep(12))
put(7, 0x6916 + 4 * 0x13 + 7, string.char(0x45):rep(12))
-- name id 5: glyph pointer $4000, bank 3, field $07
put(4, 0x415B + 5 * 0x2D + 0x29, string.char(0x00, 0x40, 0x03, 0x07))

local rom = buildRom(patches)

local function fresh()
  local keys = {}
  local function input(kind)
    if kind == "dir" then return keys.dir end
    return keys[kind]
  end
  local vm = VM.new(rom, {})
  vm:wr8(0xFFAB, 3)
  return vm, { rom = rom, vm = vm, input = input, log = {} }, keys
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

local function sramImage(writes)
  local b = {}
  for i = 1, 0x2000 do b[i] = 0 end
  for addr, val in pairs(writes) do b[addr - 0xA000 + 1] = val end
  local s = {}
  for i = 1, 0x2000 do s[i] = string.char(b[i]) end
  return table.concat(s)
end

-- List bank is the active image. Records sit in the next bank, so the
-- $A019 scan does not see the record bytes.
local function loadList(vm)
  vm.sramBank = 0
  vm:wr8(0xC727, 0)
  vm:wr8(0xA118, 0)
  vm:wr8(0xA119, 0xFF)
  vm:wr8(0xA11A, 1)
  local rec = {}
  local function put(id, bytes)
    local base = 0xA000 + id * 0x25
    for off, v in pairs(bytes) do rec[base + off] = v end
  end
  put(0, {
    [0] = 5, [2] = 12, [4] = 200, [7] = 1, [8] = 2,
    [9] = 9, [10] = 8, [11] = 7, [12] = 6, [13] = 5, [14] = 4,
    [0x22] = 2, [0x23] = 4,
  })
  put(1, {
    [0] = 6, [2] = 3, [4] = 4, [7] = 0, [8] = 9,
    [9] = 1, [0x22] = 0, [0x23] = 4,
  })
  vm.sramBanks = { [1] = sramImage(rec) }
end

do
  local vm, ctx, keys = fresh()
  loadList(vm)
  local scr = Rings.new(ctx)
  local e = scr.entry
  ok(scr.mach.cc47 == 7 and scr.mach.cd81 == 0x19, "harness homes on slot $19")
  ok(scr.mach.col == 1 and scr.mach.row == 9, "cursor sits on the entry")
  ok(e.cc4c == 0 and e.listId == 0 and e.nameId == 5, "direct read of the first id")
  ok(e.name:byte(1) == 0x41 and #e.name == 10, "name is the ten-byte record")
  ok(vm:rd8(0xCC8A) == 0x41 and vm:rd8(0xC9D8) == 5, "name buffer and picture id")
  ok(e.glyphPtr == 0x4000 and e.glyphBank == 3 and e.glyphField == 7, "glyph source")
  ok(vm:rd8(0xC6E6) == 3 and vm:rd8(0xC9B1) == 7, "glyph bank and field bytes")
  ok(e.left == 12 and e.right == 200 and e.wordH == 1 and e.wordL == 2, "map bytes")
  ok(e.stats[1] == 9 and e.stats[6] == 4 and vm:rd8(0xD11B) == 9, "six stat bytes")
  ok(e.ability[1] == 2 and e.abilityName[1]:byte(1) == 0x43, "first ability name")
  ok(e.ability[2] == 4 and e.abilityName[2]:byte(1) == 0x45, "second ability name")
  ok(vm:rd8(0xCCA4) == 1 and vm:rd8(0xCC69) == 2 and vm:rd8(0xCC6A) == 4, "empty $A019 copies the pair")
  ok(vm:rd8(0xCD8C) == 4 and vm:rd8(0xCD91) == 4, "CD8C keeps the last nonzero ability")
  ok(tap(scr, keys, "a") == nil and scr.mach.cd81 == 0x19 and vm:rd8(0xCC47) == 7,
    "A on the entry does not leave")
  tap(scr, keys, "up")
  ok(scr.mach.cd81 == 0x1D and scr.mach.row == 8, "up moves to the direct slot")
  ok(tap(scr, keys, "a") == nil and vm:rd8(0xC921) == 0x14 and vm:rd8(0xCC47) == 7
    and scr.mach.cd81 == 0x1D, "command 6 with CCA4 set stores $14")
end

do
  local vm, ctx, keys = fresh()
  loadList(vm)
  local scr = Rings.new(ctx)
  ok(tap(scr, keys, "down") == nil and scr.mach.cd81 == 0x1B and scr.mach.col == 8
    and scr.entry.cc4c == 0, "down reaches the forward slot without scrolling")
  ok(tap(scr, keys, "a") == nil and scr.entry.cc4c == 2 and scr.entry.listId == 1
    and scr.entry.nameId == 6, "A skips $FF and shows the next id")
  ok(scr.entry.name:byte(1) == 0x42 and scr.entry.abilityName[1]:byte(1) == 0x44
    and scr.entry.abilityName[2]:byte(1) == 0x45, "the next record supplies its own name")
  ok(tap(scr, keys, "up") == nil and scr.mach.cd81 == 0x1A, "up reaches the backward slot")
  ok(tap(scr, keys, "a") == nil and scr.entry.cc4c == 0 and scr.entry.listId == 0,
    "A walks back past the $FF")
  ok(tap(scr, keys, "b") == nil and scr.mach.cd81 == 2, "B moves onto the Rings label")
  local back = tap(scr, keys, "b")
  ok(back and back.action == "back" and vm:rd8(0xCC47) == 5 and vm:rd8(0xCD81) == 0,
    "second B returns to the top menu")
  local again = Rings.new(ctx)
  local closed = tap(again, keys, "start")
  ok(closed and closed.action == "close" and vm:rd8(0xC92C) == 0x0F, "Start closes the entry")
end

do
  local vm, ctx = fresh()
  loadList(vm)
  vm:wr8(0xA019, 1)
  local scr = Rings.new(ctx)
  ok(vm:rd8(0xCCA4) == 0 and vm:rd8(0xCC69) == 1 and vm:rd8(0xCC6A) == 1,
    "a nonzero $A019 leaves the pair bytes at 1")
  ok(scr.entry.nameId == 5, "the entry still loads")
end

do
  local vm, ctx = fresh()
  vm:wr8(0xA118, 0)
  vm:wr8(0xA000, 0xFF)
  local scr = Rings.new(ctx)
  ok(scr.entry.nameId == 0xFF and scr.entry.name == string.char(0x20):rep(10), "id $FF is a blank name")
  ok(scr.entry.glyphBank == 0x45 and scr.entry.glyphPtr == 0x5B80 and scr.entry.glyphField == 5,
    "id $FF uses the fixed glyph source")
end

do
  local vm, ctx = fresh()
  vm.sramBank = 0
  vm:wr8(0xC727, 0)
  vm:wr8(0xA118, 3)
  local base = 0xA000 + 3 * 0x25
  vm.sramBanks = { [1] = sramImage({
    [base] = 6, [base + 2] = 9, [base + 0x22] = 2,
  }) }
  local scr = Rings.new(ctx)
  ok(scr.entry.listId == 3 and scr.entry.nameId == 6 and scr.entry.left == 9,
    "records come from the next SRAM bank")
  ok(scr.entry.ability[1] == 2 and vm:rd8(base) == 0, "the active bank is not the record bank")
end

do
  local vm, ctx, keys = fresh()
  loadList(vm)
  local menu = StartMenu.new(ctx)
  tap(menu, keys, "down")
  ok(menu.mach.cd81 == 2, "an empty spell row skips to Rings")
  ok(tap(menu, keys, "a") == nil and menu.child and menu.child.entry.nameId == 5, "the menu opens the entry")
  ok(tap(menu, keys, "b") == nil and menu.child and menu.mach.cd81 == 2, "B returns to the Rings row")
  ok(tap(menu, keys, "b") == nil and menu.child == nil and menu.mach.cd81 == 0
    and vm:rd8(0xCC47) == 5, "the next B closes the child")
end

local romPath = os.getenv("MN_ROM")
if romPath and romPath ~= "" then
  local f = io.open(romPath, "rb")
  if not f then
    ok(false, "MN_ROM could not be opened")
  else
    local real = MnRom.new(f:read("*a"))
    f:close()
    local keys = {}
    local function input(kind)
      if kind == "dir" then return keys.dir end
      return keys[kind]
    end
    local vm = VM.new(real, {})
    vm:wr8(0xFFAB, 3)
    vm:wr8(0xA118, 1)
    vm:wr8(0xA119, 0xFF)
    vm:wr8(0xA11A, 2)
    local ctx = { rom = real, vm = vm, input = input, log = {} }
    local scr = Rings.new(ctx)
    ok(#scr.entry.name == 10 and scr.entry.glyphBank > 0, "rom name and picture resolve")
    ok(scr.mach.cd81 == 0x19 and scr.mach.row == 9, "rom cursor matches slot $19")
    tap(scr, keys, "down")
    tap(scr, keys, "a")
    ok(scr.entry.cc4c == 2 and scr.entry.listId == 2, "rom scroll skips $FF")
    tap(scr, keys, "b")
    local back = tap(scr, keys, "b")
    ok(back and back.action == "back" and vm:rd8(0xCD81) == 0, "rom second B leaves")
  end
end

print(("mn_ui_start_rings: %d checks, %d failed"):format(checks, failures))
if failures > 0 then os.exit(1) end
