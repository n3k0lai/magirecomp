-- Command sources for a battle. A side answers one question:
--   side:choose(view, slot, legal) -> index into legal, target slot (or nil)
-- where view is read-only engine state (Engine.slotInfo per slot) and legal is
-- Engine.legal(state, slot). Sides are plain values so a lockstep harness can
-- replace one with a network proxy that sends/receives the same {index, target}.
local Rng = require("mn.battle.Rng")

local M = {}

-- uniform random command and target, from its own seeded stream
function M.random(seed)
  local r = Rng.seeded(seed)
  return {
    name = "random",
    choose = function(_, _, _, legal)
      local i = 1 + r:byte() % #legal
      local c = legal[i]
      local tg = c.targets and #c.targets > 0 and c.targets[1 + r:byte() % #c.targets] or nil
      return i, tg
    end,
  }
end

-- coverage-first: every slot walks its commands in order (skipping ones it has
-- used most), so a sweep reaches every move a creature has; Tony summons the
-- first party creature he can, then alternates Focus with the rest
function M.sweep(seed)
  local r = Rng.seeded(seed)
  local used = {}
  return {
    name = "sweep",
    choose = function(_, view, slot, legal)
      local best, bi = nil, 1
      for i, c in ipairs(legal) do
        local key = (c.kind or "") .. ":" .. (c.ptr or 0) .. ":" .. (c.group or 0) .. ":" .. (c.party or 0)
        local n = used[key] or 0
        if c.kind == "run" then n = n + 1000 end -- run last: it ends the sweep
        if c.kind == "summon" then n = n - 100 end
        if slot == 0 and c.kind == "focus" and view.tonyLow then n = n - 200 end
        if not best or n < best then best, bi = n, i end
      end
      local c = legal[bi]
      local key = (c.kind or "") .. ":" .. (c.ptr or 0) .. ":" .. (c.group or 0) .. ":" .. (c.party or 0)
      used[key] = (used[key] or 0) + 1
      local tg = c.targets and #c.targets > 0 and c.targets[1 + r:byte() % #c.targets] or nil
      return bi, tg
    end,
  }
end

-- replay a recorded list of {slot=, index=, target=} per round
function M.scripted(rounds)
  local round = 0
  local lastSeen = nil
  return {
    name = "scripted",
    choose = function(_, view, slot, legal)
      if view.round ~= lastSeen then round = round + 1; lastSeen = view.round end
      for _, c in ipairs(rounds[round] or {}) do
        if c.slot == slot then return math.min(c.index, #legal), c.target end
      end
      return 1, nil
    end,
  }
end

return M
