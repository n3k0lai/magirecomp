-- List choice windows for opcodes $8C, $8F and $90. Synthetic bytes only.
--   luajit tests/engine/mn_ui_shop_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Travel = require("mn.ops.Travel")
local ListChoice = require("mn.ui.ListChoice")

local function romOf(bytes)
  return { u8 = function(_, o) return bytes[o] or 0 end }
end

local function fresh(bytes)
  return VM.new(romOf(bytes or {}), {})
end

local function ctx(vm)
  return { rom = vm.rom, vm = vm, input = function() end, log = {} }
end

local function screen(vm, mode)
  vm:wr8(0xCCA7, 0xFF)
  return ListChoice.new(ctx(vm), mode)
end

local function tap(scr, key)
  scr.ctx.input = function(kind)
    if kind == "dir" then
      if key == "up" or key == "down" or key == "left" or key == "right" then return key end
      return nil
    end
    return key == kind
  end
  local r = scr:update()
  scr.ctx.input = function() return nil end
  if not r then scr:update() end
  return r
end

local function wr16(vm, a, w)
  vm:wr8(a, w % 256); vm:wr8(a + 1, math.floor(w / 256))
end

local function rd16(vm, a)
  return vm:rd8(a) + vm:rd8(a + 1) * 256
end

local function toArrow(scr, vm)
  local guard = 0
  while vm:rd8(0xCD81) ~= 0x0C and guard < 10 do tap(scr, "down"); guard = guard + 1 end
  return guard
end

-- $8C: ten synthetic rows, scroll past the eighth, then back.
do
  local vm = fresh()
  local scr = ListChoice.new(ctx(vm), "8c")
  ok(vm:rd8(0xCD81) == 3, "$8C opens on the first row")
  ok(vm:rd8(0xCCCD) == 1 and vm:rd8(0xCCE2) == 1, "$8C first page id and more-below mark")
  ok(toArrow(scr, vm) == 8, "$8C eight downs reach the down arrow")
  ok(tap(scr, "a") == nil, "$8C scroll stays open")
  ok(vm:rd8(0xCCD5) == 8 and vm:rd8(0xCCCD) == 9, "$8C second page starts at the ninth row")
  ok(vm:rd8(0xCD81) == 0x0B and vm:rd8(0xCCE2) == 0 and vm:rd8(0xCCE1) == 1, "$8C last page sits on the up arrow")
  tap(scr, "a")
  ok(vm:rd8(0xCCD5) == 0 and vm:rd8(0xCD81) == 3 and vm:rd8(0xCCCD) == 1, "$8C up arrow returns to the first row")
end

-- $7751 / $7777 / $779D: the pair at row 12 and the pair at row 1.
do
  local vm = fresh()
  local scr = ListChoice.new(ctx(vm), "8c")
  ok(vm:rd8(0xCCEB) == 0x0B, "$8C arrow tile is the staged mark")
  ok(scr.over[0x9C29] == 0x80 and scr.over[0x9C2A] == 0x80, "$8C upper pair starts blank")
  ok(scr.over[0x9D89] == 0x0B and scr.over[0x9D8A] == 0x0B, "$8C lower pair is the more-below tile")
  toArrow(scr, vm)
  tap(scr, "a")
  ok(scr.over[0x9C29] == 0x0B and scr.over[0x9D89] == 0x80, "$8C last page flips the two pairs")
  tap(scr, "a")
  ok(scr.over[0x9C29] == 0x80 and scr.over[0x9D89] == 0x0B, "$8C first page restores the lower pair")
end

-- $8C: a pick commits and stays; a second pick requests the sound byte; B closes.
do
  local vm = fresh()
  local scr = ListChoice.new(ctx(vm), "8c")
  ok(tap(scr, "a") == nil, "$8C pick stays open")
  ok(vm:rd8(0xCCFC) == 1 and vm:rd8(0xCCCB) == 0, "$8C stores the picked id and clears the mode")
  ok(vm:rd8(0xC91F) == 0 and vm:rd8(0xC91E) == 1 and vm:rd8(0xC920) == 1, "$8C first pick sets the sound index only")
  ok(vm:rd8(0xC92A) == 0 and vm:rd8(0xC92C) == 0x0F, "$8C clears the select byte and sets $C92C")
  tap(scr, "down")
  tap(scr, "a")
  ok(vm:rd8(0xCCFC) == 2 and vm:rd8(0xC91F) == 1, "$8C second pick requests sound")
  local r = tap(scr, "b")
  ok(r and r.closed == "fe" and r.pick == 0xFE and r.mode == "8c", "$8C B closes")
end

local PRICE = MnRom.off(0x5AD7, 7)

local function sramShop(currency, stock)
  local bytes = {}
  bytes[PRICE + 3] = 10
  bytes[PRICE + 4] = 0
  bytes[PRICE + 5] = 2
  local vm = fresh(bytes)
  vm:wr8(0xA122, 1)
  vm:wr8(0x6D000, 1)
  vm:wr8(0x6D001, 4)
  vm:wr8(0xA025, 4)
  vm:wr8(0xA027, 1)
  wr16(vm, 0xA3A5, currency)
  vm:wr8(0xA4A6 + 4, stock)
  vm:wr8(0xCCCC, 1)
  vm:wr8(0xCCD5, 0)
  vm:wr8(0xCCE3, 3)
  vm:wr8(0xCCB4, 8)
  vm:wr8(0xCCB9, 1)
  vm:wr8(0xCD81, 3)
  return vm, screen(vm, "8f")
end

do
  local vm, scr = sramShop(20, 5)
  ok(vm:rd8(0xCCFE) == 10 and vm:rd8(0xCD00) == 2 and vm:rd8(0xCD17) == 1, "$8F stages cost, quantity and tier")
  ok(tap(scr, "a") == nil, "$8F buy stays open")
  ok(rd16(vm, 0xA3A5) == 10, "$8F buy subtracts the cost")
  ok(vm:rd8(0xA4A6 + 4) == 3, "$8F buy subtracts the quantity from stock")
  ok(vm:rd8(0xCD17) == 2 and vm:rd8(0xCD50) == 2, "$8F advances the tier and notes the bought record")
  ok(vm:rd8(0xC921) == 0, "$8F a covered buy does not deny")
  ok(vm:rd8(0xA027) == 2, "$8F one measure pass raises the rank byte")
  ok(vm:rd8(0xD389) % 2 == 1 and math.floor(vm:rd8(0xD389) / 2) % 2 == 0, "$8F $D389 keeps bit 0 set and bit 1 clear")
  ok(vm:rd8(0xA028) == 0 and vm:rd8(0xA029) == 0, "$8F the measure word stays put")
end

do
  local vm, scr = sramShop(5, 5)
  tap(scr, "a")
  ok(rd16(vm, 0xA3A5) == 5 and vm:rd8(0xA4A6 + 4) == 5 and vm:rd8(0xC921) == 2, "$8F too little currency denies")
  ok(scr.result == nil, "$8F deny stays open")
end

do
  local vm, scr = sramShop(100, 1)
  tap(scr, "a")
  ok(rd16(vm, 0xA3A5) == 100 and vm:rd8(0xA4A6 + 4) == 1 and vm:rd8(0xC921) == 2, "$8F short stock denies")
end

do
  local vm = fresh()
  local scr = ListChoice.new(ctx(vm), "8f")
  local r = tap(scr, "b")
  ok(r and r.closed == "fe" and r.mode == "8f", "$8F B closes")
end

local function shopVm(id, cap, price)
  local probe = fresh()
  local off = probe:recordOff(0, id)
  local bytes = {}
  bytes[off - 6] = cap
  bytes[off - 2] = price % 256
  bytes[off - 1] = math.floor(price / 256)
  return fresh(bytes)
end

local function stage90(vm, n, id, cost, currency, have)
  vm:wr8(0x6D000, n)
  for i = 0, n - 1 do
    local a = 0x6D001 + i * 3
    vm:wr8(a, id)
    vm:wr8(a + 1, cost % 256)
    vm:wr8(a + 2, math.floor(cost / 256))
  end
  wr16(vm, 0xA3A5, currency)
  vm:wr8(0xA3A7 + id, have)
  vm:wr8(0xCCCC, n)
  vm:wr8(0xCCC8, 8)
  vm:wr8(0xCCCB, 3)
  vm:wr8(0xCCE3, 3)
  vm:wr8(0xCD81, 0)
  vm:wr8(0xCCB4, 6)
  vm:wr8(0xCCB9, 1)
  wr16(vm, 0xCCE4, 0xA3A7)
end

do
  local vm = shopVm(1, 5, 4)
  stage90(vm, 1, 1, 10, 50, 0)
  local scr = screen(vm, "90")
  ok(tap(scr, "a") == nil and vm:rd8(0xCCCB) == 0 and vm:rd8(0xCD81) == 3, "$90 Buy enters the list")
  ok(tap(scr, "a") == nil, "$90 buy stays open")
  ok(vm:rd8(0xA3A7 + 1) == 1 and rd16(vm, 0xA3A5) == 40 and vm:rd8(0xC9FD) == 1, "$90 buy adds one and spends")
end

do
  local vm = shopVm(1, 5, 4)
  stage90(vm, 1, 1, 10, 50, 5)
  local scr = screen(vm, "90")
  tap(scr, "a"); tap(scr, "a")
  ok(vm:rd8(0xA3A7 + 1) == 5 and rd16(vm, 0xA3A5) == 50 and vm:rd8(0xC9FD) == 0 and vm:rd8(0xC921) == 2, "$90 full stack denies")
end

do
  local vm = shopVm(1, 5, 4)
  stage90(vm, 1, 1, 10, 1, 0)
  local scr = screen(vm, "90")
  tap(scr, "a"); tap(scr, "a")
  ok(vm:rd8(0xA3A7 + 1) == 0 and rd16(vm, 0xA3A5) == 1 and vm:rd8(0xC921) == 2, "$90 too little currency denies")
  ok(scr.result == nil, "$90 deny stays open")
end

do
  local vm = shopVm(1, 5, 4)
  stage90(vm, 1, 1, 10, 10, 2)
  local scr = screen(vm, "90")
  tap(scr, "down")
  ok(tap(scr, "a") == nil and vm:rd8(0xCCCB) == 1, "$90 Sell enters the owned list")
  ok(tap(scr, "a") == nil, "$90 sell stays open")
  ok(vm:rd8(0xA3A7 + 1) == 1 and rd16(vm, 0xA3A5) == 14, "$90 sell adds the record word and decrements")
end

do
  local vm = shopVm(1, 5, 0)
  stage90(vm, 1, 1, 10, 10, 2)
  local scr = screen(vm, "90")
  tap(scr, "down"); tap(scr, "a"); tap(scr, "a")
  ok(vm:rd8(0xA3A7 + 1) == 2 and rd16(vm, 0xA3A5) == 10 and vm:rd8(0xC921) == 2, "$90 a zero sell word denies")
end

do
  local vm = shopVm(1, 5, 4)
  stage90(vm, 1, 1, 10, 10, 1)
  local scr = screen(vm, "90")
  tap(scr, "down"); tap(scr, "a"); tap(scr, "a")
  ok(vm:rd8(0xA3A7 + 1) == 0 and vm:rd8(0xCCE3) == 3 and vm:rd8(0xCD81) == 0, "$90 selling the last one returns to the menu")
  ok(scr.result == nil, "$90 last sell stays open")
end

do
  local vm = shopVm(1, 5, 4)
  stage90(vm, 1, 1, 10, 10, 0)
  local scr = screen(vm, "90")
  tap(scr, "down"); tap(scr, "a")
  ok(vm:rd8(0xCCE3) == 3 and vm:rd8(0xCD81) == 0 and scr.result == nil, "$90 an empty sell list returns to the menu")
end

do
  local vm = shopVm(1, 5, 4)
  stage90(vm, 1, 1, 10, 50, 0)
  local scr = screen(vm, "90")
  tap(scr, "a")
  ok(tap(scr, "b") == nil and vm:rd8(0xCCE3) == 3 and vm:rd8(0xCD81) == 0, "$90 B in the list returns to the menu")
  local r = tap(scr, "b")
  ok(r and r.closed == "fe" and r.pick == 0xFE, "$90 B on the menu closes")
end

do
  local vm = shopVm(1, 5, 4)
  stage90(vm, 1, 1, 10, 50, 0)
  local scr = screen(vm, "90")
  tap(scr, "down"); tap(scr, "down")
  local r = tap(scr, "a")
  ok(r and r.closed == "done" and r.pick == 2, "$90 the third menu slot closes")
end

do
  local vm = fresh()
  local scr = ListChoice.new(ctx(vm), "90")
  tap(scr, "a")
  ok(toArrow(scr, vm) == 8, "$90 eight downs reach the down arrow")
  tap(scr, "a")
  ok(vm:rd8(0xCCD5) == 8 and vm:rd8(0xCCC8) == 16 and vm:rd8(0xCCCD) == 8, "$90 buy page steps by eight records")
  ok(vm:rd8(0xCD81) == 0x0B, "$90 last page sits on the up arrow")
  tap(scr, "a")
  ok(vm:rd8(0xCCD5) == 0 and vm:rd8(0xCD81) == 3, "$90 up arrow returns to the first record")
  ok(scr.over[0x9D89] == 0x04 and scr.over[0x9C29] == nil, "$90 first page keeps only the lower arrow")
  scr:draw()
end

-- $6CA8 / $76E0. A zero flag with a copied mark stays on the list.
do
  local vm = fresh()
  local scr = ListChoice.new(ctx(vm), "90")
  tap(scr, "a")
  vm:wr8(0xCCE3, 0)
  vm:wr8(0xCCD9, 1)
  ok(tap(scr, "b") == nil and vm:rd8(0xCCE3) == 1 and vm:rd8(0xCD81) == 3, "$90 B with a copied mark arms the first row")
  vm:wr8(0xCCE3, 0)
  for i = 0, 9 do vm:wr8(0xCCD9 + i, 0) end
  ok(tap(scr, "b") == nil and vm:rd8(0xCCE3) == 0, "$90 B with no copied mark stays on the zero flag")
end

-- Tilemap bytes are read from bank 3 at draw time. A planted corner stands in for the picture.
do
  local function plant(ptr)
    local bytes = {}
    bytes[MnRom.off(ptr, 3)] = 0x85
    bytes[MnRom.off(ptr, 3) + 20] = 0x84
    return bytes
  end
  local vm = fresh(plant(0x4B4B))
  local scr = ListChoice.new(ctx(vm), "90")
  ok(scr.over ~= nil, "$90 has a window map")
  local corner = scr.rom:u8(MnRom.off(0x4B4B, 3))
  ok(corner == 0x85, "$90 tilemap corner is the planted frame tile")
  vm = fresh(plant(0x4E1B))
  scr = ListChoice.new(ctx(vm), "8f")
  ok(scr.rom:u8(MnRom.off(0x4E1B, 3) + 20) == 0x84, "$8F tilemap reads the planted second row")
  vm = fresh(plant(0x4CB3))
  scr = ListChoice.new(ctx(vm), "8c")
  ok(scr.rom:u8(MnRom.off(0x4CB3, 3)) == 0x85, "$8C tilemap reads the planted corner")
  ok(scr.over[0x9DC2] == 0xEE and scr.over[0x9DEE] == 0x80, "$8C bottom strips are painted")
end

local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

local function runHandler(op, bytes, n, init, pump)
  local opened
  local h = {}
  local vm = VM.new(image(bytes), h)
  vm.init = init and true or false
  h.uiContext = function() return ctx(vm) end
  h.runOverlay = function(scr)
    opened = true
    if pump then return pump(scr) end
    scr.ctx.input = function(kind) return kind == "b" end
    return scr:update()
  end
  local o = MnRom.off(0x4000, 0x12)
  local back = Travel.handlers[op](vm, o, n)
  return vm, opened, back, o
end

do
  local payload = { 0x8C, 0x10, 0x00 }
  for i = 1, 16 do payload[#payload + 1] = i end
  local vm, opened, back, o = runHandler(0x8C, payload, 19, true)
  ok(not opened, "$8C during init does not open the window")
  ok(vm:rd8(0x6D000) == 1 and back == o + 19, "$8C init still copies the block and continues")
end

do
  local payload = { 0x8C, 0x10, 0x00 }
  for i = 1, 16 do payload[#payload + 1] = i end
  local vm, opened, back, o = runHandler(0x8C, payload, 19, false)
  ok(opened and back == o + 19, "$8C overlay runs and the script continues")
  ok(vm:rd8(0xCCFC) == 0, "$8C cancel does not commit an id")
end

do
  local vm, opened, back, o = runHandler(0x8F, { 0x8F, 0x03, 0x00, 0xAA, 0xBB, 0xCC }, 6, false)
  ok(opened and vm:rd8(0x6D000) == 0xAA and vm:rd8(0x6D002) == 0xCC, "$8F overlay keeps the staged block")
  ok(back == o + 6, "$8F continues after the block")
end

do
  local bytes = { 0x90, 0x00, 0x00, 0x00, 0x04, 0x00, 0x70, 0x01, 0x02, 0x00 }
  local vm, opened, back, o = runHandler(0x90, bytes, 10, false)
  ok(opened and vm:rd8(0x6D000) == 0x70 and vm:rd8(0xCCB4) == 6, "$90 overlay keeps the prefixed block")
  ok(back == o + 10, "$90 continues after the block")
  ok(vm:rd8(0xCCFC) == 0xFF and vm:rd8(0xCCFD) == 0xFF, "$90 B on the menu stores the exit pair")
end

do
  local h = {}
  local vm = VM.new(image({ 0x8C, 0x03, 0x00, 0x01, 0x02, 0x03 }), h)
  vm.init = false
  local o = MnRom.off(0x4000, 0x12)
  Travel.handlers[0x8C](vm, o, 6)
  ok(vm:rd8(0x6D000) == 1 and vm:rd8(0xCCA7) == 0xFF, "$8C with no overlay only stages")
end

if failures == 0 then print("ok " .. checks) else print(failures .. " failed of " .. checks) end
os.exit(failures == 0 and 0 or 1)
