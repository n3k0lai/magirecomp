-- mn.sfx.Driver music countdown sequencer: InstallSoundIndex with
-- FillCountdownStep / SeedCountdownFromTable, and StepSoundCountdowns
-- with its upper and lower walkers, on synthetic tables. Counts the
-- frames a $20 sound holds SoundCountdownIdle. Never plays audio.
--   luajit tests/engine/mn_music_seq_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Sfx = require("mn.Sfx")

local BANK = 0x30
local function goff(ptr, bank) return bank * 0x4000 + ptr - 0x4000 end

-- Every byte below is synthetic.
local H = 0x6400          -- header the song entry points at
local T = H + 0x84        -- table base stored at $DFA7

local function image(slotRec, lower)
  local map = {}
  local function poke(ptr, bytes)
    local o = goff(ptr, BANK)
    for i = 1, #bytes do map[o + i - 1] = bytes[i] end
  end
  local function le(ptr, v) poke(ptr, { v % 256, math.floor(v / 256) % 256 }) end
  local function be(ptr, v) poke(ptr, { math.floor(v / 256) % 256, v % 256 }) end
  -- SoundDataHeader: song list at $6300, one song.
  le(0x5A85, 0x6300 - 0x5A79)
  poke(0x5A87, { 1 })
  poke(0x6300, { 0x00, H % 256, math.floor(H / 256) })
  -- SoundDataLead masks.
  poke(0x5A75, { 0xFC, 0xF3, 0xCF, 0x3F })
  -- Tag 0 -> a stream that ends at once.
  le(0x5A88, 0x6100 - 0x5A88)
  poke(0x6100, { 0x00 })
  -- Header bytes (DFAD..DFB0) and the $3FB0 byte list after them.
  poke(H, { 0x00, 0x11, 0x22, 0x33, 0x44, 0x55 })
  be(T + 0, 0x0010)       -- slot list
  be(T + 2, 0x0020)       -- lower stream list
  be(T + 4, 600)          -- scale word: step = $66 * 600 / $3C = $3FC
  be(T + 0x10, 0x0040)    -- slot 0 record; slots 1-3 empty
  poke(T + 0x40, slotRec)
  be(T + 0x22, 0x0060)    -- action 1
  be(T + 0x24, 0x0070)    -- action 2
  poke(T + 0x50, { 0x00, 0x00, 0xFF })
  poke(T + 0x60, { 0x10, 0x02, 0x05, 0x03, 0xF0, 0x01, 0xFF })
  poke(T + 0x70, { 0x00, 0x02, 0x81, 0xF0, 0x01, 0xFF })
  return {
    off = function(ptr, bank) return goff(ptr, bank) end,
    u8 = function(_, o) return map[o] or 0 end,
  }
end

-- opcode $20: $C925 = index, $C924 = 2; one select + step per vblank.
local function start(rec)
  local s = Sfx.new(image(rec))
  s:select(); s:step() -- boot command
  s:wr(0xC925, 0)
  s:request("countdown", 2)
  return s
end
local function frame(s) s:select(); s:step() end
local function c24(s, a) return s:rd(a) + s:rd(a + 1) * 256 + s:rd(a + 2) * 65536 end

-- Case 1: action 1 starts lower slot 0; its stream arms upper slot 0.
do
  local s = start({ 0x00, 0x08, 0x01, 0x00, 0x08, 0xFF })
  frame(s) -- SoundCountdown ($072D): install, then the first step
  ok(s:r16(0xDFAA) == 0x03FC, "FillCountdownStep: $66 * 600 / $3C")
  ok(s:rd(0xDFAD) == 0x00 and s:rd(0xDFB0) == 0x33, "header bytes copied to $DFAD")
  ok(s:r16(0xDFB1) == H + 4, "$DFB1 points past the header")
  ok(s:r16(0xDFB3) == T + 0x40 and s:r16(0xDFB5) == 0, "slot 0 record only")
  ok(s:rd(0xDFA6) == 0x81, "gate and slot 0 bit")
  ok(s:rd(0xDFBB) == 0x01, "seeded action")
  ok(c24(s, 0xDFBF) == 0x0800 - 0x03FC, "seeded count less one step")
  frame(s)
  ok(c24(s, 0xDFBF) == 0x0008, "second step")
  frame(s) -- fires action 1
  ok(s:rd(0xDFD3) == 0x01, "lower slot 0 running")
  ok(c24(s, 0xDFD4) == 0x0200, "lower count from the first delta")
  ok(s:r16(0xDFB3) == T + 0x43 and s:rd(0xDFBB) == 0xFF, "record advanced")
  ok(c24(s, 0xDFBF) == 0x040C, "advance adds the delta to the top bytes")
  frame(s) -- lower expires: upper armed, then the end mark
  ok(s:rd(0xDFD3) == 0x10, "upper slot 0 armed, lower slot 0 ended")
  ok(s:rd(0xDFE4) == 0x05 and c24(s, 0xDFE8) == 0x0300, "upper D and span")
  ok(s:r16(0xDFCB) == T + 0x67, "lower pointer past the end mark")
  ok(s:rd(0xDFAC) == 0xE4, "channel 0 packed into slot 0")
  ok(s:rd(0xC924) == 1, "still waiting")
  frame(s) -- upper expires, slot action $FF
  ok(s:rd(0xDFD3) == 0 and s:rd(0xDFA6) % 16 == 0, "all slots idle")
  ok(s:rd(0xC924) == 1, "restore waits for the next pass")
  frame(s)
  ok(s:rd(0xC924) == 0, "SoundCountdownIdle restores on frame 6")
end

-- Case 2: action $FE re-indexes the slot record.
do
  local s = start({ 0x00, 0x08, 0xFE, 0x00, 0x10, 0x00, 0x08 })
  frame(s); frame(s); frame(s)
  ok(s:r16(0xDFB3) == T + 0x50, "StepIndexedCountdown: list word plus addend")
  ok(s:rd(0xDFBB) == 0xFF, "action from the new record")
  ok(c24(s, 0xDFBF) == 0x040C, "delta added")
  ok(s:rd(0xDFD3) == 0, "no lower slot")
  frame(s); frame(s)
  ok(s:rd(0xDFA6) % 16 == 0, "slot ended")
  frame(s)
  ok(s:rd(0xC924) == 0, "restored on frame 6")
end

-- Case 3: a tag-0 lower record stores a $3FB0 byte and yields.
do
  local s = start({ 0x00, 0x08, 0x02, 0x00, 0x08, 0xFF })
  frame(s)
  s:wr(0xDFA6, s:rd(0xDFA6) + 0x40)
  frame(s); frame(s); frame(s)
  ok(s:rd(0xDFAD) == 0x55, "$3FB0 byte 1 stored for slot 0")
  ok(s:rd(0xDFA6) < 0xC0 and s:rd(0xDFA6) >= 0x80, "index below 2 clears bit 6")
  ok(s:rd(0xDFD3) == 0, "end mark after the yield")
end

-- No song table: the step stays 0 and nothing is seeded (unchanged
-- behaviour for an index at or past the limit).
do
  local s = Sfx.new(image({ 0x00, 0x08, 0xFF }))
  s:select(); s:step()
  s:wr(0xC925, 5)
  s:request("countdown", 2)
  frame(s)
  ok(s:rd(0xDFA6) == 0, "index past the limit installs nothing")
  frame(s)
  ok(s:rd(0xC924) == 0, "restored at once")
end

-- With MN_ROM: $20 lengths in frames (counts only, no bytes). 00-06 end;
-- 07 loops ($FE) and still holds $C924 after 20000 frames.
local romPath = os.getenv("MN_ROM")
local fh = romPath and io.open(romPath, "rb")
if fh then
  fh:close()
  local rom = require("mn.MnRom").fromFile(romPath)
  local want = { [0] = 580, 63, 117, 185, 7928, 13006, 7245 }
  local function length(i, cap)
    local s = Sfx.new(rom)
    s:select(); s:step()
    s:wr(0xC925, i); s:request("countdown", 2)
    local n = 0
    repeat s:select(); s:step(); n = n + 1 until s:rd(0xC924) == 0 or n >= cap
    return n, s.seqGuardHits
  end
  for i = 0, 6 do
    local n, g = length(i, 20000)
    ok(n == want[i] and not g, ("ROM $20 index %d: %d frames"):format(i, n))
  end
  local n = length(7, 20000)
  ok(n == 20000, "ROM $20 index 7 loops")
end

print(("mn_music_seq_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
