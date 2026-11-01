-- Fades, the $30 wipe and sound-cue timing. Made-up bytes only.
-- $6C steps eight live words (BG palettes 6 and 7) one channel each, then
-- sprays the post-step word at $C7DB onto color 0 of palettes 0, 1, 3, 4
-- and 6, plus 2 and 5 when $C9E2 / $C9E3 are set. FinishStartup's loop
-- burns those passes with the LCD off. $30's third byte follows opcode_30.asm.
-- $1B-$24 arm a command that SelectSoundCommand takes on the next field
-- pass, before the next opcode. The spiral shows one empty frame, then one
-- frame per block, then FinishStartup with no bare-map frame and no extra select.
--   luajit tests/engine/mn_fade_screen_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end }, graphics = {} } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Op = require("mn.Opcodes")
local Panels = require("mn.ops.Panels")
local Overworld = require("mn.Overworld")
local SfxOut = require("mn.SfxOut")

local function image(at)
  local t = {}
  for i = 1, 0x13 * 0x4000 do t[i] = 0 end
  for addr, bytes in pairs(at) do
    local bank, a = addr[1], addr[2]
    for i, v in ipairs(bytes) do t[bank * 0x4000 + a - 0x4000 + i] = v end
  end
  local parts = {}
  for i = 1, #t, 4096 do parts[#parts + 1] = string.char(unpack(t, i, math.min(i + 4095, #t))) end
  local s = table.concat(parts)
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

local function rgb(r, g, b) return r + g * 32 + b * 1024 end
local C7AB = 0xC7AB
local function wrw(vm, a, w) vm:wr8(a, w % 256); vm:wr8(a + 1, math.floor(w / 256) % 256) end
local function rdw(vm, a) return vm:rd8(a) + vm:rd8(a + 1) * 256 end
local function pal(vm, i, c) return rdw(vm, C7AB + i * 8 + c * 2) end

local CALLS = { 0xCD, 0x6E, 0x56, 0xCD, 0xB1, 0x56, 0xCD, 0xCF, 0x56, 0xCD, 0xC0, 0x56, 0xC3 }

local rom = image({
  [{ 0x07, 0x56FD }] = CALLS,
  -- startup: $6C split $41 (2 frames, 1 tick) then a marker. No field frame before it.
  [{ 0x12, 0x4000 }] = { 0x93, 0x6C, 0x41, 0x00, 0x00, 0x56, 0x09, 0x94 },
  -- LCD on: the same $6C waits 2 frames before the marker.
  [{ 0x12, 0x4020 }] = { 0x6C, 0x41, 0x00, 0x00, 0x56, 0x09, 0x42 },
  -- startup $6F is instant; LCD-on $6F waits one frame.
  [{ 0x12, 0x4040 }] = { 0x93, 0x6F, 0x07, 0x00, 0x00, 0x56, 0x0A, 0x94 },
  [{ 0x12, 0x4060 }] = { 0x6F, 0x07, 0xFF, 0x7F, 0x56, 0x0B, 0x42 },
  -- startup $76 split $45 (5 ticks of 2) finishes before the marker.
  [{ 0x12, 0x4080 }] = { 0x93, 0x76, 0x45, 0x07, 0x56, 0x0C, 0x94 },
  -- $6C one tick, so the slot spray is visible before the park.
  [{ 0x12, 0x40A0 }] = { 0x6C, 0x01, 0x00, 0x00, 0x42 },
  [{ 0x12, 0x40B0 }] = { 0x6C, 0x01, 0xFF, 0x7F, 0x42 },
  [{ 0x12, 0x40C0 }] = { 0x6C, 0x01, 0x00, 0x80, 0x42 },
  -- $30 sound byte. Word 0000 is not the wipe (see docs/mn-outliers.md).
  [{ 0x12, 0x4100 }] = { 0x30, 0x00, 0x00, 0x27, 0x56, 0x0D, 0x42 },
  [{ 0x12, 0x4120 }] = { 0x30, 0x00, 0x00, 0x27, 0x56, 0x0E, 0x42 },
  [{ 0x12, 0x4140 }] = { 0x30, 0x00, 0x00, 0xFF, 0x56, 0x0F, 0x42 },
  -- spiral: music $05, then a marker, then $94.
  [{ 0x12, 0x4160 }] = { 0x30, 0xED, 0x56, 0x05, 0x56, 0x11, 0x94 },
  -- sound cues, each followed by one frame then a marker.
  [{ 0x12, 0x4200 }] = { 0x1B, 0x07, 0x40, 0x01, 0x56, 0x21, 0x42 },
  [{ 0x12, 0x4220 }] = { 0x1C, 0x08, 0x40, 0x01, 0x56, 0x22, 0x42 },
  [{ 0x12, 0x4240 }] = { 0x1D, 0x40, 0x01, 0x56, 0x23, 0x42 },
  [{ 0x12, 0x4260 }] = { 0x1E, 0x40, 0x01, 0x56, 0x24, 0x42 },
  [{ 0x12, 0x4280 }] = { 0x1F, 0x05, 0x40, 0x01, 0x56, 0x25, 0x42 },
  [{ 0x12, 0x42A0 }] = { 0x20, 0x07, 0x40, 0x01, 0x56, 0x26, 0x42 },
  [{ 0x12, 0x42C0 }] = { 0x21, 0x40, 0x01, 0x56, 0x27, 0x42 },
  [{ 0x12, 0x42E0 }] = { 0x22, 0x2F, 0x40, 0x01, 0x56, 0x28, 0x42 },
  [{ 0x12, 0x4300 }] = { 0x23, 0x2F, 0x40, 0x01, 0x56, 0x29, 0x42 },
  [{ 0x12, 0x4320 }] = { 0x24, 0x25, 0x40, 0x01, 0x56, 0x2A, 0x42 },
})

local function fillLive(vm, w)
  for i = 0, 63 do wrw(vm, C7AB + i * 2, w) end
end

-- $6C during startup: both inner frames run before the marker, LCD off the whole time.
do
  local vm = VM.new(rom, {})
  wrw(vm, 0xC7DB, 0x001F)
  vm:start(0x12, 0x4000)
  ok(vm:rd8(0xC6F8) == 0x09, "startup $6C: the marker is in the same pass")
  ok(vm:rd8(0xC7DB) == 0x1E and vm:rd8(0xC9E5) == 0x1E, "startup $6C still steps one channel")
  ok(vm.wait == 1 and vm:rd8(0xC936) == 0xE3 and vm:rd8(0xC6F3) == 1, "startup $6C: the only yield is $94, LCD back on")
end

-- LCD on: split $41 is two frames, and the step lands on the second.
do
  local vm = VM.new(rom, {})
  wrw(vm, 0xC7DB, 0x001F)
  ok(vm:start(0x12, 0x4020) and vm:rd8(0xC6F8) == 0 and vm:rd8(0xC7DB) == 0x1F, "$6C inner 2: first frame is before the step")
  vm:resume()
  ok(vm:rd8(0xC7DB) == 0x1E and vm:rd8(0xC6F8) == 0, "$6C inner 2: the step is the second frame, marker still ahead")
  vm:resume()
  ok(vm:rd8(0xC6F8) == 0x09, "$6C inner 2: the next opcode is the frame after the countdown")
end

do
  local vm = VM.new(rom, {})
  fillLive(vm, 0x1234)
  vm:start(0x12, 0x4040)
  ok(vm:rd8(0xC6F8) == 0x0A, "startup $6F: no field frame")
  local bg = true
  for i = 0, 31 do if rdw(vm, C7AB + i * 2) ~= 0 then bg = false end end
  ok(bg and rdw(vm, C7AB + 64) == 0x1234, "startup $6F $07 fills the BG live words only")
end

do
  local vm = VM.new(rom, {})
  ok(vm:start(0x12, 0x4060) and vm:rd8(0xC6F8) == 0, "$6F LCD on: one frame before the marker")
  ok(rdw(vm, C7AB) == 0x7FFF, "$6F fills before that frame's yield")
  vm:resume()
  ok(vm:rd8(0xC6F8) == 0x0B, "$6F: the marker is the next frame")
end

do
  local vm = VM.new(rom, {})
  for i = 0, 31 do wrw(vm, 0xC72B + i * 2, rgb(31, 31, 31)); wrw(vm, C7AB + i * 2, 0) end
  vm:start(0x12, 0x4080)
  ok(vm:rd8(0xC6F8) == 0x0C, "startup $76: 5 ticks of 2 frames do not yield")
  ok(pal(vm, 0, 0) == rgb(5, 5, 5), "startup $76 still steps five times")
end

-- Which words $6C changes. Pal 6 color 0 starts at red 31; colors 1-3 and
-- palette 7 start at red 10 so a spray of the post-step color 0 cannot
-- masquerade as a step.
local function armRow(vm)
  fillLive(vm, 0x0010)
  wrw(vm, 0xC7DB, 0x001F)
  for c = 1, 3 do wrw(vm, 0xC7DB + c * 2, 0x000A) end
  for c = 0, 3 do wrw(vm, 0xC7DB + 8 + c * 2, 0x000A) end
end

do
  local vm = VM.new(rom, {})
  armRow(vm)
  vm:wr8(0xC9E2, 0); vm:wr8(0xC9E3, 0)
  vm:start(0x12, 0x40A0)
  ok(pal(vm, 6, 0) == 0x001E and vm:rd8(0xC9E5) == 0x1E and vm:rd8(0xC9E6) == 0, "$6C copies the stepped $C7DB word")
  ok(pal(vm, 6, 1) == 0x0009 and pal(vm, 6, 2) == 0x0009 and pal(vm, 6, 3) == 0x0009, "$6C steps pal 6 colors 1-3, no spray")
  ok(pal(vm, 7, 0) == 0x0009 and pal(vm, 7, 3) == 0x0009, "$6C steps palette 7 and does not spray it")
  ok(pal(vm, 0, 0) == 0x001E and pal(vm, 1, 0) == 0x001E, "$6C sprays color 0 of palettes 0 and 1")
  ok(pal(vm, 3, 0) == 0x001E and pal(vm, 4, 0) == 0x001E, "$6C sprays color 0 of palettes 3 and 4")
  ok(pal(vm, 0, 1) == 0x0010 and pal(vm, 1, 2) == 0x0010 and pal(vm, 3, 3) == 0x0010 and pal(vm, 4, 1) == 0x0010,
    "$6C leaves colors 1-3 of the sprayed palettes")
  ok(pal(vm, 2, 0) == 0x0010 and pal(vm, 5, 0) == 0x0010, "$6C skips palettes 2 and 5 when $C9E2/$C9E3 are 0")
  ok(pal(vm, 2, 1) == 0x0010 and pal(vm, 8, 0) == 0x0010, "$6C leaves palette 2's other colors and the OBJ block")
  ok(vm:rd8(0xC9D8) == 0x61 and vm:rd8(0xC831) == 1, "$6C index $61, $C831 ends at 1")
  ok(vm:rd8(0xC6E4) == 0x75 and vm:rd8(0xC6E5) == 0x45 and vm:rd8(0xC6E6) == 7, "$6C plants RefreshSavedPalettes")
end

do
  local vm = VM.new(rom, {})
  armRow(vm)
  vm:wr8(0xC9E2, 1); vm:wr8(0xC9E3, 4)
  vm:start(0x12, 0x40A0)
  ok(pal(vm, 2, 0) == 0x001E and pal(vm, 5, 0) == 0x001E, "$6C sprays palettes 2 and 5 when the flags are set")
  ok(pal(vm, 2, 1) == 0x0010 and pal(vm, 5, 2) == 0x0010, "$6C flag spray is color 0 only")
end

do
  local vm = VM.new(rom, {})
  fillLive(vm, 0)
  vm:start(0x12, 0x40B0)
  ok(pal(vm, 6, 0) == rgb(1, 1, 1) and pal(vm, 0, 0) == rgb(1, 1, 1), "$6C $7FFF steps toward white, then sprays")
end

do
  local vm = VM.new(rom, {})
  wrw(vm, 0xC9E5, 0x0011); wrw(vm, 0xC7DB, 0x001F)
  vm:start(0x12, 0x40C0)
  ok(vm:rd8(0xC9DA) == 0x11 and vm:rd8(0xC9DB) == 0 and pal(vm, 6, 0) == 0x001E, "$6C bit 7 steps toward $C9E5")
end

-- A stored outer count of 0 is 256 ticks (dec of 0 is not zero).
do
  local bytes = { 0x6C, 0x00, 0x00, 0x00 }
  local img = string.rep("\0", 0x100) .. string.char(unpack(bytes)) .. string.rep("\0", 0x200000 - 0x104)
  local vm = VM.new(MnRom.new(img), {})
  wrw(vm, 0xC7DB, 0x0001)
  local h = Panels.handlers[0x6C]
  local n = Op.LEN[0x6C]
  local waited, co = 0, coroutine.create(function() return h(vm, 0x100, n, { ptr = 0x4100 }) end)
  while coroutine.status(co) ~= "dead" do
    local okr, kind, w = coroutine.resume(co)
    assert(okr, kind)
    if kind == "wait" then waited = waited + (w or 1) end
  end
  ok(waited == 256 and pal(vm, 6, 0) == 0, "$6C outer count 0 waits 256 and reaches black")
  ok(vm:rd8(0xFFA7) == 0 and vm:rd8(0xCCA6) == 0, "$6C outer 0 leaves $FFA7 clear")
end

local function cueHost()
  local music, sel = {}, {}
  return {
    music = function(v) music[#music + 1] = v end,
    sfxSelect = function(a, b, c, d) sel[#sel + 1] = { a, b, c, d } end,
  }, music, sel
end

-- $30 third byte. Index change sets $C91E; either way select clears and $C92C = $0F.
do
  local h, music, sel = cueHost()
  local vm = VM.new(rom, h)
  vm:wr8(0xC920, 0x26); vm:wr8(0xC92A, 1); vm:wr8(0xC92C, 3); vm:wr8(0xC91E, 9)
  ok(not vm:start(0x12, 0x4100), "$30 index change: same pass")
  ok(vm:rd8(0xC923) == 0x26 and vm:rd8(0xC920) == 0x27 and vm:rd8(0xC91E) == 1, "$30 saves the old index and sets wSoundActive")
  ok(vm:rd8(0xC92A) == 0 and vm:rd8(0xC92C) == 0x0F, "$30 clears wSoundSelect and sets $C92C")
  ok(music[1] == 0x27 and #sel == 1 and sel[1][1] == 0 and sel[1][4] == 0x0F, "$30 copies the select onto the driver and starts the new index")
  ok(vm:rd8(0xC6F8) == 0x0D and not vm.startupPending, "$30 word 0000 continues; FinishStartup does not run")
end

do
  local h, music, sel = cueHost()
  local vm = VM.new(rom, h)
  vm:wr8(0xC920, 0x27); vm:wr8(0xC92A, 1); vm:wr8(0xC92C, 3); vm:wr8(0xC91E, 0)
  vm:start(0x12, 0x4120)
  ok(vm:rd8(0xC920) == 0x27 and vm:rd8(0xC91E) == 0 and #music == 0, "$30 same index: no wSoundActive, music stays")
  ok(vm:rd8(0xC92A) == 0 and vm:rd8(0xC92C) == 0x0F and #sel == 1, "$30 same index still clears the select and sets $0F")
end

do
  local h, music, sel = cueHost()
  local vm = VM.new(rom, h)
  vm:wr8(0xC920, 0x26); vm:wr8(0xC92A, 1); vm:wr8(0xC92C, 3); vm:wr8(0xC91E, 0)
  vm:start(0x12, 0x4140)
  ok(vm:rd8(0xC920) == 0x26 and vm:rd8(0xC923) == 0x26 and vm:rd8(0xC92A) == 1 and vm:rd8(0xC92C) == 3,
    "$30 $FF keeps the index, the select and $C92C")
  ok(#music == 0 and #sel == 0 and vm:rd8(0xC91E) == 0, "$30 $FF does not arm sound")
end

-- Field pass: sfx select runs at the start of the next update, before the opcode after the cue.
local function field(ptr)
  local ow = setmetatable({
    input = function() return false end,
    log = {}, objects = {},
    px = 0, py = 0,
    def = { w = 20, h = 18, cells = {} },
    sfxOut = SfxOut.new(rom),
    musicLog = {},
  }, { __index = Overworld })
  ow.vm = VM.new(rom, {})
  local h = ow:host()
  h.music = function(v) ow.musicLog[#ow.musicLog + 1] = v end
  ow.vm.host = h
  local seen = {}
  local sfx = ow.sfxOut.sfx
  local sel = sfx.select
  function sfx:select()
    local row = {
      marker = ow.vm:rd8(0xC6F8),
      req = self:rd(0xC91F), idx = self:rd(0xC920),
      a = self:rd(0xC921), b = self:rd(0xC922),
      active = self:rd(0xC91E), selb = self:rd(0xC92A), vol = self:rd(0xC92C),
    }
    sel(self)
    row.cmd = self:r16(0xC91B)
    row.idxAfter = self:rd(0xC920)
    row.reqAfter = self:rd(0xC91F)
    seen[#seen + 1] = row
  end
  ow.vm:wr8(0xC920, 0x11)
  sfx:wr(0xC920, 0x11)
  sfx:wr(0xC92A, 7)
  sfx:wr(0xC92C, 1)
  ow:runScript(0x12, ptr, "cue")
  return ow, sfx, seen
end

local function landed(ptr, marker)
  local ow, sfx, seen = field(ptr)
  ok(#seen == 0 and ow.vm:rd8(0xC6F8) == 0, string.format("$%02X: the cue's own pass does not select", marker))
  ow:update()
  local row = seen[1]
  ok(row and row.marker == 0 and ow.vm:rd8(0xC6F8) == marker, string.format("$%02X: select runs before the next opcode", marker))
  return ow, sfx, row
end

do
  local ow, sfx, row = landed(0x4200, 0x21)
  ok(row.a == 0x07 and row.cmd == 0x070D, "$1B: slot A arms $070D on the next pass")
  ok(sfx:rd(0xC921) == 0xFF and ow.vm:rd8(0xC921) == 0x07, "$1B: the slot command clears the driver byte")
end

do
  local _, sfx, row = landed(0x4220, 0x22)
  ok(row.b == 0x08 and row.cmd == 0x071D, "$1C: slot B arms $071D on the next pass")
  ok(sfx:rd(0xC922) == 0xFF, "$1C: the slot command clears $C922")
end

do
  local ow, sfx, row = landed(0x4240, 0x23)
  ok(ow.vm:rd8(0xC91F) == 2 and row.req == 2, "$1D writes wSoundRequest 2 in its own pass")
  ok(row.cmd == 0x06FC and row.idxAfter == 0xFF and row.reqAfter == 0, "$1D: bit 1 arms $06FC and writes $C920 $FF in the selector")
  ok(sfx:rd(0xC91F) == 0, "$1D: the selector clears the driver request")
end

do
  local _, _, row = landed(0x4260, 0x24)
  ok(row.req == 4 and row.cmd == 0x0709 and row.idxAfter == 0x11, "$1E: bit 2 arms $0709 and leaves the index")
end

do
  local ow, _, row = landed(0x4280, 0x25)
  ok(ow.musicLog[1] == 0x05 and ow.vm:rd8(0xC91E) == 1 and ow.vm:rd8(0xC920) == 0x05, "$1F stores the index and wSoundActive in its pass")
  ok(ow.vm:rd8(0xC92A) == 0 and ow.vm:rd8(0xC92C) == 0x0F, "$1F clears the select and sets $C92C in its pass")
  ok(row.vol == 0x0F and row.selb == 0 and row.active == 0 and row.cmd == 0x066F,
    "$1F: the driver has the select bytes on the next pass; field music is h.music")
end

do
  local _, sfx, row = landed(0x42A0, 0x26)
  ok(row.cmd == 0x072D and sfx:rd(0xC924) == 1 and sfx:rd(0xC925) == 7, "$20: the countdown arms $072D on the next pass")
end

do
  local _, _, row = landed(0x42C0, 0x27)
  ok(row.req == 1 and row.cmd == 0x06FC and row.idx == 0x11 and row.idxAfter == 0x11, "$21: request 1 arms $06FC without the selector's $FF")
end

do
  local _, sfx, row = landed(0x42E0, 0x28)
  ok(row.selb == 4 and row.vol == 0x0F and row.cmd == 0x06F4, "$22: select 4 arms $06F4 on the next pass")
  ok(sfx:rd(0xC92A) == 0, "$22: SoundSelectOther clears the select when it runs")
end

do
  local _, _, row = landed(0x4300, 0x29)
  ok(row.selb == 2 and row.cmd == 0x06C1, "$23: select 2 arms $06C1 on the next pass")
end

do
  local _, sfx, row = landed(0x4320, 0x2A)
  ok(row.selb == 1 and row.idx == 0x11 and row.cmd == 0x0684 and row.idxAfter == 0xFF, "$24: bit 0 arms $0684 and writes $C920 $FF on the select")
  ok(sfx:rd(0xC929) == 3 and sfx:rd(0xC928) == 1 and sfx:rd(0xC92C) == 1, "$24: the command counts once and leaves $C92C")
end

-- Four made-up blocks. One empty frame, four block frames, then FinishStartup
-- before the next draw and before another select.
do
  local ow, sfx, seen = field(0x4160)
  local blocks = ow.overlay and ow.overlay.t
  ok(blocks == 0 and ow.vm:rd8(0xC936) == 0xE3 and ow.vm:rd8(0xC6F8) == 0, "spiral: the entry frame has no block yet")
  ok(#seen == 0 and ow.vm:rd8(0xC923) == 0x11 and ow.vm:rd8(0xC91E) == 1 and ow.vm:rd8(0xC920) == 0x05
    and sfx:rd(0xC92A) == 0 and sfx:rd(0xC92C) == 0x0F,
    "spiral: $30 stores sound before the first block's select")
  ok(ow.musicLog[1] == 0x05, "spiral: a changed index starts music in the opcode")
  local bare = false
  for i = 1, 4 do
    ow:update()
    local shown = ow.overlay and ow.overlay.t or nil
    if shown == nil and ow.vm:rd8(0xC6F8) ~= 0x11 then bare = true end
    ok(shown == i and ow.vm:rd8(0xC936) == 0xE3 and (ow.spiralHandoff == true) == (i == 4),
      "spiral block frame " .. i)
  end
  ok(#seen == 4 and seen[1].vol == 0x0F and seen[1].selb == 0 and seen[1].cmd == 0x066F,
    "spiral: one select per block, and that select sees $30's cleared select")
  ow:update()
  if ow.overlay == nil and ow.vm:rd8(0xC6F8) ~= 0x11 then bare = true end
  ok(not bare and ow.overlay == nil and ow.vm:rd8(0xC6F8) == 0x11, "spiral: FinishStartup runs before a bare field frame")
  ok(#seen == 4, "spiral: no select between the last block and FinishStartup")
  ok(ow.vm:rd8(0xC6F3) == 1 and ow.vm:rd8(0xC936) == 0xE3 and not ow.vm.startupPending, "spiral: $94 turns the LCD back on in that pass")
end

print(("mn_fade_screen_test: %d checks, %d failures"):format(checks, failures))
if failures > 0 then os.exit(1) end
