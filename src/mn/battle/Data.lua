-- Magi-Nation battle data, decoded from the user's ROM at import time.
--
-- Nothing here is committed ROM data: MnImporter calls Data.extract(rom) on first
-- boot and caches the result (mn_cache/battle_data.lua) like every other asset.
-- Layouts follow the matching disassembly (decomp/ in this repo):
--
--   names     bank 6 $5AA6, ten ASCII bytes per id (CopyIndexedName)
--   entries   bank 4 $415B, $2D bytes per id: creature and Magi templates
--             (FillD110FromIndexedEntry, ExpandD391Record)
--   moves     bank 5 $5EAE-$651D, 16-byte command records copied to $D100
--             (+0 handler in bank 2, +2 energy cost, +3 target class, +4 menu kind,
--              +5 kind ($80 physical), +6 element bits, +7 power, +8 accuracy,
--              +9 seven-byte name)
--   groups    bank 7 $22-byte item / relic / spell records (CopyIndexedGroupRecord)
--   b2        bank 2 $4000-$413F: damage span pairs (D0ESpanPairs); the luck jitter
--             table JitterScaledTableByte reads at $40DC lies inside it
--   growth    bank 2 $5B0F-$5B34: level-up contribution tables (SpendMeasureHundred)
--   texts     bank $4C battle message scripts ($9F strips, $FC = next name/number)
local M = {}

M.NAME_BANK, M.NAME_PTR = 0x06, 0x5AA6
M.ENTRY_BANK, M.ENTRY_PTR, M.ENTRY_STRIDE = 0x04, 0x415B, 0x2D
M.ENTRY_COUNT = 0x6D -- ids 0..$6C: creatures $00-$55, Tony $58, Magi $59-$6B, wild $6C
M.MOVE_BANK, M.MOVE_FIRST, M.MOVE_END = 0x05, 0x5EAE, 0x651E
M.CREATURE_LAST = 0x55
M.GROUP_BANK = 0x07
M.GROUP_RANGES = { -- base, first, last (exclusive), kind
  { 0x5DFF, 0x5E21, 0x61B7, "item" },
  { 0x6FF5, 0x7017, 0x729D, "spell" },
}
M.TEXT_BANK, M.TEXT_FIRST, M.TEXT_END = 0x4C, 0x4166, 0x4B6A

local function off(bank, ptr) return bank * 0x4000 + ptr - 0x4000 end

local function bytes(rom, o, n)
  local t = {}
  for i = 0, n - 1 do t[i] = rom:u8(o + i) end
  return t
end

local function str(rom, o, n)
  local s = {}
  for i = 0, n - 1 do
    local c = rom:u8(o + i)
    s[#s + 1] = (c >= 32 and c < 127) and string.char(c) or " "
  end
  return (table.concat(s):gsub("%s+$", ""))
end

-- rom: anything with :u8(fileOffset) (mn.MnRom, or a string wrapper in tools)
function M.extract(rom)
  local d = { names = {}, entries = {}, moves = {}, moveList = {}, groups = {}, groupList = {}, texts = {} }
  for id = 0, M.ENTRY_COUNT - 1 do
    d.names[id] = str(rom, off(M.NAME_BANK, M.NAME_PTR) + id * 10, 10)
    d.entries[id] = bytes(rom, off(M.ENTRY_BANK, M.ENTRY_PTR) + id * M.ENTRY_STRIDE, M.ENTRY_STRIDE)
  end
  for p = M.MOVE_FIRST, M.MOVE_END - 1, 16 do
    local o = off(M.MOVE_BANK, p)
    local r = bytes(rom, o, 16)
    local name = str(rom, o + 9, 7)
    d.moves[p] = { ptr = p, raw = r, name = name, handler = r[0] + r[1] * 256, cost = r[2], target = r[3],
      menu = r[4], kind = r[5], element = r[6], power = r[7], accuracy = r[8] }
    d.moveList[#d.moveList + 1] = p
  end
  for _, g in ipairs(M.GROUP_RANGES) do
    for p = g[2], g[3] - 1, 0x22 do
      local o = off(M.GROUP_BANK, p)
      local r = bytes(rom, o, 0x22)
      d.groups[p] = { ptr = p, raw = r, kind = g[4], index = (p - g[1]) / 0x22,
        name = str(rom, o + 0x0C, 13):gsub("^%s+", ""), handler = r[0] + r[1] * 256, cost = r[4], target = r[5], power = r[2] }
      d.groupList[#d.groupList + 1] = p
    end
  end
  -- relic / creature-pair records, bank 7 $6916, 19 bytes: three bank-7 routine
  -- pointers (command load, creature summon, damage step) and a 12-byte name
  d.relics = {}
  for id = 0, 0x7F do
    local o = off(0x07, 0x6916) + id * 19
    local p1, p2, p3 = rom:u8(o) + rom:u8(o + 1) * 256, rom:u8(o + 2) + rom:u8(o + 3) * 256, rom:u8(o + 4) + rom:u8(o + 5) * 256
    local lead = rom:u8(o + 6)
    local okp = function(p) return p >= 0x4000 and p < 0x8000 end
    if id > 0 and (lead ~= 0x1B or not (okp(p1) and okp(p2) and okp(p3))) then break end
    d.relics[id] = { id = id, onLoad = p1, onSummon = p2, onHit = p3, name = str(rom, o + 7, 12) }
  end
  d.statusNames = {}
  for b = 0, 7 do d.statusNames[b] = str(rom, off(0x07, 0x646D) + b * 9, 9) end
  d.b2 = bytes(rom, off(0x02, 0x4000), 0x140)
  d.growth = bytes(rom, off(0x02, 0x5B0F), 0x26)
  -- message scripts: every $9F strip in the bank-$4C message block, keyed by the
  -- pointer the battle engine plants at $C71B
  local p = M.TEXT_FIRST
  while p < M.TEXT_END do
    local o = off(M.TEXT_BANK, p)
    if rom:u8(o) == 0x9F or (rom:u8(o) == 0x9B and rom:u8(o + 3) == 0x9F) then
      local s = rom:u8(o) == 0x9B and 4 or 1
      local t = {}
      local q = o + s
      while rom:u8(q) ~= 0xFD and #t < 120 do t[#t + 1] = rom:u8(q); q = q + 1 end
      d.texts[p] = t
      p = p + (q - o) + 1
    else
      p = p + 1
    end
  end
  return d
end

-- creature roster: species ids that have a creature template (every id up to $55)
function M.creatures(d)
  local t = {}
  for id = 0, M.CREATURE_LAST do t[#t + 1] = id end
  return t
end

function M.isMagi(d, id) return d.entries[id] and d.entries[id][0] == 0x0C end

-- moves a species can ever use: the four command words of its template
function M.speciesMoves(d, id)
  local e, t = d.entries[id], {}
  for k = 0, 3 do
    local p = e[18 + 2 * k] + e[19 + 2 * k] * 256
    t[#t + 1] = { ptr = p, unlock = e[26 + k] }
  end
  return t
end

-- text with $FC substitutions from the $C949 list: subs = { actor, target, count };
-- $FB skips one entry, $FF/$FE break lines
function M.render(d, ptr, subs)
  local t = d.texts and d.texts[ptr]
  if not t then return nil end
  local out, line, si = {}, {}, 1
  for _, c in ipairs(t) do
    if c == 0xFC then line[#line + 1] = subs and subs[si] or ""; si = si + 1
    elseif c == 0xFB then si = si + 1 -- skip one list entry
    elseif c == 0xFF or c == 0xFE then
      if #line > 0 then out[#out + 1] = table.concat(line) end
      line = {}
    elseif c >= 32 and c < 127 then line[#line + 1] = string.char(c)
    elseif c == 0x11 then line[#line + 1] = "\17" end
  end
  if #line > 0 then out[#out + 1] = table.concat(line) end
  return table.concat(out, "\n")
end

return M
