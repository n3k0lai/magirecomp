-- Window slides: $9B (with the implicit $9D open slide), $99, $9A, and the
-- SetupWindow defaults. ROM-free: made-up slide table and portrait words in an
-- otherwise empty image; every frame count comes from the handler chain in
-- opcode_9b.asm / opcode_9d.asm / advance_window_y_slide.asm / opcode_9a_body.asm.
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local img = {}
for i = 1, 0x200000 do img[i] = 0 end
local function put(at, ...) for k, b in ipairs({ ... }) do img[at + k] = b end end
-- made-up slide table at 1:$48D5 (flat $48D5) and portrait words at 0:$2252
put(0x48D5, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA)
put(0x2252, 0x34, 0x12, 0x78, 0x56)
local S = 0x12 * 0x4000
-- 12:4000 $9B 23 45 ; AC C004 := 1 ; $99 ; AC C004 := 2 ; $9A ; AC C004 := 3 ; $94
put(S, 0x9B, 0x23, 0x45, 0xAC, 0x04, 0xC0, 0x01, 0x99, 0xAC, 0x04, 0xC0, 0x02,
  0x9A, 0xAC, 0x04, 0xC0, 0x03, 0x94)
-- 12:4100 $9B 23 45 ; AC C004 := 9 ; $94 (window already open)
put(S + 0x100, 0x9B, 0x23, 0x45, 0xAC, 0x04, 0xC0, 0x09, 0x94)
local ch = {}
for i = 1, #img do ch[i] = string.char(img[i]) end
local rom = MnRom.new(table.concat(ch))

local ys, opened, closed = {}, {}, 0
local host = {
  windowY = function(y) ys[#ys + 1] = y end,
  boxOpen = function(w) opened[#opened + 1] = w end,
  boxClose = function() closed = closed + 1 end,
  boxBusy = function() return false end,
}
local vm = VM.new(rom, host)
local function runUntil(v)
  for f = 1, 200 do
    if vm:rd8(0xC004) == v then return f end
    vm:resume()
  end
end

vm:start(0x12, 0x4000)
ok(vm:rd8(0xC6EE) == 0 and vm:rd8(0xC004) == 0, "$9B on a closed window parks first")
local f = runUntil(1)
ok(f == 46, "closed $9B: next op runs on frame F+45 (got " .. tostring(f and f - 1) .. ")")
ok(vm:rd8(0xC6EE) == 2, "window open")
ok(#ys == 10 and ys[1] == 0x11 and ys[10] == 0xAA, "WY walks the ten table bytes")
ok(vm:rd8(0xC6F0) == 7 and vm:rd8(0xC6F1) == 0xAA, "WX 7, WY last table byte")
ok(#opened == 1 and opened[1] == 0x4523, "portrait word reaches the host once")
ok(vm:rd8(0xC6E7) == 0x20 and vm:rd8(0xC6E8) == 0x45 and vm:rd8(0xC6E6) == 3, "glyph source nibbles")
ok(vm:rd8(0xC6EC) == 1, "PaintToggledWindowCorner flips $C6EC")
ok(vm:rd8(0xC6E9) == 0x60 and vm:rd8(0xC6EA) == 0x88, "$250C strip reset leaves $C6E9 = $8860")
-- $99 with the window open: one frame, window stays open
f = runUntil(2)
ok(f == 2, "$99 on an open window takes one frame (got " .. tostring(f and f - 1) .. ")")
ok(vm:rd8(0xC6EE) == 2, "$99 keeps the window open")
ok(closed == 1, "$99 clears the page")
-- $9A: G+1 body, G+2..G+10 slide, G+11 WY $90, G+12 clear, next op G+13
ys = {}
f = runUntil(3)
ok(f == 14, "$9A on an open window: next op on G+13 (got " .. tostring(f and f - 1) .. ")")
ok(vm:rd8(0xC6EE) == 0, "window closed")
ok(#ys == 10 and ys[1] == 0xAA and ys[9] == 0x22 and ys[10] == 0x90, "WY walks back table[9..1] then $90")
ok(closed == 2, "close reaches the host")

-- window already open: handler F+1, glyphs F+2..F+26, expiry F+27, next op F+28
local vm2 = VM.new(rom, host)
vm2:wr8(0xC6EE, 2)
vm2:wr8(0xC6EC, 1)
vm2:start(0x12, 0x4100)
local g
for i = 1, 100 do if vm2:rd8(0xC004) == 9 then g = i; break end; vm2:resume() end
ok(g == 29, "open $9B: next op on F+28 (got " .. tostring(g and g - 1) .. ")")
ok(vm2:rd8(0xC6EC) == 0, "$C6EC toggles back")

-- $99 / $9A on a closed window
local vm3 = VM.new(rom, host)
local c0 = closed
vm3:start(0x12, 0x4007) -- $99 ; AC := 2 ; $9A ; AC := 3
ok(vm3:rd8(0xC004) == 2, "$99 on a closed window: plain dispatch, same frame")
ok(closed == c0, "no clear when closed")
local h3
for i = 1, 10 do if vm3:rd8(0xC004) == 3 then h3 = i; break end; vm3:resume() end
ok(h3 == 3, "$9A on a closed window: next op on G+2 (got " .. tostring(h3 and h3 - 1) .. ")")
print(("mn_window_slide: %d checks, %d failures"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
