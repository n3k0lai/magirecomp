-- Magi-Nation battle (port). Rules come from mn.battle.Engine, a byte-level port of
-- the game's bank-2/5/7 battle code driven by data extracted from the user's ROM at
-- runtime (mn.battle.Data; nothing from the ROM is committed). PyBoy traces replay
-- through that engine byte for byte (tools/mn_battle/replay.lua).
-- Screen: backdrop, creature pictures, Tony's sprite, hand cursors, portraits and the
-- attack/elimination animations come from frames of the game's own battle code run on the
-- player's ROM (mn.fx.Gen, cached privately; drawn via mn.PpuFrame). Creatures with no
-- picture in that run are drawn as a name card.
local Font = require("mn.Font")
local Ppu = require("mn.PpuFrame")
local Engine = require("mn.battle.Engine")
local Data = require("mn.battle.Data")
local Rng = require("mn.battle.Rng")
local M = {}
M.__index = M

-- MN_GOD=1: dev-only test mode (off unless the env var is set). Tony and his creatures are
-- topped up to 999 energy before every round and enemy creatures drop to 1, so any hit
-- eliminates; the rules themselves are untouched. A GOD fight does not write Tony's
-- energy back to the field. The field and battle screens show a "GOD" tag.
M.GOD = os.getenv("MN_GOD") == "1"
M.GOD_ENERGY = 999

-- battle data is extracted once per run from the imported ROM copy in the save directory
local dataCache
function M.data()
  if dataCache then return dataCache end
  local Importer = require("mn.MnImporter")
  local bytes = love.filesystem.read(Importer.CACHE .. "/rom.bin")
  assert(bytes, "battle: ROM not imported")
  dataCache = Data.extract(require("mn.MnRom").new(bytes))
  return dataCache
end

-- card positions: player creatures 1-4 on the lower row, enemy creatures 5-8 above
local function cardXY(slot)
  if slot >= 1 and slot <= 4 then return (slot - 1) * 40, 48 end
  if slot >= 5 and slot <= 8 then return (slot - 5) * 40, 0 end
  if slot == 0 then return 120, 72 end
  return 120, 8
end
M.cardXY = cardXY

-- the creatures Tony owns. The port has no SRAM creature list yet, so the starting
-- Furok is generated once with the game's own template routine (fillFromEntry; the
-- in-game summon cost 023 matches) and kept on the field state between battles.
function M.party(ow, data)
  if ow.mnParty then return ow.mnParty end
  local tmp = Engine.new(data, { magi = 0x6C }, Rng.seeded(1))
  Engine.fillFromEntry(tmp, 0x1C, 1, 23)
  local t = {}
  for k = 0, Engine.SAVED_LEN - 1 do t[k] = Engine.rd(tmp, 0xD112 + k) end
  t[5], t[6] = t[7], t[8] -- saved energy = max
  ow.mnParty = { { saved = t } }
  return ow.mnParty
end

-- op $25 / $2E arguments -> engine setup
function M.setupFrom(ow, setup, data)
  local magi = setup.args and setup.args[2] or 0x6C
  -- the battle script's engine ops in script order: $AA/$AB battle-WRAM stores
  -- (Korg's duel sets his starting energy this way) and $2E summons
  local script, summoned = {}, false
  for _, o in ipairs(setup.ops or {}) do
    local a = o.args
    if o.op == 0x2E then
      script[#script + 1] = { op = 0x2E, slot = a[1], species = a[2], spends = a[3] or 1, energy = a[4] or 3, delay = a[5] or 1 }
      summoned = true
    elseif o.op == 0xAA then
      script[#script + 1] = { op = 0xAA, addr = a[1] + a[2] * 256, bank = a[3], value = a[4] }
    elseif o.op == 0xAB then
      script[#script + 1] = { op = 0xAB, addr = a[1] + a[2] * 256, bank = a[3], lo = a[4], hi = a[5] }
    end
  end
  if not summoned then script[#script + 1] = { op = 0x2E, slot = 9, species = 0x53, spends = 1, energy = 3, delay = 1 } end
  local energy = tonumber(os.getenv("MN_TONY_START") or "") or ow.tonyEnergy or 100
  local spells, items = {}, {}
  local vm = ow.vm
  if vm and vm.rd8 then
    for id = 1, 19 do if vm:rd8(0xA5A5 + id) ~= 0 then spells[#spells + 1] = 0x6FF5 + id * 0x22 end end
    for id = 1, 27 do
      local n = vm:rd8(0xA3A7 + id)
      if n > 0 then items[#items + 1] = { ptr = 0x5DFF + id * 0x22, count = n, id = id } end
    end
  end
  return { magi = magi, arg3 = setup.args and setup.args[3], tony = Engine.tonySaved({ energy = math.min(energy, 999), max = 100 }),
    party = M.party(ow, data), script = script, spells = spells, items = items }
end

function M.new(ow, setup)
  local b = setmetatable({ ow = ow, setup = setup, t = 0, log = ow.log, imgs = {}, vis = {} }, M)
  b.data = M.data()
  b.auto = os.getenv("MN_BAUTO")
  local seed = tonumber(os.getenv("MN_SEED") or "") or os.time()
  b.state = Engine.new(b.data, M.setupFrom(ow, setup, b.data), Rng.seeded(seed))
  b.autoSide = require("mn.battle.Sides").sweep(seed)
  b.tonyCur = 1
  for slot = 0, 9 do b:refreshVis(slot) end
  b:L(("battle vs magi %02X, seed %d"):format(Engine.rd(b.state, 0xD338), seed))
  b:buildImages()
  b.co = coroutine.create(function() return b:script() end)
  return b
end

function M:refreshVis(slot)
  local i = Engine.slotInfo(self.state, slot)
  if slot >= 1 and slot <= 8 then
    self.vis[slot] = (i.present and not i.pending) and { species = i.species, name = i.name } or nil
  else
    self.vis[slot] = { species = i.species, name = i.name }
  end
end

function M:L(s) if self.log then self.log[#self.log + 1] = ("[t%d] %s"):format(self.t, s) end end

function M:buildImages()
  local function bgmap(f) return (math.floor(f.l / 8) % 2 == 1) and "1C00" or "1800" end
  local bd = love.image.newImageData(160, 144)
  local bf = Ppu.scene("backdrop")[1]
  Ppu.cells(bd, bf, bgmap(bf), 0, 0, 20, 18, 0, 0)
  self.bg = love.graphics.newImage(bd); self.bg:setFilter("nearest", "nearest")
  self.pics = {}
  for k, p in pairs(Ppu.data().pics) do
    local im = love.image.newImageData(32, 40)
    Ppu.cells(im, p.frame, bgmap(p.frame), p.col, p.row, 4, 5, 0, 0)
    self.pics[k] = love.graphics.newImage(im); self.pics[k]:setFilter("nearest", "nearest")
  end
  -- overlays from the generated frames (OAM layers / window cells), all 160x144 transparent
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
  -- the slot marker bobs; it is drawn with its top at line 59 whatever the frame's phase
  self.imgs.slot = layer("slot", function(img, f)
    local mark = function(o) return o[1] >= 48 and o[1] <= 80 and o[2] >= 40 and o[2] <= 48 and not isTony(o) end
    local top = 999
    for _, o in ipairs(f.oam) do if mark(o) and o[1] < top then top = o[1] end end
    Ppu.oam(img, f, mark, 0, 59 - top)
  end)
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


-- ---------------------------------------------------------------- choosing
local function pad(n) return ("%03d"):format(math.min(999, n)) end

-- target pick: left/right/up/down cycle through the legal slots
function M:pickTarget(c)
  if c.code or not c.targets or #c.targets <= 1 then return c.targets and c.targets[1] end
  -- the cursor starts on the enemy side, as in the game
  local list = {}
  for _, t in ipairs(c.targets) do if t >= 5 then list[#list + 1] = t end end
  for _, t in ipairs(c.targets) do if t < 5 then list[#list + 1] = t end end
  c = { targets = list }
  local i = 1
  self.view = "target"; self.targetSlot = c.targets[i]
  while true do
    coroutine.yield()
    if self.auto then if self:autoA() then break end
    else
      if self.inDir == "right" or self.inDir == "down" then i = i % #c.targets + 1
      elseif self.inDir == "left" or self.inDir == "up" then i = (i - 2) % #c.targets + 1 end
      self.targetSlot = c.targets[i]
      if self.inA then break end
      if self.inB then self.view = nil; return false end
    end
  end
  self.view = nil
  return c.targets[i]
end

-- a list of legal commands (summon / spell / item lists)
function M:listMenu(kind, list, label)
  if #list == 0 then return nil end
  self.list = { kind = kind, rows = {} }
  for i, c in ipairs(list) do self.list.rows[i] = label(c) end
  local r = self:menu("list", #list, 1, 1)
  self.list = nil
  return r and list[r]
end

-- Tony: Summon / Focus / Spell / Item / Run, as the game's menu
function M:chooseTony(legal)
  local by = { summon = {}, focus = {}, spell = {}, item = {}, run = {} }
  for _, c in ipairs(legal) do if by[c.kind] then table.insert(by[c.kind], c) end end
  self.tonyRows = by
  local d = self.data
  while true do
    local want = self.auto and (#by.summon > 0 and 1 or 2) or nil
    local r = self:menu("tony", 5, self.tonyCur, want)
    if r then self.tonyCur = r end
    local c
    if r == 1 then c = self:listMenu("summon", by.summon, function(x) return { d.names[x.species] or "?", pad(x.cost) } end)
    elseif r == 2 then c = by.focus[1]
    elseif r == 3 then c = self:listMenu("spell", by.spell, function(x) return { d.groups[x.group].name, pad(x.cost or 0) } end)
    elseif r == 4 then c = self:listMenu("item", by.item, function(x) return { d.groups[x.group].name, "" } end)
    elseif r == 5 then c = by.run[1] end
    if c then
      local t = self:pickTarget(c)
      if t ~= false then return c, t end
    end
  end
end

-- a creature: Fight and its unlocked moves
function M:chooseCreature(slot, legal)
  local info = Engine.slotInfo(self.state, slot)
  local rows = { { name = "Fight", cost = nil, c = nil } }
  local rec = 0xD147 + slot * 0x37
  for k = 1, 4 do
    local p = Engine.rp(self.state, rec + 0x18 + 2 * (k - 1))
    local mv = self.data.moves[p]
    rows[k + 1] = { name = mv and Engine.rd(self.state, rec + 0x20 + k - 1) == 0xFF and p >= 0x5F1E and mv.name or nil, cost = mv and mv.cost }
  end
  for _, c in ipairs(legal) do rows[(c.k or 0) + 1].c = c end
  self.creatureRows, self.creatureInfo = rows, info
  while true do
    local r = self:menu("creature", 5, 1, 1)
    local c = r and rows[r].c
    if c then
      local t = self:pickTarget(c)
      if t ~= false then return c, t end
    end
  end
end

-- ---------------------------------------------------------------- playing a round
local SCENES = { ["1C:53"] = "fight_furok_weebo", ["53:58"] = "fight_weebo_tony", ["53:1C"] = "fight_weebo_furok" }

function M:play(events)
  local lastAct
  for _, ev in ipairs(events) do
    if ev.t == "msg" then
      self:say(ev.text, ev.actor == Engine.TONY_ID and "Tony" or nil)
    elseif ev.t == "act" then
      lastAct = ev
    elseif ev.t == "damage" then
      local key = lastAct and ("%02X:%02X"):format(lastAct.species, ev.species or 0)
      if key and SCENES[key] then self:playScene(SCENES[key])
      else self.flash = ev.slot; for _ = 1, 16 do coroutine.yield() end; self.flash = nil end
    elseif ev.t == "summon" and not ev.pending then
      self.vis[ev.slot] = { species = ev.species, name = self.data.names[ev.species] }
      self:fade(8); self.white = nil
    elseif ev.t == "appear" then
      self.vis[ev.slot] = { species = ev.species, name = self.data.names[ev.species] }
    elseif ev.t == "eliminated" then
      local v = self.vis[ev.slot]
      if v and ev.slot >= 1 and ev.slot <= 8 then
        local _, y = cardXY(ev.slot)
        self:eliminate(v, y)
        self.vis[ev.slot] = nil
      end
    elseif ev.t == "unimplemented" then
      self:L("battle unimplemented: " .. tostring(ev.what))
    end
  end
end

function M:god()
  if not M.GOD then return end
  local s = self.state
  Engine.ww(s, 0xD147 + 7, M.GOD_ENERGY)
  for slot = 1, 8 do
    if Engine.rd(s, 0xD091 + slot) ~= 0 then
      Engine.ww(s, 0xD147 + slot * 0x37 + 7, slot <= 4 and M.GOD_ENERGY or 1)
    end
  end
end

function M:script()
  local s = self.state
  while not Engine.over(s) do
    self:god()
    for _, slot in ipairs(Engine.pending(s)) do
      local legal = Engine.legal(s, slot)
      local c, t
      if self.auto then
        local i, tt = self.autoSide:choose({ state = s }, slot, legal)
        c, t = legal[i], tt
        for _ = 1, 12 do coroutine.yield() end
      elseif slot == 0 then c, t = self:chooseTony(legal)
      else c, t = self:chooseCreature(slot, legal) end
      Engine.choose(s, slot, c, t)
      self:L(("battle choose slot %d %s %s"):format(slot, c.kind, tostring(t)))
    end
    self:play(Engine.round(s))
  end
  self:finish(s.result == "escape" and "run" or s.result)
end

function M:finish(result)
  self:fade(20)
  local s = self.state
  if not M.GOD then
    self.ow.tonyEnergy = math.max(1, s.tonyEnergy or Engine.rw(s, 0xD14E))
    local vm = self.ow.vm
    if vm and vm.wr8 then for _, it in ipairs(s.items) do if it.id then vm:wr8(0xA3A7 + it.id, it.count) end end end
  end
  self:L(("battle result %s tony %d"):format(tostring(result), Engine.rw(s, 0xD14E)))
  self.result = result
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
local ARROW = string.char(0x0C)
local PICS = { [0x1C] = "1C", [0x53] = "53", [0x4B] = "4B" }

function M:drawCard(slot, v)
  local x, y = cardXY(slot)
  if self.flash == slot and self.t % 4 < 2 then return end
  local key = PICS[v.species]
  if key and self.pics[key] then love.graphics.draw(self.pics[key], x + 0, y); return end
  love.graphics.setColor(0.1, 0.1, 0.1); love.graphics.rectangle("fill", x, y, 32, 40)
  love.graphics.setColor(1, 1, 1); love.graphics.rectangle("line", x + 0.5, y + 0.5, 31, 39)
  local n = v.name or "?"
  Font.drawText(n:sub(1, 4), x, y + 8, WIN); Font.drawText(n:sub(5, 8), x, y + 16, WIN)
end

-- the captured menu hand sits at (32, 104) in its layer
function M:hand(x, y) love.graphics.draw(self.imgs.hand, x - 32, y - 104) end

function M:draw()
  love.graphics.clear(0, 0, 0); love.graphics.setColor(1, 1, 1)
  if self.anim then love.graphics.draw(self.anim, 0, 0); return self:drawWhite() end
  love.graphics.draw(self.bg, 0, 0)
  for slot = 1, 8 do local v = self.vis[slot]; if v then self:drawCard(slot, v) end end
  local mg = self.vis[9]
  if mg and mg.species ~= 0x6C and mg.name and mg.name ~= "" then Font.drawText(mg.name:sub(1, 5), 120, 8, WIN) end
  love.graphics.draw(self.imgs.tony, 0, 0)
  if self.elim then love.graphics.draw(self.elim, 0, 0) end
  local v = self.view
  if v == "target" and self.targetSlot then local x, y = cardXY(self.targetSlot); self:hand(x + 4, y + 16) end
  local box = self.msg or v == "tony" or v == "creature" or v == "list"
  if box then love.graphics.setColor(0, 0, 0); love.graphics.rectangle("fill", 0, 104, 160, 40); love.graphics.setColor(1, 1, 1) end
  local T = function(s, col, row) Font.drawText(s, col * 8, 104 + row * 8, WIN) end
  if self.msg then
    local m = self.msg
    if m.portrait == "Tony" then love.graphics.draw(self.imgs.portraitTony, 0, 0) end
    T(m.rows[1], 5, 1); T(m.rows[2], 5, 3)
  elseif v == "tony" then
    local to = Engine.slotInfo(self.state, 0)
    local R = self.tonyRows or {}
    T("Summon", 5, 0); T(pad(to.energy) .. ":" .. pad(to.max), 13, 0)
    T("Focus", 5, 1); T("Spell", 5, 2); T("Item", 5, 3); T("Run", 5, 4)
    T(#(R.spell or {}) > 0 and "" or "---", 15, 2); T(#(R.item or {}) > 0 and "" or "---", 15, 3)
    T("---", 15, 1); T("---", 15, 4)
    love.graphics.draw(self.imgs.hand, 0, (self.cur - 1) * 8)
  elseif v == "list" then
    for i, r in ipairs(self.list.rows) do if i <= 5 then T(r[1], 5, i - 1); T(r[2], 17, i - 1) end end
    love.graphics.draw(self.imgs.hand, 0, (self.cur - 1) * 8)
  elseif v == "creature" then
    local info = self.creatureInfo
    if info.species == 0x1C then love.graphics.draw(self.imgs.portraitFurok, 0, 0) end
    T("Fight", 5, 0); T(ARROW, 11, 0); T(pad(info.energy) .. ":" .. pad(info.max), 13, 0)
    for k = 2, 5 do local r = self.creatureRows[k]
      if r.name then T(r.name, 5, k - 1); T(pad(r.cost or 0), 15, k - 1) else T("---", 15, k - 1) end
    end
    love.graphics.draw(self.imgs.hand, 0, (self.cur - 1) * 8)
  end
  self:drawWhite()
end

function M:drawWhite()
  if self.white then love.graphics.setColor(1, 1, 1, self.white); love.graphics.rectangle("fill", 0, 0, 160, 144); love.graphics.setColor(1, 1, 1, 1) end
end

return M
