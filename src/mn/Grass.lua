-- Cell $82 encounter countdown.
--
-- DispatchHeldDirectionFromHead (01:5E10) plants the d-pad walk heads.
-- Those heads (resume_right_while_down_record.asm and the up/left/down
-- siblings) call StepCell82EveryFourthFrame (01:4212) once per pass.
-- A second call on the same pass, when the pixel step is nonzero, does
-- not tick again: hMainLoopCounter has not moved.
-- The B-held heads (resume_up_only_bit1_record.asm, right_held_from_bit4.asm)
-- call StepCell82OnEvenPass (01:4221) only while that step is nonzero.
-- Both gates jump to AdvanceCell82Countdown (01:41D8).
--
-- A zero count enters at $41AB (ld a, [$C716]) and falls into
-- StageThirdScriptFromC6DB (01:41AC), which copies $C6DB-$C6DD onto
-- wThirdScriptRecord ($C714) and plants INITIAL_SCRIPT_HANDLER.
-- FinishFrame then runs that record. runScript is that pass here.
--
-- The countdown table is read with ROM bank 1 mapped: the walk heads
-- live in bank 1 and AdvanceCell82Countdown does not switch banks.
-- AddDividerStep ($054F) supplies the low nibble index.
-- MN_NOENC=1 still stages the record and does not start the script,
-- same harness switch as the $65A4 walker encounters.

local bit = require("bit")
local World = require("mn.World")
local MnRom = require("mn.MnRom")

local band, bor, lshift, rshift, bxor, tobit =
  bit.band, bit.bor, bit.lshift, bit.rshift, bit.bxor, bit.tobit

local M = {}

M.CELL = 0x82
M.ENABLE = 0xC6D8 -- opcode $32 stores 1; startup clears it
M.COUNT = 0xC6D7  -- $FF reloads, then counts down; 0 stages the script
M.TABLE = 0xC6D9  -- little-endian pointer, bank 1
M.SCRIPT = 0xC6DB -- bank, pointer low, pointer high
M.RECORD = 0xC714 -- wThirdScriptRecord
M.BUSY = 0xC6EE
M.FRAME = 0xFFA8  -- hMainLoopCounter
M.ACCUM = 0xFFA9  -- hDividerAccum
M.HANDLER = 0x0A66

-- GameLoop increments hMainLoopCounter at the start of every pass (main_loop.asm);
-- it is the only writer of $FFA8. Every loop that runs frames without returning
-- to GameLoop leaves the counter where it was:
--   FinishStartup's RunScriptLoop, between $93 and its end (finish_startup.asm);
--   a battle (bank 2 $6591 loop, out only through ContinueStartup);
--   the Start menu (handle_start_press.asm jumps to the $673B loop);
--   the choice / list windows ($8B, $8C, $8F, $90, ...: each loops on RefreshFrame,
--   dispatch_armed_choice.asm, service_window_choice.asm, dispatch_*_choice.asm);
--   the $30 wipe (07:56ED, ends in jp FinishStartup) - the port's ow.overlay;
--   the $38 bank-4 loop (install_script_record_loop_bank4.asm: control never returns).
-- The pass that opens one of them has already counted; the port ticks before it
-- looks at ow.battle / ow.overlay, so that pass counts here too.
function M.outsideMainLoop(ow)
  local vm = ow.vm
  return vm.startupPending or vm.loop38 or ow.battle ~= nil or ow.overlay ~= nil
end

function M.frame(ow)
  local vm = ow.vm
  if not vm or M.outsideMainLoop(ow) then return end
  vm:wr8(M.FRAME, band(vm:rd8(M.FRAME) + 1, 0xFF))
end

-- AddDividerStep: two rDIV samples. vm.divBytes is an optional queue of
-- those samples (tests). Otherwise a per-VM xorshift stands in for rDIV.
local function divSample(vm)
  local q = vm.divBytes
  if q and q[1] ~= nil then return table.remove(q, 1) end
  local s = vm.divState or 1
  s = tobit(bxor(s, lshift(s, 13)))
  s = tobit(bxor(s, rshift(s, 17)))
  s = tobit(bxor(s, lshift(s, 5)))
  if s == 0 then s = 0x2545F491 end
  vm.divState = s
  return band(rshift(s, 8), 0xFF)
end

local function divStep(vm)
  local d1, d2 = divSample(vm), divSample(vm)
  local sw = band(bor(lshift(d1, 4), rshift(d1, 4)), 0xFF)
  local sra = band(rshift(sw, 1) + band(sw, 0x80), 0xFF)
  local e = band(sra + d2, 7) - 3
  local a = band(vm:rd8(M.ACCUM) + e, 0xFF)
  vm:wr8(M.ACCUM, a)
  return a
end

local function romAt(vm, addr)
  if addr < 0x4000 then return vm.rom:u8(addr) end
  return vm.rom:u8(MnRom.off(band(addr, 0xFFFF), 1))
end

-- StageThirdScriptFromC6DB, entered from the $41AB ld a, [$C716].
-- Returns true when the record was planted.
local function stage(vm)
  if vm:rd8(M.RECORD + 2) ~= 0 then return false end
  if vm:rd8(M.BUSY) ~= 0 then return false end
  vm:wr8(M.COUNT, 0xFF)
  vm:wr8(M.RECORD, vm:rd8(M.SCRIPT))
  vm:wr8(M.RECORD + 1, vm:rd8(M.SCRIPT + 1))
  vm:wr8(M.RECORD + 2, vm:rd8(M.SCRIPT + 2))
  vm:wr8(M.RECORD + 3, band(M.HANDLER, 0xFF))
  vm:wr8(M.RECORD + 4, rshift(M.HANDLER, 8))
  return true
end

-- AdvanceCell82Countdown. `cell` is the byte at hMapCellPointer.
-- Returns true when the third script was staged this pass.
function M.advance(vm, cell)
  if cell ~= M.CELL then return false end
  if vm:rd8(M.RECORD + 2) ~= 0 then return false end
  local c = vm:rd8(M.COUNT)
  if c == 0 then return stage(vm) end
  if c == 0xFF then
    local ptr = vm:rd8(M.TABLE) + lshift(vm:rd8(M.TABLE + 1), 8)
    local n = romAt(vm, ptr + band(divStep(vm), 0x0F))
    vm:wr8(M.COUNT, n)
    return false
  end
  vm:wr8(M.COUNT, band(c - 1, 0xFF))
  return false
end

local function cellOf(ow)
  return World.cell(ow.def, ow.x or 0, ow.y or 0)
end

-- One walk-head pass. Call after M.frame. ow.bHeld selects the even-pass
-- gate and requires ow.moving (nonzero pixel step). Otherwise the
-- fourth-frame gate runs, including a held direction that did not move.
-- Returns true when the third script was started.
function M.walk(ow)
  local vm = ow.vm
  if not vm or vm:rd8(M.ENABLE) == 0 then return false end
  local n = vm:rd8(M.FRAME)
  if ow.bHeld then
    if not ow.moving or band(n, 1) ~= 0 then return false end
  elseif band(n, 3) ~= 3 then
    return false
  end
  if not M.advance(vm, cellOf(ow)) then return false end
  local bank = vm:rd8(M.RECORD)
  local ptr = vm:rd8(M.RECORD + 1) + lshift(vm:rd8(M.RECORD + 2), 8)
  -- The record stays planted while its script runs: $C716 is nonzero, so
  -- AdvanceCell82Countdown is gated off until the battle's return path
  -- (M.afterBattle) leaves 00 00 00 02 14 there.
  if os.getenv("MN_NOENC") == "1" then
    -- harness only: the script never runs, so drop the record now
    M.afterBattle(vm)
    return false
  end
  if ow.runScript then ow:runScript(bank, ptr, "grass") end
  return true
end

-- Return path after a battle. Every encounter script (13:5F7C picks one of
-- eight) runs Opcode25 (opcode_25.asm, $0EC5): it stores the third record
-- back with hScriptHandler $0F59 and the pointer past its operands, so $C716
-- stays nonzero. The battle (bank 2 $5E6D, then the $6591 loop) leaves only
-- through DispatchNonzeroD016 into ContinueStartup ($2158, finish_startup.asm),
-- which stores 00 00 02 14 at $C715-$C718; the bank byte at $C714 is left.
-- The script that runs next is the $31 tail (ScriptVM duelTail).
function M.afterBattle(vm)
  vm:wr8(M.RECORD + 1, 0x00); vm:wr8(M.RECORD + 2, 0x00)
  vm:wr8(M.RECORD + 3, 0x02); vm:wr8(M.RECORD + 4, 0x14)
end

return M
