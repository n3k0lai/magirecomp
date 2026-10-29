-- StagedByteEdgeCheck / Opcode03Continue (01:4617): with the LCD on, a $7E or
-- $7F cell that sits on a view edge while that edge's reload latch is set is
-- copied again next frame instead of advancing. Synthetic bytes only.
--   luajit tests/engine/mn_edge_stall_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Records = require("mn.ops.Records")

local iv = Records.cellInView
-- the rule itself
ok(iv(false, 5, 4, 5, 4, 2, 2) == 0, "LCD off never stalls")
ok(iv(true, 5, 4, 5, 2, 2, 0) == 1, "left edge (delta 0) with the column latch")
ok(iv(true, 15, 4, 5, 2, 1, 0) == 1, "right edge (delta 10) with the column latch at 1")
ok(iv(true, 6, 4, 5, 2, 2, 2) == 0, "inner column, inner row: no stall")
ok(iv(true, 5, 4, 5, 2, 0, 0) == 0, "edge column with both latches clear")
ok(iv(true, 5, 2, 5, 2, 0, 1) == 1, "column latch clear falls through to the row test")
ok(iv(true, 7, 11, 5, 2, 0, 2) == 1, "bottom edge (delta 9) with the row latch")
ok(iv(true, 7, 11, 5, 2, 2, 0) == 0, "column latch alone does not stall an inner column")
ok(iv(true, 4, 4, 5, 2, 2, 2) == 0, "left of the view (delta $FF) is out of view")
ok(iv(true, 21, 4, 5, 2, 2, 2) == 0, "delta 16 is out of view")
ok(iv(true, 18, 4, 5, 2, 2, 0) == 0, "delta 13 is in view but not an edge")

local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- 2x1 rect from $D000 to $D025 (row 4, col 5); $52 marks the next opcode.
local SCRIPT = { 0x7E, 0x00, 0xD0, 2, 1, 0x25, 0xD0, 0x04, 0x05, 0x52, 0x05 }

local function run(latches)
  local def = { w = 8, h = 8, cells = {}, block = {} }
  for i = 1, 64 do def.cells[i] = 0x10; def.block[i] = 0x20 end
  def.cells[1], def.cells[2] = 0xA1, 0xA2
  local copies = {}
  local frameNo = 1
  local h = {
    mapWidth = function() return def.w end,
    copyCell = function(si, di)
      copies[#copies + 1] = di
      def.cells[di + 1] = def.cells[si + 1]; def.block[di + 1] = def.block[si + 1]
    end,
    edgeLatches = function()
      local l = latches[frameNo] or latches.default
      return l[1], l[2], l[3], l[4]
    end,
  }
  local vm = VM.new(image(SCRIPT), h)
  vm:start(0x12, 0x4000)
  local frames = 1
  while vm.co and frames < 20 do frameNo = frameNo + 1; frames = frames + 1; vm.wait = nil; vm:resume() end
  return copies, frames, vm, def
end

-- no latch: two cells, two copies, the opcode after $7E on the third pass
do
  local copies, frames, vm = run({ default = { 5, 0, 0, 0 } })
  ok(#copies == 2 and copies[1] == 0x25 and copies[2] == 0x26, "clear latches copy each cell once")
  ok(frames == 3 and vm:rd8(0xC6F7) == 4, "clear latches finish on the third pass")
end

-- the column latch is 2 then 1 (tile pass, attr pass) while col 5 is the left edge
do
  local copies, frames, vm, def = run({ { 5, 0, 2, 0 }, { 5, 0, 1, 0 }, default = { 5, 0, 0, 0 } })
  ok(#copies == 4, "the edge cell is copied again on each latched frame")
  ok(copies[1] == 0x25 and copies[2] == 0x25 and copies[3] == 0x25 and copies[4] == 0x26, "the stalled cell repeats before the next cell")
  ok(frames == 5 and vm:rd8(0xC6F7) == 4, "two stalled frames delay the opcode by two frames")
  ok(def.cells[0x26] == 0xA1 and def.cells[0x27] == 0xA2, "the rect still lands")
end

-- the second cell (col 6) is not an edge, so a latch while it copies does nothing
do
  local copies, frames = run({ { 5, 0, 0, 0 }, { 5, 0, 2, 0 }, default = { 5, 0, 0, 0 } })
  ok(#copies == 2 and frames == 3, "an inner cell ignores the column latch")
end

-- LCD off (map setup) never consults the latches
do
  local def = { w = 8, h = 8, cells = {}, block = {} }
  for i = 1, 64 do def.cells[i] = 0x10; def.block[i] = 0x20 end
  local asked = 0
  local h = {
    mapWidth = function() return def.w end,
    copyCell = function(si, di) def.cells[di + 1] = def.cells[si + 1] end,
    edgeLatches = function() asked = asked + 1; return 5, 0, 2, 2 end,
  }
  local vm = VM.new(image(SCRIPT), h)
  vm:runInit(0x12, 0x4000)
  ok(asked == 0 and vm:rd8(0xC6F7) == 4, "runInit copies the rect without the edge check")
end

-- host latches: 2 on the pass whose camera crossed an 8 px line, 1 on the next, then 0
do
  local okLoad, OW = pcall(require, "mn.Overworld")
  ok(okLoad and OW.stepEdgeLatches ~= nil, "Overworld exposes stepEdgeLatches")
  if okLoad then
    local cam = { 0, 0 }
    local fake = { map = 1, cameraXY = function() return cam[1], cam[2] end }
    OW.stepEdgeLatches(fake)
    ok(fake.colLatch == 0 and fake.rowLatch == 0, "first pass on a map sets no latch")
    cam[1] = 7; OW.stepEdgeLatches(fake)
    ok(fake.colLatch == 0, "moving inside one 8 px column sets nothing")
    cam[1] = 8; OW.stepEdgeLatches(fake)
    ok(fake.colLatch == 2 and fake.rowLatch == 0, "crossing x=8 sets the column latch to 2")
    OW.stepEdgeLatches(fake)
    ok(fake.colLatch == 1, "the attribute pass leaves 1")
    OW.stepEdgeLatches(fake)
    ok(fake.colLatch == 0, "then it clears")
    cam[2] = -1; OW.stepEdgeLatches(fake)
    ok(fake.rowLatch == 2 and fake.colLatch == 0, "crossing a row line upward sets the row latch")
    fake.map = 2; cam[1] = 40; OW.stepEdgeLatches(fake)
    ok(fake.colLatch == 0 and fake.rowLatch == 0, "a new map resets the latches")
  end
end

print(("mn_edge_stall: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
