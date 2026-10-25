-- Camera shots: every shot keeps its subjects in frame and its eye inside the arena.
--   luajit tests/engine/mn_b3d_shots_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
local Mat4 = require("mn.b3d.Mat4")
local Shots = require("mn.b3d.Shots")
local Timeline = require("mn.b3d.Timeline")

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end
local function near(a, b) return math.abs(a - b) < 1e-6 end

-- the layout Presenter draws (player 1-4, enemies 5-8, Magi at 0 and 9)
local slotPos = Shots.slotPos

local ASPECT = 480 / 432 -- Presenter default canvas, same ratio as the 160x144 game view
local NAMES = { "default", "intro", "attack", "bigHit", "elim", "summon" }
local PS = { 0, 0.25, 0.5, 0.75, 1 }

local function project(eye, at, fov, point)
  local c = Mat4.apply(Mat4.mul(Mat4.perspective(math.rad(fov), ASPECT, 0.1, 60), Mat4.lookAt(eye, at)), point)
  return c[1] / c[4], c[2] / c[4], c[4]
end

local function inFrame(eye, at, fov, point, limit)
  local x, y, w = project(eye, at, fov, point)
  return w > 0 and math.abs(x) <= limit and math.abs(y) <= limit, x, y, w
end

local function feetAndTop(slot)
  local p = slotPos(slot)
  return { p[1], 0, p[3] }, { p[1], 2.0, p[3] }
end

local function inArena(eye)
  return eye[3] > -6.0 and math.abs(eye[1]) < 6.5 and eye[2] > 0.3
end

local function ctxFor(actor, target, slot)
  return { actor = slotPos(actor), target = slotPos(target), slot = slot and slotPos(slot) or nil }
end

-- default frames all ten slots, feet and tops, with a margin
do
  local shot = Shots.default
  local eye, at = shot.eye(0, {}), shot.at(0, {})
  ok(inArena(eye), "default eye inside the arena")
  for slot = 0, 9 do
    local feet, top = feetAndTop(slot)
    local fok, fx, fy = inFrame(eye, at, shot.fov, feet, 0.95)
    local tok, tx, ty = inFrame(eye, at, shot.fov, top, 0.95)
    ok(fok, string.format("default slot %d feet in [-0.95,0.95] (%.3f,%.3f)", slot, fx, fy))
    ok(tok, string.format("default slot %d top in [-0.95,0.95] (%.3f,%.3f)", slot, tx, ty))
  end
end

-- every shot, every sample, actor and target in the clip box and in front of the camera
for _, name in ipairs(NAMES) do
  local shot = Shots[name]
  ok(type(shot.eye) == "function" and type(shot.at) == "function" and type(shot.fov) == "number", name .. " is a shot")
  for actor = 0, 9 do
    for target = 0, 9 do
      if actor ~= target then
        local slot = (name == "summon" or name == "elim") and actor or nil
        local ctx = ctxFor(actor, target, slot)
        for _, p in ipairs(PS) do
          local eye, at = shot.eye(p, ctx), shot.at(p, ctx)
          local label = string.format("%s %d->%d p=%s", name, actor, target, p)
          ok(inArena(eye), label .. " eye inside the arena")
          for _, slotId in ipairs({ actor, target }) do
            local feet, top = feetAndTop(slotId)
            local fov = shot.fovAt and shot.fovAt(p, ctx) or shot.fov
            local fok, fx, fy, fw = inFrame(eye, at, fov, feet, 1)
            local tok, tx, ty, tw = inFrame(eye, at, fov, top, 1)
            ok(fok, string.format("%s slot %d feet in frame (%.3f,%.3f w=%.3f)", label, slotId, fx, fy, fw))
            ok(tok, string.format("%s slot %d top in frame (%.3f,%.3f w=%.3f)", label, slotId, tx, ty, tw))
          end
        end
      end
    end
  end
end

-- intro stays inside the arena between the sampled points too, and lands on default
do
  local shot = Shots.intro
  for i = 0, 20 do
    local eye = shot.eye(i / 20, {})
    ok(inArena(eye), string.format("intro p=%.2f eye inside the arena", i / 20))
  end
  local e0 = shot.eye(0, {})
  ok(math.abs(e0[1]) > 4, "intro starts off to the side")
  ok(e0[3] > -6, "intro does not start behind the back wall")
  local e1, a1 = shot.eye(1, {}), shot.at(1, {})
  local dE, dA = Shots.default.eye(1, {}), Shots.default.at(1, {})
  ok(near(e1[1], dE[1]) and near(e1[2], dE[2]) and near(e1[3], dE[3]), "intro ends on the default eye")
  ok(near(a1[1], dA[1]) and near(a1[2], dA[2]) and near(a1[3], dA[3]), "intro ends on the default aim")
end

-- attack is a low two-shot from the side; bigHit dollies further in; elim pulls back and up; summon pushes in
do
  local ctx = ctxFor(4, 8, 4)
  local a0 = Shots.attack.eye(0, ctx)
  local a1 = Shots.attack.eye(1, ctx)
  local b1 = Shots.bigHit.eye(1, ctx)
  ok(a0[2] < 2.1 and math.abs(a0[1]) > 3, "attack is a low side view")
  local mid = { (ctx.actor[1] + ctx.target[1]) / 2, 0, (ctx.actor[3] + ctx.target[3]) / 2 }
  local function reach(e) return math.sqrt((e[1] - mid[1]) ^ 2 + (e[3] - mid[3]) ^ 2) end
  ok(reach(a1) < reach(a0) - 0.5, "attack dollies in toward the pair")
  ok(reach(b1) < reach(a1) - 0.3, "bigHit dollies further than attack")
  local e0, e1 = Shots.elim.eye(0, ctx), Shots.elim.eye(1, ctx)
  ok(e1[2] > e0[2] + 1 and e1[3] > e0[3] + 1, "elim pulls back and up")
  local s0, s1 = Shots.summon.eye(0, ctx), Shots.summon.eye(1, ctx)
  ok(s1[3] < s0[3], "summon pushes in")
end

-- bigHit only when the clip carries damage >= half the target's energy
do
  ok(Shots.resolve("attack", { damage = 5, energy = 10 }) == "bigHit", "half energy is a big hit")
  ok(Shots.resolve("attack", { damage = 6, energy = 10 }) == "bigHit", "over half energy is a big hit")
  ok(Shots.resolve("attack", { damage = 4, energy = 10 }) == "attack", "under half energy stays attack")
  ok(Shots.resolve("attack", { damage = 9 }) == "attack", "damage without energy stays attack")
  ok(Shots.resolve("attack", {}) == "attack", "attack without numbers stays attack")
  ok(Shots.resolve("intro", { damage = 9, energy = 10 }) == "intro", "only attack upgrades to bigHit")
  ok(Shots.resolve(nil, {}) == "default", "no clip is the default shot")
end

-- timeline hands the shot a ctx and does not mutate positions
do
  local pos = {}
  for slot = 0, 9 do pos[slot] = slotPos(slot) end
  local tl = Timeline.new()
  tl:push("attack", 10, { actor = 1, target = 5, damage = 8, energy = 10 })
  tl:step()
  local sm = tl:sample(pos)
  ok(sm.cam and sm.cam.kind == "attack", "attack clip drives the camera")
  ok(sm.cam.ctx.damage == 8 and sm.cam.ctx.energy == 10, "attack ctx carries damage and energy")
  ok(sm.cam.ctx.actor ~= pos[1] and sm.cam.ctx.actor[1] == pos[1][1] and sm.cam.ctx.target[3] == pos[5][3],
    "attack ctx copies actor and target positions")
  ok(pos[1][3] == slotPos(1)[3] and pos[5][1] == slotPos(5)[1], "sample leaves positions unchanged")
  ok(Shots.resolve(sm.cam.kind, sm.cam.ctx) == "bigHit", "carried hit resolves to bigHit")

  tl = Timeline.new()
  tl:push("intro", 20)
  tl:push("attack", 20, { actor = 0, target = 9 })
  tl:step()
  ok(tl:sample(pos).cam.kind == "intro", "intro keeps the camera while it overlaps an attack")

  tl = Timeline.new()
  tl:push("summon", 8, { slot = 3 })
  tl:step()
  sm = tl:sample(pos)
  ok(sm.cam.kind == "summon" and sm.cam.ctx.slot[1] == pos[3][1] and sm.cam.ctx.slot ~= pos[3],
    "summon drives the camera with a copy of the slot")

  tl = Timeline.new()
  tl:push("elim", 8, { slot = 7 })
  tl:step()
  sm = tl:sample(pos)
  ok(sm.cam.kind == "elim" and sm.cam.ctx.slot[3] == pos[7][3], "elim drives the camera with the slot")
end

-- screen box of a billboard card (it turns to face the eye about y) of half width hw, 2 tall
local function cardBox(eye, at, fov, slot, hw)
  local p = slotPos(slot)
  local dx, dz = eye[1] - p[1], eye[3] - p[3]
  local l = math.sqrt(dx * dx + dz * dz)
  local px, pz = dz / l, -dx / l
  local x0, y0, x1, y1 = 9, 9, -9, -9
  for _, c in ipairs({ { -1, 0 }, { 1, 0 }, { -1, 2 }, { 1, 2 } }) do
    local x, y, w = project(eye, at, fov, { p[1] + px * hw * c[1], c[2], p[3] + pz * hw * c[1] })
    if w <= 0 then return nil end
    x0, y0, x1, y1 = math.min(x0, x), math.min(y0, y), math.max(x1, x), math.max(y1, y)
  end
  return { x0, y0, x1, y1 }
end

-- the enemy Magi's card clears every enemy card in the default view, even the widest name
-- card ("BlackAgovo", 2.4 wide); it used to stand right behind slot 5
do
  local Card = require("mn.b3d.Card")
  local wide = Card.worldSize("BlackAgovo") / 2
  local eye, at, fov = Shots.default.eye(0, {}), Shots.default.at(0, {}), Shots.default.fov
  local m = cardBox(eye, at, fov, 9, 0.8)
  for slot = 5, 8 do
    local b = cardBox(eye, at, fov, slot, wide)
    local apart = m[3] <= b[1] or b[3] <= m[1] or m[4] <= b[2] or b[4] <= m[2]
    ok(apart, ("default: Magi card [%.2f,%.2f] clear of slot %d card [%.2f,%.2f]"):format(m[1], m[3], slot, b[1], b[3]))
  end
  for slot = 0, 9 do
    local b = cardBox(eye, at, fov, slot, (slot >= 5 and slot <= 8) and wide or 0.8)
    ok(b[1] >= -0.97 and b[3] <= 0.97 and b[2] >= -0.97 and b[4] <= 0.97,
      ("default: slot %d whole card in frame [%.2f,%.2f]x[%.2f,%.2f]"):format(slot, b[1], b[3], b[2], b[4]))
  end
end

-- attack shots keep the whole card of both sides off the frame edge (the attacker used to
-- sit right on it)
for _, name in ipairs({ "attack", "bigHit" }) do
  local shot = Shots[name]
  local worst = 0
  for actor = 0, 9 do for target = 0, 9 do if actor ~= target then
    local ctx = ctxFor(actor, target)
    for _, p in ipairs(PS) do
      local eye, at = shot.eye(p, ctx), shot.at(p, ctx)
      for _, slot in ipairs({ actor, target }) do
        local b = cardBox(eye, at, shot.fovAt and shot.fovAt(p, ctx) or shot.fov, slot, 0.8)
        local e = b and math.max(-b[1], b[3], -b[2], b[4]) or 99
        if e > worst then worst = e end
        ok(e <= 0.92, ("%s %d->%d p=%s: slot %d card inside 0.92 (edge %.3f)"):format(name, actor, target, p, slot, e))
      end
    end
  end end end
  print(("%s: worst card edge %.3f"):format(name, worst))
end

-- attack eyes stay over the floor (the Tony -> Korg shot used to back off past its edge)
do
  local worstZ, worstX = -99, 0
  for _, name in ipairs({ "attack", "bigHit" }) do
    for actor = 0, 9 do for target = 0, 9 do if actor ~= target then
      for _, p in ipairs(PS) do
        local e = Shots[name].eye(p, ctxFor(actor, target))
        worstZ, worstX = math.max(worstZ, e[3]), math.max(worstX, math.abs(e[1]))
      end
    end end end
  end
  ok(worstZ <= 9.0 and worstX <= 6.2, ("attack eyes stay over the floor (z %.2f, |x| %.2f)"):format(worstZ, worstX))
end

-- every shot says what the banner strips do
for _, name in ipairs(NAMES) do
  local b = Shots[name].banners
  ok(b == "rest" or b == "slide", name .. " has a banner mode")
end
ok(Shots.attack.banners == "slide" and Shots.bigHit.banners == "slide" and Shots.default.banners == "rest",
  "banners slide in attacks and rest otherwise, as in 2D")

print(("mn_b3d_shots_test: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
