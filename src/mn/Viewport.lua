-- Viewport math for the MN port: window size -> logical canvas size, scale and
-- letterbox offsets, plus the wide render camera. Pure Lua (no love calls) so
-- tests/engine/mn_viewport_test.lua can check it headless.
--
-- Zoom 0 is the classic 160x144 frame, letterboxed at the largest integer
-- scale. Zoom 1..3 keep pixel-perfect integer scales but grow the logical
-- canvas to fill the window: zoom 1 uses the classic scale (fill the bars with
-- more world), zoom 2 about 3/4 of it, zoom 3 about 1/2. With pixel = false
-- (or a window smaller than 160x144) the scale may be fractional.
--
-- Game logic never sees any of this: the classic camera (Overworld:cameraXY,
-- the $84/$7C/$16 camera opcodes) stays 160x144 and the wide camera is derived
-- from it, so triggers, scripts and route-harness frames do not change.

local V = {}

V.CW, V.CH = 160, 144     -- classic Game Boy frame
V.MAX_W, V.MAX_H = 640, 864 -- 40 x 54 metatiles: past this the canvas letterboxes
V.ZOOMS = 3               -- zoom levels above classic
V.ZOOM_NAMES = { [0] = "classic", "fill", "wide", "wider" }
local FACTOR = { [1] = 1, [2] = 0.75, [3] = 0.5 }

local floor, max, min = math.floor, math.max, math.min

-- ww, wh: drawable window size in device pixels.
-- o.zoom (0..3, default 0), o.pixel (default true).
-- Returns { w, h, scale, ox, oy, ux, uy, zoom, integer }:
--   w, h    logical canvas size (>= 160x144)
--   scale   canvas -> window scale
--   ox, oy  where the scaled canvas's top-left sits in the window
--   ux, uy  where the classic 160x144 UI frame sits inside the canvas
function V.compute(ww, wh, o)
  o = o or {}
  ww, wh = max(1, floor(ww or V.CW)), max(1, floor(wh or V.CH))
  local zoom = max(0, min(V.ZOOMS, floor(o.zoom or 0)))
  local pixel = o.pixel ~= false
  local fit = min(ww / V.CW, wh / V.CH)
  local base = floor(fit)
  local w, h, scale = V.CW, V.CH, nil
  local integer = pixel and base >= 1
  if zoom == 0 then
    scale = integer and base or fit
  else
    if integer then scale = max(1, floor(base * FACTOR[zoom]))
    else scale = fit * FACTOR[zoom]; if scale * V.CW > ww or scale * V.CH > wh then scale = fit end end
    -- logical size: as many pixels as fit at this scale, even so the classic
    -- frame centres on a whole pixel, never below classic, capped
    w = min(V.MAX_W, max(V.CW, floor(ww / scale / 2) * 2))
    h = min(V.MAX_H, max(V.CH, floor(wh / scale / 2) * 2))
  end
  return {
    w = w, h = h, scale = scale, zoom = zoom, integer = integer,
    ox = floor((ww - w * scale) / 2), oy = floor((wh - h * scale) / 2),
    ux = floor((w - V.CW) / 2), uy = floor((h - V.CH) / 2),
  }
end

-- One axis of the wide camera. c: the classic camera's left (or top) edge in
-- map pixels (may be negative for maps smaller than the screen), span: the
-- map's width (height) in pixels, vw: logical view size, cw: classic size.
-- Centres the view on the classic frame, keeps it inside the map when the map
-- is big enough, and always keeps the whole classic frame in view. With
-- vw == cw it returns c unchanged, so the classic path is pixel-identical.
function V.wideAxis(c, span, vw, cw)
  cw = cw or V.CW
  if vw <= cw then return c end
  local L
  if span >= vw then L = max(0, min(span - vw, c + cw / 2 - vw / 2))
  else L = (span - vw) / 2 end
  L = max(c + cw - vw, min(c, L))
  return floor(L)
end

function V.wideCamera(cx, cy, mapW, mapH, vw, vh)
  return V.wideAxis(cx, mapW, vw, V.CW), V.wideAxis(cy, mapH, vh, V.CH)
end

-- A sprite at map-pixel rect (x, y, w, h) is "offstage" when it misses both
-- the map (mapW x mapH) and the classic frame at (cx, cy): classic play could
-- never show it, so the wide view hides it too.
function V.offstage(x, y, w, h, mapW, mapH, cx, cy)
  local function hit(ax, ay, aw, ah) return x < ax + aw and x + w > ax and y < ay + ah and y + h > ay end
  return not hit(0, 0, mapW, mapH) and not hit(cx, cy, V.CW, V.CH)
end

-- Parse "WxH" (MN_VIEW_SIM) -> w, h or nil.
function V.parseSize(s)
  if type(s) ~= "string" then return nil end
  local w, h = s:match("^%s*(%d+)%s*[xX,]%s*(%d+)%s*$")
  if not w then return nil end
  return tonumber(w), tonumber(h)
end

-- Settings from env (MN_VIEW_ZOOM, MN_VIEW_PIXEL) over a saved "k=v" config.
function V.settings(getenv, saved)
  getenv = getenv or os.getenv
  local cfg = { zoom = 1, pixel = true }
  if type(saved) == "string" then
    local z = saved:match("zoom=(%d)"); if z then cfg.zoom = tonumber(z) end
    local p = saved:match("pixel=(%d)"); if p then cfg.pixel = p ~= "0" end
  end
  local ez = tonumber(getenv("MN_VIEW_ZOOM") or "")
  if ez then cfg.zoom = ez end
  local ep = getenv("MN_VIEW_PIXEL")
  if ep then cfg.pixel = ep ~= "0" end
  cfg.zoom = max(0, min(V.ZOOMS, floor(cfg.zoom)))
  return cfg
end

function V.serialize(cfg)
  return ("zoom=%d\npixel=%d\n"):format(cfg.zoom, cfg.pixel and 1 or 0)
end

return V
