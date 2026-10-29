-- SetupCommand4D (bank 6 $6DDF): A, A on a group row plants $C714 from the row's
-- bank-7 record (or the map fallback) and records the id and the player's cell at
-- $C724/$C725 for map checks. Made-up bytes only.
--   luajit tests/engine/mn_command4d_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Items = require("mn.ui.start.Items")
local Machine = require("mn.ui.start.Machine")

local SLOT, PAIR = 0x49EB, 0x493B
local patches = {}
local function put(off, s) patches[#patches + 1] = { off, s } end
local function slot(idx, col, row, right, left, up, down)
  put(MnRom.off(SLOT + idx * 8, 3), string.char(col, row, right, left, up, down, 0, 0))
end
local function pair(idx, ac, an, bc, bn)
  put(MnRom.off(PAIR + idx * 4, 3), string.char(ac, an, bc, bn))
end
slot(0x0D, 5, 3, 0, 0, 0x0D, 0x0E); pair(0x0D, 0x4D, 0x0D, 0x58, 0x03)
slot(0x0E, 5, 4, 0, 0, 0x0D, 0x0E); pair(0x0E, 0x4D, 0x0E, 0x58, 0x03)

-- bank-7 item records ($22 bytes from $5DFF + id * $22): name at +$0C, bank +$1C, script +$1D
local function record(id, nameByte, bank, ptr)
  local r = string.rep("\0", 12) .. string.char(nameByte):rep(13)
    .. string.rep("\0", 3) .. string.char(bank, ptr % 256, math.floor(ptr / 256)) .. string.rep("\0", 3)
  assert(#r == 0x22)
  put(MnRom.off(0x5DFF + id * 0x22, 7), r)
end
record(0x2A, 0x51, 0x00, 0x0000) -- no own script: the map fallback runs
record(0x2C, 0x52, 0x12, 0x4100) -- own script

-- a made-up map fallback in the $43 form the hidden-spot maps use: $C724 == $2A and
-- $C725 == $B0 enter 12:4100 (mark $C000 bit 6), else 12:4180 (mark $C001 bit 0)
put(MnRom.off(0x4000, 0x12), string.char(0x43, 0x08, 0x0F, 0x01, 0x24, 0xC7, 0x06, 0x2A, 0x00,
  0x0F, 0x01, 0x25, 0xC7, 0x06, 0xB0, 0x00, 0x12, 0x00, 0x41, 0x45, 0x12, 0x80, 0x41))
put(MnRom.off(0x4100, 0x12), string.char(0xAF, 0x00, 0xC0, 0x40, 0x42))
put(MnRom.off(0x4180, 0x12), string.char(0xAF, 0x01, 0xC0, 0x01, 0x42))

table.sort(patches, function(a, b) return a[1] < b[1] end)
local parts, at = {}, 0
for _, p in ipairs(patches) do
  if p[1] > at then parts[#parts + 1] = string.rep("\0", p[1] - at) end
  parts[#parts + 1] = p[2]; at = p[1] + #p[2]
end
parts[#parts + 1] = string.rep("\0", 0x200000 - at)
local rom = MnRom.new(table.concat(parts))

local function fresh(cell)
  local keys = {}
  local vm = VM.new(rom, {})
  vm:wr8(0xFFAB, 3)
  local ow = { def = { w = 3, h = 2, block = { 0, 0, 0, 0, cell, 0 } }, x = 1, y = 1 }
  local ctx = { rom = rom, vm = vm, ow = ow, log = {},
    input = function(k) if k == "dir" then return keys.dir end; return keys[k] end }
  return vm, ctx, keys
end
local function tap(scr, keys, btn)
  if btn == "down" then keys.dir = btn else keys[btn] = true end
  local r = scr:update()
  keys[btn] = nil; keys.dir = nil
  local r2 = scr:update()
  return r or r2
end

do -- fallback: item $2A on a $B0 cell
  local vm, ctx, keys = fresh(0xB0)
  vm:wr8(0xA3A7 + 0x2A, 1); vm:wr8(0xA3A7 + 0x2C, 2)
  vm:wr8(0xC9FF, 0x19); vm:wr8(0xCA00, 0xE0); vm:wr8(0xCA01, 0x4B)
  local scr = Items.new(ctx)
  ok(scr.mach.cd81 == 0x0D and scr.mach.rows[1].id == 0x2A, "first row is item $2A")
  ok(tap(scr, keys, "a") == nil and scr.mach.cd80 == 1, "first A latches")
  local r = tap(scr, keys, "a")
  ok(r and r.action == "use", "second A uses the row and leaves the menu")
  ok(r and r.bank == 0x19 and r.ptr == 0x4BE0 and r.id == 0x2A, "a zero record script takes the map fallback")
  ok(vm:rd8(0xC724) == 0x2A and vm:rd8(0xCCA3) == 0x2A, "$C724/$CCA3 hold the item id")
  ok(vm:rd8(0xC725) == 0xB0, "$C725 is the cell under the player")
  ok(vm:rd8(0xC723) == 3, "a row other than slot 4 sets $C723 to 3")
  ok(vm:rd8(0xC714) == 0x19 and vm:rd8(0xC715) == 0xE0 and vm:rd8(0xC716) == 0x4B
    and vm:rd8(0xC717) == 0x66 and vm:rd8(0xC718) == 0x0A, "$C714 holds the planted record")
  local src = 0x5DFF + 0x2A * 0x22
  ok(vm:rd8(0xCD8D) == src % 256 and vm:rd8(0xCD8E) == math.floor(src / 256), "$CD8D is the record address")
  ok(vm:rd8(0xC93D) == 0x49 and vm:rd8(0xC93E) == 0xC9, "$C93D points at the name copy")
  ok(vm:rd8(0xC949) == 0x51 and vm:rd8(0xC955) == 0x51 and vm:rd8(0xC956) == 0xFC, "13 name bytes then $FC")
end

do -- own script: second row, plain cell
  local vm, ctx, keys = fresh(0x00)
  vm:wr8(0xA3A7 + 0x2A, 1); vm:wr8(0xA3A7 + 0x2C, 2)
  vm:wr8(0xC9FF, 0x19); vm:wr8(0xCA00, 0xE0); vm:wr8(0xCA01, 0x4B)
  local scr = Items.new(ctx)
  tap(scr, keys, "down")
  ok(scr.mach.cd81 == 0x0E, "cursor on the second row")
  tap(scr, keys, "a")
  local r = tap(scr, keys, "a")
  ok(r and r.action == "use" and r.bank == 0x12 and r.ptr == 0x4100, "a record script wins over the fallback")
  ok(vm:rd8(0xC724) == 0x2C and vm:rd8(0xC725) == 0x00, "id $2C on a plain cell")
  ok(vm:rd8(0xC949) == 0x52, "the second record's name is copied")
end

do -- Mode6AfterCommand4D: ring entry byte swap and counts
  local vm, ctx = fresh(0)
  local m = Machine.boot(ctx)
  vm.sramBanks = nil
  vm:wr8(0xC727, 0); vm:wr8(0xCC4C, 1); vm:wr8(0xA119, 2)
  m.cca0 = 3
  local addr = 0xA022 + 2 * 0x25 + 3
  vm:wr8(addr, 5)
  vm:wr8(0xA019 + 5, 1); vm:wr8(0xA019 + 7, 4)
  vm:wr8(0xCCA3, 7)
  m:mode6AfterCommand4D()
  ok(m.cc47 == 7 and m.cc4b == 1 and m.cd81 == 0x1F, "mode 7, slot back from $CCA0")
  ok(vm:rd8(addr) == 7, "entry byte takes $CCA3")
  ok(vm:rd8(0xA019 + 5) == 2 and vm:rd8(0xA019 + 7) == 3, "old count up, new count down")
end

local function fallback(id, cell)
  local vm = VM.new(rom, {})
  vm:wr8(0xC724, id); vm:wr8(0xC725, cell)
  vm:start(0x12, 0x4000)
  for _ = 1, 4 do
    vm.wait = vm.wait and vm.wait - 1
    if not vm.wait or vm.wait <= 0 then vm.wait = nil; vm:resume() end
  end
  return vm:rd8(0xC000), vm:rd8(0xC001)
end
do
  local hit, miss = fallback(0x2A, 0xB0)
  ok(hit == 0x40 and miss == 0, "id $2A on a $B0 cell enters the hidden-spot script")
  hit, miss = fallback(0x2A, 0x00)
  ok(hit == 0 and miss == 1, "id $2A elsewhere takes the default")
  hit, miss = fallback(0x2C, 0xB0)
  ok(hit == 0 and miss == 1, "another id on the cell takes the default")
end

print(("mn_command4d_test: %d/%d"):format(checks - failures, checks))
if failures > 0 then os.exit(1) end
