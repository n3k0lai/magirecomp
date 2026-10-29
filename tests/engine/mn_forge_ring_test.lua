-- $8E CallBank4_5494ThenEnterScript (bank 4 $5494): the ring forge window.
-- Layout: full record (bank, ptr), cancel record (bank, ptr), u16 length, then a
-- list of that length (count, 8-byte entries led by the ring id). The forge NPC's
-- Forge choice (1E:7537) opens it; a pick stores the ring id in $C726 and runs on
-- past the list, where 1E:75EA checks $C726 for the story-13 ring.
-- It used to always enter the first record ("Ring Bank is full").
-- The run-on is the game's: CopyPrefixedBlockToD000 plants hScriptPtr one past the list
-- with handler $0A66 before the window opens, so when a forge leaves $CD49 = 1 and the
-- op returns, that pointer runs. A cancel leaves $CD49 = 0 and enters the cancel record.
--   luajit tests/engine/mn_forge_ring_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local function image(bytes)
  local s = string.rep("\0", 0x12 * 0x4000) .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- 12:4000 $8E (12:4040 full) (12:4050 cancel) len $0011, two rings $2A and $2B;
-- past the list: $AC C800 <- 01. 12:4040: C800 <- 02. 12:4050: C800 <- 03.
local function script()
  local b = { 0x8E, 0x12, 0x40, 0x40, 0x12, 0x50, 0x40, 0x11, 0x00, 0x02,
              0x2A, 0, 0, 0, 0, 0, 0, 0, 0x2B, 0, 0, 0, 0, 0, 0, 0,
              0xAC, 0x00, 0xC8, 0x01, 0x94 }
  local function at(p, t) for i, v in ipairs(t) do b[p - 0x4000 + i] = v end end
  for i = #b + 1, 0x60 do b[i] = 0 end
  at(0x4040, { 0xAC, 0x00, 0xC8, 0x02, 0x94 })
  at(0x4050, { 0xAC, 0x00, 0xC8, 0x03, 0x94 })
  return b
end

local function run(pick, count)
  local vm = VM.new(image(script()), { forge = function() return pick end })
  vm:wr8(0xA122, count or 0)
  vm:start(0x12, 0x4000)
  return vm
end

do -- a listed ring is forged: $C726 = id, $A122 counts it, the script goes on past the list
  local vm = run(0x2A, 3)
  ok(vm:rd8(0xC800) == 1, "forge pick continues past the list, got " .. vm:rd8(0xC800))
  ok(vm:rd8(0xC726) == 0x2A, "forge pick stores the ring id in $C726")
  ok(vm:rd8(0xA122) == 4, "forge pick counts the ring in $A122")
  ok(not vm.logged[0x8E], "$8E is not logged as unimplemented")
  ok(vm:rd8(0xCD49) == 1, "a forge leaves $CD49 = 1")
end

do -- no pick (or an unlisted id) enters the cancel record with $C726 = $FF
  local vm = run(nil)
  ok(vm:rd8(0xC800) == 3, "no pick enters the cancel record, got " .. vm:rd8(0xC800))
  ok(vm:rd8(0xC726) == 0xFF, "no pick leaves $C726 = $FF")
  ok(vm:rd8(0xCD49) == 0, "a cancel leaves $CD49 = 0")
  ok(run(0x55):rd8(0xC800) == 3, "an unlisted ring id cancels")
end

do -- a full ring bank ($A122 >= $D0) enters the first record and opens no window
  local vm = run(0x2A, 0xD0)
  ok(vm:rd8(0xC800) == 2, "a full ring bank enters the full record, got " .. vm:rd8(0xC800))
  ok(vm:rd8(0xC726) == 0, "a full ring bank leaves $C726 alone")
end

print(("mn_forge_ring_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
