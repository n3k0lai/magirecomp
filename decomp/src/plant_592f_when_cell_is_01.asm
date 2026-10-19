; Bank 1 at $5743. RightHeldFromBit4 calls this when the X step at
; wClearedOnRecordLoad ($C6D2) is zero, after DispatchCellRightOnButtonA
; and DispatchZeroXStepCellRun. rROMB0 is left alone.
;
; [HL] must be $01, and $C9A6 must be at least $04. Otherwise this
; returns to that caller. When both checks pass, this calls
; SetC12AAndClearC12B, drops that return address, stores $592F as
; hScriptPtr (low at $FFA2, high at $FFA3, the 3-byte form), and jumps
; to PlantHandlerAndHeadWord. hScriptPtr is the name from reset.asm.
; The $592F routine is still INCBIN in this bank. What [HL] and $C9A6
; are is unknown.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; SetC12AAndClearC12B is the name from set_c12a_clear_c12b.asm.
; PlantHandlerAndHeadWord is the name from plant_handler_and_head_word.asm.

; Still INCBIN. Planted as hScriptPtr when both checks pass.
DEF ScriptPtr592F EQU $592F

Plant592FWhenCellIs01::
    ld a, [hl]
    cp $01
    ret nz
    ld a, [$c9a6]
    sub $04
    ret c
    call SetC12AAndClearC12B
    pop af
    ld a, LOW(ScriptPtr592F)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr592F)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
