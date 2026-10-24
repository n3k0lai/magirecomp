-- Bracelet block kick. Synthetic map cells only.
--   luajit tests/engine/mn_kick_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local bit = require("bit")
local MnRom = require("mn.MnRom")
local Sprites = require("mn.Sprites")
local Kick = require("mn.Kick")

local function romWith(off, bytes)
  local s = string.rep("\0", off) .. bytes .. string.rep("\0", 0x200000 - off - #bytes)
  return MnRom.new(s)
end

local function world(mark, facing, cell)
  local block, cells = {}, {}
  for i = 1, 64 do block[i] = 0; cells[i] = 0x10 end
  -- Tony at 3,3. The faced cell is the kick target.
  local d = Kick.DIR[facing]
  local fx, fy = 3 + d[1], 3 + d[2]
  block[fy * 8 + fx + 1] = cell
  cells[fy * 8 + fx + 1] = 0x44
  local sounds = {}
  local mem = { [Kick.MARK] = mark }
  local ow = {
    x = 3, y = 3, px = 48, py = 48, facing = facing, log = {},
    def = { w = 8, h = 8, block = block, cells = cells },
  }
  ow.vm = {
    mem = mem, rom = romWith(0, ""),
    rd8 = function(_, a) return mem[a] or 0 end,
    wr8 = function(_, a, v) mem[a] = bit.band(v, 0xFF) end,
    host = {
      setCell = function(addr, col, mt)
        local i = addr - 0xD000
        block[i + 1] = col
        cells[i + 1] = mt
      end,
      sfxSlot = function(slot, id) sounds[#sounds + 1] = { slot, id } end,
    },
  }
  return ow, sounds, fx, fy
end

-- Mark below 2: A is consumed, the cell stays.
do
  local ow = world(1, "up", Kick.CELL)
  ok(Kick.try(ow) == true, "short mark still owns A")
  ok(ow.def.block[2 * 8 + 3 + 1] == Kick.CELL, "short mark does not clear the cell")
  ok(ow.def.cells[2 * 8 + 3 + 1] == 0x44, "short mark does not stamp the metatile")
  ok(ow.vm:rd8(Kick.MIRROR) == 1, "walk entry copies the SRAM mark to $C9A6")
  ok(bit.band(ow.vm:rd8(0xFFAA), 0x04) ~= 0, "A sets bit 2 of $FFAA")
  ok(ow.vm:rd8(0xC921) == 0, "short mark queues no sound")
  ok(Kick.try(world(2, "up", 0x08)) == false, "a wall is not a kick cell")
end

-- Mark >= 2: one cell, collision cleared, metatile $FC, sound $19.
do
  local ow, sounds, fx, fy = world(2, "right", Kick.CELL)
  local beyond = fy * 8 + (fx + 1) + 1
  ok(Kick.try(ow) == true, "bracelet mark kicks")
  ok(ow.def.block[fy * 8 + fx + 1] == 0, "bank 5 cell cleared")
  ok(ow.def.cells[fy * 8 + fx + 1] == Kick.METATILE, "bank 3 cell becomes $FC")
  ok(ow.def.block[beyond] == 0 and ow.def.cells[beyond] == 0x10, "the next cell is not written")
  ok(ow.vm:rd8(0xC921) == Kick.SOUND, "sound id $19 at $C921")
  ok(sounds[1][1] == 1 and sounds[1][2] == Kick.SOUND, "slot A plays $19")
  ok(ow.vm:rd8(0xC8C8) == fx and ow.vm:rd8(0xC8C7) == fy, "wScriptCellPos is column then row")
  local addr = ow.vm:rd8(0xC8C5) + bit.lshift(ow.vm:rd8(0xC8C6), 8)
  ok(addr == 0xD000 + fy * 8 + fx, "wScriptCellAddr is the faced cell")
  ok(ow.vm:rd8(0xFFA2) + bit.lshift(ow.vm:rd8(0xFFA3), 8) == 0x5655, "right plants Script_20_5655")
  ok(ow.vm:rd8(0xFFA4) + bit.lshift(ow.vm:rd8(0xFFA5), 8) == 0x0A66, "handler is $0A66")
  ok(ow.log[1] == "kick 4,3", "log names the cell")
end

-- Each facing plants its own bank-$20 script. The lunge is read from ROM.
do
  local ptrs = { up = 0x55E3, down = 0x5609, left = 0x562F, right = 0x5655 }
  for facing, ptr in pairs(ptrs) do
    local ow = world(2, facing, Kick.CELL)
    local off = 0x20 * 0x4000 + ptr - 0x4000
    -- one frame, X +1, then the list ends
    ow.vm.rom = romWith(off, string.char(0x4C, 1, 1, 0, 0, 0, 0))
    ok(Kick.try(ow) == true, facing .. " owns A")
    local got = ow.vm:rd8(0xFFA2) + bit.lshift(ow.vm:rd8(0xFFA3), 8)
    ok(got == ptr, facing .. " script pointer")
    ok(ow.vm:rd8(0xFF8D) + bit.lshift(ow.vm:rd8(0xFF8E), 8) == 0x5DB5, facing .. " head is RunHeadWordScript")
    ok(Kick.tick(ow) == true, facing .. " lunge frame")
    ok(ow.px == 48 + 1 and ow.py == 48, facing .. " steps the script delta")
    ok(Kick.tick(ow) == false, facing .. " lunge ends")
    ok(ow.px == 48 and ow.py == 48, facing .. " returns to the cell")
    ok(ow.vm:rd8(0xC186) + bit.lshift(ow.vm:rd8(0xC187), 8) == Kick.WALK_HEAD, facing .. " head word $5D81")
    ok(ow.x == 3 and ow.y == 3, facing .. " does not change Tony's cell")
  end
end

local path = os.getenv("MN_ROM")
if path then
  local rom = MnRom.fromFile(path)
  for _, ptr in ipairs({ 0x55E3, 0x5609, 0x562F, 0x5655 }) do
    local frames = Sprites.frames(rom, 0x20, ptr)
    local n, x, y = 0, 0, 0
    for i = 1, #frames do
      n = n + frames[i].n
      x = x + frames[i].dx * frames[i].n
      y = y + frames[i].dy * frames[i].n
    end
    ok(n == 12 and x == 0 and y == 0, string.format("ROM kick script %04X is a 12-frame lunge", ptr))
  end
end

if failures == 0 then print(("ok %d"):format(checks)) else print(("FAIL %d/%d"):format(failures, checks)); os.exit(1) end
