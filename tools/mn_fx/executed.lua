-- List the blocks the generator's runs (and the battle animations, mn.fx.Gen.cutin/summon) enter (owner block starts) for tools/mn_fx/build.py --only.
-- Run it against a full translation (build.py with tools/mn_fx/seeds.txt and no --only):
--   luajit tools/mn_fx/executed.lua <rom> <full_blocks.lua> tools/mn_fx/executed.txt
package.path = "./src/?.lua;" .. package.path
local G = require("mn.fx.Gen")
local f = assert(io.open(arg[1], "rb")); local rom = f:read("*a"); f:close()
local real = dofile(arg[2])
local used = {}
local function factory(env)
  local K = real(env)
  local owner = {}
  for k, fn in pairs(K) do if not env.entry[k] then owner[fn] = k end end
  return setmetatable({}, { __index = function(_, k) local fn = K[k]; if fn then used[owner[fn]] = true end return fn end })
end
for _, name in ipairs({ "glade", "card4b" }) do G.runOne(rom, factory, name) end
-- every move/spell animation and every summon the battle can show (mn.Battle runs them at play time)
local base = G.base(rom, factory)
local cut, sum = G.animRequests(rom)
local st = G.storeFor({ tiles = {}, maps = {}, pals = {} })
-- creature on creature both ways, and creature on magi both ways (Tony $58 in slot 0)
local PAIRS = { { 0x1C, 0x53, 1, 5 }, { 0x53, 0x1C, 5, 1 }, { 0x53, 0x58, 5, 0 }, { 0x58, 0x53, 0, 5 } }
for _, q in ipairs(cut) do
  for _, p in ipairs(PAIRS) do
    q.actor, q.target, q.actorSlot, q.targetSlot = p[1], p[2], p[3], p[4]
    G.cutin(base, st, q, factory)
  end
end
for i, id in ipairs(sum) do G.summon(base, st, id, 1 + (i - 1) % 8, factory) end
local ks = {} for k in pairs(used) do ks[#ks + 1] = k end table.sort(ks)
local out = io.open(arg[3], "w")
for _, k in ipairs(ks) do out:write(("%02X:%04X\n"):format(math.floor(k / 0x10000), k % 0x10000)) end
out:close(); print(#ks, "blocks")
