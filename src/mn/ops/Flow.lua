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
-- host.setMetatile is the whole tail: WRAM-3 plane write, then (LCD on) the redraw of
-- the saved A cell $C99C/$C99E, not of the stored word (Overworld host).
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
-- sees it. Not applied in this VM. Opcodes $26 $28 $2A $2C $2D $2E $2F all
-- come through here (ScriptVM for the others).
local function copyToD392(vm, o, op, count)
  vm:wr8(0xC937, 7)
  local args = {}
  for i = 1, count do args[i] = vm.rom:u8(o + i); vm:wr8(0xD391 + i, args[i]) end
  local h = vm.host
  if h and h.battleOp and not vm.init then h.battleOp(op, args) end
  return args
end
M.copyToD392 = copyToD392

-- CopyScriptToD392 plants INITIAL_SCRIPT_HANDLER and every bank-2 tail returns
-- (2:73AC, 2:73DD, 2:744A, 2:7477, 2:752D, 2:7595 all end in ret): the pass ends
-- and the next op runs one pass later. With the LCD off (FinishStartup's
-- RunScriptRecord, e.g. after the $30 wipe of a wild encounter) the passes run
-- back to back with no frame between them (run_script_record.asm).
function M.endD392Pass(vm)
  if not vm.init and not vm.startupPending then coroutine.yield("wait", 1) end
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
  if not vm.init and not vm:inStartup() then coroutine.yield("wait", 1) end
  return off(p, b)
end

-- reenter_reset.asm: jp ResetAtStack ($015B), the soft reset after the model-id
-- check. The running record ends. The boot path is not re-entered here.
local function reenterReset(vm)
  vm.flow = vm.flow or {}
  vm.flow.reset = true
  vm.loop38 = nil -- the reset leaves a $38 loop too
  if vm.threads then vm.threads.loop38 = nil end
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

-- opcode_20.asm (opcode $24, labelled Opcode20): high nibble plus one to $C929,
-- $C928 cleared, wSoundSelect ($C92A) = 1, then jp DispatchScriptOpcode, so the next op
-- runs in the same pass (no frame). $C92C is left alone. At the next FinishFrame,
-- SelectSoundCommand writes wSoundIndex := $FF and arms SoundSelectBit0 ($0684): every
-- $C929 selector calls it steps $C92C down; at 0 or 1 it clears the select and drops
-- the music gate ($57A0), i.e. a music fade-out. The driver (mn.sfx.Driver) runs it.
local function soundSelect1(vm, o, n)
  local e = vm.rom:u8(o + 1)
  local lim = band(rshift(e, 4), 0x0F) + 1
  vm:wr8(0xC929, lim)
  vm:wr8(0xC928, 0)
  vm:wr8(0xC92A, 1)
  local h = vm.host
  if h and h.sfxSelect then h.sfxSelect(1, 0, lim, nil) end -- nil: keep the driver's $C92C
  return o + n
end

-- opcode_20_arm_countdown.asm (opcode $20): the operand is read either way. With
-- wSoundCountdown ($C924) clear it sets $C924 = 2 and $C925 = operand: SelectSoundCommand
-- then arms SoundCountdown ($072D), which saves the driver state and installs sound index
-- $C925, and SoundCountdownIdle ($074F) restores it once that sound stops. With $C924 set,
-- the jr lands inside `jp DispatchScriptOpcode` (ld h,[hl] / ld a,[bc]) and falls into
-- Opcode21 ($0EBD): wSoundRequest ($C91F) = 1. Both paths dispatch the next op in the same
-- pass (no frame). $C924 is the driver's (it counts it down), so it is read from there.
local function armCountdown(vm, o, n)
  local e = vm.rom:u8(o + 1)
  local h = vm.host
  local cd = (h and h.sfxByte) and h.sfxByte(0xC924) or vm:rd8(0xC924)
  if cd == 0 then
    vm:wr8(0xC924, 2)
    vm:wr8(0xC925, e)
    if h and h.sfxCountdown then h.sfxCountdown(e) end
  else
    vm:wr8(0xC91F, 1)
    if h and h.sfx then h.sfx(1) end
  end
  return o + n
end

-- opcode_2f.asm: four bytes to $D392, then ApplyItemBlockThenDispatch (bank 2 $7595).
local function copyD392Item(vm, o, n)
  copyToD392(vm, o, 0x2F, 4)
  M.endD392Pass(vm)
  return o + n
end

-- opcode_2a.asm: one byte to $D392, then PlantFocusThenCopyD0D9ByOperand (bank 2 $744A).
local function copyD392Focus(vm, o, n)
  copyToD392(vm, o, 0x2A, 1)
  M.endD392Pass(vm)
  return o + n
end

---------------------------------------------------------------------------
-- The window: $9D open slide, $9B portrait, $99 text clear, $9A close slide.
-- wUnknownC6EE ($C6EE) is 0 closed, 1 sliding, 2 open; SetupWindow (default
-- state) clears it. One yield is one frame: every handler below ends its frame
-- with `ret`, and only FinishWindowYSlide ($2507 / +5) jumps straight back into
-- DispatchScriptOpcode. The ten window-Y bytes are read from the ROM at run time
-- (WindowYSlideTable, 1:$48D5); hosts see them through h.windowY.
---------------------------------------------------------------------------
local C6EE, WINDOW_X, WINDOW_Y = 0xC6EE, 0xC6F0, 0xC6F1
local SLIDE_TABLE = 0x48D5 -- bank 1 (flat offset is the address)
local function frame(vm) if not vm.init then coroutine.yield("wait", 1) end end
local function setWY(vm, y)
  vm:wr8(WINDOW_Y, y)
  local h = vm.host
  if h and h.windowY then h.windowY(y) end
end

-- FinishWindowYSlide + 5 ($250C): strip cursor state, then dispatch this frame.
local function stripState(vm)
  vm:wr8(0xC6ED, 1)
  vm:wr8(0xC93D, 0x49); vm:wr8(0xC93E, 0xC9) -- $C949
  vm:wr8(0xC6EB, 1)
  vm:wr8(0xC6E9, 0x60); vm:wr8(0xC6EA, 0x88); vm:wr8(0xC941, 0x60); vm:wr8(0xC942, 0x88)
  vm:wr8(0xC93F, 0x25); vm:wr8(0xC940, 0x9C)
  vm:wr8(0xC944, 0x86); vm:wr8(0xC946, 0x86); vm:wr8(0xC945, 0x8F); vm:wr8(0xC947, 0xA4)
end

-- Opcode9D ($23D2), from the frame its op (or a rewound gate) ran in, through
-- FinishWindowYSlide. Returns when DispatchScriptOpcode runs the op at hScriptPtr:
-- the same frame after a slide, the next frame when the window was already open.
local function openSlide(vm)
  frame(vm) -- Opcode9D: bit 7 of hScriptBank, handler $4972
  while true do -- Opcode9DBody (1:$4972)
    local c = vm:rd8(C6EE)
    if c == 2 then frame(vm); return end -- RestoreDispatchScriptOpcode (1:$4A2E)
    if c ~= 1 then break end
    frame(vm)
  end
  vm:wr8(C6EE, 1)
  vm:wr8(0xFFA6, 0)
  vm:wr8(WINDOW_X, 7)
  vm:wr8(0xFF45, 0x8F)
  frame(vm) -- body; callback BlankWindowCornerBlock
  frame(vm) -- $49B3: BlankTwoWindowSpans
  frame(vm) -- $49CD: span rows 0 and 2
  frame(vm) -- $49E2: row 4
  for i = 0, 9 do -- AdvanceWindowYSlide (1:$49F7)
    vm:wr8(0xFFA6, i + 1)
    setWY(vm, vm.rom:u8(SLIDE_TABLE + i))
    frame(vm)
  end
  frame(vm) -- index $0A: handler FinishWindowYSlide
  vm:wr8(C6EE, 2)
  stripState(vm)
end

-- ReturnUnlessC6EEIsTwo ($24EC): an op behind this gate rewinds onto itself and runs
-- Opcode9D's slide first.
local function gateOpen(vm)
  if vm:rd8(C6EE) == 2 then return end
  frame(vm) -- the gate's own frame
  openSlide(vm)
  while vm:rd8(C6EE) ~= 2 do openSlide(vm) end -- another record held it at 1
end

M.handlers[0x9D] = function(vm, o, n, cur)
  if vm.init then return o + n end
  frame(vm) -- Opcode9D's own frame
  openSlide(vm)
  return o + n
end

-- Opcode9B ($22A7 / $22C4 / $230A): two bytes; high nibble of the first and the
-- second byte are the glyph source ($C6E7/$C6E8), low nibble its bank. 25 frames of
-- CopyGlyphBytes, then PaintToggledWindowCorner flips $C6EC.
M.handlers[0x9B] = function(vm, o, n, cur)
  if vm.init then return nil end
  gateOpen(vm)
  frame(vm) -- Opcode9B: callback BlankTwoWindowSpans, handler $22C4
  local b1, b2 = vm.rom:u8(o + 1), vm.rom:u8(o + 2)
  vm:wr8(0xC6E7, band(b1, 0xF0))
  vm:wr8(0xC6E8, b2)
  vm:wr8(0xC6E6, band(b1, 0x0F))
  local k = 0x2252 + 2 * vm:rd8(0xC6EC)
  vm:wr8(0xC6E9, vm.rom:u8(k)); vm:wr8(0xC6EA, vm.rom:u8(k + 1))
  vm:wr8(0xFFA6, 0x1A)
  vm:wr8(0xC6EB, 1)
  local h = vm.host
  if h and h.boxOpen then h.boxOpen(b1 + 256 * b2) end
  frame(vm) -- $22C4
  for c = 0x19, 1, -1 do vm:wr8(0xFFA6, c); frame(vm) end -- 25 glyph copies
  vm:wr8(0xFFA6, 0)
  vm:wr8(0xC6EC, band(vm:rd8(0xC6EC) + 1, 1)) -- PaintToggledWindowCorner
  frame(vm) -- expired: handler $250C
  stripState(vm)
  return o + n
end

-- Opcode99 ($2275): open window only. Blank text rows 1 and 3, then $250C next frame.
M.handlers[0x99] = function(vm, o, n, cur)
  if vm:rd8(C6EE) ~= 2 then return o + n end
  local h = vm.host
  if h and h.boxClose and not vm.init then h.boxClose() end -- the port's box holds one page
  frame(vm)
  stripState(vm)
  return o + n
end

-- Opcode9A ($2297 / 1:$48DF / $490E / $495D): slide the window down nine steps,
-- WY $90, then clear $C6EE. A closed window costs one frame; one mid-slide waits.
M.handlers[0x9A] = function(vm, o, n, cur)
  if vm.init then return o + n end
  local h = vm.host
  if h and h.boxBusy and coroutine.running() then -- the port's text box: wait out the page
    local guard = 0
    while h.boxBusy() and guard < 3600 do guard = guard + 1; coroutine.yield("wait", 1) end
  end
  frame(vm) -- Opcode9A: handler $48DF
  while vm:rd8(C6EE) == 1 do frame(vm) end
  if vm:rd8(C6EE) == 0 then
    frame(vm) -- ClearScriptBankBit
    return o + n
  end
  vm:wr8(C6EE, 1)
  vm:wr8(0xFFA6, 9)
  frame(vm)
  for c = 9, 1, -1 do
    vm:wr8(0xFFA6, c - 1)
    setWY(vm, vm.rom:u8(SLIDE_TABLE + c))
    frame(vm)
  end
  setWY(vm, 0x90)
  frame(vm) -- count 0: handler $495D
  vm:wr8(C6EE, 0)
  if h and h.boxClose then h.boxClose() end
  frame(vm) -- ClearC6EEResumeDispatch
  return o + n
end

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
M.handlers[0x24] = soundSelect1
M.handlers[0x20] = armCountdown
M.handlers[0x2F] = copyD392Item
M.handlers[0x2A] = copyD392Focus

return M
