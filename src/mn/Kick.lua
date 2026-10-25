-- Orwin's bracelet: kick the block on the faced cell.
-- CopySRAMMarkThenHead6167 (bank 1 $613A) copies SRAM $A3A3 into $C9A6.
-- DispatchPressedAOnFacingCell (01:619A) jumps to DispatchCell*OnButtonA.
-- Those four routines (dispatch_cell_*_on_button_a.asm) take a faced cell
-- of $0B only when $C9A6 >= 2. A short count still consumes A
-- (CommitScriptAndRecordHead) and does not stamp.
-- StampMapCellInWramBanks (01:4B2D) stores sound $19 at $C921, clears the
-- bank-5 cell, and writes metatile $FC in bank 3. The faced cell is replaced
-- in place: nothing is written one cell further on.
-- PlantHandlerAndHeadWord (01:5DA2) plants handler $0A66 and head word
-- $5DB5. The bank-$20 script (Script_20_55E3 / 5609 / 562F / 5655) is a
-- 12-frame lunge that ends at $5D81 (CopySRAMMarkThenHead5E10).
-- QueueRepeatedSpriteList (00:1560) puts a bank-$20 list pointer on each
-- record. Sprites.lunge keeps it on the step; the overworld draws that
-- list until the lunge hands back to the walker.

local bit = require("bit")
local World = require("mn.World")
local Sprites = require("mn.Sprites")

local M = {}

M.MARK = 0xA3A3
M.MIRROR = 0xC9A6
M.NEED = 2
M.CELL = 0x0B
M.SOUND = 0x19
M.METATILE = 0xFC
M.WALK_HEAD = 0x5D81

-- Facing value in hRecordHead: up, left, right, down. Script is the
-- bank-$20 pointer DispatchCell*OnButtonA plants for cell $0B.
M.DIR = {
  up = { 0, -1, 0x55E3 },
  left = { -1, 0, 0x562F },
  right = { 1, 0, 0x5655 },
  down = { 0, 1, 0x5609 },
}

local function plant(vm, ptr, head)
  vm:wr8(0xFFA2, bit.band(ptr, 0xFF))
  vm:wr8(0xFFA3, bit.rshift(ptr, 8))
  vm:wr8(0xFFA4, 0x66) -- INITIAL_SCRIPT_HANDLER $0A66
  vm:wr8(0xFFA5, 0x0A)
  vm:wr8(0xFF8D, bit.band(head, 0xFF))
  vm:wr8(0xFF8E, bit.rshift(head, 8))
end

-- QueueHeadWord in the kick script, then RunHeadWordScript copies it
-- over the head word when the high byte is not zero.
local function finish(ow)
  local vm = ow.vm
  vm:wr8(0xC186, bit.band(M.WALK_HEAD, 0xFF))
  vm:wr8(0xC187, bit.rshift(M.WALK_HEAD, 8))
  plant(vm, vm:rd8(0xFFA2) + bit.lshift(vm:rd8(0xFFA3), 8), M.WALK_HEAD)
  ow.kick = nil
  if ow.x then ow.px, ow.py = ow.x * 16, ow.y * 16 end
end

function M.steps(rom, ptr)
  return Sprites.lunge(rom, 0x20, ptr)
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
  local fx, fy = ow.x + d[1], ow.y + d[2]
  if World.cell(ow.def, fx, fy) ~= M.CELL then return false end
  -- DispatchCell*OnButtonA sets bit 2 of $FFAA before the cell test.
  vm:wr8(0xFFAA, bit.bor(vm:rd8(0xFFAA), 0x04))
  if mark < M.NEED then return true end
  local addr = 0xD000 + fy * ow.def.w + fx
  vm:wr8(0xC921, M.SOUND) -- wSoundSlotA
  vm:wr8(0xC8C5, bit.band(addr, 0xFF)) -- wScriptCellAddr
  vm:wr8(0xC8C6, bit.rshift(addr, 8))
  vm:wr8(0xC8C7, fy) -- wScriptCellPos: C = row, B = column
  vm:wr8(0xC8C8, fx)
  local h = vm.host
  if h and h.setCell then h.setCell(addr, 0, M.METATILE)
  else
    local i = fy * ow.def.w + fx
    ow.def.block[i + 1] = 0
    ow.def.cells[i + 1] = M.METATILE
  end
  if h and h.sfxSlot then h.sfxSlot(1, M.SOUND) end
  plant(vm, d[3], 0x5DB5) -- RunHeadWordScript
  local steps = M.steps(vm.rom, d[3])
  if #steps == 0 then finish(ow)
  else ow.kick = { steps = steps, i = 0 } end
  if ow.log then ow.log[#ow.log + 1] = ("kick %d,%d"):format(fx, fy) end
  ow.kickSeen = true -- harness: a kick ends a ">" goal like a talk
  return true
end

-- One frame of the lunge. True while it still owns the player.
function M.tick(ow)
  local k = ow.kick
  if not k then return false end
  if not Sprites.lungeAdvance(ow, k, "kick") then finish(ow); return false end
  return true
end

return M
