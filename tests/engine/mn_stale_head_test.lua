-- 01:5D47, mid ResumeOtherLeftCellScript (the PixelWalk up head at $5D3E + 9).
-- WalkPointerSlots loads A from the head's low byte ($47) before JumpHL, so bit 6
-- is clear and the up-release path runs: hScriptPtr := $5BBF (idle script 20:5BBF
-- when bank $20 is still set), PlantDownBit7ClearHead ($5B5B) plants head $5B6E
-- and commits. Sites that plant it (16:7CF5, 19:7DA9, 1B:7B08 $05/$07 00 47 5D +
-- 20:50FB) therefore land Tony on the PixelWalk idle family, same as $5B41.
-- Made-up cells and script bytes only, no ROM bytes.
--   luajit tests/engine/mn_stale_head_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end }, graphics = {} } -- luacheck: ignore 111
local failures, checks = 0, 0
local function ok(c, w) checks = checks + 1; if not c then failures = failures + 1; print("FAIL " .. w) end end

local Overworld = require("mn.Overworld")
local PixelWalk = require("mn.PixelWalk")
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

-- slot-0 record $00,$5D47 with sprite anim: stand-in goes, Tony shown on PixelWalk
local s = setmetatable({ x = 4, y = 4, objects = { [0] = { x = 1, y = 1 } }, hidePlayer = true, log = {},
  vm = vmStub(), facing = "down" }, { __index = Overworld })
pcall(s:host().spawn, 0, 4, 4, 0x5D47, 0, 0x20, 0x50FB, 0x22, 0x4005)
ok(s.objects[0] == nil, "$5D47 slot-0 record drops the stand-in")
ok(s.hidePlayer == false, "Tony is shown")
ok(s.padHead == PixelWalk.HEAD, "pad family is PixelWalk ($5B41)")
ok(s.tonyHead == 0x5B6E, "record head becomes $5B6E (PlantDownBit7ClearHead)")

-- $07 00 47 5D trampolines the same way
local t = setmetatable({ objects = {}, log = {}, vm = vmStub(), hidePlayer = true }, { __index = Overworld })
t:setTonyHead(0x5D47)
ok(t.padHead == PixelWalk.HEAD and t.tonyHead == 0x5B6E and t.hidePlayer == false,
  "$07 00 47 5D -> PixelWalk idle")
t:setTonyHead(0x5B6E)
ok(t.padHead == PixelWalk.HEAD and t.tonyHead == 0x5B6E, "planting $5B6E is PixelWalk idle")
t:setTonyHead(0x5D81)
ok(t.padHead == 0x5D81 and t.hidePlayer == false, "a normal pad head still shows him")

print(("mn_stale_head: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
