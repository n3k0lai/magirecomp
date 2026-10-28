-- $05 refilling the record whose own script is running: the planted script runs in
-- the slot and the planting script carries on (Valkan 28:711A -> 12:7367 plants
-- slot 2 with 12:74FC, then 12:73F7 waits for C6F9 $0A; map 135 stall).
-- Synthetic bytes only.
--   luajit tests/engine/mn_record_carry_test.lua
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

-- slot 2 at 12:4000: $05 slot 2 (script field 12:4100), $94, wait C6F9 $0A, post C6FC $0B, park
-- 12:4100 (the new record script): post C6F8 $0A, park
local rom = image({
  [0x4000] = { 0x05, 0x02, 0x6B, 0x4A, 0x03, 0x04, 0x00, 0x00, 0x00, 0x12, 0x00, 0x41, 0x00, 0x00, 0x00,
    0x94, 0x60, 0x0A, 0x58, 0x0B, 0x42 },
  [0x4100] = { 0x56, 0x0A, 0x42 },
})
local h, vm = {}, nil
function h.spawn(slot, _, _, _, _, abank, aptr)
  -- Overworld's spawn: a non-sprite anim field is the record's script
  vm:spawnThread(slot, abank, aptr, true)
end
vm = VM.new(rom, h)
vm:spawnThread(2, 0x12, 0x4000)
for _ = 1, 30 do vm:tickThreads(false) end
ok(vm:rd8(0xC6F9) == 0x0A, "the planted record script ran in slot 2 and posted C6F8 $0A")
ok(vm:rd8(0xC6FD) == 0x0B, "the planting script carried on past its C6F9 $0A wait")
ok(vm.threads and vm.threads.carry2 == nil, "the carried thread ends when it parks")

-- without carry (other spawn paths) the slot's old script is replaced as before
local h2, vm2 = {}, nil
function h2.spawn(slot, _, _, _, _, abank, aptr) vm2:spawnThread(slot, abank, aptr) end
vm2 = VM.new(rom, h2)
vm2:spawnThread(2, 0x12, 0x4000)
for _ = 1, 30 do vm2:tickThreads(false) end
ok(vm2:rd8(0xC6FD) == 0x00, "a plain spawnThread still replaces the running slot script")

print(("mn_record_carry_test: %d/%d ok"):format(checks - failures, checks))
os.exit(failures == 0 and 0 or 1)
