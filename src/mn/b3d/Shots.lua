-- Camera shots for the 3D battle. Pure data: Presenter:camera looks a shot up by clip
-- kind and calls it with the timeline's progress. Nothing here steps the clock or
-- reads battle rules, so frame budgets, RNG and outcomes stay put.
--
--   shot = { eye = function(p, ctx) -> {x,y,z}, at = function(p, ctx) -> {x,y,z}, fov = degrees }
--   p    clip progress, 0..1
--   ctx  { actor, target, slot, damage, energy } from Timeline:sample (positions are
--        world-space copies; damage/energy are set only when the clip carries them)
--
-- The arena the eye must stay inside: floor y = 0, back wall quad at z = -6.5.
-- Every eye keeps z > -6, |x| < 6.5 and y > 0.3, so a shot never looks at the
-- back of that wall.
local S = {}

local FOV = 50

-- 3/4 view from behind Tony's side. Horizon sits in the upper third and every
-- slot's feet and billboard top (y + 2) land inside the frame (see the shots test).
local DEFAULT_EYE = { 1.40, 2.40, 7.60 }
local DEFAULT_AT = { 0.40, 0.85, -0.60 }

local function smooth(x)
  if x < 0 then x = 0 elseif x > 1 then x = 1 end
  return x * x * (3 - 2 * x)
end

local function copy3(v) return { v[1], v[2], v[3] } end

-- Which side of the exchange the camera sits on. A target further down +z
-- (toward Tony) puts the eye on -x; the usual player-to-enemy lunge puts it on +x.
local function sideOf(a, b)
  local dz = b[3] - a[3]
  if dz > 1e-4 then return -1 end
  if dz < -1e-4 then return 1 end
  local dx = b[1] - a[1]
  if dx > 1e-4 then return -1 end
  if dx < -1e-4 then return 1 end
  return 1
end

-- Low side cut. `dolly` is how far the eye slides in (world units) by p = 1.
-- The -x anchor sits further back: Tony stands at +x, and a close camera on
-- the far side clips him.
local function sideEyeAt(p, ctx, dolly)
  ctx = ctx or {}
  local a = ctx.actor or { 0, 0, 1.6 }
  local b = ctx.target or { 0, 0, -1.6 }
  local side = sideOf(a, b)
  local midX, midZ = (a[1] + b[1]) * 0.5, (a[3] + b[3]) * 0.5
  local x0 = side > 0 and 4.50 or -4.40
  local z0 = side > 0 and 7.05 or 9.05
  return {
    x0 + midX * 0.05 - side * dolly * p,
    1.70 + 0.30 * p,
    z0 - 0.18 * dolly * p,
  }, {
    0.15 + midX * 0.06,
    1.00,
    -0.30 + midZ * 0.04,
  }
end

local function focusOf(ctx)
  ctx = ctx or {}
  return ctx.slot or ctx.target or ctx.actor or { 0, 0, 0 }
end

S.default = {
  fov = FOV,
  eye = function() return copy3(DEFAULT_EYE) end,
  at = function() return copy3(DEFAULT_AT) end,
}

S.intro = {
  fov = FOV,
  -- Orbit in from the side-rear to the default view. Radius shrinks and the
  -- yaw stays under ~0.75 rad, which keeps the eye in front of the wall.
  eye = function(p)
    local s = smooth(p)
    local dx = DEFAULT_EYE[1] - DEFAULT_AT[1]
    local dz = DEFAULT_EYE[3] - DEFAULT_AT[3]
    local ang1, r1 = math.atan2(dx, dz), math.sqrt(dx * dx + dz * dz)
    local ang = ang1 + (1 - s) * 0.62
    local r = r1 + (1 - s) * 0.55
    return {
      DEFAULT_AT[1] + math.sin(ang) * r,
      DEFAULT_EYE[2] + (1 - s) * 1.15,
      DEFAULT_AT[3] + math.cos(ang) * r,
    }
  end,
  at = function() return copy3(DEFAULT_AT) end,
}

S.attack = {
  fov = FOV,
  eye = function(p, ctx) return (sideEyeAt(p, ctx, 0.75)) end,
  at = function(p, ctx) return select(2, sideEyeAt(p, ctx, 0.75)) end,
}

-- Deeper lateral dolly than attack. Presenter selects this only when the clip
-- carries damage >= half the target's energy (Shots.resolve).
S.bigHit = {
  fov = FOV,
  eye = function(p, ctx) return (sideEyeAt(p, ctx, 1.35)) end,
  at = function(p, ctx) return select(2, sideEyeAt(p, ctx, 1.35)) end,
}

S.elim = {
  fov = FOV,
  -- Pull back and up. The creature's own blink is the timeline's elim pose
  -- (the 2D path hides and shows the sprite while it goes); the camera just
  -- opens the shot.
  eye = function(p, ctx)
    local s = smooth(p)
    local f = focusOf(ctx)
    return {
      DEFAULT_EYE[1] + (f[1] - DEFAULT_EYE[1]) * 0.08 * s,
      DEFAULT_EYE[2] + 1.35 * s,
      DEFAULT_EYE[3] + 1.70 * s,
    }
  end,
  at = function(p, ctx)
    local s = smooth(p)
    local f = focusOf(ctx)
    return {
      DEFAULT_AT[1] + (f[1] - DEFAULT_AT[1]) * 0.35 * s,
      DEFAULT_AT[2] + 0.35 * s,
      DEFAULT_AT[3] + (f[3] - DEFAULT_AT[3]) * 0.25 * s,
    }
  end,
}

S.summon = {
  fov = FOV,
  -- Short push toward the slot. It stays wide enough that the other side of
  -- the field remains inside the clip box.
  eye = function(p, ctx)
    local s = smooth(p)
    local f = focusOf(ctx)
    return {
      DEFAULT_EYE[1] + (f[1] - DEFAULT_EYE[1]) * 0.10 * s,
      DEFAULT_EYE[2] - 0.18 * s,
      DEFAULT_EYE[3] - 0.46 * s,
    }
  end,
  at = function(p, ctx)
    local s = smooth(p)
    local f = focusOf(ctx)
    return {
      DEFAULT_AT[1] + (f[1] - DEFAULT_AT[1]) * 0.08 * s,
      DEFAULT_AT[2] + 0.04 * s,
      DEFAULT_AT[3] + (f[3] - DEFAULT_AT[3]) * 0.08 * s,
    }
  end,
}

-- attack -> bigHit when the event put damage and the target's energy on the clip
-- and the hit is at least half that energy. Missing fields leave the name "attack".
function S.resolve(kind, ctx)
  ctx = ctx or {}
  if kind == "attack" then
    local d, e = ctx.damage, ctx.energy
    if type(d) == "number" and type(e) == "number" and e > 0 and d >= e * 0.5 then return "bigHit" end
  end
  local shot = S[kind]
  if type(shot) == "table" and type(shot.eye) == "function" then return kind end
  return "default"
end

return S
