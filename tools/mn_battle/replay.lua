-- Replay PyBoy oracle rounds through the Lua engine and diff battle WRAM.
--   luajit tools/mn_battle/replay.lua --rom ROM trace.json [more.json ...] [--json out.json]
-- For each recorded round: load the pre-round WRAM and $FFA9, play the recorded
-- divider draws through mn.battle.Rng.replay, run Engine.resolve, and compare the
-- result with the post-round WRAM. Prints the differing bytes and which commands
-- ran, and (with --json) writes the per-move / per-creature match summary the
-- tester folds into the coverage report.
package.path = "src/?.lua;tools/mn_battle/?.lua;" .. package.path
local MnRom = require("mn.MnRom")
local Data = require("mn.battle.Data")
local Engine = require("mn.battle.Engine")
local Rng = require("mn.battle.Rng")
local json = require("json")

local rom, files, out = nil, {}, nil
local i = 1
while i <= #arg do
  if arg[i] == "--rom" then rom = arg[i + 1]; i = i + 1
  elseif arg[i] == "--json" then out = arg[i + 1]; i = i + 1
  else files[#files + 1] = arg[i] end
  i = i + 1
end
local data = Data.extract(MnRom.fromFile(rom or os.getenv("MN_ROM")))
local moveByHandler = {}
for _, p in ipairs(data.moveList) do moveByHandler[data.moves[p].handler] = p end

local function unhex(h) return (h:gsub("%x%x", function(x) return string.char(tonumber(x, 16)) end)) end

-- names for the WRAM areas a diff lands in
local function where(a)
  if a >= 0xD147 and a < 0xD147 + 10 * 0x37 then
    local slot = math.floor((a - 0xD147) / 0x37)
    return ("slot%d+%02X"):format(slot, (a - 0xD147) % 0x37)
  end
  if a >= 0xD0D9 and a < 0xD110 then return ("actor+%02X"):format(a - 0xD0D9) end
  if a >= 0xD110 and a < 0xD147 then return ("target+%02X"):format(a - 0xD110) end
  return ("%04X"):format(a)
end

local summary = { rounds = 0, matched = 0, moves = {}, creatures = {}, mismatchMoves = {}, battles = {} }
for _, f in ipairs(files) do
  local fh = assert(io.open(f, "r")); local t = json.decode(fh:read("*a")); fh:close()
  local okAll = true
  for r, rd in ipairs(t.rounds) do
    local list = {}
    for _, d in ipairs(rd.draws) do
      if d[1] == "s" then list[#list + 1] = { "s", d[2] } else list[#list + 1] = { d[1], d[2] } end
    end
    local rng = Rng.replay(list)
    -- the party lives in SRAM bank wSRAMBank+1 ($C727); older traces default to bank 1
    local party
    if rd.sram then
      local bank = tostring((rd.pre.srambank or 0) + 1)
      if rd.sram[bank] then party = Engine.partyFromSram(unhex(rd.sram[bank])) end
    end
    local s = Engine.load(data, unhex(rd.pre.wram), rd.pre.ffa9, rng, party)
    local ok, err = pcall(Engine.resolve, s)
    local post = unhex(rd.post.wram)
    local diffs = {}
    for a = 0, 0x3FF do
      local want, got = post:byte(a + 1), s.m[0xD000 + a]
      if want ~= got then diffs[#diffs + 1] = ("%s want %02X got %02X"):format(where(0xD000 + a), want, got) end
    end
    if s.ffa9 ~= rd.post.ffa9 then diffs[#diffs + 1] = ("FFA9 want %02X got %02X"):format(rd.post.ffa9, s.ffa9) end
    if rng.i ~= #list then diffs[#diffs + 1] = ("draws used %d of %d"):format(rng.i, #list) end
    if rng.err then diffs[#diffs + 1] = "rng " .. rng.err end
    if not ok then diffs[#diffs + 1] = "error " .. tostring(err) end
    local acts = {}
    for _, ev in ipairs(s.events) do
      if ev.t == "act" then acts[#acts + 1] = { handler = ev.handler, species = ev.species, slot = ev.slot } end
    end
    local names = {}
    for _, x in ipairs(acts) do
      local p = moveByHandler[x.handler]
      names[#names + 1] = ("%s:%s"):format(data.names[x.species] or "?", p and data.moves[p].name or ("%04X"):format(x.handler))
    end
    summary.rounds = summary.rounds + 1
    local match = #diffs == 0
    if match then summary.matched = summary.matched + 1 else okAll = false end
    for _, x in ipairs(acts) do
      local p = moveByHandler[x.handler]
      if p then
        if match then summary.moves[p] = true else summary.mismatchMoves[p] = true end
      end
      if x.slot >= 1 and x.slot <= 8 and match then summary.creatures[x.species] = true end
    end
    print(("%s round %d: %s  [%s]"):format(f, r, match and "MATCH" or ("%d diffs"):format(#diffs), table.concat(names, ", ")))
    for k = 1, math.min(#diffs, 14) do print("    " .. diffs[k]) end
  end
  summary.battles[f:match("([^/]+)$")] = okAll and "all rounds match" or "mismatch"
end
print(("%d/%d rounds match"):format(summary.matched, summary.rounds))
if out then
  local L = {}
  for p in pairs(summary.moves) do if not summary.mismatchMoves[p] then L[#L + 1] = ('"move:%04X": true'):format(p) end end
  for id in pairs(summary.creatures) do L[#L + 1] = ('"creature:%02X": true'):format(id) end
  for k, v in pairs(summary.battles) do L[#L + 1] = ('"battle:%s": "%s"'):format(k, v) end
  L[#L + 1] = ('"rounds": %d, "matched": %d'):format(summary.rounds, summary.matched)
  local fh = assert(io.open(out, "w")); fh:write("{\n  ", table.concat(L, ",\n  "), "\n}\n"); fh:close()
end
