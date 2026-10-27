-- Slot 0 records with a pad head and a sprite anim are the player, not a cutscene stand-in.
--   luajit tests/engine/mn_player_record_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Overworld = require("mn.Overworld")

local function spawnAfterDuel(handler)
  -- a duel scene leaves the slot 0 stand-in hidden and in objects[0]
  local s = setmetatable({ x = 33, y = 21, objects = { [0] = { x = 18, y = 20 } }, hidePlayer = true, log = {} },
    { __index = Overworld })
  local h = s:host()
  -- without the pad-head check this builds an npc sprite (no vm here), so trap it
  pcall(h.spawn, 0, 26, 12, handler, 0, 0x20, 0x4F73, 0x22, 0x4005)
  return s
end

-- 2F:44F9 (Ogar tail onto 279): record $00,$5B1E,26,12 with 20:4F73
local s = spawnAfterDuel(0x5B1E)
ok(s.hidePlayer == false, "$5B1E record clears the stand-in")
ok(s.objects[0] == nil, "$5B1E record is not an npc")
ok(s.x == 33 and s.y == 21, "player keeps its cell")
-- 1A:6841 (room 10): $5D81 still works
s = spawnAfterDuel(0x5D81)
ok(s.hidePlayer == false and s.objects[0] == nil, "$5D81 record clears the stand-in")

print(("%d/%d checks passed"):format(checks - failures, checks))
os.exit(failures == 0 and 0 or 1)
