-- Banner strips: where the header / footer sit in a fight scene and how they scroll
-- (synthetic scene frames, no cache or LOVE needed).
--   luajit tests/engine/mn_b3d_banners_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
local B = require("mn.b3d.Banners")

local n, fails = 0, 0
local function ok(c, msg) n = n + 1; if not c then fails = fails + 1; print("FAIL " .. msg) end end

-- runs are { lines, scx, scy, wx, wy }: frame 1 has no header yet, then header / middle /
-- footer bands, the strips scrolling at their own speeds, and a last flash frame without them
local frames = { { lines = { { 113, 0, 88, 7, 0 }, { 31, 0, 176, 7, 0 } } } }
for i = 1, 8 do
  frames[#frames + 1] = { lines = { { 31, i * 10, 0, 7, 0 }, { 82, 0, 88, 7, 0 }, { 31, i * 20, 176, 7, 0 } } }
end
frames[#frames + 1] = { lines = { { 144, 0, 0, 7, 0 } } }

local info = B.find(frames)
ok(info ~= nil, "finds the bands")
ok(info.frame == 2, "first frame with all three bands")
ok(info.header.y == 0 and info.header.h == 31, "header: map rows 0-30")
ok(info.footer.y == 33 and info.footer.h == 31, "footer: map rows 33-63 (screen line 113 + SCY 176, wrapped)")
ok(info.scroll[1].h == nil and info.scroll[3].h == 20 and info.scroll[3].f == 40, "per frame scroll")

local h0, f0, up0 = B.scrollAt(info, 0)
ok(h0 == 0 and f0 == 0 and up0 == false, "no strips on the first frame")
local h1, f1, up1 = B.scrollAt(info, 1)
ok(up1 and math.abs(h1 - 80 / 256) < 1e-9 and math.abs(f1 - 160 / 256) < 1e-9, "the end holds the last frame with strips, not the flash")
local hm = B.scrollAt(info, 0.5)
ok(hm > 0 and hm < h1, "scroll moves through the scene")

ok(B.find({ { lines = { { 144, 0, 0, 7, 0 } } } }) == nil, "a scene without bands has none")
ok(B.find(nil) == nil, "no scene, no banners")

print(("mn_b3d_banners_test: %d checks, %d failures"):format(n, fails))
if fails > 0 then os.exit(1) end
