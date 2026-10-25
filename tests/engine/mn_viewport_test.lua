-- Viewport math (mn.Viewport) and edge fill (mn.EdgeFill). Synthetic data only.
--   luajit tests/engine/mn_viewport_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end
local function eq(a, b, what) ok(a == b, ("%s: got %s want %s"):format(what, tostring(a), tostring(b))) end

local V = require("mn.Viewport")
local EF = require("mn.EdgeFill")

-- classic: largest integer scale, letterboxed, UI frame at the origin
do
  local v = V.compute(640, 576, { zoom = 0 })
  eq(v.w, 160, "classic w"); eq(v.h, 144, "classic h"); eq(v.scale, 4, "classic x4")
  eq(v.ox, 0, "classic ox"); eq(v.oy, 0, "classic oy"); eq(v.ux, 0, "classic ux"); eq(v.uy, 0, "classic uy")
  v = V.compute(1024, 742, { zoom = 0 })
  eq(v.scale, 5, "desktop scale"); eq(v.ox, 112, "desktop ox"); eq(v.oy, 11, "desktop oy")
  ok(v.integer, "desktop integer")
  -- a window smaller than 160x144 falls back to a fractional scale
  v = V.compute(120, 108, { zoom = 0 })
  eq(v.scale, 0.75, "tiny fractional"); ok(not v.integer, "tiny not integer")
  -- pixel-perfect off fills the short axis exactly
  v = V.compute(1000, 900, { zoom = 0, pixel = false })
  eq(v.scale, 6.25, "fractional fit")
end

-- Galaxy Z Fold7 panels in portrait (Samsung: cover 2520x1080, main 2184x1968)
do
  local folded = V.compute(1080, 2520, { zoom = 0 })
  eq(folded.scale, 6, "folded classic scale"); eq(folded.ox, 60, "folded ox")
  local f1 = V.compute(1080, 2520, { zoom = 1 })
  eq(f1.scale, 6, "folded fill scale"); eq(f1.w, 180, "folded fill w"); eq(f1.h, 420, "folded fill h")
  eq(f1.ux, 10, "folded ux"); eq(f1.uy, 138, "folded uy")
  local f2 = V.compute(1080, 2520, { zoom = 2 })
  eq(f2.scale, 4, "folded wide scale"); eq(f2.w, 270, "folded wide w"); eq(f2.h, 630, "folded wide h")
  local f3 = V.compute(1080, 2520, { zoom = 3 })
  eq(f3.scale, 3, "folded wider scale"); eq(f3.w, 360, "folded wider w"); eq(f3.h, 840, "folded wider h")
  local cap = V.compute(400, 3000, { zoom = 3 })
  eq(cap.h, V.MAX_H, "tall view capped"); ok(cap.oy > 0, "capped view letterboxes")
  local u0 = V.compute(1968, 2184, { zoom = 0 })
  eq(u0.scale, 12, "unfolded classic scale")
  local u2 = V.compute(1968, 2184, { zoom = 2 })
  eq(u2.scale, 9, "unfolded wide scale"); eq(u2.w, 218, "unfolded wide w"); eq(u2.h, 242, "unfolded wide h")
  local u3 = V.compute(2184, 1968, { zoom = 3 })
  eq(u3.scale, 6, "unfolded landscape wider scale"); eq(u3.w, 364, "landscape w"); eq(u3.h, 328, "landscape h")
end

-- invariants over many window sizes and zooms
do
  local bad = 0
  for ww = 100, 2600, 37 do for wh = 90, 2600, 41 do for z = 0, 3 do for _, px in ipairs({ true, false }) do
    local v = V.compute(ww, wh, { zoom = z, pixel = px })
    if v.w < 160 or v.h < 144 or v.w > V.MAX_W or v.h > V.MAX_H then bad = bad + 1 end
    if v.w * v.scale > ww + 1e-6 and ww >= 160 then bad = bad + 1 end
    if v.h * v.scale > wh + 1e-6 and wh >= 144 then bad = bad + 1 end
    if v.integer and v.scale ~= math.floor(v.scale) then bad = bad + 1 end
    if z == 0 and (v.w ~= 160 or v.h ~= 144) then bad = bad + 1 end
    if v.w % 2 ~= 0 and v.w ~= 160 then bad = bad + 1 end
  end end end end
  eq(bad, 0, "viewport invariants")
end

-- wide camera: identity when classic, contains the classic frame, stays in the map
do
  eq(V.wideAxis(37, 640, 160), 37, "classic identity")
  eq(V.wideAxis(-8, 144, 160), -8, "small map identity")
  local bad = 0
  for span = 64, 800, 16 do for vw = 160, 640, 2 do
    for c = (span < 160) and math.floor((span - 160) / 2) or 0, math.max(0, span - 160) do
      local L = V.wideAxis(c, span, vw, 160)
      if L > c or L + vw < c + 160 then bad = bad + 1 end -- classic frame inside the view
      if span >= vw and (L < 0 or L + vw > span) then bad = bad + 1 end -- no out-of-map when it fits
      if L ~= math.floor(L) then bad = bad + 1 end
    end
  end end
  eq(bad, 0, "wide camera invariants")
  -- centred on the player's classic frame in the middle of a big map
  eq(V.wideAxis(200, 1000, 260), 150, "centred")
  -- clamped at the map's left edge
  eq(V.wideAxis(0, 1000, 260), 0, "left clamp")
  local cx, cy = V.wideCamera(0, 0, 320, 288, 180, 420)
  eq(cx, 0, "wideCamera x"); eq(cy, -66, "tall view centres a short map")
end

do
  ok(not V.offstage(10, 10, 32, 32, 320, 288, 0, 0), "on-map sprite shows")
  ok(V.offstage(-200, 400, 32, 32, 320, 288, 0, 0), "parked sprite hidden")
  ok(not V.offstage(-20, 10, 32, 32, 320, 288, 0, 0), "sprite straddling the edge shows")
  ok(not V.offstage(-40, 10, 32, 32, 100, 100, -30, -22), "sprite in the classic frame shows")
end

do
  eq(V.parseSize("1080x2520"), 1080, "parse w"); eq(select(2, V.parseSize("2184X1968")), 1968, "parse h")
  ok(V.parseSize("big") == nil, "parse junk")
  local env = { MN_VIEW_ZOOM = "2" }
  local cfg = V.settings(function(k) return env[k] end, "zoom=3\npixel=0\n")
  eq(cfg.zoom, 2, "env zoom wins"); eq(cfg.pixel, false, "saved pixel")
  cfg = V.settings(function() return nil end, nil)
  eq(cfg.zoom, 1, "default zoom"); eq(cfg.pixel, true, "default pixel")
  eq(V.serialize({ zoom = 3, pixel = false }), "zoom=3\npixel=0\n", "serialize")
end

-- edge fill on a synthetic 8x4 map: a 2x2 tree pattern (10 11 / 20 21) on
-- every border, grass (1) inside, one house tile (99) on the north edge
do
  local W, H = 8, 4
  local cells = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    cells[y * W + x + 1] = ((y % 2 == 0) and 10 or 20) + (x % 2)
  end end
  cells[1 * W + 2 + 1], cells[1 * W + 3 + 1] = 1, 1
  cells[0 * W + 4 + 1] = 99
  local def = { w = W, h = H, cells = cells }
  local f, mode = EF.build(def)
  eq(mode, "block", "default mode")
  eq(f(-1, 0), 11, "west continues the tree pattern"); eq(f(-2, 1), 20, "west row 1")
  eq(f(4, -1), 20, "north skips the house"); eq(f(5, -2), 11, "north row -2")
  eq(f(-1, -1), 21, "corner"); eq(f(2, 1), 1, "inside is the map")
  local fe = EF.build(def, "extend")
  eq(fe(4, -5), 99, "extend repeats the edge"); eq(fe(-3, 2), 10, "extend west")
  local fm = EF.build(def, "mirror")
  eq(fm(-1, 0), 10, "mirror reflects"); eq(fm(8, 0), 11, "mirror east"); eq(fm(4, -1), 99, "mirror north")
  local fb = EF.build(def, "black")
  ok(fb(-1, 0) == nil, "black")
  local fo = EF.build(def, nil, { mt = 7 })
  eq(fo(-1, 0), 7, "override id")
  local fs = EF.build(def, nil, { n = 5 })
  eq(fs(0, -1), 5, "side override"); eq(fs(-1, 0), 11, "other sides keep their guess")
  -- a 1x1 map: no 2x2 block, falls back to the single dominant cell
  local f1 = EF.build({ w = 1, h = 1, cells = { 42 } })
  eq(f1(-3, 4), 42, "1x1 fallback")
  -- each(): only out-of-map cells of the view
  local n, seen = 0, {}
  local cnt = EF.each(f, W, H, -16, -16, 160, 96, function(x, y) n = n + 1; seen[x .. "," .. y] = true end)
  eq(cnt, 10 * 6 - W * H, "each count"); eq(n, cnt, "emit count"); ok(seen["-1,-1"] and not seen["0,0"], "each cells")
  eq(EF.each(f, W, H, 0, 0, 128, 64, function() end), 0, "in-map view emits nothing")
end

print(("mn_viewport: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
