-- mn.LayerHeads: the $02 layer heads (4F0D/4FB7/5061/510B), the $01 layer
-- heads (56DC idle, 5798/5818/58A7/5936), the 5DB5 head-word run and the
-- bank-$20 script frames ($4C/$4D/$46/$10). Made-up script bytes and cells; MN_ROM adds the real 20:5C7A.
--   luajit tests/engine/mn_layer_heads_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local LH = require("mn.LayerHeads")
local World = require("mn.World")

-- a made-up bank $20
local B = {}
local function put(a, bytes) for i, v in ipairs(bytes) do B[a + i - 1] = v end end
local function rd(a) return assert(B[a], ("unset byte %04X"):format(a)) end
local function lo(w) return w % 256 end
local function hi(w) return math.floor(w / 256) end

-- script frames
do
  put(0x7000, { 0x4C, 2, 0, 3, 0x11, 0x61, 1, 0xFE, 0, 0x22, 0x61, 0,
                0x4D, 4, 2, 1, 0, 0x33, 0x61, 0x44, 0x61, 0x46, 0x0C, 0x70 })
  local lw = LH.new(rd, 0, 0, 8); LH.plant(lw, 0x7000)
  local seen = {}
  for i = 1, 9 do LH.frame(lw); seen[i] = ("%d,%d,%04X"):format(lw.st.sx, lw.st.sy, lw.list) end
  ok(seen[1] == "0,3,6111" and seen[2] == "0,3,6111", "$4C: a record is stepped count frames")
  ok(seen[3] == "254,0,6122", "$4C: the next record's first frame")
  ok(seen[4] == "1,0,6133", "$4C: the zero count dispatches $4D in the same pass")
  ok(seen[5] == "1,0,6133" and seen[6] == "1,0,6144" and seen[7] == "1,0,6144", "$4D: each list word shows count frames, one step")
  ok(seen[8] == "1,0,6133", "$4D ends, $46 jumps back and the table restarts in that pass")
  put(0x7100, { 0x4D, 2, 0, 0, 1, 0x55, 0x61, 0x10, 0x34, 0x12, 0x46, 0x00, 0x71 })
  lw = LH.new(rd, 0, 0, 8); LH.plant(lw, 0x7100)
  for _ = 1, 256 do LH.frame(lw) end
  ok(lw.queued == nil, "$4D count 0 is 256 frames")
  LH.frame(lw)
  ok(lw.queued == 0x1234, "$10 queues the head word and dispatch goes on")
end

-- the made-up layer scripts at the head constants
local function walk4(a, dx, dy) put(a, { 0x4D, 2, 1, dx, dy, 0x00, 0x62, 0x46, lo(a), hi(a) }) end
walk4(0x5CB3, 0, 4); walk4(0x5C38, 0, 0xFC); walk4(0x5D2E, 0xFC, 0); walk4(0x5DA9, 4, 0)
-- entry down: up 2, then 3 frames down 4, then the slide
put(0x5C7A, { 0x4C, 1, 0, 0xFE, 0x01, 0x62, 3, 0, 4, 0x02, 0x62, 0, 0x46, 0xB3, 0x5C })
-- bump down: up 4, down 4, then the slide
put(0x5CC3, { 0x4C, 1, 0, 0xFC, 0x03, 0x62, 1, 0, 4, 0x03, 0x62, 0, 0x46, 0xB3, 0x5C })
-- exits: 4 frames of 4 px, $10 5D81, an idle script
local function exit(a, dx, dy) put(a, { 0x4C, 4, dx, dy, 0x04, 0x62, 0, 0x10, 0x81, 0x5D, 0x4D, 2, 1, 0, 0, 0x05, 0x62, 0x46, lo(a + 10), hi(a + 10) }) end
exit(0x5A9A, 0, 4); exit(0x59E7, 0xFC, 0); exit(0x5A21, 4, 0); exit(0x5A5B, 0, 0xFC)
-- $01 layer: entries end $10 56DC; idle scripts stand; walks 2 px a frame
local function entry1(a, dx, dy, idle) put(a, { 0x4C, 4, dx, dy, 0x06, 0x62, 0, 0x10, 0xDC, 0x56, 0x46, lo(idle), hi(idle) }) end
for _, a in ipairs({ 0x51B3, 0x518F, 0x519B, 0x51A7 }) do put(a, { 0x4D, 2, 8, 0, 0, 0x07, 0x62, 0x46, lo(a), hi(a) }) end
entry1(0x59A8, 0, 4, 0x51B3); entry1(0x58F5, 0xFC, 0, 0x518F); entry1(0x592F, 4, 0, 0x519B); entry1(0x5969, 0, 0xFC, 0x51A7)
local function walk2(a, dx, dy) put(a, { 0x4C, 1, dx, dy, 0x08, 0x62, 0, 0x46, lo(a), hi(a) }) end
walk2(0x526E, 0, 2); walk2(0x531D, 0xFE, 0); walk2(0x53CC, 2, 0); walk2(0x51BF, 0, 0xFE)

-- an 8-wide plane; gates live in mem and follow the writers
local function world(set)
  local c = {}
  for i = 0, 63 do c[i] = 0x08 end
  for k, v in pairs(set) do c[k[2] * 8 + k[1]] = v end
  local m = {}
  local p = { 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF }
  for i = 0, 7 do m[0xC12A + i] = p[i + 1] end
  local env = { cell = function(q) if q < 0 or q > 63 then return 0x08 end; return c[q] end,
                gate = function(v) return World.walkable(v, m) and 0 or 0xFF end }
  local io = { env = env, held = 0, frame = 0, gates = function(n) World.writeGates(m, n) end }
  return io, m
end
local function px(lw) local x, y = LH.pixel(lw); return x .. "," .. y end

-- $02 layer, down: $00 start at 1,0; band 1,1..1,3; $00 at 1,4
do
  local io, m = world({ [{ 1, 0 }] = 0, [{ 1, 1 }] = 2, [{ 1, 2 }] = 2, [{ 1, 3 }] = 2, [{ 1, 4 }] = 0 })
  local lw = LH.new(rd, 1, 0, 8)
  LH.enter(lw, 2, "down", io)
  ok(lw.head == 0x4F0D and lw.hb == 3 and lw.layer == 2, "4ED4: the down entry plants straight onto 4F0D")
  LH.tick(lw, io)
  ok(m[0xC12A] == 0xFF and m[0xC12C] == 0, "4F0D writes 4ECB every pass")
  ok(px(lw) == "16,0", "the entry's up step is stopped by the solid cell above (682D)")
  for _ = 1, 3 do LH.tick(lw, io) end
  ok(px(lw) == "16,12", "then 4 px a frame down onto the band")
  local tags = {}
  for i = 1, 12 do tags[i] = LH.tick(lw, io); if tags[i] == "exit" then break end end
  ok(lw.st.cy == 3 and lw.st.fy == 8, "the slide stops at the last $02 cell's centre")
  ok(lw.head == LH.RUN and lw.layer == nil, "a $00 cell beyond plants the exit under 5DB5")
  ok(m[0xC12A] == 0 and m[0xC12C] == 0xFF, "4EC2 restores the gates")
  local r
  for _ = 1, 4 do r = LH.tick(lw, io) end
  ok(r == "run" and px(lw) == "16,64", "5DB5 moves the record by the fine steps")
  r = LH.tick(lw, io)
  ok(r == "normal" and lw.st.cy == 4 and lw.st.fy == 8, "$10 5D81 hands back the normal head on the $00 cell")
end

-- $02 layer: a wall beyond bumps, the head stays
do
  local io = world({ [{ 1, 0 }] = 2, [{ 1, 1 }] = 2, [{ 1, 2 }] = 0x08 })
  local lw = LH.new(rd, 1, 1, 8)
  LH.plant(lw, 0x5CB3); lw.head, lw.hb, lw.layer = 0x4F0D, 3, 2
  local tag
  for _ = 1, 4 do tag = LH.tick(lw, io); if tag == "bump" then break end end
  ok(tag == "bump" and lw.head == 0x4F0D and lw.scr.ptr == 0x5CC3, "a wall beyond plants the bump script (5CC3)")
  LH.tick(lw, io)
  ok(px(lw) == "16,12", "the bump script moves the record (up 4 onto open $02)")
end

-- $02 layer: a newly pressed direction switches, a held one does not
do
  local io = world({ [{ 1, 1 }] = 2, [{ 1, 2 }] = 2, [{ 0, 1 }] = 2, [{ 0, 2 }] = 2, [{ 1, 3 }] = 2 })
  local lw = LH.new(rd, 1, 1, 8)
  LH.plant(lw, 0x5CB3); lw.head, lw.hb, lw.layer = 0x4F0D, 3, 2
  io.held = 0x80
  LH.tick(lw, io)
  ok(lw.head == 0x4F0D and px(lw) == "16,20", "down, the head's own direction, is not a switch")
  io.held = 0xA0
  LH.tick(lw, io)
  ok(lw.head == 0x4FB7 and lw.scr.ptr == 0x5D2E and px(lw) == "16,20", "a newly pressed left plants 4F9C; that pass does not move")
  LH.tick(lw, io)
  ok(lw.hb == 1 and px(lw) == "12,20", "4FB7 slides left with its script")
  LH.tick(lw, io)
  ok(lw.head == 0x4FB7, "left still held: no new press")
end

-- $01 layer: entry run, idle, walk right with the odd-frame up drift, release, exit
do
  local io, m = world({ [{ 0, 1 }] = 0, [{ 1, 1 }] = 1, [{ 2, 1 }] = 1, [{ 3, 1 }] = 0, [{ 1, 0 }] = 1, [{ 2, 0 }] = 1 })
  local lw = LH.new(rd, 0, 1, 8)
  LH.enter(lw, 1, "right", io)
  ok(m[0xC12A] == 0xFF and m[0xC12B] == 0 and lw.head == LH.RUN, "570D family: 56C0, the entry under 5DB5")
  for _ = 1, 4 do LH.tick(lw, io) end
  ok(px(lw) == "16,16" and lw.head == LH.RUN, "the entry hop moves 16 px")
  LH.tick(lw, io)
  ok(lw.head == LH.IDLE1 and lw.layer == 1, "$10 56DC: the $01 idle head")
  io.held = 0x10
  LH.tick(lw, io)
  ok(lw.head == 0x58A7 and lw.hb == 2 and px(lw) == "16,16", "56DC: held right plants 5888, no step that pass")
  io.held = 0x50; io.frame = 1
  LH.tick(lw, io)
  ok(px(lw) == "18,15", "58A7: odd hMainLoopCounter with up held sets the Y step $FF")
  io.frame = 2
  LH.tick(lw, io)
  ok(px(lw) == "20,15", "even frames keep the script's Y step")
  io.held = 0
  LH.tick(lw, io)
  ok(lw.head == LH.IDLE1 and lw.hb == 2 and lw.scr.ptr == 0x519B, "release: 519B under 56DC, the head byte stays")
  io.held = 0x10
  LH.tick(lw, io)
  local tag
  for _ = 1, 20 do tag = LH.tick(lw, io); if tag == "exit" then break end end
  ok(tag == "exit" and lw.st.cx == 2 and lw.st.fx == 8, "the walk stops at the last $01 cell and sees $00 beyond")
  ok(m[0xC12A] == 0 and m[0xC12B] == 0xFF, "56B7 restores the gates")
  local r
  for _ = 1, 5 do r = LH.tick(lw, io) end
  ok(r == "normal" and lw.st.cx == 3 and lw.st.fx == 8, "the exit lands on the $00 cell's centre, head 5D81")
end

-- $01 layer down head: left held switches to the left walk
do
  local io = world({ [{ 1, 1 }] = 1, [{ 1, 2 }] = 1, [{ 0, 1 }] = 1 })
  local lw = LH.new(rd, 1, 1, 8)
  LH.plant(lw, 0x526E); lw.head, lw.hb, lw.layer = 0x5798, 3, 1
  io.held = 0x80; LH.tick(lw, io)
  ok(px(lw) == "16,18", "5798 walks down by the script")
  io.held = 0xA0; LH.tick(lw, io)
  ok(lw.head == 0x5818 and lw.hb == 1, "down with left held plants 57F9")
end

-- With MN_ROM set (the user's own ROM; nothing from it is committed): the real 4ED4 entry
-- script 20:5C7A. $4C records (00:1560) step one per frame, the zero count dispatches the
-- $4D (00:15E8) in the same pass; 23 frames net +29 px, then the slide at +4 a frame.
do
  local romPath = os.getenv("MN_ROM")
  local f = romPath and io.open(romPath, "rb")
  if f then
    local rom = f:read("*a"); f:close()
    local function rrd(a) return rom:byte(0x20 * 0x4000 + (a - 0x4000) + 1) end
    local lw = LH.new(rrd, 0, 0, 8); LH.plant(lw, 0x5C7A)
    local function s8(v) return v >= 128 and v - 256 or v end
    local sum, seq = 0, {}
    for i = 1, 23 do LH.frame(lw); sum = sum + s8(lw.st.sy); seq[i] = s8(lw.st.sy) end
    ok(sum == 29 and seq[1] == -2 and seq[23] == 1, "5C7A: $4C rise and fall, 23 frames net +29 px")
    local slide = true
    for _ = 1, 4 do LH.frame(lw); if s8(lw.st.sy) ~= 4 then slide = false end end
    ok(slide, "5C7A: then the $4D slide at 4 px a frame")
  else
    print("mn_layer_heads: MN_ROM not set, 20:5C7A check skipped")
  end
end

print(("mn_layer_heads: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
