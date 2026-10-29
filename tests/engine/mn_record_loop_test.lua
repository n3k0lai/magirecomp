-- $38 InstallScriptRecordLoopBank4 and $39 StageHandler1126 (src/mn/ops/Panels.lua).
-- Synthetic bytes only.
--   luajit tests/engine/mn_record_loop_test.lua
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

-- runs the record, returns the frames it waited (sum of "wait" yields)
local function run(s, bank, ptr)
  s.wait = nil
  s:start(bank, ptr)
  local g, waited = 0, (s.co and s.wait) or 0
  while s.co and g < 4000 do
    s.wait = nil
    s:resume(); g = g + 1
    if s.co and s.wait then waited = waited + s.wait end
  end
  ok(s.co == nil, ("script %02X:%04X finished"):format(bank, ptr))
  return waited
end

local function wr16(s, a, v) s:wr8(a, v % 256); s:wr8(a + 1, math.floor(v / 256)) end
local function rd16(s, a) return s:rd8(a) + 256 * s:rd8(a + 1) end
local function rgb(r, g, b) return r + 32 * g + 1024 * b end


local B = 0x12
local function at(ptr, ...) return { flat(B, ptr), { ... } } end
local function at4(ptr, ...) return { flat(4, ptr), { ... } } end

-- seventeen entry bytes; byte 13/14 land in $C9BE/$C9BF (the two scales)
local entry = {}
for i = 1, 17 do entry[i] = 0x40 + i end
entry[13], entry[14] = 3, 5
local function rec(id) return 0x415B + id * 0x2D + 0x1E end
local function bytes(n, base) local t = {} for i = 1, n do t[i] = base + i end return t end

local rom = image({
  -- $38: C9E4 = 2, entries 1 and 2; then $39 forward with table $5000, then $12
  at(0x4000, 0x38, 0x02, 0x01, 0x02, 0x39, 0x01, 0x00, 0x50, 0x12),
  -- $39 alone: direction 0 (down) on table $5010
  at(0x4020, 0x39, 0x00, 0x10, 0x50, 0x12),
  -- $39 whose first later pair is the terminator
  at(0x4030, 0x39, 0x01, 0x20, 0x50, 0x12),
  -- $38 then a long wait so the loop runs
  at(0x4040, 0x38, 0x02, 0x01, 0x02, 0x40, 0x10, 0x12),
  at4(0x5000, 0x07, 0x05, 0x02, 0x10, 0x01, 0x03, 0x00, 0x99),
  at4(0x5010, 0x09, 0x04, 0x03, 0x02, 0x00, 0x00),
  at4(0x5020, 0x09, 0x06, 0x00, 0x77),
  at4(0x6F2B + 4, 0x00, 0x60),
  at4(0x6000, unpack(entry)),
  { flat(4, rec(1)), bytes(11, 0x10) },
  { flat(4, rec(2)), bytes(11, 0x20) },
})

-- $39 only (down): pair 0 once, pair 1 (count 3) three times, then the terminator frame
do
  local s = VM.new(rom, {})
  s:wr8(0xC9BC, 0x30)
  local w = run(s, B, 0x4020)
  -- 0x30 - 4 - 2*3 = 0x26
  ok(s:rd8(0xC9BC) == 0x26, ("$39 down steps C9BC to $26 (%02X)"):format(s:rd8(0xC9BC)))
  ok(s:rd8(0xC9EA) == 0 and s:rd8(0xC9E7) == 0x10 and s:rd8(0xC9E8) == 0x50, "$39 re-reads its three bytes")
  ok(s:rd8(0xFFA6) == 2, "$39 FFA6 ends on the terminator pair")
  -- frames: 1 (op returns) + 3 more steps + terminator frame = 5 waits, the 12 on the 6th
  ok(w == 6, ("$39 waits 6 frames (%d)"):format(w))
  ok(rd16(s, 0xFFA2) == 0x4024, "$39 dispatch pointer past the three bytes")
end

-- $39: a zero count right after pair 0 ends it; pair 0 still applies once
do
  local s = VM.new(rom, {})
  s:wr8(0xC9BC, 0x10)
  local w = run(s, B, 0x4030)
  ok(s:rd8(0xC9BC) == 0x16, ("$39 single pair applies once (%02X)"):format(s:rd8(0xC9BC)))
  ok(w == 3, ("$39 single pair waits 3 (%d)"):format(w))
end

-- $39 up: the cap at $60
do
  local s = VM.new(rom, {})
  s:wr8(0xC9BC, 0x5E)
  run(s, B, 0x4000) -- $38 first, which zeroes C9BC; up by 5 + 2*$10 + 3 = $28
  ok(s:rd8(0xC9BC) == 0x28, ("$38 then $39 up: C9BC $28 (%02X)"):format(s:rd8(0xC9BC)))
  -- $38 setup
  ok(s:rd8(0xC9E4) == 2 and s:rd8(0xC9E0) == 1 and s:rd8(0xC9E1) == 2, "$38 stores C9E4/C9E0/C9E1")
  ok(s:rd8(0xC9C5) == 0, "$38 C9C5 back to 0 after the present")
  ok(s:rd8(0xC9BD) == 0x58 and s:rd8(0xC9C3) == 0x20 and rd16(s, 0xC9F0) == 0x6C60
    and rd16(s, 0xC9F2) == 0x6AF9 and rd16(s, 0xC9F4) == 0x6DF9 and rd16(s, 0xC9F6) == 0x9000
    and s:rd8(0xC9F8) == 4, "$38 seeds the scroll record")
  ok(s:rd8(0xC833) == 0x24 and s:rd8(0xC832) == 0 and s:rd8(0xC834) == 0, "$38 C832-C835")
  ok(s:rd8(0xC9BE) == 3 and s:rd8(0xC9BF) == 5, "$38 applies the C9E4 table entry")
  ok(s:rd8(0xC9CD) == 0x21 and s:rd8(0xC9D7) == 0x2B, "$38 presents C9E1's record last")
  ok(rd16(s, 0xC9DC) == 0x415B + 2 * 0x2D, "$38 RecordPtrFromId base")
  ok(s:rd8(0xC9D8) == 7 and rd16(s, 0xC9DA) == 0x7FFF, "$38 stages the white fill")
  local white = true
  for i = 0, 31 do if rd16(s, 0xC7AB + 2 * i) ~= 0x7FFF then white = false end end
  ok(white and rd16(s, 0xC7AB + 64) ~= 0x7FFF, "$38 fills 32 words of the C7AB row white")
  ok(rd16(s, 0xC6E4) == 0x29A4, "$38 RefreshSavedPalettes leaves IdleCallback")
  ok(s:rd8(0xC706) == B and rd16(s, 0xC707) == 0x4004 and rd16(s, 0xC709) == 0x0A66,
    "$38 copies the script record to C706")
  ok(s.loop38 == true and s.threads and s.threads.loop38, "$38 starts the frame loop")
end

-- the loop: C9C0/C9C1/C9C2/camera per frame, Start pause and B park behind C9C6
do
  local pressed = {}
  local s = VM.new(rom, { buttonPressed = function(k) local p = pressed[k]; pressed[k] = nil; return p end })
  s:start(B, 0x4040)
  ok(s.loop38, "loop running")
  s:wr8(0xC9BC, 0x93) -- bit 7 masked: $13
  s:wr8(0xC9C4, 0x10)
  s:tickThreads(false)
  ok(s:rd8(0xC9BC) == 0x13, "loop masks C9BC to 7 bits")
  -- (0x13 sra 2) = 4; 4*3 + 0x13 = 0x1F; 4*5 + 0x13 = 0x27
  ok(s:rd8(0xC9C0) == 0x1F and s:rd8(0xC9C1) == 0x27, ("loop scales C9C0/C9C1 (%02X %02X)"):format(s:rd8(0xC9C0), s:rd8(0xC9C1)))
  ok(s:rd8(0xC9C2) == (0x10 + 0x87 - 0x13) % 256, "loop C9C2 = C9C4 + $87 - C9BC")
  ok(s:rd8(0xC935) == 0x13, "loop writes wCameraPixelX")
  -- gate closed: Start ignored
  pressed.start = true; s:tickThreads(false)
  ok(s:rd8(0xC9C7) == 0, "Start ignored while C9C6 = 0")
  s:wr8(0xC9C6, 1)
  pressed.start = true; s:tickThreads(false)
  ok(s:rd8(0xC9C7) == 1, "Start toggles C9C7 behind the gate")
  pressed.start = true; s:tickThreads(false)
  ok(s:rd8(0xC9C7) == 0, "Start toggles C9C7 back")
  pressed.b = true
  local g = 0
  repeat s:tickThreads(false); g = g + 1 until s.co == nil or g > 20
  -- eight passes each end in FinishFrame (the record still runs); the park lands at the
  -- start of the ninth frame, before the record runs again
  ok(s.co == nil and g == 9, ("B parks the record after eight white frames (%d)"):format(g))
  ok(s:rd8(0xC9C6) == 0 and rd16(s, 0xC709) == 0x1402 and s:rd8(0xC708) == 0, "B: handler $1402, pointer high 0, gate cleared")
  local white = true
  for i = 0, 31 do if rd16(s, 0xC72B + 2 * i) ~= 0x7FFF then white = false end end
  ok(white, "B fills the C72B row white")
  ok(s:rd8(0xC9DE) == 0, "B pass count ran out")
end

print(("mn_record_loop_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
