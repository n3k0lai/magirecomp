-- Crystal Gloves: push the $09 block on the faced cell one step forward.
-- CopySRAMMarkThenHead6167 (bank 1 $613A) copies SRAM $A3A3 into $C9A6.
-- DispatchPressedAOnFacingCell (01:619A) jumps to DispatchCell*OnButtonA.
-- Those four routines take a faced cell of $09 only when $C9A6 >= 1
-- (CELL_*_TAIL_MIN). A short count still consumes A
-- (CommitScriptAndRecordHead) and does not stamp.
-- PlantHandlerAndHeadWord (01:5DA2) plants handler $0A66 and head word
-- $5DB5 (RunHeadWordScript). The bank-$20 tail (Script_20_5597 / 55BD /
-- 554B / 5571) is a lunge whose deltas sum to zero, then opcode $10
-- queues WalkTwoCellsUp / Down / Left / Right ($4E7A / $4DB4 / $4DFA /
-- $4E3A). RunHeadWordScript copies that word onto the record head.
-- WalkTwoCells* (walk_two_cells_*.asm) reads the far cell, two steps
-- ahead, in WRAM bank 5. Anything other than $81 jumps to
-- RejectFarCellQueueSound (sound $0B at $C921, no stamp). On $81 it
-- jumps to StampTwoStepCells (01:4D3C): sound $17 at $C921, the far
-- cell becomes $09 and takes the near cell's bank-3 metatile, the near
-- cell becomes $81 with metatile $FD, the positions and addresses are
-- saved, and bit 3 of $FFAA is set. The head word left behind is $5D81
-- (CopySRAMMarkThenHead5E10).
-- WalkTwoCells* does not write hObjectCellX/Y. Tony stays on his cell.
-- The near cell is left as $81, which ProbeCells* treats as clear
-- (a cell >= $80 does not set the occupancy bit).
-- TODO(QueueRepeatedSpriteList): the lunge's sprite lists are not in the
-- cached walker sheet, so the pose stays the idle walker. The pixel
-- wobble from that script is applied.

local bit = require("bit")
local World = require("mn.World")
local Sprites = require("mn.Sprites")

local M = {}

M.MARK = 0xA3A3
M.MIRROR = 0xC9A6
M.NEED = 1
M.CELL = 0x09
M.FAR = 0x81
M.NEAR = 0x81
M.METATILE = 0xFD
M.SOUND = 0x17
M.REJECT = 0x0B
M.WALK_HEAD = 0x5D81
M.RUN_HEAD = 0x5DB5

-- dx, dy, bank-$20 tail, WalkTwoCells* head word queued by opcode $10.
M.DIR = {
  up = { 0, -1, 0x5597, 0x4E7A },
  down = { 0, 1, 0x55BD, 0x4DB4 },
  left = { -1, 0, 0x554B, 0x4DFA },
  right = { 1, 0, 0x5571, 0x4E3A },
}

local function plant(vm, ptr, head)
  vm:wr8(0xFFA2, bit.band(ptr, 0xFF))
  vm:wr8(0xFFA3, bit.rshift(ptr, 8))
  vm:wr8(0xFFA4, 0x66) -- INITIAL_SCRIPT_HANDLER $0A66
  vm:wr8(0xFFA5, 0x0A)
  vm:wr8(0xFF8D, bit.band(head, 0xFF))
  vm:wr8(0xFF8E, bit.rshift(head, 8))
end

local function word(vm, addr, w)
  vm:wr8(addr, bit.band(w, 0xFF))
  vm:wr8(addr + 1, bit.rshift(w, 8))
end

local function sound(ow, id)
  local vm = ow.vm
  vm:wr8(0xC921, id) -- wSoundSlotA
  local h = vm.host
  if h and h.sfxSlot then h.sfxSlot(1, id) end
end

-- WalkTwoCells* then StampTwoStepCells or RejectFarCellQueueSound.
-- The queued head word is the WalkTwoCells* address; that routine then
-- replaces the record head with $5D81.
local function commit(ow, dx, dy, walk)
  local vm = ow.vm
  word(vm, 0xC186, walk)
  plant(vm, vm:rd8(0xFFA2) + bit.lshift(vm:rd8(0xFFA3), 8), M.WALK_HEAD)
  ow.push = nil
  if ow.x then ow.px, ow.py = ow.x * 16, ow.y * 16 end

  local nx, ny = ow.x + dx, ow.y + dy
  local fx, fy = ow.x + dx * 2, ow.y + dy * 2
  if World.cell(ow.def, fx, fy) ~= M.FAR then
    sound(ow, M.REJECT)
    return
  end
  local def = ow.def
  local nearMt = def.cells[ny * def.w + nx + 1]
  local function write(x, y, col, mt)
    local addr = 0xD000 + y * def.w + x
    local h = vm.host
    if h and h.setCell then h.setCell(addr, col, mt)
    else
      local i = y * def.w + x
      def.block[i + 1] = col
      def.cells[i + 1] = mt
    end
    return addr
  end
  -- Far first (bank 5 $09, bank 3 = the near metatile), then near.
  local farAddr = write(fx, fy, M.CELL, nearMt)
  local nearAddr = write(nx, ny, M.NEAR, M.METATILE)
  word(vm, 0xC8C7, ny + bit.lshift(nx, 8)) -- wScriptCellPos ends as the near cell
  word(vm, 0xC8C5, nearAddr) -- wScriptCellAddr
  vm:wr8(0xC9A9, fx) -- far column, left in place by StampTwoStepCells
  vm:wr8(0xC9AA, fy)
  word(vm, 0xC9AB, farAddr)
  word(vm, 0xC9A7, nearAddr)
  vm:wr8(0xFFAA, bit.bor(vm:rd8(0xFFAA), 0x08))
  sound(ow, M.SOUND)
  if ow.log then ow.log[#ow.log + 1] = ("push %d,%d -> %d,%d"):format(nx, ny, fx, fy) end
  ow.kickSeen = true -- harness: a push ends a ">" goal like a kick
end

function M.steps(rom, ptr)
  if not rom or not ptr then return {} end
  local frames = Sprites.frames(rom, 0x20, ptr)
  local steps, x, y = {}, 0, 0
  for i = 1, #frames do
    local fr = frames[i]
    for _ = 1, fr.n do
      x, y = x + fr.dx, y + fr.dy
      steps[#steps + 1] = { x, y }
      if #steps >= 32 then return steps end
    end
  end
  return steps
end

-- Called when A is down. True means this cell owns A.
function M.try(ow)
  local vm = ow.vm
  if not vm or not ow.def then return false end
  -- CopySRAMMarkThenHead6167: the walk entry refreshes the mirror.
  local mark = vm:rd8(M.MARK)
  vm:wr8(M.MIRROR, mark)
  local d = M.DIR[ow.facing]
  if not d then return false end
  local nx, ny = ow.x + d[1], ow.y + d[2]
  if World.cell(ow.def, nx, ny) ~= M.CELL then return false end
  -- DispatchCell*OnButtonA sets bit 2 of $FFAA before the mark test.
  vm:wr8(0xFFAA, bit.bor(vm:rd8(0xFFAA), 0x04))
  if mark < M.NEED then return true end
  plant(vm, d[3], M.RUN_HEAD)
  local steps = M.steps(vm.rom, d[3])
  if #steps == 0 then commit(ow, d[1], d[2], d[4])
  else ow.push = { steps = steps, i = 0, dx = d[1], dy = d[2], walk = d[4] } end
  return true
end

-- One frame of the lunge. True while it still owns the player.
-- WalkTwoCells* runs when the lunge ends, which is when the tail
-- script reaches its queued head word.
function M.tick(ow)
  local p = ow.push
  if not p then return false end
  p.i = p.i + 1
  local step = p.steps[p.i]
  if not step then commit(ow, p.dx, p.dy, p.walk); return false end
  ow.px = ow.x * 16 + step[1]
  ow.py = ow.y * 16 + step[2]
  return true
end

return M
