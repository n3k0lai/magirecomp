-- mn.battle: the Magi-Nation battle engine port (src/mn/battle).
-- ROM-free: the seeded / replayed divider source and message rendering.
-- With MN_ROM set (the user's own ROM; nothing from it is committed): the Glade and
-- Korg battles run to an end, replays are bit-identical, a recorded round replays
-- through Rng.replay, and the lobby adapter satisfies the mp-lobby interface.
--   luajit tests/engine/mn_battle_engine_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Rng = require("mn.battle.Rng")
local Data = require("mn.battle.Data")

-- seeded source: same seed, same draws; masks stay in range
do
  local a, b = Rng.seeded(42), Rng.seeded(42)
  local same, inRange = true, true
  for _ = 1, 500 do
    local x, y = a:maskDiv(7), b:maskDiv(7)
    if x ~= y then same = false end
    if x < 0 or x > 7 then inRange = false end
    local s = a:divStep(); b:divStep()
    if s < -3 or s > 4 then inRange = false end
  end
  ok(same, "seeded Rng is deterministic")
  ok(inRange, "MaskDivByC stays under the mask and AddDividerStep in -3..4")
end

-- replay source hands back recorded draws in order and flags a wrong kind
do
  local r = Rng.replay({ { "m", 3 }, { "s", -2 }, { "d", 200 } })
  ok(r:maskDiv(7) == 3, "replay maskDiv")
  ok(r:divStep() == -2, "replay divStep")
  ok(r:div() == 200, "replay div")
  ok(r.i == 3, "replay consumed three draws")
  local r2 = Rng.replay({ { "s", 1 } })
  r2:maskDiv(7)
  ok(r2.err ~= nil, "replay reports a draw of the wrong kind")
end

-- message scripts: $FC substitutes, $FB skips one entry, $FE breaks the line
do
  local d = { texts = { [0x4366] = { 0xFC, 0xFE, 0x66, 0x69, 0x67, 0x68, 0x74, 0x73, 0xFE, 0xFB, 0xFC } } }
  ok(Data.render(d, 0x4366, { "Weebo", "Fight", "Furok" }) == "Weebo\nfights\nFurok", "render FC/FB/FE")
end

local ROM = os.getenv("MN_ROM")
local fh = ROM and io.open(ROM, "rb")
if not fh then
  print(("mn_battle_engine: %d checks, ROM-gated part skipped (set MN_ROM)"):format(checks))
  os.exit(failures == 0 and 0 or 1)
end
fh:close()

local Engine = require("mn.battle.Engine")
local Match = require("mn.battle.Match")
local Sides = require("mn.battle.Sides")
local data = Data.extract(require("mn.MnRom").fromFile(ROM))

ok(#data.moveList == 103, "103 move records at 5:$5EAE")
ok(data.names[0x1C] == "Furok" and data.names[0x53] == "Weebo", "roster names at 6:$5AA6")
local spells, items = 0, 0
for _, p in ipairs(data.groupList) do if data.groups[p].kind == "spell" then spells = spells + 1 else items = items + 1 end end
ok(spells == 19 and items == 27, "19 spells and 27 items")
for _, p in ipairs(data.moveList) do
  local h = data.moves[p].handler
  ok(Engine.HANDLERS[h] or Engine.SPECIAL[h], ("move %04X handler %04X ported"):format(p, h))
end
for _, p in ipairs(data.groupList) do
  ok(Engine.GROUP[data.groups[p].handler], ("group %04X effect ported"):format(p))
end

local GLADE = { magi = 0x6C, party = { { species = 0x1C, spends = 1, energy = 23 } },
  summons = { { slot = 9, species = 0x53, spends = 1, energy = 3, delay = 1 } } }
-- the Korg duel's battle script (14:$4184): op $25 arg3 5, then $AA stores $00 $19
-- at $D33D (Korg starts with 25) and $2E summons BlackAgovo, paying 20 of it
local KORG = { magi = 0x5D, arg3 = 5, party = { { species = 0x1C, spends = 3, energy = 23 } },
  script = { { op = 0xAA, addr = 0xD33D, bank = 7, value = 0x00 }, { op = 0xAA, addr = 0xD33E, bank = 7, value = 0x19 },
    { op = 0x2E, slot = 9, species = 0x08, spends = 5, energy = 0x14, delay = 2 } } }

do -- starting energy comes from the script, not a constant
  local s = Engine.new(data, KORG, Rng.seeded(1))
  local function w(a) return s.m[a] * 256 + s.m[a + 1] end
  ok(w(0xD33D) == 5, ("Korg starts with 25 and pays 20 for BlackAgovo (got %d)"):format(w(0xD33D)))
  ok(s.m[0xD36D] == 5, "op $25 arg3 lands in D36D")
end

do -- relic routines: every record pointer resolves to a translated routine
  local n = 0
  for id = 1, #data.relics do
    local r = data.relics[id]
    for _, f in ipairs({ "onLoad", "onSummon", "onHit" }) do
      ok(Engine.RELIC_OPS[r[f]] ~= nil, ("relic %d %s 7:%04X ported"):format(id, f, r[f]))
    end
    n = n + 1
  end
  ok(n == 36, ("36 relics (got %d)"):format(n))
  -- End Bringer on a fresh record: +25 max energy (current follows), +25 stats, D126 |= 8 | D125
  local s = Engine.new(data, GLADE, Rng.seeded(1))
  for a = 0xD110, 0xD146 do s.m[a] = 0 end
  s.m[0xD119], s.m[0xD11A], s.m[0xD11B], s.m[0xD125], s.m[0xD111] = 0, 0x20, 0x50, 0x02, 0xC5
  Engine.runRelic(s, 9, "onSummon")
  ok(s.m[0xD117] == 0 and s.m[0xD118] == 0x39 and s.m[0xD11A] == 0x39, "End Bringer raises max and current energy to 57")
  ok(s.m[0xD11B] == 0x63, "End Bringer caps a stat at 99")
  ok(s.m[0xD125] == 0x0A and s.m[0xD126] == 0x0A and s.m[0xD111] == 0x35, "End Bringer status bits and D111 nibble")
  -- Corf Pearl floors a stat at 1
  s.m[0xD11B] = 5; Engine.runRelic(s, 6, "onSummon")
  ok(s.m[0xD11B] == 1, "Corf Pearl floors at 1")
end

local function play(setup, seed)
  local m = Match.new(data, setup, { seed = seed, player = Sides.sweep(seed), enemy = Sides.random(seed + 1) })
  local n = 0
  while not m:over() and n < 150 do m:step(); n = n + 1 end
  return m
end

for _, sc in ipairs({ { "Glade", GLADE }, { "Korg duel", KORG } }) do
  for seed = 1, 8 do
    local a, b = play(sc[2], seed), play(sc[2], seed)
    -- the Korg duel can legitimately stall once Furok is gone (Tony cannot attack)
    if sc[1] == "Glade" then ok(a:over(), ("%s seed %d ends"):format(sc[1], seed)) end
    ok(table.concat(a.state.hashes, ",") == table.concat(b.state.hashes, ","),
      ("%s seed %d: per-round hashes repeat"):format(sc[1], seed))
    ok(next(a.state.unimplemented) == nil, ("%s seed %d: no unimplemented effect"):format(sc[1], seed))
  end
end

-- the escape command ends the Glade battle with Tony's energy intact
do
  local s = Engine.new(data, GLADE, Rng.seeded(3))
  local run
  for _, c in ipairs(Engine.legal(s, 0)) do if c.kind == "run" then run = c end end
  ok(run ~= nil, "Run is offered")
  -- AddDividerStep landing on FFA9 & 3 == 3 fails the escape; walk seeds until it works
  for seed = 1, 20 do
    s = Engine.new(data, GLADE, Rng.seeded(seed))
    Engine.choose(s, 0, run)
    Engine.round(s)
    if Engine.over(s) then break end
  end
  ok(s.result == "escape", "Run escapes")
end

-- lobby adapter: interface, legality, and lockstep-equal hashes
do
  local A = require("mn.battle.LobbyAdapter")
  A.configure(data)
  local function go()
    local b = A.new({ seed = 9, sides = { { creatures = { { id = 0x1C } } }, { magi = { id = 0x5D }, creatures = { { id = 0x08 } } } } })
    for _, m in ipairs({ "actions", "step", "hash", "result", "coverage" }) do ok(type(b[m]) == "function", "adapter has " .. m) end
    local hs, turn = {}, 0
    while not b:result() and turn < 60 do
      turn = turn + 1
      local a1, a2 = b:actions(1), b:actions(2)
      ok(#a1 > 0 and #a2 > 0, "both sides always have an action")
      local pick
      for _, a in ipairs(a1) do if a.kind ~= "run" then pick = a end end
      b:step({ pick, a2[(turn % #a2) + 1] })
      hs[#hs + 1] = b:hash()
    end
    return table.concat(hs, ",")
  end
  ok(go() == go(), "adapter hashes repeat for the same actions")
end

print(("mn_battle_engine: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
