-- Animite after a won battle (bank 5 ApplyHalfD06CThenMaybeScan -> bank 7
-- AddC9FEToMapWord0): ($D06C >> 1) + 1 joins the word at $A3A5, capped at 999,
-- and the message shows the amount actually added. The port used to print raw
-- $D06C and never add it, so Tony stayed at 55 Animite and could not pay the
-- ferry fare (300, 2A:5181) on the way to Orothe.
--   luajit tests/engine/mn_battle_animite_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Engine = require("mn.battle.Engine")

local t, g = Engine.awardAnimite(55, 20)
ok(t == 66 and g == 11, "55 + (20 >> 1) + 1 = 66")
t, g = Engine.awardAnimite(0, 0)
ok(t == 1 and g == 1, "a zero $D06C still adds 1")
t, g = Engine.awardAnimite(100, 0xFF)
ok(t == 228 and g == 128, "$FF adds $80")
t, g = Engine.awardAnimite(990, 40)
ok(t == 999 and g == 9, "capped at 999, gain is what was stored")
t, g = Engine.awardAnimite(999, 40)
ok(t == 999 and g == 0, "already at the cap: nothing added, no message")

-- Battle.setupFrom reads the word and Battle:finish writes the total back.
love = love or {} -- luacheck: ignore 111
local okB, Battle = pcall(require, "mn.Battle")
if okB then
  local mem = { [0xA3A5] = 0x2C, [0xA3A6] = 0x01 } -- 300
  local vm = { rd8 = function(_, a) return mem[a] or 0 end, wr8 = function(_, a, v) mem[a] = v end }
  local party = Battle.party; Battle.party = function() return {} end -- no ROM data here
  local setup = Battle.setupFrom({ vm = vm }, { args = {} }, {})
  Battle.party = party
  ok(setup.animite == 300, "setupFrom reads Animite from $A3A5")
  local fake = setmetatable({ ow = { vm = vm }, state = { animiteTotal = 311, animiteGain = 11, items = {}, m = setmetatable({}, { __index = function() return 0 end }) },
    fade = function() end, L = function() end }, { __index = Battle })
  local saved = Battle.GOD; Battle.GOD = true
  local okF, err = pcall(Battle.finish, fake, "win")
  Battle.GOD = saved
  ok(okF, "finish runs: " .. tostring(err))
  ok(mem[0xA3A5] == 311 % 256 and mem[0xA3A6] == 1, "finish stores the new total even under MN_GOD")
end

print(("%d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
