package.path = "src/?.lua;src/?/init.lua;tools/mn_battle/?.lua;" .. package.path
local E = require("mn.battle.Engine")
local function enc(v)
  if type(v) == "table" then local p = {}; for i, x in ipairs(v) do p[i] = enc(x) end; return "[" .. table.concat(p, ",") .. "]" end
  if type(v) == "string" then return '"' .. v .. '"' end
  return tostring(v)
end
local p = {}
for a, chain in pairs(E.HANDLERS) do p[#p + 1] = ('"%04X":%s'):format(a, enc(chain)) end
io.write("{" .. table.concat(p, ",") .. "}")
