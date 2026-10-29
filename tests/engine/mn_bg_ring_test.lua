-- BG map ring: $9800 holds 16 x 16 metatile cells, cell (x, y) at slot
-- (x & 15, y & 15) (BuildMetatilePointers 07:4C53). $82/$84 only move
-- wMapColumn/wMapRow (StoreMapCellFromDEMinus5); with the LCD on nothing redraws,
-- so each on-screen cell shows its ring slot until the seam draws it again.
-- $93's DrawMetatileWindow redraws the view. Made-up map, no ROM bytes.
--   luajit tests/engine/mn_bg_ring_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Overworld = require("mn.Overworld")
local ROM = MnRom.new(string.rep("\0", 0x200000))

local W, H = 48, 30
local function world()
  local cells, block = {}, {}
  for i = 0, W * H - 1 do cells[i + 1] = i % W; block[i + 1] = 0 end
  local s = setmetatable({ def = { w = W, h = H, cells = cells, block = block }, patches = {}, log = {},
    objects = {}, px = 5 * 16, py = 5 * 16 }, { __index = Overworld })
  local h = Overworld.host(s)
  s.vm = VM.new(ROM, h); s.vm.init = false
  return s, h
end
local function at(s, x, y) -- last overlay at a cell, or nil
  local v; for _, p in ipairs(s.patches) do if p.x == x and p.y == y then v = p.mt end end
  return v
end

do -- slot arithmetic
  local s = world()
  s:ringRecord()
  ok(s.ring[4 * 16 + 3] == 3, "cell (3,4) recorded at slot (3,4)")
end

do -- LCD on: $84 jumps 16 columns east, the view shows the old cells
  local s, h = world()
  s:ringFrame() -- view cols 0..9 recorded
  h.cameraCell(16, 0) -- camFix 256,0: cols 16..25
  ok(at(s, 16, 2) == 0, "(16,2) shows slot 0: the old column 0")
  ok(at(s, 25, 2) == 9, "(25,2) shows slot 9: the old column 9")
  ok(s.bgStale and s.bgStale[2 * W + 16], "(16,2) is stale")
  ok(at(s, 26, 2) == nil, "(26,2) is off screen")
  h.cameraCell(30, 0) -- on to cols 30..39: the stale cells left the view
  s:flushStale()
  ok(at(s, 16, 2) == 16, "off screen, the seam shows WRAM 3 at (16,2)")
end

do -- slots the view never covered keep the last cell recorded there
  local s, h = world()
  s:ringFrame()
  s.camFix = { 6 * 16, 0 }; s:ringFrame() -- cols 6..15 recorded: slots 6..15
  h.cameraCell(20, 0) -- cols 20..29: slots 4..13
  ok(at(s, 20, 2) == 4, "slot 4 still holds column 4")
  ok(at(s, 22, 2) == 6, "slot 6 holds column 6")
  ok(at(s, 29, 2) == 13, "slot 13 holds column 13")
end

do -- LCD off ($93 until the park): no ring effect, and the view is redrawn
  local s, h = world()
  s:ringFrame()
  s.vm.startupPending = true; s.vm:wr8(0xC936, 0) -- $93: TurnOffLCD (wLCDC)
  h.cameraCell(16, 0)
  ok(#s.patches == 0, "LCD off: the jump shows nothing stale")
  s.vm.startupPending = nil; s.vm:wr8(0xC936, 0xE3) -- the park: TurnOnLCD
  s:ringFrame()
  ok(s.bgStale == nil, "nothing stale after DrawMetatileWindow")
end

do -- $93 within one pass: DrawMetatileWindow clears what is stale on screen
  local s, h = world()
  s:ringFrame()
  h.cameraCell(16, 0)
  ok(s.bgStale ~= nil, "stale after the jump")
  h.lcdOff(); s:ringFrame()
  ok(at(s, 16, 2) == 16 and s.bgStale == nil, "the full draw shows WRAM 3")
end

do -- a store's redraw and a patch keep shownAt in step
  local s = world()
  s:patch(3, 3, 0x77)
  ok(s:shownAt(3, 3) == 0x77, "shownAt reads the overlay")
  ok(s:shownAt(4, 3) == 4, "shownAt falls back to the plane")
end

do -- $82/$84 store wMapColumn/Row and the fine bytes outright (center_fine_scroll_on_script_base.asm,
  -- StoreMapCellFromDEMinus5): a $16/$83 scroll offset from before does not carry over
  local s, h = world()
  s.px, s.py = 20 * 16, 12 * 16
  local bx, by = s:cameraXY()
  s.camOff = { 32, -16 }
  local ox = s:cameraXY()
  ok(ox == bx + 32, "the scroll offset moves the camera")
  h.centerCamera()
  local cx, cy = s:cameraXY()
  ok(s.camOff == nil and cx == bx and cy == by, "$82: camera back on the script base, offset gone")
  s.camOff = { 48, 0 }
  h.cameraCell(10, 4)
  cx, cy = s:cameraXY()
  ok(s.camOff == nil and cx == 160 and cy == 64, "$84: camera at the given cell, offset gone")
end

print(("mn_bg_ring: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
