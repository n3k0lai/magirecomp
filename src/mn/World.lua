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
--   $02       solid in the normal pattern ($C12C = $FF). The $02 layer
--             heads (01:4F0D and siblings) call 01:4ECB every frame, which
--             clears $C12C and sets $C12A, so $02 is floor and $00 is wall.
--   $09/$0B   A-button cells (DispatchCell*OnButtonA). $09 needs $C9A6 >= 1
--             and plants the bank-$20 push tail (WalkTwoCells*). $0B needs
--             $C9A6 >= 2 and plants the kick. Both are solid ($08-$7F).
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

-- ProbeCells* (05:6B31 and its seven siblings): a cell byte >= $80 is
-- clear, $08-$7F is occupied, and a byte under $08 is occupied only when
-- $C12A + cell is nonzero. Nothing else: the A-button cells ($09, $0B and
-- the $20-$7F list cells) are faced from the next cell, never stood on
-- (DispatchPressedAOnFacingCell 01:619A only runs on a blocked step), and
-- $01/$02 follow $C12B/$C12C like the colored gates follow $C12E-$C131.
function M.walkable(v, mem)
  if v >= 0x80 then return true end
  if v >= 0x08 then return false end
  local b = gateByte(v, mem)
  if b ~= 0 then noteGate(v, b); return false end
  return true
end

-- The four bank-1 writers of the $C12A-$C12C gate bytes. Index is the cell.
--   enter2 01:4ECB  $C12C = 0, $C12A = $FF ($02 floor, $00 wall)
--   exit2  01:4EC2  $C12A = 0, $C12C = $FF (back to the normal pattern)
--   enter1 01:56C0  $C12A = $FF, $C12B = 0 ($01 floor, $00 wall)
--   exit1  01:56B7  $C12A = 0, $C12B = $FF
--   ride   01:60E7  $C12B = 0, $C12A = $01 ($01 floor, $00 wall; mn.Ride)
--   dock   01:5F25  $C12B = $01, $C12A = 0 (A on a faced $00 cell)
M.GATE_WRITES = {
  ride = { [0x01] = 0x00, [0x00] = 0x01 },
  dock = { [0x01] = 0x01, [0x00] = 0x00 },
  enter2 = { [0x02] = 0x00, [0x00] = 0xFF },
  exit2 = { [0x00] = 0x00, [0x02] = 0xFF },
  enter1 = { [0x00] = 0xFF, [0x01] = 0x00 },
  exit1 = { [0x00] = 0x00, [0x01] = 0xFF },
}

function M.writeGates(mem, which)
  local dst = mem or wram
  if not dst then return end
  for cell, b in pairs(M.GATE_WRITES[which]) do
    if dst.wr8 then dst:wr8(BASE + cell, b)
    else dst[BASE + cell] = b end
  end
end

-- Gate writes for a layer change from one head family to another
-- (nil = the normal walk heads, 1 = the $01 layer, 2 = the $02 layer).
function M.applyLayer(mem, from, to)
  if from == to then return end
  if from == 2 then M.writeGates(mem, "exit2") elseif from == 1 then M.writeGates(mem, "exit1") end
  if to == 2 then M.writeGates(mem, "enter2") elseif to == 1 then M.writeGates(mem, "enter1") end
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
-- needs $C9A6 >= 3 (Agadon's Boots, 19:7B66 stores $A3A3 = 3). Count 3 (a
-- run of three, or a run that lands on anything but $00/$82) is World.step's
-- $02 layer entry. Returns the landing cell for a hop, or nil.
function M.hop(def, x, y, dx, dy, mark)
  local c, lx, ly = M.cellRun(def, x, y, dx, dy, mark)
  if c == 1 then return lx, ly end
  if c == 2 and (mark or 0) >= 3 then return lx, ly end
  return nil
end

-- One player step from x,y by dx,dy under head family `layer` (nil normal,
-- 1 the $01 layer, 2 the $02 layer). Returns nx, ny, newLayer, how, where
-- how is "step", "hop", "enter", "exit", or nil with nx = nil for a
-- blocked step. The caller applies the gate bytes (applyLayer).
--
-- Normal heads (5B6E family), blocked step: CountCellRun dispatch first
-- (01:51B6 and siblings). Count 1 hops, count 2 hops at $C9A6 >= 3, count 3
-- at $C9A6 >= 5 jumps to 4ED4/4F7E/5028/50D2, which plant the $02 layer
-- heads and the bank-$20 entry anim (5C7A ...) that walks Tony onto that
-- first $02 cell. A count of zero falls to Plant*WhenCellIs01 (01:570D,
-- 5728, 5743, 575E): a $01 cell at $C9A6 >= 4 calls 56C0 and plants the
-- one-cell anim 59A8/58F5/592F/5969 onto it.
--
-- Layer heads (02: 4F0D/4FB7/5061/510B; 01: 5798/5818/58A7/5936): a blocked
-- step looks at the faced cell. $00 calls 4EC2 (or 56B7) and plants the
-- one-cell anim 5A9A/59E7/5A21/5A5B onto it, back on the normal heads.
-- Anything else stays: the $02 heads bump (5CC3 ...), the $01 heads commit.
function M.step(def, x, y, dx, dy, layer, mark, mem)
  mark = mark or 0
  local nx, ny = x + dx, y + dy
  local v = M.cell(def, nx, ny)
  if M.walkable(v, mem) then return nx, ny, layer, "step" end
  if layer == 1 or layer == 2 then
    if v == 0x00 then return nx, ny, nil, "exit" end
    return nil, nil, layer, (layer == 2) and "bump" or nil
  end
  local c, lx, ly = M.cellRun(def, nx, ny, dx, dy, mark)
  if c == 1 then return lx, ly, nil, "hop" end
  if c == 2 then
    if mark >= 3 then return lx, ly, nil, "hop" end
    return nil
  end
  if c == 3 then
    if mark >= 5 then return nx, ny, 2, "enter" end
    return nil
  end
  if v == 0x01 and mark >= 4 then return nx, ny, 1, "enter" end
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

-- Planner support: the gate bytes $C12A-$C131 as they will be under each head
-- family, starting from `mem` under `layer`. Layer changes only rewrite the
-- three bytes in GATE_WRITES, so the table for family L is the current bytes
-- with applyLayer(layer -> L). Keys: 0 normal, 1, 2.
function M.gatesFor(mem, layer)
  local out = {}
  for _, to in ipairs({ 0, 1, 2 }) do
    local t = {}
    for i = 0, 7 do t[BASE + i] = gateByte(i, mem) end
    M.applyLayer(t, layer, to ~= 0 and to or nil)
    out[to] = t
  end
  return out
end

-- The cells one press reaches from x,y under head family `layer`, the way
-- World.step moves the player: plain steps, hops, and $01/$02 layer entries
-- and exits. Returns { { nx, ny, newLayer, dx, dy, how }, ... }.
function M.moves(def, x, y, layer, mark, gates)
  local out = {}
  for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
    local nx, ny, nl, how = M.step(def, x, y, d[1], d[2], layer, mark, gates[layer or 0])
    if nx and nx >= 0 and ny >= 0 and nx < def.w and ny < def.h then
      out[#out + 1] = { nx, ny, nl, d[1], d[2], how }
    end
  end
  return out
end

return M
