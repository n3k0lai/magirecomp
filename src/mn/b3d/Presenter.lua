-- 3D battle presentation (prototype, off unless MN_BATTLE3D=1). It only draws: mn.Battle keeps
-- running the byte-level engine and its coroutine exactly as in 2D and hands this module the
-- same events with the same frame budgets (see mn.b3d.Timeline), so no rule, RNG draw or frame
-- count changes. Everything it shows is built at runtime from the battle images mn.Battle
-- already made from the player's ROM (backdrop, creature pictures, Tony's sprite); nothing
-- from the ROM is stored. docs/mn-battle-3d.md has the design and the roadmap.
--   MN_BATTLE3D=1          turn it on (classic 2D stays the default)
--   MN_B3D_SIZE=480x432    render size (composited into the 160x144 game canvas)
--   MN_B3D_SHOT=dir        write render frames there as PNG (dev / review only)
--   MN_B3D_EVERY=2         one PNG every N battle frames
local Mat4 = require("mn.b3d.Mat4")
local Timeline = require("mn.b3d.Timeline")
local Font = require("mn.Font")
local Card = require("mn.b3d.Card")
local Ppu = require("mn.PpuFrame")

local P = {}
P.__index = P

local SHADER = [[
uniform mat4 proj;
uniform mat4 view;
uniform mat4 model;
uniform float flash;
uniform float shade;
#ifdef VERTEX
vec4 position(mat4 tp, vec4 v) {
  vec4 p = proj * view * model * v;
  p.y = -p.y; // LÖVE canvases are stored upside down
  return p;
}
#endif
#ifdef PIXEL
vec4 effect(vec4 col, Image tex, vec2 uv, vec2 sc) {
  vec4 c = Texel(tex, uv) * col;
  if (c.a < 0.5) discard;
  c.rgb = mix(c.rgb * shade, vec3(1.0), flash);
  return c;
}
#endif
]]

local FMT = { { "VertexPosition", "float", 3 }, { "VertexTexCoord", "float", 2 } }

local function quad(x0, y0, x1, y1, u0, v0, u1, v1, z)
  z = z or 0
  return love.graphics.newMesh(FMT, {
    { x0, y0, z, u0, v1 }, { x1, y0, z, u1, v1 }, { x1, y1, z, u1, v0 },
    { x0, y0, z, u0, v1 }, { x1, y1, z, u1, v0 }, { x0, y1, z, u0, v0 } }, "triangles", "static")
end

-- ground plane in XZ (y = 0), uv repeats `rep` times
local function ground(half, rep)
  return love.graphics.newMesh(FMT, {
    { -half, 0, -half, 0, 0 }, { half, 0, -half, rep, 0 }, { half, 0, half, rep, rep },
    { -half, 0, -half, 0, 0 }, { half, 0, half, rep, rep }, { -half, 0, half, 0, rep } }, "triangles", "static")
end

-- arena layout: player creatures 1-4 near the camera, enemies 5-8 across, the two Magi behind
local function slotPos(slot)
  if slot >= 1 and slot <= 4 then return { (slot - 2.5) * 1.5, 0, 1.6 } end
  if slot >= 5 and slot <= 8 then return { (slot - 6.5) * 1.5, 0, -1.6 } end
  if slot == 0 then return { 2.4, 0, 3.4 } end
  return { -2.4, 0, -3.4 }
end
P.slotPos = slotPos

local function nearest(im) im:setFilter("nearest", "nearest"); return im end

-- crop the opaque part of a 160x144 ImageData layer into its own image
local function crop(data)
  local x0, y0, x1, y1 = 999, 999, -1, -1
  for y = 0, data:getHeight() - 1 do for x = 0, data:getWidth() - 1 do
    local _, _, _, a = data:getPixel(x, y)
    if a > 0 then x0, y0, x1, y1 = math.min(x0, x), math.min(y0, y), math.max(x1, x), math.max(y1, y) end
  end end
  if x1 < 0 then return nil end
  local out = love.image.newImageData(x1 - x0 + 1, y1 - y0 + 1)
  out:paste(data, 0, 0, x0, y0, x1 - x0 + 1, y1 - y0 + 1)
  return nearest(love.graphics.newImage(out))
end

function P.new(battle, opts)
  opts = opts or {}
  local self = setmetatable({ b = battle, tl = Timeline.new(), tex = {}, frame = 0, shots = 0 }, P)
  local w, h = (os.getenv("MN_B3D_SIZE") or "480x432"):match("(%d+)x(%d+)")
  self.w, self.h = tonumber(w) or 480, tonumber(h) or 432
  self.canvas = love.graphics.newCanvas(self.w, self.h)
  self.shader = love.graphics.newShader(SHADER)
  self.shotDir = opts.shotDir or os.getenv("MN_B3D_SHOT")
  self.every = tonumber(os.getenv("MN_B3D_EVERY") or "") or 2
  -- backdrop: the battle background the 2D screen draws, wrapped onto the floor and the far wall
  self.bg = battle.bg
  self.bgRep = love.graphics.newImage(battle.bgData)
  self.bgRep:setWrap("repeat", "repeat"); nearest(self.bgRep)
  self.floor = ground(7, 2); self.floor:setTexture(self.bgRep)
  -- the far wall shows the upper (sky / scenery) half of the backdrop
  self.wall = quad(-9, 0, 9, 7, 0, 0, 1, 0.55); self.wall:setTexture(self.bg)
  self.card = quad(-0.5, 0, 0.5, 1, 0, 0, 1, 1)
  -- blob shadow and hit spark, drawn into small images at start-up
  local sd = love.image.newImageData(16, 8)
  sd:mapPixel(function(x, y) local dx, dy = (x - 7.5) / 8, (y - 3.5) / 4; return 0, 0, 0, (dx * dx + dy * dy) < 1 and 1 or 0 end)
  self.shadowTex = nearest(love.graphics.newImage(sd))
  self.shadow = love.graphics.newMesh(FMT, { { -0.6, 0.01, -0.3, 0, 0 }, { 0.6, 0.01, -0.3, 1, 0 }, { 0.6, 0.01, 0.3, 1, 1 },
    { -0.6, 0.01, -0.3, 0, 0 }, { 0.6, 0.01, 0.3, 1, 1 }, { -0.6, 0.01, 0.3, 0, 1 } }, "triangles", "static")
  self.shadow:setTexture(self.shadowTex)
  local sp = love.image.newImageData(4, 4); sp:mapPixel(function(x, y) return 1, 1, 0.7, (x == 1 or x == 2 or y == 1 or y == 2) and 1 or 0 end)
  self.sparkTex = nearest(love.graphics.newImage(sp))
  -- Tony from the battle's own idle frame
  local isTony = function(o) return o[2] >= 68 and o[2] <= 80 and o[1] >= 78 and o[1] <= 96 end
  local ok, td = pcall(function() local d = love.image.newImageData(160, 144); Ppu.oam(d, Ppu.scene("idle")[1], isTony); return d end)
  self.tony = ok and crop(td) or nil
  self.tl:push("intro", opts.introFrames or 96)
  return self
end

-- texture for a slot's creature: its battle picture when the run has one, else a name card
function P:texFor(slot, v)
  local pics, PICS = self.b.pics or {}, self.b.PICS or {}
  if slot == 0 and self.tony then return self.tony, self.tony:getWidth() / 16, self.tony:getHeight() / 16 end
  local key = PICS[v.species]
  if key and pics[key] then return pics[key], 1.6, 2.0 end
  local name = v.name or "?"
  local t = self.tex[name]
  if not t then
    t = Card.draw(love.graphics, Font, love.graphics.newCanvas(Card.W, Card.H), name)
    nearest(t); self.tex[name] = t
  end
  return t, 1.6, 2.0
end

-- ---------------------------------------------------------------- events (from mn.Battle:play)
function P:attack(actor, target, frames, script)
  if actor and target then self.tl:push("attack", frames, { actor = actor, target = target, script = script }) end
  self:log(("b3d attack %s -> %s (%d frames, anim %s)"):format(tostring(actor), tostring(target), frames, script and ("4C:%04X"):format(script) or "-"))
end
function P:summon(slot, frames) self.tl:push("summon", frames, { slot = slot }) end
function P:eliminate(slot, frames) self.tl:push("elim", frames, { slot = slot }); self.gone = self.gone or {}; self.gone[slot] = self.tl.f + frames end
function P:log(s) if self.b.L then self.b:L(s) end end

-- one battle frame
function P:step()
  self.tl:step(); self.frame = self.frame + 1
  -- sticky: the test harness may not draw every frame, so the next render takes the shot
  if self.shotDir and self.frame % self.every == 0 and self.shots < 900 then self.wantShot = true end
end

-- ---------------------------------------------------------------- camera
local DEFAULT = { eye = { 0.6, 2.6, 7.4 }, at = { 0, 0.9, -0.6 } }
function P:camera(sample)
  local c = sample.cam
  if c and c.kind == "intro" then
    -- orbit in from behind the enemy Magi to the default view behind Tony's side
    local p = Timeline.smooth(self.tl:phase(c))
    local ang = (1 - p) * math.pi * 0.85
    local r, y = 7.4 + (1 - p) * 2.5, 2.6 + (1 - p) * 2.4
    return { math.sin(ang) * r + 0.6 * p, y, math.cos(ang) * r }, DEFAULT.at
  elseif c and c.kind == "attack" then
    -- cut to a low side view of the exchange, dollying slightly while it plays
    local a, b = slotPos(c.actor), slotPos(c.target)
    local mid = { (a[1] + b[1]) / 2, 0.9, (a[3] + b[3]) / 2 }
    local p = self.tl:phase(c)
    local side = (b[3] - a[3]) >= 0 and -1 or 1
    return { mid[1] + side * (5.2 - p * 0.8), 1.6 + p * 0.3, mid[3] + 1.2 }, mid
  end
  return DEFAULT.eye, DEFAULT.at
end

-- ---------------------------------------------------------------- drawing
function P:render()
  local s = self.tl:sample(setmetatable({}, { __index = function(_, k) return slotPos(k) end }))
  local eye, at = self:camera(s)
  self.eye = eye
  local g = love.graphics
  local prev = g.getCanvas()
  g.push("all")
  g.setCanvas({ self.canvas, depth = true })
  g.clear(0.55, 0.7, 0.9, 1, true, true)
  g.setDepthMode("lequal", true)
  g.setShader(self.shader)
  self.shader:send("proj", Mat4.perspective(math.rad(50), self.w / self.h, 0.1, 60))
  self.shader:send("view", Mat4.lookAt(eye, at))
  self.shader:send("flash", 0); self.shader:send("shade", 1)
  g.setColor(1, 1, 1, 1)
  self.shader:send("model", Mat4.identity()); g.draw(self.floor)
  self.shader:send("shade", 0.85)
  self.shader:send("model", Mat4.translate(0, 0, -6.5)); g.draw(self.wall)
  -- combatants (cylindrical billboards facing the camera)
  local vis = self.b.vis or {}
  for slot = 0, 9 do
    local v = vis[slot]
    local hidden = (slot == 9 and (not v or not v.name or v.name == "" or v.species == 0x6C)) or (slot >= 1 and slot <= 8 and not v)
    if self.gone and self.gone[slot] and self.tl.f >= self.gone[slot] then hidden = true end
    if v and not hidden then
      local tex, w, h = self:texFor(slot, v)
      local base = slotPos(slot)
      local q = s.pose[slot] or { 0, 0, 0, false, 1 }
      local x, y, z = base[1] + q[1], base[2] + q[2], base[3] + q[3]
      local yaw = math.atan2(eye[1] - x, eye[3] - z)
      self.shader:send("flash", 0); self.shader:send("shade", 1)
      self.shader:send("model", Mat4.mul(Mat4.translate(x, 0, z), Mat4.scale(q[5] * 1.1, 1, q[5] * 1.1))); g.draw(self.shadow)
      self.card:setTexture(tex)
      self.shader:send("flash", q[4] and 0.8 or 0)
      self.shader:send("model", Mat4.mul(Mat4.translate(x, y, z), Mat4.mul(Mat4.rotY(yaw), Mat4.scale(w * q[5], h * q[5], 1))))
      g.draw(self.card)
    end
  end
  -- hit sparks around the target while an attack connects
  for _, c in ipairs(self.tl.clips) do
    if c.kind == "attack" and c.hit then
      local b = slotPos(c.target)
      self.card:setTexture(self.sparkTex); self.shader:send("flash", 0)
      local n = self.tl.f - c.start
      for i = 1, 6 do
        local ang = i * 1.047 + n * 0.25
        local r = 0.3 + (n % 12) * 0.06
        local x, y, z = b[1] + math.cos(ang) * r, 1.0 + math.sin(ang) * r, b[3] + 0.3
        local yaw = math.atan2(eye[1] - x, eye[3] - z)
        self.shader:send("model", Mat4.mul(Mat4.translate(x, y, z), Mat4.mul(Mat4.rotY(yaw), Mat4.scale(0.18, 0.18, 1))))
        g.draw(self.card)
      end
    end
  end
  g.setShader(); g.setDepthMode()
  g.pop()
  g.setCanvas(prev)
  if self.wantShot then
    self.wantShot = false; self.shots = self.shots + 1
    local f = io.open(("%s/b3d_%04d.png"):format(self.shotDir, self.frame), "wb")
    if f then f:write(self.canvas:newImageData():encode("png"):getString()); f:close()
    elseif self.shots == 1 then print("[b3d] cannot write shots to " .. tostring(self.shotDir)) end
  end
end

-- draw into the current (160x144) target
function P:draw(x, y, w, h)
  self:render()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canvas, x or 0, y or 0, 0, (w or 160) / self.w, (h or 144) / self.h)
end

return P
