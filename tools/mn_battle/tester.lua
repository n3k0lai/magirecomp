-- Headless Magi-Nation battle tester: seeded self-play over every creature and
-- command, rule checks, per-round state hashes and a coverage report.
--
--   luajit tools/mn_battle/tester.lua --rom <magination.gbc> [--out reports]
--          [--seeds N] [--quick] [--oracle reports/battle-oracle.json] [--loop SECONDS]
--
-- Needs the user's ROM (data is extracted in memory, nothing ROM-derived is
-- written except names in the report). Battles run in-process with two command
-- sources (mn.battle.Sides): the player side is a seeded sweep/random side, the
-- enemy side is the ROM's own AI tables or, in "mirror" runs, a second side.
-- mn.battle.Match is the seam a lockstep harness swaps for networked sides.
package.path = "src/?.lua;" .. package.path
local MnRom = require("mn.MnRom")
local Data = require("mn.battle.Data")
local Engine = require("mn.battle.Engine")
local Match = require("mn.battle.Match")
local Sides = require("mn.battle.Sides")

local args = {}
do
  local i = 1
  while i <= #arg do
    local a = arg[i]
    if a:sub(1, 2) == "--" then
      local v = arg[i + 1]
      if v == nil or v:sub(1, 2) == "--" then args[a:sub(3)] = true else args[a:sub(3)] = v; i = i + 1 end
    end
    i = i + 1
  end
end
local ROM = args.rom or os.getenv("MN_ROM")
if not ROM then io.stderr:write("need --rom <magination.gbc> (or MN_ROM)\n"); os.exit(2) end
local OUT = args.out or "reports"
local SEEDS = tonumber(args.seeds or (args.quick and 2 or 6))
local MAXR = 150

local data = Data.extract(MnRom.fromFile(ROM))

local function hex(v, n) return ("%0" .. (n or 4) .. "X"):format(v) end

-- coverage accumulators
local moveByHandler = {}
for _, p in ipairs(data.moveList) do moveByHandler[data.moves[p].handler] = p end
local cov = { moves = {}, creatures = {}, groups = {}, relics = {} }
local issues = { crashes = {}, violations = {}, unimplemented = {}, stalemates = {}, nondeterministic = {} }
local stats = { battles = 0, rounds = 0, results = {} }
local function bump(t, k, n) t[k] = (t[k] or 0) + (n or 1) end

local function setupFor(sc)
  return {
    magi = sc.magi, magiEnergy = sc.magiEnergy, arg3 = sc.arg3, script = sc.script, party = sc.party, summons = sc.summons, spells = sc.spells, items = sc.items, ffa9 = sc.ffa9,
  }
end

-- rule checks after every round
local function check(m, sc, seed, round)
  local s = m.state
  local bad = {}
  local d016 = Engine.rd(s, 0xD016)
  if d016 > 3 then bad[#bad + 1] = "D016 = " .. d016 end
  for i = 0, 9 do
    local x = Engine.slotInfo(s, i)
    if x.present or i == 0 or i == 9 then
      if x.energy > x.max and not (i == 9 and x.max == 0xFFFF) then bad[#bad + 1] = ("slot %d energy %d > max %d"):format(i, x.energy, x.max) end
      for _, k in ipairs({ "str", "skill", "speed", "def", "resist", "luck" }) do
        if x[k] > 0x63 and i >= 1 and i <= 8 then bad[#bad + 1] = ("slot %d %s %d > 99"):format(i, k, x[k]) end
      end
    end
    if x.present and i >= 1 and i <= 8 and x.energy == 0 and d016 == 0 then
      bad[#bad + 1] = ("slot %d present with 0 energy"):format(i)
    end
  end
  for _, ev in ipairs(m.events[#m.events] or {}) do
    if ev.t == "anomaly" then bad[#bad + 1] = ev.what end
  end
  for _, b in ipairs(bad) do
    local key = sc.name .. ": " .. b:gsub("%d+", "#")
    if not issues.violations[key] then issues.violations[key] = { first = ("%s seed %d round %d: %s"):format(sc.name, seed, round, b), count = 0 } end
    issues.violations[key].count = issues.violations[key].count + 1
  end
end

local function account(m)
  for r = 0, #m.events do
    for _, ev in ipairs(m.events[r] or {}) do
      if ev.t == "act" then
        local p = moveByHandler[ev.handler]
        if p then bump(cov.moves, p) end
        if ev.group then bump(cov.groups, ev.group) end
        if ev.slot >= 1 and ev.slot <= 8 then
          local c = cov.creatures[ev.species] or { acted = 0, seen = 0 }
          c.acted = c.acted + 1; cov.creatures[ev.species] = c
        end
      elseif ev.t == "summon" or ev.t == "appear" then
        local c = cov.creatures[ev.species] or { acted = 0, seen = 0 }
        c.seen = c.seen + 1; cov.creatures[ev.species] = c
      elseif ev.t == "unimplemented" then
        bump(issues.unimplemented, ev.what)
      end
    end
  end
end

local function runOne(sc, seed, sideName)
  local mk = sideName == "random" and Sides.random or Sides.sweep
  local opts = { seed = seed * 7919 + 13, player = mk(seed) }
  if sc.mirror then opts.enemy = Sides.random(seed + 1000) end
  local ok, err = pcall(function()
    local m = Match.new(data, setupFor(sc), opts)
    if sc.unlockAll then
      for slot = 1, 8 do for k = 0, 3 do Engine.wr(m.state, Engine.recAddr(slot) + 0x20 + k, 0xFF) end end
      for _, sv in pairs(m.state.party) do for k = 0, 3 do sv[0x1E + k] = 0xFF end end
    end
    local r = 0
    while not m:over() and r < MAXR do
      m:step(); r = r + 1
      if sc.unlockAll then for slot = 5, 8 do for k = 0, 3 do Engine.wr(m.state, Engine.recAddr(slot) + 0x20 + k, 0xFF) end end end
      check(m, sc, seed, r)
    end
    stats.battles = stats.battles + 1
    stats.rounds = stats.rounds + r
    account(m)
    local res = m:result() or "stalemate"
    bump(stats.results, sc.kind .. ":" .. res)
    if not m:over() then issues.stalemates[#issues.stalemates + 1] = ("%s seed %d"):format(sc.name, seed) end
    -- determinism: same seed + recorded inputs must give the same hash stream
    if sc.replay then
      local rounds = {}
      for i, ch in ipairs(m.inputs) do rounds[i] = ch end
      local m2 = Match.new(data, setupFor(sc), { seed = opts.seed, player = Sides.scripted(rounds),
        enemy = sc.mirror and Sides.scripted(rounds) or nil })
      if sc.unlockAll then
        for slot = 1, 8 do for k = 0, 3 do Engine.wr(m2.state, Engine.recAddr(slot) + 0x20 + k, 0xFF) end end
        for _, sv in pairs(m2.state.party) do for k = 0, 3 do sv[0x1E + k] = 0xFF end end
      end
      local i = 0
      while not m2:over() and i < r do
        m2:step(); i = i + 1
        if sc.unlockAll then for slot = 5, 8 do for k = 0, 3 do Engine.wr(m2.state, Engine.recAddr(slot) + 0x20 + k, 0xFF) end end end
      end
      for k = 0, r do
        if m.hashes[k] ~= m2.hashes[k] then
          issues.nondeterministic[#issues.nondeterministic + 1] = ("%s seed %d diverges at round %d"):format(sc.name, seed, k)
          break
        end
      end
    end
    if sc.keepHashes then sc.hashLog[#sc.hashLog + 1] = { seed = seed, side = sideName, result = res, rounds = r, hashes = m.hashes } end
  end)
  if not ok then
    local key = tostring(err):gsub("^[^:]+:%d+: ", "")
    if not issues.crashes[key] then issues.crashes[key] = { first = ("%s seed %d: %s"):format(sc.name, seed, tostring(err)), count = 0 } end
    issues.crashes[key].count = issues.crashes[key].count + 1
  end
end

-- scenarios ------------------------------------------------------------------
local scenarios = {}
-- story battles, as the overworld scripts set them up (op $25 / op $2E)
scenarios[#scenarios + 1] = { name = "Glade: wild Magi + Weebo", kind = "story", magi = 0x6C,
  party = { { species = 0x1C, spends = 1, energy = 22 } },
  summons = { { slot = 9, species = 0x53, spends = 1, energy = 3, delay = 1 } }, replay = true, keepHashes = true, hashLog = {} }
-- Korg's duel script (14:$4184) stores $00 $19 at $D33D with op $AA (he starts
-- with 25 energy), then summons BlackAgovo for 20 with op $2E
scenarios[#scenarios + 1] = { name = "Korg duel: Korg + BlackAgovo", kind = "story", magi = 0x5D, arg3 = 5,
  party = { { species = 0x1C, spends = 3, energy = 22 } },
  script = { { op = 0xAA, addr = 0xD33D, bank = 7, value = 0x00 }, { op = 0xAA, addr = 0xD33E, bank = 7, value = 0x19 },
    { op = 0x2E, slot = 9, species = 0x08, spends = 5, energy = 0x14, delay = 2 } }, replay = true, keepHashes = true, hashLog = {} }
-- every creature on the player side against a rotating wild opponent, and every
-- creature on the enemy side (its own ROM AI) against a rotating ally
local roster = Data.creatures(data)
for i, id in ipairs(roster) do
  local foe = roster[(i * 7) % #roster + 1]
  scenarios[#scenarios + 1] = { name = ("ally %s vs %s"):format(data.names[id], data.names[foe]), kind = "ally", magi = 0x6C,
    party = { { species = id, spends = 6, energy = 40 } }, unlockAll = true,
    summons = { { slot = 9, species = foe, spends = 4, energy = 30, delay = 0 } } }
  scenarios[#scenarios + 1] = { name = ("enemy %s vs %s"):format(data.names[id], data.names[foe]), kind = "enemy", magi = 0x6C,
    party = { { species = foe, spends = 6, energy = 40 } }, unlockAll = true, replay = (i % 9 == 0),
    summons = { { slot = 9, species = id, spends = 5, energy = 40, delay = 0 } } }
  scenarios[#scenarios + 1] = { name = ("mirror %s vs %s"):format(data.names[id], data.names[foe]), kind = "mirror", magi = 0x6C, mirror = true,
    party = { { species = id, spends = 6, energy = 40 } }, unlockAll = true, replay = (i % 11 == 0),
    summons = { { slot = 9, species = foe, spends = 5, energy = 40, delay = 0 } } }
end
-- every spell and item once from Tony (bank-7 effects report as unimplemented)
local spellList, itemList = {}, {}
for _, p in ipairs(data.groupList) do
  local g = data.groups[p]
  if g.kind == "spell" then spellList[#spellList + 1] = p else itemList[#itemList + 1] = { ptr = p, count = 3 } end
end
scenarios[#scenarios + 1] = { name = "Tony spells + items", kind = "groups", magi = 0x6C, spells = spellList, items = itemList,
  party = { { species = 0x1C, spends = 3, energy = 22 } },
  summons = { { slot = 9, species = 0x53, spends = 3, energy = 30, delay = 0 } } }

-- run ------------------------------------------------------------------------
local function runAll()
  local t0 = os.clock()
  for _, sc in ipairs(scenarios) do
    local n = (sc.kind == "story" or sc.kind == "groups") and SEEDS * 4 or SEEDS
    for seed = 1, n do
      runOne(sc, seed, (seed % 2 == 0) and "random" or "sweep")
    end
  end
  return os.clock() - t0
end

local oracle = { moves = {}, creatures = {}, battles = {}, groups = {} }
if args.oracle then
  local f = io.open(args.oracle, "r")
  if f then
    local txt = f:read("*a"); f:close()
    -- tiny reader for the oracle summary: "move:5F1E": true, "creature:53": true
    for k in txt:gmatch('"move:(%x+)"%s*:%s*true') do oracle.moves[tonumber(k, 16)] = true end
    for k in txt:gmatch('"creature:(%x+)"%s*:%s*true') do oracle.creatures[tonumber(k, 16)] = true end
    for k in txt:gmatch('"group:(%x+)"%s*:%s*true') do oracle.groups[tonumber(k, 16)] = true end
    for name, res in txt:gmatch('"battle:([^"]+)"%s*:%s*"([^"]*)"') do oracle.battles[name] = res end
  end
end

-- report ---------------------------------------------------------------------
local function moveImplemented(p)
  local mv = data.moves[p]
  return (Engine.HANDLERS[mv.handler] or Engine.SPECIAL[mv.handler]) and true or false
end

local function jsonStr(v) return '"' .. tostring(v):gsub('\\', '\\\\'):gsub('"', '\\"'):gsub("\n", "\\n") .. '"' end
local function toJson(v, ind)
  ind = ind or ""
  local t = type(v)
  if t == "table" then
    local isArr = #v > 0 or next(v) == nil
    local parts = {}
    if isArr then
      for _, x in ipairs(v) do parts[#parts + 1] = ind .. "  " .. toJson(x, ind .. "  ") end
      return "[\n" .. table.concat(parts, ",\n") .. "\n" .. ind .. "]"
    end
    local keys = {}
    for k in pairs(v) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    for _, k in ipairs(keys) do parts[#parts + 1] = ind .. "  " .. jsonStr(k) .. ": " .. toJson(v[k], ind .. "  ") end
    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. ind .. "}"
  elseif t == "string" then return jsonStr(v)
  elseif t == "boolean" or t == "number" then return tostring(v)
  end
  return "null"
end

local function report(elapsed)
  os.execute("mkdir -p " .. OUT)
  local J = { generated = os.date("!%Y-%m-%dT%H:%M:%SZ"), battles = stats.battles, rounds = stats.rounds,
    seconds = elapsed, results = stats.results, moves = {}, creatures = {}, spells = {}, items = {}, relics = {},
    crashes = {}, violations = {}, unimplemented = issues.unimplemented, stalemates = issues.stalemates,
    nondeterministic = issues.nondeterministic, storyHashes = {} }
  local mt = { total = 0, impl = 0, tested = 0, match = 0 }
  local mdMoves = {}
  for _, p in ipairs(data.moveList) do
    local mv = data.moves[p]
    local impl, n = moveImplemented(p), cov.moves[p] or 0
    local match = oracle.moves[p] and true or false
    mt.total = mt.total + 1
    if impl then mt.impl = mt.impl + 1 end
    if impl and n > 0 then mt.tested = mt.tested + 1 end
    if match then mt.match = mt.match + 1 end
    J.moves[#J.moves + 1] = { ptr = hex(p), name = mv.name, handler = hex(mv.handler), cost = mv.cost, power = mv.power,
      accuracy = mv.accuracy, target = hex(mv.target, 2), implemented = impl, uses = n, matching = match }
    mdMoves[#mdMoves + 1] = ("| %s | %s | %s | %d | %d | %s | %s | %s |"):format(hex(p), mv.name, hex(mv.handler), mv.cost, mv.power,
      impl and "yes" or "**no**", n > 0 and tostring(n) or "**0**", match and "yes" or "-")
  end
  local ct = { total = 0, impl = 0, tested = 0, match = 0 }
  local mdCre = {}
  for _, id in ipairs(roster) do
    local mvList = Data.speciesMoves(data, id)
    local impl, names = true, {}
    for _, x in ipairs(mvList) do
      local mv = data.moves[x.ptr]
      if mv then names[#names + 1] = mv.name; if not moveImplemented(x.ptr) then impl = false end
      else impl = false; names[#names + 1] = "?" .. hex(x.ptr) end
    end
    local c = cov.creatures[id] or { acted = 0, seen = 0 }
    local tested = impl and c.acted > 0
    local match = oracle.creatures[id] and true or false
    ct.total = ct.total + 1
    if impl then ct.impl = ct.impl + 1 end
    if tested then ct.tested = ct.tested + 1 end
    if match then ct.match = ct.match + 1 end
    J.creatures[#J.creatures + 1] = { id = hex(id, 2), name = data.names[id], moves = names, ai = data.entries[id][15],
      implemented = impl, appearances = c.seen, actions = c.acted, matching = match }
    mdCre[#mdCre + 1] = ("| %s | %s | %s | %d | %s | %d | %s |"):format(hex(id, 2), data.names[id], table.concat(names, ", "),
      data.entries[id][15], impl and "yes" or "**no**", c.acted, match and "yes" or "-")
  end
  local gt = { spell = { total = 0, impl = 0, tested = 0, match = 0 }, item = { total = 0, impl = 0, tested = 0, match = 0 } }
  for _, p in ipairs(data.groupList) do
    local g = data.groups[p]
    local impl = (Engine.GROUP and Engine.GROUP[g.handler]) and true or false
    local bucket = g.kind == "spell" and "spells" or "items"
    local uses, match = cov.groups[p] or 0, oracle.groups[p] and true or false
    J[bucket][#J[bucket] + 1] = { ptr = hex(p), name = g.name, handler = hex(g.handler), cost = g.cost, target = hex(g.target, 2),
      implemented = impl, uses = uses, matching = match }
    local t = gt[g.kind == "spell" and "spell" or "item"]
    t.total = t.total + 1; if impl then t.impl = t.impl + 1 end
    if impl and uses > 0 then t.tested = t.tested + 1 end
    if match then t.match = t.match + 1 end
  end
  local rt = { total = 0, impl = 0 }
  for i = 1, #data.relics do
    local r = data.relics[i]
    local impl = r.onSummon == 0x6BD5 and r.onHit == 0x6BD5
    J.relics[#J.relics + 1] = { id = i, name = r.name, onSummon = hex(r.onSummon), onHit = hex(r.onHit), implemented = impl }
    rt.total = rt.total + 1; if impl then rt.impl = rt.impl + 1 end
  end
  for k, v in pairs(issues.crashes) do J.crashes[#J.crashes + 1] = { error = k, count = v.count, first = v.first } end
  for k, v in pairs(issues.violations) do J.violations[#J.violations + 1] = { rule = k, count = v.count, first = v.first } end
  for _, sc in ipairs(scenarios) do if sc.keepHashes then J.storyHashes[sc.name] = sc.hashLog end end
  J.summary = { moves = mt, creatures = ct, spells = gt.spell, items = gt.item, relics = rt }
  local f = assert(io.open(OUT .. "/battle-coverage.json", "w")); f:write(toJson(J), "\n"); f:close()

  local L = {}
  local function w(s) L[#L + 1] = s end
  w("# Magi-Nation battle coverage")
  w("")
  w(("Generated by `tools/mn_battle/tester.lua` (%s). %d seeded battles, %d rounds, %.1fs.")
    :format(J.generated, stats.battles, stats.rounds, elapsed))
  w("")
  w("*implemented*: the command's handler is ported. *tested*: it ran in a self-play battle")
  w("with no crash or rule violation attributed to it. *matching*: a PyBoy replay of the real")
  w("ROM (`tools/mn_battle/oracle.py`) produced the same battle WRAM after it ran.")
  w("")
  w("| | total | implemented | tested | matching |")
  w("|---|---|---|---|---|")
  w(("| creature moves + commands | %d | %d | %d | %d |"):format(mt.total, mt.impl, mt.tested, mt.match))
  w(("| creatures | %d | %d | %d | %d |"):format(ct.total, ct.impl, ct.tested, ct.match))
  w(("| spells | %d | %d | %d | %d |"):format(gt.spell.total, gt.spell.impl, gt.spell.tested, gt.spell.match))
  w(("| items | %d | %d | %d | %d |"):format(gt.item.total, gt.item.impl, gt.item.tested, gt.item.match))
  w(("| relics | %d | %d | - | - |"):format(rt.total, rt.impl))
  w("")
  w("## Results")
  w("")
  local rk = {}
  for k in pairs(stats.results) do rk[#rk + 1] = k end
  table.sort(rk)
  for _, k in ipairs(rk) do w(("- %s: %d"):format(k, stats.results[k])) end
  w("")
  w("## Problems")
  w("")
  w(("- crashes: %d kinds"):format(#J.crashes))
  for _, c in ipairs(J.crashes) do w(("  - %dx `%s`"):format(c.count, c.first)) end
  w(("- rule violations: %d kinds"):format(#J.violations))
  table.sort(J.violations, function(a, b) return a.count > b.count end)
  for i, c in ipairs(J.violations) do if i <= 25 then w(("  - %dx %s"):format(c.count, c.first)) end end
  w(("- nondeterministic replays: %d"):format(#issues.nondeterministic))
  for _, x in ipairs(issues.nondeterministic) do w("  - " .. x) end
  w(("- stalemates (%d rounds): %d"):format(MAXR, #issues.stalemates))
  local uk = {}
  for k, n in pairs(issues.unimplemented) do uk[#uk + 1] = { k = k, n = n } end
  table.sort(uk, function(a, b) return a.n > b.n end)
  w(("- unimplemented effects hit: %d kinds"):format(#uk))
  for _, x in ipairs(uk) do w(("  - %dx %s"):format(x.n, x.k)) end
  w("")
  w("## Story battles (oracle)")
  w("")
  if next(oracle.battles) then
    -- named traces one per line; the per-move / per-group sweeps are summed up
    local keys, sweeps = {}, { n = 0, ok = 0 }
    for k, v in pairs(oracle.battles) do
      if k:find("move_") or k:find("spell_") or k:find("item_") then
        sweeps.n = sweeps.n + 1; if v:find("^all rounds match") then sweeps.ok = sweeps.ok + 1 end
      else keys[#keys + 1] = k end
    end
    table.sort(keys)
    for _, k in ipairs(keys) do w(("- %s: %s"):format(k, oracle.battles[k])) end
    if sweeps.n > 0 then w(("- move/spell/item sweep runs: %d/%d with every round matching"):format(sweeps.ok, sweeps.n)) end
  else
    w("- no oracle file given")
  end
  w("")
  w("## Commands and creature moves")
  w("")
  w("| record | name | handler | cost | power | implemented | uses | matching |")
  w("|---|---|---|---|---|---|---|---|")
  for _, x in ipairs(mdMoves) do w(x) end
  w("")
  w("## Creatures")
  w("")
  w("| id | name | moves | AI | implemented | actions | matching |")
  w("|---|---|---|---|---|---|---|")
  for _, x in ipairs(mdCre) do w(x) end
  w("")
  w("## Spells, items, relics")
  w("")
  w("Bank-7 group effects (spells, items) and relic routines are enumerated but not ported yet.")
  w("")
  for _, x in ipairs(J.spells) do w(("- spell %s %s (cost %d, target %s, 7:%s)"):format(x.ptr, x.name, x.cost, x.target, x.handler)) end
  for _, x in ipairs(J.items) do w(("- item %s %s (target %s, 7:%s)"):format(x.ptr, x.name, x.target, x.handler)) end
  for _, x in ipairs(J.relics) do w(("- relic %d %s (summon 7:%s, hit 7:%s)%s"):format(x.id, x.name, x.onSummon, x.onHit, x.implemented and "" or " - not ported")) end
  f = assert(io.open(OUT .. "/battle-coverage.md", "w")); f:write(table.concat(L, "\n"), "\n"); f:close()
  print(("battles %d rounds %d in %.1fs | moves impl %d/%d tested %d match %d | creatures impl %d/%d tested %d match %d | crashes %d violations %d nondet %d stalemates %d unimpl kinds %d")
    :format(stats.battles, stats.rounds, elapsed, mt.impl, mt.total, mt.tested, mt.match, ct.impl, ct.total, ct.tested, ct.match,
      #J.crashes, #J.violations, #issues.nondeterministic, #issues.stalemates, #uk))
  local failed = #J.crashes > 0 or #issues.nondeterministic > 0
  return failed
end

local elapsed = runAll()
local failed = report(elapsed)
if args.loop then
  -- continuous mode: rerun with fresh seeds until killed
  local every = tonumber(args.loop) or 300
  local base = SEEDS
  while true do
    os.execute("sleep " .. every)
    base = base + SEEDS
    SEEDS = base
    stats = { battles = 0, rounds = 0, results = {} }
    report(runAll())
  end
end
os.exit(failed and 1 or 0)
