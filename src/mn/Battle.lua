-- Magi-Nation battle (port), first battle: Tony (+Furok) vs Weebo on map 3.
-- Screen: backdrop + creature pictures captured from ROM tiles (data_battle_capture.json);
-- Tony's sprite, hand cursors, brackets, portraits, attack/elimination animations from PyBoy
-- frame captures (data_battle_scenes.lua via mn.PpuFrame). Rules, numbers and message text:
-- docs/battle-formulas.md (each marked observed / estimated / guessed).
local Font = require("mn.Font")
local Ppu = require("mn.PpuFrame")
local M = {}
M.__index = M

local json_cache
local function capture()
  if json_cache then return json_cache end
  local s = love.filesystem.read("src/mn/data_battle_capture.json")
  local i = 1
  local function ws() i = s:find("[^%s]", i) end
  local val
  function val()
    ws(); local c = s:sub(i, i)
    if c == "{" then local t = {}; i = i + 1; ws()
      if s:sub(i, i) == "}" then i = i + 1; return t end
      while true do ws(); local k = val(); ws(); i = i + 1; t[k] = val(); ws()
        local d = s:sub(i, i); i = i + 1; if d == "}" then return t end end
    elseif c == "[" then local t = {}; i = i + 1; ws()
      if s:sub(i, i) == "]" then i = i + 1; return t end
      while true do t[#t + 1] = val(); ws(); local d = s:sub(i, i); i = i + 1; if d == "]" then return t end end
    elseif c == '"' then local j = s:find('"', i + 1, true); local r = s:sub(i + 1, j - 1); i = j + 1; return r
    else local j = s:find("[,%]}%s]", i); local r = tonumber(s:sub(i, j - 1)); i = j; return r end
  end
  json_cache = val()
  return json_cache
end

-- species: energy/cost observed in PyBoy (battle records, HUD); damage tables observed (see doc)
local SPECIES = {
  [0x58] = { name = "Tony", e = 100 },
  [0x1C] = { name = "Furok", e = 22, cost = 22, pic = "1C" },
  [0x53] = { name = "Weebo", e = 3, pic = "53" },
  [0x4B] = { name = "Twee", e = 2, pic = "4B" },
}
M.SPECIES = SPECIES

-- Fight damage as fitted to the strength/defence sweeps (kept for other creatures)
function M.fightDamage(str, def)
  return math.max(1, math.floor(str / 2) + 1 - math.floor((def + 1) / 32))
end

-- observed outcome tables (PyBoy RNG sweeps, docs/battle-formulas.md)
M.FOCUS = function(r) return math.max(1, math.min(8, r:random(0, 9))) end       -- 1..8, ends doubled
M.FUROK_FIGHT = function(r) return r:random() < 0.44 and 8 or 5 end
M.FUROK_SCRATCH = function(r) return r:random() < 0.40 and 9 or 6 end
M.WEEBO_FIGHT = function(r) local x = r:random(); return x < 0.74 and 2 or (x < 0.86 and 3 or 4) end
M.WEEBO_FIGHT_TONY = function(r) return r:random(2, 3) end
M.WEEBO_HEAL = function(r) return r:random(2, 16) end
M.WEEBO_MISS = 0.10
M.WEEBO_HEALS = 0.5

-- MN_GOD=1: dev-only test mode (off unless the env var is set). The summoned Furok gets
-- 999 energy and every Furok hit eliminates its target, so any fight is one hit; action
-- costs (summon, Scratch, spells via M:spend) are never paid. A GOD fight does not write
-- Tony's energy back to the field. The field and battle screens show a "GOD" tag.
M.GOD = os.getenv("MN_GOD") == "1"
M.GOD_ENERGY = 999

function M.new(ow, setup)
  local b = setmetatable({ ow = ow, setup = setup, t = 0, log = ow.log, imgs = {} }, M)
  local sp, lv = 0x53, 1
  for _, o in ipairs(setup.ops or {}) do if o.op == 0x2E and o.args[1] == 0x09 then sp, lv = o.args[2], o.args[3]; break end end
  local S = SPECIES[sp] or SPECIES[0x53]
  b.enemy = { sp = sp, name = S.name, e = S.e, max = S.e, pic = S.pic }
  b.tony = { name = "Tony", e = tonumber(os.getenv("MN_TONY_START") or "") or ow.tonyEnergy or 100, max = 100 }
  b.ally = nil
  b.auto = os.getenv("MN_BAUTO")
  b.rng = love.math.newRandomGenerator(tonumber(os.getenv("MN_SEED") or "7"))
  b.tonyCur, b.allyCur = 1, 1
  ow.log[#ow.log + 1] = ("battle vs %s (%02X lv %d)"):format(b.enemy.name, sp, lv)
  b:buildImages()
  b.co = coroutine.create(function() return b:script() end)
  return b
end

function M:L(s) if self.log then self.log[#self.log + 1] = ("[t%d] %s"):format(self.t, s) end end

function M:buildImages()
  local cap = capture()
  local Importer = require("mn.MnImporter")
  local hi = love.filesystem.read(Importer.CACHE .. "/battle.bin")
  local lo = love.filesystem.read(Importer.CACHE .. "/battle_lo.bin")
  local rom = { u8 = function(_, o)
    if o >= 0x43 * 0x4000 then return hi:byte(o - 0x43 * 0x4000 + 1) or 0 end
    return lo:byte(o + 1) or 0 end }
  local pal = {}
  for p, ws in ipairs(cap.backdrop.pal) do
    pal[p - 1] = {}
    for c = 0, 3 do local w = ws[c + 1]
      pal[p - 1][c] = { (w % 32) / 31, (math.floor(w / 32) % 32) / 31, (math.floor(w / 1024) % 32) / 31 } end
  end
  local function tile(img, cell, px, py)
    local off, p, xf, yf = cell[1], pal[cell[2]] or pal[0], cell[3] == 1, cell[4] == 1
    for y = 0, 7 do
      local sy = yf and 7 - y or y
      local l, h = rom:u8(off + sy * 2), rom:u8(off + sy * 2 + 1)
      for x = 0, 7 do
        local bit = 7 - x; local sx = xf and 7 - x or x
        local ci = (math.floor(l / 2 ^ bit) % 2) + 2 * (math.floor(h / 2 ^ bit) % 2)
        local c = p[ci]; img:setPixel(px + sx, py + y, c[1], c[2], c[3], 1)
      end
    end
  end
  local bd = love.image.newImageData(160, 144)
  for r, row in ipairs(cap.backdrop.cells) do for c, cell in ipairs(row) do tile(bd, cell, (c - 1) * 8, (r - 1) * 8) end end
  self.bg = love.graphics.newImage(bd); self.bg:setFilter("nearest", "nearest")
  self.pics = {}
  for k, rows in pairs(cap.pics) do
    local im = love.image.newImageData(32, 40)
    for r, row in ipairs(rows) do for c, cell in ipairs(row) do tile(im, cell, (c - 1) * 8, (r - 1) * 8) end end
    self.pics[k] = love.graphics.newImage(im); self.pics[k]:setFilter("nearest", "nearest")
  end
  -- overlays from the captured frames (OAM layers / window cells), all 160x144 transparent
  local function layer(scene, fn)
    local img = love.image.newImageData(160, 144); fn(img, Ppu.scene(scene)[1])
    local im = love.graphics.newImage(img); im:setFilter("nearest", "nearest"); return im
  end
  local isTony = function(o) return o[2] >= 68 and o[2] <= 80 and o[1] >= 78 and o[1] <= 96 end
  self.imgs.tony = layer("idle", function(img, f) Ppu.oam(img, f, isTony) end)
  self.imgs.hand = layer("menu", function(img, f) Ppu.oam(img, f, function(o) return o[1] == 104 and o[2] == 32 end) end)
  self.imgs.sparkle = layer("menu", function(img, f) Ppu.oam(img, f, function(o) return o[1] < 50 end) end)
  self.imgs.target = layer("target", function(img, f) Ppu.oam(img, f, function(o) return o[1] <= 18 end) end)
  self.imgs.brackets = layer("target", function(img, f) Ppu.oam(img, f, function(o) return o[1] >= 48 and o[1] <= 80 and not isTony(o) end) end)
  self.imgs.slot = layer("slot", function(img, f) Ppu.oam(img, f, function(o) return o[1] >= 59 and o[1] <= 67 end) end)
  self.imgs.portraitTony = layer("tonymsg", function(img, f) Ppu.cells(img, f, "1C00", 0, 0, 5, 4, 0, 104) end)
  self.imgs.portraitFurok = layer("furokmenu300", function(img, f) Ppu.cells(img, f, "1C00", 0, 0, 4, 4, 0, 104) end)
end

-- ---------------------------------------------------------------- input
function M:readInput()
  self.inA, self.inB, self.inDir = false, false, nil
  if self.auto then return end
  self.inA = self.ow.input("a") and true or false
  self.inB = self.ow.input("b") and true or false
  local d = self.ow.input("dir")
  if d ~= self.lastDir then self.inDir = d end
  self.lastDir = d
  if self.inA or self.inB or self.inDir then self:L("battle key " .. (self.inA and "A" or self.inB and "B" or self.inDir)) end
end

-- autopilot: press A every 12 frames; menus jump to the wanted entry
function M:autoA() return self.auto and self.t % 12 == 0 end

-- ---------------------------------------------------------------- coroutine helpers
local function wait(n) for _ = 1, n do coroutine.yield() end end

function M:waitA()
  while true do coroutine.yield(); if self.inA or self:autoA() then return end end
end

-- message: typewriter (1 glyph / 2 frames) on window rows 1 and 3 from col 5; text lines are
-- the game's own breaks ("\n", as seen in PyBoy); a third line scrolls row 3 up to row 1.
function M:say(text, portrait)
  self:L("battle msg: " .. text:gsub("\n", " "))
  local lines = {}; for l in (text .. "\n"):gmatch("(.-)\n") do lines[#lines + 1] = l end
  self.msg = { rows = { "", "" }, portrait = portrait }
  for i, l in ipairs(lines) do
    local row = i == 1 and 1 or 2
    if i >= 3 then self.msg.rows = { lines[i - 1], "" }; wait(8) end
    for n = 1, #l do self.msg.rows[row] = l:sub(1, n); wait(2) end
  end
  self:L("battle msg wait"); self:waitA(); self.msg = nil
end

-- vertical menu; returns index (1-based) or nil on B
function M:menu(kind, n, cur, want)
  self.view = kind; self.cur = cur; self:L("battle menu " .. kind)
  while true do
    coroutine.yield()
    if self.auto and want then
      if self.cur ~= want then self.cur = want end
      if self:autoA() then break end
    end
    if self.inDir == "down" then self.cur = self.cur % n + 1 elseif self.inDir == "up" then self.cur = (self.cur - 2) % n + 1 end
    if self.inA then break end
    if self.inB then self.view = nil; return nil end
  end
  self.view = nil; return self.cur
end

-- target / slot pick (single target in this battle): A confirms, B backs out
function M:pick(kind)
  self.view = kind; self:L("battle pick " .. kind)
  while true do coroutine.yield(); if self.inA or self:autoA() then break end; if self.inB then self.view = nil; return false end end
  self.view = nil; return true
end

function M:playScene(name)
  local frames = Ppu.scene(name); self:L("battle anim " .. name)
  self.animCache = self.animCache or {}
  for i, f in ipairs(frames) do
    local key = name .. i
    if not self.animCache[key] then
      local im = love.graphics.newImage(Ppu.render(f)); im:setFilter("nearest", "nearest"); self.animCache[key] = im
    end
    self.anim = self.animCache[key]; coroutine.yield()
  end
  self.anim = nil
end

function M:eliminate(who, dy)
  local frames = Ppu.scene("elim_top"); self:L("battle eliminate " .. who.name)
  self.elimCache = self.elimCache or {}
  for i, f in ipairs(frames) do
    if i == 12 then who.gone = true end -- card is cleared under the sparkle (observed ~frame 12)
    local key = i .. ":" .. dy
    if not self.elimCache[key] then
      local img = love.image.newImageData(160, 144); Ppu.oam(img, f, nil, 0, dy)
      self.elimCache[key] = love.graphics.newImage(img); self.elimCache[key]:setFilter("nearest", "nearest")
    end
    self.elim = self.elimCache[key]; coroutine.yield()
  end
  self.elim = nil
end

function M:fade(n) for i = 1, n do self.white = i / n; coroutine.yield() end end

-- ---------------------------------------------------------------- rules
function M:damage(tgt, n) tgt.e = math.max(0, tgt.e - n) end
-- energy paid for an action (summon, Scratch, later spells): free under MN_GOD
function M:spend(who, n) if not M.GOD then who.e = who.e - n end end

function M:weeboAct(furokAtStart)
  local en, r = self.enemy, self.rng
  if en.e <= 0 then return end
  if r:random() < M.WEEBO_HEALS and en.e >= 3 then
    self:say(("%s\nuses Heal\non itself"):format(en.name))
    en.e = math.min(en.max, en.e - 3 + M.WEEBO_HEAL(r)); return
  end
  local tgt = (furokAtStart and self.ally and self.ally.e > 0) and self.ally or self.tony
  self:say(("%s\nfights\n%s"):format(en.name, tgt.name))
  if r:random() < M.WEEBO_MISS then self:say(("%s\nmissed!"):format(en.name)); return end
  self:playScene(tgt == self.tony and "fight_weebo_tony" or "fight_weebo_furok")
  self:damage(tgt, tgt == self.tony and M.WEEBO_FIGHT_TONY(r) or M.WEEBO_FIGHT(r))
  if tgt == self.ally and tgt.e <= 0 then
    self:eliminate(self.ally, 48); self:say("Furok\nis eliminated."); self.ally = nil
  end
end

function M:allyAct(act)
  local A, en, r = self.ally, self.enemy, self.rng
  if not act or not A or A.e <= 0 or en.e <= 0 then return end
  if act == "Scratch" then
    self:spend(A, 5)
    self:say(("%s\nuses Scratch\non %s"):format(A.name, en.name))
    self:playScene("fight_furok_weebo") -- Scratch reuses the Fight animation (not captured separately)
    self:damage(en, M.GOD and en.e or M.FUROK_SCRATCH(r))
  else
    self:say(("%s\nfights\n%s"):format(A.name, en.name))
    self:playScene("fight_furok_weebo")
    self:damage(en, M.GOD and en.e or M.FUROK_FIGHT(r))
  end
end

function M:refund()
  if self.ally and self.ally.e > 0 then -- surviving creature returns energy + 1 to Tony (observed 22->+23, 10->+11)
    local e = math.min(self.ally.e, self.ally.real or self.ally.e) -- MN_GOD: never more than the real Furok
    self.tony.e = math.min(self.tony.max, self.tony.e + e + 1)
  end
end

function M:finish(result)
  self:fade(20)
  if not M.GOD then self.ow.tonyEnergy = self.tony.e end -- MN_GOD fights leave the field energy as it was
  self:L(("battle result %s tony %d"):format(result, self.tony.e))
  self.result = result
end

function M:script()
  local to = self.tony
  while true do
    -- Tony's command
    local tonyAct
    local furokAtStart = self.ally ~= nil
    while not tonyAct do
      local wantT = (self.auto and not self.ally and to.e >= SPECIES[0x1C].cost) and 1 or 2
      local c = self:menu("tony", 5, self.tonyCur, wantT)
      if c then self.tonyCur = c end
      if c == 1 then
        if not self.ally then
          local F = SPECIES[0x1C]
          if self:menu("summon", 1, 1, 1) and to.e >= F.cost then
            if self:pick("slot") then tonyAct = "Summon" end
          end
        else self:menu("summon", 1, 1, 1) end -- (only creature already out: A does nothing)
      elseif c == 2 then tonyAct = "Focus"
      elseif c == 5 then tonyAct = "Run" end
      -- Spell / Item: "---" entries, nothing happens
    end
    local allyAct
    if self.ally and tonyAct ~= "Run" then
      while not allyAct do
        local c = self:menu("ally", 2, self.allyCur, 1)
        if c then self.allyCur = c
          if c == 2 and self.ally.e < 5 then c = nil end
          if c and self:pick("target") then allyAct = c == 2 and "Scratch" or "Fight" end
        end
      end
    end
    -- resolution: Tony first, then Furok and Weebo in random order
    if tonyAct == "Run" then self:say("Tony escapes."); self:refund(); self:finish("run"); return end
    if tonyAct == "Summon" then
      local F = SPECIES[0x1C]; self:spend(to, F.cost)
      self.ally = { name = "Furok", e = F.e, max = F.e, pic = F.pic, real = F.e }
      if M.GOD then self.ally.e, self.ally.max = M.GOD_ENERGY, M.GOD_ENERGY; self:L("MN_GOD: Furok energy 999, one-hit wins") end
      self:say("Furok\nwas summoned."); self:fade(8); self.white = nil
    elseif tonyAct == "Focus" then
      local g = M.FOCUS(self.rng); to.e = math.min(to.max, to.e + g)
      self:say(("Tony gains\n%d energy\nby focusing."):format(g), "Tony")
    end
    if self.rng:random(2) == 1 then self:allyAct(allyAct); self:weeboAct(furokAtStart)
    else self:weeboAct(furokAtStart); self:allyAct(allyAct) end
    if self.enemy.e <= 0 then
      self:eliminate(self.enemy, 0)
      to.e = math.min(to.max, to.e + 2); self:say("Tony gains 2\nenergy for the\ndefeat.", "Tony")
      self:refund()
      self:say("You got\n001 Animite!"); self:say(("\17%s\nfound!"):format(self.enemy.name)); self:say("Tony wins!")
      self:finish("win"); return
    end
    if to.e <= 0 and not self.ally then self:say("Tony was\ndefeated."); self:finish("loss"); return end
  end
end

function M:update()
  self.t = self.t + 1
  if self.result then return self.result end
  self:readInput()
  local ok, err = coroutine.resume(self.co)
  if not ok then error(err) end
  return self.result
end

-- ---------------------------------------------------------------- drawing
local WIN = { [0] = { 0, 0, 0 }, { 0.4, 0.4, 0.4 }, { 0.75, 0.75, 0.75 }, { 1, 1, 1 } } -- white on black
local function pad(n) return ("%03d"):format(n) end
local ARROW = string.char(0x0C)

function M:draw()
  love.graphics.clear(0, 0, 0); love.graphics.setColor(1, 1, 1)
  if self.anim then love.graphics.draw(self.anim, 0, 0); return self:drawWhite() end
  love.graphics.draw(self.bg, 0, 0)
  local en = self.enemy
  if self.pics[en.pic] and not en.gone then love.graphics.draw(self.pics[en.pic], 40, 0) end
  if self.ally and not self.ally.gone and self.pics["1C"] then love.graphics.draw(self.pics["1C"], 40, 48) end
  love.graphics.draw(self.imgs.tony, 0, 0)
  if self.elim then love.graphics.draw(self.elim, 0, 0) end
  local v = self.view
  if v == "tony" or v == "summon" or v == "slot" then if not self.ally then love.graphics.draw(self.imgs.sparkle, 0, 0) end end
  if self.ally and (v == "ally" or v == "target" or (self.msg and v == nil)) then love.graphics.draw(self.imgs.brackets, 0, 0) end
  if v == "target" then love.graphics.draw(self.imgs.target, 0, 0) end
  if v == "slot" then love.graphics.draw(self.imgs.slot, 0, 0) end
  local box = self.msg or v == "tony" or v == "ally" or v == "summon"
  if box then love.graphics.setColor(0, 0, 0); love.graphics.rectangle("fill", 0, 104, 160, 40); love.graphics.setColor(1, 1, 1) end
  local T = function(s, col, row) Font.drawText(s, col * 8, 104 + row * 8, WIN) end
  if self.msg then
    local m = self.msg
    if m.portrait == "Tony" then love.graphics.draw(self.imgs.portraitTony, 0, 0) end
    T(m.rows[1], 5, 1); T(m.rows[2], 5, 3)
  elseif v == "tony" then
    local to = self.tony
    T("Summon", 5, 0); T(pad(to.e) .. ":" .. pad(to.max), 13, 0)
    T("Focus", 5, 1); T("Spell", 5, 2); T("Item", 5, 3); T("Run", 5, 4)
    for r = 1, 4 do T("---", 15, r) end
    love.graphics.draw(self.imgs.hand, 0, (self.cur - 1) * 8)
  elseif v == "summon" then
    T("Furok", 5, 0); T(pad(SPECIES[0x1C].cost), 17, 0)
    love.graphics.draw(self.imgs.hand, 0, 0)
  elseif v == "ally" then
    local A = self.ally
    love.graphics.draw(self.imgs.portraitFurok, 0, 0)
    T("Fight", 5, 0); T(ARROW, 11, 0); T(pad(A.e) .. ":" .. pad(A.max), 13, 0)
    T("Scratch", 5, 1); T("005", 15, 1); for r = 2, 4 do T("---", 15, r) end
    love.graphics.draw(self.imgs.hand, 0, (self.cur - 1) * 8)
  end
  self:drawWhite()
end

function M:drawWhite()
  if self.white then love.graphics.setColor(1, 1, 1, self.white); love.graphics.rectangle("fill", 0, 0, 160, 144); love.graphics.setColor(1, 1, 1, 1) end
end

return M
