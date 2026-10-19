; Bank 4 at $73FE. CallBank4ThenPlantHead659D reaches this through
; CallBankedHL with bank 4 mapped, then plants head word $659D.
; This routine does not write rROMB0 and does not call out.
;
; A is cleared into SCRIPT_SCROLL ($C9BC), $C9C0, and $C9C1.
; wVBlankRoutine is pointed at $37AA, still INCBIN.
; SCRIPT_SCROLL is the name from step_scroll_by_script_pair.asm.
; wVBlankRoutine is the name from default_state.asm.
; ScaleEByDIntoC9C0 writes $C9C0 and $C9C1. What $37AA does is
; still unknown.

; Bank 0 address stored at wVBlankRoutine. Still INCBIN.
DEF VBLANK_ROUTINE_37AA EQU $37AA

ClearScrollScaleAndPointVBlank37AA::
    xor a
    ld [SCRIPT_SCROLL], a
    ld [$C9C0], a
    ld [$C9C1], a
    ld a, LOW(VBLANK_ROUTINE_37AA)
    ld [wVBlankRoutine], a
    ld a, HIGH(VBLANK_ROUTINE_37AA)
    ld [wVBlankRoutine + 1], a
    ret
