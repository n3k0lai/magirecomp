-- An A-list set before the map load in the same script run survives the load;
-- a list left over from an earlier map does not. No ROM needed.
--   luajit tests/engine/mn_alist_order_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local okOw, Overworld = pcall(require, "mn.Overworld")
if okOw then
  local function fake() return setmetatable({}, { __index = Overworld }) end
  local function set(ow, p) ow.aList = p; ow.aListCo = coroutine.running() or true end

  -- same run: list first, then the load (map 19's order)
  local a = fake()
  coroutine.wrap(function() set(a, 0x411B); a:settleAList() end)()
  ok(a.aList == 0x411B, "a list set earlier in the same run survives the load")
  ok(a.aListCo == nil, "the marker is consumed by the load")

  -- a later load from another run drops it
  coroutine.wrap(function() a:settleAList() end)()
  ok(a.aList == nil, "a later load from another run drops the old list")

  -- list set after the previous load, next door runs in a new coroutine
  local b = fake()
  coroutine.wrap(function() b:settleAList(); set(b, 0x4131) end)()
  ok(b.aList == 0x4131, "a list set after the load stays for that map")
  coroutine.wrap(function() b:settleAList() end)()
  ok(b.aList == nil, "the next map's load drops the stale list")

  -- no list at all
  local c = fake(); c:settleAList()
  ok(c.aList == nil and c.aListCo == nil, "nothing set, nothing kept")
else
  print("skip Overworld part: " .. tostring(Overworld):sub(1, 80))
end

print(("mn_alist_order: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
