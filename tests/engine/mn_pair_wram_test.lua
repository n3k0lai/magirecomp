-- The door pair is plain WRAM (made-up bytes only, no ROM).
--   $01 (opcode_01.asm) and $02 (opcode_02.asm) write $C9A1/$C9A2.
--   $00 (opcode_00_bank1.asm) always copies $C9A1/$C9A2 to $C18E/$C18F.
--   $05 (fill_script_record_0808.asm) writes record +5/+6. Slot 0's record is
--   $C189 ($0303 table), so slot 0's +5/+6 *is* $C18E/$C18F.
--   $25 (opcode_25.asm) copies $C18E/$C18F back to $C9A1/$C9A2.
-- Nothing clears the pair, and no rule looks at walls: the last writer wins.
--   luajit tests/engine/mn_pair_wram_test.lua
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
  local s = string.rep("\0", 0x12 * 0x4000) .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

local function rec(slot, tx, ty)
  return { 0x05, slot, 0x00, 0x00, tx, ty, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }
end

local function concat(parts)
  local t = {}
  for _, p in ipairs(parts) do
    if type(p) == "table" then for _, b in ipairs(p) do t[#t + 1] = b end else t[#t + 1] = p end
  end
  return t
end

-- open(x, y) decides walls; the VM must not care.
local function run(bytes, x0, y0, open)
  local x, y = x0, y0
  local st = { moved = 0 }
  local host = {
    playerCell = function() return x, y end,
    placePlayer = function(px, py) x, y = px, py end,
    cellOpen = open or function() return true end,
    loadMap = function() end,
    spawn = function(slot, sx, sy) if slot == 0 then st.sx, st.sy = sx, sy end end,
    moveStandIn = function(sx, sy) st.sx, st.sy = sx, sy; st.moved = st.moved + 1 end,
    centerCamera = function() end,
  }
  local vm = VM.new(image(bytes), host)
  vm:start(0x12, 0x4000)
  return x, y, vm, st
end

local LOAD = { 0x65, 0x00, 0x40, 0x4F }
local wall = function(cx, cy) return not (cx == 1 and cy == 1) end

-- Ringsmith shape (no $00 after the slot-0 $05): the record cell is the spawn,
-- whether or not the door's rebased cell is open.
do
  local b = concat({ { 0x02, 0, 1, 0, 1, 0x93 }, LOAD, rec(0, 8, 13), { 0x82, 0x12 } })
  local x, y = run(b, 0, 0, wall)
  ok(x == 8 and y == 13, "ringsmith: blocked pair, record cell 8,13 (got " .. x .. "," .. y .. ")")
  x, y = run(b, 0, 0)
  ok(x == 8 and y == 13, "ringsmith: open pair, still 8,13 (no $00) (got " .. x .. "," .. y .. ")")
end

-- 182 story $0F shape: $01 29,11, slot 0 at 11,3, then $00. Pair wins and the
-- stand-in moves with it, open or not.
for _, open in ipairs({ false, true }) do
  local b = concat({ { 0x01, 29, 11, 0x93 }, rec(0, 11, 3), { 0x00, 0x12 } })
  local x, y, _, st = run(b, 0, 0, open and nil or function(_, cy) return cy ~= 11 end)
  local tag = open and "open" or "wall"
  ok(x == 29 and y == 11, "182 (" .. tag .. "): player on 29,11 (got " .. x .. "," .. y .. ")")
  ok(st.sx == 29 and st.sy == 11 and st.moved == 1, "182 (" .. tag .. "): stand-in moved once to 29,11")
end

-- 1A:6802 -> 1A:6082 shape: $02 on the old map, slot 0 at 5,5, $65, $00.
do
  local b = concat({ { 0x02, 7, 8, 0, 0x1B, 0x93 }, rec(0, 5, 5), LOAD, { 0x00, 0x12 } })
  local x, y, vm = run(b, 8, 0)
  ok(x == 9 and y == 27, "6802 shape: 8,0 -> 9,27 (got " .. x .. "," .. y .. ")")
  ok(vm:rd8(0xC9A1) == 9 and vm:rd8(0xC9A2) == 27, "pair lives at $C9A1/$C9A2")
end

-- $02 reads $C18E as it is now: after a slot-0 $05 that is the record cell.
do
  local x, y, vm = run(concat({ rec(0, 5, 5), { 0x02, 1, 2, 1, 3, 0x12 } }), 0, 0)
  ok(x == 5 and y == 5, "$02 does not move the player")
  ok(vm:rd8(0xC9A1) == 6 and vm:rd8(0xC9A2) == 7, "$02 from 5,5 by +1,+2 is 6,7")
end

-- The pair persists: a second $00 reuses it.
do
  local x, y = run(concat({ { 0x01, 4, 6, 0x00 }, rec(0, 1, 1), { 0x00, 0x12 } }), 0, 0)
  ok(x == 4 and y == 6, "second $00 reuses the stale pair (got " .. x .. "," .. y .. ")")
end

-- $00 with no $01/$02 this run copies whatever WRAM holds.
do
  local host = { playerCell = function() return 0, 0 end, placePlayer = function() end, centerCamera = function() end }
  local px, py
  host.placePlayer = function(a, b) px, py = a, b end
  local vm = VM.new(image({ 0x00, 0x12 }), host)
  vm:wr8(0xC9A1, 0x11); vm:wr8(0xC9A2, 0x22)
  vm:start(0x12, 0x4000)
  ok(px == 0x11 and py == 0x22, "$00 copies the WRAM pair as-is")
end

-- $25 saves $C18E into the pair (the battle return's $00 puts the player back).
do
  local b = { 0x25, 0, 0, 0, 0, 0, 0, 0x01, 9, 9, 0x00, 0x12 }
  local x, y, vm = run(b, 3, 4)
  ok(vm:rd8(0xC9A1) == 9 and vm:rd8(0xC9A2) == 9, "$01 after $25 overwrote the pair")
  x, y, vm = run({ 0x25, 0, 0, 0, 0, 0, 0, 0x12 }, 3, 4)
  ok(vm:rd8(0xC9A1) == 3 and vm:rd8(0xC9A2) == 4, "$25 copies $C18E/$C18F to the pair")
end

if failures == 0 then print(("ok %d checks"):format(checks)) else print(("%d FAIL / %d"):format(failures, checks)) end
os.exit(failures == 0 and 0 or 1)
