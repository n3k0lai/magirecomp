-- Slot-record and map-plane opcodes. Synthetic bytes only.
--   luajit tests/engine/mn_ops_records_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Records = require("mn.ops.Records")

local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

local function world()
  local ow = {
    objects = {}, x = 3, y = 4, patches = {},
    def = { w = 8, h = 8, cells = {}, block = {} },
  }
  for i = 1, 64 do ow.def.cells[i] = 0x10; ow.def.block[i] = 0x20 end
  local h = { mapWidth = function() return ow.def.w end }
  function h.setCell(addr, col, mt)
    local i = addr - 0xD000
    ow.def.block[i + 1] = col
    ow.def.cells[i + 1] = mt
    ow.last = { addr, col, mt }
  end
  Records.host(ow, h)
  return ow, h
end

local function run(bytes, ow, h)
  local vm = VM.new(image(bytes), h)
  vm:start(0x12, 0x4000)
  local guard = 0
  while vm.co and guard < 16 do vm.wait = nil; vm:resume(); guard = guard + 1 end
  return vm
end

local function cell(ow, addr)
  local i = addr - 0xD000
  return ow.def.block[i + 1], ow.def.cells[i + 1]
end

-- $03 IndexedAddAndStore: pointer + word, bank 5 then bank 3. dx/dy do not move the slot.
do
  local ow, h = world()
  ow.objects[2] = { x = 4, y = 5, fineX = 1, fineY = 2, cellPtr = 0xD010, ptrSet = true, base = 9 }
  local vm = VM.new(image({ 0x03, 2, 0xFF, 0x01, 0x02, 0x00, 0x61, 0x62, 0x52, 0x05 }), h)
  vm:start(0x12, 0x4000)
  local col, mt = cell(ow, 0xD012)
  ok(col == 0x61 and mt == 0x62, "$03 writes collision then metatile at pointer+word")
  ok(ow.objects[2].x == 4 and ow.objects[2].y == 5, "$03 leaves the slot cell alone")
  ok(vm.co ~= nil and vm:rd8(0xC6F5) == 0, "$03 ends the burst before the next opcode")
  vm.wait = nil; vm:resume()
  ok(vm:rd8(0xC6F5) == 1 and vm:rd8(0xC6F6) == 0xFF and vm:rd8(0xC6F7) == 4, "$52 plants 01 FF and byte-1")
  ow.objects[1] = { x = 1, y = 1, cellPtr = 0xD008, ptrSet = true }
  local init = VM.new(image({ 0x03, 1, 0, 0, 0, 0, 0x01, 0x02, 0x52, 0x03 }), h)
  init:runInit(0x12, 0x4000)
  local c2, m2 = cell(ow, 0xD008)
  ok(c2 == 0x01 and m2 == 0x02 and init:rd8(0xC6F7) == 2, "$03 during map setup does not yield past the next opcode")
end

-- $0D uses the HRAM head. $0E patches the overlay from the same pointer.
do
  local ow, h = world()
  local vm = VM.new(image({ 0x0D, 0xFF, 0x00, 0x05, 0x00, 0x41, 0x42 }), h)
  vm:wr8(0xFF91, 4); vm:wr8(0xFF92, 9); vm:wr8(0xFF93, 0x10); vm:wr8(0xFF94, 0xD0)
  vm:start(0x12, 0x4000)
  local col, mt = cell(ow, 0xD015) -- 0xD010 + 5
  ok(col == 0x41 and mt == 0x42, "$0D stores at head pointer + word")
  ok(vm:rd8(0xFF91) == 4 and vm:rd8(0xFF92) == 9, "$0D does not rewrite the head cell")
  vm = VM.new(image({ 0x0E, 0x02, 0x00, 0x55, 0x66 }), h)
  vm:wr8(0xFF93, 0x20); vm:wr8(0xFF94, 0xD0)
  vm:start(0x12, 0x4000)
  ok(ow.ovCol and ow.ovCol[0x23] == 0x55 and ow.ovMt[0x23] == 0x66, "$0E writes banks 6 and 4")
  local lc, lm = cell(ow, 0xD022)
  ok(lc == 0x20 and lm == 0x10, "$0E does not touch the live planes")
end

-- $04 patches the overlay of a slot pointer. $7F blits a 2x2 window, one cell a frame.
do
  local ow, h = world()
  ow.objects[0x22] = { x = 0, y = 0, cellPtr = 0xD000, ptrSet = true }
  run({ 0x04, 0x22, 0x03, 0x00, 0x11, 0x22 }, ow, h)
  ok(ow.ovCol[4] == 0x11 and ow.ovMt[4] == 0x22, "$04 adds the word to the slot pointer on the overlay")
  local lc, lm = cell(ow, 0xD003)
  ok(lc == 0x20 and lm == 0x10, "$04 leaves the live cell")
  -- width 2, height 2, stride 8: src D000,D001 then D008,D009 -> dst D020
  ow.ovCol[1], ow.ovMt[1] = 0x01, 0xA1
  ow.ovCol[2], ow.ovMt[2] = 0x02, 0xA2
  ow.ovCol[9], ow.ovMt[9] = 0x03, 0xA3
  ow.ovCol[10], ow.ovMt[10] = 0x04, 0xA4
  local vm = VM.new(image({ 0x7F, 0x00, 0xD0, 2, 2, 0x20, 0xD0, 0x02, 0x03 }), h)
  vm:start(0x12, 0x4000)
  local c1, m1 = cell(ow, 0xD020)
  ok(c1 == 0x01 and m1 == 0xA1, "$7F copies the first overlay cell and waits")
  ok(vm:rd8(0xFFA7) == 2 and vm:rd8(0xC704) == 2 and vm:rd16(0xC6FE) == 0xD000, "$7F stages width, height and source")
  ok(vm:rd8(0xC702) == 0x02 and vm:rd8(0xC703) == 0x03, "$7F stages the row and column")
  ok(vm.co ~= nil, "$7F is not finished after one cell")
  vm.wait = nil; vm:resume()
  local _, m2 = cell(ow, 0xD021)
  ok(m2 == 0xA2, "$7F steps across the row")
  vm.wait = nil; vm:resume()
  local _, m3 = cell(ow, 0xD028)
  ok(m3 == 0xA3, "$7F adds stride-(width-1) on the next row")
  vm.wait = nil; vm:resume()
  local c4, m4 = cell(ow, 0xD029)
  ok(c4 == 0x04 and m4 == 0xA4, "$7F finishes the window")
end

-- $06 copies position and resets fine. $08 writes six bytes. $0A sets the tile base.
do
  local ow, h = world()
  ow.objects[1] = { x = 9, y = 8, fineX = 1, fineY = 2, cellPtr = 0xD099, ptrSet = true, base = 4 }
  ow.objects[2] = { x = 1, y = 1, fineX = 3, fineY = 3, cellPtr = 0xD001, ptrSet = true, base = 5 }
  run({ 0x06, 2, 1 }, ow, h)
  local d, s = ow.objects[2], ow.objects[1]
  ok(d.x == 9 and d.y == 8 and d.cellPtr == 0xD099 and d.fineX == 8 and d.fineY == 8, "$06 copies cell and pointer, fine = 8")
  ok(d.ox == 0 and d.oy == 0, "$06 snaps the sprite offset to fine 8")
  ok(s.x == 9 and s.fineX == 1, "$06 leaves the source record")
  run({ 0x08, 2, 0x0A, 0xFE, 0x06, 0x07, 0x40, 0xD0 }, ow, h)
  ok(d.fineX == 0x0A and d.fineY == 0xFE and d.x == 6 and d.y == 7 and d.cellPtr == 0xD040, "$08 writes six bytes at record+3")
  ok(d.oy == (0xFE - 256) - 8, "$08 signed fine Y moves the sprite offset")
  ow.objects[0] = { x = 1, y = 1, base = 0 }
  run({ 0x0A, 0x80, 0x3C }, ow, h)
  ok(ow.objects[0].base == 0x3C, "$0A index $80 wraps onto slot 0's tile base")
  run({ 0x0A, 2, 0x55 }, ow, h)
  ok(d.base == 0x55, "$0A stores record byte 9")
end

-- $0F / $17 / $18 head bytes. $10 queues the head word.
do
  local ow, h = world()
  ow.objects[4] = { x = 6, y = 7, fineX = 3, fineY = 4, cellPtr = 0xD066, ptrSet = true, base = 1 }
  ow.objects[5] = { x = 1, y = 1, fineX = 9, fineY = 9, cellPtr = 0xD001, ptrSet = true, base = 2 }
  local vm = run({ 0x0F, 4 }, ow, h)
  ok(vm:rd8(0xFF8F) == 8 and vm:rd8(0xFF90) == 8, "$0F forces fine X/Y to 8")
  ok(vm:rd8(0xFF91) == 6 and vm:rd8(0xFF92) == 7 and vm:rd16(0xFF93) == 0xD066, "$0F copies cell and pointer into the head")
  ok(ow.objects[4].fineX == 3 and ow.objects[4].x == 6, "$0F does not rewrite the source slot")
  ow.objects[5].x = 2
  vm = VM.new(image({ 0x17, 0x01, 0x02, 0x03, 0x04, 0x10, 0xD0 }), h)
  vm.curSlot = 5
  vm:start(0x12, 0x4000)
  ok(vm:rd8(0xFF8F) == 1 and vm:rd8(0xFF90) == 2 and vm:rd16(0xFF93) == 0xD010, "$17 stages six head bytes")
  ok(ow.objects[5].x == 3 and ow.objects[5].y == 4 and ow.objects[5].cellPtr == 0xD010, "$17 writeback moves curSlot")
  vm = VM.new(image({ 0x18, 0x2A }), h)
  vm.curSlot = 5
  vm:start(0x12, 0x4000)
  ok(vm:rd8(0xFF95) == 0x2A and ow.objects[5].base == 0x2A, "$18 stores hSpriteTileBase and the slot base")
  vm = run({ 0x10, 0x12, 0x34 }, ow, h)
  ok(vm:rd8(0xC186) == 0x12 and vm:rd8(0xC187) == 0x34, "$10 stores the head word")
end

-- $78 copies word pairs into the panel buffer. $81 writes the live planes.
do
  local ow, h = world()
  local bytes = { 0x78, 0x08, 0x40, 0x12, 0x20, 0, 0, 0 }
  local payload = { 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88 }
  for i = 1, 8 do bytes[8 + i] = payload[i] end
  local vm = VM.new(image(bytes), h)
  vm:start(0x12, 0x4000)
  ok(vm:rd8(0xC9D8) == 0x20 and vm:rd8(0xC9D9) == 4 and vm:rd16(0xC9DA) == 0xC73B, "$78 stages the panel row and the pair count")
  ok(vm:rd8(0xC73B) == 0x11 and vm:rd8(0xC73C) == 0x22 and vm:rd8(0xC741) == 0x77 and vm:rd8(0xC742) == 0x88, "$78 copies four word pairs from ROM")
  ok(vm.co ~= nil, "$78 ends the burst")
  vm = VM.new(image({ 0x81, 0x01, 0x02, 0x30, 0xD0, 0x0B, 0x0C }), h)
  vm:start(0x12, 0x4000)
  local col, mt = cell(ow, 0xD030)
  ok(col == 0x0B and mt == 0x0C, "$81 writes bank 5 then bank 3 at the address word")
  ok(vm.co ~= nil, "$81 ends the burst")
end

-- Slot 0 with no object is the player.
do
  local ow, h = world()
  run({ 0x08, 0, 8, 8, 6, 7, 0x40, 0xD0 }, ow, h)
  ok(ow.x == 6 and ow.y == 7 and ow.objects[0] == nil, "$08 on an empty slot 0 moves the player")
  local ob = h.slotRecord(0)
  ok(ob.cellPtr == 0xD040 and ob.x == 6, "$08 keeps the explicit cell pointer")
end

print(("mn_ops_records: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
