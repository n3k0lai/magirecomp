-- SRAM save file and the save-path opcodes. ROM-free: scripts are synthetic bytes.
--   luajit tests/engine/mn_save_test.lua
-- With MN_ROM and MN_SAVE_HEADLESS=1, also checks that a save taken from a
-- headless run of MN_FRAMES frames resumes on the same map.
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path
love = love or { math = { random = function(a) return a or 0 end } } -- luacheck: ignore 111

local bit = require("bit")
local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local MnRom = require("mn.MnRom")
local VM = require("mn.ScriptVM")
local SaveFile = require("mn.SaveFile")
local Save = require("mn.ops.Save")

local function image(bytes)
  local pre = string.rep("\0", 0x12 * 0x4000)
  local s = pre .. string.char(unpack(bytes))
  return MnRom.new(s .. string.rep("\0", 0x200000 - #s))
end

local function memfs()
  local box = {}
  return {
    box = box,
    write = function(path, data) box[path] = data; return true end,
    read = function(path) return box[path] end,
    createDirectory = function() return true end,
  }
end

local function sram(vm)
  local t = {}
  for a = 0xA000, 0xBFFF do t[#t + 1] = string.char(vm:rd8(a)) end
  return table.concat(t)
end

local function digits(vm)
  return vm:rd8(0xC949), vm:rd8(0xC94A), vm:rd8(0xC94B), vm:rd8(0xC94C)
end

-- round trip: distinctive SRAM, file, fresh VM, same live bank
do
  local stamp = string.char(0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE,
    0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF)
  local zero = string.rep("\0", SaveFile.BANK_SIZE)
  local live = SaveFile.writeStamp(zero, stamp)
  live = SaveFile.poke(live, 0xA000, 2)
  live = SaveFile.poke(live, 0xA012, 0x1F)
  live = SaveFile.poke(live, 0xA013, 0x0C)
  live = SaveFile.poke(live, 0xA014, 0x50)
  live = SaveFile.poke(live, 0xA015, 4)
  live = SaveFile.poke(live, 0xA016, 9)
  live = SaveFile.poke(live, 0xA123, 0x2A)
  live = SaveFile.poke(live, 0xA124, 0x01)
  live = SaveFile.poke(live, 0xA3A7, 3)
  local banks = { [0] = SaveFile.poke(SaveFile.writeStamp(zero, stamp), 0xA000, 2),
    [1] = zero, [2] = live, [3] = zero }
  local fs = memfs()
  ok(SaveFile.writeFile(fs, SaveFile.PATH, banks) == true, "write returns")
  ok(#fs.box[SaveFile.PATH] == SaveFile.BANK_SIZE * 4, "file is four banks")
  local got = SaveFile.readFile(fs, SaveFile.PATH)
  local acc, w = SaveFile.accept(got, stamp)
  ok(acc ~= nil and w == 0, "flag 2 mirrors onto bank 0")
  ok(acc and acc[w] == live, "live bank survives the mirror")
  local vm = VM.new(image({ 0 }), {})
  Save.install(vm, acc, w)
  ok(sram(vm) == live, "fresh VM SRAM matches the saved bank")
  ok(vm:rd8(0xA123) == 0x2A and vm:rd8(0xA3A7) == 3, "story word and item survived")
  local b, p, x, y = Save.resume(vm)
  ok(b == 0x1F and p == 0x500C and x == 4 and y == 9, "resume triple and cell")
end

-- signature: a flipped stamp byte, a bad flag, and a short file are rejected
do
  local stamp = string.rep("\1", 16)
  local banks = SaveFile.wipe(stamp)
  ok(SaveFile.stampOk(banks[0], stamp), "wipe plants the stamp on bank 0")
  ok(SaveFile.peek(banks[0], 0xA012) == 0x22, "wipe mark past the stamp")
  ok(SaveFile.peek(banks[2], 0xBFF0) == stamp:byte(16), "reversed stamp on bank 2")
  local acc = SaveFile.accept(banks, stamp)
  ok(acc ~= nil, "a wiped image is accepted")
  local raw = SaveFile.encode(banks)
  local bad = raw:sub(1, 2) .. string.char(bit.bxor(raw:byte(3), 0xFF)) .. raw:sub(4)
  local decoded = SaveFile.decode(bad)
  ok(SaveFile.accept(decoded, stamp) == nil, "corrupt stamp is rejected")
  local tail = SaveFile.poke(banks[0], 0xBFF0, 0x5A)
  local flagged = { [0] = tail, [1] = banks[1], [2] = banks[2], [3] = banks[3] }
  ok(SaveFile.accept(flagged, stamp) == nil, "bad tail is rejected")
  local flag = SaveFile.poke(banks[0], 0xA000, 1)
  ok(SaveFile.accept({ [0] = flag, [1] = banks[1], [2] = banks[2], [3] = banks[3] }, stamp) == nil,
    "flag other than 0 or 2 is rejected")
  ok(SaveFile.decode(raw:sub(1, 100)) == nil, "short file is rejected")
  ok(SaveFile.accept(decoded, string.rep("\0", 16)) == nil, "wrong stamp is rejected")
end

-- opcodes on synthetic bytes. Each image is one opcode; the zeros after it are $00.
local function runOp(bytes, host, prep)
  local vm = VM.new(image(bytes), host or {})
  vm.saveFs = memfs()
  if prep then prep(vm) end
  vm:runInit(0x12, 0x4000)
  return vm
end

do
  local vm = runOp({ 0xAD, 0xA5, 0xA3, 0xE7, 0x03 })
  ok(vm:rd8(0xA3A5) == 0xE7 and vm:rd8(0xA3A6) == 0x03, "$AD stores the word little-endian")

  vm = runOp({ 0x92, 0x00 }, nil, function(v)
    v:wr8(0xC18E, 5); v:wr8(0xC18F, 8)
    v:wr8(0xA123, 0x11)
  end)
  ok(vm:rd8(0xA015) == 5 and vm:rd8(0xA016) == 8, "$92 copies the script-base cell")
  ok(vm:rd8(0xA017) == 1, "$92 sets the save mark")
  ok(vm:rd8(0xA123) == 0x11, "$92 keeps the story word")
  ok(vm:rd8(0xA000) == 2, "$92 leaves the active-bank flag")
  ok(vm.saveFs.box[SaveFile.PATH] ~= nil, "$92 writes the slot file")
  local again = VM.new(image({ 0 }), {})
  local acc, w = SaveFile.accept(SaveFile.decode(vm.saveFs.box[SaveFile.PATH]), Save.romStamp(again))
  ok(acc ~= nil, "$92 file passes the signature check")
  if acc then Save.install(again, acc, w) end
  ok(acc ~= nil and sram(again) == sram(vm), "$92 file reloads into an identical SRAM")

  local zero = string.rep("\0", SaveFile.BANK_SIZE)
  vm = runOp({ 0x92, 0x01 }, { playerCell = function() return 4, 7 end }, function(v)
    v:wr8(0xC18E, 1); v:wr8(0xC18F, 1)
    v.sramBank = 2
    v.sramBanks = { [0] = zero, [1] = zero, [2] = zero, [3] = zero }
    v.sramBanks[3] = SaveFile.poke(SaveFile.poke(zero, 0xA007, 0x34), 0xA008, 0x12)
  end)
  ok(vm:rd8(0xA015) == 4 and vm:rd8(0xA016) == 7, "$92 uses the player cell when the host has one")
  local nb = vm.sramBanks[1]
  ok(SaveFile.peek(nb, 0xA005) == 0x34 and SaveFile.peek(nb, 0xA006) == 0x12,
    "$92 copies the map word in the next SRAM bank")

  vm = runOp({ 0x92, 0x00 }, nil, function(v)
    v.sramBank = 2
    v.sramBanks = { [0] = zero, [1] = zero, [2] = zero,
      [3] = SaveFile.poke(zero, 0xA007, 0x99) }
  end)
  ok(SaveFile.peek(vm.sramBanks[3], 0xA005) == 0, "$92 operand 0 skips the map-word copy")

  vm = runOp({ 0x98, 0xB0, 0xA2 }, nil, function(v) v:wr8(0xA2B0, 42) end)
  local a, b, c, d = digits(vm)
  ok(a == 0x30 and b == 0x34 and c == 0x32 and d == 0xFC, "$98 formats the pointed byte")
  ok(vm:rd8(0xC93D) == 0x49 and vm:rd8(0xC93E) == 0xC9, "$98 points the list tail at the digits")
  ok(vm:rd8(0xC92F) == 0 and vm:rd8(0xC92E) == 4 and vm:rd8(0xC92D) == 2, "$98 digit places")

  vm = runOp({ 0x9E, 0x00, 0xA1 }, nil, function(v) v:wr8(0xA100, 0x00); v:wr8(0xA101, 0x01) end)
  a, b, c, d = digits(vm)
  ok(a == 0x32 and b == 0x35 and c == 0x36 and d == 0xFC, "$9E formats the pointed word")

  vm = runOp({ 0x9E, 0x00, 0xA1 }, nil, function(v) v:wr8(0xA100, 0xFF); v:wr8(0xA101, 0x03) end)
  a, b, c = digits(vm)
  ok(a == 0x3A and b == 0x32 and c == 0x33, "$9E keeps a hundreds digit of 10")
end

-- Headless: a save built from the map-entry script of an MN_FRAMES run, loaded
-- with MN_SAVE_LOAD, is on that same map. Prints only pass/fail and the map.
local function headless()
  if os.getenv("MN_SAVE_HEADLESS") ~= "1" then return end
  local romPath = os.getenv("MN_ROM")
  if not romPath then print("FAIL headless needs MN_ROM"); failures = failures + 1; return end
  local frames = os.getenv("MN_FRAMES") or "180"
  local function run(extra, out)
    os.execute("mkdir -p " .. out)
    local cmd = "MN_FRAMES=" .. frames .. " MN_START=1 MN_IDLE_ON=1 MN_NOMUSIC=1 POKEPORT_IDENTITY=mn-save-hl "
      .. extra .. " ~/Code/interns/bin/mn-headless love . --mn --rom " .. romPath
      .. " --mn-test " .. out
    local f = assert(io.popen(cmd))
    local text = f:read("*a")
    f:close()
    return text
  end
  local first = run("", "/tmp/mn-save-hl-a")
  local map = first:match("final player %d+,%d+ map (%d+)")
  local bank, ptr = first:match("script (%x+):(%x+) %(map entry%)")
  ok(map ~= nil and bank ~= nil, "headless run reports a map and an entry script")
  if not map then return end
  local rf = assert(io.open(romPath, "rb"))
  rf:seek("set", 7 * 0x4000)
  local stamp = rf:read(16)
  rf:close()
  local zero = string.rep("\0", SaveFile.BANK_SIZE)
  local live = SaveFile.writeStamp(zero, stamp)
  live = SaveFile.poke(live, 0xA000, 2)
  live = SaveFile.poke(live, 0xA012, tonumber(bank, 16))
  local p = tonumber(ptr, 16)
  live = SaveFile.poke(live, 0xA013, bit.band(p, 0xFF))
  live = SaveFile.poke(live, 0xA014, bit.rshift(p, 8))
  local banks = {
    [0] = SaveFile.poke(SaveFile.writeStamp(zero, stamp), 0xA000, 2),
    [1] = zero, [2] = live, [3] = zero,
  }
  local path = "/tmp/mn-save-slot.sav"
  local wf = assert(io.open(path, "wb"))
  wf:write(SaveFile.encode(banks))
  wf:close()
  local second = run("MN_SAVE_LOAD=" .. path .. " ", "/tmp/mn-save-hl-b")
  local map2 = second:match("final player %d+,%d+ map (%d+)")
  local resumed = second:match("script %x+:%x+ %(continue%)")
  ok(resumed ~= nil, "loaded save resumes through the saved script")
  ok(map2 == map, "save at frame " .. frames .. " resumes on map " .. tostring(map))
  os.remove(path)
  os.execute("rm -rf /tmp/mn-save-hl-a /tmp/mn-save-hl-b")
end
headless()

print(("mn_save: %d checks, %d failed"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
