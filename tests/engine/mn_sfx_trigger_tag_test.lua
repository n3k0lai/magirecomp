-- mn.sfx.Driver sound command $26 (sound_command_trigger_tag.asm) on synthetic
-- bytes: C = the first operand on both paths, D = $DFE4 + slot, and the $4F15
-- path (bit 1 of $DF09 + slot set) keeps the slot's priority and runs the
-- prime stores before setting bit 1 again. Never plays audio.
--   luajit tests/engine/mn_sfx_trigger_tag_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local Sfx = require("mn.Sfx")
local Driver = require("mn.sfx.Driver")

local BANK = 0x30
local function goff(ptr, bank) return bank * 0x4000 + ptr - 0x4000 end

-- Every byte below is synthetic. Tag 1 -> a plain record at $6200 (first
-- byte not $0E, so OpenChannelForTag keeps C). Command operands at $6000.
local function image(e)
  local map = {}
  local function poke(ptr, bytes)
    local o = goff(ptr, BANK)
    for i = 1, #bytes do map[o + i - 1] = bytes[i] end
  end
  local off = 0x6200 - 0x5A88
  poke(0x5A8A, { off % 256, math.floor(off / 256) })
  poke(0x6200, { 0x00 })
  poke(0x6000, { e, 0x01 })
  return {
    off = function(ptr, bank) return goff(ptr, bank) end,
    u8 = function(_, o) return map[o] or 0 end,
  }
end

local function setup(e, flags, pri, pri2)
  local s = Sfx.new(image(e))
  s:wr(0xDF9C, 0)            -- current slot 0
  s:wr(0xDF09, flags)
  s:wr(0xDF9D, pri)
  s:wr(0xDF9D + 2, pri2 or 0)
  s:wr(0xDFE4, 0x5A)         -- wExpirySlotHigh, slot 0
  s:wr(0xDF16, 0x33)         -- slot 0's own period high (not the D source)
  s:wr(0xDFF4, 0x77)         -- wTagEnvelopeParam, slot 0
  s:w16(0xDF7E, 0x6123)      -- slot 0 stream pointer
  s:w16(0xDF9A, 0x5FFF)
  return s
end
local cmd26 = Driver._cmds[0x26]

-- Prime path (bit 1 clear): hint 2 opens channel 2 with B = 0.
do
  local s = setup(2, 0x00, 5)
  cmd26(s, 0x6000)
  ok(s:r16(0xDF7E + 4) == 0x6200, "prime: channel 2 from the first operand")
  ok(s:rd(0xDF9D + 2) == 0, "prime: priority forced to 0")
  ok(s:rd(0xDF09 + 2) == 0x20, "prime: bit 1 clear, bit 5 set")
  ok(s:rd(0xDF0D + 2) % 64 >= 32, "prime: $DF0D bit 5")
  ok(s:rd(0xDFF4 + 2) == 0x77, "prime: envelope from the slot")
  ok(s:rd(0xDF16 + 4) == 0x5A and s:rd(0xDF15 + 4) == 0, "prime: D from $DFE4 + slot")
  ok(s:r16(0xDF9A) == 0x6002, "prime: other channel, cursor past the operands")
end

-- $4F15 path (bit 1 set): B = the slot's priority, so a higher one rejects.
do
  local s = setup(2, 0x02, 3, 4)
  cmd26(s, 0x6000)
  ok(s:r16(0xDF7E + 4) == 0, "D1: priority 3 below 4 rejects")
  ok(s:r16(0xDF9A) == 0x6002, "D1 reject: cursor past the operands")
end
do
  local s = setup(2, 0x02, 3, 2)
  cmd26(s, 0x6000)
  ok(s:r16(0xDF7E + 4) == 0x6200 and s:rd(0xDF9D + 2) == 3, "D1: opens channel 2 at the slot's priority")
  ok(s:rd(0xDF09 + 2) == 0x22, "D1: prime stores, then bit 1 set again")
  ok(s:rd(0xDFF4 + 2) == 0x77 and s:rd(0xDF16 + 4) == 0x5A, "D1: envelope and D stored")
  ok(s:rd(0xDFFE) == 1, "D1: D = 1 for the period fold")
end

-- Hint 0 is the current slot: the cursor reloads from its new stream word.
do
  local s = setup(0, 0x00, 0)
  cmd26(s, 0x6000)
  ok(s:r16(0xDF9A) == 0x6200, "same slot: cursor reloaded")
end

print(("mn_sfx_trigger_tag_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
