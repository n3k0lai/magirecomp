-- Using an object: a record script that is only "$5B talk, $42" runs the talk; one that
-- carries on after its $5B (257 boatman 1B:509A: $5B 1B:4D16, then $4B selector, wait on
-- C6FD for the talk's $58 01 post, enter 1B:50ED -> 2A:6547) must run as the slot thread.
--   luajit tests/engine/mn_use_record_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end }, graphics = {} } -- luacheck: ignore 111
local failures, checks = 0, 0
local function ok(c, w) checks = checks + 1; if not c then failures = failures + 1; print("FAIL " .. w) end end
local okLoad, Overworld = pcall(require, "mn.Overworld")
ok(okLoad, "load mn.Overworld: " .. tostring(not okLoad and Overworld or ""))
local MnRom = require("mn.MnRom")
local s = string.rep("\0", 0x1B * 0x4000)
local body = { [0x09A] = { 0x5B, 0x1B, 0x16, 0x4D, 0x4B }, [0x100] = { 0x5B, 0x1B, 0x16, 0x4D, 0x42 }, [0x200] = { 0x14, 0x0F, 0xD8, 0x52, 0x42 } }
local bank = {}
for i = 0, 0x3FF do bank[i + 1] = 0 end
for at, b in pairs(body) do for k, v in ipairs(b) do bank[at + k] = v end end
local chars = {}; for i = 1, #bank do chars[i] = string.char(bank[i]) end
s = s .. table.concat(chars); s = s .. string.rep("\0", 0x200000 - #s)
local rom = MnRom.new(s)
local f = okLoad and Overworld.useRunsRecord
ok(type(f) == "function", "Overworld.useRunsRecord exists")
if type(f) == "function" then
  ok(f(rom, 0x1B, 0x409A) == true, "boatman-style $5B then $4B runs the record thread")
  ok(f(rom, 0x1B, 0x4100) == false, "plain $5B talk / $42 runs the talk")
  ok(f(rom, 0x1B, 0x4200) == true, "non-$5B record runs as the thread")
end
if failures == 0 then print(("ok %d checks"):format(checks)) else print(("%d FAIL / %d"):format(failures, checks)) end
os.exit(failures == 0 and 0 or 1)
