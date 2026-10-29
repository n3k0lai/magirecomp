-- wLCDC ($C936, turn_off_lcd.asm / turn_on_lcd.asm) decides "LCD off" for $44
-- (skip_two_unless_lcd_off.asm), $A0-$A2 (ops/Flow) and $A3/$A4: TurnOffLCD writes 0,
-- TurnOnLCDIfOff writes $E3 only when it is 0. FinishStartup turns it off before
-- RunScriptLoop and on after it, so a startup script branches as in map setup.
-- LcdOffSetup (04:6346) wraps a map-setup record the same way. Synthetic bytes only.
--   luajit tests/engine/mn_wlcdc_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Overworld = require("mn.Overworld")

local function image(at)
  local t = {}
  for i = 1, 0x13 * 0x4000 do t[i] = 0 end
  for addr, bytes in pairs(at) do
    for i, v in ipairs(bytes) do t[0x12 * 0x4000 + addr - 0x4000 + i] = v end
  end
  local parts = {}
  for i = 1, #t, 4096 do parts[#parts + 1] = string.char(unpack(t, i, math.min(i + 4095, #t))) end
  local s = table.concat(parts)
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

local rom = image({
  -- $44 to 4010, else C6F8 = 09, park
  [0x4000] = { 0x44, 0x10, 0x40, 0x56, 0x09, 0x42 },
  [0x4010] = { 0x56, 0x0A, 0x42 },
  -- a setup record that ends without a park ($94 in map setup just returns)
  [0x4100] = { 0x56, 0x0B, 0x94 },
  -- $93 (FinishStartup) then the same $44
  [0x4020] = { 0x93, 0x44, 0x10, 0x40, 0x56, 0x09, 0x42 },
  -- $93, $A4: flag $A100 mask $01, reward 02/03, cell $D010; then C6F8 = 09, park
  [0x4040] = { 0x93, 0xA4, 0x00, 0xA1, 0x01, 0x02, 0x03, 0x10, 0xD0, 0x56, 0x09, 0x42 },
  -- $93, $A3: flag $A100 mask $02, script 12:4010, metatile $3C, cell $D020; then C6F8 = 09
  [0x4060] = { 0x93, 0xA3, 0x00, 0xA1, 0x02, 0x12, 0x10, 0x40, 0x3C, 0x20, 0xD0, 0x56, 0x09, 0x42 },
  -- $93, $A0: SRAM $A100 mask $04, script 12:4010, set $11, clear $22, cell $D030; then C6F8 = 09
  [0x4080] = { 0x93, 0xA0, 0x00, 0xA1, 0x04, 0x12, 0x10, 0x40, 0x11, 0x22, 0x30, 0xD0, 0x56, 0x09, 0x42 },
  -- $93, $A2: SRAM $A100 mask $08, script 12:4010, byte $5A, cell $D040; then C6F8 = 09
  [0x40C0] = { 0x93, 0xA2, 0x00, 0xA1, 0x08, 0x12, 0x10, 0x40, 0x5A, 0x40, 0xD0, 0x56, 0x09, 0x42 },
})

local function host(cells)
  return {
    setMetatile = function(a, v) cells[#cells + 1] = { a, v } end,
    giveReward = function() cells.reward = true; return true end,
    sound = function() end,
  }
end

do -- a fresh VM has the LCD on
  local vm = VM.new(rom, {})
  ok(vm:rd8(0xC936) == 0xE3 and not vm:lcdOff(), "VM.new: wLCDC = LCDC_PLAY")
  vm:start(0x12, 0x4000)
  ok(vm:rd8(0xC6F8) == 0x09, "$44 LCD on: skips the word")
end

do -- map setup (LcdOffSetup): off for the record, on again after
  local vm = VM.new(rom, {})
  vm:runInit(0x12, 0x4000)
  ok(vm:rd8(0xC6F8) == 0x0A, "$44 in map setup follows the word")
  ok(vm:rd8(0xC936) == 0xE3, "map setup ends with TurnOnLCDIfOff")
end

do -- FinishStartup: $44 inside RunScriptLoop follows the word; the park turns the LCD on
  local vm = VM.new(rom, {})
  local seen
  vm.host.lcdOff = function() seen = vm:rd8(0xC936) end
  vm:start(0x12, 0x4020)
  ok(seen == 0, "$93 writes wLCDC = 0 before host.lcdOff")
  ok(vm:rd8(0xC6F8) == 0x0A, "$44 in the startup loop follows the word (LCD off)")
  ok(vm:rd8(0xC936) == 0xE3 and not vm.startupPending and vm:rd8(0xC6F3) == 1, "the park: C6F3 = 1, TurnOnLCD")
end

do -- a map-setup record run inside the startup loop leaves the LCD off
  local vm = VM.new(rom, {})
  vm.startupPending = true; vm:wr8(0xC936, 0)
  vm:runInit(0x12, 0x4100)
  ok(vm:rd8(0xC6F8) == 0x0B and vm.startupPending, "the setup record ran; startup still pending")
  ok(vm:rd8(0xC936) == 0 and vm:lcdOff(), "runInit in startup: wLCDC stays 0")
end

do -- the Overworld view of the LCD reads the same byte
  local vm = VM.new(rom, {})
  ok(Overworld.lcdOn({ vm = vm }), "lcdOn with wLCDC $E3")
  vm:wr8(0xC936, 0)
  ok(not Overworld.lcdOn({ vm = vm }), "lcdOn false with wLCDC 0")
end

do -- $A4 in the startup loop: LCD-off branch (flag set -> cell $FF, continue; clear -> park)
  local cells = {}
  local vm = VM.new(rom, host(cells)); vm:wr8(0xA100, 0x01)
  vm:start(0x12, 0x4040)
  ok(cells[1] and cells[1][1] == 0xD010 and cells[1][2] == 0xFF and vm:rd8(0xC6F8) == 0x09,
    "$A4 startup, flag set: cell := $FF and continue")
  ok(not cells.reward, "$A4 startup: no reward (the LCD-on path)")
  cells = {}
  vm = VM.new(rom, host(cells))
  vm:start(0x12, 0x4040)
  ok(#cells == 0 and not cells.reward and vm:rd8(0xC6F8) ~= 0x09, "$A4 startup, flag clear: parks")
end

do -- $A3 in the startup loop: flag set stores the metatile and parks; clear parks
  local cells = {}
  local vm = VM.new(rom, host(cells)); vm:wr8(0xA100, 0x02)
  vm:start(0x12, 0x4060)
  ok(cells[1] and cells[1][1] == 0xD020 and cells[1][2] == 0x3C and vm:rd8(0xC6F8) ~= 0x0A,
    "$A3 startup, flag set: metatile stored, script not entered")
  cells = {}
  vm = VM.new(rom, host(cells))
  vm:start(0x12, 0x4060)
  ok(#cells == 0 and vm:rd8(0xA100) == 0 and vm:rd8(0xC6F8) ~= 0x09, "$A3 startup, flag clear: no OR, parks")
end

do -- $A0 in the startup loop: mask clear stores the clear byte, leaves SRAM, continues
  local cells = {}
  local vm = VM.new(rom, host(cells))
  vm:start(0x12, 0x4080)
  ok(vm:rd8(0xD030) == 0x22 and vm:rd8(0xA100) == 0 and vm:rd8(0xC6F8) == 0x09, "$A0 startup, mask clear: LCD-off path")
end

do -- $A2 in the startup loop: mask clear runs InstallParkedScript, no OR
  local cells = {}
  local vm = VM.new(rom, host(cells))
  vm:start(0x12, 0x40C0)
  ok(vm:rd8(0xA100) == 0 and vm:rd8(0xD040) == 0 and vm:rd8(0xC6F8) ~= 0x09, "$A2 startup, mask clear: parks, SRAM kept")
  ok(vm:rd8(0xC6F4) == 1, "$A2 ran InstallParkedScript")
end

print(("mn_wlcdc: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
