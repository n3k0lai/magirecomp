; Bank 1 at $575E. The path at $5456 reaches this when bit 6 of $c9a3
; is set, the signed vertical step at $C6D3 is zero, and
; DispatchBit6ZeroStepCellRun returns because CountCellRun counted
; zero. rROMB0 is left alone.
;
; [HL] must be $01, and $C9A6 must be at least $04. Otherwise this
; returns to that caller. When both checks pass, this calls
; SetC12AAndClearC12B, drops that return address, stores $5969 as
; hScriptPtr (low at $FFA2, high at $FFA3, the 3-byte form), and jumps
; to PlantHandlerAndHeadWord. hScriptPtr is the name from reset.asm.
; $5969 is the call to StageThirdScriptFromMarkedCell inside
; ResumeUpIdleRecord. What [HL] and $C9A6 are is unknown.
;
; The byte at $5777 is the low byte of that jump to
; PlantHandlerAndHeadWord. A script pointer planted at $5777 from
; PlantScriptOnLeftTwoCellRun lands in the middle of this jump.
;
; DispatchBit6ZeroStepCellRun is the name from
; dispatch_bit6_zero_step_cell_run.asm. CountCellRun is the name from
; count_cell_run.asm. SetC12AAndClearC12B is the name from
; set_c12a_clear_c12b.asm. PlantHandlerAndHeadWord is the name from
; plant_handler_and_head_word.asm. ResumeUpIdleRecord is the name from
; resume_up_idle_record.asm. StageThirdScriptFromMarkedCell is the name
; from stage_third_script_from_marked_cell.asm.
; PlantScriptOnLeftTwoCellRun is the name from
; plant_script_on_left_two_cell_run.asm.

; Inside ResumeUpIdleRecord. Planted as hScriptPtr when both checks pass.
DEF ScriptPtr5969 EQU $5969

Plant5969WhenCellIs01::
    ld a, [hl]
    cp $01
    ret nz
    ld a, [$c9a6]
    sub $04
    ret c
    call SetC12AAndClearC12B
    pop af
    ld a, LOW(ScriptPtr5969)
    ld [hScriptPtr], a
    ld a, HIGH(ScriptPtr5969)
    ld [hScriptPtr + 1], a
    jp PlantHandlerAndHeadWord
