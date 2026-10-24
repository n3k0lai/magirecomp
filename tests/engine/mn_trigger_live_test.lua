-- Step triggers follow the live list ($64's triggerPtr), not the importer's
-- cached first list: direction gate and destination map. Synthetic bytes.
--   luajit tests/engine/mn_trigger_live_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local World = require("mn.World")
ok(World.gate(1, 0, -1) and not World.gate(1, 0, 1), "kind 1 fires moving up only")
ok(World.gate(2, 0, 1) and not World.gate(2, 0, -1), "kind 2 fires moving down only")
ok(World.gate(3, 1, 0) and not World.gate(3, -1, 0), "kind 3 fires moving right only")
ok(World.gate(4, -1, 0) and not World.gate(4, 1, 0), "kind 4 fires moving left only")
ok(World.gate(0, 1, 0) and World.gate(5, 0, -1), "other kinds fire from any direction")

local okOw, Overworld = pcall(require, "mn.Overworld")
if okOw then
  local MnRom = require("mn.MnRom")
  -- bank $21 list at $4100: one entry {kind 4, bank $22, ptr $4200};
  -- 22:4200 is $65 with a bank-$4F map pointer for map 7.
  local bytes = {}
  local function put(off, ...) for i, v in ipairs({ ... }) do bytes[off + i - 1] = v end end
  put(0x21 * 0x4000 + 0x100, 1, 4, 0x22, 0x00, 0x42)
  local mp = 0x4000 + 7 * 15
  put(0x22 * 0x4000 + 0x200, 0x65, mp % 256, math.floor(mp / 256), 0x4F)
  local n = 0x23 * 0x4000
  local t = {}
  for i = 0, n - 1 do t[i + 1] = string.char(bytes[i] or 0) end
  local rom = setmetatable({ s = table.concat(t) }, MnRom)
  local fake = setmetatable({ triggerPtr = 0x4100, vm = { rom = rom } }, { __index = Overworld })
  ok(fake:triggerTo(0) == 7, "live entry 0 resolves to map 7")
  ok(fake:triggerTo(1) == nil, "an index past the live list has no destination")
  fake.triggerPtr = nil
  ok(fake:triggerTo(0) == nil, "no live list, no destination")
else
  print("skip Overworld part: " .. tostring(Overworld):sub(1, 80))
end

print(("mn_trigger_live: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
