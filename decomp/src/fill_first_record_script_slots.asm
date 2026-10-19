; Bank 1 at $651A. RunTailScriptThenPlantTwoScripts calls this after
; writing the ten-byte head and returns. rROMB0 is left alone.
;
; $FFAA and $FFAB are cleared. FinishFrame copies $FFAA to $FFAB, so
; both the live byte and the latch are zero. $FFAB is read with a
; literal because hLatchedFFAB is defined later.
;
; wRecordFlags is the first record. Its low two bits pick the pointer
; in the first seven-byte script slot. 0 stores ScriptPtr50AB, 3 stores
; ScriptPtr50B5, 1 stores PlantOtherRightCellScript, and 2 stores
; $50C9, still INCBIN. Any other value falls into the 0 store. The slot
; bank byte is $20 and its handler is INITIAL_SCRIPT_HANDLER. The last
; two bytes of that slot are left alone.
;
; The second slot’s handler becomes InstallParkedScript ($1402). Its
; bank and pointer bytes are left alone. The head word at
; wRecordFlags + 1 becomes RunTwoScriptsFromRecord.
;
; wRecordFlags is the name from init_pointer_list.asm. ScriptPtr50AB is
; the EQU in resume_script_low_from_a_record.asm. ScriptPtr50B5 is the
; EQU in resume_y_step_bit1_clear_record.asm. PlantOtherRightCellScript
; and RunTwoScriptsFromRecord are already source. INITIAL_SCRIPT_HANDLER
; is the name from reset.asm. InstallParkedScript is the name from
; install_parked_script.asm. The seven-byte slot layout is the one
; LoadScriptBytes copies into hScriptBank.

; First record. The two script slots begin after the ten-byte head.
DEF wFirstScriptSlot EQU wRecordFlags + $0A
DEF wSecondScriptSlot EQU wFirstScriptSlot + $07

; Bank byte of the first script slot. What bank $20 holds is still unknown.
DEF FIRST_SCRIPT_BANK EQU $20

; Pointer stored when the low two bits are 2. Still INCBIN in this bank.
DEF ScriptPtr50C9 EQU $50C9

FillFirstRecordScriptSlots::
    xor a
    ldh [$ffaa], a
    ldh [$ffab], a
    ld a, [wRecordFlags]
    and $03
    cp $00
    jr z, .ptr50AB
    cp $03
    jr z, .ptr50B5
    cp $01
    jr z, .ptr50BF
    cp $02
    jr z, .ptr50C9
.ptr50AB:
    ld a, LOW(ScriptPtr50AB)
    ld [wFirstScriptSlot + 1], a
    ld a, HIGH(ScriptPtr50AB)
    ld [wFirstScriptSlot + 2], a
    jr .storeHandler
.ptr50B5:
    ld a, LOW(ScriptPtr50B5)
    ld [wFirstScriptSlot + 1], a
    ld a, HIGH(ScriptPtr50B5)
    ld [wFirstScriptSlot + 2], a
    jr .storeHandler
.ptr50BF:
    ld a, LOW(PlantOtherRightCellScript)
    ld [wFirstScriptSlot + 1], a
    ld a, HIGH(PlantOtherRightCellScript)
    ld [wFirstScriptSlot + 2], a
    jr .storeHandler
.ptr50C9:
    ld a, LOW(ScriptPtr50C9)
    ld [wFirstScriptSlot + 1], a
    ld a, HIGH(ScriptPtr50C9)
    ld [wFirstScriptSlot + 2], a
.storeHandler:
    ld a, FIRST_SCRIPT_BANK
    ld [wFirstScriptSlot], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [wFirstScriptSlot + 3], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [wFirstScriptSlot + 4], a
    ld a, LOW(InstallParkedScript)
    ld [wSecondScriptSlot + 3], a
    ld a, HIGH(InstallParkedScript)
    ld [wSecondScriptSlot + 4], a
    ld a, LOW(RunTwoScriptsFromRecord)
    ld [wRecordFlags + 1], a
    ld a, HIGH(RunTwoScriptsFromRecord)
    ld [wRecordFlags + 2], a
    ret
