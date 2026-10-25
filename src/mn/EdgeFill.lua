-- Best-guess metatiles for cells past a map's edge, for views wider than
-- 160x144 (see mn.Viewport). Built at draw time from the map's own cell plane
-- in the runtime cache (def.cells, metatile ids into that map's 256x256
-- atlas), so nothing ROM-derived is stored in the repo. Pure Lua: build()
-- returns fill(x, y) -> metatile id, or nil for black.
--
-- Modes:
--   block   (default) per side, the most common 2x2 metatile block in the
--           outer two rows/columns, tiled on the map's own parity, so 2-wide
--           trees, water and cliff patterns continue. Corners use the most
--           common block of the whole border ring.
--   edge    per side, the most common single metatile.
--   extend  repeat the nearest edge cell outward (clamp).
--   mirror  reflect the map across its edge.
--   black   no fill (the old look).
-- A per-map override (mn.EdgeFillMaps) may pick a mode, or name metatile ids:
--   { mode = "edge" } | { mt = 12 } | { n = 12, s = { 1, 2, 3, 4 }, corner = 0 }
-- where a side is one id or a 2x2 block { tl, tr, bl, br }.

local M = {}
M.MODES = { block = true, edge = true, extend = true, mirror = true, black = true }
M.DEFAULT = "block"

local floor, max, min = math.floor, math.max, math.min
local function pmod(a, b) return a - floor(a / b) * b end

local function cellAt(cells, W, x, y) return cells[y * W + x + 1] end

-- most common key in a count table (ties: smallest key, so it is deterministic)
local function best(counts, vals)
  local bk, bn
  for k, n in pairs(counts) do
    if not bn or n > bn or (n == bn and k < bk) then bk, bn = k, n end
  end
  return bk and vals[bk]
end

-- 2x2 blocks on absolute even parity inside the rectangle [x0,x1] x [y0,y1]
local function countBlocks(cells, W, H, x0, y0, x1, y1, counts, vals)
  for by = y0 - pmod(y0, 2), y1, 2 do
    for bx = x0 - pmod(x0, 2), x1, 2 do
      if bx >= 0 and by >= 0 and bx + 1 < W and by + 1 < H then
        local b = { cellAt(cells, W, bx, by), cellAt(cells, W, bx + 1, by),
                    cellAt(cells, W, bx, by + 1), cellAt(cells, W, bx + 1, by + 1) }
        local k = table.concat(b, ",")
        counts[k] = (counts[k] or 0) + 1; vals[k] = b
      end
    end
  end
end

local function countCells(cells, W, x0, y0, x1, y1, counts, vals)
  for y = y0, y1 do for x = x0, x1 do
    local v = cellAt(cells, W, x, y)
    if v then local k = ("%05d"):format(v); counts[k] = (counts[k] or 0) + 1; vals[k] = v end
  end end
end

-- the four side rectangles (outer two rows / columns)
local function bands(W, H)
  local d = 1
  return {
    n = { 0, 0, W - 1, min(H - 1, d) },
    s = { 0, max(0, H - 1 - d), W - 1, H - 1 },
    w = { 0, 0, min(W - 1, d), H - 1 },
    e = { max(0, W - 1 - d), 0, W - 1, H - 1 },
  }
end

local function sideTiles(cells, W, H, unit)
  local out, ringC, ringV = {}, {}, {}
  for side, r in pairs(bands(W, H)) do
    local c, v = {}, {}
    if unit == "block" then countBlocks(cells, W, H, r[1], r[2], r[3], r[4], c, v)
    else countCells(cells, W, r[1], r[2], r[3], r[4], c, v) end
    out[side] = best(c, v)
    for k, n in pairs(c) do ringC[k] = (ringC[k] or 0) + n; ringV[k] = v[k] end
  end
  out.corner = best(ringC, ringV)
  -- a band too thin for a 2x2 block falls back to its single dominant cell
  if unit == "block" then
    local single = sideTiles(cells, W, H, "edge")
    for _, k in ipairs({ "n", "s", "w", "e", "corner" }) do out[k] = out[k] or single[k] end
  end
  return out
end

-- a side entry (id or 2x2 block) -> the id for absolute cell (x, y)
local function pick(t, x, y)
  if type(t) == "table" then return t[pmod(y, 2) * 2 + pmod(x, 2) + 1] end
  return t
end

-- def: { w, h, cells }, mode: one of MODES (nil = default), ov: override entry
function M.build(def, mode, ov)
  local W, H, cells = def.w, def.h, def.cells
  ov = ov or {}
  mode = ov.mode or mode or M.DEFAULT
  if not M.MODES[mode] then mode = M.DEFAULT end
  if not cells or W < 1 or H < 1 or mode == "black" then
    if ov.mt then return function() return ov.mt end, "override" end
    return function() return nil end, "black"
  end
  if ov.mt then return function() return ov.mt end, "override" end
  if mode == "extend" then
    return function(x, y) return cellAt(cells, W, max(0, min(W - 1, x)), max(0, min(H - 1, y))) end, mode
  elseif mode == "mirror" then
    local function ref(a, n)
      local p = pmod(a, 2 * n)
      return p < n and p or 2 * n - 1 - p
    end
    return function(x, y) return cellAt(cells, W, ref(x, W), ref(y, H)) end, mode
  end
  local t = sideTiles(cells, W, H, mode == "block" and "block" or "edge")
  for _, k in ipairs({ "n", "s", "w", "e", "corner" }) do if ov[k] ~= nil then t[k] = ov[k] end end
  return function(x, y)
    local ox = x < 0 or x >= W
    local oy = y < 0 or y >= H
    if ox and oy then return pick(t.corner, x, y) end
    if y < 0 then return pick(t.n, x, y) elseif y >= H then return pick(t.s, x, y) end
    if x < 0 then return pick(t.w, x, y) elseif x >= W then return pick(t.e, x, y) end
    return cellAt(cells, W, x, y)
  end, mode
end

-- Cells of the view rectangle (L, T, vw, vh in map pixels) that lie outside
-- the map, as calls to emit(cellX, cellY, mt). Returns the count.
function M.each(fill, W, H, L, T, vw, vh, emit)
  local n = 0
  for y = floor(T / 16), floor((T + vh - 1) / 16) do
    for x = floor(L / 16), floor((L + vw - 1) / 16) do
      if x < 0 or y < 0 or x >= W or y >= H then
        local mt = fill(x, y)
        if mt then emit(x, y, mt); n = n + 1 end
      end
    end
  end
  return n
end

return M
