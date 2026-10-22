-- mn.fx: the battle-scene generator (src/mn/fx). ROM-free: the shipped modules carry no ROM data
-- (no capture files, no long byte strings or numeric tables in the translated code) and the cache
-- serialiser round-trips. With MN_ROM set (the user's own ROM; nothing from it is committed) the
-- generator runs the game's own code from the boot hand-over, its three attacks land on the
-- expected frames, every scene the battle screen draws is present and a rebuild is identical.
--   luajit tests/engine/mn_battle_scenes_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end
local function read(p) local f = io.open(p, "rb"); if not f then return nil end local s = f:read("*a"); f:close(); return s end

ok(read("src/mn/data_battle_scenes.lua") == nil, "no captured scene file in src/mn")
ok(read("src/mn/data_battle_capture.json") == nil, "no captured backdrop file in src/mn")

-- the translated code: no string literals and no long constant tables (data belongs to the ROM)
for _, p in ipairs({ "src/mn/fx/Blocks.lua", "src/mn/fx/Cgb.lua", "src/mn/fx/Start.lua", "src/mn/fx/Gen.lua" }) do
  local s = read(p) or ""
  ok(#s > 0, p .. " exists")
  local code = s:gsub("%-%-[^\n]*", "")
  local longest = 0
  for str in code:gmatch('"([^"\n]*)"') do longest = math.max(longest, #str) end
  ok(longest < 80, p .. ": no long string literals (" .. longest .. ")")
  local run = 0
  for tbl in code:gmatch("%b{}") do
    local n = select(2, tbl:gsub("0x%x+", "")) + select(2, tbl:gsub("[^%w_]%d+", ""))
    run = math.max(run, n)
  end
  ok(run < 300, p .. ": no long numeric tables (" .. run .. ")")
end

local G = require("mn.fx.Gen")
do
  local t = { version = 1, tiles = { "00ff" }, maps = { { 0, 1, 2 } }, scenes = { a = { { l = 0x91, m = { ["1800"] = 0 } } } } }
  local back = assert(loadstring(G.serialize(t)))()
  ok(back.version == 1 and back.tiles[1] == "00ff" and back.maps[1][3] == 2 and back.scenes.a[1].m["1800"] == 0, "serialise round-trip")
end

local romPath = os.getenv("MN_ROM")
local rom = romPath and read(romPath)
if rom then
  local t0 = os.clock()
  local a = G.build(rom)
  local b = G.build(rom)
  ok(G.serialize(a) == G.serialize(b), "a rebuild is identical")
  local want = { idle = 1, menu = 1, target = 1, slot = 1, tonymsg = 1, furokmenu300 = 1, backdrop = 1,
    fight_weebo_tony = 120, fight_weebo_furok = 120, fight_furok_weebo = 120, elim_top = 121 }
  for k, n in pairs(want) do ok(a.scenes[k] and #a.scenes[k] == n, ("scene %s has %d frames"):format(k, n)) end
  for _, k in ipairs({ "53", "1C", "4B" }) do ok(a.pics[k] ~= nil, "creature picture " .. k) end
  local f = a.scenes.idle[1]
  local tony = 0
  for _, o in ipairs(f.oam) do if o[2] >= 68 and o[2] <= 80 and o[1] >= 78 and o[1] <= 96 then tony = tony + 1 end end
  ok(tony == 6, "Tony's sprite is 6 objects in the idle frame")
  for _, o in ipairs(a.scenes.elim_top[1].oam) do ok(not (o[2] >= 68 and o[2] <= 80 and o[1] >= 78 and o[1] <= 96), "elimination frames carry no Tony objects") end
  print(("mn_battle_scenes: built twice in %.1fs, %d tiles"):format(os.clock() - t0, #a.tiles))
else
  print("mn_battle_scenes: MN_ROM not set, generator run skipped")
end

print(("mn_battle_scenes: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
