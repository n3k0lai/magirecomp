-- Panel / menu opcodes (src/mn/ops/Panels.lua). Synthetic bytes only.
--   luajit tests/engine/mn_ops_panels_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Op = require("mn.Opcodes")
local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")

local function flat(bank, ptr) return bank * 0x4000 + ptr - 0x4000 end

-- patches: { fileOffset, byte-list }
local function image(patches)
  table.sort(patches, function(a, b) return a[1] < b[1] end)
  local chunks, pos = {}, 0
  for _, p in ipairs(patches) do
    if p[1] < pos then error("overlapping patch") end
    if p[1] > pos then chunks[#chunks + 1] = string.rep("\0", p[1] - pos) end
    chunks[#chunks + 1] = string.char(unpack(p[2]))
    pos = p[1] + #p[2]
  end
  if pos < 0x200000 then chunks[#chunks + 1] = string.rep("\0", 0x200000 - pos) end
  return MnRom.new(table.concat(chunks))
end

local function run(vm, bank, ptr)
  vm:start(bank, ptr)
  local g = 0
  while vm.co and g < 2000 do vm:resume(); g = g + 1 end
  ok(vm.co == nil, ("script %02X:%04X finished"):format(bank, ptr))
end

local function ticks(vm, n)
  for _ = 1, n do vm:tickThreads() end
end

-- bank 4 planted records: $3B walks twelve (1,0,0) triples to its $24 limit;
-- $3A's first triple clamps $C9C3; $33's first five bytes are a 00 restart.
local rec24 = {}
for _ = 1, 12 do rec24[#rec24 + 1] = 1; rec24[#rec24 + 1] = 0; rec24[#rec24 + 1] = 0 end
local rec30 = { 0, 0x80, 0 }
local rec33 = { 0, 0, 0, 0x06, 0x02 }

-- $34 table at 4:6F2B, index 1 -> 4:7200, seventeen field bytes.
-- $35 reads eleven bytes at entry 0's +$1E field (4:4179).
local fields17 = {}
for i = 1, 17 do fields17[i] = 0x40 + i end
local fields11 = {}
for i = 1, 11 do fields11[i] = 0x80 + i end

-- $73 source: 24 bytes at 3:4000. Word 2 (offset 2) survives the $C9E5 rewrite.
local pairSrc = {}
for i = 0, 23 do pairSrc[i + 1] = 0x10 + i end

local B = 0x12
local function at(ptr, ...)
  return { flat(B, ptr), { ... } }
end

local rom = image({
  { flat(4, 0x6C3C), rec24 },
  { flat(4, 0x6C0C), rec30 },
  { flat(4, 0x6BDC), rec33 },
  { flat(4, 0x6F2B) + 2, { 0x00, 0x72 } },
  { flat(4, 0x7200), fields17 },
  { flat(4, 0x4179), fields11 },
  { flat(3, 0x4000), pairSrc },
  at(0x4000, 0x50, 0x00, 0xC2, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x12),
  at(0x4010, 0x3B, 0x12),
  at(0x4020, 0x3A, 0x12),
  at(0x4030, 0x33, 0x12),
  at(0x4040, 0x3D, 0x12),
  at(0x4050, 0x3E, 0x12),
  at(0x4060, 0x3F, 0x12),
  at(0x4070, 0x34, 0x01, 0x12),
  at(0x4080, 0x35, 0x00, 0x12),
  at(0x4090, 0x36, 0x12),
  at(0x40A0, 0x37, 0x12),
  at(0x40B0, 0x3C, 0x00, 0x04, 0x02, 0x12),
  at(0x40C0, 0x3C, 0x00, 0x00, 0x01, 0x12),
  at(0x40D0, 0x3C, 0x01, 0x10, 0x01, 0x12),
  at(0x40E0, 0x3C, 0x00, 0x00, 0x00, 0x12),
  at(0x4100, 0x6C, 0x01, 0x00, 0x00, 0x12),
  at(0x4110, 0x6C, 0x01, 0x00, 0x80, 0x12),
  at(0x4120, 0x6C, 0x02, 0x00, 0x00, 0x12),
  at(0x4130, 0x6D, 0x01, 0x12),
  at(0x4140, 0x72, 0x01, 0x00, 0x12),
  at(0x4150, 0x73, 0x00, 0x40, 0x03, 0x00, 0x12),
  at(0x4160, 0x73, 0x00, 0x40, 0x03, 0x01, 0x12),
  at(0x4170, 0x75, 0x00, 0x12),
  at(0x4180, 0x7B, 0x00, 0x12),
  at(0x4190, 0xA8, 0x12),
  { flat(7, 0x4000), { 0xA8, 0x12 } },
})

local function vm()
  return VM.new(rom, {})
end

-- $50 FillPointedRecord0C5F
do
  local s = vm()
  for _, i in ipairs({ 0, 3, 4, 7, 8, 15, 17, 22 }) do s:wr8(0xC200 + i, 0xA5) end
  run(s, B, 0x4000)
  ok(s:rd8(0xC201) == 0x0C and s:rd8(0xC202) == 0x5F, "$50 plants $0C $5F")
  ok(s:rd8(0xC205) == 0x11 and s:rd8(0xC206) == 0x22, "$50 copies the first pair")
  ok(s:rd8(0xC209) == 0x33, "$50 copies the single byte")
  ok(s:rd8(0xC20A) == 0x44 and s:rd8(0xC20B) == 0x55 and s:rd8(0xC20C) == 0x66, "$50 copies three bytes")
  ok(s:rd8(0xC20D) == 0x66 and s:rd8(0xC20E) == 0x0A, "$50 plants DispatchScriptOpcode")
  ok(s:rd8(0xC214) == 0x02 and s:rd8(0xC215) == 0x14, "$50 plants $02 $14")
  local kept = true
  for _, i in ipairs({ 0, 3, 4, 7, 8, 15, 17, 22 }) do
    if s:rd8(0xC200 + i) ~= 0xA5 then kept = false end
  end
  ok(kept, "$50 leaves the skipped record bytes")
  ok(Op.LEN[0x50] == 8, "$50 operand length")
end

-- PlantLimit thread: twelve steps of +1 on $C9C4, then the index hits $24.
do
  local s = vm()
  run(s, B, 0x4010)
  ok(s:rd8(0xC9EC) == 0x24 and s:rd16(0xC9F0) == 0x6C3C, "$3B plants limit $24 at $6C3C")
  ok(s:rd8(0xC9EB) == 0 and s:rd8(0xC9EE) == 0 and s:rd8(0xC9EF) == 0, "$3B clears the step counters")
  ok(s:rd16(0xFFA4) == 0x0A66, "$3B plants DispatchScriptOpcode")
  ticks(s, 12)
  ok(s:rd8(0xC9C4) == 12 and s:rd8(0xC9EB) == 0x24, "$3B thread walked the record")
  ticks(s, 2)
  ok(s:rd8(0xC9C4) == 12, "$3B thread stops at the limit")
end

do
  local s = vm()
  s:runInit(B, 0x4010)
  ok(s.threads == nil or s.threads.panelRec == nil, "$3B during init does not start the thread")
  ok(s:rd8(0xC9EC) == 0x24, "$3B during init still plants the limit")
end

do
  local s = vm()
  run(s, B, 0x4020)
  ok(s:rd8(0xC9EC) == 0x30 and s:rd16(0xC9F0) == 0x6C0C, "$3A plants limit $30 at $6C0C")
  ticks(s, 1)
  ok(s:rd8(0xC9C3) == 0x71 and s:rd8(0xC9EB) == 3, "$3A clamps $C9C3 at $71")
end

do
  local s = vm()
  run(s, B, 0x4030)
  ok(s:rd8(0xC9EC) == 0x30 and s:rd16(0xC9F0) == 0x6BDC, "$33 plants $30 at $6BDC")
  ticks(s, 1)
  ok(s:rd8(0xC9EB) == 0x06 and s:rd8(0xC9ED) == 0x02, "$33 record's 00 triple restarts the index")
end

do
  local s = vm()
  run(s, B, 0x4040)
  ok(s:rd8(0xC9EC) == 0x54 and s:rd16(0xC9F0) == 0x6C60, "$3D plants limit $54 at $6C60")
  run(s, B, 0x4050)
  ok(s:rd8(0xC9EC) == 0xA8 and s:rd16(0xC9F0) == 0x6CB4, "$3E plants limit $A8 at $6CB4")
  run(s, B, 0x4060)
  ok(s:rd8(0xC9EC) == 0x1D and s:rd16(0xC9F0) == 0x6D5C, "$3F plants limit $1D at $6D5C")
end

-- $34 / $35 entry-record copies out of bank 4
do
  local s = vm()
  s:wr8(0xC9E4, 0x5A)
  run(s, B, 0x4070)
  ok(s:rd8(0xC9E4) == 0x5A, "$34 restores $C9E4")
  ok(s:rd8(0xC9DE) == 0x00 and s:rd8(0xC9DF) == 0x72, "$34 stores the table pointer")
  ok(s:rd8(0xC9CD) == 0x41 and s:rd8(0xC9D7) == 0x51, "$34 copies the seventeen field bytes")
  ok(s:rd8(0xC938) == 4, "$34 leaves bank 4 mapped")
end

do
  local s = vm()
  run(s, B, 0x4080)
  ok(s:rd8(0xC9D8) == 0 and s:rd8(0xC9D9) == 0, "$35 stores the id and clears the panel slot")
  ok(s:rd16(0xC9DC) == 0x415B and s:rd16(0xC9DE) == 0x4179, "$35 points at entry 0 + $1E")
  ok(s:rd8(0xC9CD) == 0x81 and s:rd8(0xC9D7) == 0x8B, "$35 copies the eleven field bytes")
end

-- $36 / $37 then SeedRowMaskAndRecord
do
  local s = vm()
  run(s, B, 0x4090)
  ok(s:rd8(0xC9FA) == 0x08 and s:rd16(0xC9F4) == 0x6DE9, "$36 plants $08 and $6DE9")
  ok(s:rd8(0xC9F9) == 0xFF and s:rd8(0xC9FB) == 0x7A, "$36 seeds the row-mask bytes")
  ok(s:rd16(0xC9F2) == 0x6ABF and s:rd16(0xC9F6) == 0x9000, "$36 stores the step and vram words")
  ok(s:rd8(0xC9EC) == 0xA8 and s:rd16(0xC9F0) == 0x6CB4 and s:rd8(0xC9EB) == 0, "$36 resets the planted record")
  run(s, B, 0x40A0)
  ok(s:rd8(0xC9FA) == 0x10 and s:rd16(0xC9F4) == 0x6DF9, "$37 plants $10 and $6DF9")
end

-- $3C scroll countdown
do
  local s = vm()
  s:wr8(0xC9BC, 0x10)
  run(s, B, 0x40B0)
  ok(s:rd8(0xC9EA) == 0 and s:rd8(0xC9E9) == 4, "$3C stores the pair")
  ok(s:rd8(0xC9BC) == 0x08 and s:rd8(0xFFA6) == 0, "$3C steps $C9BC down once a frame")
  s:wr8(0xC9BC, 0x05)
  run(s, B, 0x40C0)
  ok(s:rd8(0xC9BC) == 0, "$3C zero step clears a downward scroll")
  s:wr8(0xC9BC, 0x58)
  run(s, B, 0x40D0)
  ok(s:rd8(0xC9BC) == 0x60, "$3C caps an upward step at $60")
  s:wr8(0xC9BC, 0x22)
  run(s, B, 0x40E0)
  ok(s:rd8(0xC9BC) == 0x22, "$3C count of zero does not step")
end

-- $6C steps the staged row toward black. $C7DB is the first word of that row.
do
  local s = vm()
  s:wr8(0xC7DB, 0x1F); s:wr8(0xC7DC, 0x00)
  run(s, B, 0x4100)
  ok(s:rd8(0xC7DB) == 0x1E and s:rd8(0xC9E5) == 0x1E, "$6C walks one channel toward black and copies $C7DB")
  ok(s:rd8(0xC9D8) == 0x61 and s:rd8(0xC9DC) == 1 and s:rd8(0xC831) == 1, "$6C stages the color index")
  ok(s:rd8(0xC6E4) == 0x75 and s:rd8(0xC6E6) == 7, "$6C plants the bank-7 callback")
  ok(s:rd8(0xCCA6) == 0 and s:rd16(0xFFA4) == 0x0A66, "$6C ends the countdown on DispatchScriptOpcode")
end

do
  local s = vm()
  s:wr8(0xC9E5, 0x11); s:wr8(0xC9E6, 0x22)
  run(s, B, 0x4110)
  ok(s:rd8(0xC9DA) == 0x11 and s:rd8(0xC9DB) == 0x22, "$6C bit 7 takes the word at $C9E5")
end

do
  local s = vm()
  s:wr8(0xC7DB, 0x1F)
  s:runInit(B, 0x4120)
  ok(s:rd8(0xC7DB) == 0x1D, "$6C during init applies every outer step")
end

-- $6D steps the saved row toward the working row.
do
  local s = vm()
  s:wr8(0xC75B, 0x00); s:wr8(0xC75C, 0x00)
  s:wr8(0xC7DB, 0x1F); s:wr8(0xC7DC, 0x00)
  run(s, B, 0x4130)
  ok(s:rd8(0xC7DB) == 0x1E and s:rd8(0xC9D8) == 0x61, "$6D steps the panel row toward the working word")
  ok(s:rd8(0xFFA7) == 0 and s:rd8(0xFFA6) == 1, "$6D split byte $01 expires in one frame")
end

-- $72 blends saved palette 0 color 1 toward the working word.
do
  local s = vm()
  s:wr8(0xC72D, 0x00); s:wr8(0xC72E, 0x00)
  s:wr8(0xC7AD, 0x1F); s:wr8(0xC7AE, 0x00)
  run(s, B, 0x4140)
  ok(s:rd8(0xC9D9) == 0 and s:rd8(0xC7AD) == 0x1E, "$72 reads the panel byte and blends one channel")
  ok(s:rd8(0xC9DC) == 1, "$72 sets the entry-record count")
end

-- $73 copies twelve words, then rewrites the $C9E5 slots.
do
  local s = vm()
  s:wr8(0xC9E5, 0xCD); s:wr8(0xC9E6, 0xAB)
  run(s, B, 0x4150)
  ok(s:rd16(0xC9D5) == 0x4000 and s:rd8(0xC9D7) == 3 and s:rd8(0xC9D9) == 0,
    "$73 stores the pair pointer, bank, and slot")
  ok(s:rd8(0xC72B) == 0xCD and s:rd8(0xC72C) == 0xAB, "$73 writes the $C9E5 word over slot 0")
  ok(s:rd8(0xC72D) == 0x12, "$73 keeps a copied word the rewrite does not cover")
  ok(s:rd8(0xC938) == 0, "$73 restores ROM bank 0")
  local s2 = vm()
  s2:wr8(0xC9E5, 0x00)
  run(s2, B, 0x4160)
  ok(s2:rd8(0xC72B + 0x1A) == 0x12, "$73 nonzero slot copies at index $0C")
end

-- $75 complements palette 0 color 1. $7B complements the first four words at $C7AB.
do
  local s = vm()
  s:wr8(0xC7AD, 0x12)
  s:wr8(0xC9E2, 1) -- skip the extra color-0 complement
  run(s, B, 0x4170)
  ok(s:rd8(0xC9D9) == 0 and s:rd8(0xC7AD) == 0xED, "$75 complements the low slot palettes")
  ok(s:rd8(0xC6E4) == 0x75 and s:rd16(0xFFA4) == 0x0A66, "$75 plants the callback and the dispatcher")
end

do
  local s = vm()
  s:wr8(0xC7AB, 0x12)
  run(s, B, 0x4180)
  ok(s:rd8(0xC9D8) == 0 and s:rd8(0xC7AB) == 0xED, "$7B complements the row $80 bytes on")
  ok(s:rd8(0xC831) == 1, "$7B sets the panel-busy byte")
end

-- $A8 is IncrementSramScriptWord only in bank 7.
do
  local s = vm()
  s:wr8(0xA123, 0x05)
  run(s, B, 0x4190)
  ok(s:rd8(0xA123) == 0x05, "$A8 outside bank 7 does not touch $A123")
  local s7 = vm()
  s7:wr8(0xA123, 0xFF); s7:wr8(0xA124, 0x01)
  s7:wr8(0xA125, 0xAB); s7:wr8(0xA224, 0xCD)
  run(s7, 7, 0x4000)
  ok(s7:rd8(0xA123) == 0 and s7:rd8(0xA124) == 0x02, "$A8 in bank 7 increments the SRAM word")
  ok(s7:rd8(0xA125) == 0 and s7:rd8(0xA1A3) == 0, "$A8 clears the $A125 run")
  ok(s7:rd8(0xA224) == 0 and s7:rd8(0xA2A2) == 0, "$A8 clears the $A224 run")
end

-- every claimed opcode has a size ScriptVM's table knows
for op in pairs(require("mn.ops.Panels").handlers) do
  ok(type(Op.LEN[op]) == "number", ("$%02X has a fixed size"):format(op))
end

print(("mn_ops_panels: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
