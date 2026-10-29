-- The headless planner's moves (World.gatesFor / World.moves): every cell one
-- press reaches, with the head family, so routes cross $01/$02 layer walks
-- the way World.step moves the player. Synthetic map cells only.
--   luajit tests/engine/mn_planner_layers_test.lua
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

local function mem(mark)
  local m = { [0xA3A3] = mark }
  local p = { 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF }
  for i = 0, 7 do m[0xC12A + i] = p[i + 1] end
  return m
end

-- BFS over (cell, family) with World.moves, as Boot's planners do.
local function route(def, sx, sy, tx, ty, m, layer)
  local n = def.w * def.h
  local gates, mark = World.gatesFor(m, layer), World.mark(m)
  local s0 = (layer or 0) * n + sy * def.w + sx
  local prev, q, h = { [s0] = -1 }, { { sx, sy, layer } }, 1
  while h <= #q do
    local c = q[h]; h = h + 1
    local id = (c[3] or 0) * n + c[2] * def.w + c[1]
    if c[3] ~= 2 and c[1] == tx and c[2] == ty then
      local path = {}
      while prev[id] ~= -1 do table.insert(path, 1, id); id = prev[id] end
      local cells = {}
      for i, k in ipairs(path) do local ck = k % n; cells[i] = { ck % def.w, math.floor(ck / def.w), math.floor(k / n) } end
      return cells
    end
    for _, mv in ipairs(World.moves(def, c[1], c[2], c[3], mark, gates)) do
      local k = (mv[3] or 0) * n + mv[2] * def.w + mv[1]
      if not prev[k] then prev[k] = id; q[#q + 1] = { mv[1], mv[2], mv[3] } end
    end
  end
end

-- gatesFor: one table per family, built from the live bytes, input untouched.
local m = mem(5)
local g = World.gatesFor(m, nil)
ok(g[0][0xC12A] == 0x00 and g[0][0xC12C] == 0xFF, "family 0 keeps the normal pattern")
ok(g[2][0xC12A] == 0xFF and g[2][0xC12C] == 0x00, "family 2 = 4ECB writes")
ok(g[1][0xC12A] == 0xFF and g[1][0xC12B] == 0x00, "family 1 = 56C0 writes")
ok(m[0xC12A] == 0x00 and m[0xC12C] == 0xFF, "gatesFor does not write the live bytes")
ok(g[0][0xC12E] == m[0xC12E] and g[2][0xC12E] == m[0xC12E] and g[1][0xC131] == m[0xC131], "colored gate bytes carry over unchanged")
local m2 = mem(5); World.applyLayer(m2, nil, 2)
local g2 = World.gatesFor(m2, 2)
ok(g2[0][0xC12A] == 0x00 and g2[0][0xC12C] == 0xFF, "from inside layer 2, family 0 = 4EC2 writes")

-- A $02 band of three between floor and goal, walled off otherwise.
local W8 = 0x08
local band = grid({
  { W8, W8, W8, W8, W8 },
  { 0x80, 0x02, 0x02, 0x02, 0x00 },
  { W8, W8, W8, W8, W8 },
})
ok(route(band, 0, 1, 4, 1, mem(4)) == nil, "$C9A6 = 4: the band of three is a wall, no route")
local r = route(band, 0, 1, 4, 1, mem(5))
ok(r and #r == 4, "$C9A6 = 5: four presses across the band")
ok(r and r[1][1] == 1 and r[1][3] == 2, "first press enters layer 2 on the first band cell")
ok(r and r[3][1] == 3 and r[3][3] == 2, "the layer walks along $02")
ok(r and r[4][1] == 4 and r[4][3] == 0, "the $00 cell past the band exits to the normal heads")
ok(route(band, 0, 1, 2, 1, mem(5)) == nil, "no goal mid-band: the $02 heads keep sliding")

-- A single $01 hops with no item; a pair needs $C9A6 >= 3. CountCellRun only
-- keeps the count when the run ends on $00 or $82.
local hop1 = grid({ { 0x80, 0x01, 0x00 } })
r = route(hop1, 0, 0, 2, 0, mem(0))
ok(r and #r == 1 and r[1][1] == 2 and r[1][3] == 0, "a run of one is one hop")
local hop2 = grid({ { 0x80, 0x01, 0x01, 0x82 } })
ok(route(hop2, 0, 0, 3, 0, mem(2)) == nil, "a run of two at $C9A6 = 2 is a wall")
ok(route(grid({ { 0x80, 0x01, 0x80 } }), 0, 0, 2, 0, mem(0)) == nil, "a run ending on $80 forces count 3: no hop")
r = route(hop2, 0, 0, 3, 0, mem(3))
ok(r and #r == 1, "a run of two at $C9A6 = 3 is one hop")

-- The $01 layer at $C9A6 >= 4 (Plant5969WhenCellIs01): enter, walk $01, exit on $00.
local one = grid({
  { W8, W8, W8, W8, W8 },
  { 0x80, 0x01, 0x01, 0x01, 0x00 },
  { W8, W8, W8, W8, W8 },
})
r = route(one, 0, 1, 4, 1, mem(4))
ok(r and r[1][3] == 1 and r[#r][1] == 4 and r[#r][3] == 0, "$01 band: enter layer 1, exit on $00")
-- Starting inside layer 1 the route stays on $01 floor until a $00.
r = route(one, 2, 1, 4, 1, (function() local mm = mem(4); World.applyLayer(mm, nil, 1); return mm end)(), 1)
ok(r and #r == 2 and r[2][3] == 0, "from inside layer 1: walk then exit")

print(("%d/%d checks passed  (planner routes $01/$02 layer walks)"):format(checks - failures, checks))
if failures > 0 then os.exit(1) end
