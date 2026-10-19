-- Text window in the map's BG palette 7. SetupWindow fills $9C00 with attr
-- $8F (palette 7, VRAM bank 1) and tile $80; frame tiles are bank 6 $50B0
-- ($80-$85), glyphs are bank 6 $4000 + code*16 (StripGlyphPointer $2BC8),
-- all drawn as opaque BG tiles with that palette.
local Importer = require("mn.MnImporter")
local M = {}
local raw, cache = nil, {}

local function sheet(pal)
  local key = table.concat({ pal[0][1], pal[0][2], pal[0][3], pal[1][1], pal[2][1], pal[3][1], pal[3][3] }, ",")
  if cache[key] then return cache[key] end
  raw = raw or love.filesystem.read(Importer.CACHE .. "/window.bin")
  local img = love.image.newImageData(8 * 262, 8)
  for t = 0, 261 do for p = 0, 63 do
    local c = pal[raw:byte(t * 64 + p + 1)]
    img:setPixel(t * 8 + p % 8, math.floor(p / 8), c[1], c[2], c[3], 1)
  end end
  local im = love.graphics.newImage(img); im:setFilter("nearest", "nearest")
  local q = {}
  for t = 0, 261 do q[t] = love.graphics.newQuad(t * 8, 0, 8, 8, 8 * 262, 8) end
  cache[key] = { im = im, q = q }
  return cache[key]
end

local DEFAULT = { [0] = { 1, 1, 1 }, { 0.75, 0.75, 0.75 }, { 0.4, 0.4, 0.4 }, { 0, 0, 0 } }

-- plain glyph run (battle window: no frame, text at col 5)
function M.drawText(str, x, y, pal)
  local s = sheet(pal or DEFAULT)
  for i = 1, #str do love.graphics.draw(s.im, s.q[str:byte(i)], x + (i - 1) * 8, y) end
end

function M.drawBox(str, pal)
  local s = sheet(pal or DEFAULT)
  local F = 256 -- frame tiles start after the 256 glyphs
  for ty = 0, 4 do for tx = 0, 19 do
    local t, sx, ox = F + 0, 1, 0
    if ty == 0 then
      if tx == 0 then t = F + 5 elseif tx == 19 then t, sx, ox = F + 5, -1, 8 else t = F + 3 end
    end
    love.graphics.draw(s.im, s.q[t], tx * 8 + ox, 104 + ty * 8, 0, sx, 1)
  end end
  local cx, cy = 8, 112
  for i = 1, #str do
    local c = str:byte(i)
    if c == 10 then cx, cy = 8, cy + 8 else love.graphics.draw(s.im, s.q[c], cx, cy); cx = cx + 8 end
  end
end
-- Typewriter box, timed against PyBoy: one glyph every 2 frames on window
-- rows 1 and 3 (y 112 / 128); <LINE> moves to row 3 or scrolls, <WAIT>
-- blinks a cursor (15-frame period) until A, then scrolls row 3 up to row 1.
-- A portrait (5x5 tiles, bank 8, $9B word - 8, BG palette 7) fills cols 0-4.
function M.newBox(portrait)
  return { lines = { "", "" }, cur = 1, q = "", i = 1, t = 0, wait = false, done = true, portrait = portrait, blink = 0 }
end

function M.append(b, tokens) b.q = b.q:sub(b.i) .. tokens; b.i = 1; b.done = false end

local function scroll(b) b.lines[1], b.lines[2], b.cur = b.lines[2], "", 2 end

function M.update(b, a)
  if b.wait then
    b.blink = b.blink + 1
    if a then b.wait = false; scroll(b) end
    return
  end
  if b.done then return end
  b.t = b.t + 1
  if b.t < 2 then return end
  b.t = 0
  while true do
    local c = b.q:sub(b.i, b.i); b.i = b.i + 1
    if c == "" then b.done = true; return end
    if c == "\n" then
      if b.cur == 1 and b.lines[1] ~= "" then b.cur = 2 elseif b.cur == 2 then scroll(b) end
    elseif c == "\f" then b.wait = true; b.blink = 0; return
    else b.lines[b.cur] = b.lines[b.cur] .. c; return end
  end
end

-- portrait ImageData cache keyed by word
local portraits = {}
local function portraitImage(rom, word, pal)
  local key = word .. ":" .. pal[0][1] .. pal[3][1]
  if portraits[key] then return portraits[key] end
  local img = love.image.newImageData(40, 40)
  -- 22C4: low nibble of the word is the ROM bank, the rest the tile pointer
  local o = (word % 16) * 0x4000 + (word - word % 16) - 0x4000
  for t = 0, 24 do
    for y = 0, 7 do
      local lo, hi = rom:u8(o + t * 16 + y * 2), rom:u8(o + t * 16 + y * 2 + 1)
      for x = 0, 7 do
        local sh = 7 - x
        local ci = (math.floor(lo / 2 ^ sh) % 2) + 2 * (math.floor(hi / 2 ^ sh) % 2)
        local c = pal[ci]
        img:setPixel((t % 5) * 8 + x, math.floor(t / 5) * 8 + y, c[1], c[2], c[3], 1)
      end
    end
  end
  local im = love.graphics.newImage(img); im:setFilter("nearest", "nearest")
  portraits[key] = im
  return im
end

-- Choice menu ($9C): option i sits at the i-th leading space of the strip's lines
-- (" Yes/ No", " Forge  Equip/ Power  Done"), row-major; the cursor starts on 1.
function M.choice(b, n)
  local pos = {}
  for r = 1, 2 do
    local line = b.lines[r] or ""
    for i = 1, #line do
      if line:sub(i, i) == " " and line:sub(i + 1, i + 1):match("%S") and (i == 1 or line:sub(i - 1, i - 1) == " ") then
        pos[#pos + 1] = { r, i - 1 }
      end
    end
  end
  for i = #pos + 1, n do pos[i] = { 1 + (i - 1) % 2, 0 } end
  b.choice = { n = n, cur = 1, pos = pos }
  return b.choice
end

-- up/down step through the rows, left/right through the columns (row-major order)
function M.choiceMove(c, dir)
  local cols = math.max(1, math.ceil(c.n / 2))
  local r, col = math.floor((c.cur - 1) / cols), (c.cur - 1) % cols
  if dir == "up" or dir == "down" then r = 1 - r elseif dir == "left" then col = math.max(0, col - 1) elseif dir == "right" then col = math.min(cols - 1, col + 1) end
  local k = r * cols + col + 1
  if k <= c.n then c.cur = k end
end

local hands = {}
function M.hand(pal)
  local key = pal[0][1] .. "," .. pal[3][1] .. "," .. pal[3][2]
  if hands[key] then return hands[key] end
  local bin = love.filesystem.read(Importer.CACHE .. "/battle.bin") -- banks $43+; tile at $43:5B1C
  local img = love.image.newImageData(8, 8)
  for y = 0, 7 do
    local lo, hi = bin:byte(0x1B1C + y * 2 + 1), bin:byte(0x1B1C + y * 2 + 2)
    for x = 0, 7 do
      local sh = 7 - x
      local c = pal[(math.floor(lo / 2 ^ sh) % 2) + 2 * (math.floor(hi / 2 ^ sh) % 2)]
      img:setPixel(x, y, c[1], c[2], c[3], 1)
    end
  end
  hands[key] = love.graphics.newImage(img); hands[key]:setFilter("nearest", "nearest")
  return hands[key]
end

function M.drawTyped(b, pal, rom)
  pal = pal or DEFAULT
  local s = sheet(pal)
  local F = 256
  for ty = 0, 4 do for tx = 0, 19 do
    local t, sx, ox = F + 0, 1, 0
    if ty == 0 then
      if tx == 0 then t = F + 5 elseif tx == 19 then t, sx, ox = F + 5, -1, 8 else t = F + 3 end
    end
    love.graphics.draw(s.im, s.q[t], tx * 8 + ox, 104 + ty * 8, 0, sx, 1)
  end end
  -- text always starts at window column 5 (PyBoy $9C00 rows 1/3), portrait or not
  local x0 = 40
  if b.portrait and rom then love.graphics.draw(portraitImage(rom, b.portrait, pal), 0, 104) end
  for r = 1, 2 do
    local line, cx = b.lines[r], x0
    for i = 1, #line do love.graphics.draw(s.im, s.q[line:byte(i)], cx, 104 + 8 + (r - 1) * 16); cx = cx + 8 end
  end
  if b.choice then -- $9C menu: hand tile on the option's leading space (PyBoy $9C00, tile at $43:5B1C)
    local o = b.choice.pos[b.choice.cur]
    if o then love.graphics.draw(M.hand(pal), x0 + o[2] * 8, 104 + 8 + (o[1] - 1) * 16) end
  end
  if b.wait and math.floor(b.blink / 15) % 2 == 0 then -- cursor: down-arrow glyph at the row end
    love.graphics.draw(s.im, s.q[0x3E], 152, 128)
  end
end

return M
