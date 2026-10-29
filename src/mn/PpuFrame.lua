-- Minimal CGB PPU for the battle scenes in the private cache (mn_cache/battle_scenes.lua, written by
-- mn.fx.Gen from a run of the game's own code on the player's ROM). A scene frame is: LCDC, both 32x32
-- tile maps, per-line SCX/SCY/WX/WY runs, OAM, BG/OBJ palettes; tiles are 16-byte strings (hex) in
-- the cache. Validated against PyBoy screenshots.
local M = {}
local D, px = nil, {}

local function load()
  if D then return D end
  D = require("mn.fx.Gen").load()
  return D
end
function M.data() return load() end
function M.reset() D, px = nil, {} end

-- tile index (0-based into D.tiles) -> 64 colour indices
local function tilepx(ti)
  local t = px[ti]; if t then return t end
  t = {}
  local hex = D.tiles[ti + 1]
  for y = 0, 7 do
    local lo, hi = tonumber(hex:sub(y * 4 + 1, y * 4 + 2), 16), tonumber(hex:sub(y * 4 + 3, y * 4 + 4), 16)
    for x = 0, 7 do
      local b = 7 - x
      t[y * 8 + x] = (math.floor(lo / 2 ^ b) % 2) + 2 * (math.floor(hi / 2 ^ b) % 2)
    end
  end
  px[ti] = t; return t
end

local function colour(w) return (w % 32) / 31, (math.floor(w / 32) % 32) / 31, (math.floor(w / 1024) % 32) / 31 end
local function palrgb(p)
  local out = {}
  for i = 0, 7 do out[i] = {} for c = 0, 3 do out[i][c] = { colour(p[i + 1][c + 1]) } end end
  return out
end

function M.scene(name) load(); return D.scenes[name] end

-- draw OAM entries of frame f into img (ImageData) with optional filter(o) and offset
function M.oam(img, f, filter, dx, dy)
  load(); local op = palrgb(D.pals[f.op + 1]); local h = (math.floor(f.l / 4) % 2 == 1) and 16 or 8
  for i = #f.oam, 1, -1 do
    local o = f.oam[i]
    if not filter or filter(o) then
      local oy, ox, ts, p, xf, yf = o[1] + (dy or 0), o[2] + (dx or 0), o[3], o[4], o[5], o[6]
      for yy = 0, h - 1 do
        local ty = yf == 1 and h - 1 - yy or yy
        local t = tilepx(ts[math.floor(ty / 8) + 1])
        for xx = 0, 7 do
          local sx, sy = ox + xx, oy + yy
          if sx >= 0 and sx < img:getWidth() and sy >= 0 and sy < img:getHeight() then
            local v = t[(ty % 8) * 8 + (xf == 1 and 7 - xx or xx)]
            if v ~= 0 then local c = op[p][v]; img:setPixel(sx, sy, c[1], c[2], c[3], 1) end
          end
        end
      end
    end
  end
end

-- copy a rectangle of tile-map cells (map name "1800"/"1C00", cell col/row) into img at px,py
function M.cells(img, f, mapname, col, row, w, h, px0, py0)
  load(); local bp = palrgb(D.pals[f.bp + 1]); local m = D.maps[f.m[mapname] + 1]
  for r = 0, h - 1 do for c = 0, w - 1 do
    local k = ((row + r) * 32 + col + c) * 5
    local t, p, xf, yf = tilepx(m[k + 1]), m[k + 2], m[k + 3], m[k + 4]
    for y = 0, 7 do for x = 0, 7 do
      local v = t[(yf == 1 and 7 - y or y) * 8 + (xf == 1 and 7 - x or x)]
      local cc = bp[p][v]; img:setPixel(px0 + c * 8 + x, py0 + r * 8 + y, cc[1], cc[2], cc[3], 1)
    end end
  end end
end

-- full frame render (BG + window per line, then OBJ) -> ImageData 160x144
function M.render(f)
  load()
  local img = love.image.newImageData(160, 144)
  if f.off then -- LCD off (LCDC bit 7 clear): the CGB shows white
    for y = 0, 143 do for x = 0, 159 do img:setPixel(x, y, 1, 1, 1, 1) end end
    return img
  end
  local bp = palrgb(D.pals[f.bp + 1])
  local lcdc = f.l
  local bit = function(n) return math.floor(lcdc / 2 ^ n) % 2 == 1 end
  local bgm = D.maps[f.m[bit(3) and "1C00" or "1800"] + 1]
  local wm = D.maps[f.m[bit(6) and "1C00" or "1800"] + 1]
  local y, wline = 0, 0
  for _, run in ipairs(f.lines) do
    local n, scx, scy, wx, wy = run[1], run[2], run[3], run[4], run[5]
    for _ = 1, n do
      local winon = bit(5) and y >= wy and wx < 160
      for x = 0, 159 do
        local mx, my, m
        if winon and x >= wx then mx, my, m = x - wx, wline, wm
        else mx, my, m = (x + scx) % 256, (y + scy) % 256, bgm end
        local k = (math.floor(my / 8) * 32 + math.floor(mx / 8)) * 5
        local t, p, xf, yf = tilepx(m[k + 1]), m[k + 2], m[k + 3], m[k + 4]
        local tx, ty = mx % 8, my % 8
        if xf == 1 then tx = 7 - tx end
        if yf == 1 then ty = 7 - ty end
        local c = bp[p][t[ty * 8 + tx]]; img:setPixel(x, y, c[1], c[2], c[3], 1)
      end
      if winon then wline = wline + 1 end
      y = y + 1
    end
  end
  if bit(1) then M.oam(img, f) end
  return img
end

return M
