-- While a script runs in slot 0 the pad does not move the player (map 25's
-- scene walks the player and would otherwise step back onto the exit trigger
-- and restart itself). No ROM needed.
--   luajit tests/engine/mn_slot0_input_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local okOw, Overworld = pcall(require, "mn.Overworld")
if okOw then
  local function fake(threads) return setmetatable({ vm = { threads = threads } }, { __index = Overworld }) end
  local live = coroutine.create(function() coroutine.yield() end); coroutine.resume(live)
  local dead = coroutine.create(function() end); coroutine.resume(dead)
  ok(fake({ [0] = { co = live } }):slot0Scripted(), "a live slot 0 thread holds the pad")
  ok(not fake({ [0] = { co = dead } }):slot0Scripted(), "a finished slot 0 thread frees the pad")
  ok(not fake({ [2] = { co = live } }):slot0Scripted(), "other slots do not hold the pad")
  ok(not fake(nil):slot0Scripted(), "no threads, no hold")
  ok(not setmetatable({}, { __index = Overworld }):slot0Scripted(), "no vm, no hold")
else
  print("skip Overworld part: " .. tostring(Overworld):sub(1, 80))
end

print(("mn_slot0_input: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
