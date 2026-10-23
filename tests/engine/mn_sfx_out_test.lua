-- SfxOut queues sfx:render and stays silent when audio is dummy or muted.
--   luajit tests/engine/mn_sfx_out_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local ffi = require("ffi")
ffi.cdef[[ int setenv(const char *n, const char *v, int overwrite); int unsetenv(const char *n); ]]
local function env(name, value)
  if value == nil then ffi.C.unsetenv(name) else ffi.C.setenv(name, value, 1) end
end

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Sfx = require("mn.Sfx")
local SfxOut = require("mn.SfxOut")

local function clearAudioEnv()
  env("SDL_AUDIODRIVER", nil)
  env("MN_NOMUSIC", nil)
  env("MN_MUTE", nil)
end

local function romImage(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

-- Unmuted: a stub device records the queue and must be asked to play.
do
  clearAudioEnv()
  local created, plays, queued = {}, 0, {}
  love = { -- luacheck: ignore 111
    audio = {
      newQueueableSource = function(rate, bits, ch, buffers)
        created[#created + 1] = { rate, bits, ch, buffers }
        return {
          queue = function(_, sd) queued[#queued + 1] = sd end,
          play = function() plays = plays + 1 end,
          isPlaying = function() return plays > 0 end,
          getFreeBufferCount = function() return 4 end,
        }
      end,
    },
    sound = {
      newSoundData = function(n, rate, bits, ch)
        return {
          n = n, rate = rate, bits = bits, ch = ch,
          setSample = function() end,
        }
      end,
    },
  }
  local out = SfxOut.new(romImage({ 0 }))
  ok(out.muted == false and out.src ~= nil, "unmuted builds a source")
  ok(#created == 1 and created[1][1] == 44100 and created[1][2] == 16
    and created[1][3] == 1 and created[1][4] == 4, "source is mono 44100 16-bit, four buffers")
  ok(plays == 0, "constructing the source does not play")
  out.sfx.render = function(_, n)
    local t = {}
    for i = 1, n do t[i] = 0 end
    return t
  end
  out:update(735 / 44100)
  ok(#queued == 1 and queued[1].n == 735 and queued[1].rate == 44100
    and queued[1].bits == 16 and queued[1].ch == 1, "one frame queues 735 mono samples")
  ok(plays == 1, "unmuted play starts the queue")
  out:update(735 / 44100)
  ok(#queued == 2 and queued[2].n == 735 and plays == 1, "a playing source is not started again")
end

-- Muted paths never construct a source and never call play. The driver still steps.
local function muteCase(label, apply)
  clearAudioEnv()
  local plays, created = 0, 0
  love = { -- luacheck: ignore 111
    audio = {
      newQueueableSource = function() created = created + 1; return { play = function() plays = plays + 1 end } end,
      play = function() plays = plays + 1 end,
    },
    sound = { newSoundData = function() plays = plays + 1 end },
  }
  apply()
  local out = SfxOut.new(romImage({ 0 }))
  local stepped = 0
  out.sfx.render = function(_, n) stepped = n; return { 0 } end
  out:update(735 / 44100)
  ok(out.muted == true and out.src == nil, label .. " builds no source")
  ok(created == 0 and plays == 0, label .. " never creates or plays")
  ok(stepped == 735, label .. " still renders the samples due")
end

muteCase("dummy driver", function() env("SDL_AUDIODRIVER", "dummy") end)
muteCase("MN_NOMUSIC", function() env("MN_NOMUSIC", "1") end)
muteCase("MN_MUTE", function() env("MN_MUTE", "1") end)
muteCase("no love.audio", function() love.audio = nil end)

-- $1E $21 $22 $23 copy into the driver SfxOut owns.
do
  clearAudioEnv()
  env("MN_MUTE", "1")
  love = {} -- luacheck: ignore 111
  local function run(bytes)
    local rom = romImage(bytes)
    local ow = { rom = rom, sfxOut = SfxOut.new(rom) }
    local h = {}
    local sfx = Sfx.host(ow, h)
    local vm = VM.new(rom, h)
    vm:start(0x12, 0x4000)
    return vm, sfx, ow
  end
  local vm, sfx, ow = run({ 0x1E, 0x97 })
  ok(ow.sfx == ow.sfxOut.sfx and sfx == ow.sfx, "$1E uses the SfxOut driver")
  ok(vm:rd8(0xC91F) == 4 and sfx:rd(0xC91F) == 4, "$1E sets wSoundRequest to 4 on the driver")
  vm, sfx = run({ 0x21, 0x97 })
  ok(vm:rd8(0xC91F) == 1 and sfx:rd(0xC91F) == 1, "$21 sets wSoundRequest to 1 on the driver")
  vm, sfx = run({ 0x22, 0x2F, 0x97 })
  ok(sfx:rd(0xC92C) == 0x0F and sfx:rd(0xC928) == 0 and sfx:rd(0xC929) == 0
    and sfx:rd(0xC92A) == 4, "$22 selects sound 4 with the low nibble")
  ok(vm:rd8(0xC92A) == 4 and vm:rd8(0xC92C) == 0x0F, "$22 still writes the VM copy")
  vm, sfx = run({ 0x23, 0x2F, 0x97 })
  ok(sfx:rd(0xC929) == 3 and sfx:rd(0xC928) == 0 and sfx:rd(0xC92C) == 0
    and sfx:rd(0xC92A) == 2, "$23 selects sound 2 with the high nibble plus one")
  -- One field frame: SelectSoundCommand consumes request 4 and arms $0709.
  vm, sfx, ow = run({ 0x1E, 0x97 })
  ow.sfxOut:update(735 / 44100)
  ok(sfx:rd(0xC91F) == 0 and sfx:r16(0xC91B) == 0x0709, "$1E arms SoundRequestBit2 on the next frame")
end

clearAudioEnv()
print(("mn_sfx_out: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
