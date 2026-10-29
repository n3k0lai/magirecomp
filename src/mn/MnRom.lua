-- Magi-Nation (GBC) ROM decoder: first vertical slice.
-- Pure Lua (LuaJIT `bit`), no LOVE dependency. Formats follow the decomp at
-- mn-gfx branch integration:
--   src/load_five_banked_map_sources.asm, src/copy_map_records.asm,
--   src/unpack_bytes.asm, scripts/rle/README.md, scripts/own/gen_map_sources.py
local bit = require("bit")
local band, bor, rshift, lshift = bit.band, bit.bor, bit.rshift, bit.lshift

local M = {}
M.__index = M

M.MAP_SOURCES_BANK = 0x4F -- bank $4F $4000: 369 records x 5 far pointers
M.MAP_COUNT = 369

function M.new(bytes)
  assert(#bytes >= 0x200000, "ROM too small")
  local self = setmetatable({ s = bytes }, M)
  return self
end

function M.fromFile(path)
  local f = assert(io.open(path, "rb")); local s = f:read("*a"); f:close()
  return M.new(s)
end

function M:u8(o) return self.s:byte(o + 1) end
function M:u16(o) return self.s:byte(o + 1) + lshift(self.s:byte(o + 2), 8) end
function M.off(ptr, bank) return bank * 0x4000 + ptr - 0x4000 end

-- UnpackBytes: $01-3F copy n | $81-BF fill n | $40-7F lo copy long | $C0-FF lo v fill long | $00/$80 end
function M:unpack(o)
  local out, p = {}, o
  while true do
    local c = self:u8(p); local kind, n = rshift(c, 6), band(c, 0x3F)
    if (kind == 0 or kind == 2) and n == 0 then p = p + 1; break end
    if kind == 0 then
      for i = 1, n do out[#out + 1] = self:u8(p + i) end; p = p + 1 + n
    elseif kind == 2 then
      local v = self:u8(p + 1); for _ = 1, n do out[#out + 1] = v end; p = p + 2
    else
      n = bor(lshift(n, 8), self:u8(p + 1))
      if kind == 1 then
        for i = 1, n do out[#out + 1] = self:u8(p + 1 + i) end; p = p + 2 + n
      else
        local v = self:u8(p + 2); for _ = 1, n do out[#out + 1] = v end; p = p + 3
      end
    end
  end
  return out, p
end

function M:mapSources(i)
  local o = M.off(0x4000 + 15 * i, M.MAP_SOURCES_BANK)
  local t = {}
  for k = 0, 4 do t[k] = { ptr = self:u16(o + 3 * k), bank = self:u8(o + 3 * k + 2) } end
  return t
end

-- slot 0: 32 RGB555 words = 8 BG palettes x 4 colours -> {r,g,b} 0..1
function M:palettes(src)
  local o, pals = M.off(src.ptr, src.bank), {}
  for p = 0, 7 do
    pals[p] = {}
    for c = 0, 3 do
      local w = self:u16(o + 2 * (p * 4 + c))
      pals[p][c] = { band(w, 31) / 31, band(rshift(w, 5), 31) / 31, band(rshift(w, 10), 31) / 31 }
    end
  end
  return pals
end

-- slot 1: CopyMapRecords. Two counted lists (VRAM bank 0, bank 1) of 7-byte
-- records: dw dest, dw src, db tiles (bit4 => src stride $100), db rows, db bank.
-- Returns vram[0..1] as Lua arrays indexed by (addr-$8000).
function M:vram(src)
  local vram = { [0] = {}, [1] = {} }
  for b = 0, 1 do for i = 0, 0x17FF do vram[b][i] = 0 end end
  local o = M.off(src.ptr, src.bank)
  for vb = 0, 1 do
    local n = self:u8(o); o = o + 1
    for _ = 1, n do
      local dest, s, tiles, rows, bank = self:u16(o), self:u16(o + 2), self:u8(o + 4), self:u8(o + 5), self:u8(o + 6)
      o = o + 7
      local cnt = band(tiles, 0x0F); if cnt == 0 then cnt = 16 end
      local sstride = band(tiles, 0x10) ~= 0 and 0x100 or cnt * 16
      for r = 0, rows - 1 do
        local so = M.off(s + r * sstride, bank)
        local d0 = dest + r * 0x100 - 0x8000
        for k = 0, cnt * 16 - 1 do
          if d0 + k >= 0 and d0 + k < 0x1800 then vram[vb][d0 + k] = self:u8(so + k) end
        end
      end
    end
  end
  return vram
end

-- slot 2: 2048-byte metatile table (UnpackBytes): 256 x 4 tile ids, then 256 x 4 attrs
function M:metatiles(src)
  local d = self:unpack(M.off(src.ptr, src.bank))
  return d
end

-- slot 3: map record: w, w*9 (dw), w-11, r, size (dw), then stream (metatile ids)
function M:mapRecord(src)
  local o = M.off(src.ptr, src.bank)
  local w, rr, size = self:u8(o), self:u8(o + 4), self:u16(o + 5)
  local cells = self:unpack(o + 7)
  -- byte 3 (w-11) / byte 4 = last camera column / row (wMapColumn/wMapRow clamp)
  return { w = w, h = math.floor(#cells / w), cameraCols = self:u8(o + 3), cameraRows = rr, size = size, cells = cells }
end

-- slot 4: block record: w, len (dw), stream (per-cell collision/behaviour)
function M:blockRecord(src)
  local o = M.off(src.ptr, src.bank)
  return { w = self:u8(o), len = self:u16(o + 1), cells = self:unpack(o + 3) }
end

function M:loadMap(i)
  local s = self:mapSources(i)
  return {
    index = i, sources = s,
    palettes = self:palettes(s[0]), vram = self:vram(s[1]),
    meta = self:metatiles(s[2]), map = self:mapRecord(s[3]), block = self:blockRecord(s[4]),
  }
end

-- LCDC signed tile mode ($9000 base): id<128 -> $9000, else $8800 region.
local function tileBase(id) return id < 128 and (0x1000 + id * 16) or (id * 16) end

-- Render to an RGBA callback: put(x, y, r, g, b). Returns pixel w, h.
function M.render(m, put)
  local W, H = m.map.w, m.map.h
  for my = 0, H - 1 do for mx = 0, W - 1 do
    local mt = m.map.cells[my * W + mx + 1]
    for q = 0, 3 do
      local id = m.meta[mt * 4 + q + 1]; local at = m.meta[1024 + mt * 4 + q + 1]
      local pal = m.palettes[band(at, 7)]; local vb = band(at, 8) ~= 0 and 1 or 0
      local xf, yf = band(at, 0x20) ~= 0, band(at, 0x40) ~= 0
      local base = tileBase(id); local mem = m.vram[vb]
      local ox, oy = mx * 16 + (q % 2) * 8, my * 16 + math.floor(q / 2) * 8
      for ty = 0, 7 do
        local sy = yf and (7 - ty) or ty
        local lo, hi = mem[base + sy * 2], mem[base + sy * 2 + 1]
        for tx = 0, 7 do
          local sx = xf and tx or (7 - tx)
          local ci = bor(band(rshift(lo, sx), 1), lshift(band(rshift(hi, sx), 1), 1))
          local c = pal[ci]; put(ox + tx, oy + ty, c[1], c[2], c[3])
        end
      end
    end
  end end
  return W * 16, H * 16
end

-- ---------------------------------------------------------------------------
-- Script layer (static walk only). Opcode metadata: src/mn/Opcodes.lua.
local Op = require("mn.Opcodes")

function M:exprSize(o, depth)
  depth = depth or 0
  local k = Op.EXPR[self:u8(o)]
  if not k or depth > 16 then return nil end
  local n = 1 + k[1]
  for _ = 1, k[2] do
    local m = self:exprSize(o + n, depth + 1); if not m then return nil end
    n = n + m
  end
  return n
end

-- Size of the instruction at file offset o, plus far branch targets {bank,ptr}.
function M:insn(o)
  local op = self:u8(o); local L = Op.LEN[op]; local t = {}
  if L == nil then return nil end
  if type(L) == "number" then
    if op == 0x45 then t[1] = { self:u8(o + 1), self:u16(o + 2) } end
    return 1 + L, t, op
  end
  local n
  if L == "pick" then
    local c = self:u8(o + 1); n = 2 + 3 * c
    for i = 0, c - 1 do t[#t + 1] = { self:u8(o + 2 + 3 * i), self:u16(o + 3 + 3 * i) } end
  elseif L == "range7" or L == "exact5" then
    local m = self:exprSize(o + 1); if not m then return nil end
    local k = L == "range7" and 7 or 5; local e = o + 1 + m; local guard = 0
    while self:u8(e) ~= 0xFF and guard < 64 do
      t[#t + 1] = { self:u8(e), self:u16(e + k - 2) }; e = e + k; guard = guard + 1
    end
    n = e + 1 - o
  elseif L == "expr3" then
    local m = self:exprSize(o + 1); if not m then return nil end
    t[1] = { self:u8(o + 1 + m), self:u16(o + 2 + m) }; n = 1 + m + 3
  elseif L == "expr_w" or L == "expr_wb" then
    -- $A6/$A7 (address word, expression), $A5 (address word, mask byte, expression):
    -- the ferry fare 2A:5261 is `$A7 A3A5 (A3A5 - 300)`, which ended the record unsized
    local k = L == "expr_w" and 3 or 4
    local m = self:exprSize(o + k); if not m then return nil end
    n = k + m
  elseif L == "strip" then
    local e = o + 1; while self:u8(e) ~= 0xFD do e = e + 1 end; n = e + 1 - o
  elseif L == "blk0" then n = 3 + self:u16(o + 1)
  elseif L == "blk8e" then n = 9 + self:u16(o + 7)
    t[1] = { self:u8(o + 1), self:u16(o + 2) }; t[2] = { self:u8(o + 4), self:u16(o + 5) }
  elseif L == "blk3" then n = 6 + self:u16(o + 4)
  elseif L == "repeat2" then n = self:u8(o + 1) == 0 and 2 or 4
  elseif L == "rec3" or L == "rec4" or L == "rec5" or L == "rec6" then
    local k = tonumber(L:sub(4)); local e = o + 1
    while self:u8(e) ~= 0 do e = e + k end; n = e + 1 - o
  elseif L == "tab" then if band(self:u8(o + 1), 1) ~= 0 then return nil end; n = 5 + self:u8(o + 1)
  else return nil end
  return n, t, op
end

-- Map-entry scripts: opcode $65 (LoadFiveBankedMapSources via $1820) with a
-- bank-$4F pointer. Followed by $64 (ReadBank21ByteThenResume: trigger list)
-- and $05 object spawns (slot, sprite list ptr, cell X, cell Y, ...).
function M:findEntries()
  local out = {}
  for b = 0x02, 0x7F do
    local base = b * 0x4000
    for a = 0, 0x3FFB do
      local o = base + a
      if self:u8(o) == 0x65 and self:u8(o + 3) == 0x4F then
        local p = self:u16(o + 1)
        if p >= 0x4000 and p < 0x559E and (p - 0x4000) % 15 == 0 then
          local e = { bank = b, ptr = 0x4000 + a, map = (p - 0x4000) / 15 }
          local q = o + 4
          for _ = 1, 24 do
            local n, _, op = self:insn(q); if not n then break end
            if op == 0x64 and not e.list then e.list = self:u16(q + 1) end
            if op == 0x05 and self:u8(q + 1) == 0 and not e.spawn then
              e.spawn = { x = self:u8(q + 4), y = self:u8(q + 5) }
            end
            if Op.END[op] then break end
            q = q + n
          end
          out[#out + 1] = e
        end
      end
    end
  end
  return out
end

-- Bank-$21 trigger list: count, then 4-byte {kind, bank, ptr}. Kind is the
-- direction gate in StageThirdScriptFromMarkedCell: 1 moving up, 2 down,
-- 3 right, 4 left, other values fire from any direction.
function M:triggerList(ptr)
  local o = M.off(ptr, 0x21); local c = self:u8(o); local t = {}
  for i = 0, c - 1 do
    local q = o + 1 + 4 * i
    t[i] = { kind = self:u8(q), bank = self:u8(q + 1), ptr = self:u16(q + 2) }
  end
  return t, c
end

-- A plausible trigger list: 1..63 records, each a ROM bank and a
-- $4000-$7FFF script pointer.
function M:triggerListOk(ptr)
  local t, c = self:triggerList(ptr)
  if c < 1 or c > 63 then return false end
  for i = 0, c - 1 do
    if t[i].bank < 0x02 or t[i].bank > 0x7F or t[i].ptr < 0x4000 or t[i].ptr > 0x7FFF then return false end
  end
  return true
end

-- Follow a trigger script (straight line + far branches, BFS) to the first
-- map-entry script. Opcode $02 before it rebases the player position:
-- x' = x - b0 + b1, y' = y - b2 + b3 (wScriptPair from $C18E/$C18F).
function M:resolveWarp(bank, ptr, entryAt)
  local queue, seen, head = { { bank, ptr } }, {}, 1
  local rebase
  while head <= #queue and head < 64 do
    local b, p = queue[head][1], queue[head][2]; head = head + 1
    local key = b * 65536 + p
    if not seen[key] and p >= 0x4000 and p < 0x8000 then
      seen[key] = true
      local o = M.off(p, b)
      for _ = 1, 40 do
        if self:u8(o) == 0x65 and self:u8(o + 3) == 0x4F then
          local e = entryAt[b * 65536 + (o - b * 0x4000 + 0x4000)]
          return { map = (self:u16(o + 1) - 0x4000) / 15, entry = e, rebase = rebase }
        end
        local n, t, op = self:insn(o); if not n then break end
        if op == 0x02 and not rebase then
          rebase = { self:u8(o + 1), self:u8(o + 2), self:u8(o + 3), self:u8(o + 4) }
        end
        for _, x in ipairs(t) do queue[#queue + 1] = x end
        -- $93 FinishStartup resets SP into MainLoop; the record's script
        -- continues at the next byte (every map-entry script starts 93 65).
        -- $86 SeedCameraAndEnterLoop reruns the loop from the next byte too;
        -- $94 MarkScriptDone21B2 yields a frame and resumes at the next byte.
        if Op.END[op] and op ~= 0x86 and op ~= 0x93 and op ~= 0x94 then break end
        o = o + n
      end
    end
  end
  return nil
end

return M
