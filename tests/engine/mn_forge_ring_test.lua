-- $8E CallBank4_5494ThenEnterScript (bank 4 $5494): the ring forge window.
-- Layout: full record (bank, ptr), cancel record (bank, ptr), u16 length, then a
-- list of that length (count, 8-byte entries led by the ring id). The forge NPC's
-- Forge choice (1E:7537) opens it; a pick stores the ring id in $C726 and runs on
-- past the list, where 1E:75EA checks $C726 for the story-13 ring.
-- It used to always enter the first record ("Ring Bank is full").
-- The run-on is the game's: CopyPrefixedBlockToD000 plants hScriptPtr one past the list
-- with handler $0A66 before the window opens, so when a forge leaves $CD49 = 1 and the
-- op returns, that pointer runs. A cancel leaves $CD49 = 0 and enters the cancel record.
-- A pick is paid for and recorded as in bank 4 (TryAffordOtherChoice $5A5B,
-- CommitOtherChoiceFive $5CB3, AddSRAMEntryForOperand $5D19). Made-up bytes only.
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

-- bank 4 $415B + id * $2D: made-up ring records, byte i = id + i
local function image(bytes)
  local b4 = {}
  for _, id in ipairs({ 0x2A, 0x2B }) do
    local off = MnRom.off(0x415B + id * 0x2D, 4)
    for i = 0, 0x2C do b4[off + i] = (id + i) % 256 end
  end
  local t = {}
  for i = 0, 0x12 * 0x4000 - 1 do t[#t + 1] = string.char(b4[i] or 0) end
  local s = table.concat(t) .. string.char(unpack(bytes))
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

local function run(pick, count, setup, entries)
  local vm = VM.new(image(entries or script()), { forge = function() return pick end })
  vm:wr8(0xA122, count or 0)
  vm:wr8(0xA025 + 2 * 0x25, 0xFF) -- entries 0 and 1 taken, entry 2 free
  for a = 0xA118, 0xA121 do vm:wr8(a, a < 0xA11B and 1 or 0xFF) end
  if setup then setup(vm) end
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

do -- the new SRAM ring entry and its $A118 slot (made-up record bytes id + i)
  local vm = run(0x2B, 3, function(v) v:wr8(0xCD50, 1) end) -- [$CD50] - 1 = no measure passes
  local e = 0xA025 + 2 * 0x25
  ok(vm:rd8(0xCD49) == 1 and vm:rd8(0xCD51) == 0x2B, "commit sets $CD49 and $CD51")
  ok(vm:rd8(0xCD56) == 2, "free entry index in $CD56")
  ok(vm:rd8(0xCD52) + vm:rd8(0xCD53) * 256 == e, "entry address in $CD52")
  local want = { [0] = 0x2B, 0x2B, 1, 0, 0, 0, 0, 0, 0x2C }
  for i = 0, 9 do want[9 + i] = 0x2B + 4 + i end
  want[19] = 0; want[20] = 0x2B + 14; want[21] = 0x2B + 15
  for i = 0, 11 do want[22 + i] = 0x2B + 18 + i end
  want[34], want[35], want[36] = 0, 0, 0
  for i = 0, 0x24 do
    if i ~= 5 and i ~= 6 then -- the measure word is SpendNewEntryMeasures' to keep
      ok(vm:rd8(e + i) == want[i], ("entry +%d = %02X, got %02X"):format(i, want[i], vm:rd8(e + i)))
    end
  end
  ok(vm:rd8(0xA11B) == 3, "first $FF id slot gets index + 1")
  ok(vm:rd8(0xA11C) == 0xFF, "only one id slot is written")
end

-- costs: entry $2A needs 300 animite, 2 of stock 5 and 1 of stock 9
local function costly()
  local b = script()
  b[12], b[13], b[14], b[15], b[16], b[17], b[18] = 5, 2, 9, 1, 0x2C, 0x01, 0
  return b
end

do -- an affordable pick pays animite and both stocks
  local vm = run(0x2A, 0, function(v)
    v:wr8(0xA3A5, 0x2C); v:wr8(0xA3A6, 0x01) -- exactly 300
    v:wr8(0xA4A6 + 5, 4); v:wr8(0xA4A6 + 9, 1)
  end, costly())
  ok(vm:rd8(0xC800) == 1, "an exact cost is affordable")
  ok(vm:rd8(0xA3A5) == 0 and vm:rd8(0xA3A6) == 0, "animite word paid")
  ok(vm:rd8(0xA4A6 + 5) == 2 and vm:rd8(0xA4A6 + 9) == 0, "both stocks paid")
  ok(vm:rd8(0xC726) == 0x2A and vm:rd8(0xA122) == 1, "commit stores the id and counts it")
end

for _, short in ipairs({ "animite", "stock A", "stock B" }) do
  local denied = {}
  local tries = 0
  local vm = VM.new(image(costly()), {
    forge = function() tries = tries + 1; if tries == 1 then return 0x2A end end,
    forgeDenied = function(id) denied[#denied + 1] = id end,
  })
  vm:wr8(0xA025 + 2 * 0x25, 0xFF)
  vm:wr8(0xA3A5, short == "animite" and 0x2B or 0x2C); vm:wr8(0xA3A6, 0x01)
  vm:wr8(0xA4A6 + 5, short == "stock A" and 1 or 2)
  vm:wr8(0xA4A6 + 9, short == "stock B" and 0 or 1)
  vm:start(0x12, 0x4000)
  ok(denied[1] == 0x2A, short .. ": short pick shows the unaffordable notice")
  ok(tries == 2, short .. ": the window stays open after the notice")
  ok(vm:rd8(0xC800) == 3, short .. ": then cancel enters the cancel record")
  ok(vm:rd8(0xA3A6) == 0x01 and vm:rd8(0xA122) == 0, short .. ": nothing is paid or counted")
end

do -- $2C (gift a ring): id and level count to $CD51/$CD50, then the same entry add
  local b = { 0x2C, 0x2A, 0x01, 0xAC, 0x00, 0xC8, 0x01, 0x94 }
  local vm = VM.new(image(b), {})
  vm:wr8(0xA025, 0xFF)
  for a = 0xA118, 0xA121 do vm:wr8(a, 0xFF) end
  vm:start(0x12, 0x4000)
  ok(vm:rd8(0xC800) == 1, "$2C runs on")
  ok(vm:rd8(0xCD51) == 0x2A and vm:rd8(0xCD50) == 1, "$2C stores its operands")
  ok(vm:rd8(0xA025) == 0x2A and vm:rd8(0xA027) == 1, "$2C writes the first free entry")
  ok(vm:rd8(0xA025 + 9) == 0x2A + 4, "$2C entry name bytes come from the bank-4 record")
  ok(vm:rd8(0xA118) == 1 and vm:rd8(0xA122) == 1 and vm:rd8(0xC726) == 0x2A, "$2C fills id slot, count, $C726")
  ok(not vm.logged[0x2C], "$2C is not logged as unimplemented")
end

do -- with a bank-1 SRAM image the entry goes there; the bank-0 bytes stay
  local b = { 0x2C, 0x2B, 0x01, 0x94 }
  local vm = VM.new(image(b), {})
  vm.sramBank = 0
  vm.sramBanks = { [1] = string.rep("\0", 0x25) .. string.rep("\255", 0x25) }
  vm:wr8(0xA025, 0x77)
  for a = 0xA118, 0xA121 do vm:wr8(a, 0xFF) end
  vm:start(0x12, 0x4000)
  local img = vm.sramBanks[1]
  ok(img:byte(0x25 + 1) == 0x2B and img:byte(0x25 + 3) == 1, "entry written to the bank-1 image")
  ok(img:byte(0x25 + 10) == 0x2B + 4, "bank-1 entry name bytes")
  ok(vm:rd8(0xA025) == 0x77, "bank-0 bytes at the entry address are put back")
  ok(vm:rd8(0xA118) == 1, "the id slot is in bank 0")
end

print(("mn_forge_ring_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
