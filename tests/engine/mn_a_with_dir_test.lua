-- ResumePlantedHead6167 (01:6167) tests the held directions ($C9A3 bits 4-7) first
-- and jumps away to their plants; a newly pressed A ($C9A4 bit 0) is dispatched only
-- when no direction is held. A pressed while a direction is held is dropped.
-- Made-up map, no ROM bytes.
--   luajit tests/engine/mn_a_with_dir_test.lua
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

local function fake(keys)
  local block = {}
  for i = 1, 25 do block[i] = 0 end
  local s = setmetatable({
    def = { w = 5, h = 5, block = block, triggers = {} }, x = 2, y = 2, px = 32, py = 32,
    facing = "up", objects = {}, log = {}, map = 1, sfxOut = { update = function() end },
    talks = {},
  }, { __index = Overworld })
  s.vm = VM.new(ROM, {})
  s.input = function(k) return keys[k] end
  -- an NPC on the faced cell (2,1) with a talk script
  s.objects[3] = { x = 2, y = 1, talk = { 0x12, 0x4000 } }
  s.runScript = function(self, b, p, why) self.talks[#self.talks + 1] = why end
  return s
end

do -- A alone: the faced record talks
  local s = fake({ a = true })
  s:update()
  ok(#s.talks == 1 and s.talks[1] == "talk to slot 3", "A with no direction dispatches on the faced cell")
  ok(not s.moving, "A alone does not step")
end

do -- A while right is held: the direction plant runs, the A is dropped
  local s = fake({ a = true, dir = "right" })
  s:update()
  ok(#s.talks == 0, "A while a direction is held is dropped")
  ok(s.moving == "right" and s.x == 3, "the held direction is handled")
end

do -- A while the faced direction (up, toward the NPC) is held: a bump, still no talk
  local s = fake({ a = true, dir = "up" })
  s:update()
  ok(#s.talks == 0, "A while holding toward the record is still dropped")
end

do -- on the $02 layer the record head is 4F0D/4FB7/5061/510B: A (bit 0) is never read
  local s = fake({ a = true })
  s.layer, s.layerDir = 2, nil
  s:update()
  ok(#s.talks == 0, "A on the $02 layer does not dispatch on the faced cell")
end

print(("mn_a_with_dir: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
