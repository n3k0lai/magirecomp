-- Presentation timeline for the 3D battle. Battle rules never read it: mn.Battle hands it the
-- engine's events (the same ones the 2D screen plays) and the frame count the 2D screen would
-- spend on each, so turns, RNG and outcomes stay byte-identical and only the picture changes.
-- Pure Lua (no LÖVE), unit-tested in tests/engine/mn_b3d_test.lua.
local T = {}
T.__index = T

local function clamp(x) return x < 0 and 0 or (x > 1 and 1 or x) end
local function smooth(x) x = clamp(x); return x * x * (3 - 2 * x) end
T.smooth = smooth

function T.new() return setmetatable({ clips = {}, f = 0 }, T) end

-- clip kinds: "attack" (actor lunges at target, target hit), "intro" (camera orbit),
-- "summon" (creature pops in), "elim" (creature blinks out). Each lasts exactly
-- `frames` presentation frames. attack, intro, summon and elim drive the camera.
-- Optional attack fields `damage` and `energy` are copied onto the clip ctx for the
-- shot table; the timeline never invents them.
function T:push(kind, frames, a) a = a or {}; a.kind, a.frames, a.start = kind, frames, self.f; self.clips[#self.clips + 1] = a; return a end

function T:step() self.f = self.f + 1; local live = {}
  for _, c in ipairs(self.clips) do if self.f - c.start < c.frames then live[#live + 1] = c end end
  self.clips = live
end

-- 0..1 progress of clip c at the current frame
function T:phase(c) return clamp((self.f - c.start) / math.max(1, c.frames)) end

local function copy3(p)
  if not p then return nil end
  return { p[1], p[2], p[3] }
end

-- per-slot pose offsets and camera state for the current frame
-- returns { pose = { [slot] = { dx, dy, dz, flash, scale } }, cam = clip-or-nil }
-- When cam is set, cam.ctx is { actor, target, slot, damage, energy }: world-position
-- copies for the shot table. `pos` itself is not written.
function T:sample(pos)
  local pose, cam = {}, nil
  local function P(slot) pose[slot] = pose[slot] or { 0, 0, 0, false, 1 }; return pose[slot] end
  for _, c in ipairs(self.clips) do
    local p = self:phase(c)
    if c.kind == "attack" and pos[c.actor] and pos[c.target] then
      local a, b = pos[c.actor], pos[c.target]
      -- lunge out over 0..0.35, hold, back over 0.55..0.8
      local k = p < 0.35 and smooth(p / 0.35) or (p < 0.55 and 1 or 1 - smooth((p - 0.55) / 0.25))
      local q = P(c.actor)
      q[1], q[3] = q[1] + (b[1] - a[1]) * 0.6 * k, q[3] + (b[3] - a[3]) * 0.6 * k
      q[2] = q[2] + math.sin(math.pi * clamp(p / 0.35)) * 0.4 * (p < 0.35 and 1 or 0)
      if p >= 0.3 and p < 0.8 then
        local t = P(c.target)
        t[4] = math.floor((self.f - c.start) / 2) % 2 == 0
        local s = 1 - (p - 0.3) / 0.5
        t[1] = t[1] + math.sin((self.f - c.start) * 1.7) * 0.12 * s
        t[3] = t[3] + (b[3] - a[3] > 0 and 1 or -1) * 0.25 * s
      end
      c.hit = p >= 0.3 and p < 0.8
      cam = cam or c
    elseif c.kind == "summon" then
      P(c.slot)[5] = smooth(p)
      cam = cam or c
    elseif c.kind == "elim" then
      local q = P(c.slot)
      q[4] = math.floor((self.f - c.start) / 3) % 2 == 0 and p < 0.5
      q[5] = 1 - smooth((p - 0.3) / 0.7)
      q[2] = q[2] + p * 0.6
      cam = cam or c
    elseif c.kind == "intro" then
      cam = cam or c
    end
  end
  if cam then
    cam.ctx = {
      actor = copy3(cam.actor and pos[cam.actor]),
      target = copy3(cam.target and pos[cam.target]),
      slot = copy3(cam.slot and pos[cam.slot]),
      damage = cam.damage,
      energy = cam.energy,
    }
  end
  return { pose = pose, cam = cam }
end

return T
