-- 01:5D47, mid ResumeOtherLeftCellScript: planted as slot-0 head with a sprite anim
-- (16:7CF5, 19:7DA9, 1B:7B08 $07/$05 00 47 5D + 20:50FB). Bit 6 of $C9A3 with a stale
-- hRecordHead/hScriptPtr always takes .noSide, so the dispatcher is not lifted. Port:
-- drop the stand-in, hide Tony, hold him (turn, A, grass; no pad walk); Walk.screenY
-- is nil. The remaining outlier is a stale double commit (docs/mn-outliers.md).
-- Made-up cells and script bytes only, no ROM bytes.
--   luajit tests/engine/mn_stale_head_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end }, graphics = {} } -- luacheck: ignore 111
local failures, checks = 0, 0
local function ok(c, w) checks = checks + 1; if not c then failures = failures + 1; print("FAIL " .. w) end end

local Overworld = require("mn.Overworld")
local Walk = require("mn.Walk")
local MnRom = require("mn.MnRom")

-- a made-up sprite loop at 20:50FB so the anim field reads as a sprite anim:
-- $4C (1 frame, list $5000), $46 back to itself
local at = 0x20 * 0x4000 + 0x50FB - 0x4000
local img = string.rep("\0", at) .. string.char(0x4C, 0x01, 0x00, 0x00, 0x00, 0x50, 0x00, 0x46, 0xFB, 0x50)
local rom = MnRom.new(img .. string.rep("\0", 0x200000 - #img))

local function vmStub()
  local v = { mem = {}, threads = {}, spawned = {}, rom = rom }
  function v:rd8(a) return self.mem[a] or 0 end
  function v:wr8(a, b) self.mem[a] = b end
  function v:spawnThread(slot, b, ptr) self.spawned[#self.spawned + 1] = { slot, b, ptr } end
  return v
end

-- slot-0 record $00,$5D47 with sprite anim: stand-in goes, Tony hidden, stale head kept
local s = setmetatable({ x = 4, y = 4, objects = { [0] = { x = 1, y = 1 } }, hidePlayer = true, log = {},
  vm = vmStub(), facing = "down" }, { __index = Overworld })
pcall(s:host().spawn, 0, 4, 4, 0x5D47, 0, 0x20, 0x50FB, 0x22, 0x4005)
ok(s.objects[0] == nil, "$5D47 slot-0 record drops the stand-in")
ok(s.hidePlayer == true, "Tony stays hidden")
ok(s.padHead == 0x5D47 and s.tonyHead == 0x5D47, "the $5D47 head is kept")
ok(Walk.screenY(s, 0, nil) == nil, "Walk.screenY is nil while he is hidden")

-- field: held direction turns, does not move; A tests the faced cell
local W, H = 7, 7
local block = {}
for i = 1, W * H do block[i] = 0x00 end
local function set(x, y, v) block[y * W + x + 1] = v end
set(4, 3, 0x41) -- cell to the right of 3,3
local ran = {}
local function field()
  local o = setmetatable({ def = { w = W, h = H, block = block }, vm = vmStub(), objects = {}, log = {},
    x = 3, y = 3, facing = "left", padHead = 0x5D47, hidePlayer = true, aList = 0x5000 }, { __index = Overworld })
  o.listEntry = function(_, ptr, idx) return nil, 0x15, 0x6000 + idx end
  o.runScript = function(_, b, p, why) ran[#ran + 1] = { b, p, why } end
  function o:snap() self.px, self.py = self.x * 16, self.y * 16 end
  return o
end

local o = field()
o.input = function(k) return k == "dir" and "right" or nil end
o:stalePass()
ok(o.x == 3 and o.y == 3 and not o.moving, "a held direction does not walk")
ok(o.facing == "right", "a held direction turns Tony")

ran = {}
o.input = function(k) return k == "a" or nil end
o:stalePass()
ok(#ran == 1 and ran[1][1] == 0x15 and ran[1][2] == 0x6001, "A runs list entry from the faced cell")
ok(o.hidePlayer == true, "he stays hidden after A")

-- setTonyHead($5D47) from $07 also hides
local t = setmetatable({ objects = {}, log = {}, vm = vmStub(), hidePlayer = false }, { __index = Overworld })
t:setTonyHead(0x5D47)
ok(t.padHead == 0x5D47 and t.hidePlayer == true, "$07 00 47 5D hides Tony")
t:setTonyHead(0x5D81)
ok(t.padHead == 0x5D81 and t.hidePlayer == false, "a real pad head shows him again")

print(("mn_stale_head: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
