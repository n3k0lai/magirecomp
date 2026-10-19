; Bank 1 at $5728. ResumeLeftWhileDownBit1Record calls this when the
; X step at wClearedOnRecordLoad ($C6D2) is zero, after
; DispatchCellLeftOnButtonA and $51F2. rROMB0 is left alone.
;
; [HL] must be $01, and $C9A6 must be at least $04. Otherwise this
; returns to that caller. When both checks pass, this calls
; SetC12AAndClearC12B, drops that return address, stores $58F5 as
; hScriptPtr (low at $FFA2, high at $FFA3, the 3-byte form), and jumps
; to PlantHandlerAndHeadWord. hScriptPtr is the name from reset.asm.
; The $58F5 routine is still INCBIN in this bank. What [HL] and $C9A6
; are is unknown.
;
; wClearedOnRecordLoad is the name from load_record_head.asm.
; SetC12AAndClearC12B is the name from set_c12a_clear_c12b.asm.
; PlantHandlerAndHeadWord is the name from plant_handler_and_head_word.asm.

; Still INCBIN. Planted as hScriptPtr when both checks pass.
DEF ScriptPtr58F5 EQU $58F5

Plant58F5WhenCellIs01::
    ld a, [hl]
    cp $01
    ret nz
    ld a, [$c9a6]
    sub $04
    ret c
    call SetC12AAndClearC12B
    pop af
    ld a, LOW(ScriptPtr58F5)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr58F5)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
