-- One battle driven by command sources: the place a lockstep harness plugs in.
--
--   local m = Match.new(data, setup, { seed = 7, player = Sides.random(1) })
--   while not m:over() do m:step() end
--
-- Each step asks the player side for every slot that needs a command, records
-- the choices (m.inputs) and the post-round state hash (m.hashes), then runs one
-- engine round. With opts.enemy set, enemy creature slots are commanded by that
-- side instead of the ROM's AI tables. Two machines that feed the same seed and
-- the same inputs get the same hashes round for round.
local Engine = require("mn.battle.Engine")
local Rng = require("mn.battle.Rng")

local M = {}
M.__index = M

function M.new(data, setup, opts)
  opts = opts or {}
  local self = setmetatable({ opts = opts, inputs = {}, hashes = {}, events = {}, log = {} }, M)
  self.rng = opts.rng or Rng.seeded(opts.seed or 1)
  self.state = Engine.new(data, setup, self.rng)
  self.player, self.enemy = opts.player, opts.enemy
  self.events[0] = self.state.round0
  self.hashes[0] = Engine.hash(self.state)
  return self
end

function M:view()
  local s = self.state
  local v = { round = s.rounds, slots = {} }
  for i = 0, 9 do v.slots[i] = Engine.slotInfo(s, i) end
  v.tonyLow = v.slots[0].energy < 30
  return v
end

local function ask(self, side, slot, chosen)
  local s = self.state
  local legal = Engine.legal(s, slot)
  if #legal == 0 then return end
  local idx, target = side:choose(self:view(), slot, legal)
  local c = legal[idx] or legal[1]
  Engine.choose(s, slot, c, target)
  chosen[#chosen + 1] = { slot = slot, index = idx, target = target, kind = c.kind, ptr = c.ptr, group = c.group, party = c.party }
end

function M:step()
  local s = self.state
  if Engine.over(s) then return nil end
  local chosen = {}
  if self.player then
    for _, slot in ipairs(Engine.pending(s)) do ask(self, self.player, slot, chosen) end
  end
  if self.enemy then
    for slot = 5, 8 do
      if Engine.slotInfo(s, slot).present then ask(self, self.enemy, slot, chosen) end
    end
  end
  self.inputs[#self.inputs + 1] = chosen
  local ev = Engine.round(s)
  self.events[#self.events + 1] = ev
  self.hashes[#self.hashes + 1] = Engine.hash(s)
  return ev
end

function M:over() return Engine.over(self.state) end
function M:result() return self.state.result end

return M
