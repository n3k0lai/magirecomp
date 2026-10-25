-- Cell $82 grass countdown. Synthetic bytes only.
--   luajit tests/engine/mn_grass_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local bit = require("bit")
local ffi = require("ffi")
local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Grass = require("mn.Grass")

ffi.cdef[[ int setenv(const char *n, const char *v, int o); ]]
local function setenv(n, v) ffi.C.setenv(n, v, 1) end

-- Bank 1 table at $4100 (16 copies of the countdown byte). Bank 2 script
-- at $4000: opcode $AC stores one byte, opcode $12 parks the record.
local MARK, N = 0xC100, 5
local function rom()
  local s = string.rep("\0", 0x200000)
  local function poke(off, bytes)
    s = s:sub(1, off) .. bytes .. s:sub(off + #bytes + 1)
  end
  poke(MnRom.off(0x4100, 1), string.rep(string.char(N), 16))
  poke(MnRom.off(0x4000, 2), string.char(0xAC, 0x00, 0xC1, 0x5A, 0x12))
  return MnRom.new(s)
end

local ROM = rom()

local function plane(cell)
  local block = {}
  for i = 1, 9 do block[i] = cell end
  return { w = 3, h = 3, block = block }
end

local function world(cell)
  local vm = VM.new(ROM, {})
  vm:wr8(Grass.ENABLE, 1)
  vm:wr8(Grass.COUNT, 0xFF)
  vm:wr8(Grass.SCRIPT, 2)
  vm:wr8(Grass.SCRIPT + 1, 0x00)
  vm:wr8(Grass.SCRIPT + 2, 0x40)
  vm:wr8(Grass.TABLE, 0x00)
  vm:wr8(Grass.TABLE + 1, 0x41)
  local ow = {
    x = 1, y = 1, moving = true, def = plane(cell), vm = vm, log = {},
  }
  function ow:runScript(bank, ptr, why)
    self.why = why
    self.vm:start(bank, ptr)
  end
  return ow
end

-- D-pad walk head: StepCell82EveryFourthFrame. hMainLoopCounter ticks
-- when its low two bits are both set. Opcode $32 leaves the count at
-- $FF, so the first tick reloads N and does not decrement. N further
-- ticks reach 0, and the next tick stages the script. That is pass
-- 4 * (N + 2) - 1 from a counter that started at 0.
local FIRE = 4 * (N + 2) - 1

local function pass(ow)
  Grass.frame(ow)
  return Grass.walk(ow)
end

do
  local ow = world(Grass.CELL)
  for _ = 1, 3 do ok(pass(ow) == false, "reload pass does not start the script") end
  ok(ow.vm:rd8(Grass.COUNT) == N, "first tick loads the table byte")
  ok(ow.vm:rd8(MARK) == 0, "reload does not run the script")
  for _ = 4, FIRE - 1 do ok(pass(ow) == false, "countdown still running") end
  ok(ow.vm:rd8(MARK) == 0, "script has not fired yet")
  ok(ow.vm:rd8(Grass.COUNT) == 0, "the pass before the stage leaves the count at 0")
  ok(pass(ow) == true, "zero count starts the third script")
  ok(ow.why == "grass", "the walk reports a grass script")
  ok(ow.vm:rd8(MARK) == 0x5A, "the armed script stored its byte")
  ok(ow.vm:rd8(Grass.COUNT) == 0xFF, "staging reloads the count sentinel")
  ok(ow.vm:rd8(Grass.RECORD + 2) == 0 and ow.vm:rd8(Grass.RECORD) == 0, "the record is consumed when the script starts")
  ow.vm:wr8(MARK, 0)
  ok(pass(ow) == false and ow.vm:rd8(MARK) == 0, "the next pass only reloads the countdown")
  for _ = 1, FIRE do pass(ow) end
  ok(ow.vm:rd8(MARK) == 0x5A, "a second countdown fires again")
end

do
  local ow = world(0x00)
  for _ = 1, FIRE + 8 do pass(ow) end
  ok(ow.vm:rd8(MARK) == 0, "a floor cell never fires")
  ok(ow.vm:rd8(Grass.COUNT) == 0xFF, "a floor cell does not touch the count")
  ok(ow.why == nil, "a floor cell does not start a script")
end

do
  local ow = world(Grass.CELL)
  ow.vm:wr8(Grass.ENABLE, 0)
  for _ = 1, FIRE + 8 do ok(pass(ow) == false, "disabled countdown does not start") end
  ok(ow.vm:rd8(MARK) == 0, "$C6D8 clear never fires")
  ok(ow.vm:rd8(Grass.COUNT) == 0xFF, "$C6D8 clear does not reload")
end

-- B held: StepCell82OnEvenPass, even passes only, and only while moving.
do
  local ow = world(Grass.CELL)
  ow.bHeld = true
  local evenFire = 2 * (N + 2)
  for _ = 1, evenFire - 1 do ok(pass(ow) == false, "even-pass countdown still running") end
  ok(pass(ow) == true and ow.vm:rd8(MARK) == 0x5A, "even pass fires after the even-frame count")
end

do
  local ow = world(Grass.CELL)
  ow.bHeld = true
  ow.moving = false
  for _ = 1, FIRE + 8 do pass(ow) end
  ok(ow.vm:rd8(MARK) == 0, "B held with no pixel step never fires")
end

do
  local ow = world(Grass.CELL)
  setenv("MN_NOENC", "1")
  for _ = 1, FIRE do pass(ow) end
  setenv("MN_NOENC", "0")
  ok(ow.vm:rd8(MARK) == 0, "MN_NOENC does not run the grass script")
  ok(ow.why == nil, "MN_NOENC does not start a script")
  ok(ow.vm:rd8(Grass.RECORD + 2) == 0, "MN_NOENC consumes the record without running it")
end

if failures > 0 then print(failures .. " FAIL / " .. checks) else print("ok " .. checks) end
os.exit(failures > 0 and 1 or 0)
