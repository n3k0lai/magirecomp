-- Route tooling: MN_PICK="bank:ptr" makes a $9C choice take the option whose record
-- targets that address. A "!" suffix takes it only once per VM: the forge menu
-- (1E:74EE) comes back after each ring, and the second visit must fall through to
-- the default so the route can leave ("1E:7537!").
--   luajit tests/engine/mn_pick_once_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

-- 12:4000 $9C two options: 0 -> 12:4020 (Done: C800 <- 02), 1 -> 12:4010 (Forge: C800 <- 01).
local function image()
  local b = { 0x9C, 0x02, 0x12, 0x20, 0x40, 0x12, 0x10, 0x40 }
  for i = #b + 1, 0x40 do b[i] = 0 end
  local function at(p, t) for i, v in ipairs(t) do b[p - 0x4000 + i] = v end end
  at(0x4010, { 0xAC, 0x00, 0xC8, 0x01, 0x94 })
  at(0x4020, { 0xAC, 0x00, 0xC8, 0x02, 0x94 })
  local s = string.rep("\0", 0x12 * 0x4000) .. string.char(unpack(b))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

local realGetenv = os.getenv
local function visits(pick, n)
  os.getenv = function(k) if k == "MN_PICK" then return pick end return realGetenv(k) end -- luacheck: ignore 122
  local vm, got = VM.new(image(), {}), {}
  for i = 1, n do vm:wr8(0xC800, 0); vm:start(0x12, 0x4000); got[i] = vm:rd8(0xC800) end
  os.getenv = realGetenv -- luacheck: ignore 122
  return got
end

do
  local g = visits("12:4010", 2)
  ok(g[1] == 1 and g[2] == 1, "a plain MN_PICK takes its option every time")
  g = visits("12:4010!", 3)
  ok(g[1] == 1, "a '!' pick takes its option the first time, got " .. g[1])
  ok(g[2] == 2 and g[3] == 2, "a '!' pick falls through to the default afterwards")
  g = visits("2B:43F0,12:4010!", 2)
  ok(g[1] == 1 and g[2] == 2, "'!' works inside a list")
  ok(visits(nil, 1)[1] == 2, "no MN_PICK takes the default option")
end

print(("mn_pick_once_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
