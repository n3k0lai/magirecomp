-- $7C/$7D scroll nudge: NudgeCameraDeltas (bank 1 $4587) per frame, on made-up camera values.
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end }, graphics = {} } -- luacheck: ignore 111
local failures, checks = 0, 0
local function ok(c, w) checks = checks + 1; if not c then failures = failures + 1; print("FAIL " .. w) end end
local okLoad, Ow = pcall(require, "mn.Overworld")
ok(okLoad, "load mn.Overworld")
if okLoad then
  local function run(c, tc, tr, spd, mx, my)
    local n = 0
    while not Ow.nudgeStep(c, tc, tr, spd, mx or 1000, my or 1000) and n < 500 do n = n + 1 end
    return n
  end
  local c = { 0, 0 }
  local n = run(c, 2, 0, 3)
  ok(c[1] == 33 and c[2] == 0 and n == 11, "right: stops on the first frame cell 2 is reached (33 px, 11 frames)")
  c = { 80, 32 }
  run(c, 2, 2, 2)
  ok(c[1] == 46 and c[2] == 32, "left: stops as soon as cell 2 matches (46 px), not at 32")
  c = { 0, 0 }
  run(c, 0, 9, 9)
  ok(c[2] == 144, "speed clamped to 4 px per frame (36 frames x 4 = 144)")
  c = { 0, 0 }
  n = run(c, 20, 0, 2, 64, 0)
  ok(c[1] == 64 and n == 32, "right edge blocks the axis and finishes it")
  c = { 16, 16 }
  ok(Ow.nudgeStep(c, 1, 1, 2, 100, 100) and c[1] == 16, "already on the target cell: done, no move")
end
print(("mn_nudge: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
