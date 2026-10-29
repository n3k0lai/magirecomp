-- $30 -> 07:584A -> 07:56ED FillTilemapRect22x20 (mn.Spiral): the wipe holds the
-- record until its last block; MN_ROM adds the real block order (11x10 spiral).
--   luajit tests/engine/mn_spiral_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Spiral = require("mn.Spiral")

local function image(at)
  local t = {}
  for i = 1, 0x13 * 0x4000 do t[i] = 0 end
  for addr, bytes in pairs(at) do
    local bank, a = addr[1], addr[2]
    for i, v in ipairs(bytes) do t[bank * 0x4000 + a - 0x4000 + i] = v end
  end
  local parts = {}
  for i = 1, #t, 4096 do parts[#parts + 1] = string.char(unpack(t, i, math.min(i + 4095, #t))) end
  local s = table.concat(parts)
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- made-up 07:56FD call list: first block, right, down, left
local rom = image({
  [{ 0x07, 0x56FD }] = { 0xCD, 0x6E, 0x56, 0xCD, 0xB1, 0x56, 0xCD, 0xCF, 0x56, 0xCD, 0xC0, 0x56, 0xC3 },
  [{ 0x12, 0x4000 }] = { 0x30, 0xED, 0x56, 0xFF, 0x56, 0x05, 0x42 },
})
local o = Spiral.order(rom)
ok(o and #o == 4, "order: one block per call")
ok(o and o[2][1] == 1 and o[3][2] == 1 and o[4][1] == 0 and o[4][2] == 1, "order: right, down, left")

local held = 0
local vm = VM.new(rom, {
  spiral = function() for _ = 1, 3 do held = held + 1; coroutine.yield("wait", 1) end end,
})
vm:spawnThread(2, 0x12, 0x4000)
for _ = 1, 3 do vm:tickThreads(false) end
ok(vm:rd8(0xC840) == 0xED and vm:rd8(0xC841) == 0x56, "$30 stores $C840/$C841")
ok(held == 3 and vm:rd8(0xC6F8) == 0, "the wipe holds the record")
vm:tickThreads(false)
ok(vm:rd8(0xC6F8) == 5, "the record goes on after the wipe")

local path = os.getenv("MN_ROM")
local f = path and io.open(path, "rb")
if f then
  local real = MnRom.new(f:read("*a")); f:close()
  local t = Spiral.order(real)
  ok(t and #t == 110, "ROM: 110 blocks")
  local seen, dup = {}, false
  for _, c in ipairs(t or {}) do
    local k = c[2] * 11 + c[1]
    if seen[k] or c[1] < 0 or c[1] > 10 or c[2] < 0 or c[2] > 9 then dup = true end
    seen[k] = true
  end
  ok(not dup, "ROM: each 2x2 block of the 22x20 rectangle once")
  ok(t and t[11][1] == 10 and t[11][2] == 0 and t[110][1] == 4 and t[110][2] == 5, "ROM: spiral corners")
end

print(("mn_spiral_test: %d/%d ok"):format(checks - failures, checks))
os.exit(failures == 0 and 0 or 1)
