-- Cell semantics for the WRAM bank-5 plane (slot-4 block record), named from
-- the decomp (mn-gfx integration):
--   $00       open floor. Resume*RecordHead walks only onto a zero cell.
--             ProbeCells* still consults $C12A: a nonzero byte there blocks it.
--   $08       wall (88% of all non-zero cells; never entered).
--   $01-$07   low cells. A cell below $08 is solid when the byte at
--             $C12A + cell is nonzero (probe_cells_up.asm and the seven
--             sibling probes). WriteC12APatternBank5 (05:6C08) stores
--             00 FF FF 00 FF FF FF FF, so $00 and $03 start open and
--             $01, $02, $04-$07 start solid. Opcode $85 rewrites
--             $C12E-$C131 (cells $04-$07).
--   $02       stop cell: ResumeHead00Record commits without walking.
--             Stays solid even when $C12C is clear.
--   $09/$0B   A-button cells (DispatchCell*OnButtonA). $09 needs $C9A6 >= 1
--             and plants the bank-$20 push tail (WalkTwoCells*). $0B needs
--             $C9A6 >= 2 and plants the kick. Both are solid.
--   $81       WalkTwoCells* accepts only this far cell. StampTwoStepCells
--             writes $09 there and $81 on the near cell. ProbeCells* leaves
--             a cell >= $80 clear, so $81 stays walkable.
--   $82       countdown cell (AdvanceCell82Countdown).
--   $20-$7F with bit 5/6, bit 7 clear: A-button list scripts
--             (SaveCellBelowAndStageThirdScript -> StageThirdScriptFromListIndex).
--   $C0-$FF   step triggers: low 6 bits index the map's bank-$21 list set by
--             script opcode $64 (StageThirdScriptFromMarkedCell); the record's
--             kind gates direction (1 up, 2 down, 3 right, 4 left, else any).
local bit = require("bit")
local M = {}

-- WriteC12APatternBank5 (05:6C08). Index 0 is the byte at $C12A (cell $00).
local PATTERN = { 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF }
local BASE = 0xC12A
-- Live WRAM once seedPattern has copied the pattern into a VM. Opcode $85
-- writes $C12E-$C131 into that same table. Nil uses PATTERN.
local wram

function M.cell(def, x, y)
  if x < 0 or y < 0 or x >= def.w or y >= def.h then return 0x08 end
  return def.block[y * def.w + x + 1]
end

-- Copy the bank-5 pattern into the VM. SetupDefaultState calls
-- WriteC12APattern on the reset path, before any map script.
function M.seedPattern(vm)
  for i = 0, 7 do vm:wr8(BASE + i, PATTERN[i + 1]) end
  wram = vm.mem
end

local function gateByte(cell, mem)
  local src = mem or wram
  if not src then return PATTERN[cell + 1] end
  if src.rd8 then return src:rd8(BASE + cell) end
  local b = src[BASE + cell]
  if b == nil then return 0 end
  return b
end

local function noteGate(cell, byte)
  local flag = os.getenv("MN_DEBUG_GATES")
  if flag == nil or flag == "" then return end
  local seen = M._gateSeen
  if not seen then seen = {}; M._gateSeen = seen end
  local key = cell * 256 + byte
  if seen[key] then return end
  seen[key] = true
  print(("[gates] cell $%02X blocked ($%04X=$%02X)"):format(cell, BASE + cell, byte))
end

-- ProbeCells*: >= $80 stays clear, $08-$7F is occupied, and a byte under
-- $08 is occupied only when $C12A + cell is nonzero. $02/$09/$0B stay
-- solid on top of that (stop cell and the A-button cells). $40-$7F stay
-- solid (signs and the high list cells).
function M.walkable(v, mem)
  if v == 0x08 or v == 0x02 or v == 0x09 or v == 0x0B then return false end
  -- $40-$5F are A-press cells (signs, counters, fireplaces): PyBoy blocks Tony on them
  -- (map 59 counter $41, map 60 $45); $60-$7F are solid
  if v >= 0x40 and v < 0x80 then return false end
  -- Only the colored gates $04-$07 are gated for now. $01-$03 are also
  -- driven by $C12B/$C12C (clear_c12a_set_c12b.asm and siblings), which the
  -- port does not run yet, so they keep their old meaning.
  if v >= 0x04 and v < 0x08 then
    local b = gateByte(v, mem)
    if b ~= 0 then noteGate(v, b); return false end
  end
  return true
end

function M.trigger(def, x, y, dx, dy)
  local v = M.cell(def, x, y)
  if v < 0xC0 then return nil end
  local t = def.triggers[bit.band(v, 0x3F) + 1]
  if not t then return nil end
  if not M.gate(t.kind, dx, dy) then return nil end
  return t
end

-- StageThirdScriptFromMarkedCell's direction gate: 1 up, 2 down, 3 right,
-- 4 left; any other kind fires from every direction.
function M.gate(k, dx, dy)
  return not ((k == 1 and dy >= 0) or (k == 2 and dy <= 0) or (k == 3 and dx <= 0) or (k == 4 and dx >= 0))
end

return M
