-- Logical map camera ($C85F/$C860, fine $C85D/$C85E) and ClampMapCamera.
-- Made-up limits and a made-up $16 record. No ROM bytes.
--   luajit tests/engine/mn_map_camera_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MapCamera = require("mn.MapCamera")
local Overworld = require("mn.Overworld")
local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local LIM = { w = 40, col = 29, row = 20 }

local function pin(lim, cam)
  return MapCamera.clamp(lim, cam)
end

do -- $2F37 origin, and one scroll step across a fine boundary
  local o = MapCamera.origin()
  ok(o.col == 0 and o.row == 0 and o.fx == 0 and o.fy == 0, "origin is column 0 row 0 fine 0")
  MapCamera.step(o, -1, 0)
  ok(o.col == 255 and o.fx == 15 and o.fy == 0, "a left step from fine 0 wraps the column")
  local c = MapCamera.center(6, 4)
  ok(c.col == 6 and c.row == 4 and c.fx == 8 and c.fy == 8, "$82/$84 store fine 8")
  MapCamera.step(c, 9, -9)
  ok(c.col == 7 and c.fx == 1 and c.row == 3 and c.fy == 15, "step carries across a cell")
end

do -- inside the limits, fine 8 survives and the edge byte stays 0
  local cam = MapCamera.center(6, 4)
  local p, e, px, py = pin(LIM, cam)
  ok(cam.fx == 8 and cam.col == 6, "clamp leaves its input alone")
  ok(p.col == 6 and p.fx == 8 and p.row == 4 and p.fy == 8, "inside: fine 8 kept")
  ok(e == 0 and px == 104 and py == 72, "inside: flags 0, pixels 104,72")
end

do -- column 0 drops fine 8; a cell under 5 wraps and pins to 0
  local p, e, px, py = pin(LIM, { col = 0, row = 4, fx = 8, fy = 8 })
  ok(p.col == 0 and p.fx == 0 and p.row == 4 and p.fy == 8, "column 0 pins fine X to 0")
  ok(e == 4 and px == 0 and py == 72, "column 0 sets bit 2")
  local wrapped = MapCamera.center(3 - 5, 4 - 5)
  ok(wrapped.col == 254 and wrapped.row == 255, "cell - 5 wraps through 256")
  p, e = pin(LIM, wrapped)
  ok(p.col == 0 and p.fx == 0 and p.row == 0 and p.fy == 0 and e == 0x44, "wrapped cell pins to 0,0 flags $44")
end

do -- past $C845: limit column, fine 15, bit 1; the pixel byte wraps at 256
  local p, e, px, py = pin(LIM, { col = 30, row = 4, fx = 8, fy = 8 })
  ok(p.col == 29 and p.fx == 15 and p.row == 4 and p.fy == 8, "past the column limit: fine 15")
  ok(e == 2 and px == (29 * 16 + 15) % 256 and py == 72, "bit 1, SCX wraps")
end

do -- width 10: bits 3 and 2, and bit 1 when the column limit is 0
  local p, e = pin({ w = 10, col = 0, row = 5 }, { col = 3, row = 2, fx = 8, fy = 8 })
  ok(p.col == 0 and p.fx == 0 and p.row == 2 and p.fy == 8 and e == 14, "width 10, column limit 0: flags 8+4+2")
  p, e = pin({ w = 10, col = 5, row = 5 }, { col = 3, row = 2, fx = 8, fy = 8 })
  ok(p.col == 0 and p.fx == 0 and e == 12, "width 10, column limit 5: flags 8+4")
end

do -- row limit 0 pins a positive row to row 0 fine 15 (bits 5 and 6)
  local p, e, px, py = pin({ w = 40, col = 29, row = 0 }, { col = 6, row = 3, fx = 8, fy = 8 })
  ok(p.row == 0 and p.fy == 15 and p.col == 6 and p.fx == 8, "row limit 0: fine 15")
  ok(e == 0x60 and py == 15 and px == 104, "row limit 0: flags $60, SCY 15")
end

do -- row limit $FF, a row at/past limit+10, and a row in [limit, limit+9]
  local p, e, px, py = pin({ w = 40, col = 29, row = 0xFF }, { col = 6, row = 3, fx = 8, fy = 8 })
  ok(p.row == 0 and p.fy == 0 and e == 0xC0 and py == 0 and px == 104, "row limit $FF: bits 7 and 6")
  p, e = pin(LIM, { col = 6, row = 30, fx = 8, fy = 8 })
  ok(p.row == 0 and p.fy == 0 and p.col == 6 and e == 0x40, "row >= limit+10 pins to 0")
  p, e, px, py = pin(LIM, { col = 6, row = 25, fx = 8, fy = 8 })
  ok(p.row == 20 and p.fy == 15 and e == 0x20 and py == (20 * 16 + 15) % 256, "row in [limit, limit+9]: fine 15")
end

do -- header limits 1/0 on a 12-wide map: $84 word $0807, and a row of 255
  local gorge = { w = 12, col = 1, row = 0 }
  local p, e, px, py = pin(gorge, MapCamera.center(2, 3))
  ok(p.col == 1 and p.fx == 15 and p.row == 0 and p.fy == 15, "word $0807 pins to col 1 fine 15, row 0 fine 15")
  ok(e == 0x62 and px == 31 and py == 15, "that pin is flags $62, pixels 31,15")
  p, e, px, py = pin(gorge, { col = 1, row = 255, fx = 8, fy = 8 })
  ok(p.col == 1 and p.fx == 15 and p.row == 0 and p.fy == 0, "row 255 pins to row 0 fine 0")
  ok(e == 0x62 and px == 31 and py == 0, "row 255: flags $62, pixels 31,0")
end

do -- a missing header limit falls back; a stored 0 is kept
  local none = MapCamera.limits({ w = 48, h = 30 })
  ok(none.col == 37 and none.row == 20, "no header bytes: w-11, h-10")
  local zero = MapCamera.limits({ w = 12, h = 22, camCol = 0, camRow = 0 })
  ok(zero.col == 0 and zero.row == 0 and zero.w == 12, "camCol 0 and camRow 0 are kept")
end

local function field(w, h, camCol, camRow, px, py)
  local s = setmetatable({
    def = { w = w, h = h, camCol = camCol, camRow = camRow, cells = {}, block = {} },
    patches = {}, log = {}, objects = {},
    px = (px or 0) * 16, py = (py or 0) * 16,
    ringRecord = function() end, ringApply = function() end,
  }, { __index = Overworld })
  s.vm = { playerCell = function() return px or 0, py or 0 end }
  return s, Overworld.host(s)
end

do -- $84's visible camera is the pin; the logical camera stays the raw store
  local s, h = field(40, 30, 29, 20, 0, 0)
  s.objects[3] = { x = 12, y = 9 }
  h.cameraCell(10, 4)
  ok(s.camFix[1] == 168 and s.camFix[2] == 72 and s.camOff == nil, "$84 inside: camFix 168,72")
  ok(s.mapCam.col == 10 and s.mapCam.fx == 8 and s.mapCam.row == 4 and s.mapCam.fy == 8, "$84 inside: mapCam fine 8")
  h.cameraCell(35, 25)
  ok(s.camFix[1] == 29 * 16 + 15 and s.camFix[2] == 20 * 16 + 15, "$84 past the limits: pin pixels")
  ok(s.mapCam.col == 35 and s.mapCam.row == 25 and s.mapCam.fx == 8, "$84 past the limits: mapCam stays raw")
  ok(s.objects[3].x == 12 and s.objects[3].y == 9, "$84 does not move a placed object")
  h.cameraCell(251, 251)
  ok(s.camFix[1] == 0 and s.camFix[2] == 0, "$84 of 251,251 pins the visible camera to 0,0")
  ok(s.mapCam.col == 251 and s.mapCam.row == 251, "$84 of 251,251 keeps the wrapped store")
  h.cameraCell(-5, -5)
  ok(s.mapCam.col == 251 and s.mapCam.row == 251 and s.camFix[1] == 0 and s.camFix[2] == 0, "word $0000: store 251, visible 0")
end

do -- $82 records the logical camera and leaves the visible camera following the player
  local s, h = field(40, 30, 29, 20, 12, 9)
  s.camFix = { 40, 40 }; s.camOff = { 8, 8 }
  h.centerCamera()
  ok(s.mapCam.col == 7 and s.mapCam.row == 4 and s.mapCam.fx == 8 and s.mapCam.fy == 8, "$82: cell 12,9 → column 7 row 4 fine 8")
  ok(s.camFix == nil and s.camOff == nil, "$82 clears the visible override")
  local x, y = s:cameraXY()
  ok(x == 12 * 16 + 8 - 80 and y == 9 * 16 + 8 - 72, "$82 visible camera follows the player")
  -- two dx=4 pans sum to 8 and the step uses the clamped 4
  s.pans = { { 2, 4, 0 }, { 2, 4, 0 } }
  s:panFrame(); s:panFrame()
  ok(s.mapCam.col == 8 and s.mapCam.fx == 0 and s.mapCam.row == 4 and s.mapCam.fy == 8, "pans step mapCam by the applied delta")
  x = s:cameraXY()
  ok(x == 12 * 16 + 8 - 80 + 8, "the same applied +8 moves the visible camera")
end

do -- $16 posts the scroll and plays the anim; still stays unset
  local function image(bytes)
    local pre = string.rep("\0", 0x12 * 0x4000)
    local s = pre .. string.char(unpack(bytes))
    return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
  end
  local function run16(bytes)
    local anim, pans
    local host = {
      setAnim = function(slot, recs, still) anim = { slot, recs, still } end,
      pan = function(c, dx, dy, carry) pans = { c, dx, dy, carry } end,
    }
    local vm = VM.new(image(bytes), host)
    vm.curSlot = 4
    vm:start(0x12, 0x4000)
    return anim, pans
  end
  local anim, pans = run16({ 0x16, 0x0E, 0xA0, 0x53, 0x04, 0x01, 0x00, 0x00, 0x94 })
  ok(anim and anim[1] == 4 and anim[3] == nil, "$16 setAnim leaves still unset")
  ok(anim[2][1][1] == 0x0E and anim[2][1][2] == 0x53A0 and anim[2][1][3] == 4, "$16 anim record is bank, ptr, frames")
  ok(pans[1] == 4 and pans[2] == 1 and pans[3] == 0 and pans[4] == 4, "$16 pan is 4 frames of +1,0 on slot 4")
  anim, pans = run16({ 0x16, 0x0E, 0xA0, 0x53, 0x04, 0x00, 0xFF, 0x00, 0x94 })
  ok(pans[2] == 0 and pans[3] == -1 and anim[3] == nil, "$16 sy $FF is dy -1, still unset")
end

print(("mn_map_camera: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
