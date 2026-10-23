-- Choice window ($8B DispatchArmedChoice / $8D ServiceWindowChoice).
-- Synthetic slot lists and SRAM bytes. A ROM-gated block checks the real
-- cursor record when MN_ROM is set, and prints nothing from the ROM.
--   luajit tests/engine/mn_ui_choice_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local quad = {}
love = { -- luacheck: ignore 111
  math = { random = function(a) return a or 0 end },
  filesystem = { read = function() return string.rep("\0", 262 * 64) end },
  image = { newImageData = function() return { setPixel = function() end } end },
  graphics = {
    setColor = function() end,
    draw = function() end,
    newQuad = function() return quad end,
    newImage = function() return { setFilter = function() end } end,
  },
}

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Travel = require("mn.ops.Travel")
local Choice = require("mn.ui.ChoiceWindow")

local function bytes(n)
  local t = {}
  for i = 1, n do t[i] = 0 end
  return t
end

local function poke(buf, off, data)
  for i = 1, #data do buf[off + i] = data[i] end
end

local function rec(col, row, right, left, up, down)
  return { col, row, right, left, up, down, 4, 5 }
end

local function layList(buf, ptr, rows)
  local off = MnRom.off(ptr, 3)
  local flat = {}
  for r = 1, #rows do
    for i = 1, 8 do flat[#flat + 1] = rows[r][i] end
  end
  poke(buf, off, flat)
end

local function testRom()
  local buf = bytes(0x200000)
  local tableOff = MnRom.off(0x4524, 3)
  poke(buf, tableOff + 7 * 2, { 0x00, 0x49 })
  poke(buf, tableOff + 8 * 2, { 0x00, 0x48 })
  local armed = {}
  for i = 1, 14 do armed[i] = rec(1, 3, 0, 0, 0, 0) end
  armed[1] = rec(1, 0x0E, 13, 13, 2, 1)
  armed[2] = rec(1, 0x0F, 13, 13, 0, 2)
  armed[3] = rec(1, 0x10, 13, 4, 1, 0) -- left targets an unmarked slot
  armed[14] = rec(0x0D, 0x0F, 1, 1, 0, 2)
  layList(buf, 0x4800, armed)
  local window = {}
  for i = 0, 12 do
    local down = i < 7 and i + 1 or (i == 7 and 8 or 1)
    local up = i > 0 and i - 1 or 1
    window[i + 1] = rec(1, 3 + i, down, 0, up, down)
  end
  window[9] = rec(8, 0x0B, 0, 7, 7, 0) -- record 8, the forward page
  layList(buf, 0x4900, window)
  local t = {}
  for i = 1, 0x200000 do t[i] = string.char(buf[i]) end
  return MnRom.new(table.concat(t))
end

local ROM = testRom()

local function screen(vm)
  return Choice.new({ rom = ROM, vm = vm, input = function() return nil end, log = {} })
end

local function press(scr, key)
  scr.ctx.input = function(kind)
    if kind == "dir" then
      if key == "up" or key == "down" or key == "left" or key == "right" then return key end
      return nil
    end
    return kind == key
  end
  return scr:update()
end

local function release(scr)
  scr.ctx.input = function() return nil end
  return scr:update()
end

local function tap(scr, key)
  local r = press(scr, key)
  if r then return r end
  return release(scr)
end

local function armedVm()
  local vm = VM.new(ROM, {})
  vm:wr8(0xCCB4, 8)
  vm:wr8(0xCCA9, 0xF3)
  vm:wr8(0xCCA7, 0xFF)
  vm:wr8(0xCCB9, 1)
  vm:wr8(0xCCBA, 0)
  vm:wr8(0xCCE3, 3)
  vm:wr8(0xCCB6, 0xD6); vm:wr8(0xCCB7, 0xCC)
  vm:wr8(0xCC42, 0x10)
  vm:wr8(0xCC43, 0xF2); vm:wr8(0xCC44, 0x52)
  vm:wr8(0xCC45, 0x60); vm:wr8(0xCC46, 0x88)
  return vm
end

-- Armed menu: down wraps the three marked rows, left into a zero mark stays.
do
  local vm = armedVm()
  local scr = screen(vm)
  ok(scr.kind == "armed" and scr.col == 1 and scr.row == 0x0E, "armed cursor starts on record 0")
  ok(vm:rd8(0xCD81) == 0 and vm:rd8(0xCCD6) == 1 and vm:rd8(0xCCD8) == 1, "seed plants three marks and slot 0")
  ok(vm:rd8(0xCCD9) == 0 and vm:rd8(0xCCE3) == 3, "seed leaves the cancel mark at CCE3")
  ok(press(scr, "down") == nil and scr.row == 0x0F and vm:rd8(0xCD81) == 1, "down moves to record 1")
  ok(press(scr, "down") == nil and vm:rd8(0xCD81) == 1, "a held down does not repeat")
  ok(release(scr) == nil and tap(scr, "down") == nil and vm:rd8(0xCD81) == 2, "down after release reaches record 2")
  ok(tap(scr, "left") == nil and vm:rd8(0xCD81) == 2, "a zero mark does not move the cursor")
  ok(tap(scr, "down") == nil and vm:rd8(0xCD81) == 0, "down from the last row wraps to record 0")
  local side = tap(scr, "right")
  ok(side == nil and vm:rd8(0xCD81) == 13 and scr.col == 0x0D, "right reaches the side slot")
end

-- A on records 0, 1, and 2 writes the PrepareChoice012 bytes. B and the
-- blank slot ($0D) store $FF the way the exit paths do.
do
  local vm = armedVm()
  local scr = screen(vm)
  tap(scr, "down")
  local r = press(scr, "a")
  ok(r and r.pick == 1 and r.cancelled == false, "A on record 1 returns that pick")
  ok(vm:rd8(0xCCA7) == 1 and vm:rd8(0xCCCB) == 1 and vm:rd8(0xCCD5) == 0, "A copies the slot into CCCB")
  ok(vm:rd8(0xCCFD) == 3 and vm:rd8(0xCCE9) == 0x0C and vm:rd8(0xCCE8) == 0x22, "choice 1 record shape")
  ok(vm:rd8(0xCCE6) == 0xF5 and vm:rd8(0xCCE7) == 0x6F, "choice 1 glyph pointer")
  ok(vm:rd8(0xCCE4) == 0xA5 and vm:rd8(0xCCE5) == 0xA5 and vm:rd8(0xCCEA) == 0x0D, "choice 1 list pointer")

  vm = armedVm(); scr = screen(vm)
  r = press(scr, "a")
  ok(r and r.pick == 0 and r.cancelled == false and vm:rd8(0xCCFD) == 0, "A on record 0 stores CCFD 0")
  ok(vm:rd8(0xCCE4) == 0xA7 and vm:rd8(0xCCE5) == 0xA3 and vm:rd8(0xCCE6) == 0xFF, "choice 0 pointers")

  vm = armedVm(); scr = screen(vm)
  tap(scr, "down"); tap(scr, "down")
  r = press(scr, "a")
  ok(r and r.pick == 2 and vm:rd8(0xCCFD) == 2 and vm:rd8(0xCCE9) == 0x06, "choice 2 stores CCFD 2")
  ok(vm:rd8(0xCCE8) == 0x13 and vm:rd8(0xCCE4) == 0x19 and vm:rd8(0xCCE5) == 0xA0, "choice 2 pointers")

  vm = armedVm(); scr = screen(vm)
  r = press(scr, "b")
  ok(r and r.pick == 0xFE and r.cancelled == true, "B cancels")
  ok(vm:rd8(0xCCA7) == 0xFE and vm:rd8(0xCCFC) == 0xFF and vm:rd8(0xCCFD) == 0xFF, "B stores FF at CCFC and CCFD")

  vm = armedVm(); scr = screen(vm)
  tap(scr, "right")
  r = press(scr, "a")
  ok(r and r.pick == 0x0D and r.cancelled == true, "the blank slot cancels")
  ok(vm:rd8(0xCCFC) == 0xFF and vm:rd8(0xCCFD) == 0xFF, "choice $0D blanks the result pair")
end

-- QueueBlinkSprite: hidden below $0F, shown through $1E, then the count wraps.
do
  local vm = armedVm()
  local scr = screen(vm)
  ok(scr.show == false and vm:rd8(0xCD7F) == 0, "the cursor starts hidden")
  for _ = 1, 15 do scr:update() end
  ok(vm:rd8(0xCD7F) == 15 and scr.show == true and scr.tile == 0x81, "the cursor shows at count $0F")
  ok(vm:rd8(0xCCA8) == 0x81, "the blink tile is $81")
  for _ = 1, 16 do scr:update() end
  ok(vm:rd8(0xCD7F) == 0 and scr.show == false, "the blink count wraps at $1F")
end

-- Window menu: page of SRAM pairs, cursor from record 1, A and B results.
do
  local vm = VM.new(ROM, {})
  vm:wr8(0xA122, 4)
  vm:wr8(0xC937, 2)
  vm:wr8(0xA025, 0x11); vm:wr8(0xA027, 0x22)
  vm:wr8(0xA04A, 0x33); vm:wr8(0xA04C, 0x44)
  Choice.demo(vm)
  ok(vm:rd8(0xCCB4) == 7 and vm:rd8(0xCD58) == 4 and vm:rd8(0xCCA7) == 0xFF, "demo stages the $8D slot")
  ok(vm:rd8(0xCC42) == 5 and vm:rd8(0xCC43) == 0xE0 and vm:rd8(0xC6E7) == 0xD0, "demo glyph pointers")
  ok(vm:rd8(0xCCB9) == 0 and vm:rd8(0xCD81) == 1 and vm:rd8(0xC728) == 0, "demo clears the cursors and arms id 1")
  local scr = screen(vm)
  ok(scr.kind == "window" and scr.col == 1 and scr.row == 4, "window cursor starts on record 1")
  ok(scr:update() == nil and scr.show == true and scr.tile == 0x82, "a zero CCB9 holds the cursor on")
  ok(vm:rd8(0xCD67) == 4 and vm:rd8(0xCD59) == 0x11 and vm:rd8(0xCD5A) == 0x22, "first SRAM pair")
  ok(vm:rd8(0xCD5B) == 0x33 and vm:rd8(0xCD5C) == 0x44, "second SRAM pair")
  ok(vm:rd8(0xCC4E) == 1 and vm:rd8(0xCC51) == 1 and vm:rd8(0xCC52) == 0, "four shown rows")
  ok(vm:rd8(0xCC4D) == 0 and vm:rd8(0xCC55) == 0, "first page, no further page")
  ok(tap(scr, "up") == nil and vm:rd8(0xCD81) == 1, "up into a zero mark stays")
  ok(tap(scr, "down") == nil and tap(scr, "down") == nil and vm:rd8(0xCD81) == 3, "down walks shown rows")
  local r = press(scr, "a")
  ok(r and r.pick == 3 and r.cancelled == false and vm:rd8(0xCD74) == 3, "A saves the slot at CD74")

  vm = VM.new(ROM, {})
  vm:wr8(0xA122, 4)
  Choice.demo(vm)
  scr = screen(vm)
  r = press(scr, "b")
  ok(r and r.pick == 0xFE and r.cancelled == true and vm:rd8(0xCD74) == 0xFE, "B saves FE at CD74")
  scr:draw()
end

-- Choice $08 pages forward while records remain, then the cursor returns to id 1.
do
  local vm = VM.new(ROM, {})
  vm:wr8(0xA122, 10)
  for i = 0, 9 do vm:wr8(0xA025 + i * 0x25, 0x40 + i) end
  Choice.demo(vm)
  local scr = screen(vm)
  ok(vm:rd8(0xCC55) == 1 and vm:rd8(0xCD67) == 7, "a long list sets the more mark")
  for _ = 1, 6 do tap(scr, "down") end
  ok(vm:rd8(0xCD81) == 7, "the seventh shown row is slot 7")
  tap(scr, "down")
  ok(vm:rd8(0xCD81) == 8, "down from the last row reaches the page slot")
  local r = press(scr, "a")
  ok(r == nil and vm:rd8(0xCCA7) == 0xFF and vm:rd8(0xCD81) == 1, "choice 8 stays open on the next page")
  ok(vm:rd8(0xCD57) == 7 and vm:rd8(0xCD59) == 0x47, "the next page starts at record 7")
end

-- Handlers open the overlay after staging, and skip it during map setup.
local function play(op, keys, prep, init)
  local vm
  local cur
  local opened = 0
  local function input(kind)
    if kind == "dir" then
      if cur == "up" or cur == "down" or cur == "left" or cur == "right" then return cur end
      return nil
    end
    return cur == kind
  end
  vm = VM.new(ROM, {
    uiContext = function() return { rom = ROM, vm = vm, input = input, log = {} } end,
    runOverlay = function(scr)
      opened = opened + 1
      local r
      for _, key in ipairs(keys) do
        cur = key
        r = scr:update()
        if r then return r end
        cur = nil
        r = scr:update()
        if r then return r end
      end
      return r
    end,
  })
  if prep then prep(vm) end
  if init then vm.init = true end
  local nx = Travel.handlers[op](vm, 100, 1)
  return vm, nx, opened
end

do
  local vm, nx, opened = play(0x8B, { "down", "a" })
  ok(nx == 101 and opened == 1, "$8B opens one window and continues")
  ok(vm:rd8(0xCC42) == 0x10 and vm:rd8(0xCCB4) == 8 and vm:rd8(0xCCE3) == 3, "$8B staging still lands")
  ok(vm:rd8(0xCCFD) == 3 and vm:rd8(0xCCA7) == 1, "$8B A on the second row stores choice 1")

  vm, nx, opened = play(0x8B, { "b" })
  ok(nx == 101 and opened == 1 and vm:rd8(0xCCFD) == 0xFF and vm:rd8(0xCCFC) == 0xFF, "$8B B stores the cancel pair")

  vm, nx, opened = play(0x8B, { "a" }, function(v) v:wr8(0xCD81, 5) end, true)
  ok(opened == 0 and nx == 101 and vm:rd8(0xCD81) == 5 and vm:rd8(0xCCFD) == 0, "$8B map setup does not open")

  vm, nx, opened = play(0x8D, { "down", "a" }, function(v)
    v:wr8(0xA122, 4); v:wr8(0xC937, 2)
  end)
  ok(opened == 1 and nx == 101 and vm:rd8(0xCD74) == 2, "$8D A saves the walked slot")
  ok(vm:rd8(0xCCB4) == 7 and vm:rd8(0xCD58) == 4 and vm:rd8(0xC6EB) == 1, "$8D staging still lands")

  vm, nx, opened = play(0x8D, { "b" }, nil, true)
  ok(nx == 101 and opened == 0 and vm:rd8(0xCD74) == 0 and vm:rd8(0xCCA7) == 0xFF, "$8D map setup leaves the wait byte")
end

local romPath = os.getenv("MN_ROM")
if romPath then
  local live = MnRom.fromFile(romPath)
  local vm = VM.new(live, {})
  vm:wr8(0xA122, 1)
  Choice.demo(vm)
  local scr = Choice.new({ rom = live, vm = vm, input = function() return nil end })
  ok(scr.col == 1 and scr.row == 3 and vm:rd8(0xCD88) == 4 and vm:rd8(0xCD89) == 5,
    "ROM window slot 1 is column 1 row 3, A confirms, B cancels")
  vm = VM.new(live, {})
  vm:wr8(0xCCB4, 8)
  vm:wr8(0xCCA7, 0xFF)
  vm:wr8(0xCCA9, 0xF3)
  vm:wr8(0xCCB9, 1)
  vm:wr8(0xCCE3, 3)
  vm:wr8(0xCCB6, 0xD6); vm:wr8(0xCCB7, 0xCC)
  vm:wr8(0xCC42, 0x10)
  vm:wr8(0xCC43, 0xF2); vm:wr8(0xCC44, 0x52)
  vm:wr8(0xCC45, 0x60); vm:wr8(0xCC46, 0x88)
  scr = Choice.new({ rom = live, vm = vm, input = function() return nil end })
  ok(scr.col == 1 and scr.row == 0x0E and vm:rd8(0xCD88) == 4, "ROM armed slot 0 is column 1 row $0E")
  scr:draw()
end

print(("mn_ui_choice: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
