-- Battle move and summon animations: the game's own code (mn.fx) run per request from a machine
-- stopped at StagePointerUnlessD0B6Matches (02:472E). ROM-free: machine clones run independently
-- and the scene store appends new entries to the loaded table once. With MN_ROM (the user's own
-- ROM; nothing from it is committed): the Fight cut-in generated from the base's own staging values
-- is the Glade capture frame for frame, and a summon copies a 20-tile card onto a 4x5 panel.
--   luajit tests/engine/mn_battle_anims_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Cgb = require("mn.fx.Cgb")
local Blocks = require("mn.fx.Blocks")
local G = require("mn.fx.Gen")

do -- clone: memories and registers are copies, the ROM is shared
  local fake = string.rep("\0", 0x8000)
  local m = Cgb.new(fake, Blocks)
  m:write(0xC000, 5)
  local r = m.env.regs(); r.A = 0x11; m.env.setregs(r)
  local c = m:clone(Blocks)
  ok(c.rom == m.rom, "clone shares the ROM")
  ok(c:R(0xC000, c.env.cy(), 0) == 5 and c.env.regs().A == 0x11, "clone starts from the source state")
  c:write(0xC000, 9)
  local r2 = c.env.regs(); r2.A = 0x22; c.env.setregs(r2)
  ok(m:R(0xC000, m.env.cy(), 0) == 5, "source memory untouched by the clone")
  ok(m.env.regs().A == 0x11, "source registers untouched by the clone")
end

do -- storeFor: existing entries are found, new ones appended to the table once
  local t = { tiles = { "00112233445566778899aabbccddeeff" }, maps = { { 1, 2 } }, pals = {} }
  local st = G.storeFor(t)
  ok(G.storeFor(t) == st, "store cached on the table")
  local raw = ("00112233445566778899aabbccddeeff"):gsub("%x%x", function(x) return string.char(tonumber(x, 16)) end)
  ok(st.tile(raw) == 0 and #t.tiles == 1, "known tile found")
  ok(st.tile(("\1"):rep(16)) == 1 and #t.tiles == 2 and t.tiles[2] == ("01"):rep(16), "new tile appended as hex")
  ok(st.tile(("\1"):rep(16)) == 1 and #t.tiles == 2, "new tile not appended twice")
  ok(st.map({ 1, 2 }) == 0 and st.map({ 3 }) == 1 and #t.maps == 2, "maps dedup and append")
  local p = {} for q = 1, 8 do p[q] = { q, 0, 0, 0 } end
  ok(st.pal(p) == 0 and st.pal(p) == 0 and #t.pals == 1, "palettes dedup and append")
end

local path = os.getenv("MN_ROM")
local f = path and io.open(path, "rb")
if f then
  local rom = f:read("*a"); f:close()
  local base = G.base(rom, Blocks)
  local function rd(a) return base:R(a, base.env.cy(), 0) end
  local r = base.env.regs()
  ok(base.rombank == 2 and base.PC == 0x472E, "base stops at the staging call")
  local t = { tiles = {}, maps = {}, pals = {} }
  local st = G.storeFor(t)
  local out = { scenes = {}, pics = {} }
  G.runOne(rom, Blocks, "glade", st, out)
  local fr = G.cutin(base, st, { bank = r.A, ptr = r.B * 256 + r.C, actor = rd(0xD0DB), target = rd(0xD112),
    actorSlot = rd(0xD0B6), targetSlot = rd(0xD103), c9e4 = rd(0xC9E4) }, Blocks)
  local clip = out.scenes.fight_weebo_tony
  local same, n = 0, 0
  for i = 1, #clip do
    if fr[7 + i] then n = n + 1; if G.serialize(fr[7 + i]) == G.serialize(clip[i]) then same = same + 1 end end
  end
  ok(n > 100 and same == n, ("cut-in matches the Glade capture (%d/%d)"):format(same, n))
  local c = G.summon(base, st, 0x1C, 1, Blocks)
  ok(#c.frames == 21 and c.n == 20, "summon: 21 frames, 20 card tiles")
  ok(c.w == 4 and c.h == 5 and c.col == 0 and c.row == 7, "summon: slot 1 card is 4x5 at col 0, row 7")
else
  print("mn_battle_anims_test: MN_ROM not set, ROM checks skipped")
end

print(("mn_battle_anims: %d checks, %d failed"):format(checks, failures))
if failures > 0 then os.exit(1) end
