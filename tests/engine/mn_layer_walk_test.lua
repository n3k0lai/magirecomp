-- $01 / $02 layer walks: the bank-1 gate writers (4ECB/4EC2/56C0/56B7) and
-- World.step's head-family switches. Synthetic map cells only.
--   luajit tests/engine/mn_layer_walk_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local World = require("mn.World")

local function grid(rows)
  local block, w = {}, #rows[1]
  for y = 1, #rows do for x = 1, w do block[#block + 1] = rows[y][x] end end
  return { w = w, h = #rows, block = block }
end

local function mem()
  local m = {}
  local p = { 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF }
  for i = 0, 7 do m[0xC12A + i] = p[i + 1] end
  return m
end

-- Gate writers.
local m = mem()
World.writeGates(m, "enter2")
ok(m[0xC12A] == 0xFF and m[0xC12C] == 0x00 and m[0xC12B] == 0xFF, "4ECB: $C12A=$FF, $C12C=0")
ok(World.walkable(0x02, m) and not World.walkable(0x00, m), "layer 2: $02 floor, $00 wall")
ok(not World.walkable(0x01, m), "layer 2: $01 stays solid ($C12B untouched)")
ok(World.walkable(0x03, m) and World.walkable(0xC1, m), "layer 2: $03 and >= $80 stay open")
World.writeGates(m, "exit2")
ok(m[0xC12A] == 0x00 and m[0xC12C] == 0xFF, "4EC2: back to the normal pattern")
World.writeGates(m, "enter1")
ok(m[0xC12A] == 0xFF and m[0xC12B] == 0x00, "56C0: $C12A=$FF, $C12B=0")
ok(World.walkable(0x01, m) and not World.walkable(0x00, m) and not World.walkable(0x02, m), "layer 1: only $01 is floor")
World.writeGates(m, "exit1")
ok(m[0xC12A] == 0x00 and m[0xC12B] == 0xFF, "56B7: back to the normal pattern")

-- A column walked down from y=0: floor, a $02 band of three, floor.
local col = grid({ { 0x00 }, { 0x02 }, { 0x02 }, { 0x02 }, { 0x00 }, { 0x08 } })
m = mem()
ok(World.step(col, 0, 0, 0, 1, nil, 4, m) == nil, "a run of three at $C9A6 = 4 is blocked")
local x, y, layer, how = World.step(col, 0, 0, 0, 1, nil, 5, m)
ok(x == 0 and y == 1 and layer == 2 and how == "enter", "$C9A6 >= 5 enters the $02 layer on the first band cell")
World.applyLayer(m, nil, 2)
x, y, layer, how = World.step(col, 0, 1, 0, 1, 2, 5, m)
ok(y == 2 and layer == 2 and how == "step", "the layer walks along $02")
x, y, layer, how = World.step(col, 0, 3, 0, 1, 2, 5, m)
ok(y == 4 and layer == nil and how == "exit", "a blocked step onto $00 leaves the layer onto it")
World.applyLayer(m, 2, layer)
ok(m[0xC12A] == 0 and m[0xC12C] == 0xFF, "the exit restores the gates")

-- A one-cell $02 band with a wall behind it: count 3, so a layer entry too.
local ledge = grid({ { 0x00 }, { 0x02 }, { 0x08 } })
m = mem()
ok(World.step(ledge, 0, 0, 0, 1, nil, 3, m) == nil, "$02 then a wall at $C9A6 < 5 is blocked")
x, y, layer = World.step(ledge, 0, 0, 0, 1, nil, 5, m)
ok(y == 1 and layer == 2, "$02 then a wall at $C9A6 >= 5 enters the layer")
World.applyLayer(m, nil, 2)
x, y, layer, how = World.step(ledge, 0, 1, 0, 1, 2, 5, m)
ok(x == nil and layer == 2 and how == "bump", "a wall inside the layer bumps and stays")
x, y, layer, how = World.step(ledge, 0, 1, 0, -1, 2, 5, m)
ok(y == 0 and layer == nil and how == "exit", "turning back onto $00 leaves the layer")

-- Hops still win over the layer: a run of one landing on $00.
local gap = grid({ { 0x00 }, { 0x02 }, { 0x00 } })
x, y, layer, how = World.step(gap, 0, 0, 0, 1, nil, 5, mem())
ok(y == 2 and layer == nil and how == "hop", "a one-cell gap hops even at $C9A6 >= 5")

-- The $01 layer: a row walked right.
local row = grid({ { 0x00, 0x01, 0x01, 0x00, 0x08 } })
m = mem()
x, y, layer, how = World.step(row, 0, 0, 1, 0, nil, 3, m)
ok(x == 3 and how == "hop", "below $C9A6 4 a run of two $01 is a boots hop")
ok(World.step(row, 0, 0, 1, 0, nil, 2, m) == nil, "and needs $C9A6 >= 3")
row = grid({ { 0x00, 0x01, 0x01, 0x01, 0x00 } })
ok(World.step(row, 0, 0, 1, 0, nil, 3, m) == nil, "three $01 below $C9A6 4 is count 3: blocked")
x, y, layer, how = World.step(row, 0, 0, 1, 0, nil, 4, m)
ok(x == 1 and layer == 1 and how == "enter", "$C9A6 >= 4: a blocked $01 plants the $01 layer")
World.applyLayer(m, nil, 1)
x, y, layer = World.step(row, 1, 0, 1, 0, 1, 4, m)
ok(x == 2 and layer == 1, "the $01 layer walks along $01")
x, y, layer, how = World.step(row, 3, 0, 1, 0, 1, 4, m)
ok(x == 4 and layer == nil and how == "exit", "a blocked step onto $00 leaves the $01 layer")
local stuck = grid({ { 0x01, 0x08 } })
x, y, layer, how = World.step(stuck, 0, 0, 1, 0, 1, 4, m)
ok(x == nil and layer == 1 and how == nil, "a wall in the $01 layer commits without a bump")

print(("mn_layer_walk_test: %d/%d checks passed"):format(checks - failures, checks))
if failures > 0 then os.exit(1) end
