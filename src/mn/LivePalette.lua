-- mn.LivePalette: draw the field through the live palette block.
--
-- RefreshSavedPalettes ($07:4575), the callback every palette op plants,
-- copies $C7AB (8 BG palettes) and $C7EB (8 OBJ palettes) to the hardware.
-- The game has no other fade: a fade is a palette op walking those words.
--
-- BG: the importer writes a palette-index twin of each map image and
-- metatile atlas (MnRom.indexPalettes). The BG shader looks the index up in
-- a 32x1 texture of the live BG words, so per-palette ops ($70 water
-- cycling on palettes 0-2) only touch the pixels that use those palettes.
--
-- OBJ: sprites are built with the default OBJ block ($21:$5CC0), so the OBJ
-- shader maps each of those 32 base colors to the matching live word
-- through a 32x32x32 table. Where two OBJ palettes share a base color with
-- different live colors, the lower palette wins. That only differs from
-- the hardware when an op touches some OBJ palettes and not others.
local bit = require("bit")
local band, rshift = bit.band, bit.rshift

local M = {}
M.__index = M

local C7AB, C7EB = 0xC7AB, 0xC7EB

function M.words(vm, base, n)
  local w = {}
  for k = 0, n - 1 do w[k] = vm:rd8(base + 2 * k) + 256 * vm:rd8(base + 2 * k + 1) end
  return w
end

function M.rgb(w)
  return band(w, 31) / 31, band(rshift(w, 5), 31) / 31, band(rshift(w, 10), 31) / 31
end

-- 15-bit key of an RGB555 word (red low). Matches the shader's key.
function M.key(w) return band(w, 0x7FFF) end

-- base word -> live word, first palette wins (pure; tested headless).
function M.objMap(base, live)
  local m = {}
  for k = 0, 31 do
    local b = M.key(base[k])
    if m[b] == nil then m[b] = live[k] end
  end
  return m
end

local BG_GLSL = [[
uniform Image live;
vec4 effect(vec4 col, Image tex, vec2 tc, vec2 sc) {
  vec4 p = Texel(tex, tc);
  float i = floor(p.r * 255.0 / 8.0);
  vec4 c = Texel(live, vec2((i + 0.5) / 32.0, 0.5));
  return vec4(c.rgb, p.a) * col;
}
]]

local OBJ_GLSL = [[
uniform Image lut;
vec4 effect(vec4 col, Image tex, vec2 tc, vec2 sc) {
  vec4 p = Texel(tex, tc);
  vec3 q = floor(p.rgb * 31.0 + 0.5);
  vec4 c = Texel(lut, vec2((q.r + 32.0 * q.g + 0.5) / 1024.0, (q.b + 0.5) / 32.0));
  return vec4(c.rgb, p.a) * col;
}
]]

function M.new(objBase)
  local s = setmetatable({ objBase = objBase, sig = nil, set = {} }, M)
  s.bgData = love.image.newImageData(32, 1)
  s.bgImage = love.graphics.newImage(s.bgData); s.bgImage:setFilter("nearest", "nearest")
  s.lutData = love.image.newImageData(1024, 32)
  for b = 0, 31 do for gr = 0, 31 do for x = 0, 31 do s.lutData:setPixel(x + 32 * gr, b, x / 31, gr / 31, b / 31, 1) end end end
  s.lutImage = love.graphics.newImage(s.lutData); s.lutImage:setFilter("nearest", "nearest")
  s.bg = love.graphics.newShader(BG_GLSL)
  s.obj = love.graphics.newShader(OBJ_GLSL)
  return s
end

-- Refresh the textures when $C7AB-$C82A changed.
function M:update(vm)
  local t = {}
  for a = C7AB, C7AB + 0x7F do t[#t + 1] = vm:rd8(a) end
  local sig = table.concat(t, ",")
  if sig == self.sig then return end
  self.sig = sig
  local bg = M.words(vm, C7AB, 32)
  for k = 0, 31 do local r, g, b = M.rgb(bg[k]); self.bgData:setPixel(k, 0, r, g, b, 1) end
  self.bgImage:replacePixels(self.bgData)
  for key in pairs(self.set) do
    local r, g, b = M.rgb(key)
    self.lutData:setPixel(band(key, 31) + 32 * band(rshift(key, 5), 31), rshift(key, 10), r, g, b, 1)
  end
  self.set = {}
  for key, w in pairs(M.objMap(self.objBase, M.words(vm, C7EB, 32))) do
    local r, g, b = M.rgb(w)
    self.lutData:setPixel(band(key, 31) + 32 * band(rshift(key, 5), 31), rshift(key, 10), r, g, b, 1)
    self.set[key] = true
  end
  self.lutImage:replacePixels(self.lutData)
  self.bg:send("live", self.bgImage)
  self.obj:send("lut", self.lutImage)
end

return M
