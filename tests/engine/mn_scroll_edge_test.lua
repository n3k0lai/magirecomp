-- $83 / $16 pans go through $C843/$C844 and StepHorizontalScroll / StepVerticalScroll
-- (bank 7): each frame's delta is clamped to -4..+4, a step past column 0 fine 0 or the
-- limit column ($C845) fine 15 is cut short, a stride of 10 never steps sideways, and a
-- row limit of $FF never steps vertically. Made-up maps, no ROM bytes.
--   luajit tests/engine/mn_scroll_edge_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Overworld = require("mn.Overworld")

local function world(w, h, camCol, camRow, px, py)
  local s = setmetatable({ def = { w = w, h = h, camCol = camCol, camRow = camRow, cells = {}, block = {} },
    patches = {}, log = {}, objects = {}, px = px * 16, py = py * 16 }, { __index = Overworld })
  return s
end
local function run(s, frames) for _ = 1, frames do if s.pans then s:panFrame() end end end

do -- a delta past 4 moves 4 a frame
  local s = world(40, 30, 29, 20, 20, 15)
  local x0, y0 = s:cameraXY()
  s.pans = { { 3, 7, -9 } }
  run(s, 3)
  local x, y = s:cameraXY()
  ok(x == x0 + 12 and y == y0 - 12, "7,-9 for 3 frames moves 12,-12")
  ok(s.pans == nil, "the pan ends after its count")
end

do -- left / up stop at 0, cut short on the frame that would cross
  local s = world(40, 30, 29, 20, 4, 4) -- follow camera at 0,0 is clamped; start at 6,6
  s.camFix = { 6, 6 }
  s.pans = { { 5, -4, -4 } }
  run(s, 5)
  local x, y = s:cameraXY()
  ok(x == 0 and y == 0, "left/up pan stops at the map's top-left corner")
  ok(s.camOff[1] == -6 and s.camOff[2] == -6, "only 6 of 20 pixels applied")
end

do -- right / down stop at the limit column/row, fine 15
  local s = world(40, 30, 29, 20, 0, 0)
  local hiX, hiY = 29 * 16 + 15, 20 * 16 + 15
  s.camFix = { hiX - 5, hiY - 2 }
  s.pans = { { 4, 4, 4 } }
  run(s, 4)
  local x, y = s:cameraXY()
  ok(x == hiX and y == hiY, "right/down pan stops at limit*16+15")
  s.pans = { { 2, -3, -1 } }
  run(s, 2)
  x, y = s:cameraXY()
  ok(x == hiX - 6 and y == hiY - 2, "the way back is open")
end

do -- stride 10: no sideways steps; row limit $FF: no vertical steps
  local s = world(10, 30, 0xFF, 20, 0, 5)
  s.camFix = { 0, 40 }
  s.pans = { { 3, 4, 4 } }
  run(s, 3)
  local x, y = s:cameraXY()
  ok(x == 0 and y == 52, "width 10: only the vertical half moves")
  s = world(24, 9, 13, 0xFF, 0, 0)
  s.camFix = { 40, 0 }
  s.pans = { { 2, -4, 4 } }
  run(s, 2)
  x, y = s:cameraXY()
  ok(x == 32 and y == 0, "row limit $FF: only the horizontal half moves")
end

do -- panFrame moves the camera. The $16 slot named on the pan stays put.
  local s = world(40, 30, 29, 20, 0, 0)
  s.camFix = { 8, 100 }
  s.objects[3] = { x = 5, y = 7, ox = 0, oy = 0 }
  s.pans = { { 4, -4, 0, nil, { [3] = true } } }
  run(s, 4)
  local x = s:cameraXY()
  local ob = s.objects[3]
  ok(x == 0, "the pan stops at column 0")
  ok(ob.x == 5 and ob.ox == 0 and ob.oy == 0, "panFrame leaves the walker where it is")
end

do -- without header limits the field's W-160 / H-144 apply
  local s = world(20, 18, nil, nil, 0, 0)
  s.camFix = { 158, 142 }
  s.pans = { { 1, 4, 4 } }
  run(s, 1)
  local x, y = s:cameraXY()
  ok(x == 160 and y == 144, "fallback limits W-160, H-144")
end

do -- two threads in one frame: the deltas sum into $C843/$C844, clamped once
  local s = world(40, 30, 29, 20, 20, 15)
  s.camFix = { 100, 100 }
  s.pans = { { 2, 1, 0 }, { 4, 2, -1 } }
  local xs = {}
  for _ = 1, 4 do run(s, 1); xs[#xs + 1] = s:cameraXY() end
  ok(xs[1] == 103 and xs[2] == 106 and xs[3] == 108 and xs[4] == 110, "1 + 2 for 2 frames, then 2: "
    .. table.concat(xs, ","))
  ok(s.pans == nil, "both pans end after their counts")
  local s2 = world(40, 30, 29, 20, 20, 15)
  s2.camFix = { 100, 100 }
  s2.pans = { { 2, 3, 0 }, { 2, 3, 0 } }
  run(s2, 2)
  ok(s2:cameraXY() == 108, "3 + 3 is clamped to 4 once a frame")
end

do -- the Tavel Gorge kids (1F:50CD): three walkers each start $16 with dy -1
  local function kids(top)
    local s = world(40, 30, 29, 20, 0, 0)
    s.camFix = { 0, top }
    for slot = 3, 5 do s.objects[slot] = { x = 4 + slot, y = 3 } end
    for slot = 3, 5 do
      s.pans = s.pans or {}
      s.pans[#s.pans + 1] = { 8, 0, -1, nil, { [slot] = true } }
    end
    run(s, 8)
    return s
  end
  local s = kids(0)
  local _, y = s:cameraXY()
  ok(y == 0, "camera at the map top stays there")
  ok(s.objects[3].y == 3 and s.objects[4].y == 3 and s.objects[5].y == 3
    and (s.objects[3].oy or 0) == 0, "panFrame leaves the kids on row 3")
  local s2 = kids(64)
  local _, y2 = s2:cameraXY()
  ok(y2 == 64 - 24, "below the top the three -1s sum to -3 a frame")
  ok(s2.objects[4].y == 3 and (s2.objects[4].oy or 0) == 0, "panFrame leaves each kid on row 3")
end

do -- row limit 0: the vertical range is fine 0..15 (bits 5 and 6 together)
  local s = world(40, 30, 29, 0, 0, 0)
  s.camFix = { 0, 15 }
  s.pans = { { 20, 0, -1 } }
  run(s, 20)
  local _, y = s:cameraXY()
  ok(y == 0, "row limit 0: up from fine 15 stops at fine 0")
  s.pans = { { 20, 0, 1 } }
  run(s, 20)
  _, y = s:cameraXY()
  ok(y == 15, "row limit 0: down stops at fine 15")
end

do -- column limit 0, and the width is not 10: no right step past fine 15
  local s = world(20, 18, 0, 10, 0, 0)
  s.camFix = { 15, 0 }
  s.pans = { { 3, 4, 0 } }
  run(s, 3)
  ok(s:cameraXY() == 15, "column limit 0: right stops at fine 15")
end

do -- the walker moves by its anim step; the camera moves by the scroll pair
  local Sprites = require("mn.Sprites")
  local s = world(40, 30, 29, 20, 0, 0)
  s.camFix = { 0, 4 }
  local ob = { x = 5, y = 6, ox = 0, oy = 0, seq = { { n = 100, dx = 0, dy = -1 } }, fi = 1, ft = 0 }
  s.objects[3] = ob
  s.pans = { { 8, 0, -1, nil, { [3] = true } } }
  for _ = 1, 8 do
    Sprites.tick(ob, function() return true end)
    if s.pans then s:panFrame() end
  end
  local _, y = s:cameraXY()
  ok(y == 0, "camera dy -1 from fine 4 stops at 0")
  ok(ob.y * 16 + ob.oy == 6 * 16 - 8, "the anim step is -1 a frame for all 8 frames")
end

do -- h.pan keeps one pan per call: same-count same-delta walkers are not merged
  local s = world(40, 30, 29, 20, 20, 15)
  local h = Overworld.host(s)
  h.pan(8, 0, -1, 3); h.pan(8, 0, -1, 4); h.pan(5, 2, 0)
  ok(s.pans and #s.pans == 3, "three h.pan calls are three pans")
  ok(s.pans[1][5][3] and s.pans[2][5][4] and s.pans[3][5] == nil, "each $16 pan carries its own walker")
end

print(("mn_scroll_edge: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
