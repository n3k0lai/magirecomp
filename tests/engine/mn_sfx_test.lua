-- mn.Sfx: synthetic streams for each ported command, plus a ROM-gated
-- render of every slot id (counts only). Never plays audio.
--   luajit tests/engine/mn_sfx_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local bit = require("bit")
local band = bit.band

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Sfx = require("mn.Sfx")

local BANK = 0x30
local function goff(ptr, bank) return bank * 0x4000 + ptr - 0x4000 end

-- Sparse bank-$30 image. Period words, the nibble table, and stream bytes
-- are synthetic. Nothing here is copied from the ROM.
local function image()
  local map = {}
  local function poke(ptr, bytes)
    local o = goff(ptr, BANK)
    for i = 1, #bytes do map[o + i - 1] = bytes[i] end
  end
  local function w16(ptr, v)
    poke(ptr, { v % 256, math.floor(v / 256) % 256 })
  end
  for i = 0, 83 do w16(0x51D8 + i * 2, 0x0400 + i) end
  local nib = {}
  for i = 1, 128 do nib[i] = 0xFF end
  poke(0x564B, nib)
  local scale = {}
  for i = 1, 84 do scale[i] = 0 end
  poke(0x5282, scale)
  return {
    off = function(ptr, bank) return goff(ptr, bank) end,
    u8 = function(_, o) return map[o] or 0 end,
    poke = poke,
    w16 = w16,
  }
end

local function le(v) return { v % 256, math.floor(v / 256) % 256 } end

-- Header, one slot record, one stream. Stream address is absolute in bank $30.
local function load(rom, stream, slot)
  slot = slot or { 0, 1, 0x20, 0x0F }
  local streamAt = 0x6100
  local slotAt = 0x5E00
  rom.poke(streamAt, stream)
  rom.poke(slotAt, slot)
  -- SoundDataHeader ($5A79): phase, slots, count, waves, limit, pad, index, count, songs, count.
  local phaseOff = 0x5C00 - 0x5A79
  local slotOff = slotAt - 0x5A79
  local waveOff = 0x5F00 - 0x5A79
  rom.poke(0x5A79, {})
  rom.w16(0x5A79, phaseOff)
  rom.w16(0x5A7B, slotOff)
  rom.poke(0x5A7D, { 1 })
  rom.w16(0x5A7E, waveOff)
  rom.poke(0x5A80, { 1, 0 })
  rom.w16(0x5A82, 0)
  rom.poke(0x5A84, { 0 })
  rom.w16(0x5A85, 0)
  rom.poke(0x5A87, { 0 })
  -- tag 0 → this stream. Offset is from SoundStreamTable ($5A88).
  rom.w16(0x5A88, streamAt - 0x5A88)
  -- one wave record: 16 bytes at $6200, count 1, flag 0, bank delta 0
  local rec = {}
  for _, b in ipairs(le(0x6200)) do rec[#rec + 1] = b end
  for _, b in ipairs(le(1)) do rec[#rec + 1] = b end
  rec[#rec + 1] = 0
  rec[#rec + 1] = 0
  rom.poke(0x5F00, rec)
  local wave = {}
  for i = 1, 16 do wave[i] = 0x8F end
  rom.poke(0x6200, wave)
  -- phase-script table entry 0 points two bytes ahead, at the step word.
  rom.w16(0x5C00, 2)
  rom.poke(0x5C02, { 0x00, 0x10, 0x08 })
end

local function play(rom)
  local s = Sfx.new(rom)
  s:request("slotA", 0)
  s:select()
  s:step()
  return s
end

local function nr(s, a) return s:rd(a) end

-- InitSoundState: signature, idle slots, master volume.
do
  local s = Sfx.new(image())
  ok(s:rd(0xC91D) == 0x55, "init stores $55 at $C91D")
  ok(s:rd(0xC921) == 0xFF and s:rd(0xC922) == 0xFF, "slots start idle")
  ok(s:rd(0xDF02) == 0xF5 and s:rd(0xDF00) == 0x30, "work area signature")
  ok(s:rd(0xFF24) == 0x77 and s:rd(0xFF26) == 0x80, "ResetApu leaves NR50 and power")
  ok(s:r16(0xC91B) == 0x0659, "boot command is Store0FAtC92C")
end

-- snd_duty + snd_wait + snd_end. Channel 0, duty 2 → NR11 $80, NR51 both.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x0C, 0x02, 0x04, 0x00, 0x00, 0x00, 0x02, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xFF11), 0xC0) == 0x80, "duty 2 lands in NR11 bits 7-6")
  ok(band(nr(s, 0xFF12), 0xF0) == 0xF0, "envelope high nibble is full")
  ok(band(nr(s, 0xFF25), 0x11) == 0x11, "NR51 routes channel 0 both sides")
  ok(s:r16(0xDF7E) ~= 0, "wait leaves the stream running")
  local buf = s:render(2000)
  local peak = 0
  for i = 1, #buf do
    local v = buf[i]
    if v > peak then peak = v end
    if -v > peak then peak = -v end
    ok(v <= 1 and v >= -1, "sample in range")
    if v > 1 or v < -1 then break end
  end
  ok(peak > 0.01, "duty stream is not silent")
  local guard = 0
  while s:busy() and guard < 30 do s:select(); s:step(); guard = guard + 1 end
  ok(s:r16(0xDF7E) == 0, "snd_end clears the stream")
end

-- snd_noise on channel 3 writes NR43.
do
  local rom = image()
  load(rom, { 0x0E, 0x03, 0x10, 0x47, 0x0C, 0xFF, 0x04, 0x00, 0x00, 0x00, 0x04, 0x00 })
  local s = play(rom)
  ok(nr(s, 0xFF22) == 0x47, "snd_noise stores NR43")
  ok(band(nr(s, 0xFF25), 0x88) == 0x88, "noise channel is routed")
  local buf = s:render(800)
  local peak = 0
  for i = 1, #buf do if math.abs(buf[i]) > peak then peak = math.abs(buf[i]) end end
  ok(peak > 0, "noise stream is not silent")
end

-- snd_vibrato arms bit 0 and the step word (big-endian operand).
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x01, 0x00, 0x10, 0x04, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF09), 0x01) == 0x01, "vibrato sets slide bit 0")
  ok(s:r16(0xDF34) == 0x0010, "vibrato step is the big-endian word")
end

-- snd_glide (count 4). Bit 2 of the channel flags.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x02, 0x01, 0x00, 0x00, 0x04, 0x00, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF09), 0x04) == 0x04, "glide sets slide bit 2")
  ok(s:r16(0xDF3A) == 3, "glide count ticks once in the arming frame")
end

-- snd_ramp bit 3.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x03, 0x00, 0x02, 0x00, 0x20, 0x00, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF09), 0x08) == 0x08, "ramp sets slide bit 3")
end

-- snd_loop limit 2 then snd_end. Relative offset points at the loop opcode.
do
  local rom = image()
  -- 05 02 FF FC  00
  load(rom, { 0x0E, 0x00, 0x05, 0x02, 0xFF, 0xFC, 0x00 })
  local s = play(rom)
  ok(s:r16(0xDF7E) == 0, "finite loop falls out into snd_end")
  ok(nr(s, 0xDF8E) == 0, "loop counter clears on the last pass")
end

-- snd_loop count 0 repeats forever.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x0C, 0x02, 0x05, 0x00, 0xFF, 0xFC })
  local s = play(rom)
  for _ = 1, 40 do s:select(); s:step() end
  ok(s:r16(0xDF7E) ~= 0, "count-0 loop stays busy")
  ok(nr(s, 0xDF8E) == 40 or nr(s, 0xDF8E) > 0, "loop counter keeps climbing")
end

-- snd_jump (offset from $5A88) lands on snd_end placed at that address.
do
  local rom = image()
  local stream = { 0x0E, 0x00, 0x06, 0x00, 0x00 }
  load(rom, stream)
  local dest = 0x6300
  local off = dest - 0x5A88
  stream[4] = math.floor(off / 256)
  stream[5] = off % 256
  rom.poke(0x6100, stream)
  rom.poke(dest, { 0x00 })
  local s = play(rom)
  ok(s:r16(0xDF7E) == 0, "snd_jump reaches snd_end")
end

-- snd_slide_to stores the delta and asks for a period write.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x07, 0x30, 0x00, 0x00 }, { 0, 1, 0x10, 0x0F })
  local s = play(rom)
  ok(s:r16(0xDF23) == 0x2000, "slide-to delta is target minus the period")
end

-- snd_set_slide mode 0 writes the delta word.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x08, 0x00, 0x00, 0x20, 0x00 })
  local s = play(rom)
  ok(s:r16(0xDF23) == 0x0020, "set-slide stores the word")
end

-- snd_env_mix flags an envelope update. Nibble table is $FF, so the
-- looked-up value is 15.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x09, 0x0A, 0x00 })
  local s = play(rom)
  ok(nr(s, 0xDFF4) == 15, "env-mix looks up a nibble")
end

-- snd_pan after duty rewrites NR51. Operand 0 is left only.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x0C, 0x01, 0x0A, 0x00, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xFF25), 0x11) == 0x10, "pan left clears the right terminal")
  ok(band(nr(s, 0xDF11), 0x11) == 0x10, "own-mask follows the pan")
end

-- snd_random mode 0 writes a period byte on channel 0.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x0B, 0x00, 0x10, 0x20, 0x00, 0x00 })
  local s = play(rom)
  local hi = nr(s, 0xDF16)
  ok(hi >= 0x10 and hi < 0x20, "random period stays inside the span")
end

-- snd_release ($0D) drops NR51 and ends.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x0C, 0x02, 0x0D })
  local s = play(rom)
  ok(band(nr(s, 0xFF25), 0x11) == 0, "release clears the channel in NR51")
  ok(s:r16(0xDF7E) == 0, "release ends the stream")
end

-- snd_skip inside the program (not the channel header) consumes one byte.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x0E, 0x7F, 0x1A, 0x03, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF33), 0x08) == 0x08, "skip does not eat the next command")
end

-- snd_phase_script points $DF58 past the step word.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x0F, 0x00, 0x00 })
  local s = play(rom)
  ok(s:r16(0xDF58) == 0x5C04, "phase script cursor is past its step word")
  ok(band(nr(s, 0xDF0D), 0x0F) ~= 0, "phase script arms the phase flags")
end

-- snd_phase_up byte-swaps the step and starts at level 15.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x11, 0xFF, 0x00, 0x00 })
  local s = play(rom)
  ok(nr(s, 0xDF70) == 0x0E or nr(s, 0xDF70) == 0x0F, "phase-up level starts near 15")
  ok(s:r16(0xDF68) == 0xFF00, "phase-up stores the step byte-swapped")
end

-- snd_countdown sets the release bit.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x12, 0x00, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF0D), 0x80) == 0x80, "countdown sets phase bit 7")
end

-- snd_envelope after the open-slot write has been consumed.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x04, 0x00, 0x00, 0x00, 0x02, 0x13, 0x0A, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xFF12), 0xF0) == 0xF0, "first frame applies the slot envelope")
  -- SoundCommand04 returns to RunSoundStream, which stops the tick on $04
  -- even when the countdown just expired. The envelope command is next frame.
  s:select(); s:step()
  s:select(); s:step()
  ok(nr(s, 0xFF12) == 0xFA, "snd_envelope writes the level nibble and the operand")
end

-- snd_slide_rel adds the high byte onto $DF2A (0 at open).
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x14, 0x04, 0x00, 0x00 }, { 0, 1, 0x00, 0x0F })
  local s = play(rom)
  ok(s:r16(0xDF23) == 0x0400, "relative slide delta uses the added high byte")
end

-- snd_branch_period takes the jump when the period high is above the threshold.
do
  local rom = image()
  local stream = { 0x0E, 0x00, 0x15, 0x10, 0x00, 0x00, 0x1A, 0x01, 0x00 }
  load(rom, stream, { 0, 1, 0x20, 0x0F })
  local dest = 0x6300
  local off = dest - 0x5A88
  stream[5] = math.floor(off / 256)
  stream[6] = off % 256
  rom.poke(0x6100, stream)
  rom.poke(dest, { 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF33), 0x02) == 0, "period branch skips the bit command")
  ok(s:r16(0xDF7E) == 0, "period branch lands on snd_end")
end

-- snd_branch_random: threshold 0 always takes it (step result is >= 0).
do
  local rom = image()
  local stream = { 0x0E, 0x00, 0x16, 0x00, 0x00, 0x00, 0x1A, 0x02, 0x00 }
  load(rom, stream)
  local dest = 0x6300
  local off = dest - 0x5A88
  stream[5] = math.floor(off / 256)
  stream[6] = off % 256
  rom.poke(0x6100, stream)
  rom.poke(dest, { 0x00 })
  local before = 0xDE
  local s = Sfx.new(rom)
  ok(s:rd(0xDF03) == before, "LFSR seed is $DE")
  s:request("slotA", 0)
  s:select(); s:step()
  ok(s:rd(0xDF03) ~= before, "random branch steps $DF03")
  ok(s:r16(0xDF7E) == 0, "random branch is taken")
end

-- snd_branch_env. Slot envelope lookup is 15, threshold 1.
do
  local rom = image()
  local stream = { 0x0E, 0x00, 0x17, 0x01, 0x00, 0x00, 0x1A, 0x00, 0x00 }
  load(rom, stream)
  local dest = 0x6300
  local off = dest - 0x5A88
  stream[5] = math.floor(off / 256)
  stream[6] = off % 256
  rom.poke(0x6100, stream)
  rom.poke(dest, { 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF33), 1) == 0, "envelope branch skips the following bit")
end

-- snd_set_loop / snd_clear_loop across a wait.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x18, 0x00, 0x30, 0x04, 0x00, 0x00, 0x00, 0x01, 0x19, 0x00 })
  local s = play(rom)
  ok(s:r16(0xDF86) == 0x5A88 + 0x0030, "set-loop stores an address from $5A88")
  s:select(); s:step()
  ok(s:r16(0xDF86) == 0, "clear-loop zeroes it")
end

-- snd_df33_bit.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x1A, 0x05, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF33), 0x20) == 0x20, "df33 or's the named bit")
end

-- snd_glide_cmd ($1B) also sets the glide flag.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x1B, 0x00, 0x10, 0x00, 0x04, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF09), 0x04) == 0x04, "glide command arms bit 2")
end

-- snd_priority absolute store.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x1C, 0x01, 0x07, 0x04, 0x00, 0x00, 0x00, 0x04 })
  local s = play(rom)
  ok(nr(s, 0xDF9D) == 7, "priority command stores the value")
end

-- snd_end_23 is the same terminator.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x23 })
  local s = play(rom)
  ok(s:r16(0xDF7E) == 0 and nr(s, 0xDF9D) == 0, "opcode $23 ends like snd_end")
end

-- snd_clear_fx drops the vibrato bit and sets bit 5.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x01, 0x00, 0x01, 0x02, 0x1F, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF09), 0x01) == 0, "clear-fx drops the vibrato bit")
  ok(band(nr(s, 0xDF09), 0x40) == 0x40, "clear-fx's period bit is consumed as a write")
end

-- snd_clear_fx_slide ($20) also clears the per-tick slide sum's source word.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x20 })
  local s = play(rom)
  ok(band(nr(s, 0xDF09), 0x40) == 0x40, "opcode $20 requests a period write")
end

-- snd_phase_down flags.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x27, 0x00, 0x20, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF0D), 0x01) == 0x01, "phase-down sets the integrate flag")
  ok(s:r16(0xDF68) == 0x0020, "phase-down stores the operand word swapped")
end

-- snd_env_level ($28) stores the looked-up level at $DF2F.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x28, 0x04, 0x00 })
  local s = play(rom)
  ok(nr(s, 0xDF2F) == 15, "env-level stores the nibble lookup")
end

-- snd_wave_sweep ($1D) enables UpdateWaveDuty (bit 0 of $DF74) on channel 2.
do
  local rom = image()
  load(rom, { 0x0E, 0x02, 0x1D, 0x04, 0x10, 0x01, 0x20, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF74), 0x01) == 0x01, "wave sweep sets the duty flag")
  ok(nr(s, 0xFF1A) == 0x80, "wave DAC is on")
end

-- snd_wave_reset ($24) also raises that flag. Channel must be 2 so the
-- following period write is the wave channel; the command itself does not check.
do
  local rom = image()
  load(rom, { 0x0E, 0x02, 0x24, 0x08, 0x00 })
  local s = play(rom)
  ok(band(nr(s, 0xDF74), 0x01) == 1, "wave reset sets bit 0")
  ok(nr(s, 0xDF7C) == 0x08, "wave reset stores the width byte")
end

-- Lower priority is rejected. Second slot id needs a second record; bump count.
do
  local rom = image()
  load(rom, { 0x0E, 0x00, 0x04, 0x00, 0x00, 0x00, 0x08, 0x00 }, { 0, 5, 0x20, 0x0F })
  rom.poke(0x5A7D, { 2 })
  rom.poke(0x5E04, { 0, 1, 0x10, 0x0F })
  local s = Sfx.new(rom)
  s:request("slotA", 0)
  s:select(); s:step()
  local ptr = s:r16(0xDF7E)
  s:request("slotA", 1)
  s:select(); s:step()
  ok(s:r16(0xDF7E) == ptr, "lower priority does not replace the stream")
  ok(nr(s, 0xDF9D) == 5, "priority byte stays")
end

-- request bit 2 latches nothing unless bit 4 is set; it does arm $0709.
do
  local s = Sfx.new(image())
  s:request("request", 4)
  s:select()
  ok(s:rd(0xC91F) == 0, "select consumes the request")
  ok(s:r16(0xC91B) == 0x0709, "bit 2 arms LatchCountdownGate")
end

-- request bit 1 clears the song index and arms the drop command.
do
  local s = Sfx.new(image())
  s:wr(0xC920, 3)
  s:request("request", 2)
  s:select()
  ok(s:rd(0xC920) == 0xFF and s:r16(0xC91B) == 0x06FC, "bit 1 drops the music gate")
end

-- Sfx.host wires the three callbacks the VM already calls.
do
  local ow, h = { rom = image() }, {}
  local sfx = Sfx.host(ow, h)
  h.sfxSlot(1, 4)
  h.sfx(2)
  h.sfxRequest(1)
  ok(ow.sfx == sfx, "host stores the driver on the overworld")
  ok(sfx:rd(0xC921) == 4, "sfxSlot writes slot A")
  ok(sfx:rd(0xC91F) == 1, "sfxRequest is the last request write")
end

-- Every slot id in the player's ROM. Print counts only.
local romPath = os.getenv("MN_ROM")
if romPath and romPath ~= "" then
  local MnRom = require("mn.MnRom")
  local rom = MnRom.fromFile(romPath)
  local function u8(ptr) return rom:u8(rom.off(ptr, 0x30)) end
  local count = u8(0x5A7D)
  local ended, looping, silent = 0, 0, 0
  for id = 0, count - 1 do
    local s = Sfx.new(rom)
    s:request("slotA", id)
    local peak = 0
    local frames = 0
    while frames < 180 do
      local buf = s:render(800)
      for i = 1, #buf do
        local v = buf[i]
        local a = v < 0 and -v or v
        if a > peak then peak = a end
        if v ~= v or v > 1 or v < -1 then
          ok(false, "rom sample out of range")
          frames = 180
          break
        end
      end
      frames = frames + 1
      if not s:busy() then break end
    end
    if peak < 1e-6 then silent = silent + 1 end
    if s:busy() then looping = looping + 1 else ended = ended + 1 end
  end
  -- One slot plays a stream that only rewrites the envelope of a channel that is
  -- already open (no duty, no trigger), so on its own it is silent and ends.
  ok(silent <= 1, "every rom sfx but the envelope-only one produced a sample")
  ok(ended + looping == count, "every rom slot was rendered")
  print(("sfx rom: slots %d ended %d looping %d"):format(count, ended, looping))
end

if failures == 0 then
  print(("ok %d"):format(checks))
else
  print(("FAILED %d / %d"):format(failures, checks))
  os.exit(1)
end
