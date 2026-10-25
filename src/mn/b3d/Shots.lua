-- Camera shots for the 3D battle. Pure data: Presenter:camera looks a shot up by clip
-- kind and calls it with the timeline's progress. Nothing here steps the clock or
-- reads battle rules, so frame budgets, RNG and outcomes stay put.
--
--   shot = { eye = function(p, ctx) -> {x,y,z}, at = function(p, ctx) -> {x,y,z}, fov = degrees }
--   (fovAt(p, ctx), when present, overrides fov for that moment: attacks widen for long exchanges)
--   p    clip progress, 0..1
--   ctx  { actor, target, slot, damage, energy } from Timeline:sample (positions are
--        world-space copies; damage/energy are set only when the clip carries them)
--
-- The arena the eye must stay inside: floor y = 0, back wall quad at z = -6.5.
-- Every eye keeps z > -6, |x| < 6.5 and y > 0.3, so a shot never looks at the
-- back of that wall.
--
-- Each shot also says what the banner strips do (Presenter, MN_B3D_BANNERS):
--   banners = "rest"   canopy and grass hold still
--   banners = "slide"  they slide sideways the way the 2D header and footer do in an attack
local S = {}

-- Arena layout, shared by Presenter and the tests: player creatures 1-4 near the camera,
-- enemies 5-8 across, Tony (0) behind his row on the right, the enemy Magi (9) at the far
-- left end of its row. The Magi used to stand behind slot 5 and its card hid behind that
-- creature's card; out at the end of the row it clears all four enemy cards (the shots test
-- checks this with the widest name card).
function S.slotPos(slot)
  if slot >= 1 and slot <= 4 then return { (slot - 2.5) * 1.5, 0, 1.6 } end
  if slot >= 5 and slot <= 8 then return { (slot - 6.5) * 1.5, 0, -1.6 } end
  if slot == 0 then return { 2.4, 0, 3.4 } end
  return { -5.4, 0, -2.0 }
end

local FOV = 50

-- 3/4 view from behind Tony's side, far enough back that both rows and both Magi fit
-- with room to spare; every slot's feet and billboard top (y + 2) land inside the frame
-- and the grass fringe at the front edge sits below Tony's feet (see the shots test).
local DEFAULT_EYE = { 1.40, 3.20, 9.40 }
local DEFAULT_AT = { -0.30, 0.85, -0.80 }

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

-- Low two-shot across the exchange. The eye looks across the line from actor to target
-- from the front of the field (tilted toward +z so it reads as a 3/4 view and stays off the
-- side walls), and backs off with the distance between the two, so a long exchange (Tony
-- against the enemy Magi) frames as well as a short one; the attacker's whole card keeps a
-- margin from the frame edge (it used to sit right on it). `dolly` is how far the eye slides
-- in toward the pair (world units) by p = 1.
local REACH, PER_UNIT, TILT, X_MAX, Z_MAX = 5.5, 0.95, 0.35, 6.2, 9.0
local LIFT = 0.30 -- per unit of distance beyond 5: long exchanges rise instead of backing off the floor
-- When the eye would have to back off past Z_MAX (off the floor) it stops there and the lens
-- widens by the same ratio instead, so the pair keeps the framing it would have had.
local FOV_MAX = 75
local function sideEyeAt(p, ctx, dolly)
  ctx = ctx or {}
  local a = ctx.actor or { 0, 0, 1.6 }
  local b = ctx.target or { 0, 0, -1.6 }
  local mx, mz = (a[1] + b[1]) * 0.5, (a[3] + b[3]) * 0.5
  local dx, dz = b[1] - a[1], b[3] - a[3]
  local len = math.sqrt(dx * dx + dz * dz)
  local nx, nz
  if len < 1e-4 then nx, nz = 0, 1
  else
    nx, nz = -dz / len, dx / len
    if nz < -1e-4 or (math.abs(nz) <= 1e-4 and nx * sideOf(a, b) < 0) then nx, nz = -nx, -nz end
  end
  nx, nz = nx * (1 - TILT), nz * (1 - TILT) + TILT
  local nl = math.sqrt(nx * nx + nz * nz); nx, nz = nx / nl, nz / nl
  local r = REACH + PER_UNIT * len
  local ex, ez = mx + nx * r, mz + nz * r
  if ex > X_MAX then ez = ez + (ex - X_MAX); ex = X_MAX elseif ex < -X_MAX then ez = ez + (-X_MAX - ex); ex = -X_MAX end
  local ey = 1.90 + LIFT * math.max(0, len - 5)
  local fov = FOV
  if ez > Z_MAX then
    local far = math.sqrt((ex - mx) ^ 2 + (ez - mz) ^ 2)
    ez = Z_MAX
    local near = math.sqrt((ex - mx) ^ 2 + (ez - mz) ^ 2)
    fov = math.min(FOV_MAX, math.deg(2 * math.atan(math.tan(math.rad(FOV / 2)) * far / near)))
  end
  local tx, tz = mx - ex, mz - ez
  local tl = math.sqrt(tx * tx + tz * tz)
  local d = dolly * p
  return { ex + tx / tl * d, ey + 0.30 * p, ez + tz / tl * d }, { mx, 1.00, mz }, fov
end

local function focusOf(ctx)
  ctx = ctx or {}
  return ctx.slot or ctx.target or ctx.actor or { 0, 0, 0 }
end

S.default = {
  fov = FOV, banners = "rest",
  eye = function() return copy3(DEFAULT_EYE) end,
  at = function() return copy3(DEFAULT_AT) end,
}

S.intro = {
  fov = FOV, banners = "rest",
  -- Orbit in from the side-rear to the default view. Radius shrinks and the
  -- yaw stays under ~0.62 rad, which keeps the eye in front of the wall.
  eye = function(p)
    local s = smooth(p)
    local dx = DEFAULT_EYE[1] - DEFAULT_AT[1]
    local dz = DEFAULT_EYE[3] - DEFAULT_AT[3]
    local ang1, r1 = math.atan2(dx, dz), math.sqrt(dx * dx + dz * dz)
    local ang = ang1 + (1 - s) * 0.45
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
  fov = FOV, banners = "slide",
  fovAt = function(p, ctx) return select(3, sideEyeAt(p, ctx, 0.75)) end,
  eye = function(p, ctx) return (sideEyeAt(p, ctx, 0.75)) end,
  at = function(p, ctx) return select(2, sideEyeAt(p, ctx, 0.75)) end,
}

-- Deeper dolly than attack. Presenter selects this only when the clip
-- carries damage >= half the target's energy (Shots.resolve).
S.bigHit = {
  fov = FOV, banners = "slide",
  fovAt = function(p, ctx) return select(3, sideEyeAt(p, ctx, 1.35)) end,
  eye = function(p, ctx) return (sideEyeAt(p, ctx, 1.35)) end,
  at = function(p, ctx) return select(2, sideEyeAt(p, ctx, 1.35)) end,
}

S.elim = {
  fov = FOV, banners = "rest",
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
  fov = FOV, banners = "rest",
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
