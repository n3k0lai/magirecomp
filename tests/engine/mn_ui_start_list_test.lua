-- Start-menu list mode (IndexedSetup index $0B) and RetargetSramSlotCount.
-- Synthetic SRAM and name bytes. The MN_ROM block prints pass/fail only.
--   luajit tests/engine/mn_ui_start_list_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local bit = require("bit")
local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local SaveFile = require("mn.SaveFile")
local StartMenu = require("mn.ui.StartMenu")
local List = require("mn.ui.start.List")

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
local function slot(idx, col, row, right, left, up, down)
  patches[#patches + 1] = {
    MnRom.off(SLOT + idx * 8, 3),
    string.char(col, row, right, left, up, down, 0, 0),
  }
end
local function pair(idx, ac, an, bc, bn)
  patches[#patches + 1] = {
    MnRom.off(PAIR + idx * 4, 3),
    string.char(ac, an, bc, bn),
  }
end

slot(0, 1, 12, 0x24, 0x24, 4, 1); pair(0, 0x05, 0x00, 0x63, 0x00)
slot(5, 13, 16, 0, 0x24, 0x24, 0x24); pair(5, 0x0B, 0x0D, 0x00, 0x00)
slot(0x24, 13, 15, 5, 0, 5, 5); pair(0x24, 0x4D, 0x24, 0x58, 0x00)
slot(0x0D, 5, 3, 0x0E, 0x17, 0x17, 0x0E); pair(0x0D, 0x4D, 0x0D, 0x58, 0x03)
slot(0x0E, 5, 4, 0x0F, 0x0D, 0x0D, 0x0F); pair(0x0E, 0x4D, 0x0E, 0x58, 0x03)
slot(0x0F, 5, 5, 0x10, 0x0E, 0x0E, 0x10); pair(0x0F, 0x4D, 0x0F, 0x58, 0x03)
slot(0x10, 5, 6, 0x11, 0x0F, 0x0F, 0x11); pair(0x10, 0x4D, 0x10, 0x58, 0x03)
slot(0x11, 5, 7, 0x18, 0x10, 0x10, 0x18); pair(0x11, 0x4D, 0x11, 0x58, 0x03)
slot(0x17, 8, 1, 0x0D, 0x18, 0x18, 0x0D); pair(0x17, 0x2C, 0x0D, 0x58, 0x03)
slot(0x18, 8, 9, 0x17, 0x11, 0x11, 0x17); pair(0x18, 0x2D, 0x0D, 0x58, 0x03)

local function plantName(id, b)
  local addr = (id == 0xFF) and 0x5A9C or (0x5AA6 + id * 10)
  patches[#patches + 1] = { MnRom.off(addr, 6), string.char(b):rep(10) }
end
plantName(0, 0x41)
plantName(1, 0x41)
plantName(2, 0x42)
plantName(3, 0x43)
plantName(4, 0x44)
plantName(7, 0x47)
plantName(9, 0x49)
plantName(10, 0x4A)
plantName(0xFF, 0x20)

local rom = buildRom(patches)

local function fresh()
  local keys = {}
  local function input(kind)
    if kind == "dir" then return keys.dir end
    return keys[kind]
  end
  local vm = VM.new(rom, {})
  vm:wr8(0xFFAB, 3)
  vm.sramBank = 0
  vm:wr8(0xC727, 0)
  local zero = string.rep("\0", SaveFile.BANK_SIZE)
  vm.sramBanks = { [0] = zero, [1] = zero, [2] = zero, [3] = zero }
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

local function pokeNext(vm, addr, val)
  vm.sramBanks[1] = SaveFile.poke(vm.sramBanks[1], addr, val)
end

do
  local vm, ctx, keys = fresh()
  vm:wr8(0xA4A6 + 1, 3)
  vm:wr8(0xA4A6 + 3, 8)
  local scr = List.new(ctx)
  local row = scr.mach.rows[1]
  ok(row.id == 1 and row.count == 3 and #row.glyphs == 10 and row.glyphs:byte(1) == 0x41,
    "first list row uses the ten-byte name")
  ok(scr.mach.rows[2].id == 3 and scr.mach.rows[2].count == 8
    and scr.mach.rows[2].glyphs:byte(1) == 0x43, "second list row")
  ok(scr.mach.rows[3].count == 0, "a short list pads the third row")
  ok(vm:rd8(0xCC47) == 0x0B and vm:rd8(0xCD81) == 0x0D, "list homes on slot $0D")
  ok(vm:rd8(0xCC82) == 0xA6 and vm:rd8(0xCC83) == 0xA4, "list base is $A4A6")
  ok(vm:rd8(0xCC84) == 0 and vm:rd8(0xCC85) == 0, "index $0B stores no addend")
  ok(vm:rd8(0xCC87) == 0x0D and vm:rd8(0xCC88) == 0x01, "list scale is 1")
  ok(vm:rd8(0xCC5A) == 1 and vm:rd8(0xCC5B) == 1 and vm:rd8(0xCC5C) == 0,
    "empty rows clear $CC5A")
  ok(scr.mach.col == 5 and scr.mach.row == 3, "cursor sits on the first count")
  ok(not scr.mach.showAbove and not scr.mach.showBelow, "two rows hide both arrows")
  ok(tap(scr, keys, "down") == nil and scr.mach.cd81 == 0x0E and scr.mach.row == 4,
    "down steps to the next row")
  ok(tap(scr, keys, "a") == nil and vm:rd8(0xCD80) == 1, "A latches the row")
  ok(tap(scr, keys, "a") == nil and vm:rd8(0xCD80) == 0 and scr.mach.cd81 == 0x0E,
    "a second A clears the latch and stays")
  ok(tap(scr, keys, "b") == nil and scr.mach.cd81 == 5, "B moves onto the list label")
  local back = tap(scr, keys, "b")
  ok(back and back.action == "back" and vm:rd8(0xCD81) == 0 and vm:rd8(0xCC47) == 5,
    "second B returns to the top menu")
end

do
  local vm, ctx, keys = fresh()
  for i = 0, 5 do vm:wr8(0xA4A6 + i * 2, i + 1) end
  local scr = List.new(ctx)
  ok(scr.mach.showBelow and not scr.mach.showAbove, "six rows show the lower arrow")
  ok(scr.mach.rows[1].id == 0 and scr.mach.rows[5].id == 8, "first page is the first five")
  for _ = 1, 5 do tap(scr, keys, "down") end
  ok(scr.mach.cd81 == 0x18, "down reaches the lower arrow")
  ok(tap(scr, keys, "a") == nil and scr.mach.rows[1].id == 10 and scr.mach.rows[1].count == 6,
    "the lower arrow advances one page")
  ok(scr.mach.showAbove and scr.mach.rows[1].glyphs:byte(1) == 0x4A, "the new page shows its name")
  tap(scr, keys, "up")
  ok(scr.mach.cd81 == 0x17, "up reaches the upper arrow")
  ok(tap(scr, keys, "a") == nil and scr.mach.rows[1].id == 0, "the upper arrow returns")
end

do
  local vm, ctx, keys = fresh()
  vm:wr8(0xA4A7, 1)
  local closed = List.new(ctx)
  local r = tap(closed, keys, "start")
  ok(r and r.action == "close", "Start closes the list")
  ok(vm:rd8(0xC92C) == 0x0F, "close restores the field sound byte")
end

do
  local vm, ctx, keys = fresh()
  vm:wr8(0xA4A6, 1)
  vm:wr8(0xCCA5, 1)
  local scr = StartMenu.new(ctx)
  ok(vm:rd8(0xCCA1) == 0 and vm:rd8(0xCC4C) == 0, "open clears the select latch")
  ok(vm:rd8(0xCC52) == 1, "a nonzero list span leaves the row selectable")
  tap(scr, keys, "right")
  tap(scr, keys, "down")
  ok(tap(scr, keys, "a") == nil and scr.child and scr.child.spec.mode == 0x0B,
    "A on the list row opens it")
  vm:wr8(0xA4A6, 0)
  local shut = StartMenu.new(ctx)
  tap(shut, keys, "right")
  tap(shut, keys, "down")
  ok(shut.mach.cd81 ~= 5, "an empty list span is skipped")
end

do
  local vm, ctx = fresh()
  vm:wr8(0xA118, 2)
  vm:wr8(0xA019 + 5, 4)
  pokeNext(vm, 0xA022 + 2 * 0x25, 5)
  pokeNext(vm, 0xA022 + 2 * 0x25 + 1, 9)
  local scr = List.new(ctx)
  scr.mach.cd81 = 0x10
  ok(scr.mach:press("select") == nil and vm:rd8(0xCCA1) == 0 and vm:rd8(0xCC4B) == 0,
    "Select off $1C/$1D does nothing")
  scr.mach.cd81 = 0x1C
  ok(scr.mach:press("select") == nil and vm:rd8(0xCCA0) == 0, "slot $1C stores difference 0")
  ok(vm:rd8(0xCCA1) == 5 and vm:rd8(0xCC4B) == 1, "a zero latch takes the byte")
  ok(vm:rd8(0xA019 + 5) == 5, "the taken id increments its count")
  ok(SaveFile.peek(vm.sramBanks[1], 0xA022 + 2 * 0x25) == 0, "the source byte is cleared")
  scr.mach.cd81 = 0x1D
  ok(scr.mach:press("left") == nil and vm:rd8(0xCCA0) == 1, "Left on $1D is Select")
  ok(vm:rd8(0xCCA1) == 0 and vm:rd8(0xA019 + 5) == 4, "the swap returns the old count")
  ok(vm:rd8(0xA019 + 9) == 1, "the displaced id increments")
  ok(SaveFile.peek(vm.sramBanks[1], 0xA022 + 2 * 0x25 + 1) == 5, "the latch is written")
  scr.mach.cd81 = 0x1C
  scr.mach.cc4b = 0
  scr.mach:flush()
  ok(scr.mach:press("select") == nil and vm:rd8(0xCCA1) == 0 and vm:rd8(0xCC4B) == 0,
    "a zero source byte leaves the latch clear")
end

do
  local vm, ctx = fresh()
  vm:wr8(0xA118, 1)
  vm:wr8(0xA019 + 1, 0)
  pokeNext(vm, 0xA022 + 0x25, 1)
  local scr = List.new(ctx)
  scr.mach.cd81 = 0x1C
  scr.mach:press("right")
  ok(vm:rd8(0xCCA1) == 1 and vm:rd8(0xA019 + 1) == 1, "Right on $1C takes the byte")
  scr.mach:press("select")
  ok(vm:rd8(0xCCA1) == 0 and vm:rd8(0xA019 + 1) == 0, "putting it back decrements")
  ok(SaveFile.peek(vm.sramBanks[1], 0xA022 + 0x25) == 1, "the byte is restored")
  ok(bit.band(vm:rd8(0xCC4B), 0xFF) == 1, "a swap sets $CC4B")
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
    local function u8(bank, addr) return real:u8(MnRom.off(addr, bank)) or 0 end
    ok(u8(3, PAIR + 0x0D * 4) == 0x4D, "rom list row A is the latch command")
    ok(u8(3, PAIR + 0x0D * 4 + 2) == 0x58, "rom list row B is the back command")
    ok(u8(3, PAIR + 5 * 4) == 0x0B, "rom list label A selects index $0B")
    local src = real:u16(MnRom.off(0x51C1 + 0x0B * 2, 6))
    ok(src ~= 0, "rom index $0B has a map")
    local vm = VM.new(real, {})
    vm:wr8(0xFFAB, 3)
    vm:wr8(0xA4A6 + 4, 2)
    local keys = {}
    local function input(kind)
      if kind == "dir" then return keys.dir end
      return keys[kind]
    end
    local scr = List.new({ rom = real, vm = vm, input = input, log = {} })
    ok(#scr.mach.rows[1].glyphs == 10 and scr.mach.rows[1].id == 4 and scr.mach.rows[1].count == 2,
      "rom name for the planted offset is ten bytes")
    ok(vm:rd8(0xCC47) == 0x0B and vm:rd8(0xCC88) == 1, "rom list scale byte")
  end
end

print(("mn_ui_start_list: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
