-- First-boot importer for Magi-Nation, following gen1recomp's RomImporter
-- contract: validate the ROM's SHA-1, decode into a private cache in the LOVE
-- save dir, release the ROM. Gameplay reads only the cache.
local MnRom = require("mn.MnRom")
local M = {}

M.SHA1 = "9972a7bca43210b4b6c0b3f6ee5d1957a865e12d" -- Magi-Nation (USA) GBC
M.CACHE = "mn_cache"
M.VERSION = 13

local function ser(v, ind)
  ind = ind or ""
  local t = type(v)
  if t == "number" or t == "boolean" then return tostring(v) end
  if t == "string" then return string.format("%q", v) end
  local parts, ni = {}, ind .. " "
  local n = #v
  for i = 1, n do parts[#parts + 1] = ser(v[i], ni) end
  local keys = {}
  for k in pairs(v) do if not (type(k) == "number" and k >= 1 and k <= n and k % 1 == 0) then keys[#keys + 1] = k end end
  table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
  for _, k in ipairs(keys) do
    local ks = type(k) == "string" and k:match("^[%a_][%w_]*$") and k or ("[" .. ser(k) .. "]")
    parts[#parts + 1] = ks .. "=" .. ser(v[k], ni)
  end
  return "{" .. table.concat(parts, ",") .. "}"
end
M.serialize = ser

function M.isCached()
  local s = love.filesystem.read(M.CACHE .. "/manifest.lua")
  if not s then return false end
  local ok, m = pcall(function() return assert(loadstring(s))() end)
  return ok and m.sha1 == M.SHA1 and m.version == M.VERSION
end

-- bytes: ROM contents. Returns true or nil, error.

-- Player walker: QueueSpriteList records (Y, X, tile, attr; $80 ends) in bank
-- $20 at $44AC-$4523, driven by the sprite-animation scripts below
-- (sprite_anim_bank20.asm). $4C QueueRepeatedSpriteList records are
-- (frames, dy, dx, list ptr), $00 ends. Tiles: OBJ VRAM bank 1 at $8000 as
-- loaded by the map-source VRAM records; palettes: the $66 block at $21:$5CC0.
-- the overworld walker the real game runs (slot 0 bytes 10-12 read in PyBoy while walking):
-- $4D 4-frame tables of 3-row lists (legs/body/head, 24 px), idles are single $4C records
M.PLAYER_ANIMS = { down = 0x4FCD, up = 0x4FB3, right = 0x4FED, left = 0x4FDD,
  idle_down = 0x50B3, idle_up = 0x50A9, idle_right = 0x50C5, idle_left = 0x50BD }

local function exportPlayer(rom)
  local bit = require("bit")
  local vbanks = rom:vram(rom:mapSources(0)[1])
  -- Tony's walker tiles: OBJ VRAM bank 1 $8000-$87FF is ROM $60:$7000 verbatim in the
  -- real game (PyBoy compare); map 0's source records stop short of the leg row ($44/$45)
  do local so = MnRom.off(0x7000, 0x60); for k = 0, 0x7FF do vbanks[1][k] = rom:u8(so + k) end end
  local po = MnRom.off(0x5CC0, 0x21); local pals = {}
  for p = 0, 7 do pals[p] = {} for c = 0, 3 do
    local w = rom:u16(po + 2 * (p * 4 + c))
    pals[p][c] = { bit.band(w, 31) / 31, bit.band(bit.rshift(w, 5), 31) / 31, bit.band(bit.rshift(w, 10), 31) / 31 }
  end end
  local lists, order = {}, {}
  local function addList(ptr)
    if lists[ptr] then return lists[ptr] end
    order[#order + 1] = ptr; lists[ptr] = #order; return #order
  end
  local anims = {}
  for name, a in pairs(M.PLAYER_ANIMS) do
    local o = MnRom.off(a, 0x20); local seq = {}
    local op = rom:u8(o)
    if op == 0x4C then
      local q = o + 1
      while rom:u8(q) ~= 0 do
        seq[#seq + 1] = { n = rom:u8(q), dy = rom:u8(q + 1), dx = rom:u8(q + 2), f = addList(rom:u16(q + 3)) }
        q = q + 5
      end
    elseif op == 0x4D then -- table size, count(frames per entry), two bytes, pointers
      local sz, cnt = rom:u8(o + 1), rom:u8(o + 2)
      for k = 0, sz / 2 - 1 do seq[#seq + 1] = { n = cnt, dy = 0, dx = 0, f = addList(rom:u16(o + 5 + 2 * k)) } end
    end
    anims[name] = seq
  end
  local img = love.image.newImageData(32 * #order, 32) -- 32x32 cells, origin (16,16): OAM lists reach 24 px tall
  for i, ptr in ipairs(order) do
    local q = MnRom.off(ptr, 0x20)
    while rom:u8(q) ~= 0x80 do
      local y, x, t, at = rom:u8(q), rom:u8(q + 1), rom:u8(q + 2), rom:u8(q + 3)
      if y >= 128 then y = y - 256 end; if x >= 128 then x = x - 256 end
      local pal = pals[bit.band(at, 7)]; local vram = vbanks[bit.band(at, 8) ~= 0 and 1 or 0] -- attr bit 3 = VRAM bank
      for ty = 0, 7 do
        local sy = bit.band(at, 0x40) ~= 0 and 7 - ty or ty
        local lo, hi = vram[t * 16 + sy * 2], vram[t * 16 + sy * 2 + 1]
        for tx = 0, 7 do
          local sx = bit.band(at, 0x20) ~= 0 and tx or 7 - tx
          local ci = bit.band(bit.rshift(lo, sx), 1) + 2 * bit.band(bit.rshift(hi, sx), 1)
          local px, py = (i - 1) * 32 + 16 + x + tx, 16 + y + ty
          if ci ~= 0 and px >= (i - 1) * 32 and px < i * 32 and py >= 0 and py < 32 then
            local c = pal[ci]; img:setPixel(px, py, c[1], c[2], c[3], 1)
          end
        end
      end
      q = q + 4
    end
  end
  love.filesystem.write(M.CACHE .. "/player.png", img:encode("png"))
  love.filesystem.write(M.CACHE .. "/player.lua", "return " .. ser({ frames = #order, anims = anims }))
  -- banks $00-$3C: script VM ($00-$30) + sound driver/song data ($30-$3C)
  love.filesystem.write(M.CACHE .. "/scripts.bin", rom.s:sub(1, 0x3D * 0x4000))
  -- battle screen tiles: every 8x8 tile the captured layout references (banks $00-$45)
  love.filesystem.write(M.CACHE .. "/battle.bin", rom.s:sub(1, 0x46 * 0x4000):sub(0x43 * 0x4000 + 1))
  love.filesystem.write(M.CACHE .. "/battle_lo.bin", rom.s:sub(1, 0x0E * 0x4000))
  -- battle scenes (src/mn/data_battle_scenes.lua) reference tiles anywhere in the ROM
  love.filesystem.write(M.CACHE .. "/rom.bin", rom.s)
end
M.exportPlayer = exportPlayer

function M.import(bytes, log)
  log = log or function() end
  local sha = love.data.encode("string", "hex", love.data.hash("sha1", bytes))
  if sha ~= M.SHA1 then return nil, "ROM SHA-1 mismatch: " .. sha end
  local rom = MnRom.new(bytes)
  love.filesystem.createDirectory(M.CACHE .. "/maps")

  local entries = rom:findEntries()
  local entryAt, byMap = {}, {}
  for _, e in ipairs(entries) do
    entryAt[e.bank * 65536 + e.ptr] = e
    byMap[e.map] = byMap[e.map] or {}
    table.insert(byMap[e.map], { bank = e.bank, ptr = e.ptr, list = e.list, spawn = e.spawn })
  end
  log(("%d map-entry scripts"):format(#entries))

  local index = {}
  for i = 0, MnRom.MAP_COUNT - 1 do
    local m = rom:loadMap(i)
    local W, H = m.map.w, m.map.h
    local img = love.image.newImageData(W * 16, H * 16)
    MnRom.render(m, function(x, y, r, g, b) img:setPixel(x, y, r, g, b, 1) end)
    love.filesystem.write(("%s/maps/%03d.png"):format(M.CACHE, i), img:encode("png"))
    -- OBJ tile memory $8000-$8FFF, VRAM banks 0 and 1, for NPC sprites
    local ob = {}
    for vb = 0, 1 do for k = 0, 0xFFF do ob[#ob + 1] = string.char(m.vram[vb][k]) end end
    love.filesystem.write(("%s/maps/%03d.obj"):format(M.CACHE, i), table.concat(ob))
    -- metatile atlas (16x16 grid of 16px metatiles) for runtime cell rewrites
    local at = love.image.newImageData(256, 256)
    local fake = { map = { w = 16, h = 16, cells = {} }, meta = m.meta, palettes = m.palettes, vram = m.vram }
    for k = 0, 255 do fake.map.cells[k + 1] = k end
    MnRom.render(fake, function(x, y, r, g, b) at:setPixel(x, y, r, g, b, 1) end)
    love.filesystem.write(("%s/maps/%03d_meta.png"):format(M.CACHE, i), at:encode("png"))
    -- trigger list: first entry script for this map that sets one
    local triggers, listPtr = {}, nil
    for _, e in ipairs(byMap[i] or {}) do if e.list then listPtr = e.list; break end end
    if listPtr then
      local t, c = rom:triggerList(listPtr)
      for k = 0, c - 1 do
        local w = rom:resolveWarp(t[k].bank, t[k].ptr, entryAt)
        triggers[k + 1] = { kind = t[k].kind, script = ("%02X:%04X"):format(t[k].bank, t[k].ptr),
          to = w and w.map or -1, rebase = w and w.rebase or nil,
          spawn = w and w.entry and w.entry.spawn or nil }
      end
    end
    local def = { index = i, w = W, h = H, pal7 = m.palettes[7], camCol = m.map.cameraCols, camRow = m.map.cameraRows, cells = m.map.cells, block = m.block.cells,
      triggerList = listPtr, triggers = triggers, entries = byMap[i] or {} }
    love.filesystem.write(("%s/maps/%03d.lua"):format(M.CACHE, i), "return " .. ser(def))
    index[#index + 1] = { i = i, w = W, h = H, n = #triggers }
  end
  exportPlayer(rom)
  -- font: bank 6 $4000, glyph = code * 16 (StripGlyphPointer $2BC8)
  local fimg = love.image.newImageData(128, 128)
  local shade = { [0] = { 0.97, 0.97, 0.94, 0 }, { 0.75, 0.75, 0.7, 0 }, { 0.45, 0.45, 0.5, 1 }, { 0.1, 0.1, 0.2, 1 } }
  for c = 0, 255 do for ty = 0, 7 do
    local lo, hi = rom:u8(6 * 0x4000 + c * 16 + ty * 2), rom:u8(6 * 0x4000 + c * 16 + ty * 2 + 1)
    for tx = 0, 7 do
      local ci = math.floor(lo / 2 ^ (7 - tx)) % 2 + 2 * (math.floor(hi / 2 ^ (7 - tx)) % 2)
      local col = shade[ci]; fimg:setPixel((c % 16) * 8 + tx, math.floor(c / 16) * 8 + ty, col[1], col[2], col[3], col[4])
    end
  end end
  love.filesystem.write(M.CACHE .. "/font.png", fimg:encode("png"))
  local fr = love.image.newImageData(48, 8)
  local paper = { [0] = { 0.97, 0.96, 0.9 }, { 0.82, 0.8, 0.72 }, { 0.5, 0.48, 0.45 }, { 0.12, 0.12, 0.2 } }
  for t = 0, 5 do for ty = 0, 7 do
    local o = MnRom.off(0x50B0 + t * 16 + ty * 2, 6); local lo, hi = rom:u8(o), rom:u8(o + 1)
    for tx = 0, 7 do
      local ci = math.floor(lo / 2 ^ (7 - tx)) % 2 + 2 * (math.floor(hi / 2 ^ (7 - tx)) % 2)
      local c = paper[ci]; fr:setPixel(t * 8 + tx, ty, c[1], c[2], c[3], 1)
    end
  end end
  love.filesystem.write(M.CACHE .. "/frame.png", fr:encode("png"))
  -- 2bpp indices for runtime palette-7 colouring: 256 font glyphs then 6 frame tiles
  local idx = {}
  local function tileIdx(o)
    for ty = 0, 7 do
      local lo, hi = rom:u8(o + ty * 2), rom:u8(o + ty * 2 + 1)
      for tx = 0, 7 do idx[#idx + 1] = string.char(math.floor(lo / 2 ^ (7 - tx)) % 2 + 2 * (math.floor(hi / 2 ^ (7 - tx)) % 2)) end
    end
  end
  for c = 0, 255 do tileIdx(6 * 0x4000 + c * 16) end
  for t = 0, 5 do tileIdx(MnRom.off(0x50B0 + t * 16, 6)) end
  love.filesystem.write(M.CACHE .. "/window.bin", table.concat(idx))
  -- item records: bank 7 $5E0B, $22 bytes each, 13-byte name (first byte an
  -- icon glyph); the max-count byte read by bank 7 $6865 sits 6 bytes before.
  local items = {}
  for id = 1, 120 do
    local o = MnRom.off(0x5E0B + id * 0x22, 7)
    local nm = rom.s:sub(o + 2, o + 13):gsub("%s+$", "")
    if nm ~= "" and not nm:find("[%z\1-\31\127-\255]") then items[id] = { name = nm, max = rom:u8(o - 6) } end
  end
  love.filesystem.write(M.CACHE .. "/items.lua", "return " .. ser(items))
  love.filesystem.write(M.CACHE .. "/manifest.lua",
    "return " .. ser({ sha1 = sha, version = M.VERSION, maps = index }))
  log("cache written")
  return true
end

function M.loadMap(i)
  local def = assert(loadstring(assert(love.filesystem.read(("%s/maps/%03d.lua"):format(M.CACHE, i)))))()
  def.image = love.graphics and love.graphics.newImage and
    love.graphics.newImage(("%s/maps/%03d.png"):format(M.CACHE, i)) or nil
  if def.image then def.image:setFilter("nearest", "nearest") end
  return def
end

function M.scriptRom()
  local s = assert(love.filesystem.read(M.CACHE .. "/scripts.bin"))
  return setmetatable({ s = s }, MnRom)
end

return M
