-- Sprites block a step only through the cell map. Synthetic plane only.
-- MarkZeroMapCell (bank 1 $4AD5) writes $08 under a record only when that
-- cell byte is $00, so a live sprite on floor blocks and a live sprite on
-- a $C0+ step trigger does not (279's slot 2 on the story-9 cell 34,21).
--   luajit tests/engine/mn_sprite_cell_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local World = require("mn.World")

-- floor, a step-trigger cell, a list cell, a gate cell
local def = { w = 4, h = 1, block = { 0x00, 0xC5, 0x21, 0x04 } }
local function npc(x, t)
  local ob = { x = x, y = 0, anim = { 0x11, 0x7604 }, handler = 0x4A6B }
  for k, v in pairs(t or {}) do ob[k] = v end
  return ob
end

ok(World.blocks(def, npc(0), 0, 0) == true, "live sprite on floor $00 blocks")
ok(World.blocks(def, npc(1), 1, 0) == false, "live sprite on a $C5 step trigger does not block")
ok(World.blocks(def, npc(2), 2, 0) == false, "live sprite on a list cell does not block")
ok(World.blocks(def, npc(3), 3, 0) == false, "live sprite on a gate cell does not block")
ok(World.blocks(def, npc(0), 1, 0) == false, "a sprite only covers its own cell")
ok(World.blocks(def, npc(0, { dormant = true }), 0, 0) == false, "dormant record does not block")
ok(World.blocks(def, npc(0, { blank = true }), 0, 0) == false, "blank record does not block")
ok(World.blocks(def, npc(0, { anim = false }), 0, 0) == false, "imageless record does not block")
ok(World.blocks(def, npc(0, { handler = 0x65A4 }), 0, 0) == false, "$65A4 step-on record does not block")

if failures == 0 then print(("ok %d checks"):format(checks))
else print(("%d FAILED / %d"):format(failures, checks)); os.exit(1) end
