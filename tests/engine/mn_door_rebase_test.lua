-- Door rebase (opcode_02.asm): new = old - lo + hi, applied by $00
-- (opcode_00_bank1.asm). A slot-0 $05 template must not replace a pair
-- that was computed before $65 loaded the destination (1A:6802 / 1A:6082).
--   luajit tests/engine/mn_door_rebase_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- Slot-0 FillScriptRecord0808 ($05, 14 operands) at cell tx,ty. Other fields are zeros.
local function slot0(tx, ty)
  return { 0x05, 0x00, 0x00, 0x00, tx, ty, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }
end

local function concat(parts)
  local t = {}
  for _, p in ipairs(parts) do
    if type(p) == "table" then for _, b in ipairs(p) do t[#t + 1] = b end else t[#t + 1] = p end
  end
  return t
end

-- Old map: rows at or below y=20 are walls (the 26 -> 15 rebase lands at y=27).
-- Destination: one wall at 1,1 (ringsmith shape). Everything else is floor.
local function world(startX, startY)
  local x, y, loaded = startX, startY, false
  local placed = {}
  local host = {
    playerCell = function() return x, y end,
    placePlayer = function(px, py)
      x, y = px, py
      placed[#placed + 1] = { px, py }
    end,
    cellOpen = function(cx, cy)
      if not loaded then return cy < 20 and cx >= 0 and cx < 32 end
      return not (cx == 1 and cy == 1)
    end,
    loadMap = function() loaded = true end,
    spawn = function() end,
    centerCamera = function() end,
  }
  return host, function() return x, y, placed, loaded end
end

local function run(bytes, x, y)
  local host, at = world(x, y)
  local vm = VM.new(image(bytes), host)
  vm:start(0x12, 0x4000)
  local px, py, placed, loaded = at()
  return px, py, placed, loaded, vm
end

local function rebase(px, py, loX, hiX, loY, hiY)
  return (px - loX + hiX) % 256, (py - loY + hiY) % 256
end

do
  local x, y = rebase(8, 0, 7, 8, 0, 0x1B)
  ok(x == 9 and y == 27, "pair (7,8),(0,$1B) on 8,0 is 9,27")
  x, y = rebase(23, 21, 0x16, 0x06, 21, 11)
  ok(x == 7 and y == 11, "pair ($16,$06),($15,$0B) on 23,21 is 7,11")
end

-- $02 alone stores wScriptPair. $12 parks (opcode_12.asm).
do
  local x, y, _, _, vm = run({ 0x02, 7, 8, 0, 0x1B, 0x12 }, 8, 0)
  ok(vm.pair[1] == 9 and vm.pair[2] == 27 and x == 8 and y == 0, "$02 keeps the player until $00")
  x, y, _, _, vm = run({ 0x02, 0x16, 0x06, 21, 11, 0x12 }, 23, 21)
  ok(vm.pair[1] == 7 and vm.pair[2] == 11, "$02 on 23,21 stores 7,11")
end

-- 1A:6082 order: $93, slot 0 at 5,5, $65, $00. The template is off the map
-- being left, so it must not replace the rebase. $00 then copies the pair.
local function doorScript(loX, hiX, loY, hiY)
  return concat({
    { 0x02, loX, hiX, loY, hiY, 0x93 },
    slot0(5, 5),
    { 0x65, 0x00, 0x40, 0x4F, 0x00, 0x12 },
  })
end

do
  local x, y, placed = run(doorScript(7, 8, 0, 0x1B), 8, 0)
  ok(x == 9 and y == 27, "slot 0 at 5,5 does not override 8,0 -> 9,27")
  ok(placed[#placed][1] == 9 and placed[#placed][2] == 27, "last place is the rebase")
  local overwrote = false
  for _, p in ipairs(placed) do if p[1] == 5 and p[2] == 5 then overwrote = true end end
  ok(not overwrote, "template 5,5 is not placed while the pair is pending")
end

do
  local x, y = run(doorScript(0x16, 0x06, 21, 11), 23, 21)
  ok(x == 7 and y == 11, "223 -> 225 shape still lands on 7,11")
end

-- No pending door: the slot-0 template is the spawn (new game / a load at a cell).
do
  local x, y = run(concat({ { 0x93 }, slot0(5, 5), { 0x65, 0x00, 0x40, 0x4F, 0x00, 0x12 } }), 3, 4)
  ok(x == 5 and y == 5, "no pair: template 5,5 is used")
end

-- Ringsmith (14:7DD2): $65 then $05, and the rebased cell is a wall on the
-- new map. The record's cell is used. $82 centers; it does not copy a blocked pair.
do
  local bytes = concat({
    { 0x02, 0, 1, 0, 1, 0x93, 0x65, 0x00, 0x40, 0x4F },
    slot0(8, 13),
    { 0x82, 0x12 },
  })
  local x, y = run(bytes, 0, 0)
  ok(x == 8 and y == 13, "wall on the loaded map keeps the slot-0 cell")
end

-- 250 -> 249 (19:7AFC -> 19:7784): the rebase 27,2 is a wall when slot 0's
-- $05 runs, then the entry's $7E copy opens it. $00 in the original puts the
-- player on the pair whatever the cell held, so once it is open (by $94) the
-- player must stand there, not on the 5,5 template. Here a slot-2 $05 stands in
-- for the $7E copy (the fake host opens 1,1 when it spawns).
do
  local host, at = world(0, 0)
  local spawned = 0
  host.spawn = function() spawned = spawned + 1 end
  local open0 = host.cellOpen
  host.cellOpen = function(cx, cy) if cx == 1 and cy == 1 and spawned >= 2 then return true end return open0(cx, cy) end
  local slot2 = slot0(9, 9); slot2[2] = 0x02
  local bytes = concat({
    { 0x02, 0, 1, 0, 1, 0x93, 0x65, 0x00, 0x40, 0x4F },
    slot0(5, 5),
    slot2,
    { 0x94, 0x12 },
  })
  local vm = VM.new(image(bytes), host)
  vm:start(0x12, 0x4000)
  local x, y = at()
  ok(x == 1 and y == 1, "a pair the entry opens after $05 wins over the template (got " .. x .. "," .. y .. ")")
  ok(vm.pairWall == nil, "pairWall cleared once placed")
end

-- 1D:79C8 order: map load, slot 0 whose cell matches the rebase, $82, no $00.
do
  local bytes = concat({
    { 0x02, 0x16, 0x06, 21, 11, 0x93, 0x65, 0x00, 0x40, 0x4F },
    slot0(7, 11),
    { 0x82, 0x12 },
  })
  local x, y = run(bytes, 23, 21)
  ok(x == 7 and y == 11, "$82 applies a pair that is open on the new map")
end

-- Same bytes as a map-setup run (runInit). The template still must not win
-- while the pair is waiting for its map.
do
  local host, at = world(8, 0)
  local vm = VM.new(image(doorScript(7, 8, 0, 0x1B)), host)
  vm:runInit(0x12, 0x4000)
  local x, y = at()
  ok(x == 9 and y == 27 and vm.pair == nil, "init run keeps the door rebase")
end

local romPath = os.getenv("MN_ROM")
if romPath then
  local f = io.open(romPath, "rb")
  if f then
    local rom = MnRom.new(f:read("*a"))
    f:close()
    local w = rom:resolveWarp(0x1A, 0x6802, {})
    local b = w and w.rebase
    if b then
      local x, y = rebase(8, 0, b[1], b[2], b[3], b[4])
      ok(w.map == 15 and x == 9 and y == 27, "ROM 1A:6802 from 8,0 resolves to map 15 at 9,27")
    else
      ok(false, "ROM 1A:6802 resolveWarp found a rebase")
    end
  end
end

if failures == 0 then print(("ok %d checks"):format(checks)) else print(("%d FAIL / %d"):format(failures, checks)) end
os.exit(failures == 0 and 0 or 1)
