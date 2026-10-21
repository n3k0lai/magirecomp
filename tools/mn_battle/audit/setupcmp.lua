-- compare Engine.new(setup) with the real WRAM recorded at battle start
-- luajit setupcmp.lua ROM setup.json '<setup lua table>'
package.path = "src/?.lua;tools/mn_battle/?.lua;" .. package.path
local MnRom = require("mn.MnRom"); local Data = require("mn.battle.Data")
local Engine = require("mn.battle.Engine"); local Rng = require("mn.battle.Rng"); local json = require("json")
local data = Data.extract(MnRom.fromFile(arg[1]))
local f = assert(io.open(arg[2], "rb")); local t = json.decode(f:read("*a")); f:close()
local chunk = assert(loadstring("return " .. arg[3])); setfenv(chunk, { Engine = Engine }); local setup = chunk()
local list = {}
for _, d in ipairs(t.draws) do list[#list + 1] = { d[1], d[2] } end
local rng = Rng.replay(list)
if not setup.ffa9 then
  for _, d in ipairs(t.draws) do if d[1] == "s" then setup.ffa9 = (d[4] - d[2]) % 256; break end end
end
local s = Engine.new(data, setup, rng)
local w = t.wram:gsub("%x%x", function(x) return string.char(tonumber(x, 16)) end)
local n = 0
local ignore = {}
for a in (arg[4] or ""):gmatch("%x+") do ignore[tonumber(a, 16)] = true end
local lo, hi = tonumber(arg[5] or "D000", 16) - 0xD000, tonumber(arg[6] or "D3FF", 16) - 0xD000
for a = lo, hi do
  local want, got = w:byte(a + 1), s.m[0xD000 + a]
  if want ~= got and not ignore[0xD000 + a] then n = n + 1; if n <= 60 then io.write(("%04X want %02X got %02X\n"):format(0xD000 + a, want, got)) end end
end
print(("draws used %d of %d%s, ffa9 want %02X got %02X, diffs %d"):format(rng.i, #list, rng.err and (" (" .. rng.err .. ")") or "", t.ffa9, s.ffa9, n))
