-- opcode_05.asm: CopyThreeScriptBytesAndHandler stores DispatchScriptOpcode next to the
-- record's anim field, so the game runs that field as a script whatever bank it is in.
-- The port used to decide by bank (0E/0F/10/11/20/25 = static sprite anim, else a VM
-- thread), which froze twelve real record scripts (25:7211 choreography on maps 236/237,
-- 11:7039's $47 random pick, 0E:5EA8, 11:7596, 11:75C8, 11:7900). Now Sprites.isAnim
-- decides by content, and a thread's $4C/$4D/$4E/$4F show their lists through animAt.
-- ROM-free: synthetic bytes in an otherwise empty 2 MiB image.
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local Sprites = require("mn.Sprites")

local img = {}
local function put(bank, ptr, bytes)
  img[#img + 1] = { bank * 0x4000 + ptr - 0x4000, string.char((table.unpack or unpack)(bytes)) }
end
-- 11:4000 pure loop: $4C (3 frames, list $5000), $46 back
put(0x11, 0x4000, { 0x4C, 0x03, 0x00, 0x00, 0x00, 0x50, 0x00, 0x46, 0x00, 0x40 })
-- 11:4010 mixed: $4C 2 frames, $48 yield, $4C 2 frames, $42
put(0x11, 0x4010, { 0x4C, 0x02, 0x00, 0x00, 0x10, 0x50, 0x00, 0x48,
  0x4C, 0x02, 0x00, 0x00, 0x20, 0x50, 0x00, 0x42 })
-- 25:4000 starts with a flow op: a script even in a "sprite" bank
put(0x25, 0x4000, { 0x58, 0x01, 0x42 })
-- 05:4000 pure anim outside the old bank list: the game has no bank test
put(0x05, 0x4000, { 0x4D, 0x02, 0x04, 0x00, 0x00, 0x00, 0x50, 0x42 })
-- 22:4004 the null record: no sprite op, not an anim
put(0x22, 0x4004, { 0x42 })
-- 12:4000 a map script handing slot 3 the mixed record, then slot 4 the pure one
put(0x12, 0x4000, { 0x09, 0x03, 0x11, 0x10, 0x40, 0x09, 0x04, 0x11, 0x00, 0x40, 0x94 })
table.sort(img, function(a, b) return a[1] < b[1] end)
local parts, at = {}, 0
for _, p in ipairs(img) do
  parts[#parts + 1] = string.rep("\0", p[1] - at); parts[#parts + 1] = p[2]; at = p[1] + #p[2]
end
local s = table.concat(parts)
local rom = MnRom.new(s .. string.rep("\0", 0x200000 - #s))

ok(Sprites.isAnim(rom, 0x11, 0x4000) == true, "pure $4C/$46 loop is an anim")
ok(Sprites.isAnim(rom, 0x11, 0x4010) == false, "$48 between sprite ops makes a script")
ok(Sprites.isAnim(rom, 0x25, 0x4000) == false, "bank-25 flow script is a script")
ok(Sprites.isAnim(rom, 0x05, 0x4000) == true, "pure $4D anim outside the old banks is an anim")
ok(Sprites.isAnim(rom, 0x22, 0x4004) == false, "the null record is not an anim")
ok(Sprites.isAnim(rom, 0x11, 0x3000) == false, "a pointer outside $4000-$7FFF is not an anim")

local shown, anims = {}, {}
local host = {
  isSpriteBank = function(b, p) return Sprites.isAnim(rom, b, p) end,
  animAt = function(slot, b, p) shown[#shown + 1] = ("%d %02X:%04X"):format(slot, b, p) end,
  setAnim = function(slot, recs) anims[#anims + 1] = ("%d %02X:%04X"):format(slot, recs[1][1], recs[1][2]) end,
}
local vm = VM.new(rom, host)
vm:start(0x12, 0x4000)
ok(vm.threads and vm.threads[3] ~= nil, "$09 with a mixed record starts a thread")
ok(not (vm.threads and vm.threads[4]), "$09 with a pure anim does not")
ok(anims[1] == "4 11:4000", "the pure anim goes to setAnim")
for _ = 1, 12 do vm:tickThreads(false) end
ok(shown[1] == "3 11:4010", "first $4C shows its list")
ok(shown[2] == "3 11:4018", "second $4C after the $48 yield shows its list")
ok(#shown == 2, "nothing else drawn (" .. #shown .. ")")
ok(not vm.threads[3], "the record script ends at $42")

print(("%d/%d checks passed  (mn_record_script_anim_test)"):format(checks - failures, checks))
if failures > 0 then os.exit(1) end
