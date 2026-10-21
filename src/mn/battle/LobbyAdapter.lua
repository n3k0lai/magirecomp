-- Wraps mn.battle.Engine in the mp-lobby battle interface (src/mn/net/BattleAdapter.lua
-- on the mp-lobby branch), so the self-play / lockstep harness can drive the real engine:
--
--   local LobbyAdapter = require("mn.battle.LobbyAdapter")
--   LobbyAdapter.configure(data)          -- mn.battle.Data.extract(rom), once
--   LobbyAdapter.register(BattleAdapter)  -- registers it as "engine"
--
-- The game's battles are Tony's side against one enemy Magi, so the mapping is:
--   side 1 = Tony (slot 0) and the creatures he summons (slots 1-4); setup.sides[1]
--            .creatures become his party (built with the game's template routine)
--   side 2 = the enemy Magi (slot 9) and its creatures (slots 5-8); setup.sides[2]
--            .creatures are op-$2E summons that appear after one round. The Magi itself
--            follows its in-game AI table; side 2 actions command the creatures, and
--            any creature side 2 does not command also uses the in-game AI.
-- All randomness comes from the seeded divider stand-in (mn.battle.Rng), so two peers
-- that feed the same actions get the same hash every turn.
local Engine = require("mn.battle.Engine")
local Data = require("mn.battle.Data")
local Rng = require("mn.battle.Rng")

local A = {}
A.__index = A
A.NAME = "engine"
A.MAX_TURNS = 200

local data
function A.configure(d) data = d end
function A.configureFromRom(path)
  data = Data.extract(require("mn.MnRom").fromFile(path))
  return data
end

function A.register(BattleAdapter)
  BattleAdapter.register(A.NAME, A)
end

local function entryId(e) return type(e) == "table" and e.id or e end

function A.new(setup)
  assert(data, "LobbyAdapter.configure(data) first")
  local s1, s2 = setup.sides[1] or {}, setup.sides[2] or {}
  local party, summons = {}, {}
  for _, c in ipairs(s1.creatures or {}) do
    local id = entryId(c)
    if id and id <= Data.CREATURE_LAST and not Data.isMagi(data, id) then
      party[#party + 1] = { species = id, spends = 1, energy = c.energy or 20 }
    end
  end
  for _, c in ipairs(s2.creatures or {}) do
    local id = entryId(c)
    if id and id <= Data.CREATURE_LAST and not Data.isMagi(data, id) and #summons < 4 then
      summons[#summons + 1] = { slot = 9, species = id, spends = 1, energy = c.energy or 20, delay = 1 }
    end
  end
  local magi = entryId(s2.magi)
  if not (magi and Data.isMagi(data, magi) and magi ~= Engine.TONY_ID) then magi = 0x5D end
  local self = setmetatable({ turn = 0, seen = { creatures = {}, moves = {} } }, A)
  self.state = Engine.new(data, { magi = magi, party = party, summons = summons }, Rng.seeded(setup.seed or 1))
  return self
end

-- the slots each side commands this turn
function A:slots(i)
  local s = self.state
  if i == 1 then return Engine.pending(s) end
  local t = {}
  for slot = 5, 8 do
    if Engine.rd(s, 0xD091 + slot) ~= 0 and Engine.rd(s, 0xD07D + slot) == 0 then t[#t + 1] = slot end
  end
  return t
end

-- JSON-safe: { slot, index (into Engine.legal), kind, ptr, group, target }
function A:actions(i)
  if self:result() then return {} end
  -- side 2 can always leave its turn to the in-game AI (its Magi always does)
  local out = i == 2 and { { slot = 9, kind = "ai" } } or {}
  for _, slot in ipairs(self:slots(i)) do
    for idx, c in ipairs(Engine.legal(self.state, slot)) do
      local base = { slot = slot, index = idx, kind = c.kind, ptr = c.ptr, group = c.group, party = c.party }
      if c.code or not c.targets or #c.targets == 0 then
        out[#out + 1] = base
      else
        for _, t in ipairs(c.targets) do
          local a = {}
          for k, v in pairs(base) do a[k] = v end
          a.target = t
          out[#out + 1] = a
        end
      end
    end
  end
  return out
end

local function same(a, b)
  return a.slot == b.slot and a.index == b.index and a.target == b.target and a.kind == b.kind
end

-- acts[i] is one action or a list of actions (one per slot); side 1 slots left out
-- take their first legal command, side 2 slots left out keep the in-game AI
function A:step(acts)
  if self:result() then return {} end
  self.turn = self.turn + 1
  local s, ev = self.state, {}
  for i = 1, 2 do
    local legal = self:actions(i)
    local list = acts[i] or {}
    if list.slot or list.kind then list = { list } end
    local done = {}
    for _, a in ipairs(list) do
      local ok = false
      for _, b in ipairs(legal) do if same(a, b) then ok = true; break end end
      if ok and a.kind == "ai" then
        done[9] = true
      elseif ok and not done[a.slot] then
        Engine.choose(s, a.slot, Engine.legal(s, a.slot)[a.index], a.target)
        done[a.slot] = true
      else
        ev[#ev + 1] = { kind = "illegal", side = i, action = type(a) == "table" and a.kind or "none" }
      end
    end
    if i == 1 then
      for _, slot in ipairs(self:slots(1)) do
        if not done[slot] then Engine.choose(s, slot, Engine.legal(s, slot)[1]) end
      end
    end
  end
  for _, e in ipairs(Engine.round(s)) do
    local o = { kind = e.t }
    for k, v in pairs(e) do if k ~= "t" and type(v) ~= "table" then o[k] = v end end
    ev[#ev + 1] = o
    if e.t == "act" then
      if e.species then self.seen.creatures[e.species] = true end
      self.seen.moves[("%04X"):format(e.handler)] = true
    elseif e.t == "summon" or e.t == "appear" then
      self.seen.creatures[e.species] = true
    end
  end
  return ev
end

function A:hash() return Engine.hash(self.state) end

function A:result()
  local s = self.state
  if Engine.over(s) then
    local r = s.result
    if r == "win" then return { winner = 1, why = "enemy magi defeated" } end
    if r == "loss" then return { winner = 2, why = "Tony defeated" } end
    return { winner = 0, why = r or "ended" }
  end
  if self.turn >= A.MAX_TURNS then return { winner = 0, why = "turn limit" } end
  return nil
end

-- moves are keyed by their handler address (each of the 103 move records has its own)
function A:coverage() return { creatures = self.seen.creatures, moves = self.seen.moves } end

return A
