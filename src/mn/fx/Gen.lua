-- Battle-scene generator. At ROM import (or the first battle after an older import) the game's own
-- code runs in mn.fx.Cgb from the CGB boot hand-over: its start-up, sound and battle set-up, then the
-- Glade battle against Weebo with a fixed joypad schedule. The frames the battle screen needs are
-- recorded into the private cache (mn_cache/battle_scenes.lua); tiles, maps and palettes there come
-- from the player's ROM through that run and are never shipped.
local Cgb = require("mn.fx.Cgb")
local Start = require("mn.fx.Start")
local band, rshift = bit.band, bit.rshift
local G = {}
G.VERSION = 1
G.FILE = "battle_scenes.lua"

local A_FIRST, A_PERIOD = 76, 30
-- joypad: A every 30 frames from frame 76; with focus, Down before the 7th A (Tony focuses on his
-- first turn, so Weebo attacks Tony before Furok is summoned)
local function events(focus, last)
  local ev, t, i = {}, A_FIRST, 0
  local function add(f, k, d) ev[f] = ev[f] or {}; table.insert(ev[f], { k, d }) end
  while t < last do
    if focus and i == 6 then add(t - 12, "down", true); add(t - 8, "down", false) end
    add(t, "a", true); add(t + 4, "a", false)
    t = t + A_PERIOD; i = i + 1
  end
  return ev
end

-- the Glade Weebo battle: its op $25 sits at $14:$4158 (script $14:$4076)
local REDIRECT_BANK, REDIRECT_PTR = 0x14, 0x4158
local CUTIN = 0x02 * 0x10000 + 0x472E

G.RUNS = {
  glade = { party = 0x1C, focus = true, last = 2420, cuts = { 1027, 1807, 2167 },
    stills = { menu = 245, target = 1537, slot = 783, furokmenu300 = 1503, tonymsg = 1600, idle = 1632, backdrop = 200 },
    pics = { ["53"] = { 449, 5, 0 }, ["1C"] = { 820, 5, 6 } },
    clips = { fight_weebo_tony = { 1, 8, 120 }, fight_weebo_furok = { 2, 8, 120 }, fight_furok_weebo = { 3, 8, 120 } },
    elim = { elim_top = { 2295, 121 } } },
  -- the same battle with species $4B as Tony's creature, for its card picture
  card4b = { party = 0x4B, focus = false, last = 432, cuts = {}, stills = {}, pics = { ["4B"] = { 430, 5, 6 } }, clips = {}, elim = {} },
}

local function isTony(y, x) return x >= 68 and x <= 80 and y >= 78 and y <= 96 end

-- scene store: tiles (16-byte strings, deduplicated), maps, palettes, frames
local function newStore()
  local st = { tiles = {}, tix = {}, maps = {}, mix = {}, pals = {}, pix = {} }
  function st.tile(s) local i = st.tix[s]; if not i then st.tiles[#st.tiles + 1] = s; i = #st.tiles - 1; st.tix[s] = i end return i end
  function st.map(t) local k = table.concat(t, ","); local i = st.mix[k]; if not i then st.maps[#st.maps + 1] = t; i = #st.maps - 1; st.mix[k] = i end return i end
  function st.pal(t)
    local f = {} for p = 1, 8 do f[p] = table.concat(t[p], ",") end
    local k = table.concat(f, ";"); local i = st.pix[k]; if not i then st.pals[#st.pals + 1] = t; i = #st.pals - 1; st.pix[k] = i end return i
  end
  return st
end

local function frameOf(st, m, filter)
  local l = m.LCDC
  local V = m.vram
  local function tbytes(bank, idx, obj)
    local base = (obj or band(l, 0x10) ~= 0) and idx * 16 or 0x1000 + ((idx >= 128) and idx - 256 or idx) * 16
    local t, v = {}, V[bank]
    for i = 0, 15 do t[i + 1] = string.char(v[base + i]) end
    return st.tile(table.concat(t))
  end
  local f = { l = l, m = {}, lines = {}, oam = {} }
  if band(l, 0x80) == 0 then f.off = true end -- LCD off: the screen shows white
  local function pal(mem) local t = {} for p = 0, 7 do t[p + 1] = {} for c = 0, 3 do t[p + 1][c + 1] = mem[p * 4 + c] end end return t end
  f.bp, f.op = st.pal(pal(m.bmem)), st.pal(pal(m.omem))
  for _, base in ipairs({ 0x1800, 0x1C00 }) do
    local t = {}
    for i = 0, 1023 do
      local a = V[1][base + i]
      t[#t + 1] = tbytes(band(rshift(a, 3), 1), V[0][base + i])
      t[#t + 1] = band(a, 7); t[#t + 1] = band(rshift(a, 5), 1); t[#t + 1] = band(rshift(a, 6), 1); t[#t + 1] = band(rshift(a, 7), 1)
    end
    f.m[("%X"):format(base)] = st.map(t)
  end
  local on = band(l, 0x80) ~= 0
  for y = 0, 143 do
    local s = on and m.scan[y] or { 0, 0, 0, 0 }
    local last = f.lines[#f.lines]
    if last and last[2] == s[1] and last[3] == s[2] and last[4] == s[3] and last[5] == s[4] then last[1] = last[1] + 1
    else f.lines[#f.lines + 1] = { 1, s[1], s[2], s[3], s[4] } end
  end
  local h = band(l, 4) ~= 0 and 16 or 8
  local c = m.env.cy()
  for i = 0, 39 do
    local y, x, t, a = m:R(0xFE00 + i * 4, c, 0), m:R(0xFE01 + i * 4, c, 0), m:R(0xFE02 + i * 4, c, 0), m:R(0xFE03 + i * 4, c, 0)
    if y > 0 and y < 160 and x > 0 and x < 168 and (not filter or filter(y - 16, x - 8)) then
      local b = band(rshift(a, 3), 1)
      local ts = h == 16 and { tbytes(b, band(t, 0xFE), true), tbytes(b, bit.bor(t, 1), true) } or { tbytes(b, t, true) }
      f.oam[#f.oam + 1] = { y - 16, x - 8, ts, band(a, 7), band(rshift(a, 5), 1), band(rshift(a, 6), 1), band(rshift(a, 7), 1) }
    end
  end
  return f
end

-- one run of the battle; onFrame(m, n) is for tools (frame dumps, block lists)
function G.runOne(rom, blocks, name, st, out, onFrame)
  local R = G.RUNS[name]
  local sram = Start.sram(Cgb, rom, blocks, { species = R.party })
  local m = Cgb.new(rom, blocks); Start.boot(m)
  local ev = events(R.focus, R.last)
  local done, cuts = false, {}
  m.hookpcs = { [0x0A66] = true }
  m.hook = function(mm)
    if done then return end
    done = true
    mm:write(0xFFA1, REDIRECT_BANK); mm:write(0xC938, REDIRECT_BANK); mm:write(0x2000, REDIRECT_BANK)
    local r = mm.env.regs(); r.B = rshift(REDIRECT_PTR, 8); r.C = band(REDIRECT_PTR, 0xFF); mm.env.setregs(r)
    for b = 0, 3 do for i = 0, 0x1FFF do mm.sram[b][i] = sram[b][i] end end
  end
  m.watch = { [CUTIN] = function(mm) cuts[#cuts + 1] = mm.frames end }
  local want = {}
  for k, n in pairs(R.stills) do want[n] = want[n] or {}; table.insert(want[n], { "still", k }) end
  for k, p in pairs(R.pics) do want[p[1]] = want[p[1]] or {}; table.insert(want[p[1]], { "pic", k, p[2], p[3] }) end
  for k, e in pairs(R.elim) do for i = 0, e[2] - 1 do local n = e[1] + i; want[n] = want[n] or {}; table.insert(want[n], { "elim", k, i }) end end
  for k, c in pairs(R.clips) do
    local base = R.cuts[c[1]] + c[2]
    for i = 0, c[3] - 1 do local n = base + i; want[n] = want[n] or {}; table.insert(want[n], { "clip", k, i }) end
  end
  while m.frames < R.last do
    m:frame()
    local n = m.frames
    if onFrame then onFrame(m, n) end
    local w = want[n]
    if w and st then
      local full
      for _, it in ipairs(w) do
        if it[1] == "elim" then
          out.scenes[it[2]] = out.scenes[it[2]] or {}
          out.scenes[it[2]][it[3] + 1] = frameOf(st, m, function(y, x) return not isTony(y, x) end)
        else
          full = full or frameOf(st, m)
          if it[1] == "still" then out.scenes[it[2]] = { full }
          elseif it[1] == "pic" then out.pics[it[2]] = { frame = full, col = it[3], row = it[4] }
          else out.scenes[it[2]] = out.scenes[it[2]] or {}; out.scenes[it[2]][it[3] + 1] = full end
        end
      end
    end
    for _, e in ipairs(ev[n] or {}) do m:button(e[1], e[2]) end
  end
  for i, c in ipairs(R.cuts) do
    if cuts[i] ~= c then error(("battle run %s: attack %d at frame %s, expected %d (ROM revision?)"):format(name, i, tostring(cuts[i]), c)) end
  end
  return m
end

function G.build(rom, log)
  log = log or function() end
  local blocks = require("mn.fx.Blocks")
  local st = newStore()
  local out = { version = G.VERSION, scenes = {}, pics = {} }
  for _, name in ipairs({ "glade", "card4b" }) do
    log("battle scenes: running " .. name)
    G.runOne(rom, blocks, name, st, out)
  end
  local hex = {}
  for i, s in ipairs(st.tiles) do hex[i] = (s:gsub(".", function(c) return ("%02x"):format(c:byte()) end)) end
  out.tiles, out.maps, out.pals = hex, st.maps, st.pals
  return out
end

-- ---------------------------------------------------------------- move and summon animations
-- Every move or spell animation goes through StagePointerUnlessD0B6Matches (02:472E): it stages the
-- script (bank in A, pointer in BC) at $C9CC/$C9CA, copies the actor and target species ($D0DB,
-- $D112) to $C9E0/$C9E1 and calls RunStagedPointerScript (04:71ED), which turns the LCD off, builds
-- the scene (PresentInstalledScriptEntries: backdrop by $C9E4, both creature pictures), runs the
-- script and its sprite records each frame (B skips, Start pauses) and ends on the white frames of
-- HandleScriptLoopB. The summon (LoadD107EntryThenScript4AE0 / FillD110ThenScript4AF5Or4B0A)
-- calls CountdownPanelCallbacks (04:61EB): the card palette is set in the panel's attributes, then
-- CopyGlyphBytes ($2949) copies one 16-byte tile of the card picture per frame.
-- Both run here as the game's own code, from one machine stopped at the first move animation of the
-- Glade run (the game's own call site, battle screen up); each request runs on a copy of it.
local CUT_PC = 0x472E
local CUT_RET = 0x02 * 0x10000 + 0x4763 -- the instruction after StagePointer's call of 04:71ED
local SUMMON_BANK, SUMMON_PC = 0x04, 0x61EB -- CountdownPanelCallbacks

function G.base(rom, blocks)
  local R = G.RUNS.glade
  local sram = Start.sram(Cgb, rom, blocks, { species = R.party })
  local m = Cgb.new(rom, blocks); Start.boot(m)
  local ev = events(R.focus, R.last)
  local redirected, stop = false, false
  m.hookpcs = { [0x0A66] = true, [CUT_PC] = true }
  m.hook = function(mm, pc)
    if pc == CUT_PC then if mm.rombank == 2 then stop = true end return end
    if redirected then return end
    redirected = true
    mm:write(0xFFA1, REDIRECT_BANK); mm:write(0xC938, REDIRECT_BANK); mm:write(0x2000, REDIRECT_BANK)
    local r = mm.env.regs(); r.B = rshift(REDIRECT_PTR, 8); r.C = band(REDIRECT_PTR, 0xFF); mm.env.setregs(r)
    for b = 0, 3 do for i = 0, 0x1FFF do mm.sram[b][i] = sram[b][i] end end
  end
  while m.frames < R.last and not stop do
    m.frame_done = false
    repeat m:step() until m.frame_done or stop
    if not stop then
      m.frames = m.frames + 1
      for _, e in ipairs(ev[m.frames] or {}) do m:button(e[1], e[2]) end
    end
  end
  if not stop then error("battle animation base: no move animation in the Glade run (ROM revision?)") end
  m.hookpcs, m.hook = nil, nil
  return m
end

-- frames of m one at a time until done() holds: next() -> frame, or nil once done
local function stream(m, st, done, limit, after)
  local n = 0
  return function()
    if n < 0 then return nil end
    m.frame_done = false
    repeat m:step() until m.frame_done or done()
    if done() then n = -1; return nil end
    m.frames = m.frames + 1; n = n + 1
    if n > limit then error(("animation still running after %d frames"):format(limit)) end
    local f = frameOf(st, m)
    if after then after(f) end
    return f
  end
end
local function all(next) local t = {} for f in next do t[#t + 1] = f end return t end

-- q = { bank, ptr, actor, target, actorSlot, targetSlot, c9e4 }: the frames from the staging call to
-- the return of RunStagedPointerScript (LcdOffSetup then redraws the battle screen). Returns next()
-- and the machine (its joypad takes B to skip and Start to pause, as in the game).
function G.cutinFrames(base, st, q, blocks)
  local m = base:clone(blocks)
  local r = m.env.regs(); r.A = q.bank; r.B = rshift(q.ptr, 8); r.C = band(q.ptr, 0xFF); m.env.setregs(r)
  m:write(0xD0B6, q.actorSlot); m:write(0xD103, q.targetSlot)
  m:write(0xD0DB, q.actor); m:write(0xD112, q.target)
  if q.c9e4 then m:write(0xC9E4, q.c9e4) end
  local back = false
  m.watch = { [CUT_RET] = function() back = true end }
  return stream(m, st, function() return back end, 4000), m
end
function G.cutin(base, st, q, blocks) return all(G.cutinFrames(base, st, q, blocks)) end

-- the summon of species into battle slot (1-8; the panel index is slot - 1). next() gives each frame
-- with f.copied = the card tiles CopyGlyphBytes has copied by then ($C6E9 is its VRAM destination);
-- after the last frame, card() gives the panel's cells (col, row, w, h in map "1800"/"1C00") and each
-- cell's tile number in the card picture (tileOf, row-major from 1).
function G.summonFrames(base, st, species, slot, blocks)
  local m = base:clone(blocks)
  m:write(0xC9D8, species); m:write(0xC9D9, slot - 1)
  local env = m.env
  local SENT = 0xFFF0
  local sp = band(env.sp() - 2, 0xFFFF)
  m:W(sp, band(SENT, 0xFF), env.cy(), 0); m:W(sp + 1, rshift(SENT, 8), env.cy(), 0); env.sp(sp)
  -- the caller runs in bank 4, which is what the routine's bank bookkeeping ($C938) restores
  m:write(0xFFA1, SUMMON_BANK); m:write(0xC938, SUMMON_BANK)
  m:W(0x2000, SUMMON_BANK, env.cy(), 0); m.PC = SUMMON_PC; m.stopAt = SENT; m.stopped = false
  local function rd(a) return m:R(a, env.cy(), 0) end
  local dest0
  m.watch = { [0x2949] = function() dest0 = dest0 or rd(0xC6E9) + rd(0xC6EA) * 256 end }
  local function copied() return dest0 and math.floor((rd(0xC6E9) + rd(0xC6EA) * 256 - dest0) / 16) or 0 end
  local next = stream(m, st, function() return m.stopped end, 200, function(f) f.copied = copied() end)
  local function card()
    local vbank, n = rd(0xC6EB), copied()
    if n == 0 then error("summon: no card tiles copied") end
    local l = m.LCDC
    local mapbase = band(l, 0x08) ~= 0 and 0x1C00 or 0x1800
    local cells, c0, r0, c1, r1 = {}, 99, 99, -1, -1
    for i = 0, 1023 do
      local id, at = m.vram[0][mapbase + i], m.vram[1][mapbase + i]
      local addr = band(l, 0x10) ~= 0 and 0x8000 + id * 16 or 0x9000 + (id >= 128 and id - 256 or id) * 16
      local k = (addr - dest0) / 16
      if band(rshift(at, 3), 1) == vbank and k >= 0 and k < n and k % 1 == 0 then
        local c, r = i % 32, math.floor(i / 32)
        cells[#cells + 1] = { c, r, k }
        c0, r0, c1, r1 = math.min(c0, c), math.min(r0, r), math.max(c1, c), math.max(r1, r)
      end
    end
    if #cells == 0 then error("summon: the card tiles are not on the BG map") end
    local tileOf = {}
    for _, c in ipairs(cells) do tileOf[(c[2] - r0) * (c1 - c0 + 1) + (c[1] - c0) + 1] = c[3] end
    return { col = c0, row = r0, w = c1 - c0 + 1, h = r1 - r0 + 1, tileOf = tileOf, n = n,
      map = mapbase == 0x1C00 and "1C00" or "1800", frame = frameOf(st, m) }
  end
  return next, card, m
end
function G.summon(base, st, species, slot, blocks)
  local next, card = G.summonFrames(base, st, species, slot, blocks)
  local frames = all(next)
  local c = card(); c.frames = frames
  return c
end

-- every animation the battle engine can stage: the move handlers' bank-$4C scripts, the Fight
-- animation ($4C:$5225) and each spell record's +$1F..+$21 script; and every summonable species
-- (rom: the ROM bytes, or battle data from mn.battle.Data.extract)
function G.animRequests(rom)
  local Engine = require("mn.battle.Engine")
  local Data = require("mn.battle.Data")
  local d = type(rom) == "string" and Data.extract(require("mn.MnRom").new(rom)) or rom
  local seen, cut = {}, {}
  local function add(bank, ptr)
    local k = bank * 0x10000 + ptr
    if not seen[k] then seen[k] = true; cut[#cut + 1] = { bank = bank, ptr = ptr } end
  end
  add(0x4C, 0x5225)
  for _, chain in pairs(Engine.HANDLERS) do
    for _, op in ipairs(chain) do if type(op) == "table" and op[1] == "anim" then add(0x4C, op[2]) end end
  end
  for _, p in ipairs(d.groupList) do
    local r = d.groups[p].raw
    if r[0x1F] ~= 0 then add(r[0x1F], r[0x20] + r[0x21] * 256) end
  end
  table.sort(cut, function(a, b) return a.bank * 0x10000 + a.ptr < b.bank * 0x10000 + b.ptr end)
  local sum = {}
  for _, id in ipairs(Data.creatures(d)) do if not Data.isMagi(d, id) then sum[#sum + 1] = id end end
  return cut, sum
end

-- a scene store over an already built table (its tiles are hex strings), for frames made at runtime
function G.storeFor(t)
  if t.store then return t.store end
  local st = newStore()
  for i, h in ipairs(t.tiles) do
    local s = h:gsub("%x%x", function(x) return string.char(tonumber(x, 16)) end)
    st.tiles[i] = s; st.tix[s] = i - 1
  end
  for i, mp in ipairs(t.maps) do st.maps[i] = mp; st.mix[table.concat(mp, ",")] = i - 1 end
  for i, p in ipairs(t.pals) do
    st.pals[i] = p
    local f = {} for q = 1, 8 do f[q] = table.concat(p[q], ",") end
    st.pix[table.concat(f, ";")] = i - 1
  end
  -- new entries go to t as well
  local tile, map, pal = st.tile, st.map, st.pal
  function st.tile(s)
    local n = #st.tiles; local i = tile(s)
    if #st.tiles > n then t.tiles[#t.tiles + 1] = (s:gsub(".", function(c) return ("%02x"):format(c:byte()) end)) end
    return i
  end
  function st.map(m) local n = #st.maps; local i = map(m); if #st.maps > n then t.maps[#t.maps + 1] = m end return i end
  function st.pal(p) local n = #st.pals; local i = pal(p); if #st.pals > n then t.pals[#t.pals + 1] = p end return i end
  t.store = st
  return st
end

-- compact Lua serialisation of the scene table
function G.serialize(t)
  local parts = {}
  local function w(v)
    local ty = type(v)
    if ty == "table" then
      parts[#parts + 1] = "{"
      local n = #v
      for i = 1, n do w(v[i]); parts[#parts + 1] = "," end
      for k, x in pairs(v) do
        if not (type(k) == "number" and k >= 1 and k <= n and k % 1 == 0) then
          parts[#parts + 1] = type(k) == "string" and ("[%q]="):format(k) or ("[%s]="):format(tostring(k))
          w(x); parts[#parts + 1] = ","
        end
      end
      parts[#parts + 1] = "}"
    elseif ty == "string" then parts[#parts + 1] = ("%q"):format(v)
    else parts[#parts + 1] = tostring(v) end
  end
  w(t)
  return "return " .. table.concat(parts)
end

-- LÖVE side: write the cache file, or load it (generating it from mn_cache/rom.bin when missing)
function G.write(rom, log)
  local Importer = require("mn.MnImporter")
  local t = G.build(rom, log)
  love.filesystem.write(Importer.CACHE .. "/" .. G.FILE, G.serialize(t))
  return t
end

function G.load(log)
  local Importer = require("mn.MnImporter")
  local path = Importer.CACHE .. "/" .. G.FILE
  local s = love.filesystem.read(path)
  if s then
    local ok, t = pcall(function() return assert(loadstring(s))() end)
    if ok and type(t) == "table" and t.version == G.VERSION then return t end
  end
  local rom = assert(love.filesystem.read(Importer.CACHE .. "/rom.bin"), "mn_cache/rom.bin missing (re-import)")
  return G.write(rom, log)
end

return G
