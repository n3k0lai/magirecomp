; Bank 4 at $734D. InstallScriptRecordLoopBank4 calls this on every pass
; of the bank 4 loop, after $71A6. Bank 4 is already mapped. This routine
; does not write rROMB0.
;
; wVBlankRoutine ($C6E2) is pointed at $36F9, still INCBIN. ArmPanelCallback
; runs in bank 7. Bit 7 of $C9BC is cleared. $73AA (still INCBIN) is called
; twice: A = 0 with D = [$C9BE] writes $C9C0, then A = 1 with D = [$C9BF]
; writes $C9C1. E is the masked $C9BC both times. DE is saved around $709E
; (still INCBIN). E then becomes $87 minus that masked byte, and $C9C2
; becomes [$C9C4] plus the new E. The masked $C9BC is copied to
; wCameraPixelX.
;
; When [$C9C7] is not 1, FinishFrame runs and this returns. When it is 1,
; hVBlankFlags is set to $87, bank 7's $5897 (SelectSoundCommand) runs, and
; WaitVBlankFlag runs. What $36F9, $709E, $73AA, $C9BC–$C9C4, and $C9C7
; mean is still unknown.
;
; wVBlankRoutine is the name from default_state.asm. wCameraPixelX is the
; name from queue_sprite_list.asm. hVBlankFlags is the name from
; draw_cgb_notice.asm. CallBankedHL, ArmPanelCallback, FinishFrame, and
; WaitVBlankFlag are already source.

; Bank 0 address stored at wVBlankRoutine. Still INCBIN.
DEF VBLANK_ROUTINE_36F9 EQU $36F9

; Bank passed to CallBankedHL for ArmPanelCallback and for $5897.
DEF PANEL_FRAME_BANK EQU $07

ApplyC9BCScrollThenFrame::
    ld a, LOW(VBLANK_ROUTINE_36F9)
    ld [wVBlankRoutine], a
    ld a, HIGH(VBLANK_ROUTINE_36F9)
    ld [wVBlankRoutine + 1], a
    ld hl, ArmPanelCallback
    ld e, PANEL_FRAME_BANK
    call CallBankedHL
    ld a, [$C9BC]
    and $7F
    ld [$C9BC], a
    ld e, a
    ld a, [$C9BE]
    ld d, a
    xor a
    call $73AA
    ld a, [$C9BF]
    ld d, a
    ld a, $01
    call $73AA
    push de
    call $709E
    pop de
    ld a, $87
    sub e
    ld e, a
    ld a, [$C9C4]
    add e
    ld [$C9C2], a
    ld a, [$C9BC]
    ld [wCameraPixelX], a
    ld a, [$C9C7]
    cp $01
    jr z, .sound_then_wait
    call FinishFrame
    ret

.sound_then_wait:
    ld a, $87
    ldh [hVBlankFlags], a
    ld hl, $5897
    ld e, PANEL_FRAME_BANK
    call CallBankedHL
    call WaitVBlankFlag
    ret
