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
