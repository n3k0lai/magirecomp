-- $67 CallScriptUnpackHeaderAndBlock -> UnpackMapHeaderIntoWRAMBank3 ($2F37)
-- and UnpackBlockIntoWRAMBank5 ($2DDC). Made-up streams only.
--   luajit tests/engine/mn_unpack_map_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local Records = require("mn.ops.Records")

-- header at 30:4000: stride 3, word $1234, camera limits 5/6, two skipped,
-- then copy 3 ($03) and fill 3 ($83), then end
-- block at 31:4010: $C6CF byte $77, two skipped, then fill 6 with $09 + end
local rom = {}
local function put(off, bytes) for i, b in ipairs(bytes) do rom[off + i - 1] = b end end
local H, B = 0x30 * 0x4000, 0x31 * 0x4000 + 0x10
put(H, { 0x03, 0x34, 0x12, 0x05, 0x06, 0xEE, 0xEE, 0x03, 0x0A, 0x0B, 0x0C, 0x83, 0x0D, 0x00 })
put(B, { 0x77, 0xEE, 0xEE, 0x86, 0x09, 0x00 })
local n = 0x200000
local parts = {}
for i = 0, n - 1 do parts[#parts + 1] = string.char(rom[i] or 0) end
local R = MnRom.new(table.concat(parts))

local p = Records.readMapPlanes(R, H, B)
ok(p.stride == 3 and p.word == 0x1234 and p.camCol == 5 and p.camRow == 6, "header fields")
ok(#p.cells == 6 and p.cells[1] == 0x0A and p.cells[3] == 0x0C and p.cells[4] == 0x0D and p.cells[6] == 0x0D, "metatile plane")
ok(p.c6cf == 0x77 and #p.block == 6 and p.block[1] == 9 and p.block[6] == 9, "collision plane")

-- the opcode through the host: the live map takes both planes
local ow = { def = { w = 10, h = 10, cells = {}, block = {}, image = "old", camCol = 1, camRow = 1 }, patches = { 1 }, camFix = { 4, 4 } }
local h = { fullRom = function() return R end }
Records.host(ow, h)
local mem = {}
local script = { [0] = 0x67, 0x00, 0x40, 0x30, 0x10, 0x40, 0x31 }
local vm = {
  host = h, mem = mem,
  rom = { u8 = function(_, a) return script[a] end, u16 = function(_, a) return script[a] + script[a + 1] * 256 end },
  wr8 = function(_, a, v) mem[a] = v end,
}
mem[0xC85F], mem[0xC843] = 9, 9
ok(Records.handlers[0x67](vm, 0, 7) == 7, "continues past the six operand bytes")
ok(ow.def.w == 3 and ow.def.h == 2 and ow.def.cells[2] == 0x0B and ow.def.block[1] == 9, "live planes replaced")
ok(ow.def.camCol == 5 and ow.def.camRow == 6 and ow.def.image == "old", "camera limits, image kept")
ok(#ow.patches == 6 and ow.patches[4].x == 0 and ow.patches[4].y == 1 and ow.patches[4].mt == 0x0D, "every cell patched")
ok(ow.camFix == nil, "camera unpinned")
ok(mem[0xC85F] == 0 and mem[0xC843] == 0 and mem[0xC842] == 0x44, "scroll state cleared, edge flags $44")
ok(mem[0xC847] == 3 and mem[0xC849] == 0x34 and mem[0xC84A] == 0x12 and mem[0xC6CF] == 0x77, "header stores")
ok(mem[0xC845] == 5 and mem[0xC846] == 6 and mem[0xC848] == 16, "camera limits and row limit + $0A")
ok(mem[0xC84B] == 0 and mem[0xC84C] == 0, "C84B word cleared")
local good = true
for k = 0, 7 do if mem[0xC84D + 2 * k] ~= 3 * (k + 1) or mem[0xC84E + 2 * k] ~= 0 then good = false end end
ok(good, "stride multiples 1..8")

print(("mn_unpack_map_test: %d/%d"):format(checks - failures, checks))
if failures > 0 then os.exit(1) end
