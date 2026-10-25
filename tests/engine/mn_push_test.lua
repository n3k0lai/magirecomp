-- Crystal Gloves block push. Synthetic map cells only.
--   luajit tests/engine/mn_push_test.lua
package.path = "./?.lua;./?/init.lua;./src/?.lua;" .. package.path

local failures, checks = 0, 0
local function ok(cond, what)
  checks = checks + 1
  if not cond then failures = failures + 1; print("FAIL " .. what) end
end

local bit = require("bit")
local MnRom = require("mn.MnRom")
local Sprites = require("mn.Sprites")
local Push = require("mn.Push")
local Kick = require("mn.Kick")

local function romWith(off, bytes)
  local s = string.rep("\0", off) .. bytes .. string.rep("\0", 0x200000 - off - #bytes)
  return MnRom.new(s)
end

local function world(mark, facing, near, far)
  local block, cells = {}, {}
  for i = 1, 64 do block[i] = 0; cells[i] = 0x10 end
  -- Tony at 3,3. Near is the faced block; far is two cells ahead.
  local d = Push.DIR[facing]
  local nx, ny = 3 + d[1], 3 + d[2]
  local fx, fy = 3 + d[1] * 2, 3 + d[2] * 2
  block[ny * 8 + nx + 1] = near
  cells[ny * 8 + nx + 1] = 0x44
  block[fy * 8 + fx + 1] = far
  cells[fy * 8 + fx + 1] = 0x21
  local sounds = {}
  local mem = { [Push.MARK] = mark }
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
  return ow, sounds, nx, ny, fx, fy
end

local function at(ow, x, y)
  local i = y * 8 + x + 1
  return ow.def.block[i], ow.def.cells[i]
end

local function u16(ow, addr)
  return ow.vm:rd8(addr) + bit.lshift(ow.vm:rd8(addr + 1), 8)
end

-- Mark below 1: A is consumed, neither cell changes.
do
  local ow, sounds, nx, ny, fx, fy = world(0, "right", Push.CELL, Push.FAR)
  ok(Push.try(ow) == true, "short mark still owns A")
  local nb, nm = at(ow, nx, ny)
  local fb, fm = at(ow, fx, fy)
  ok(nb == Push.CELL and nm == 0x44, "short mark leaves the block")
  ok(fb == Push.FAR and fm == 0x21, "short mark leaves the far cell")
  ok(ow.vm:rd8(Push.MIRROR) == 0, "walk entry copies the SRAM mark to $C9A6")
  ok(bit.band(ow.vm:rd8(0xFFAA), 0x04) ~= 0, "A sets bit 2 of $FFAA")
  ok(bit.band(ow.vm:rd8(0xFFAA), 0x08) == 0, "short mark does not set bit 3")
  ok(ow.vm:rd8(0xC921) == 0 and #sounds == 0, "short mark queues no sound")
  ok(ow.kickSeen == nil and ow.x == 3 and ow.y == 3, "short mark does not move Tony")
  ok(Push.try(world(1, "up", 0x08, Push.FAR)) == false, "a wall is not a push cell")
end

-- Mark >= 1 and far cell $81: the block slides one cell. Tony stays.
do
  local ow, sounds, nx, ny, fx, fy = world(1, "right", Push.CELL, Push.FAR)
  ok(Push.try(ow) == true, "gloves mark pushes")
  local nb, nm = at(ow, nx, ny)
  local fb, fm = at(ow, fx, fy)
  ok(nb == Push.NEAR and nm == Push.METATILE, "near cell becomes $81 / metatile $FD")
  ok(fb == Push.CELL and fm == 0x44, "far cell becomes $09 with the block metatile")
  ok(ow.vm:rd8(0xC921) == Push.SOUND, "sound id $17 at $C921")
  ok(sounds[1][1] == 1 and sounds[1][2] == Push.SOUND, "slot A plays $17")
  ok(ow.vm:rd8(0xC8C8) == nx and ow.vm:rd8(0xC8C7) == ny, "wScriptCellPos ends as the near cell")
  ok(u16(ow, 0xC8C5) == 0xD000 + ny * 8 + nx, "wScriptCellAddr is the near cell")
  ok(ow.vm:rd8(0xC9A9) == fx and ow.vm:rd8(0xC9AA) == fy, "$C9A9/$C9AA keep the far column and row")
  ok(u16(ow, 0xC9AB) == 0xD000 + fy * 8 + fx, "$C9AB is the far address")
  ok(u16(ow, 0xC9A7) == 0xD000 + ny * 8 + nx, "$C9A7 is the near address")
  ok(bit.band(ow.vm:rd8(0xFFAA), 0x08) ~= 0, "StampTwoStepCells sets bit 3 of $FFAA")
  ok(u16(ow, 0xFFA2) == 0x5571, "right plants Script_20_5571")
  ok(u16(ow, 0xFFA4) == 0x0A66, "handler is $0A66")
  ok(u16(ow, 0xC186) == 0x4E3A, "opcode $10 queued WalkTwoCellsRight")
  ok(u16(ow, 0xFF8D) == Push.WALK_HEAD, "head word is $5D81")
  ok(ow.log[1] == "push 4,3 -> 5,3", "log names both cells")
  ok(ow.kickSeen == true, "a push ends a route goal")
  ok(ow.x == 3 and ow.y == 3 and ow.px == 48 and ow.py == 48, "Tony stays on his cell")
end

-- Far cell other than $81: RejectFarCellQueueSound, nothing moves.
do
  local ow, sounds, nx, ny, fx, fy = world(2, "down", Push.CELL, 0x00)
  ok(Push.try(ow) == true, "a blocked push still owns A")
  local nb, nm = at(ow, nx, ny)
  local fb, fm = at(ow, fx, fy)
  ok(nb == Push.CELL and nm == 0x44, "reject leaves the block")
  ok(fb == 0x00 and fm == 0x21, "reject leaves the far cell")
  ok(ow.vm:rd8(0xC921) == Push.REJECT and sounds[1][2] == Push.REJECT, "reject queues sound $0B")
  ok(bit.band(ow.vm:rd8(0xFFAA), 0x08) == 0, "reject does not set bit 3")
  ok(ow.kickSeen == nil and #ow.log == 0, "reject is not a completed push")
  ok(u16(ow, 0xFF8D) == Push.WALK_HEAD, "WalkTwoCells* still plants head $5D81")
  ok(ow.x == 3 and ow.y == 3, "reject does not move Tony")
end

-- Each facing plants its tail and slides along that axis.
do
  local expect = {
    up = { script = 0x5597, walk = 0x4E7A, nx = 3, ny = 2, fx = 3, fy = 1 },
    down = { script = 0x55BD, walk = 0x4DB4, nx = 3, ny = 4, fx = 3, fy = 5 },
    left = { script = 0x554B, walk = 0x4DFA, nx = 2, ny = 3, fx = 1, fy = 3 },
    right = { script = 0x5571, walk = 0x4E3A, nx = 4, ny = 3, fx = 5, fy = 3 },
  }
  for facing, e in pairs(expect) do
    local ow = world(2, facing, Push.CELL, Push.FAR)
    ok(Push.try(ow) == true, facing .. " owns A")
    local nb, nm = at(ow, e.nx, e.ny)
    local fb, fm = at(ow, e.fx, e.fy)
    ok(nb == Push.NEAR and nm == Push.METATILE, facing .. " near cell")
    ok(fb == Push.CELL and fm == 0x44, facing .. " far cell")
    ok(u16(ow, 0xFFA2) == e.script, facing .. " script pointer")
    ok(u16(ow, 0xC186) == e.walk, facing .. " WalkTwoCells head")
    ok(ow.log[1] == ("push %d,%d -> %d,%d"):format(e.nx, e.ny, e.fx, e.fy), facing .. " log")
    ok(ow.x == 3 and ow.y == 3, facing .. " Tony stays")
  end
end

-- The lunge plays before WalkTwoCells*. A $0B cell is still the kick.
do
  local ow, _, nx, ny = world(2, "left", Push.CELL, Push.FAR)
  local off = 0x20 * 0x4000 + 0x554B - 0x4000
  ow.vm.rom = romWith(off, string.char(0x4C, 1, 1, 0, 0, 0, 0))
  ok(Push.try(ow) == true, "lunge owns A")
  ok(at(ow, nx, ny) == Push.CELL, "cells wait until the lunge ends")
  ok(u16(ow, 0xFF8D) == Push.RUN_HEAD, "head stays RunHeadWordScript during the lunge")
  ok(Push.tick(ow) == true, "lunge frame")
  ok(ow.px == 49 and ow.py == 48, "steps the script delta")
  ok(Sprites.lungeList(ow.push) == nil, "blank list keeps the walker")
  ok(Push.tick(ow) == false, "lunge ends")
  ok(ow.px == 48 and ow.py == 48, "returns to the cell")
  ok(at(ow, nx, ny) == Push.NEAR, "stamp runs when the head word does")
  ok(ow.x == 3 and ow.y == 3, "the lunge does not change Tony's cell")

  local kickOw = world(2, "up", Kick.CELL, 0)
  ok(Push.try(kickOw) == false, "$0B is not a push")
  ok(Kick.try(kickOw) == true, "$0B still kicks")
  ok(at(kickOw, 3, 2) == 0, "kick clears the faced cell")
  ok(select(2, at(kickOw, 3, 2)) == Kick.METATILE, "kick still stamps metatile $FC")
end

-- Per-step list follows the $4C records. Cells wait until the last frame.
do
  local ow, _, nx, ny = world(2, "right", Push.CELL, Push.FAR)
  local off = 0x20 * 0x4000 + 0x5571 - 0x4000
  ow.vm.rom = romWith(off, string.char(
    0x4C,
    2, 1, 0, 0x11, 0x22,
    1, 0, 0, 0x00, 0x00,
    1, 0xFF, 0, 0x33, 0x44,
    0))
  ok(Push.try(ow) == true, "pose script owns A")
  ok(at(ow, nx, ny) == Push.CELL, "pose does not stamp early")
  local expect = {
    { 1, 0, 0x2211 },
    { 2, 0, 0x2211 },
    { 2, 0, 0 },
    { 1, 0, 0x4433 },
  }
  for i, e in ipairs(expect) do
    ok(Push.tick(ow) == true, "pose frame " .. i)
    ok(ow.px == 48 + e[1] and ow.py == 48 + e[2], "pose wobble " .. i)
    ok(ow.push.steps[ow.push.i].list == e[3], "pose step list " .. i)
    ok((Sprites.lungeList(ow.push) or 0) == e[3], "pose drawn list " .. i)
    ok(at(ow, nx, ny) == Push.CELL, "pose frame " .. i .. " leaves the block")
  end
  ok(Push.tick(ow) == false, "pose lunge ends")
  ok(ow.push == nil and Sprites.lungeList(ow.push) == nil, "walker returns when the lunge ends")
  ok(at(ow, nx, ny) == Push.NEAR, "stamp runs after the last list")
  ok(ow.px == 48 and ow.py == 48, "pose returns to the cell")
end

local function listSprites(rom, lp)
  if not lp or lp == 0 then return 0 end
  local o, n = MnRom.off(lp, 0x20), 0
  while rom:u8(o) ~= 0x80 and n < 24 do n = n + 1; o = o + 4 end
  return n
end

local path = os.getenv("MN_ROM")
if path then
  local rom = MnRom.fromFile(path)
  local allSteps, allListed = 0, 0
  for _, ptr in ipairs({ 0x5597, 0x55BD, 0x554B, 0x5571 }) do
    local frames = Sprites.frames(rom, 0x20, ptr)
    local n, x, y = 0, 0, 0
    for i = 1, #frames do
      n = n + frames[i].n
      x = x + frames[i].dx * frames[i].n
      y = y + frames[i].dy * frames[i].n
    end
    ok(n == 20 and x == 0 and y == 0, string.format("ROM push script %04X is a 20-frame lunge", ptr))
    local steps = Push.steps(rom, ptr)
    local listed, seen = 0, {}
    for i = 1, #steps do
      local lp = steps[i].list or 0
      if listSprites(rom, lp) > 0 then listed = listed + 1; seen[lp] = true end
    end
    local kinds = 0
    for _ in pairs(seen) do kinds = kinds + 1 end
    ok(#steps == 20 and listed == #steps and kinds >= 2, string.format("ROM push script %04X pose", ptr))
    allSteps = allSteps + #steps
    allListed = allListed + listed
  end
  print(("pose push %d/%d"):format(allListed, allSteps))
end

if failures == 0 then print(("ok %d"):format(checks)) else print(("FAIL %d/%d"):format(failures, checks)); os.exit(1) end
