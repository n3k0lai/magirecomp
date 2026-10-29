-- MapCamera: the asm's logical camera (wMapColumn/Row $C85F/$C860, fine $C85D/$C85E)
-- next to the port's visible one. ClampMapCamera (clamp_map_camera.asm) pins the column
-- and row and builds $C935/$C934; $82/$84 store cell - 5 with fine 8 and nothing else.
-- Made-up limits, no ROM bytes.
--   luajit tests/engine/mn_map_camera_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MapCamera = require("mn.MapCamera")
local bit = require("bit")
local C = MapCamera.center

do -- inside the limits: column/row kept, fine 8 kept, pixel = cell * 16 + 8
  local cam, e, px, py = MapCamera.clamp({ w = 40, col = 29, row = 20 }, C(6, 4))
  ok(cam.col == 6 and cam.row == 4 and cam.fx == 8 and cam.fy == 8 and e == 0, "inside: unchanged, no flags")
  ok(px == 104 and py == 72, "inside: $C935/$C934 = cell * 16 + 8")
end

do -- column 0 or at/past the width: column 0, fine 0, bit 2
  local cam, e, px = MapCamera.clamp({ w = 40, col = 29, row = 20 }, C(0, 4))
  ok(cam.col == 0 and cam.fx == 0 and e == 4 and px == 0, "column 0 drops fine 8")
  cam, e = MapCamera.clamp({ w = 40, col = 29, row = 20 }, C(3 - 5, 4)) -- cell 3: (3-5) & $FF = 254
  ok(cam.col == 0 and cam.fx == 0 and e == 4, "a cell under 5 wraps past the width and pins to 0")
end

do -- at/past the limit column: the limit, fine 15, bit 1
  local cam, e, px = MapCamera.clamp({ w = 40, col = 29, row = 20 }, C(33, 4))
  ok(cam.col == 29 and cam.fx == 15 and e == 2, "past $C845: limit column, fine 15")
  ok(px == (29 * 16 + 15) % 256, "pixel byte wraps at 256")
end

do -- width 10: bit 3 (no sideways steps) and column 0
  local cam, e = MapCamera.clamp({ w = 10, col = 0, row = 20 }, C(4, 4))
  ok(cam.col == 0 and cam.fx == 0 and e == 8 + 4 + 2, "width 10: bits 3, 2, 1")
end

do -- row limit 0 (a 10-row map): any row pins to row 0 with fine 15, bits 5 and 6
  local cam, e, _, py = MapCamera.clamp({ w = 40, col = 29, row = 0 }, C(2, 3))
  ok(cam.row == 0 and cam.fy == 15 and e == 0x60 and py == 15, "row limit 0: row 0, fine 15")
end

do -- row limit $FF (shorter than the window): bit 7, row 0, fine 0
  local cam, e, _, py = MapCamera.clamp({ w = 40, col = 29, row = 0xFF }, C(2, 3))
  ok(cam.row == 0 and cam.fy == 0 and bit.band(e, 0xC0) == 0xC0 and py == 0, "row limit $FF: no vertical")
end

do -- a row at/past limit + 10 pins to 0, between limit and limit + 10 pins to the limit
  local cam = MapCamera.clamp({ w = 40, col = 29, row = 5 }, C(6, 15))
  ok(cam.row == 0 and cam.fy == 0, "row >= $C846 + 10: row 0")
  cam = MapCamera.clamp({ w = 40, col = 29, row = 5 }, C(6, 9))
  ok(cam.row == 5 and cam.fy == 15, "row in $C846..+9: the limit, fine 15")
end

do -- steps carry fine crossings into the column / row
  local cam = MapCamera.step(C(6, 4), 9, -9)
  ok(cam.col == 7 and cam.fx == 1 and cam.row == 3 and cam.fy == 15, "8+9 = col+1 fine 1; 8-9 = row-1 fine 15")
  cam = MapCamera.step(MapCamera.origin(), -1, 0)
  ok(cam.col == 255 and cam.fx == 15, "the column byte wraps")
end

do -- the host: $84 records the logical camera; the visible camera is its clamp
  local Overworld = require("mn.Overworld")
  local s = setmetatable({ def = { w = 40, h = 30, camCol = 29, camRow = 20, cells = {}, block = {} },
    patches = {}, log = {}, objects = {}, px = 20 * 16, py = 15 * 16 }, { __index = Overworld })
  local h = Overworld.host(s)
  s.ringRecord = function() end; s.ringApply = function() end
  h.cameraCell(10, 4)
  ok(s.mapCam.col == 10 and s.mapCam.row == 4 and s.mapCam.fx == 8 and s.mapCam.fy == 8, "$84 stores cell-5, fine 8")
  local x, y = s:cameraXY()
  ok(x == 168 and y == 72, "visible camera: column 10 row 4 fine 8 survive inside the limits")
  h.cameraCell(35, 25)
  x, y = s:cameraXY()
  ok(x == 29 * 16 + 15 and y == 20 * 16 + 15, "past the limits: last column/row fine 15")
  h.cameraCell(251, 251)
  x, y = s:cameraXY()
  ok(x == 0 and y == 0, "a wrapped cell - 5 pins to column/row 0 fine 0")
  s.vm = { playerCell = function() return 12, 9 end }
  h.centerCamera()
  ok(s.mapCam.col == 7 and s.mapCam.row == 4 and s.mapCam.fx == 8, "$82 stores $C18E/F - 5, fine 8")
  s.pans = { { 2, 4, 0 } }
  s:panFrame(); s:panFrame()
  ok(s.mapCam.col == 8 and s.mapCam.fx == 0, "8 + 4 + 4 = next column, fine 0")
end

do -- limits from the header, else w - 11 / h - 10
  local l = MapCamera.limits({ w = 40, h = 30, camCol = 29, camRow = 0xFF })
  ok(l.w == 40 and l.col == 29 and l.row == 0xFF, "header limits")
  l = MapCamera.limits({ w = 48, h = 30 })
  ok(l.col == 37 and l.row == 20, "fallback limits")
  local _, _, px, py = MapCamera.clamp(l, MapCamera.center(10, 4))
  ok(px == 168 and py == 72, "a $84 to 10,4 redraws at 168,72 (fine 8)")
end

print(("mn_map_camera: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
