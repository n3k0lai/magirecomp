-- 3D battle presentation: matrix math and the event timeline (no LÖVE, no ROM).
--   luajit tests/engine/mn_b3d_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
local Mat4 = require("mn.b3d.Mat4")
local Timeline = require("mn.b3d.Timeline")

local failures, checks = 0, 0
local function ok(cond, what) checks = checks + 1; if not cond then failures = failures + 1; print("FAIL " .. what) end end
local function near(a, b) return math.abs(a - b) < 1e-6 end

-- lookAt puts the target straight ahead (-z) of the eye
do
  local v = Mat4.lookAt({ 0, 2, 5 }, { 0, 2, 0 })
  local p = Mat4.apply(v, { 0, 2, 0 })
  ok(near(p[1], 0) and near(p[2], 0) and near(p[3], -5), "lookAt: target on -z at distance 5")
  local m = Mat4.mul(Mat4.translate(1, 2, 3), Mat4.identity())
  local q = Mat4.apply(m, { 0, 0, 0 })
  ok(near(q[1], 1) and near(q[2], 2) and near(q[3], 3), "translate")
  local pr = Mat4.perspective(math.rad(90), 1, 1, 10)
  local c = Mat4.apply(pr, { 0, 0, -1 })
  ok(near(c[3] / c[4], -1), "perspective: near plane maps to -1")
  local r = Mat4.apply(Mat4.rotY(math.pi / 2), { 0, 0, 1 })
  ok(near(r[1], 1) and near(r[3], 0), "rotY turns +z to +x")
end

-- clips last exactly their frame budget; an attack moves the actor and flashes the target
do
  local tl = Timeline.new()
  local pos = { [1] = { 0, 0, 1.6 }, [5] = { 0, 0, -1.6 } }
  tl:push("attack", 20, { actor = 1, target = 5 })
  local moved, flashed = false, false
  for _ = 1, 19 do
    tl:step()
    local s = tl:sample(pos)
    if s.pose[1] and s.pose[1][3] < -0.1 then moved = true end
    if s.pose[5] and s.pose[5][4] then flashed = true end
    ok(s.cam ~= nil, "attack drives the camera while it plays")
  end
  ok(moved, "attack: actor lunges toward the target")
  ok(flashed, "attack: target flashes")
  tl:step()
  ok(#tl.clips == 0, "attack: clip ends after its 20 frames")
  ok(tl:sample(pos).cam == nil, "camera returns to default")
end

-- the timeline never touches the battle state it is given
do
  local tl = Timeline.new()
  local pos = { [0] = { 1, 0, 3 }, [5] = { 0, 0, -1 } }
  tl:push("attack", 8, { actor = 0, target = 5 }); tl:push("summon", 8, { slot = 5 }); tl:push("elim", 8, { slot = 5 })
  for _ = 1, 8 do tl:step(); tl:sample(pos) end
  ok(pos[0][1] == 1 and pos[0][3] == 3 and pos[5][3] == -1, "sample leaves positions unchanged")
end

-- name cards are drawn with the 3D shader and depth test switched off, onto their own canvas,
-- and the caller's canvas is restored (they used to come out blank inside render())
do
  local Card = require("mn.b3d.Card")
  local log, state = {}, { shader = "3d", depth = "lequal", canvas = "scene" }
  local stack = {}
  local g = {
    getCanvas = function() return state.canvas end,
    push = function() stack[#stack + 1] = { shader = state.shader, depth = state.depth, canvas = state.canvas } end,
    pop = function() local t = table.remove(stack); state.shader, state.depth, state.canvas = t.shader, t.depth, t.canvas end,
    setShader = function(s) state.shader = s end,
    setDepthMode = function(m) state.depth = m end,
    setCanvas = function(c) state.canvas = c end,
    origin = function() end, setBlendMode = function() end, setColor = function() end,
    clear = function() log[#log + 1] = { "clear", state.canvas } end,
    rectangle = function() log[#log + 1] = { "rect", state.canvas, state.shader, state.depth } end,
  }
  local font = { drawText = function(str) log[#log + 1] = { "text:" .. str, state.canvas, state.shader, state.depth } end }
  local cv = Card.draw(g, font, "card", "Furok")
  ok(cv == "card", "card: returns its canvas")
  local texts = {}
  for _, e in ipairs(log) do
    if e[1] ~= "clear" then ok(e[2] == "card" and e[3] == nil and e[4] == nil, "card: " .. e[1] .. " drawn on the card with no 3D shader/depth") end
    if e[1]:sub(1, 5) == "text:" then texts[#texts + 1] = e[1]:sub(6) end
  end
  ok(texts[1] == "Furo" and texts[2] == "k", "card: name split 4 letters per row")
  ok(state.canvas == "scene" and state.shader == "3d" and state.depth == "lequal", "card: caller's canvas and 3D state restored")
end

print(("mn_b3d_test: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
