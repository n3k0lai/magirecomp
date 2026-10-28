-- MN_SNAP_TO=c141: a cutscene handing control back in map 141 writes a checkpoint
-- with the map, cell, trigger lists and SRAM and no script to replay (the 135
-- scene's carry2 warp into Ashgar's house has no door to replay). Plain numbers
-- and s-specs do not fire on control. No ROM needed.
--   luajit tests/engine/mn_control_snapshot_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end }, graphics = {}, filesystem = {} } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local M = require("mn.Overworld")
local env = {}
local getenv = os.getenv
os.getenv = function(k) if env[k] ~= nil then return env[k] end return getenv(k) end -- luacheck: ignore 122

local file = os.tmpname()
local function fake(map)
  return setmetatable({ map = map, x = 13, y = 10, facing = "down", triggerPtr = 0x5A10, aList = 0x5A40,
    tonyEnergy = 40, log = {}, vm = { mem = { [0xA123] = 0x0D, [0xA1A5] = 8, [0xC000] = 5 } } }, { __index = M })
end

env.MN_SNAP_TO, env.MN_SNAP_FILE = "c141", file
os.remove(file)
local s = fake(135); s:controlSnapshot()
ok(io.open(file) == nil, "control in 135 does not fire c141")
s = fake(141); s:controlSnapshot()
local snap = loadfile(file) and loadfile(file)()
ok(snap ~= nil, "control in 141 writes the checkpoint")
if snap then
  ok(snap.map == 141 and snap.x == 13 and snap.y == 10, "map and cell")
  ok(snap.bank == nil and snap.ptr == nil, "no script to replay")
  ok(snap.trig == 0x5A10 and snap.alist == 0x5A40, "trigger lists kept")
  ok(snap.mem[0xA1A5] == 8 and snap.mem[0xA123] == 0x0D, "SRAM kept")
  ok(snap.mem[0xC000] == nil, "WRAM dropped")
end
ok(s.log[#s.log]:find("control in 141") ~= nil, "log names the control checkpoint")

for _, spec in ipairs({ "141", "s141" }) do
  env.MN_SNAP_TO = spec; os.remove(file)
  fake(141):controlSnapshot()
  ok(io.open(file) == nil, spec .. " does not fire on control")
end

env.MN_SNAP_TO = "c141:2"; os.remove(file)
s = fake(141); s:controlSnapshot()
ok(io.open(file) == nil, "c141:2 skips the first hand-back")
s:controlSnapshot()
ok(io.open(file) ~= nil, "c141:2 writes on the second")
os.remove(file)

-- plane edits survive the checkpoint: map 134's entry 28:68C1 blits the story
-- 15 door (C2 at 24,18) at control time; MN_LOAD runs no entry script, so the
-- snapshot carries the diff against the stored map and load puts it back
do
  local W, H = 40, 30
  local function plain()
    local d = { w = W, h = H, block = {}, cells = {} }
    for i = 1, W * H do d.block[i] = 0; d.cells[i] = 0x11 end
    return d
  end
  local live = plain()
  live.block[18 * W + 24 + 1] = 0xC2; live.cells[18 * W + 24 + 1] = 0x5A
  local diff = M.planeDiff(live, plain())
  ok(#diff == 1 and diff[1] == ("%d,%d,%d"):format(18 * W + 24, 0xC2, 0x5A), "diff holds only the door cell")
  local saveBase = M.baseMap
  M.baseMap = function() return plain() end
  env.MN_SNAP_TO = "c134"; os.remove(file)
  local s134 = fake(134); s134.def = live; s134:controlSnapshot()
  M.baseMap = saveBase
  local sn = loadfile(file) and loadfile(file)()
  ok(sn and sn.planes and #sn.planes == 3, "checkpoint saves the plane diff")
  local back = setmetatable({ def = plain(), patches = {} }, { __index = M })
  if sn and sn.planes then back:applyPlanes(sn.planes) end
  ok(back.def.block[18 * W + 24 + 1] == 0xC2 and back.def.cells[18 * W + 24 + 1] == 0x5A, "load puts the door back")
  ok(#back.patches == 1 and back.patches[1].x == 24 and back.patches[1].y == 18, "patch drawn at 24,18")
  env.MN_SNAP_TO = "c141"; os.remove(file)
  local s141 = fake(141); s141.def = plain()
  M.baseMap = function() return plain() end
  s141:controlSnapshot(); M.baseMap = saveBase
  sn = loadfile(file) and loadfile(file)()
  ok(sn and sn.planes == nil, "no planes key when nothing changed")
  os.remove(file)
end

-- MN_SNAP_AT: a frame / end checkpoint, written once, without MN_SNAP_TO
do
  env.MN_SNAP_TO = nil; env.MN_SNAP_AT = "end"; env.MN_SNAP_FILE = file; os.remove(file)
  local s186 = fake(186)
  s186:frameSnapshot(100, false)
  ok(io.open(file) == nil, "end checkpoint waits for the last frame")
  s186:frameSnapshot(101, true)
  local sn = loadfile(file) and loadfile(file)()
  ok(sn and sn.map == 186 and sn.trig == 0x5A10 and sn.bank == nil, "end checkpoint is a control checkpoint")
  ok(s186.log[#s186.log]:find("control in 186") ~= nil, "log names the end checkpoint")
  os.remove(file); s186:frameSnapshot(102, true)
  ok(io.open(file) == nil, "end checkpoint fires once")
  env.MN_SNAP_AT = "50"; s186 = fake(186)
  s186:frameSnapshot(49, false)
  ok(io.open(file) == nil, "frame checkpoint waits for frame 50")
  s186:frameSnapshot(50, false)
  ok(io.open(file) ~= nil, "frame checkpoint writes on frame 50")
  os.remove(file); env.MN_SNAP_AT = nil; env.MN_SNAP_FILE = nil
end

print(("mn_control_snapshot: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
