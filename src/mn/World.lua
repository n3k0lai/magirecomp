-- Cell semantics for the WRAM bank-5 plane (slot-4 block record), named from
-- the decomp (mn-gfx integration):
--   $00       open floor. Resume*RecordHead walks only onto a zero cell.
--   $08       wall (88% of all non-zero cells; never entered).
--   $02       stop cell: ResumeHead00Record commits without walking.
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

function M.cell(def, x, y)
  if x < 0 or y < 0 or x >= def.w or y >= def.h then return 0x08 end
  return def.block[y * def.w + x + 1]
end

-- The game's walk gate is "cell == 0" (plus triggers it stages on entry).
-- Values with unproven meaning ($A0-$BF, $01, $40-$5F) are treated as floor
-- so the viewer can explore; tighten once their handlers are lifted.
function M.walkable(v)
  if v == 0x00 or v >= 0xC0 then return true end
  if v == 0x08 or v == 0x02 or v == 0x09 or v == 0x0B then return false end
  -- $40-$5F are A-press cells (signs, counters, fireplaces): PyBoy blocks Tony on them
  -- (map 59 counter $41, map 60 $45); $60-$7F are solid
  if v >= 0x40 and v < 0x80 then return false end
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
