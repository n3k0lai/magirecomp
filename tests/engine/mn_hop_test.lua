-- $01/$02 cell runs: CountCellRun (01:517C) and DispatchZeroStepCellRun's
-- gates. Synthetic map cells only.
--   luajit tests/engine/mn_hop_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local World = require("mn.World")

-- One 1x8 column, walked up from y = 7. col[1] is y = 0.
local function column(col)
  local block = {}
  for i = 1, #col do block[i] = col[i] end
  return { w = 1, h = #col, block = block }
end

-- Map 134's x = 25 seam at story $0E: 24 open, 25-26 $02, 27 open.
local seam = column({ 0x08, 0x08, 0x08, 0x00, 0x02, 0x02, 0x00, 0x08 })
local c, lx, ly = World.cellRun(seam, 0, 5, 0, -1, 2)
ok(c == 2 and lx == 0 and ly == 3, "two $02 cells then floor count 2, land on the floor")
ok(World.hop(seam, 0, 5, 0, -1, 2) == nil, "a run of two needs $C9A6 >= 3 (no boots: blocked)")
local hx, hy = World.hop(seam, 0, 5, 0, -1, 3)
ok(hx == 0 and hy == 3, "Agadon's Boots ($A3A3 = 3) hop the two-cell run")
ok(not World.walkable(0x02), "a $02 cell itself stays solid")

-- x = 24: three $02 cells. Count 3 needs $C9A6 >= 5 (the $02 layer walk).
local three = column({ 0x08, 0x08, 0x00, 0x02, 0x02, 0x02, 0x00, 0x08 })
ok(World.cellRun(three, 0, 5, 0, -1, 3) == 3, "three-cell run counts 3")
ok(World.hop(three, 0, 5, 0, -1, 4) == nil, "a run of three is not a hop")

-- A single cell hops with no item; $82 also ends the run.
local one = column({ 0x08, 0x08, 0x08, 0x08, 0x82, 0x01, 0x00, 0x08 })
local ox, oy = World.hop(one, 0, 5, 0, -1, 0)
ok(ox == 0 and oy == 4, "one $01 cell then $82 hops with $C9A6 = 0")

-- A wall after the run forces 3, so nothing hops.
local wall = column({ 0x08, 0x08, 0x08, 0x08, 0x08, 0x02, 0x00, 0x08 })
ok(World.cellRun(wall, 0, 5, 0, -1, 5) == 3, "a wall landing forces count 3")
ok(World.hop(wall, 0, 5, 0, -1, 5) == nil, "no hop onto a wall")

-- $C9A6 >= 4: $01 no longer continues a run (Plant5969WhenCellIs01 path).
local ones = column({ 0x08, 0x08, 0x08, 0x08, 0x00, 0x01, 0x00, 0x08 })
ok(World.cellRun(ones, 0, 5, 0, -1, 4) == 0, "$01 is not a run cell at $C9A6 >= 4")
ok(World.cellRun(ones, 0, 5, 0, -1, 3) == 1, "$01 is a run cell below 4")

-- Sideways uses the same count (DispatchZeroXStepCellRun, 01:522E).
local row = { w = 5, h = 1, block = { 0x00, 0x02, 0x02, 0x00, 0x08 } }
local rx = World.hop(row, 1, 0, 1, 0, 3)
ok(rx == 3, "right across two $02 cells with the boots")

print(("mn_hop_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
