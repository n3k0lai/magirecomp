-- $4F QueueRepeatedOffsetSpriteList: screen-space dx/dy steps (no wall test), first
-- list shown first, VM waits the sum of counts. ROM-free made-up bytes.
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local Sprites = require("mn.Sprites")
local VM = require("mn.ScriptVM")

local img = {}
for i = 1, 0x200000 do img[i] = 0 end
local function put(at, ...) for k, b in ipairs({ ... }) do img[at + k] = b end end
local B = 0x12 * 0x4000
-- 12:4000 $4F (3, +6, 0, $5000) (2, -2, +1, $5010) 0 ; AC C004 := 5 ; $94
put(B, 0x4F, 3, 6, 0, 0x00, 0x50, 2, 0xFE, 1, 0x10, 0x50, 0, 0xAC, 0x04, 0xC0, 5, 0x94)
-- 12:4100 same records under $4C
put(B + 0x100, 0x4C, 3, 6, 0, 0x00, 0x50, 0)
local ch = {}
for i = 1, #img do ch[i] = string.char(img[i]) end
local rom = MnRom.new(table.concat(ch))

local fr = Sprites.frames(rom, 0x12, 0x4000)
ok(#fr == 2 and fr[1].screen and fr[2].screen, "$4F records are screen-space steps")
ok(fr[1].dx == 6 and fr[2].dx == -2 and fr[2].dy == 1, "signed dx/dy")
ok(fr[1].list == 0x5000, "first list first")
local f4c = Sprites.frames(rom, 0x12, 0x4100)
ok(#f4c == 1 and not f4c[1].screen, "$4C records stay fine steps")

-- a wall to the right does not stop $4F motion; it does stop $4C
local o = { seq = fr, fi = 1, ft = 0, ox = 0, oy = 0, x = 5, y = 5 }
local wall = function() return false end
for _ = 1, 3 do Sprites.tick(o, wall) end
ok(o.x == 6 and o.ox == 2, "$4F: 3 frames of +6 px cross the cell despite the wall")
local p = { seq = f4c, fi = 1, ft = 0, ox = 0, oy = 0, x = 5, y = 5 }
for _ = 1, 3 do Sprites.tick(p, wall) end
ok(p.x == 5, "$4C is held by the wall")

local vm = VM.new(rom, {})
vm:start(0x12, 0x4000)
local n = 0
while vm:rd8(0xC004) ~= 5 and n < 20 do -- Overworld's host: resume once vm.wait runs out
  n = n + 1
  vm.wait = vm.wait and vm.wait - 1
  if not vm.wait or vm.wait <= 0 then vm.wait = nil; vm:resume() end
end
ok(n == 5, "next op runs after the 3 + 2 step frames (got " .. n .. ")")
print(("mn_offset_list: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
