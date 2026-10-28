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

-- Does object ob block a step onto x,y? A record never blocks by itself: the
-- player's step probes only the WRAM-5 cell map (ProbeCellsUp and its
-- siblings, StepClassProbeTable). A record makes its cell solid through
-- MarkZeroMapCell (bank 1 $4AD5), which writes $08 there only when the cell
-- byte is $00, and ClearRecordHeadBit5 puts the $00 back. On any other cell
-- (a $C0+ step trigger, a list cell, a gate) a sprite never blocks: 279's
-- slot 2 (2F:453E) stands on the story-9 step cell 34,21 ($C5) and the real
-- game walks onto it. Dormant, blank and imageless records and $65A4 step-on
-- records do not block either (Overworld's old rule).
function M.blocks(def, ob, x, y)
  if ob.x ~= x or ob.y ~= y then return false end
  if ob.dormant or ob.blank or not (ob.image or ob.anim) or ob.handler == 0x65A4 then return false end
  return M.cell(def, x, y) == 0x00
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

-- The walk mark. The ROM copies SRAM $A3A3 into $C9A6 on walk entry
-- (CopySRAMMarkThenHead*), so read $A3A3 from the seeded VM (0 if none).
function M.mark(vm)
  local src = vm or wram
  if not src then return 0 end
  if src.rd8 then return src:rd8(0xA3A3) end
  return src[0xA3A3] or 0
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
  -- Only the colored gates $04-$07 are gated here. $01/$02 are crossed
  -- by M.hop (CountCellRun); the $C12A-$C12C swaps only matter for the
  -- layer walks ($01 at $C9A6 >= 4, $02 runs at >= 5), not modelled yet.
  if v >= 0x04 and v < 0x08 then
    local b = gateByte(v, mem)
    if b ~= 0 then noteGate(v, b); return false end
  end
  return true
end

-- CountCellRun (01:517C): HL is the cell Tony walks into, DE the stride.
-- With $C9A6 < 4, $01 and $02 both continue the run; with $C9A6 >= 4 only
-- $02 does (a $01 cell then goes to Plant5969WhenCellIs01 instead). The
-- first non-run cell ends it: $00 or $82 keep the count, anything else
-- forces 3. Returns the count and the landing cell (nil when forced).
function M.cellRun(def, x, y, dx, dy, mark)
  local function run(v) return v == 0x02 or (v == 0x01 and (mark or 0) < 4) end
  local c = 0
  local cx, cy = x, y
  while run(M.cell(def, cx, cy)) do
    c = c + 1; cx, cy = cx + dx, cy + dy
    if c >= 3 then break end
  end
  if c == 0 then return 0 end
  local v = M.cell(def, cx, cy)
  if c >= 3 or not (v == 0x00 or v == 0x82) then return 3 end
  return c, cx, cy
end

-- DispatchZeroStepCellRun and its three siblings (01:51B6 down, 01:526A up,
-- 01:51F2 left, 01:522E right), run when a step into the cell is blocked:
-- a run of one hops it with no item ($56F9 / $5813 heads), a run of two
-- needs $C9A6 >= 3 (Agadon's Boots, 19:7B66 stores $A3A3 = 3), and a run of
-- three or more needs $C9A6 >= 5 and switches the record to the $02 layer
-- heads (ResumeHead00-03Record, which swap $C12A/$C12C). Returns the landing
-- cell for a hop, or nil. The $02 layer walk is not modelled yet.
function M.hop(def, x, y, dx, dy, mark)
  local c, lx, ly = M.cellRun(def, x, y, dx, dy, mark)
  if c == 1 then return lx, ly end
  if c == 2 and (mark or 0) >= 3 then return lx, ly end
  return nil
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
