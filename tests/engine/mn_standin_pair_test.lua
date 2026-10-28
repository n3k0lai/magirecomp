-- $00 (opcode_00_bank1.asm) copies wScriptPair to $C18E, slot 0's record cell.
-- A cutscene stand-in that an earlier slot-0 $05 filled at its template cell
-- must move to the door pair with it (182 story $0F entry 2A:6172: template
-- 11,3 is inside a wall, the 277 D6 pair is 29,11).
--   luajit tests/engine/mn_standin_pair_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local function image(bytes)
  local s = string.rep("\0", 0x12 * 0x4000) .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- synthetic: $01 pair 29,11; $93; slot-0 $05 at 11,3; $00; $12
local bytes = { 0x01, 29, 11, 0x93,
  0x05, 0x00, 0x00, 0x00, 11, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0x00, 0x12 }

local px, py, sx, sy, moved = nil, nil, nil, nil, 0
local host = {
  playerCell = function() return px or 0, py or 0 end,
  placePlayer = function(x, y) px, py = x, y end,
  cellOpen = function(_, cy) return cy == 11 end,
  spawn = function(slot, x, y) if slot == 0 then sx, sy = x, y end end,
  moveStandIn = function(x, y) sx, sy = x, y; moved = moved + 1 end,
  centerCamera = function() end,
}
local vm = VM.new(image(bytes), host)
vm:start(0x12, 0x4000)
ok(px == 29 and py == 11, "player on the door pair 29,11 (got " .. tostring(px) .. "," .. tostring(py) .. ")")
ok(sx == 29 and sy == 11, "slot-0 stand-in moved to the pair (got " .. tostring(sx) .. "," .. tostring(sy) .. ")")
ok(moved == 1, "moved once by $00")
ok(vm.pair == nil, "pair consumed")

if failures == 0 then print(("ok %d checks"):format(checks)) else print(("%d FAIL / %d"):format(failures, checks)) end
os.exit(failures == 0 and 0 or 1)
