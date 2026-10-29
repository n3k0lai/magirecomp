-- Battle exit, DispatchNonzeroD016 (02:6316): only a loss steps the palettes to white
-- ($20 passes, one channel unit a pass); a win or an escape goes straight to TurnOffLCD.
-- Stub state only, no ROM bytes.
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end }, graphics = {}, filesystem = {} } -- luacheck: ignore 111
local failures, checks = 0, 0
local function ok(c, w) checks = checks + 1; if not c then failures = failures + 1; print("FAIL " .. w) end end

local Battle = require("mn.Battle")
local Engine = require("mn.battle.Engine")

local function run(result)
  local b = setmetatable({ state = { items = {}, tonyEnergy = 5, m = setmetatable({}, { __index = function() return 0 end }) }, ow = {}, L = function() end }, { __index = Battle })
  local frames, seen = 0, {}
  local co = coroutine.create(function() b:finish(result) end)
  while coroutine.status(co) ~= "dead" do
    local okr, err = coroutine.resume(co); assert(okr, err)
    if coroutine.status(co) ~= "dead" then frames = frames + 1; seen[#seen + 1] = b.whiteAdd end
  end
  return frames, seen, b
end
local _ = Engine
local f, seen, b = run("loss")
ok(f == 0x20, "a loss takes $20 frames (got " .. f .. ")")
ok(math.abs(seen[1] - 1 / 31) < 1e-9 and math.abs(seen[31] - 1) < 1e-9 and seen[32] == 1, "one unit a pass, white from pass 31")
ok(b.result == "loss", "the result is kept")
f = run("win"); ok(f == 0, "a win does not fade")
f = run("run"); ok(f == 0, "an escape does not fade")

if failures == 0 then print(("ok %d checks"):format(checks)) else print(("%d FAIL / %d"):format(failures, checks)) end
os.exit(failures == 0 and 0 or 1)
