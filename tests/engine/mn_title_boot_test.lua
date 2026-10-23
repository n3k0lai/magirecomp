-- Title boot helpers: reset WRAM defaults, save install without resume, and
-- the 2A:734B Start poll. Synthetic bytes only unless MN_ROM is set.
--   luajit tests/engine/mn_title_boot_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local SaveFile = require("mn.SaveFile")
local Title = require("mn.boot.Title")

local function romWith(stamp)
  local s = string.rep("\0", 0x200000)
  local base = 7 * 0x4000
  s = s:sub(1, base) .. stamp .. s:sub(base + #stamp + 1)
  return MnRom.new(s)
end

local function vm(stamp)
  return VM.new(romWith(stamp or string.rep("\0", 16)), {})
end

local function env(map)
  return function(name) return map[name] end
end

-- choose: keyboard default stays Continue until pictures land; the two old boots stay put.
do
  ok(Title.choose(env({}), {}) == "continue", "keyboard default stays Continue (title is opt-in)")
  ok(Title.choose(env({ MN_TITLE = "1" }), {}) == "title", "MN_TITLE=1 boots the title from the keyboard")
  ok(Title.choose(env({ MN_NEWGAME = "1" }), {}) == "continue", "MN_NEWGAME stays Continue")
  ok(Title.choose(env({}), { test = true }) == nil, "--mn-test stays the map harness")
  ok(Title.choose(env({ MN_TITLE = "1" }), { test = true }) == "title", "MN_TITLE boots the title under --mn-test")
  ok(Title.choose(env({ MN_TITLE = "1", MN_NEWGAME = "1" }), { test = true }) == "title", "MN_TITLE wins over MN_NEWGAME")
  ok(Title.choose(env({ MN_LOAD = "/tmp/x" }), {}) == nil, "MN_LOAD skips the title")
  ok(Title.choose(env({ MN_BATTLE_TEST = "1" }), {}) == nil, "MN_BATTLE_TEST skips the title")
  ok(Title.choose(env({ MN_TITLE = "1", MN_LOAD = "snap" }), {}) == nil, "MN_LOAD wins over MN_TITLE")
end

-- SetupDefaultState + FinishStartup bytes, including the quad pattern.
do
  local v = vm()
  Title.applyDefaults(v)
  for _, pair in ipairs(Title.defaults()) do
    ok(v:rd8(pair[1]) == pair[2], string.format("default $%04X", pair[1]))
  end
  ok(v:rd8(0xC710) == 0x02 and v:rd8(0xC711) == 0x14, "quad at $C70E")
  ok(v:rd8(0xC717) == 0x02 and v:rd8(0xC718) == 0x14, "quad at $C715")
  ok(v:rd8(0xC71E) == 0x02 and v:rd8(0xFFAA) == 3 and v:rd8(0xFFAB) == 3, "quad tail and menu bits")
  ok(v:rd8(0xCCA6) == 0 and v:rd8(0xC6F3) == 0 and v:rd8(0xC6EF) == 3, "title flags start clear")
end

-- A valid image is installed. The resume triple is readable and not started.
do
  local stamp = string.char(0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE,
    0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF)
  local zero = string.rep("\0", SaveFile.BANK_SIZE)
  local live = SaveFile.writeStamp(zero, stamp)
  live = SaveFile.poke(live, 0xA000, 2)
  live = SaveFile.poke(live, 0xA012, 0x1F)
  live = SaveFile.poke(live, 0xA013, 0x0C)
  live = SaveFile.poke(live, 0xA014, 0x50)
  live = SaveFile.poke(live, 0xA017, 1)
  local banks = {
    [0] = SaveFile.poke(SaveFile.writeStamp(zero, stamp), 0xA000, 2),
    [1] = zero, [2] = live, [3] = zero,
  }
  local v = vm(stamp)
  local started = false
  v.host = { run = function() started = true end }
  ok(Title.installSave(v, SaveFile.encode(banks)) == true, "valid save installs")
  ok(v:rd8(0xA017) == 1, "installed save keeps $A017")
  ok(v:rd8(0xA012) == 0x1F and v:rd16(0xA013) == 0x500C, "resume triple is stored")
  ok(started == false, "install does not run the saved script")
  ok(Title.installSave(v, nil) == false, "nil data installs nothing")
  ok(Title.installSave(v, "short") == false, "short file installs nothing")
  local bad = SaveFile.poke(banks[0], 0xA002, 0)
  local banksBad = { [0] = bad, [1] = zero, [2] = live, [3] = zero }
  local v2 = vm(stamp)
  local okSave, why = Title.installSave(v2, SaveFile.encode(banksBad))
  ok(okSave == false and why == "rejected", "bad stamp is rejected")
  ok(v2:rd8(0xA017) == 0, "rejected save does not write $A017")
end

-- 2A:734B: a miss waits one frame; Start is bit 3 and does not wait.
do
  local v = vm()
  Title.applyDefaults(v)
  local down = false
  Title.attachPoll(v, function(kind) return kind == "start" and down end)
  local function run(atPoll, pressed)
    down = pressed
    local seen, yielded
    -- The coroutine body is outside the scope of `local co = create(...)`,
    -- so the pcs key has to be coroutine.running(), the same key the hook uses.
    local co
    co = coroutine.create(function()
      v.pcs[coroutine.running()] = atPoll and Title.POLL or 0
      seen = v:rd8(0xC932)
    end)
    v.co = co
    local okRun, why, arg = coroutine.resume(co)
    if okRun and why == "wait" then
      yielded = arg
      down = true
      coroutine.resume(co)
    end
    return seen, yielded, coroutine.status(co)
  end
  local seen, yielded, status = run(true, false)
  ok(yielded == 1 and seen == 0x08 and status == "dead", "poll miss waits, then Start is bit 3")
  seen, yielded, status = run(true, true)
  ok(yielded == nil and seen == 0x08 and status == "dead", "Start already down does not wait")
  seen, yielded, status = run(false, false)
  ok(yielded == nil and seen == 0 and status == "dead", "other reads keep the cleared joypad byte")
end

if os.getenv("MN_ROM") then
  local live = MnRom.fromFile(os.getenv("MN_ROM"))
  local at = MnRom.off(Title.PTR, Title.BANK)
  ok(live:u8(at) == 0x45, "22:418E is EnterScriptFromLookup")
  ok(live:u8(Title.POLL) == 0x43, "2A:734B is the lookup opcode")
  ok(live:u16(Title.POLL + 2) == 0xC932, "poll address is $C932")
  ok(live:u8(Title.POLL + 4) == 0x08, "poll mask is Start")
end

if failures > 0 then
  print(string.format("%d checks, %d failed", checks, failures))
  os.exit(1)
end
print(string.format("ok %d checks", checks))
