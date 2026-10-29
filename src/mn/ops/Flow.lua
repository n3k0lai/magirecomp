-- Script control-flow and record-install opcodes. vm.init stands in for wLCDC == 0
-- (the LCD-off map-setup run), the same convention as $A3/$A4 in ScriptVM.
-- A parked record returns nil so that run stops. Nothing here keeps ROM bytes.
local bit = require("bit")
local band, bor, bxor, lshift, rshift = bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift

local M = { handlers = {} }

local INITIAL = 0x0A66 -- INITIAL_SCRIPT_HANDLER, reset.asm
local PARKED = 0x1402  -- InstallParkedScript

local function off(ptr, bank) return bank * 0x4000 + ptr - 0x4000 end

local function ptrOf(o) return o % 0x4000 + 0x4000 end

-- hScriptBank / hScriptPtr / hScriptHandler (reset.asm). bank or ptr may be left alone.
local function plant(vm, handler, bank, ptr)
  if bank ~= nil then vm:wr8(0xFFA1, bank) end
  if ptr ~= nil then vm:wr8(0xFFA2, band(ptr, 0xFF)); vm:wr8(0xFFA3, band(rshift(ptr, 8), 0xFF)) end
  vm:wr8(0xFFA4, band(handler, 0xFF)); vm:wr8(0xFFA5, band(rshift(handler, 8), 0xFF))
end

-- install_parked_script.asm: wFlagC6F4 = 1, script pointer 0, handler stays parked.
local function parkNow(vm)
  vm:wr8(0xC6F4, 1)
  plant(vm, PARKED, nil, 0)
end

-- store_e_through_word.asm: E through the little-endian word, WRAM bank 3.
-- The LCD-on tail (bank 7 $4CA1) rebuilds the metatile; setMetatile is that write.
local function storeCell(vm, addr, mt)
  vm:wr8(0xC937, 3)
  vm:wr8(addr, mt)
  local h = vm.host
  if h and h.setMetatile then h.setMetatile(addr, mt) end
end

local function masked(vm, addr, mask) return band(vm:rd8(addr), mask) ~= 0 end

-- BranchWhenLCDOff (branch_when_lcd_off.asm). Ten operands: SRAM word, mask,
-- script bank and pointer, byte stored when that mask is set, byte stored when
-- it is clear, WRAM-3 cell word. PlantScriptPtrReadSramByte reads the SRAM byte.
-- LCD off: mask clear continues after the record and stores the clear byte
-- (StageBytePastFour); mask set enters the script and stores the set byte
-- (PlantScriptPastRecord). LCD on: mask clear ORs the mask into SRAM and enters
-- the script (OrBCIntoSramByte); mask set XORs it and continues (XorRecordByteIntoSram).
local function branchWhenLCDOff(vm, o, n, cur)
  local r = vm.rom
  local addr, mask = r:u16(o + 1), r:u8(o + 3)
  local bank, ptr = r:u8(o + 4), r:u16(o + 5)
  local tileSet, tileClr, cell = r:u8(o + 7), r:u8(o + 8), r:u16(o + 9)
  local set = masked(vm, addr, mask)
  local function go(b, p) plant(vm, INITIAL, b, p); return off(p, b) end
  local function cont(tile)
    storeCell(vm, cell, tile)
    local p = ptrOf(o + n)
    plant(vm, INITIAL, cur.bank, p)
    return o + n
  end
  if vm.init then
    if set then storeCell(vm, cell, tileSet); return go(bank, ptr) end
    return cont(tileClr)
  elseif set then
    vm:wr8(addr, bxor(vm:rd8(addr), mask))
    return cont(tileClr)
  end
  vm:wr8(addr, bor(vm:rd8(addr), mask))
  storeCell(vm, cell, tileSet)
  return go(bank, ptr)
end

-- PlantParkedHandlerWhenLCDOff. Same ten operands as $A0. LCD off always plants
-- InstallParkedScript (the body runs on the next pass) and still stores a byte:
-- the set byte when the mask hits, the clear byte otherwise (StageBytePastFour).
-- LCD on is BranchRecordBitsAfterParkedPlant, the same OR/XOR split as $A0.
local function plantParkedWhenLCDOff(vm, o, n, cur)
  if not vm.init then return branchWhenLCDOff(vm, o, n, cur) end
  local r = vm.rom
  local addr, mask = r:u16(o + 1), r:u8(o + 3)
  local tileSet, tileClr, cell = r:u8(o + 7), r:u8(o + 8), r:u16(o + 9)
  plant(vm, PARKED, nil, masked(vm, addr, mask) and ptrOf(o + 10) or ptrOf(o + n))
  storeCell(vm, cell, masked(vm, addr, mask) and tileSet or tileClr)
  return nil
end

-- BranchParkedScriptWhenLCDOff. Nine operands: SRAM word, mask, script bank and
-- pointer, one cell byte, WRAM-3 cell word. LCD off and mask clear jumps to
-- InstallParkedScript. Any other LCD-off result stores the cell byte
-- (StageBytePastThree) and continues. LCD on and mask clear ORs the mask and
-- stores (OrBCIntoSramBeforeStage); mask set enters the script.
local function branchParkedWhenLCDOff(vm, o, n, cur)
  local r = vm.rom
  local addr, mask = r:u16(o + 1), r:u8(o + 3)
  local bank, ptr = r:u8(o + 4), r:u16(o + 5)
  local tile, cell = r:u8(o + 7), r:u16(o + 8)
  local set = masked(vm, addr, mask)
  if vm.init then
    if not set then parkNow(vm); return nil end
    storeCell(vm, cell, tile)
    plant(vm, INITIAL, cur.bank, ptrOf(o + n))
    return o + n
  elseif set then
    plant(vm, INITIAL, bank, ptr)
    return off(ptr, bank)
  end
  vm:wr8(addr, bor(vm:rd8(addr), mask))
  storeCell(vm, cell, tile)
  plant(vm, INITIAL, cur.bank, ptrOf(o + n))
  return o + n
end

-- copy_script_to_d392.asm: A operand bytes to $D392 in WRAM bank 7, then the
-- caller's bank-2 tail. That tail is a battle-record effect; host.battleOp
-- sees it the same way $2E does. Not applied in this VM.
local function copyToD392(vm, o, op, count)
  vm:wr8(0xC937, 7)
  local args = {}
  for i = 1, count do args[i] = vm.rom:u8(o + i); vm:wr8(0xD391 + i, args[i]) end
  local h = vm.host
  if h and h.battleOp and not vm.init then h.battleOp(op, args) end
end

-- opcode_32.asm: $C6D8 = 1, $C6D7 = $FF, first three operands to $C6DB-$C6DD
-- (bank, pointer of the third script), last two to $C6D9 (countdown table).
-- StageThirdScriptFromC6DB (bank 1 $41AC) copies $C6DB into $C714 later, when
-- the cell-$82 countdown in advance_cell82_countdown.asm expires. This opcode
-- only stages the bytes, then returns to INITIAL_SCRIPT_HANDLER.
local function setThirdScript(vm, o, n)
  local r = vm.rom
  vm:wr8(0xC6D8, 1)
  vm:wr8(0xC6D7, 0xFF)
  vm:wr8(0xC6DB, r:u8(o + 1))
  vm:wr8(0xC6DC, r:u8(o + 2))
  vm:wr8(0xC6DD, r:u8(o + 3))
  vm:wr8(0xC6D9, r:u8(o + 4))
  vm:wr8(0xC6DA, r:u8(o + 5))
  return o + n
end

-- fill_wscript_record_from_script.asm -> CopyThreeScriptBytesThenDispatch ($17A0):
-- three script bytes into wScriptRecord ($C706) and DispatchScriptOpcode ($0A66)
-- in the handler word. FinishFrame runs that record; a thread is the stand-in
-- ScriptVM already uses for the $C70D sibling ($5A).
local function fillWScript(vm, o, n)
  local r = vm.rom
  local b, p = r:u8(o + 1), r:u16(o + 2)
  vm:wr8(0xC706, b)
  vm:wr8(0xC707, band(p, 0xFF))
  vm:wr8(0xC708, band(rshift(p, 8), 0xFF))
  vm:wr8(0xC709, 0x66)
  vm:wr8(0xC70A, 0x0A)
  if not vm.init then
    vm.threads = vm.threads or {}
    vm.threads.c706 = { co = coroutine.create(function() vm:run(b, p) end), wait = 0, slot = "c706" }
  end
  return o + n
end

-- copy_fallback_script_record.asm: three bytes to wFallbackScriptBank ($C9FF)
-- and wFallbackScriptPtr ($CA00). SetupCommand4D reads them when the group-list
-- word at $CDAE is zero. Dispatch continues at the next opcode.
local function copyFallback(vm, o, n)
  local r = vm.rom
  vm:wr8(0xC9FF, r:u8(o + 1))
  vm:wr8(0xCA00, r:u8(o + 2))
  vm:wr8(0xCA01, r:u8(o + 3))
  return o + n
end

-- stage_script_byte_enter_bank1.asm -> ApplyScriptByteToC12E (bank 1 $45E6):
-- $C12E-$C131 cleared, then $FF in each byte whose bit 0-3 of the operand is set.
-- Those four bytes are the $C12A pattern for cells $04-$07 (probe_cells_up.asm):
-- a set bit makes that colored gate solid, a clear bit makes it open.
-- The script continues.
local function stageC12E(vm, o, n, cur)
  local e = vm.rom:u8(o + 1)
  for i = 0, 3 do vm:wr8(0xC12E + i, band(e, lshift(1, i)) ~= 0 and 0xFF or 0) end
  plant(vm, INITIAL, cur.bank, ptrOf(o + n))
  return o + n
end

-- install_script_from_bc.asm: bank, pointer low, pointer high become the script
-- record, wFlagC6F4 = 1, handler = INITIAL_SCRIPT_HANDLER, then the caller
-- returns. The next pass runs that script. A yield is that pass boundary;
-- map setup (no later pass) enters it immediately.
local function installFromBC(vm, o, n)
  local b, p = vm.rom:u8(o + 1), vm.rom:u16(o + 2)
  vm:wr8(0xC6F4, 1)
  plant(vm, INITIAL, b, p)
  if not vm.init then coroutine.yield("wait", 1) end
  return off(p, b)
end

-- reenter_reset.asm: jp ResetAtStack ($015B), the soft reset after the model-id
-- check. The running record ends. The boot path is not re-entered here.
local function reenterReset(vm)
  vm.flow = vm.flow or {}
  vm.flow.reset = true
  local h = vm.host
  if h and h.reenterReset then h.reenterReset() end
  return nil
end

-- opcode_1e.asm: wSoundRequest ($C91F) = 4. SelectSoundCommand treats bit 2 as
-- SoundRequestBit2 (the latch at $0709).
local function soundRequest4(vm, o, n)
  vm:wr8(0xC91F, 4)
  local h = vm.host
  if h and h.sfx then h.sfx(4) end
  return o + n
end

-- opcode_22.asm: low nibble to $C92C, $C928 and $C929 cleared, wSoundSelect
-- ($C92A) = 4. Bits 0 and 1 are clear, so SelectSoundCommand takes
-- SoundSelectOther, which passes $C92C to ApplyC92C and clears the select.
local function soundSelect4(vm, o, n)
  local v = band(vm.rom:u8(o + 1), 0x0F)
  vm:wr8(0xC92C, v)
  vm:wr8(0xC928, 0)
  vm:wr8(0xC929, 0)
  vm:wr8(0xC92A, 4)
  local h = vm.host
  if h and h.sfxSelect then h.sfxSelect(4, 0, 0, v) end
  return o + n
end

-- opcode_23.asm: high nibble plus one to $C929, $C928 and $C92C cleared,
-- wSoundSelect = 2. SoundSelectBit1 counts $C928 up to $C929, then steps $C92C.
local function soundSelect2(vm, o, n)
  local e = vm.rom:u8(o + 1)
  local lim = band(rshift(e, 4), 0x0F) + 1
  vm:wr8(0xC929, lim)
  vm:wr8(0xC928, 0)
  vm:wr8(0xC92C, 0)
  vm:wr8(0xC92A, 2)
  local h = vm.host
  if h and h.sfxSelect then h.sfxSelect(2, 0, lim, 0) end
  return o + n
end

-- opcode_2f.asm: four bytes to $D392, then ApplyItemBlockThenDispatch (bank 2 $7595).
local function copyD392Item(vm, o, n)
  copyToD392(vm, o, 0x2F, 4)
  return o + n
end

-- opcode_2a.asm: one byte to $D392, then PlantFocusThenCopyD0D9ByOperand (bank 2 $744A).
local function copyD392Focus(vm, o, n)
  copyToD392(vm, o, 0x2A, 1)
  return o + n
end

-- opcode_9d.asm: plants bank-1 continuation $4972 (INCBIN), which the decomp documents as
-- resuming dispatch once wUnknownC6EE ($C6EE) is 2 (SC_WaitC6EETwo).
local function waitC6EETwo(vm, o, n)
  if not vm.init then
    local guard = 0
    while vm:rd8(0xC6EE) ~= 2 and guard < 3600 do guard = guard + 1; coroutine.yield("wait", 1) end
  end
  return o + n
end

M.handlers[0x9D] = waitC6EETwo
M.handlers[0xA0] = branchWhenLCDOff
M.handlers[0xA1] = plantParkedWhenLCDOff
M.handlers[0xA2] = branchParkedWhenLCDOff
M.handlers[0x32] = setThirdScript
M.handlers[0x59] = fillWScript
M.handlers[0x95] = copyFallback
M.handlers[0x85] = stageC12E
M.handlers[0x4A] = installFromBC
M.handlers[0x97] = reenterReset
M.handlers[0x1E] = soundRequest4
M.handlers[0x22] = soundSelect4
M.handlers[0x23] = soundSelect2
M.handlers[0x2F] = copyD392Item
M.handlers[0x2A] = copyD392Focus

return M
