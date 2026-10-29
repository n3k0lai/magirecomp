-- FinishStartup's RunScriptLoop (run_script_record.asm) repeats the main record's passes
-- with no frame wait until wScriptDone, and the LCD stays off until then. A per-pass step
-- handler that counts $FFA6 down and rets (script_byte_countdown.asm $40,
-- queue_repeated_sprite_list.asm $4C, step_script_sprite_pointer_table.asm $4D,
-- repeat_two_script_bytes.asm $4E, queue_repeated_offset_sprite_list.asm $4F,
-- arm_copy_glyph_from_script.asm $6B) therefore costs no frame between $93 and the park.
-- Record threads step from MainLoop's FinishFrame only, so they keep their passes.
-- The same holds for handlers that end the pass (below).
-- Synthetic bytes only.
--   luajit tests/engine/mn_startup_passes_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

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

-- each script: one counted op, post C6F8 $09, park ($42)
local scripts = {
  { 0x40, "$40 countdown", { 0x40, 0x05 } },
  { 0x4C, "$4C repeated sprite list", { 0x4C, 0x03, 0x00, 0x00, 0x00, 0x50, 0x00 } },
  { 0x4D, "$4D sprite pointer table", { 0x4D, 0x02, 0x04, 0x00, 0x00, 0x00, 0x50 } },
  { 0x4E, "$4E repeat two bytes", { 0x4E, 0x06, 0x01, 0x00 } },
  { 0x4F, "$4F repeated offset sprite list", { 0x4F, 0x02, 0x01, 0x00, 0x00, 0x50, 0x00 } },
  { 0x6B, "$6B glyph copy", { 0x6B, 0x03, 0x12, 0x00, 0x48, 0x00, 0x82, 0x01 } },
}
local at = {}
for i, sc in ipairs(scripts) do
  local b = {}
  for _, v in ipairs(sc[3]) do b[#b + 1] = v end
  b[#b + 1] = 0x56; b[#b + 1] = 0x09; b[#b + 1] = 0x42
  at[0x4000 + 0x40 * i] = b
end
local rom = image(at)

for i, sc in ipairs(scripts) do
  local calls = {}
  local h = { glyphCopy = function(count) calls[#calls + 1] = count end }
  -- main record inside the startup loop: the passes run back to back
  local vm = VM.new(rom, h)
  vm.startupPending = true
  local live = vm:start(0x12, 0x4000 + 0x40 * i)
  ok(not live and vm:rd8(0xC6F8) == 0x09, sc[2] .. ": no frame while startup runs")
  ok(not vm.startupPending and vm:rd8(0xC6F3) == 1, sc[2] .. ": the park ends startup")
  if sc[1] == 0x6B then ok(#calls == 1 and calls[1] == 3, "$6B: the three tiles in one call") end
  -- after startup (LCD on) the same op still takes its passes
  local v2 = VM.new(rom, h)
  ok(v2:start(0x12, 0x4000 + 0x40 * i) and v2:rd8(0xC6F8) == 0, sc[2] .. ": with the LCD on it waits")
  -- a record thread during startup is not the main record: it keeps its passes
  local v3 = VM.new(rom, h)
  v3.startupPending = true
  v3:spawnThread(2, 0x12, 0x4000 + 0x40 * i)
  v3:tickThreads(false)
  ok(v3:rd8(0xC6F8) == 0 and v3.startupPending, sc[2] .. ": a record thread still waits")
end

-- Pass ends: a handler that plants INITIAL_SCRIPT_HANDLER (or DispatchScriptOpcode) and
-- rets ends the pass (plant_initial_script_handler.asm $48, opcode_13.asm $13,
-- store_script_word_at_a123.asm $A9, branch_bank1_on_script_byte.asm $91,
-- install_script_from_bc.asm $4A, write_script_bytes_across_wram_banks.asm $80 and
-- opcode_0d.asm $0D through Opcode03Continue). In the startup loop the next pass is
-- immediate.
local ends = {
  { "$48", { 0x48 } },
  { "$13", { 0x13, 0x00, 0x50 } },
  { "$A9", { 0xA9, 0x01, 0x00 } },
  { "$91", { 0x91, 0x01 } },
  { "$80", { 0x80, 0x00, 0x00, 0x00, 0xD0, 0x01, 0x02 } },
  { "$0D", { 0x0D, 0x00, 0x00, 0x00, 0xD0, 0x01, 0x02 } },
  { "$4A", { 0x4A, 0x12, 0x00, 0x48 } }, -- installs 12:4800 (post, park)
}
local at2 = { [0x4800] = { 0x56, 0x09, 0x42 } }
for i, e in ipairs(ends) do
  local b = {}
  for _, v in ipairs(e[2]) do b[#b + 1] = v end
  b[#b + 1] = 0x56; b[#b + 1] = 0x09; b[#b + 1] = 0x42
  at2[0x5000 + 0x40 * i] = b
end
local rom2 = image(at2)
for i, e in ipairs(ends) do
  local vm = VM.new(rom2, {})
  vm.startupPending = true
  local live = vm:start(0x12, 0x5000 + 0x40 * i)
  ok(not live and vm:rd8(0xC6F8) == 0x09 and not vm.startupPending, e[1] .. ": the next pass follows at once in the startup loop")
  local v2 = VM.new(rom2, {})
  ok(v2:start(0x12, 0x5000 + 0x40 * i) and v2:rd8(0xC6F8) == 0, e[1] .. ": with the LCD on the pass ends the frame")
  v2.wait = nil; v2:resume()
  ok(v2:rd8(0xC6F8) == 0x09, e[1] .. ": and the next op runs on the next pass")
end

-- $96 SaveScriptTripleToSRAM ends in `jp INITIAL_SCRIPT_HANDLER` ($0A66 is
-- DispatchScriptOpcode, save_script_triple.asm): the next op runs in the same pass,
-- with the LCD on or off.
do
  local rom3 = image({ [0x4000] = { 0x96, 0x12, 0x34, 0x56, 0x56, 0x09, 0x42 } })
  local vm = VM.new(rom3, {})
  vm:start(0x12, 0x4000)
  ok(vm:rd8(0xC6F8) == 0x09, "$96: the next op runs in the same pass")
  ok(vm:rd8(0xA012) == 0x12 and vm:rd8(0xA013) == 0x34 and vm:rd8(0xA014) == 0x56, "$96: saves bank and pointer")
  local v2 = VM.new(rom3, {})
  v2.startupPending = true
  ok(not v2:start(0x12, 0x4000) and v2:rd8(0xC6F8) == 0x09, "$96: same in the startup loop")
end

print(("mn_startup_passes: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
