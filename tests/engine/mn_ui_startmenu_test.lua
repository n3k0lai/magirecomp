-- Field Start menu. Synthetic slot tables and SRAM. ROM-free except the
-- optional MN_ROM block, which prints pass/fail only.
--   luajit tests/engine/mn_ui_startmenu_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Digits = require("mn.ui.start.Digits")
local StartMenu = require("mn.ui.StartMenu")
local Items = require("mn.ui.start.Items")
local Spell = require("mn.ui.start.Spell")
local SaveScr = require("mn.ui.start.Save")
local SaveFile = require("mn.SaveFile")

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
slot(1, 1, 13, 0, 0, 0, 2); pair(1, 0x03, 0x06, 0x00, 0x00)
slot(2, 1, 14, 0, 0, 1, 3); pair(2, 0x07, 0x19, 0x00, 0x00)
slot(3, 1, 15, 0, 0, 2, 4); pair(3, 0x04, 0x0D, 0x00, 0x00)
slot(4, 1, 16, 0, 0, 3, 0); pair(4, 0x09, 0x14, 0x00, 0x00)
slot(5, 13, 16, 0, 0x24, 0x24, 0x24); pair(5, 0x0B, 0x0D, 0x00, 0x00)
slot(0x24, 13, 15, 5, 0, 5, 5); pair(0x24, 0x4D, 0x24, 0x58, 0x00)
slot(6, 5, 3, 0, 0, 0x0B, 7); pair(6, 0x00, 0x00, 0x58, 0x01)
slot(7, 5, 4, 0, 0, 6, 7); pair(7, 0x00, 0x00, 0x00, 0x00)
slot(0x0D, 5, 3, 0, 0, 0x17, 0x0E); pair(0x0D, 0x00, 0x00, 0x58, 0x03)
slot(0x0E, 5, 4, 0, 0, 0x0D, 0x0F); pair(0x0E, 0, 0, 0, 0)
slot(0x0F, 5, 5, 0, 0, 0x0E, 0x10); pair(0x0F, 0, 0, 0, 0)
slot(0x10, 5, 6, 0, 0, 0x0F, 0x11); pair(0x10, 0, 0, 0, 0)
slot(0x11, 5, 7, 0, 0, 0x10, 0x18); pair(0x11, 0, 0, 0, 0)
slot(0x17, 8, 1, 0, 0, 0x17, 0x0D); pair(0x17, 0x2C, 0x17, 0, 0)
slot(0x18, 8, 9, 0, 0, 0x11, 0x18); pair(0x18, 0x2D, 0x18, 0, 0)
slot(0x19, 1, 9, 0x19, 0x19, 0x1D, 0x1B); pair(0x19, 0x08, 0x2B, 0x07, 0x02)

local function plantName(addend, id, scale, b)
  patches[#patches + 1] = {
    MnRom.off(addend + id * scale + 12, 7),
    string.char(b):rep(13),
  }
end
plantName(0x5DFF, 1, 0x22, 0x41)
plantName(0x5DFF, 3, 0x22, 0x43)
plantName(0x5DFF, 6, 0x22, 0x46)
plantName(0x6FF5, 0, 0x22, 0x42)

local rom = buildRom(patches)

local function memfs()
  local box = {}
  return {
    box = box,
    write = function(path, data) box[path] = data; return true end,
    read = function(path) return box[path] end,
    createDirectory = function() return true end,
  }
end

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

do
  local h, t, o = Digits.format(0, 0)
  ok(h == 0 and t == 0 and o == 0, "zero word is three zero digits")
  h, t, o = Digits.format(0, 255)
  ok(h == 2 and t == 5 and o == 5, "255 is 2,5,5")
  h, t, o = Digits.format(1, 0)
  ok(h == 2 and t == 5 and o == 6, "high bit 1 seeds 256")
  h, t, o = Digits.format(3, 255)
  ok(h == 10 and t == 2 and o == 3, "hundreds is left above 9")
  h, t, o = Digits.format(7, 0)
  ok(h == 7 and t == 6 and o == 8, "only the low two high bits count")
end

do
  local vm = VM.new(rom, {})
  ok(not StartMenu.canOpen(vm), "FFAB bit 1 starts clear")
  vm:wr8(0xFFAB, 2)
  ok(StartMenu.canOpen(vm), "FFAB bit 1 alone is enough")
  vm:wr8(0xFFAB, 3)
  ok(StartMenu.canOpen(vm), "FFAB 3 opens")
  vm:wr8(0xFFAB, 1)
  ok(not StartMenu.canOpen(vm), "FFAB without bit 1 stays shut")
  vm:wr8(0xFFAB, 3)
  vm:wr8(0xC6EE, 1)
  ok(not StartMenu.canOpen(vm), "C6EE blocks")
  vm:wr8(0xC6EE, 0)
  vm:wr8(0xC716, 1)
  ok(not StartMenu.canOpen(vm), "C716 blocks")
  vm:wr8(0xC716, 0)
  vm:wr8(0xCCA6, 1)
  ok(not StartMenu.canOpen(vm), "CCA6 blocks")
  vm:wr8(0xCCA6, 0)
  ok(StartMenu.canOpen(vm), "cleared gates open")
end

do
  local vm, ctx, keys = fresh()
  vm:wr8(0xCC4E, 9); vm:wr8(0xCC50, 9); vm:wr8(0xCC52, 9)
  vm:wr8(0xA118, 5); vm:wr8(0xA3A4, 3); vm:wr8(0xCCA5, 4)
  local scr = StartMenu.new(ctx)
  ok(vm:rd8(0xC92C) == 6, "open sets the menu sound byte")
  ok(vm:rd8(0xC928) == 0 and vm:rd8(0xC92A) == 4, "open clears the other sound bytes")
  ok(vm:rd8(0xCC4E) == 0 and vm:rd8(0xCC50) == 0 and vm:rd8(0xCC52) == 0,
    "empty SRAM spans clear their flags")
  ok(vm:rd8(0xCC4D) == 1 and vm:rd8(0xCC4D + 0x2B) == 1, "slot flags start set")
  ok(vm:rd8(0xCC4F) == 6, "CC4F is A118 plus one")
  ok(vm:rd8(0xCC51) == 3 and vm:rd8(0xCC71) == 4, "CC51 and CC71 copy SRAM")
  ok(vm:rd8(0xCCA9) == 0xFF and vm:rd8(0xC6F0) == 7 and vm:rd8(0xC6F1) == 0,
    "dispatch mask and palette bytes")
  ok(scr.mach.col == 1 and scr.mach.row == 12 and scr.mach.cd81 == 0, "cursor starts on row 0")
  ok(tap(scr, keys, "a") == nil and scr.mach.cd81 == 0, "A on the first row stays")
  local closed = tap(scr, keys, "b")
  ok(closed and closed.action == "close", "B on the first row closes")
  ok(vm:rd8(0xC92C) == 0x0F and vm:rd8(0xC92A) == 4, "close restores the field sound bytes")
end

do
  local vm, ctx = fresh()
  vm:wr8(0xA3A8, 1); vm:wr8(0xCC50, 9)
  StartMenu.new(ctx)
  ok(vm:rd8(0xCC50) == 1, "a nonzero item span is filled and left set")
  ok(vm:rd8(0xCC4E) == 0, "the other empty span still clears")
end

do
  local vm, ctx, keys = fresh()
  vm:wr8(0xA5A6, 1); vm:wr8(0xA3A8, 1); vm:wr8(0xA3A4, 1)
  local scr = StartMenu.new(ctx)
  tap(scr, keys, "down")
  tap(scr, keys, "a")
  ok(scr.child and scr.child.spec.mode == 3, "A on the second row opens spells")
  ok(vm:rd8(0xCC47) == 3 and vm:rd8(0xCD81) == 6, "spell list homes on its first slot")
  ok(tap(scr, keys, "b") == nil and scr.child and vm:rd8(0xCD81) == 1, "first B stays in the list")
  ok(tap(scr, keys, "b") == nil and scr.child == nil and vm:rd8(0xCD81) == 0, "second B returns")
  ok(tap(scr, keys, "down") == nil and scr.mach.cd81 == 1, "the menu still moves")
  tap(scr, keys, "down")
  ok(tap(scr, keys, "a") == nil and scr.child and vm:rd8(0xCC47) == 7
    and vm:rd8(0xCD81) == 0x19, "A on rings opens the entry")
  ok(tap(scr, keys, "b") == nil and scr.child and vm:rd8(0xCD81) == 2, "first rings B stays on the label")
  ok(tap(scr, keys, "b") == nil and scr.child == nil and vm:rd8(0xCD81) == 0, "second rings B returns")
  tap(scr, keys, "down")
  tap(scr, keys, "down")
  tap(scr, keys, "down")
  tap(scr, keys, "a")
  ok(scr.child and scr.child.spec.mode == 4, "A on items opens the item list")
  ok(tap(scr, keys, "b") == nil and scr.child and vm:rd8(0xCD81) == 3, "first item B stays")
  ok(tap(scr, keys, "b") == nil and scr.child == nil and vm:rd8(0xCD81) == 0, "second item B returns")
  tap(scr, keys, "down"); tap(scr, keys, "down"); tap(scr, keys, "down"); tap(scr, keys, "down")
  ok(scr.mach.cd81 == 4, "four downs reach glyph")
  ok(tap(scr, keys, "a") == nil and scr.child == nil and vm:rd8(0xCC47) == 5, "glyph A does nothing")
  local closed = tap(scr, keys, "start")
  ok(closed and closed.action == "close", "Start closes from the top menu")
end

do
  local vm, ctx, keys = fresh()
  vm:wr8(0xA3A8, 4); vm:wr8(0xA3AA, 7)
  local scr = Items.new(ctx)
  local row = scr.mach.rows[1]
  ok(row.id == 1 and row.count == 4 and row.glyphs:byte(1) == 0x41, "first item row")
  ok(scr.mach.rows[2].id == 3 and scr.mach.rows[2].count == 7
    and scr.mach.rows[2].glyphs:byte(1) == 0x43, "second item row")
  ok(scr.mach.rows[3].count == 0, "a padded row has a zero count")
  ok(not scr.mach.showAbove and not scr.mach.showBelow, "two items hide both arrows")
  ok(vm:rd8(0xCC82) == 0xA7 and vm:rd8(0xCC83) == 0xA3, "item base is stored")
  ok(vm:rd8(0xCC87) == 0x0D and vm:rd8(0xCC88) == 0x22, "item scale bytes")
  ok(tap(scr, keys, "down") == nil and scr.mach.cd81 == 0x0E and scr.mach.row == 4, "item cursor steps")
  local home = Items.new(ctx)
  ok(tap(home, keys, "b") == nil and home.mach.cd81 == 3, "B from the first item moves to its label")
  local back = tap(home, keys, "b")
  ok(back and back.action == "back", "second B leaves the item screen")
end

do
  local vm, ctx, keys = fresh()
  for i = 1, 6 do vm:wr8(0xA3A7 + i, i) end
  local scr = Items.new(ctx)
  ok(scr.mach.showBelow and not scr.mach.showAbove, "six items show the lower arrow")
  ok(scr.mach.rows[1].id == 1 and scr.mach.rows[5].id == 5, "first page is the first five")
  for _ = 1, 5 do tap(scr, keys, "down") end
  ok(scr.mach.cd81 == 0x18, "down reaches the lower arrow")
  ok(tap(scr, keys, "a") == nil and scr.mach.rows[1].id == 6 and scr.mach.rows[1].count == 6,
    "the lower arrow advances one page")
  ok(scr.mach.showAbove and scr.mach.rows[1].glyphs:byte(1) == 0x46, "the new page shows its name")
  tap(scr, keys, "up")
  ok(scr.mach.cd81 == 0x17, "up reaches the upper arrow")
  ok(tap(scr, keys, "a") == nil and scr.mach.rows[1].id == 1, "the upper arrow returns")
end

do
  local vm, ctx, keys = fresh()
  vm:wr8(0xA5A5, 1)
  local scr = Spell.new(ctx)
  ok(scr.mach.rows[1].id == 0 and scr.mach.rows[1].count == 1
    and scr.mach.rows[1].glyphs:byte(1) == 0x42, "spell row uses its record")
  ok(vm:rd8(0xCC47) == 3 and vm:rd8(0xCD81) == 6, "spell homes on slot 6")
  ok(tap(scr, keys, "b") == nil and scr.mach.cd81 == 1, "spell B moves to the label slot")
  local back = tap(scr, keys, "b")
  ok(back and back.action == "back", "second spell B leaves")
end

do
  local vm, ctx, keys = fresh()
  vm:wr8(0xA3A8, 1)
  local scr = StartMenu.new(ctx)
  tap(scr, keys, "down"); tap(scr, keys, "down"); tap(scr, keys, "down")
  tap(scr, keys, "a")
  local closed = tap(scr, keys, "start")
  ok(closed and closed.action == "close", "Start inside items closes")
  ok(vm:rd8(0xC92C) == 0x0F, "that close restores the sound byte")
end

do
  local vm, ctx, keys = fresh()
  vm.saveFs = memfs()
  vm.sramBank = 2
  vm:wr8(0xCCA5, 1); vm:wr8(0xA4A6, 1)
  ctx.ow = { x = 4, y = 9 }
  local scr = StartMenu.new(ctx)
  tap(scr, keys, "right")
  ok(scr.mach.cd81 == 0x24 and scr.mach.col == 13 and scr.mach.row == 15, "right reaches save")
  tap(scr, keys, "down")
  ok(scr.mach.cd81 == 5, "down from save reaches list")
  ok(tap(scr, keys, "a") == nil and scr.child == nil and vm:rd8(0xCC47) == 5, "list A does nothing")
  tap(scr, keys, "up")
  ok(tap(scr, keys, "a") == nil and vm:rd8(0xCD80) == 1, "first save A only latches")
  ok(vm.saveFs.box[SaveFile.PATH] == nil, "the latch does not write")
  ok(tap(scr, keys, "start") == nil and vm:rd8(0xCD80) == 1, "Start is ignored while latched")
  ok(tap(scr, keys, "b") == nil and vm:rd8(0xCD80) == 0 and scr.mach.cd81 == 0x24,
    "B clears the latch and stays")
  tap(scr, keys, "a")
  local saved = tap(scr, keys, "a")
  ok(saved and saved.action == "save" and saved.wrote == true, "second A saves")
  ok(saved.bank == 0x22 and saved.ptr == 0x4127, "CCA5 set picks the other record")
  ok(vm:rd8(0xC714) == 0x22 and vm:rd8(0xC715) == 0x27 and vm:rd8(0xC716) == 0x41, "script pointer")
  ok(vm:rd8(0xC717) == 0x66 and vm:rd8(0xC718) == 0x0A, "script handler")
  ok(vm:rd8(0xA015) == 4 and vm:rd8(0xA016) == 9 and vm:rd8(0xA017) == 1, "cell and save mark")
  ok(#vm.saveFs.box[SaveFile.PATH] == SaveFile.BANK_SIZE * 4, "file is four banks")
  ok(vm:rd8(0xC92C) == 0x0F, "save leaves the menu sound state")
  ok(not StartMenu.canOpen(vm), "the planted pointer blocks a new open")
end

do
  local _, ctx, keys = fresh()
  local hid = StartMenu.new(ctx)
  ok(tap(hid, keys, "right") == nil and hid.mach.cd81 ~= 0x24, "CCA5 clear skips the save slot")
end

do
  local vm, ctx, keys = fresh()
  vm.saveFs = memfs()
  vm.sramBank = 2
  vm:wr8(0xCCA5, 1)
  ctx.ow = { x = 1, y = 2 }
  local scr = SaveScr.new(ctx)
  ok(scr.mach.cd81 == 0x24, "the save screen starts on the save slot")
  vm:wr8(0xCCA5, 0)
  tap(scr, keys, "a")
  local saved = tap(scr, keys, "a")
  ok(saved and saved.action == "save" and saved.bank == 0x12 and saved.ptr == 0x79D3,
    "CCA5 clear picks the field record")
  ok(vm:rd8(0xC716) == 0x79, "that record's high byte is stored")
  vm:wr8(0xCCA5, 1)
  local again = SaveScr.new(ctx)
  ok(tap(again, keys, "b") == nil and again.mach.cd81 == 0, "B on save moves to the first row")
  local cancel = tap(again, keys, "b")
  ok(cancel and cancel.action == "cancel", "B on the first row cancels")
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
      local ctx = { rom = real, vm = vm, input = input, log = {} }
      return StartMenu.new(ctx), keys, vm
    end
    local scr, keys, vm = live()
    ok(scr.mach.col == 1 and scr.mach.row == 12, "rom cursor home")
    tap(scr, keys, "down")
    ok(scr.mach.col == 1 and scr.mach.cd81 == 1, "rom one down stays in the column")
    tap(scr, keys, "a")
    ok(scr.child and scr.child.spec.mode == 3, "rom spell opens")
    scr, keys, vm = live()
    tap(scr, keys, "down"); tap(scr, keys, "down")
    tap(scr, keys, "a")
    ok(scr.child and vm:rd8(0xCC47) == 7 and vm:rd8(0xCD81) == 0x19, "rom rings A opens the entry")
    scr, keys, vm = live()
    tap(scr, keys, "down"); tap(scr, keys, "down"); tap(scr, keys, "down")
    tap(scr, keys, "a")
    ok(scr.child and scr.child.spec.mode == 4, "rom items open")
    ok(vm:rd8(0xCD81) == 0x0D, "rom item cursor homes")
  end
end

print(("mn_ui_startmenu: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
