-- Header and footer banners for the 3D arena.
--
-- In 2D the fight scenes split the screen into three bands while an attack plays: a header
-- strip (a vine canopy) across the top, the fighters in the middle, and a footer strip (grass
-- and ferns) across the bottom, the two strips scrolling sideways at their own speeds. The
-- art is not shipped: it comes from the private scene cache (mn_cache/battle_scenes.lua, made
-- by mn.fx.Gen running the game's own code on the player's ROM). Here the two strips are cut
-- out of the cached background map and used as a canopy overhead and grass on the floor.
--
-- B.find(frames) is pure (no LOVE): it reads the per-line scroll runs of a cached scene and
-- returns where the strips sit in the map and how far each one is scrolled on every frame.
-- B.build(Ppu) makes the LOVE images; it returns nil when there is no cache.
local B = {}

-- fight scenes in the cache, the first one present is used (MN_B3D_BANNER_SCENE picks one)
B.SCENES = { "fight_weebo_tony", "fight_weebo_furok", "fight_furok_weebo" }

-- a three-band frame: header run from screen line 0, the middle, footer run to line 143
local function bands(f)
  local r = f.lines
  if #r ~= 3 or r[1][1] < 8 or r[3][1] < 8 then return nil end
  return r[1], r[3], r[1][1] + r[2][1]
end

function B.find(frames)
  if type(frames) ~= "table" then return nil end
  local first
  for i, f in ipairs(frames) do
    if bands(f) then first = i; break end
  end
  if not first then return nil end
  local hr, fr, fline = bands(frames[first])
  local out = {
    frame = first,
    header = { y = hr[3] % 256, h = hr[1] },
    footer = { y = (fline + fr[3]) % 256, h = fr[1] },
    scroll = {},
  }
  -- per frame scroll of each strip in map pixels (nil while the strip is not up)
  for i, f in ipairs(frames) do
    local h, ft = bands(f)
    out.scroll[i] = h and { h = h[2], f = ft[2] } or {}
  end
  return out
end

-- scroll of the strips p (0..1) of the way through the scene, in texture widths
function B.scrollAt(info, p)
  local n = #info.scroll
  local i = math.max(1, math.min(n, 1 + math.floor(p * (n - 1) + 0.5)))
  -- hold the last frame that had the strips up (the scene ends on a flash without them)
  while i > 1 and info.scroll[i].h == nil do i = i - 1 end
  local s = info.scroll[i]
  return (s.h or 0) / 256, (s.f or 0) / 256, s.h ~= nil
end

function B.build(Ppu, sceneName)
  local list = sceneName and { sceneName } or B.SCENES
  for _, name in ipairs(list) do
    local frames = Ppu.scene(name)
    local info = B.find(frames)
    if info then
      local f = frames[info.frame]
      local function img(band)
        local t = love.graphics.newImage(Ppu.band(f, band.y, band.h, true))
        t:setFilter("nearest", "nearest"); t:setWrap("repeat", "clamp")
        return t
      end
      info.scene = name
      info.headerTex, info.footerTex = img(info.header), img(info.footer)
      return info
    end
  end
  return nil
end

return B
