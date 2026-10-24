-- Magi-Nation battle engine: a readable Lua port of the bank-2 battle loop.
--
-- The state is the game's own battle WRAM (bank 7, $D000-$D3FF) held as a byte
-- array, plus the $FFA9 divider accumulator. Every routine below mirrors one
-- routine of the matching disassembly and names it with its ROM address, so a
-- port step can be diffed byte for byte against the real game running in PyBoy
-- (tools/mn_battle/oracle.py). Randomness comes from a mn.battle.Rng source.
--
-- Shape for callers (UI, headless tester, lockstep harness):
--   local st = Engine.new(data, setup, rng)      -- setup: see Engine.new
--   Engine.legal(st, slot)                       -- commands + targets for a side
--   Engine.choose(st, slot, cmd)                 -- write one command record
--   Engine.round(st)                             -- AI, rank, act; returns events
--   Engine.hash(st)                              -- state hash for lockstep
-- No call blocks or draws; presentation consumes the returned event list.
local bit = require("bit")
local band, bor, bxor, bnot, lshift, rshift = bit.band, bit.bor, bit.bxor, bit.bnot, bit.lshift, bit.rshift
local Data = require("mn.battle.Data")

local E = {}
E.__index = E

E.REC, E.STRIDE = 0xD147, 0x37
E.TONY, E.MAGI = 0, 9
E.TONY_ID = 0x58
E.WIN, E.LOSS, E.ESCAPE = 2, 3, 1

-- 16-byte command records in bank 5 (LoadSelectedRecordToD100)
E.FIGHT, E.SUMMON, E.SUMMONX, E.ITEM, E.RUN, E.SPELL, E.FOCUS = 0x5EAE, 0x5EBE, 0x5ECE, 0x5EDE, 0x5EEE, 0x5EFE, 0x5F0E

local function u8(v) return band(v, 0xFF) end

---------------------------------------------------------------------------
-- WRAM helpers
---------------------------------------------------------------------------
local function rd(s, a) return s.m[a] end
local function wr(s, a, v) s.m[a] = band(v, 0xFF) end
local function rw(s, a) return s.m[a] * 256 + s.m[a + 1] end -- big endian words
local function ww(s, a, v) v = band(v, 0xFFFF); s.m[a] = rshift(v, 8); s.m[a + 1] = band(v, 0xFF) end
local function rp(s, a) return s.m[a] + s.m[a + 1] * 256 end -- little-endian pointers
local function wp(s, a, v) s.m[a] = band(v, 0xFF); s.m[a + 1] = band(rshift(v, 8), 0xFF) end
local function recAddr(slot) return E.REC + slot * E.STRIDE end
local function copy37(s, dst, src) local m = s.m; for i = 0, E.STRIDE - 1 do m[dst + i] = m[src + i] end end
E.recAddr = recAddr

local function emit(s, ev) s.events[#s.events + 1] = ev; return ev end

-- name ids for $FC substitution (WriteIndexedNamesAndCount, bank 5)
local function nameOf(s, id) local n = s.data.names[id]; return n or ("#" .. id) end
local function countText(s)
  if rd(s, 0xD076) ~= 0 then return tostring(rd(s, 0xD077)) end
  return tostring(rd(s, 0xD073))
end
-- plant a bank-$4C message: actor name, target name, number (the $C949 list)
local function say(s, script, extra)
  local ev = { t = "msg", script = script, actor = rd(s, 0xD0DB), target = rd(s, 0xD112),
    actorSlot = rd(s, 0xD0B6), targetSlot = rd(s, 0xD103) }
  ev.subs = extra or { nameOf(s, ev.actor), nameOf(s, ev.target), countText(s) }
  ev.text = Data.render(s.data, script, ev.subs)
  return emit(s, ev)
end
local function anim(s, script)
  -- StagePointerUnlessD0B6Matches: the move animation is skipped on self-targets
  if rd(s, 0xD0B6) == rd(s, 0xD103) then return end
  emit(s, { t = "anim", script = script, actor = rd(s, 0xD0DB), target = rd(s, 0xD112),
    actorSlot = rd(s, 0xD0B6), targetSlot = rd(s, 0xD103) })
end
-- ApplyIndexedIdRecord (5:$57BA) parameters: which portrait shows which face.
-- Only the UI reads them, but they are battle WRAM, so they are kept exact.
local function portrait(s, face, slotCode, species)
  wr(s, 0xD0C0, face); wr(s, 0xD0C1, slotCode); wr(s, 0xD0C2, species)
  if species < 0x6C then emit(s, { t = "portrait", face = face, who = slotCode, species = species }) end
end
local function unimpl(s, what)
  s.unimplemented[what] = (s.unimplemented[what] or 0) + 1
  emit(s, { t = "unimplemented", what = what })
end

---------------------------------------------------------------------------
-- randomness ($053A MaskDivByC, $054F AddDividerStep, $53FB JitterScaledTableByte)
---------------------------------------------------------------------------
local function maskDiv(s, c) return s.rng:maskDiv(c) end
local function divStep(s)
  s.ffa9 = u8(s.ffa9 + s.rng:divStep())
  return s.ffa9
end
local function divideHL(hl, a) -- DivideHLByA: 8-bit quotient, 0 when a == 0
  if a == 0 then return 0 end
  return band(math.floor(hl / a), 0xFF)
end
-- JitterScaledTableByte: scale a (10 or $12) by table[$40DC + b]; result is a
-- signed offset folded into 8 bits
local function jitter(s, a, b)
  local t = s.data.b2[0xDC + b] or 0
  local e = divideHL(a * t, 0x63)
  local c = u8(e * 2 + 1)
  local r = divideHL(s.rng:div() * c, 0xFF)
  return u8(r - e)
end

---------------------------------------------------------------------------
-- record creation
---------------------------------------------------------------------------
-- growth contribution samplers, bank 2 $59F2-$5AFA
local GROWTH_LOW, GROWTH_MID, GROWTH_HIGH = 8, 18, 28 -- offsets of $5B17/$5B21/$5B2B in growth
-- $59F2/$5A2B (skill, speed) and $5A64/$5AAF (defense, resist) pick a mod-10
-- table by the creature type byte at $D113
local function tableFor(s, defenseSide)
  local t = rd(s, 0xD113)
  if t == 2 then return GROWTH_MID end
  if t == 6 then return GROWTH_LOW end
  if t == 0 then return defenseSide and GROWTH_LOW or GROWTH_HIGH end
  if t == 4 then return defenseSide and GROWTH_HIGH or GROWTH_LOW end
  return GROWTH_HIGH
end
local function sampleMod10(s, base)
  local r = divStep(s) % 10
  return s.data.growth[base + r]
end
local function growth(s)
  local g = s.data.growth
  -- $5AFA strength
  local b = divStep(s); local a = divStep(s)
  local swap = band(lshift(a, 4), 0xF0) + rshift(a, 4)
  local c11 = g[band(band(swap, b), 7)]
  -- $59F2 skill / $5A2B speed
  local c12 = sampleMod10(s, tableFor(s, false))
  local c13 = sampleMod10(s, tableFor(s, false))
  -- $5A64 defense / $5AAF resist: plus a coin from (step / 3) bit 1
  local function withCoin(base)
    local v = sampleMod10(s, base)
    local r = divStep(s) % 3
    return u8(v + rshift(band(r, 2), 1))
  end
  local c14 = withCoin(tableFor(s, true))
  local c15 = withCoin(tableFor(s, true))
  return c11, c12, c13, c14, c15
end

-- SpendMeasureHundred (2:$57F1, spend_measure_hundred.asm): one level up. Its
-- scratch bytes are battle WRAM and are kept exact: D38B rank roll, D388 energy
-- step, D38A level roll, D38C..D390 the five stat contributions, D389 flags.
function E.spendMeasureHundred(s, rec, creating)
  wr(s, 0xD38B, maskDiv(s, 3) * 5)
  local d388 = maskDiv(s, 3) + 1
  wr(s, 0xD388, d388)
  if not creating then ww(s, rec + 5, rw(s, rec + 5) - 0x64) end -- MEASURE_UNDER (D389 bit 0 clear)
  local rank = rd(s, rec + 4)
  wr(s, 0xD38A, rank)
  if rank == 0x63 then return end
  rank = rank + 1
  wr(s, rec + 4, rank)
  if rank >= 0x3E then wr(s, 0xD38B, 0) end
  local c = { growth(s) }
  for i = 1, 5 do
    wr(s, 0xD38B + i, c[i])
    local v = c[i] + rd(s, rec + 10 + i)
    if v >= 0x63 then v = 0x63 end
    wr(s, rec + 10 + i, v)
  end
  local e = u8(rd(s, rec + 0x11) + d388)
  local mx = rw(s, rec + 9) + e
  if mx >= 0xFA then mx = 0xFA end
  ww(s, rec + 9, mx)
  local d38a = u8(rank - 1 + 1 + jitter(s, 0x0A, rd(s, rec + 0x10)))
  wr(s, 0xD38A, d38a)
  -- ClaimFirstMeasureThreshold ($5657): unlock the first command whose level is reached
  for k = 0, 3 do
    local f = rd(s, rec + 0x20 + k)
    if f ~= 0xFF then
      if d38a >= f then
        wr(s, rec + 0x20 + k, 0xFF)
        wr(s, 0xD389, bor(rd(s, 0xD389), 0x80))
        if not creating then emit(s, { t = "learn", slot = rec, move = rd(s, rec + 0x18 + 2 * k) + rd(s, rec + 0x19 + 2 * k) * 256 }) end
      end
      break
    end
  end
  -- RunFlaggedMeasureScript ($58FF): with D389 bit 1 (show the level-up) it
  -- clears bit 7 again after the "learned" message
  if band(rd(s, 0xD389), 0x02) ~= 0 then wr(s, 0xD389, band(rd(s, 0xD389), 0x7F)) end
end

-- FillD110FromIndexedEntry ($4653): build a creature into D110 from its template
function E.fillFromEntry(s, species, spends, energy)
  local e = s.data.entries[species]
  local d = 0xD110
  -- the routine writes D110..D136 only; D137..D146 (+$27 command pointer and the
  -- command name) keep whatever the staging record held before
  for i = 0, 0x26 do s.m[d + i] = 0 end
  wr(s, d, 1); wr(s, d + 1, 0); wr(s, d + 2, species); wr(s, d + 3, e[0])
  for i = 0, 9 do wr(s, d + 0x0B + i, e[4 + i]) end
  wr(s, d + 0x15, 0); wr(s, d + 0x16, e[14]); wr(s, d + 0x17, e[15])
  for i = 0, 11 do wr(s, d + 0x18 + i, e[18 + i]) end
  wr(s, 0xD389, 1) -- `set 0, a; res 1, a; ld [$D389], a` before the spend loop
  local n = spends == 0 and 256 or spends
  for _ = 1, n do E.spendMeasureHundred(s, d, true) end
  wr(s, d + 8, energy); wr(s, d + 10, energy)
end

-- the 30-byte saved record format (CopySramBlockToHL $5C5C) into a battle slot
local function loadSaved(s, slot, saved)
  local r = recAddr(slot)
  wr(s, r, 0); wr(s, r + 1, 0)
  for i = 0, 29 do wr(s, r + 2 + i, saved[i] or 0) end
  for i = 32, 35 do wr(s, r + i, 0xFF) end
  for i = 36, 54 do wr(s, r + i, 0) end
end

-- ExpandD391Record (bank 4 $411A): a Magi's saved-format record from its template
function E.magiSaved(data, id)
  local e, t = data.entries[id], {}
  t[0] = id; t[1] = e[0]; t[2] = 0; t[3] = 0; t[4] = 0
  t[5] = e[2]; t[6] = e[3]; t[7] = e[2]; t[8] = e[3]
  for i = 0, 9 do t[9 + i] = e[4 + i] end
  t[19] = 0; t[20] = e[14]; t[21] = e[15]
  for i = 0, 7 do t[22 + i] = e[18 + i] end
  return t
end

-- Tony's saved record (SRAM $A000). Defaults are the values a fresh file has
-- when the Glade battle runs; the overworld passes its own when it has one.
function E.tonySaved(o)
  o = o or {}
  local lv, en, mx = o.level or 1, o.energy or 100, o.max or o.energy or 100
  local st = o.stats or { 50, 50, 50, 25, 25, 1 }
  local t = { [0] = E.TONY_ID, 0x0C, lv, rshift(o.measure or 42, 8), band(o.measure or 42, 0xFF),
    rshift(en, 8), band(en, 0xFF), rshift(mx, 8), band(mx, 0xFF) }
  for i = 1, 6 do t[8 + i] = st[i] end
  t[15] = 0; t[16] = 0; t[17] = 0; t[18] = 0xFF; t[19] = 0; t[20] = 0; t[21] = 0
  local mv = { E.SUMMON, E.SPELL, E.ITEM, E.RUN }
  for k = 1, 4 do t[20 + 2 * k] = band(mv[k], 0xFF); t[21 + 2 * k] = rshift(mv[k], 8) end
  return t
end

---------------------------------------------------------------------------
-- creation
---------------------------------------------------------------------------
-- setup = {
--   magi = id,                 -- op $25 second arg ($6C wild, $5D Korg, ...)
--   tony = saved record table (E.tonySaved{...}) or nil for defaults,
--   party = { {species=, spends=, energy=, relics={a,b}} ... } creatures Tony can summon,
--   summons = { {slot=9, species=, spends=, energy=, delay=} ... } op $2E args,
--   spells = { group ptr... }, items = { {ptr=, count=} ... },
--   ffa9 = initial $FFA9 (0 by default)
-- }
function E.new(data, setup, rng)
  local s = setmetatable({ data = data, rng = rng, m = {}, ffa9 = setup.ffa9 or 0, events = {},
    unimplemented = {}, setup = setup, party = {}, partyOut = {}, partyLost = {}, spells = setup.spells or {},
    items = {}, chosen = {}, hashes = {}, rounds = 0 }, E)
  for a = 0xD000, 0xD3FF do s.m[a] = 0 end
  for i, it in ipairs(setup.items or {}) do s.items[i] = { ptr = it.ptr, count = it.count or 1 } end
  -- party creatures live in SRAM in the game ($25-byte records after Tony's at
  -- $A000, so the first is $A025) and $D107 holds that SRAM address. Generated
  -- ones use the same template routine the enemy side uses.
  for i, p in ipairs(setup.party or {}) do
    local addr = E.PARTY_BASE + (i - 1) * E.SAVED_LEN
    if p.saved then s.party[addr] = p.saved
    else
      E.fillFromEntry(s, p.species, p.spends or 1, p.energy or 10)
      local t = {}
      for k = 0, E.SAVED_LEN - 1 do t[k] = rd(s, 0xD112 + k) end
      -- relic ids sit at saved +$22/+$23 (they load to D134/D135)
      if p.relics then t[0x22] = p.relics[1] or 0; t[0x23] = p.relics[2] or 0 end
      s.party[addr] = t
    end
  end
  E.init(s)
  return s
end

E.PARTY_BASE, E.SAVED_LEN = 0xA025, 0x25

-- the party as the save holds it: $25-byte records from $A025 until an $FF species
function E.partyFromSram(bytes, base)
  base = base or 0xA000
  local party = {}
  for addr = E.PARTY_BASE, E.PARTY_BASE + 40 * E.SAVED_LEN, E.SAVED_LEN do
    local o = addr - base
    local sp = bytes:byte(o + 1)
    if not sp or sp == 0xFF or sp == 0 then break end
    local t = {}
    for k = 0, E.SAVED_LEN - 1 do t[k] = bytes:byte(o + 1 + k) end
    party[addr] = t
  end
  return party
end

-- InitWram7BeforeReset ($6xxx, init_wram7_before_reset.asm)
function E.init(s)
  local setup = s.setup
  wp(s, 0xD06D, 0) -- round counter, little endian
  for a = 0xD0D9, 0xD0D9 + 0x294 - 1 do s.m[a] = 0 end
  loadSaved(s, 0, setup.tony or E.tonySaved())
  wr(s, 0xD091, 1)
  loadSaved(s, 9, E.magiSaved(s.data, setup.magi or 0x6C))
  -- Opcode25 (0:$0EC5) operands that land in battle WRAM
  wr(s, 0xD391, setup.magi or 0x6C); wr(s, 0xD0D3, (setup.magi or 0x6C) == 0x6C and 1 or 0)
  wr(s, 0xD36D, setup.arg3 or 0)
  -- a Magi starts with its template energy (ExpandD391Record); a story battle
  -- changes it from its battle script with op $AA (Korg's duel, 14:$4184, stores
  -- $00 $19 at $D33D: he starts with 25). setup.magiEnergy is kept for callers
  -- that set it by hand.
  if setup.magiEnergy then ww(s, recAddr(9) + 7, setup.magiEnergy) end
  wr(s, 0xD09A, rd(s, 0xD339) == 0x0E and 0 or 1)
  portrait(s, 0, 0x0C, rd(s, 0xD338))
  wr(s, 0xD15C, 0); wr(s, 0xD34B, 0); wr(s, 0xD016, 0); wr(s, 0xD06C, 0)
  wr(s, 0xD0CD, 0xFF)
  for a = 0xD092, 0xD099 do s.m[a] = 0 end
  for a = 0xD36E, 0xD36E + 0x17 do s.m[a] = 0 end
  for a = 0xD07D, 0xD086 do s.m[a] = 0 end
  for a = 0xD0B8, 0xD0BF do s.m[a] = 0xFF end
  ww(s, 0xD35D, 0); wr(s, 0xD35D, 0xC2); wr(s, 0xD35E, 0x51) -- magi command = default $51C2
  wr(s, 0xD16E, 0xC2); wr(s, 0xD16F, 0x51)                    -- Tony command = default
  -- the battle script's ops (op $AA stores, op $2E summons), then the first
  -- rank and walk. In the game the engine loop runs beside the script and op $2B
  -- lets one pass through; this order reproduces the Glade start byte for byte
  -- and the Korg duel start except one leftover byte pair (see the report).
  for _, o in ipairs(setup.script or {}) do E.scriptOp(s, o) end
  for _, sm in ipairs(setup.summons or {}) do E.opcode2E(s, sm) end
  E.rank(s)
  E.walkSlots(s)
  s.round0 = s.events; s.events = {}
end

---------------------------------------------------------------------------
-- RankEightD092Slots ($6BE7): speed + luck jitter, bubble sort into D008..D00F
---------------------------------------------------------------------------
function E.rank(s)
  for c = 0, 7 do
    if rd(s, 0xD092 + c) ~= 0 then
      local r = recAddr(c + 1)
      local spd = rd(s, r + 0x0D)
      wr(s, 0xD015, spd)
      local a = jitter(s, 0x0A, rd(s, r + 0x10))
      local v = spd + a
      if v > 0xFF then v = 0 end
      wr(s, 0xD000 + c, v); wr(s, 0xD008 + c, c + 1)
    else
      wr(s, 0xD000 + c, 0); wr(s, 0xD008 + c, 0xFF)
    end
  end
  -- the original bubble pass: e walks 7..d074+1 comparing [e] with [e-1]
  local d074 = 0
  while true do
    for e = 7, d074 + 1, -1 do
      local a, b = rd(s, 0xD000 + e), rd(s, 0xD000 + e - 1)
      if a >= b then -- `cp [hl]; jr c, .noSwap` swaps on a >= b
        wr(s, 0xD000 + e, b); wr(s, 0xD000 + e - 1, a)
        local x, y = rd(s, 0xD008 + e), rd(s, 0xD008 + e - 1)
        wr(s, 0xD010, x) -- the swap's scratch byte
        wr(s, 0xD008 + e, y); wr(s, 0xD008 + e - 1, x)
      end
    end
    wr(s, 0xD074, d074)
    if d074 == 6 then break end
    d074 = d074 + 1
  end
end

---------------------------------------------------------------------------
-- small shared routines
---------------------------------------------------------------------------
-- OrFourD092AndD07E ($657B): any player creature present or arriving
local function orFourD092AndD07E(s)
  local a = 0
  for i = 0, 3 do a = bor(a, rd(s, 0xD092 + i), rd(s, 0xD07E + i)) end
  return a
end
-- OrD096QuadUnlessD09AClosed ($6FB2): enemy side still standing
local function orD096Quad(s)
  local a = 0
  for i = 0, 3 do a = bor(a, rd(s, 0xD096 + i)) end
  if a ~= 0 then return a end
  if rd(s, 0xD09A) == 0 then return 0 end
  for i = 0, 3 do a = bor(a, rd(s, 0xD082 + i)) end
  return bor(a, rd(s, 0xD33D), rd(s, 0xD33E))
end
E.orFourD092AndD07E, E.orD096Quad = orFourD092AndD07E, orD096Quad

-- SetD016WhenSlotsClosed ($62C1)
local function setD016WhenSlotsClosed(s)
  if rd(s, 0xD016) ~= 0 then return end
  local a = bor(rd(s, 0xD14E), rd(s, 0xD14F), orFourD092AndD07E(s))
  if a == 0 then wr(s, 0xD016, E.LOSS); return end
  a = 0
  for i = 0, 3 do a = bor(a, rd(s, 0xD096 + i)) end
  if a ~= 0 then return end
  if rd(s, 0xD09A) ~= 0 then
    for i = 0, 3 do a = bor(a, rd(s, 0xD082 + i)) end
    a = bor(a, rd(s, 0xD33D), rd(s, 0xD33E))
    if a ~= 0 then return end
  end
  wr(s, 0xD016, E.WIN)
end

-- MulLByBShift5 (drain): (l * b) >> 5 with the original's b == 1 -> 0 quirk
local function mulLByBShift5(l, b)
  if l == 0 or b == 0 or b == 1 then return 0 end
  local hl = band(l * b, 0xFFFF)
  return band(lshift(rshift(hl, 8), 3) + rshift(band(hl, 0xFF), 5), 0xFF)
end

local function moveName(s) -- the 7-byte name at $D109
  local t = {}
  for i = 0, 6 do local c = rd(s, 0xD109 + i); t[#t + 1] = (c >= 32 and c < 127) and string.char(c) or " " end
  return (table.concat(t):gsub("%s+$", ""))
end
local function names(s) return { nameOf(s, rd(s, 0xD0DB)), nameOf(s, rd(s, 0xD112)), countText(s) } end
local function plant(s, script, subs) s.planted = { script = script, subs = subs or names(s) } end
local function showPlanted(s)
  local p = s.planted
  if p then say(s, p.script, p.subs); s.planted = nil end
end

-- LoadSelectedRecordToD100 (5:$56AF): CCA7 0 = Fight/Focus, 1..4 = command k
-- Relic routines, bank 7 $6BD5-$6FCE, translated mechanically from the matching
-- source by tools/mn_battle/audit/relics.py. A relic record (7:$6916, 19 bytes)
-- holds three bank-7 pointers: +0 runs from LoadSelectedRecordToD100 for the
-- actor's D0FD/D0FE ids (every relic points it at the bare `ret` at $6BD5), +2
-- runs from RunPairIdScripts (5:$4109) on the summoned creature's D134/D135 ids,
-- and +4 runs from FinishLowD103Refresh after the move handler for D0FD/D0FE.
--   up off n   AddACapByteAtBc on $D110+off (cap $63)
--   dn off n   SubAFloorByteAtBc on $D110+off (floor 1)
--   or a m     [a] |= m;  orfrom a b: [a] |= [b] (A still holds the byte just stored)
--   maxe n     max energy D119 += n and current D117 = the new max
--   set a v / andor a m o
local RELIC_OPS = {
  [0x6BD5] = {  },
  [0x6BD6] = { { "up", 0xC, 0xA } },
  [0x6BE4] = { { "up", 0xE, 0xC } },
  [0x6BF2] = { { "up", 0xB, 0x8 } },
  [0x6C00] = { { "up", 0xE, 0x4 } },
  [0x6C0E] = { { "up", 0xC, 0x6 } },
  [0x6C1C] = { { "up", 0xC, 0xF }, { "up", 0xF, 0xF }, { "dn", 0xB, 0xF } },
  [0x6C42] = { { "up", 0xB, 0x6 }, { "up", 0xC, 0x6 }, { "up", 0x10, 0x14 }, { "dn", 0xE, 0xA }, { "dn", 0xF, 0xA } },
  [0x6C80] = { { "or", 0xD122, 0x1 }, { "up", 0xF, 0xF }, { "up", 0xE, 0xF }, { "dn", 0xD, 0x19 } },
  [0x6CAD] = { { "maxe", 0x19 }, { "up", 0xB, 0x19 }, { "up", 0xE, 0x19 }, { "up", 0xF, 0x19 }, { "up", 0xC, 0x19 }, { "up", 0xD, 0x19 }, { "or", 0xD125, 0x8 }, { "orfrom", 0xD126, 0xD125 }, { "andor", 0xD111, 0xF, 0x30 } },
  [0x6D1F] = { { "maxe", 0x6 } },
  [0x6D3B] = { { "or", 0xD122, 0x2 }, { "up", 0xC, 0xF }, { "up", 0xB, 0xF }, { "dn", 0xE, 0xF }, { "dn", 0xF, 0xF } },
  [0x6D73] = { { "or", 0xD122, 0x1 }, { "or", 0xD123, 0x20 } },
  [0x6D82] = { { "or", 0xD106, 0x2 } },
  [0x6D8A] = { { "up", 0xE, 0x5 } },
  [0x6D98] = { { "up", 0x10, 0xF } },
  [0x6DA6] = { { "maxe", 0x4 } },
  [0x6DC2] = { { "up", 0xB, 0x5 } },
  [0x6DD0] = { { "or", 0xD122, 0x20 }, { "or", 0xD123, 0x8 } },
  [0x6DDF] = { { "or", 0xD106, 0x10 } },
  [0x6DE7] = { { "up", 0xC, 0xA } },
  [0x6DF5] = { { "up", 0xB, 0xC } },
  [0x6E03] = { { "up", 0xF, 0xA } },
  [0x6E11] = { { "up", 0xD, 0xA }, { "up", 0xC, 0x5 }, { "up", 0xB, 0xA }, { "or", 0xD126, 0x4 } },
  [0x6E40] = { { "or", 0xD122, 0x10 }, { "maxe", 0xF }, { "up", 0xE, 0xF }, { "dn", 0xB, 0xF } },
  [0x6E7B] = { { "set", 0xD120, 0x0 } },
  [0x6E80] = { { "up", 0xB, 0x2 }, { "up", 0xD, 0x2 } },
  [0x6E9B] = { { "up", 0xF, 0x14 }, { "up", 0xE, 0x14 }, { "or", 0xD126, 0x40 } },
  [0x6EBD] = { { "up", 0xE, 0xF } },
  [0x6ECB] = { { "or", 0xD122, 0x8 }, { "or", 0xD123, 0x1 } },
  [0x6EDA] = { { "or", 0xD106, 0x4 } },
  [0x6EE2] = { { "maxe", 0x8 } },
  [0x6EFE] = { { "or", 0xD126, 0x1 } },
  [0x6F06] = { { "or", 0xD122, 0x4 }, { "or", 0xD123, 0x2 } },
  [0x6F15] = { { "or", 0xD106, 0x1 } },
  [0x6F1D] = { { "maxe", 0x8 }, { "or", 0xD124, 0xFF } },
  [0x6F40] = { { "up", 0xB, 0xF } },
  [0x6F4E] = { { "or", 0xD122, 0x10 }, { "or", 0xD123, 0x4 } },
  [0x6F5D] = { { "or", 0xD106, 0x8 } },
  [0x6F65] = { { "up", 0xB, 0x8 } },
  [0x6F73] = { { "or", 0xD122, 0x8 }, { "or", 0xD126, 0x4 }, { "up", 0xE, 0x5 }, { "up", 0xB, 0x5 }, { "up", 0xC, 0x5 }, { "up", 0xF, 0x5 }, { "dn", 0xD, 0x5 } },
  [0x6FC1] = { { "up", 0x10, 0x5 } },
}
E.RELIC_OPS = RELIC_OPS
local function runRelic(s, id, field)
  if id == 0 then return end
  local r = s.data.relics and s.data.relics[id]
  if not r then unimpl(s, ("relic id %02X"):format(id)); return end
  local ptr = r[field]
  local ops = RELIC_OPS[ptr]
  if not ops then unimpl(s, ("relic routine 7:%04X"):format(ptr)); return end
  emit(s, { t = "relic", id = id, name = r.name, field = field, routine = ptr })
  for _, o in ipairs(ops) do
    local k = o[1]
    if k == "up" then
      local a = 0xD110 + o[2]; local v = u8(rd(s, a) + o[3]); if v >= 0x63 then v = 0x63 end; wr(s, a, v)
    elseif k == "dn" then
      local a = 0xD110 + o[2]; local v = rd(s, a) - o[3]; if v <= 0 then v = 1 end; wr(s, a, v)
    elseif k == "or" then wr(s, o[2], bor(rd(s, o[2]), o[3]))
    elseif k == "orfrom" then wr(s, o[2], bor(rd(s, o[2]), rd(s, o[3])))
    elseif k == "maxe" then
      local v = band(rd(s, 0xD119) * 256 + rd(s, 0xD11A) + o[2], 0xFFFF)
      wr(s, 0xD119, rshift(v, 8)); wr(s, 0xD117, rshift(v, 8)); wr(s, 0xD11A, band(v, 0xFF)); wr(s, 0xD118, band(v, 0xFF))
    elseif k == "set" then wr(s, o[2], o[3])
    elseif k == "andor" then wr(s, o[2], bor(band(rd(s, o[2]), o[3]), o[4]))
    end
  end
end
E.runRelic = runRelic

local function loadSelected(s)
  wr(s, 0xD0D4, 0)
  local k = s.cca7 or 0 -- $CCA7 lives in bank-0 WRAM, outside the battle bank
  local ptr
  if k == 0 or k == 5 then
    local b = band(rd(s, 0xD0B1), 0x7F)
    if b == 0 or b == 9 then ptr = E.FOCUS
    else ptr = E.FIGHT; wr(s, 0xD0D4, rd(s, 0xD0FF)) end
  else
    ptr = rp(s, 0xD0F1 + 2 * (k - 1))
  end
  local mv = s.data.moves[ptr]
  if mv then
    for i = 0, 15 do wr(s, 0xD100 + i, mv.raw[i]) end
  else
    unimpl(s, ("command record %04X"):format(ptr))
    for i = 0, 15 do wr(s, 0xD100 + i, s.data.moves[E.FIGHT].raw[i]) end
  end
  if rd(s, 0xD0D4) ~= 0 then wr(s, 0xD103, 0x0B) end
  runRelic(s, rd(s, 0xD0FD), "onLoad")
  runRelic(s, rd(s, 0xD0FE), "onLoad")
end
E.loadSelected = loadSelected

-- the 5:$4000 legality routines used by DispatchIfD0E0AboveD102 ($43E6)
local function legalForClass(s, class)
  local b1 = rd(s, 0xD0B1)
  local enemy = band(b1, 0x80) ~= 0
  if class == 0x0C or class == 0x0D then -- $5C04: a free slot on the right side
    local low
    if enemy then low = class ~= 0x0C else low = class == 0x0C end
    local f, c = low and 0xD092 or 0xD096, low and 0xD07E or 0xD082
    for i = 0, 3 do if rd(s, f + i) == 0 and rd(s, c + i) == 0 then return 1 end end
    return 0
  elseif class == 0x0E then -- $5BE7: any creature
    for i = 0, 7 do if rd(s, 0xD092 + i) ~= 0 then return 1 end end
    return 0
  elseif class == 0x0F then -- $5BCE
    if not enemy or rd(s, 0xD09A) ~= 0 then return 1 end
    return 0
  elseif class == 0x10 or class == 0x11 then -- $5C44
    if enemy then
      if class == 0x11 then return 1 end
      for i = 0, 3 do if rd(s, 0xD092 + i) ~= 0 then return 0 end end
      return 1
    end
    if rd(s, 0xD09A) == 0 then return 0 end
    if class == 0x11 then return 1 end
    for i = 0, 3 do if rd(s, 0xD096 + i) ~= 0 then return 0 end end
    return 1
  elseif class == 0x14 or class == 0x15 or class == 0x16 or class == 0x18 then -- $5B91 / $5B29
    local own = class == 0x16 or class == 0x18
    local slot = band(b1, 0x7F)
    if own then wr(s, 0xD091 + slot, 0) end
    local base
    if own then base = enemy and 0xD096 or 0xD092 else base = enemy and 0xD092 or 0xD096 end
    local ok = 0
    for i = 0, 3 do if rd(s, base + i) ~= 0 then ok = 1 end end
    if ok == 0 and class == 0x15 then
      if own then ok = (not enemy or rd(s, 0xD09A) ~= 0) and 1 or 0
      else ok = (enemy or rd(s, 0xD09A) ~= 0) and 1 or 0 end
    end
    if own then wr(s, 0xD091 + slot, 1) end
    return ok
  end
  return 1 -- $5BFE
end

-- DispatchIfD0E0AboveD102 (5:$43E6): affordable and a legal target exists
local function checkAffordable(s)
  local cost = rd(s, 0xD102)
  if cost ~= 0 then
    local en = rw(s, 0xD0E0)
    if en < cost or en == cost then wr(s, 0xD0AF, 0); wr(s, 0xD0D8, 1); return 0 end
  end
  local cls = rd(s, 0xD103)
  wr(s, 0xD0B0, cls)
  local ok = legalForClass(s, cls)
  wr(s, 0xD0AF, ok)
  return ok
end

-- FinishOpcode2D ($752D) / ApplySummonXRecordThenPickSlot ($748B): a summon by
-- the enemy Magi from the battle script, op $2E slot species spends energy delay
-- (CopyScriptToD392 puts the five bytes at $D392). Returns true when it summoned.
function E.opcode2E(s, sm)
  local magi = sm.slot or 9
  wr(s, 0xD392, magi); wr(s, 0xD393, sm.species); wr(s, 0xD394, sm.spends or 1)
  wr(s, 0xD395, sm.energy or 1); wr(s, 0xD396, sm.delay or 0)
  wr(s, 0xD0D8, 0)
  -- $748B: the Magi's record into D0D9, the SummonX command record into D100
  copy37(s, 0xD0D9, recAddr(magi)); wr(s, 0xD0B1, 0xFF)
  local mv = s.data.moves[E.SUMMONX]
  for i = 0, 15 do wr(s, 0xD100 + i, mv.raw[i]) end
  wr(s, 0xD0B1, 0x89); wr(s, 0xD103, 0x0C); wr(s, 0xD102, rd(s, 0xD395))
  if checkAffordable(s) == 0 then
    -- $752D: an unaffordable summon leaves the D0D9 copy of the Magi at 1 energy
    if rd(s, 0xD0D8) ~= 0 then ww(s, 0xD0E0, 1) end
    return false
  end
  wr(s, 0xD068, rd(s, 0xD393)); wr(s, 0xD069, rd(s, 0xD394)); wr(s, 0xD06A, rd(s, 0xD395))
  -- first free enemy slot 6..8 (present or arriving), else slot 5 unchecked
  local slot = 5
  for t = 6, 8 do
    if u8(rd(s, 0xD091 + t) + rd(s, 0xD07D + t)) == 0 then slot = t; break end
  end
  wr(s, 0xD103, slot)
  -- nothing is paid here: D102 keeps the cost and ClearMarksAndWalkSlots ($66DD)
  -- takes it from the Magi when it walks the Magi's slot
  copy37(s, recAddr(magi), 0xD0D9)
  wr(s, 0xD0C1, slot); wr(s, 0xD0C0, 1) -- PlantSlot11WhenD0C0IsOne (panel only)
  portrait(s, 2, 0x0C, rd(s, 0xD338))
  E.fillFromEntry(s, rd(s, 0xD068), rd(s, 0xD069), rd(s, 0xD06A))
  wp(s, 0xD07B, recAddr(slot))
  copy37(s, recAddr(slot), 0xD110)
  wr(s, 0xD07D + slot, rd(s, 0xD396) + 1)
  wr(s, 0xD100, 0xC2); wr(s, 0xD101, 0x51)
  copy37(s, recAddr(magi), 0xD0D9)
  emit(s, { t = "summon", slot = slot, species = sm.species, pending = true })
  return true
end

-- the battle script ops the engine understands, in script order (the script the
-- op $25 record points at, run up to op $27):
--   { op = 0xAA, addr = A, bank = B, value = V }  StoreScriptByteInWramBank (0:$2801)
--   { op = 0x2E, slot =, species =, spends =, energy =, delay = }  opcode_2e.asm
function E.scriptOp(s, o)
  if o.op == 0xAA then
    if (o.bank or 7) == 7 and o.addr >= 0xD000 and o.addr < 0xD400 then wr(s, o.addr, o.value) end
  elseif o.op == 0xAB then -- StoreScriptWordInWramBank
    if (o.bank or 7) == 7 and o.addr >= 0xD000 and o.addr < 0xD3FF then wr(s, o.addr, o.lo); wr(s, o.addr + 1, o.hi) end
  elseif o.op == 0x2E then
    E.opcode2E(s, o)
  end
end

---------------------------------------------------------------------------
-- target pickers for the enemy AI (bank 2 $6FF9-$72FD)
---------------------------------------------------------------------------
-- ResolveD103BeforeMarkScan ($7366)
local function resolveD103(s)
  wr(s, 0xD0C9, 1)
  local t = rd(s, 0xD103)
  if t >= 0x14 then return end
  if t == 0x0A then wr(s, 0xD103, divideHL(rp(s, 0xD079) - E.REC, 0x37)); return end
  if t == 0x0B then return end
  if t == 0x11 then wr(s, 0xD103, rd(s, 0xD110) == 0 and 9 or 0); return end
  wr(s, 0xD0C9, 0)
end

-- PickD091MarkIntoD103 ($72FD): random end of the right side
local function pickD091Mark(s)
  resolveD103(s)
  if rd(s, 0xD0C9) ~= 0 then return end
  local function from(i) wr(s, 0xD103, i) end
  if band(rd(s, 0xD105), 0x7F) < 5 then
    if band(divStep(s), 1) ~= 0 then
      local i = 4
      while i > 0 and rd(s, 0xD091 + i) == 0 do i = i - 1 end
      from(i)
    else
      for i = 1, 4 do if rd(s, 0xD091 + i) ~= 0 then from(i); return end end
      from(0)
    end
  else
    if band(divStep(s), 1) ~= 0 then
      local i = 5
      while i < 9 and rd(s, 0xD091 + i) == 0 do i = i + 1 end
      from(i)
    else
      for i = 8, 5, -1 do if rd(s, 0xD091 + i) ~= 0 then from(i); return end end
      from(9)
    end
  end
end

-- FirstNonzeroOfFour ($70C3): random start, random direction
local function firstNonzeroOfFour(s, base)
  local a = divStep(s)
  local c = band(a, 3)
  for _ = 1, 4 do
    if rd(s, base + c) ~= 0 then return c end
    if band(a, 0x80) ~= 0 then c = c - 1; if c < 0 then c = 3 end
    else c = c + 1; if c == 4 then c = 0 end end
  end
  return 0xFF
end
local function pickD092Plus1(s) -- $714F
  local c = firstNonzeroOfFour(s, 0xD092)
  wr(s, 0xD103, c == 0xFF and 0 or c + 1)
end
local function pickD096Plus5(s) -- $7191
  local c = firstNonzeroOfFour(s, 0xD096)
  wr(s, 0xD103, c == 0xFF and 9 or c + 5)
end

-- ScaleCount (energy / max in 32nds) for $7101
local function scaleCount(de, bc)
  -- de = energy, bc = max: counts how many max/2 steps fit 16*energy
  local cnt = 0
  if band(de, 0xFF) == 0 then if rshift(de, 8) == 0 then return 0 end
  elseif band(de, 0xFF) >= band(bc, 0xFF) and rshift(de, 8) >= rshift(bc, 8) then return 0x20 end
  bc = rshift(bc, 1)
  de = band(lshift(de, 4), 0xFFFF)
  local hl = bc
  while hl < de do hl = band(hl + bc, 0xFFFF); cnt = cnt + 1; if bc == 0 then break end end
  return band(cnt, 0xFF)
end
-- ScaleFourRecordsIntoD3C4 ($7101) / CopyFourRawRecordWords ($712F): four
-- big-endian words at $D3C4 (a scaled count is stored as count, 0), D074 counts down
local function fourScores(s, base, scaled)
  local t = {}
  for k = 0, 3 do
    local r = base + k * E.STRIDE
    local v
    if scaled then v = scaleCount(rw(s, r + 7), rw(s, r + 9)) * 256
    else v = rw(s, r + 7) end
    t[k + 1] = v
    ww(s, 0xD3C4 + 2 * k, v)
  end
  wr(s, 0xD074, 0)
  return t
end
-- PickLeast/GreatestNonzeroD3C4Slot ($7067/$700B): 1-based, 0 when none
-- the scan keeps its pick in $D3CC and its countdown in $D074 (left 0)
local function pickBy(s, t, least)
  local best, at = nil, 0
  for k = 1, 4 do
    local v = t[k]
    if v ~= 0 then
      if not best then best, at = v, k
      elseif least and v <= best then best, at = v, k
      elseif not least and v > best then best, at = v, k end
    end
  end
  wr(s, 0xD074, 0)
  if at ~= 0 then wr(s, 0xD3CC, at) end
  wr(s, 0xD103, at)
end

local AI = {}
-- $725E MatchDividerRemainderToFF: random command, then a random-side target
AI[0] = function(s)
  local d074 = 0
  while true do
    d074 = band(d074 + 1, 0xFF)
    wr(s, 0xD074, d074)
    local a = 0
    if d074 ~= 0 then
      local r = divStep(s) % 5
      a = r
      if r ~= 0 and rd(s, 0xD0F9 + r - 1) ~= 0xFF then a = -1 end
    end
    if a >= 0 then
      s.cca7 = a
      loadSelected(s)
      if checkAffordable(s) ~= 0 then break end
    end
  end
  pickD091Mark(s)
end
-- $72E2: Focus (Magi) / Fight, at the Magi slot
AI[1] = function(s) s.cca7 = 0; loadSelected(s); wr(s, 0xD103, 9) end
AI[2] = AI[1]
-- $71EF MatchSixRemainderThenPickSlot
AI[3] = function(s)
  local d074 = 0
  while true do
    d074 = band(d074 + 1, 0xFF)
    wr(s, 0xD074, d074)
    local a = 0
    if d074 ~= 0 then
      local r = divStep(s) % 6
      if r >= 2 then
        a = r - 1
        if rd(s, 0xD0F9 + r - 2) ~= 0xFF then a = -1 end
      end
    end
    if a >= 0 then
      s.cca7 = a
      loadSelected(s)
      if checkAffordable(s) ~= 0 then break end
    end
  end
  resolveD103(s)
  if rd(s, 0xD0C9) ~= 0 then return end
  if band(rd(s, 0xD0EE), 0x40) ~= 0 then
    if band(divStep(s), 0x10) == 0 then pickD096Plus5(s) else pickD092Plus1(s) end
  elseif rd(s, 0xD105) >= 5 then pickD096Plus5(s)
  else pickD092Plus1(s) end
end
local function add4(s) local t = rd(s, 0xD103); wr(s, 0xD103, t == 0 and 9 or t + 4) end
AI[4] = function(s) pickBy(s, fourScores(s, 0xD25A, true), true); add4(s) end   -- $71CC
AI[5] = function(s) pickBy(s, fourScores(s, 0xD25A, true), false); add4(s) end  -- $71B2
AI[6] = function(s) pickBy(s, fourScores(s, 0xD25A, false), true); add4(s) end  -- $71BF
AI[7] = function(s) pickBy(s, fourScores(s, 0xD25A, false), false); add4(s) end -- $71A5
AI[8] = pickD096Plus5                                                             -- $7191
AI[9] = function(s) wr(s, 0xD103, rd(s, 0xD392)) end                              -- $718A
AI[10] = function(s) pickBy(s, fourScores(s, 0xD17E, true), true) end            -- $7180
AI[11] = function(s) pickBy(s, fourScores(s, 0xD17E, true), false) end           -- $716C
AI[12] = function(s) pickBy(s, fourScores(s, 0xD17E, false), true) end           -- $7176
AI[13] = function(s) pickBy(s, fourScores(s, 0xD17E, false), false) end          -- $7162
AI[14] = pickD092Plus1                                                            -- $714F
AI[15] = function(s) wr(s, 0xD103, 0) end                                         -- $71D9
AI[16] = function(s)                                                              -- $71DE
  local a = 0
  for i = 0, 3 do a = bor(a, rd(s, 0xD092 + i)) end
  if a == 0 then wr(s, 0xD103, 0) else pickD092Plus1(s) end
end
E.AI = AI

local function runAI(s)
  emit(s, { t = "ai", type = rd(s, 0xD0F0), slot = rd(s, 0xD0B6) })
  local f = AI[rd(s, 0xD0F0)]
  if f then f(s) else unimpl(s, ("AI type %d"):format(rd(s, 0xD0F0))) end
end

---------------------------------------------------------------------------
-- move handlers, bank 2 $47D0-$5040. Every creature command is a short chain
-- of the same few steps; the table lists each handler's chain in ROM order.
--   Z            `ret z`: stop when the hit did no damage
--   TWO          D071 = 2 (no damage popup / miss text)
--   {A, p}       stage the bank-$4C move animation p
--   {K, t}       AddDividerStep < t -> instant elimination ($5:4B45)
--   {C, t}       continue only when AddDividerStep < t
--   {UP, o, n, msg} / {DN, o, n, msg}  raise (cap 99) / lower (floor 1) target
--                stat at record offset o by n; message when the target is a creature
--   {BIT, b}     give the target status bit b unless immune or already set
--   {HEAL, k}    D077 = (MaskDiv(7) + 1) * k healed onto the target
--   DRAIN        actor regains half of the damage
--   CURE         clear temporary status (bank 7 $66D2)
---------------------------------------------------------------------------
local Z, TWO, A, K, C, UP, DN, BIT, HEAL, DRAIN, CURE, IGNITE =
  "z", "two", "anim", "kill", "chance", "up", "dn", "bit", "heal", "drain", "cure", "ignite"
local SKILL, SPEED, DEF, RES, LUCK = 0x0C, 0x0D, 0x0E, 0x0F, 0x10
local HANDLERS = {
  [0x47D0] = { Z, { A, 0x5A32 } }, [0x47DA] = { Z, { A, 0x4EE1 } }, [0x47E4] = { Z, { A, 0x57D0 } },
  [0x47EE] = { Z, { A, 0x53B3 } }, [0x47F8] = { Z, { A, 0x4F18 } },
  [0x4802] = { TWO, { UP, SKILL, 0x14, 0x490B } },
  [0x4838] = { Z, { A, 0x5640 }, { K, 0x40 } },
  [0x4850] = { TWO, { BIT, 0x10 } },
  [0x4865] = { Z, { A, 0x4E80 } },
  [0x486F] = { TWO, { UP, SKILL, 0x14, 0x490B } },
  [0x48A5] = { Z, { A, 0x4DC6 }, { C, 0xC0 }, { DN, SKILL, 0x14, 0x45F5 } },
  [0x48E3] = { Z, { A, 0x4D87 } },
  [0x48ED] = { TWO, { A, 0x5320 }, { DN, SPEED, 0x14, 0x460D } },
  [0x4929] = { Z, { A, 0x4E80 }, DRAIN, { K, 0x40 } },
  [0x4951] = { Z, { A, 0x5698 } },
  [0x495B] = { Z, { A, 0x596F }, { K, 0x40 } },
  [0x4973] = { Z, { A, 0x505A } },
  [0x497D] = { Z, { A, 0x51D0 }, { K, 0x40 } },
  [0x4995] = { Z, { A, 0x56D6 } },
  [0x499F] = { TWO, { A, 0x5B77 }, { BIT, 0x40 } },
  [0x49BC] = { Z, { A, 0x53B3 } },
  [0x49C6] = { Z, { A, 0x4E80 }, { K, 0x40 } },
  [0x49DE] = { TWO, { HEAL, 4 } },
  [0x49F7] = { Z, { A, 0x4FD5 }, { K, 0x40 } },
  [0x4A0F] = { Z, { A, 0x57D0 } }, [0x4A19] = { Z, { A, 0x4F18 } },
  [0x4A23] = { TWO, { A, 0x4D5C }, { BIT, 0x40 } },
  [0x4A40] = { Z, { A, 0x5429 } },
  [0x4A4A] = { TWO, { UP, LUCK, 0x32, 0x48C9 } },
  [0x4A80] = { Z, { A, 0x4DC6 } }, [0x4A8A] = { Z, { A, 0x52AE } },
  [0x4A94] = { TWO, { DN, SPEED, 0x14, 0x460D } },
  [0x4AC8] = { Z, { A, 0x5B01 } }, [0x4AD2] = { Z, { A, 0x53EE } }, [0x4ADC] = { Z, { A, 0x576A } },
  [0x4AE6] = { { A, 0x4D35 }, { HEAL, 2 } },
  [0x4B01] = { Z, { A, 0x4F18 }, { C, 0x80 }, IGNITE },
  [0x4B27] = { Z, { A, 0x5854 } },
  [0x4B31] = { Z, { A, 0x57D0 }, { BIT, 0x01 } },
  [0x4B4A] = { Z, { A, 0x596F } },
  [0x4B54] = { TWO, { BIT, 0x80 } },
  [0x4B69] = { Z, { A, 0x5205 } }, [0x4B73] = { Z, { A, 0x5109 } },
  [0x4B7D] = { TWO, { A, 0x4EE1 }, { DN, RES, 0x0A, 0x45DC } },
  [0x4BB9] = { Z, { A, 0x5245 } }, [0x4BC3] = { Z, { A, 0x59D2 } }, [0x4BCD] = { Z, { A, 0x5A32 } },
  [0x4BD7] = { TWO, { A, 0x4B79 }, { BIT, 0x40 } },
  [0x4BF4] = { TWO, { A, 0x4D35 }, CURE },
  [0x4C0A] = { TWO, { UP, DEF, 0x0A, 0x48B1 } },
  [0x4C40] = { Z, { A, 0x4E80 } }, [0x4C4A] = { Z, { A, 0x5BC4 } },
  [0x4C54] = { Z, { A, 0x4C5E }, { K, 0x40 } },
  [0x4C6C] = { Z, { A, 0x5A32 } },
  [0x4C76] = { TWO, { A, 0x560E }, { BIT, 0x40 } },
  [0x4C93] = { TWO, { BIT, 0x20 } },
  [0x4CA8] = { Z, { A, 0x4DC6 } }, [0x4CB2] = { Z, { A, 0x4E4B } }, [0x4CBC] = { Z, { A, 0x5698 } },
  [0x4CC6] = { TWO, { A, 0x4F64 }, { DN, DEF, 0x0A, 0x45C2 } },
  [0x4D02] = { Z, { A, 0x5805 } }, [0x4D0C] = { Z, { A, 0x4D87 } },
  [0x4D16] = { Z, { A, 0x5A32 }, { K, 0x40 } },
  [0x4D2E] = { Z, { A, 0x4D5C } }, [0x4D38] = { Z, { A, 0x5205 } },
  [0x4D42] = { TWO, { UP, DEF, 0x14, 0x48B1 } },
  [0x4D78] = { Z, { A, 0x5360 } },
  [0x4D82] = { Z, { A, 0x5A32 }, { K, 0x40 } },
  [0x4D9A] = { TWO, { BIT, 0x80 } },
  [0x4DAF] = { TWO, { UP, SPEED, 0x14, 0x48F5 } },
  [0x4DE5] = { Z, { A, 0x4F64 }, { DN, RES, 0x14, 0x45DC } },
  [0x4E1D] = { Z, { A, 0x4D5C } },
  [0x4E27] = { TWO, { UP, DEF, 0x0A, 0x48B1 } },
  [0x4E5D] = { Z, { A, 0x560E }, { C, 0xC0 }, { BIT, 0x01 } },
  [0x4E7C] = { Z, { A, 0x5C67 } },
  [0x4E86] = { Z, { A, 0x5854 }, { C, 0xC0 }, { BIT, 0x01 } },
  [0x4EA5] = { Z, { A, 0x5109 } }, [0x4EAF] = { Z, { A, 0x4BCC } },
  [0x4EB9] = { TWO, { BIT, 0x40 } },
  [0x4ECE] = { Z, { A, 0x5320 }, DRAIN },
  [0x4EE8] = { Z, { A, 0x51D0 } }, [0x4EF2] = { Z, { A, 0x5805 } }, [0x4EFC] = { Z, { A, 0x4CB8 } },
  [0x4F06] = { Z, { A, 0x5889 }, { K, 0x40 } },
  [0x4F1E] = { Z, { A, 0x5854 } }, [0x4F28] = { Z, { A, 0x5854 } },
  [0x4F32] = { Z, { A, 0x55BD }, { K, 0x40 } },
  [0x4F4A] = { TWO, { BIT, 0x40 } },
  [0x4F5F] = { Z, { A, 0x4C7E } }, [0x4F69] = { Z, { A, 0x58CD } }, [0x4F73] = { Z, { A, 0x4CB8 } },
  [0x4F7D] = { TWO, { UP, DEF, 0x0A, 0x48B1 } },
  [0x4FB3] = { Z, { A, 0x57D0 }, DRAIN },
  [0x4FCD] = { Z, { A, 0x590B }, { K, 0x40 } },
  [0x4FE5] = { Z, { A, 0x5320 }, { DN, SPEED, 0x14, 0x460D }, { C, 0x80 }, { BIT, 0x40 } },
  [0x5032] = { Z, { A, 0x51D0 }, { K, 0x40 } },
}
E.HANDLERS = HANDLERS

-- TrySetBitPairAtPlus14 on the target copy at $D110
local function trySetBit(s, base, mask)
  if band(rd(s, base + 0x14), mask) ~= 0 or band(rd(s, base + 0x15), mask) ~= 0 then return false end
  wr(s, base + 0x15, rd(s, base + 0x15) + mask)
  return true
end
local function statusName(s, mask)
  local b = 0
  while mask > 1 do mask = rshift(mask, 1); b = b + 1 end
  return s.data.statusNames and s.data.statusNames[b] or ("status" .. b)
end
-- StageNameTextAndScript41C1
local function statusMsg(s, mask)
  local n = names(s); n[3] = statusName(s, mask)
  say(s, 0x41C1, n)
  emit(s, { t = "status", slot = rd(s, 0xD103), bit = mask })
end

local function statMsg(s, amount, script)
  if rd(s, 0xD112) >= 0x58 then return end
  wr(s, 0xD0C7, rd(s, 0xD112)); wr(s, 0xD0C8, amount)
  say(s, script, { "", nameOf(s, rd(s, 0xD112)), tostring(amount) }) -- PlantMarkedNameAndCount
end

local function runChain(s, chain)
  for _, op in ipairs(chain) do
    local k = type(op) == "table" and op[1] or op
    if k == Z then if rd(s, 0xD073) == 0 then return end
    elseif k == TWO then wr(s, 0xD071, 2)
    elseif k == A then anim(s, op[2])
    elseif k == K then
      if divStep(s) >= op[2] then return end
      if rd(s, 0xD113) ~= 0x0C then wr(s, 0xD0B4, 1) end -- SetD0B4UnlessD113Is0C
    elseif k == C then if divStep(s) >= op[2] then return end
    elseif k == UP then
      local a = 0xD110 + op[2]
      local v = u8(rd(s, a) + op[3]); if v >= 0x63 then v = 0x63 end
      wr(s, a, v)
      -- `ld a,[$D112]; cp $58; ret nc`: a Magi target gets no message and the
      -- handler ends here (Whirl's confusion roll is skipped against a Magi)
      if rd(s, 0xD112) >= 0x58 then return end
      statMsg(s, op[3], op[4])
    elseif k == DN then
      local a = 0xD110 + op[2]
      local v = rd(s, a) - op[3]; if v <= 0 then v = 1 end
      wr(s, a, v)
      if rd(s, 0xD112) >= 0x58 then return end
      statMsg(s, op[3], op[4])
    elseif k == BIT then if trySetBit(s, 0xD110, op[2]) then statusMsg(s, op[2]) end
    elseif k == IGNITE then
      if trySetBit(s, 0xD110, 0x08) then
        wr(s, 0xD0DA, bor(rd(s, 0xD0DA), 0x30))
        statusMsg(s, 0x08)
      end
    elseif k == HEAL then
      wr(s, 0xD077, (maskDiv(s, 7) + 1) * op[2]); wr(s, 0xD070, 1); wr(s, 0xD076, 1)
    elseif k == DRAIN then
      wr(s, 0xD0C5, 0x10); wr(s, 0xD0C6, 0x10)
      wr(s, 0xD071, 1); plant(s, 0x4299) -- 5:$4595
    elseif k == CURE then -- bank 7 $66D2
      wr(s, 0xD076, 1); wr(s, 0xD077, 0); wr(s, 0xD071, 1)
      wr(s, 0xD125, rd(s, 0xD126)); plant(s, 0x4A4E)
    end
  end
end

-- the command handlers that are not creature moves
local SPECIAL = {}
SPECIAL[0x517D] = function(s) -- Fight
  if rd(s, 0xD0FF) ~= 0 then -- $5191 defend
    wr(s, 0xD071, 1); wr(s, 0xD076, 1); wr(s, 0xD077, 0)
    plant(s, 0x424B)
    emit(s, { t = "defend", slot = rd(s, 0xD0B6) })
    return
  end
  if rd(s, 0xD073) == 0 then return end
  anim(s, 0x5225)
end
SPECIAL[0x51C2] = function(s) wr(s, 0xD071, 2); wr(s, 0xD076, 2) end -- default
SPECIAL[0x51D2] = function(s) -- Run
  wr(s, 0xD076, 1); wr(s, 0xD077, 0)
  if band(divStep(s), 3) == 3 then wr(s, 0xD071, 1); plant(s, 0x4A29)
  else wr(s, 0xD016, E.ESCAPE); wr(s, 0xD071, 2) end
end
SPECIAL[0x504A] = function(s) -- Focus
  if rd(s, 0xD017) ~= 0 and rd(s, 0xD09A) == 0 then wr(s, 0xD071, 2); return end
  local function countFlag()
    wr(s, 0xD077, rw(s, 0xD117) == 0 and 1 or 0)
    wr(s, 0xD076, 1); wr(s, 0xD070, 1)
    plant(s, 0x4376)
  end
  if rd(s, 0xD0B6) == 9 then countFlag()
  else
    wr(s, 0xD073, maskDiv(s, 7) + 1); wr(s, 0xD070, 1)
    if rd(s, 0xD017) == 0 then portrait(s, 5, 0x0B, E.TONY_ID); plant(s, 0x4386) else countFlag() end
  end
  wr(s, 0xD071, 1)
  s.planted.subs = names(s)
end
SPECIAL[0x5272] = function(s) -- Summon (player): LoadD107EntryThenScript4AE0
  local slot = rd(s, 0xD103)
  wr(s, 0xD075, bor(rd(s, 0xD075), lshift(1, slot - 1))); wr(s, 0xD091 + slot, 1) -- 5:$405C
  wr(s, 0xD385, rd(s, 0xD385) + 1)
  local addr = rp(s, 0xD107)
  local saved = s.party[addr]
  if not saved then unimpl(s, "summon without party creature"); wr(s, 0xD071, 2); return end
  -- LoadD110Record: flag, 0, then the $25 saved bytes; energy starts full
  wr(s, 0xD110, rd(s, 0xD017) ~= 0 and 1 or 0); wr(s, 0xD111, 0)
  for i = 0, E.SAVED_LEN - 1 do wr(s, 0xD112 + i, saved[i] or 0) end
  wr(s, 0xD117, rd(s, 0xD119)); wr(s, 0xD118, rd(s, 0xD11A))
  wr(s, 0xD125, 0)
  runRelic(s, rd(s, 0xD134), "onSummon") -- RunPairIdScripts
  runRelic(s, rd(s, 0xD135), "onSummon")
  wr(s, 0xD125, bor(rd(s, 0xD126), rd(s, 0xD125)))
  wr(s, 0xD076, 1); wr(s, 0xD077, 0)
  wp(s, 0xD36E + (slot - 1) * 2, addr)
  wr(s, 0xD376 + slot - 1, rd(s, 0xD06F))
  wr(s, 0xD37A + rd(s, 0xD06F), 2)
  wp(s, 0xD07B, recAddr(slot))
  wr(s, 0xD071, 1)
  plant(s, 0x4AE0)
  s.partyOut[addr] = slot
  emit(s, { t = "summon", slot = slot, species = rd(s, 0xD112), party = addr })
end
SPECIAL[0x5331] = function(s) -- SummonX (enemy, in battle)
  local slot = rd(s, 0xD103)
  wr(s, 0xD075, bor(rd(s, 0xD075), lshift(1, slot - 1))); wr(s, 0xD091 + slot, 1)
  E.fillFromEntry(s, rd(s, 0xD068), rd(s, 0xD069), rd(s, 0xD06A))
  wp(s, 0xD07B, recAddr(slot))
  wr(s, 0xD071, 1)
  plant(s, rd(s, 0xD09A) ~= 0 and 0x4AF5 or 0x4B0A)
  emit(s, { t = "summon", slot = slot, species = rd(s, 0xD112) })
end
SPECIAL[0x50E6] = function(s) -- Item: CopyD107GroupThenScript446D
  local g = s.data.groups[rp(s, 0xD107)]
  say(s, 0x446D, { nameOf(s, rd(s, 0xD0DB)), g and g.name or "?" })
  E.groupEffect(s, g)
  if rd(s, 0xD017) ~= 0 then return end
  -- the save's item count at $A3A7 + index goes down by one
  if g then
    for _, it in ipairs(s.items) do if it.ptr == g.ptr and it.count > 0 then it.count = it.count - 1; break end end
  end
  wr(s, 0xD107, 0) -- only the low byte, as the game does
end
SPECIAL[0x5207] = function(s) -- Spell: CopyD107GroupThenScript4A40
  local g = s.data.groups[rp(s, 0xD107)]
  say(s, 0x4A40, { nameOf(s, rd(s, 0xD0DB)), g and g.name or "?" })
  -- the record's +$1F..+$21 animation is staged unless the caster targets itself (UI only)
  if g and rd(s, 0xD0B6) ~= rd(s, 0xD103) then
    emit(s, { t = "anim", script = g.raw[0x20] + g.raw[0x21] * 256, group = g.ptr })
  end
  E.groupEffect(s, g)
end
E.SPECIAL = SPECIAL

---------------------------------------------------------------------------
-- bank-7 item / spell effects. The group record is copied to $CD91; the fields
-- used are +2 ($CD93) amount, +3 ($CD94) stat index and +$19..$1B ($CDAA) the
-- message script that gets planted.
local GROUP = {}
local function cd(g, addr) return g.raw[addr - 0xCD91] or 0 end
local function plantCDAA(s, g)
  plant(s, cd(g, 0xCDAB) + cd(g, 0xCDAC) * 256)
end
-- the saved creature the target slot came from, for the permanent (SRAM) changes
local function savedOf(s, slot)
  if slot < 1 or slot > 4 then return nil end
  return s.party[rp(s, 0xD36E + (slot - 1) * 2)]
end
GROUP[0x64B5] = function(s, g) -- lower a stat by CD93, or plain damage CD93
  local k = cd(g, 0xCD94)
  if k ~= 0 then
    local a = 0xD110 + 0x0A + k
    local old = rd(s, a)
    local v = old - cd(g, 0xCD93); if v < 0 then v = 0 end
    wr(s, a, v)
    wr(s, 0xD077, u8(old - v)); wr(s, 0xD076, 2)
  else
    wr(s, 0xD077, cd(g, 0xCD93)); wr(s, 0xD076, 1)
  end
  wr(s, 0xD071, 1)
  plantCDAA(s, g)
end
GROUP[0x6551] = function(s, g) -- raise a stat by CD93 (cap $63), or heal CD93
  local k = cd(g, 0xCD94)
  if k ~= 0 then
    local a = 0xD110 + 0x0A + k
    local old = rd(s, a)
    local v = u8(old + cd(g, 0xCD93)); if v >= 0x63 then v = 0x63 end
    wr(s, a, v)
    wr(s, 0xD077, u8(v - old)); wr(s, 0xD076, 2)
  else
    wr(s, 0xD077, cd(g, 0xCD93)); wr(s, 0xD076, 1); wr(s, 0xD070, 1)
  end
  wr(s, 0xD071, 1)
  plantCDAA(s, g)
end
GROUP[0x650F] = function(s, g) -- 64B5, and the saved creature loses it for good
  GROUP[0x64B5](s, g)
  local sv = savedOf(s, rd(s, 0xD103))
  if sv then local i = 8 + cd(g, 0xCD94); sv[i] = u8((sv[i] or 0) - cd(g, 0xCD93)) end
end
GROUP[0x65AF] = function(s, g) -- 6551, and the saved creature keeps it
  GROUP[0x6551](s, g)
  local sv = savedOf(s, rd(s, 0xD103))
  if sv then
    local i = 8 + cd(g, 0xCD94)
    local v = u8((sv[i] or 0) + cd(g, 0xCD93)); if v >= 0x63 then v = 0x63 end
    sv[i] = v
  end
end
GROUP[0x66D2] = function(s) -- cure: statuses back to the creature's own
  wr(s, 0xD076, 1); wr(s, 0xD077, 0); wr(s, 0xD071, 1)
  plant(s, 0x4A4E)
  wr(s, 0xD125, rd(s, 0xD126))
end
GROUP[0x6701] = function(s, g) -- full energy
  wr(s, 0xD076, 1); wr(s, 0xD077, 0)
  wr(s, 0xD117, rd(s, 0xD119)); wr(s, 0xD118, rd(s, 0xD11A))
  wr(s, 0xD071, 1)
  plantCDAA(s, g)
end
GROUP[0x6739] = function(s, g) -- karmic: a permanent raise, and a random stat pays for it
  GROUP[0x65AF](s, g)
  local a = divStep(s)
  local rem = a % 5
  -- `dec a; add a; ld c, a; ld b, $00`: a remainder of 0 indexes $D36E + $FE = $D46C,
  -- past battle WRAM, so no saved creature is reached through it
  local pa = 0xD36E + band((rem - 1) * 2, 0xFF)
  local base = (s.m[pa] or 0) + (s.m[pa + 1] or 0) * 256
  if rd(s, 0xD103) < 5 then
    local sv = s.party[base]
    if sv then
      local i = rem + 9
      local v = u8((sv[i] or 0) - 1); if v == 0 then v = 1 end
      sv[i] = v
    end
  end
  s.karmicStat = rem
end
GROUP[0x6791] = function(s, g) -- master rune: +2 to all five stats, for good
  for k = 1, 5 do
    local fake = { raw = {} }
    for i, v in pairs(g.raw) do fake.raw[i] = v end
    fake.raw[2], fake.raw[3] = 2, k
    GROUP[0x65AF](s, fake)
  end
  plantCDAA(s, g)
end
local function rotateStatus(s, g, left)
  wr(s, 0xD076, 1); wr(s, 0xD077, 0)
  local v = rd(s, 0xD125)
  if left then v = u8(bor(lshift(v, 1), rshift(v, 7))) else v = u8(bor(rshift(v, 1), lshift(band(v, 1), 7))) end
  v = bor(v, rd(s, 0xD126))
  v = band(v, u8(bnot(rd(s, 0xD124))))
  wr(s, 0xD125, v)
  wr(s, 0xD111, 0x33); wr(s, 0xD071, 1)
  plantCDAA(s, g)
end
GROUP[0x67E3] = function(s, g) rotateStatus(s, g, true) end
GROUP[0x6824] = function(s, g) rotateStatus(s, g, false) end
GROUP[0x729D] = function(s, g) -- fixed damage CD93
  wr(s, 0xD076, 1); wr(s, 0xD077, cd(g, 0xCD93))
end
GROUP[0x72B1] = function(s, g) -- executioner: 10 + FFA9 mod 30
  wr(s, 0xD076, 1)
  local a = divStep(s)
  wr(s, 0xD077, a % 0x1E + 0x0A)
  wr(s, 0xD071, 1)
  plantCDAA(s, g)
end
GROUP[0x72F0] = function(s) -- cunning blow: the target is eliminated unless it is a magi
  if rd(s, 0xD113) ~= 0x0C then wr(s, 0xD0B4, 1) end
  divStep(s)
end
E.GROUP = GROUP

function E.groupEffect(s, g)
  if not g then unimpl(s, "group record"); wr(s, 0xD071, 2); return end
  local f = GROUP[g.handler]
  if f then return f(s, g) end
  unimpl(s, ("%s %s (handler 7:%04X)"):format(g.kind, g.name, g.handler))
  wr(s, 0xD071, 2)
end

local function runHandler(s)
  local h = rp(s, 0xD100)
  local f = SPECIAL[h]
  if f then return f(s) end
  local chain = HANDLERS[h]
  if chain then return runChain(s, chain) end
  unimpl(s, ("handler 2:%04X"):format(h))
end
E.runHandler = runHandler

---------------------------------------------------------------------------
-- FinishLowD103Refresh ($4140): hit, damage, handler, energy, elimination
---------------------------------------------------------------------------
-- PassIfScaledD11DBelowLimit ($5420)
local function passHit(s)
  local sample = u8(maskDiv(s, 0xFF) + u8(rd(s, 0xD11D) * 2))
  if band(rd(s, 0xD125), 0x10) ~= 0 then
    if sample < 0x4C then return true end
    say(s, 0x4448, names(s)) -- "is hidden!"
    return false
  end
  return sample < rd(s, 0xD108)
end
-- ScaleD0E4PairByD11E ($539D) / ScaleD0E5PairByD11F ($53CC)
local function scaleBase(s, stat, guard)
  local j = jitter(s, 0x0A, rd(s, 0xD0E9))
  local idx = u8(rd(s, stat) + j)
  local o = u8(idx * 2)
  local lo, hi = s.data.b2[o], s.data.b2[o + 1]
  local span = u8(hi - lo)
  local q = divideHL(span * u8(0x63 - rd(s, guard)), 0x64)
  return u8(q + lo)
end

-- ApplyD125WhenD105Below5 ($6DE7): target status reactions
local function applyD125(s)
  if rd(s, 0xD105) >= 5 then return end
  local st = rd(s, 0xD125)
  if band(st, 0x02) ~= 0 then -- stone
    wr(s, 0xD076, 1)
    if band(rd(s, 0xD106), 0x01) ~= 0 then wr(s, 0xD077, 0xFF)
    else local h = rshift(rd(s, 0xD073), 1); wr(s, 0xD077, h == 0 and 1 or h) end
    return
  end
  if band(st, 0x10) ~= 0 then -- hidden
    if band(st, 0x20) ~= 0 then wr(s, 0xD076, 1); wr(s, 0xD077, 0xFF); return end
    wr(s, 0xD125, bxor(rd(s, 0xD125), 0x10))
  end
  if band(rd(s, 0xD125), 0x01) ~= 0 and band(rd(s, 0xD106), 0x02) ~= 0 and band(rd(s, 0xD0EF), 0x01) == 0 then
    say(s, 0x4826, names(s)) -- fire cures plague
    wr(s, 0xD125, bxor(rd(s, 0xD125), 0x01))
  end
  if band(rd(s, 0xD125), 0x04) ~= 0 and band(rd(s, 0xD106), 0x08) ~= 0 then
    say(s, 0x442B, names(s)) -- water cures hiccups
    wr(s, 0xD125, bxor(rd(s, 0xD125), 0x04))
  end
  if band(rd(s, 0xD125), 0x40) ~= 0 and band(rd(s, 0xD110), rd(s, 0xD0D9)) ~= 0 then
    wr(s, 0xD125, bxor(rd(s, 0xD125), 0x40))
  end
end

-- ContinueAfterC71BPlant ($4593 / $459B)
local function afterPlant(s, show)
  if show then showPlanted(s) end
  if rd(s, 0xD016) == 0 then
    portrait(s, 0, 0x0C, rd(s, 0xD338)); portrait(s, 0, 0x0B, E.TONY_ID)
  end
  if rd(s, 0xD0B2) == 0 then return end
  emit(s, { t = "eliminated", slot = rd(s, 0xD103), species = rd(s, 0xD112) })
  wr(s, 0xD076, 0)
  if rd(s, 0xD0D2) == 0 then return end
  wr(s, 0xD073, rd(s, 0xD0D2))
  say(s, 0x4884, names(s))
end

function E.finishLow(s)
  for _, a in ipairs({ 0xD073, 0xD071, 0xD070, 0xD0B2, 0xD0B4, 0xD076, 0xD0C5, 0xD0D2 }) do wr(s, a, 0) end
  s.planted = nil
  local handler = rp(s, 0xD100)
  local actor, t = rd(s, 0xD0B6), rd(s, 0xD103)
  if rd(s, 0xD01A) == 0 and actor ~= 0 and actor ~= 9 and rd(s, 0xD0FF) == 0 and t < 0x0A then
    local subs = { nameOf(s, rd(s, 0xD0DB)), moveName(s), nameOf(s, rd(s, 0xD112)) }
    if t == actor then say(s, 0x4B44, subs)
    elseif handler == 0x517D then say(s, 0x4366, subs)
    else say(s, 0x4B32, subs) end
  end
  if rd(s, 0xD107) ~= 0 and passHit(s) then
    local base
    if handler == 0x517D or band(rd(s, 0xD105), 0x80) ~= 0 then base = scaleBase(s, 0xD0E4, 0xD11E)
    else base = scaleBase(s, 0xD0E5, 0xD11F) end
    wr(s, 0xD073, divideHL(base * rd(s, 0xD107), 0xFF) + 1)
  end
  runHandler(s)
  runRelic(s, rd(s, 0xD0FD), "onHit")
  runRelic(s, rd(s, 0xD0FE), "onHit")
  if rd(s, 0xD073) ~= 0 then
    local el = rd(s, 0xD106)
    if band(el, rd(s, 0xD122)) ~= 0 then
      local v = rd(s, 0xD073); v = v - rshift(v, 2); if v <= 0 then v = 1 end
      wr(s, 0xD073, v); say(s, 0x42A8, names(s))
    end
    if band(el, rd(s, 0xD123)) ~= 0 then
      local v = rd(s, 0xD073); v = v + rshift(v, 2); if v > 0xFF then v = 0xFF end
      wr(s, 0xD073, v); say(s, 0x42C3, names(s))
    end
    if rd(s, 0xD136) ~= 0 then wr(s, 0xD073, rshift(rd(s, 0xD073), 1) + 1) end
  end
  local d076 = rd(s, 0xD076)
  if d076 ~= 0 then wr(s, 0xD073, d076 == 2 and 0 or rd(s, 0xD077)) end
  local ko = false
  if rd(s, 0xD0B4) ~= 0 then ko = true
  elseif rd(s, 0xD073) ~= 0 then
    applyD125(s)
    if rd(s, 0xD0B4) ~= 0 then ko = true
    elseif rd(s, 0xD073) ~= 0 then
      local en, n = rw(s, 0xD117), rd(s, 0xD073)
      if rd(s, 0xD070) ~= 0 then
        en = en + n
        local mx = rw(s, 0xD119)
        if en > mx then en = mx end
        ww(s, 0xD117, en)
        emit(s, { t = "heal", slot = rd(s, 0xD103), amount = n })
      else
        if en - n <= 0 then ko = true else ww(s, 0xD117, en - n) end
      end
    end
  end
  if ko then
    wr(s, 0xD0D2, rshift(rd(s, 0xD118), 1) + 1)
    ww(s, 0xD117, 0)
    local tp = rp(s, 0xD07B)
    if tp == E.REC then
      if orFourD092AndD07E(s) == 0 then wr(s, 0xD016, E.LOSS) end
    elseif tp == recAddr(9) then
      if orD096Quad(s) == 0 then wr(s, 0xD016, E.WIN) end
    else
      wr(s, 0xD0B2, 1)
      local tt = rd(s, 0xD103)
      wr(s, 0xD091 + tt, 0); wr(s, 0xD0A5 + tt, 1)
      local skipMsg = false
      if tt < 5 then
        local k = rd(s, 0xD376 + tt - 1)
        wr(s, 0xD37A + k, 1)
        local idx = rp(s, 0xD36E + (tt - 1) * 2)
        if s.party[idx] then s.partyOut[idx] = nil; s.partyLost[idx] = true end
        portrait(s, 1, 0x0C, rd(s, 0xD338))
        wp(s, 0xD36E + (tt - 1) * 2, 0)
        wr(s, 0xD0D2, 0)
      else
        local v = rd(s, 0xD06C) + rd(s, 0xD114); if v > 0xFF then v = 0xFF end
        wr(s, 0xD06C, v)
        if rd(s, 0xD0D9) == 0 and rd(s, 0xD0B6) ~= 0 then
          local te, tm = rw(s, 0xD14E) + rd(s, 0xD0D2), rw(s, 0xD150)
          if te > tm then te = tm end
          ww(s, 0xD14E, te)
        end
        local sp, x = rd(s, 0xD112), 0xD0B8
        for _ = 1, 8 do -- the original stores into the first entry that differs
          if rd(s, x) ~= sp then wr(s, x, sp); break end
          x = x + 1
        end
        if rd(s, 0xD09A) == 0 and orD096Quad(s) == 0 then wr(s, 0xD016, E.WIN); skipMsg = true end
      end
      if not skipMsg then
        plant(s, rd(s, 0xD0B4) ~= 0 and 0x445A or 0x4235, names(s))
        wr(s, 0xD071, 1)
      end
    end
  end
  -- testD071
  local d071 = rd(s, 0xD071)
  if d071 ~= 0 then
    afterPlant(s, d071 ~= 2)
  elseif rd(s, 0xD073) == 0 then
    plant(s, 0x47FD, names(s)); afterPlant(s, true)
  else
    if rd(s, 0xD016) == 0 then
      emit(s, { t = "damage", slot = rd(s, 0xD103), amount = rd(s, 0xD073), species = rd(s, 0xD112) })
    end
    afterPlant(s, false)
  end
end

-- SelectD091MarkAfterD0B5 (5:$44F4): retarget a dead or diverted target
local function retarget(s)
  local d = rd(s, 0xD103)
  if rd(s, 0xD0B5) == 0 then
    if d >= 5 then
      for i = 5, 9 do if rd(s, 0xD091 + i) ~= 0 then wr(s, 0xD103, i); return end end
      wr(s, 0xD103, 9)
    else
      for i = 4, 0, -1 do if rd(s, 0xD091 + i) ~= 0 then wr(s, 0xD103, i); return end end
    end
  else
    if d >= 5 then
      for i = 5, 9 do if rd(s, 0xD091 + i) ~= 0 and i ~= d then wr(s, 0xD103, i); return end end
    else
      for i = 4, 0, -1 do if rd(s, 0xD091 + i) ~= 0 and i ~= d then wr(s, 0xD103, i); return end end
    end
  end
end

local function loadTarget(s)
  local r = recAddr(rd(s, 0xD103))
  wp(s, 0xD07B, r)
  copy37(s, 0xD110, r)
end

-- RefreshSlotForLowD103 ($5CDD)
function E.refreshSlot(s)
  wr(s, 0xD078, 0)
  local t = rd(s, 0xD103)
  if t == 0x0A or t >= 0x0C then
    -- EnterD016Mode2: the original ends the battle as a win here
    emit(s, { t = "anomaly", what = ("target code %02X reached RefreshSlotForLowD103"):format(t) })
    s.anomalies = (s.anomalies or 0) + 1
    wr(s, 0xD016, E.WIN)
    return
  end
  local finishOnly = false
  if t == 0x0B then
    E.finishLow(s); return
  end
  if rd(s, 0xD091 + t) == 0 and t ~= 9 then
    if rd(s, 0xD0A5 + t) == 0 then finishOnly = true
    else
      if rd(s, 0xD01A) == 1 then return end
      wr(s, 0xD0B5, 0); retarget(s)
    end
  end
  if not finishOnly then
    loadTarget(s)
    local k = rd(s, 0xD105)
    if k ~= 4 and k ~= 9 and rd(s, 0xD01A) ~= 1 then
      if band(rd(s, 0xD125), 0x80) ~= 0 then
        say(s, 0x4276, names(s))
        wr(s, 0xD0B5, 1); retarget(s)
        loadTarget(s)
      end
      if band(rd(s, 0xD125), 0x20) ~= 0 then
        local n = names(s); say(s, 0x47C5, n)
        wr(s, 0xD125, bxor(rd(s, 0xD125), 0x20)) -- AdjustLowNibbleOrToggleBit5, a = 1
        say(s, 0x47AF, { nameOf(s, rd(s, 0xD112)) })
        copy37(s, rp(s, 0xD07B), 0xD110)
        wr(s, 0xD103, rd(s, 0xD0B6))
        loadTarget(s)
      end
    end
  end
  E.finishLow(s)
  if rd(s, 0xD103) == 0x0B then return end
  copy37(s, rp(s, 0xD07B), 0xD110)
end

-- StepD074RangesInBank7 (5:$407C): a group command hits every slot its code covers
local GROUP_TONY = { low = { [0x18] = 1, [0x19] = 1, [0x1C] = 1, [0x1D] = 1 }, high = { [0x15] = 1, [0x1C] = 1, [0x1D] = 1 } }
local OWN_ALL = { [0x17] = 1, [0x19] = 1, [0x1B] = 1, [0x1D] = 1 }
local OWN_OTHERS = { [0x16] = 1, [0x18] = 1, [0x1A] = 1, [0x1C] = 1 }
local function groupCovers(s, code, slot, actor)
  local low = actor < 5
  if slot == 0 then return (low and GROUP_TONY.low or GROUP_TONY.high)[code] ~= nil end
  if slot == 9 then
    if rd(s, 0xD09A) == 0 then return false end
    return (low and GROUP_TONY.high or GROUP_TONY.low)[code] ~= nil
  end
  if rd(s, 0xD091 + slot) == 0 then return false end
  local own = (slot < 5) == low
  if own then
    if OWN_ALL[code] then return true end
    if OWN_OTHERS[code] and slot ~= actor then return true end
    return false
  end
  return code == 0x14 or code == 0x15 or code >= 0x1A
end
E.groupCovers = groupCovers

function E.groupAny(s, code, actor)
  if ((actor < 5) and GROUP_TONY.low or GROUP_TONY.high)[code] then return true end
  for slot = 1, 9 do if groupCovers(s, code, slot, actor) then return true end end
  return false
end

function E.groupHit(s)
  local code = rd(s, 0xD103)
  wr(s, 0xD0B0, code)
  local actor = rd(s, 0xD0B6)
  -- each check leaves its answer in $D019; $D074 is the slot counter, $D018 the slot
  local function hit(slot, f)
    wr(s, 0xD019, f and 1 or 0)
    if f then wr(s, 0xD103, slot); E.refreshSlot(s) end
  end
  -- the Tony check uses the code band test only (FlagD019ForCopiedD0B0)
  hit(0, ((actor < 5) and GROUP_TONY.low or GROUP_TONY.high)[code] and true or false)
  wr(s, 0xD074, 0)
  while true do
    local v = rd(s, 0xD074) + 1; wr(s, 0xD074, v)
    if v == 5 then break end
    wr(s, 0xD018, v)
    hit(v, groupCovers(s, code, v, actor))
  end
  wr(s, 0xD074, 4)
  while true do
    local v = rd(s, 0xD074) + 1; wr(s, 0xD074, v)
    if v == 9 then break end
    wr(s, 0xD018, v)
    hit(v, groupCovers(s, code, v, actor))
  end
  hit(9, groupCovers(s, code, 9, actor))
end

---------------------------------------------------------------------------
-- end-of-action status ticks and summon countdowns
---------------------------------------------------------------------------
-- ApplyMarkedSlotFlags ($6C7D) on the actor copy at $D0D9
local function applyMarkedFlags(s)
  if rd(s, 0xD0B7) ~= 0 then return end
  local st = rd(s, 0xD0EE)
  if band(st, 0x01) ~= 0 then -- plague: -10 from the low energy byte
    local lo = rd(s, 0xD0E1) - 0x0A
    if lo <= 0 then
      wr(s, 0xD0E0, 0); wr(s, 0xD0E1, 0); wr(s, 0xD0B7, 2)
      plant(s, 0x4860, { nameOf(s, rd(s, 0xD0DB)), nameOf(s, rd(s, 0xD112)), countText(s) })
      return
    end
    wr(s, 0xD0E1, lo)
    say(s, 0x4842, names(s))
    emit(s, { t = "plague", slot = rd(s, 0xD0B6), amount = 10 })
  end
  if band(rd(s, 0xD0EE), 0x08) ~= 0 then -- eruption countdown in the high nibble of +1
    local b = rd(s, 0xD0DA)
    local hi = rshift(b, 4); if hi == 0 then hi = 0x0F end
    hi = hi - 1
    if hi == 0 then
      local en = rw(s, 0xD0E0)
      wr(s, 0xD0E0, 0); wr(s, 0xD0E1, 0)
      local amt = divideHL(en, 3) + 1
      -- the negated amount stays at D0C3 (low byte first), as the game leaves it
      local neg = band(0x10000 - amt, 0xFFFF)
      wr(s, 0xD0C3, band(neg, 0xFF)); wr(s, 0xD0C4, rshift(neg, 8))
      local base = 0xD14E + E.STRIDE * (rd(s, 0xD0D9) * 4 + 1)
      for k = 0, 3 do
        local a = base + k * E.STRIDE
        local v = rw(s, a) - amt
        if v < 0 then v = 1 end
        ww(s, a, v)
      end
      wr(s, 0xD0B7, 2)
      plant(s, 0x42E7, names(s))
      return
    end
    wr(s, 0xD0DA, lshift(hi, 4) + band(b, 0x0F))
    say(s, 0x4320, names(s))
  end
  if band(rd(s, 0xD0EE), 0x20) ~= 0 then -- mirror wears off (AdjustLowNibbleOrToggleBit5, a = 0)
    local b = rd(s, 0xD0DA)
    local n = band(b, 0x0F) - 1
    if n == 0 then
      wr(s, 0xD0EE, bxor(rd(s, 0xD0EE), 0x20))
      say(s, 0x47AF, { nameOf(s, rd(s, 0xD0DB)) })
    else
      wr(s, 0xD0DA, band(b, 0xF0) + n)
      say(s, 0x47E2, { nameOf(s, rd(s, 0xD0DB)) })
    end
  end
end

-- ExpireD07ECountdowns (5:$5A45): pending summons arrive
local function expireCountdowns(s)
  for k = 0, 7 do
    local a = 0xD07E + k
    local v = rd(s, a)
    if v ~= 0 then
      v = v - 1; wr(s, a, v)
      if v == 0 then
        local slot = k + 1
        portrait(s, 0, 0x0C, rd(s, 0xD338))
        wr(s, 0xD112, rd(s, recAddr(slot) + 2))
        wr(s, 0xD103, slot)
        wr(s, 0xD075, bor(rd(s, 0xD075), lshift(1, slot - 1))); wr(s, 0xD091 + slot, 1)
        wr(s, 0xD384, rd(s, 0xD384) + 1)
        say(s, rd(s, 0xD09A) ~= 0 and 0x4AF5 or 0x4B0A, names(s))
        emit(s, { t = "appear", slot = slot, species = rd(s, 0xD112) })
      end
    end
  end
  wr(s, 0xD074, 0) -- the slot counter runs 8 down to 0
  local m = rd(s, 0xD075)
  for i = 0, 7 do
    if m == 0 then break end
    if band(m, 1) ~= 0 then wr(s, 0xD092 + i, 1) end
    m = rshift(m, 1)
  end
  for t = 0, 9 do if rd(s, 0xD0A5 + t) ~= 0 then wr(s, 0xD091 + t, 0) end end
end

---------------------------------------------------------------------------
-- ClearMarksAndWalkSlots ($66DD): Tony, the Magi, then the ranked creatures act
---------------------------------------------------------------------------
local function eliminateActor(s, slot)
  if slot == 0 then
    if orFourD092AndD07E(s) == 0 then wr(s, 0xD016, E.LOSS); return true end
    return false
  elseif slot == 9 then
    if orD096Quad(s) == 0 then wr(s, 0xD016, E.WIN); return true end
    return false
  end
  wr(s, 0xD091 + slot, 0); wr(s, 0xD0A5 + slot, 1)
  if slot < 5 then
    local k = rd(s, 0xD376 + slot - 1)
    wr(s, 0xD37A + k, 1)
    local idx = rp(s, 0xD36E + (slot - 1) * 2)
    if s.party[idx] then s.partyOut[idx] = nil; s.partyLost[idx] = true end
    wp(s, 0xD36E + (slot - 1) * 2, 0)
  end
  if rd(s, 0xD0B7) == 1 then plant(s, 0x434B, names(s)) end
  showPlanted(s)
  emit(s, { t = "eliminated", slot = slot, species = rd(s, 0xD0DB) })
  return false
end

function E.walkSlots(s)
  wr(s, 0xD017, 0); wr(s, 0xD075, 0)
  for t = 0, 9 do wr(s, 0xD0A5 + t, 0) end
  while true do
    wr(s, 0xD0B7, 0)
    local idx, slot = rd(s, 0xD017), nil
    if idx == 0 then slot = 0
    elseif idx == 1 then slot = 9
    else
      local c = rd(s, 0xD006 + idx)
      if c ~= 0xFF and rd(s, 0xD091 + c) ~= 0 then slot = c end
    end
    if slot then
      wr(s, 0xD0B6, slot)
      local rec = recAddr(slot)
      wp(s, 0xD079, rec)
      copy37(s, 0xD0D9, rec)
      s.actingSlot = slot
      emit(s, { t = "turn", slot = slot, species = rd(s, 0xD0DB) })
      local skipped = false
      if band(rd(s, 0xD0EE), 0x04) ~= 0 then -- hiccups
        local j = jitter(s, 0x12, rd(s, 0xD0E9))
        local v = u8(maskDiv(s, 0x20) + j)
        if v + (0xFF - rd(s, 0xD0E6)) >= 0x100 then
          say(s, 0x441C, names(s))
          skipped = true
        end
      end
      if not skipped then
        local cost, en = rd(s, 0xD102), rw(s, 0xD0E0)
        if (en >= cost and en ~= cost) or cost == 0 then
          ww(s, 0xD0E0, en - cost)
        else
          if idx < 2 then wr(s, 0xD0B1, 0)
          else
            wr(s, 0xD0B1, 1)
            if band(rd(s, 0xD105), 0x7F) >= 5 then wr(s, 0xD0FF, 0xFF) end
          end
          s.cca7 = 0
          wr(s, 0xD0CE, rd(s, 0xD103))
          loadSelected(s)
          local old = rd(s, 0xD0CE)
          if old < 0x0A then wr(s, 0xD103, old)
          elseif rd(s, 0xD0D9) ~= 0 then pickD091Mark(s)
          else
            local t = 9
            for i = 5, 8 do if rd(s, 0xD091 + i) ~= 0 then t = i; break end end
            wr(s, 0xD103, t)
          end
          emit(s, { t = "tired", slot = slot })
        end
        copy37(s, rec, 0xD0D9)
        emit(s, { t = "act", slot = slot, handler = rp(s, 0xD100), target = rd(s, 0xD103), species = rd(s, 0xD0DB),
      group = (rp(s, 0xD100) == 0x5207 or rp(s, 0xD100) == 0x50E6) and rp(s, 0xD107) or nil })
        if rd(s, 0xD103) < 0x14 then
          wr(s, 0xD01A, 0)
          E.refreshSlot(s)
        else
          wr(s, 0xD019, 0); wr(s, 0xD01A, 1)
          if slot ~= 0 and slot ~= 9 then say(s, 0x4B1A, { nameOf(s, rd(s, 0xD0DB)), moveName(s) }) end
          E.groupHit(s)
        end
        copy37(s, 0xD0D9, rec)
        if rd(s, 0xD0C5) ~= 0 then
          local amt = mulLByBShift5(rd(s, 0xD0C6), rd(s, 0xD073))
          local v, mx = rw(s, 0xD0E0) + amt, rw(s, 0xD0E2)
          if v >= mx then v = mx end
          ww(s, 0xD0E0, v)
        end
      end
      if idx >= 2 then applyMarkedFlags(s) end
      copy37(s, rec, 0xD0D9)
      if rd(s, 0xD0B7) ~= 0 then
        if eliminateActor(s, slot) then return end
      end
    end
    local r = rp(s, 0xD06D)
    if r ~= 0 and r ~= 1 then setD016WhenSlotsClosed(s) end
    if rd(s, 0xD016) ~= 0 then return end
    wr(s, 0xD017, idx + 1)
    if idx + 1 > 9 then break end
  end
  expireCountdowns(s)
  wp(s, 0xD06D, rp(s, 0xD06D) + 1)
end

---------------------------------------------------------------------------
-- choosing commands
---------------------------------------------------------------------------
-- legal-target masks (5:$402A table) for the player's menus: returns a set of slots
function E.targetMask(s, class, slot)
  local m = {}
  local enemySide = slot >= 5
  if class == 0x0A then m[slot] = true
  elseif class == 0x0B then -- no target
  elseif class == 0x0C or class == 0x0D then
    local low = (class == 0x0C) ~= enemySide
    for i = 0, 3 do
      local t = low and (i + 1) or (i + 5)
      if rd(s, 0xD091 + t) == 0 and rd(s, 0xD07D + t) == 0 then m[t] = true end
    end
  elseif class == 0x0E or class == 0x12 or class == 0x13 then
    if class ~= 0x0E then m[0] = true end
    for t = 1, 8 do if rd(s, 0xD091 + t) ~= 0 then m[t] = true end end
    if rd(s, 0xD09A) ~= 0 then
      local none = true
      for t = 5, 8 do if rd(s, 0xD091 + t) ~= 0 then none = false end end
      if class == 0x13 or none then m[9] = true end
    end
  elseif class == 0x0F then m[0] = true
  elseif class == 0x10 or class == 0x11 then m[9] = true
  end
  return m
end

-- the commands a side may pick for one slot. Each entry:
--   { kind = "move"|"focus"|"summon"|"spell"|"item"|"run", ptr = record, k = CCA7 index,
--     targets = { slot... } or code = group code, party = idx, group = ptr, cost = n }
function E.legal(s, slot)
  local out = {}
  local rec = recAddr(slot)
  local en = rw(s, rec + 7)
  local function add(c) out[#out + 1] = c end
  local function targets(class)
    local t = {}
    for i = 0, 9 do if E.targetMask(s, class, slot)[i] then t[#t + 1] = i end end
    return t
  end
  if slot == 0 then
    add({ kind = "focus", k = 0, ptr = E.FOCUS, targets = { 0 } })
    for k = 1, 4 do
      local p = rp(s, rec + 0x18 + 2 * (k - 1))
      if p == E.SUMMON then
        local free = targets(0x0C)
        if #free > 0 then
          for idx, sv in pairs(s.party) do
            if not s.partyOut[idx] and not s.partyLost[idx] then
              add({ kind = "summon", k = k, ptr = p, party = idx, species = sv[0], cost = E.summonCost(sv), targets = free })
            end
          end
        end
      elseif p == E.SPELL then
        for _, g in ipairs(s.spells) do
          local gr = s.data.groups[g]
          if gr and en > gr.cost then
            local c = { kind = "spell", k = k, ptr = p, group = g, cost = gr.cost }
            if gr.target >= 0x14 then c.code = gr.target else c.targets = targets(gr.target) end
            add(c)
          end
        end
      elseif p == E.ITEM then
        for _, it in ipairs(s.items) do
          local gr = s.data.groups[it.ptr]
          if gr and it.count > 0 then
            local c = { kind = "item", k = k, ptr = p, group = it.ptr }
            if gr.target >= 0x14 then c.code = gr.target else c.targets = targets(gr.target) end
            add(c)
          end
        end
      elseif p == E.RUN then
        add({ kind = "run", k = k, ptr = p, targets = { 0x0B } })
      end
    end
  else
    add({ kind = "move", k = 0, ptr = E.FIGHT, targets = targets(0x12) })
    for k = 1, 4 do
      local p = rp(s, rec + 0x18 + 2 * (k - 1))
      local mv = s.data.moves[p]
      if mv and rd(s, rec + 0x20 + k - 1) == 0xFF and p >= 0x5F1E then
        local c = { kind = "move", k = k, ptr = p, cost = mv.cost }
        local ok = true
        if mv.target >= 0x14 then
          c.code = mv.target
          -- PyBoy: a creature cannot pick an all-enemy-creatures move while no enemy
          -- creature is out (the menu does not take it); inferred rule: the code
          -- must cover at least one present slot
          ok = E.groupAny(s, mv.target, slot)
        else c.targets = targets(mv.target) end
        if ok and (en > mv.cost or mv.cost == 0) then add(c) end
      end
    end
  end
  return out
end

-- a creature costs Tony its full energy to summon (and pays it back +1 on a win)
function E.summonCost(saved) return saved[8] or 0 end -- the menu shows max energy

-- write a chosen command into the slot's record (what the menus at $5FDF do)
function E.choose(s, slot, c, target)
  local rec = recAddr(slot)
  local mv = s.data.moves[c.ptr]
  for i = 0, 15 do wr(s, rec + 39 + i, mv.raw[i]) end
  wr(s, rec + 38, 0) -- D0FF
  if c.kind == "summon" then
    wp(s, rec + 39 + 7, c.party) -- D107: which saved creature
    wr(s, rec + 39 + 2, c.cost or 0)
  elseif c.kind == "spell" or c.kind == "item" then
    local g = s.data.groups[c.group]
    wp(s, rec + 39 + 7, c.group)
    wr(s, rec + 39 + 2, g.cost)
    wr(s, rec + 39 + 3, g.target)
  elseif c.kind == "defend" then
    wr(s, rec + 38, 0xFF)
  end
  local t
  if c.code then t = c.code
  elseif target ~= nil then t = target
  elseif c.targets and c.targets[1] then t = c.targets[1]
  else t = 0x0B end
  wr(s, rec + 39 + 3, t)
  s.chosen[slot] = { kind = c.kind, ptr = c.ptr, target = t, group = c.group, party = c.party }
end

-- player creatures under stone keep their last command; confused ones attack at random
-- (WalkFourD092Records $5xxx). Returns the slots that still need a command.
function E.pending(s)
  local need = { 0 }
  for slot = 1, 4 do
    if rd(s, 0xD091 + slot) ~= 0 then
      local st = rd(s, recAddr(slot) + 0x15)
      if band(st, 0x42) == 0 then need[#need + 1] = slot end
    end
  end
  return need
end

local function playerAuto(s)
  -- WalkFourD092Records: stone skips the menu, confusion picks a random target
  for slot = 1, 4 do
    if rd(s, 0xD091 + slot) ~= 0 then
      local rec = recAddr(slot)
      copy37(s, 0xD0D9, rec)
      wr(s, 0xD0B1, slot)
      if band(rd(s, 0xD0EE), 0x02) ~= 0 then
        say(s, 0x4AC1, names(s))
      elseif band(rd(s, 0xD0EE), 0x40) ~= 0 then
        s.cca7 = 0; loadSelected(s)
        local r
        repeat r = divStep(s) % 10 until rd(s, 0xD091 + r) ~= 0
        wr(s, 0xD103, r)
        say(s, 0x41D3, names(s))
      end
      copy37(s, rec, 0xD0D9)
    end
  end
end

local function enemyAI(s)
  for k = 0, 3 do
    local slot = 5 + k
    wr(s, 0xD0B1, bor(0x80, slot))
    -- ApplyFourD096Slots ($6A01) walks D079 over all four enemy records,
    -- present or not, and leaves it on slot 8 for the Magi's turn below
    local rec = recAddr(slot)
    wp(s, 0xD079, rec)
    if rd(s, 0xD096 + k) ~= 0 and not s.chosen[slot] then -- a chosen slot is driven from outside
      copy37(s, 0xD0D9, rec)
      wr(s, 0xD0FF, 0)
      if band(rd(s, 0xD0EE), 0x40) ~= 0 then
        s.cca7 = 0; loadSelected(s)
        local r
        repeat r = divStep(s) % 10 until rd(s, 0xD091 + r) ~= 0
        wr(s, 0xD103, r)
        say(s, 0x41D3, names(s))
      else
        runAI(s)
        wr(s, 0xD0FF, 0)
      end
      copy37(s, rec, 0xD0D9)
    end
  end
  -- DispatchSlot9ByD0F0 ($6BBA)
  if s.chosen[9] then return end
  wr(s, 0xD0B1, 9)
  copy37(s, 0xD0D9, recAddr(9)) -- DispatchSlot9ByD0F0 does not touch D079
  runAI(s)
  wr(s, 0xD0FF, 0)
  copy37(s, recAddr(9), 0xD0D9)
end

-- the engine half of a round (ApplyFourD096Slots .. ClearMarksAndWalkSlots), the
-- span the PyBoy oracle brackets
function E.resolve(s)
  enemyAI(s)
  E.rank(s)
  E.walkSlots(s)
end

-- a state from a WRAM dump (oracle replays): bytes = 1024-byte string for $D000-$D3FF
function E.load(data, bytes, ffa9, rng, party)
  local s = setmetatable({ data = data, rng = rng, m = {}, ffa9 = ffa9 or 0, events = {}, unimplemented = {},
    setup = {}, party = party or {}, partyOut = {}, partyLost = {}, spells = {}, items = {}, chosen = {},
    hashes = {}, rounds = 0 }, E)
  for i = 0, 0x3FF do s.m[0xD000 + i] = bytes:byte(i + 1) end
  return s
end

-- one round of LoopWhileD0D5 ($6591) after the player side has chosen
function E.round(s)
  s.events = {}
  if rd(s, 0xD016) ~= 0 then return s.events end
  playerAuto(s)
  enemyAI(s)
  E.rank(s)
  -- WaitUntilD3C2Clears (bank 2 $5E5E): a director duel's script gets one pass here
  -- (op $2E summons land before the slots walk); s.scriptPass may yield
  if s.scriptPass then s.scriptPass(s) end
  E.walkSlots(s)
  if rd(s, 0xD016) ~= 0 then E.finish(s) end
  s.chosen = {}
  s.rounds = (s.rounds or 0) + 1
  s.hashes[#s.hashes + 1] = E.hash(s)
  return s.events
end

-- DispatchNonzeroD016 ($6316): rewards and the closing message
function E.finish(s)
  local code = rd(s, 0xD016)
  s.result = code == E.WIN and "win" or code == E.LOSS and "loss" or code == E.ESCAPE and "escape" or ("code" .. code)
  if code == E.WIN then
    portrait(s, 4, 0x0C, rd(s, 0xD338)); portrait(s, 3, 0x0B, E.TONY_ID)
    for k = 0, 3 do
      local idx = rp(s, 0xD36E + 2 * k)
      if idx ~= 0 and s.party[idx] then
        local r = recAddr(k + 1)
        local v = rw(s, 0xD14E) + rw(s, r + 7) + 1
        local mx = rw(s, 0xD150)
        if v > mx then v = mx end
        ww(s, 0xD14E, v)
        s.party[idx][5] = rd(s, r + 7); s.party[idx][6] = rd(s, r + 8) -- creature energy back to the save
        s.partyOut[idx] = nil
      end
    end
    local an = rd(s, 0xD06C)
    if an > 0 then say(s, 0x43E2, { tostring(an) }) end
    for i = 0, 7 do
      local sp = rd(s, 0xD0B8 + i)
      if sp ~= 0xFF then say(s, 0x43F9, { nameOf(s, sp) }) end
    end
    say(s, 0x4B5B, {})
  elseif code == E.LOSS then
    portrait(s, 3, 0x0C, rd(s, 0xD338)); portrait(s, 4, 0x0B, E.TONY_ID)
    say(s, 0x45AB, {})
  elseif code == E.ESCAPE then
    say(s, 0x4A17, {})
  end
  s.animite = rd(s, 0xD06C)
  s.tonyEnergy = rw(s, 0xD14E)
  emit(s, { t = "end", result = s.result, animite = s.animite, tonyEnergy = s.tonyEnergy })
end

---------------------------------------------------------------------------
-- hashing and inspection
---------------------------------------------------------------------------
-- FNV-1a over battle WRAM $D000-$D3FF, $FFA9 and the party bookkeeping
function E.hash(s)
  local h = 0x811C9DC5
  local function mix(b)
    h = bxor(h, b)
    h = bit.tobit(h * 0x01000193 % 0x100000000)
  end
  for a = 0xD000, 0xD3FF do mix(s.m[a]) end
  mix(s.ffa9)
  return bit.tohex(h)
end

function E.slotInfo(s, slot)
  local r = recAddr(slot)
  return {
    slot = slot, present = rd(s, 0xD091 + slot) ~= 0, species = rd(s, r + 2), name = nameOf(s, rd(s, r + 2)),
    type = rd(s, r + 3), level = rd(s, r + 4), energy = rw(s, r + 7), max = rw(s, r + 9),
    str = rd(s, r + 11), skill = rd(s, r + 12), speed = rd(s, r + 13), def = rd(s, r + 14),
    resist = rd(s, r + 15), luck = rd(s, r + 16), status = rd(s, r + 0x15),
    pending = slot >= 1 and slot <= 8 and rd(s, 0xD07D + slot) ~= 0,
  }
end

function E.over(s) return rd(s, 0xD016) ~= 0 end
E.rd, E.rw, E.wr, E.ww, E.rp = rd, rw, wr, ww, rp

return E
