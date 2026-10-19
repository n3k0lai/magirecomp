; Called from the routine at $36F9 when bit 0 of $FF9E is set, after the
; LCD is turned on with LCDC $E3.
;
; rWX is set to $A7 so the window starts at pixel 160 and sits off the
; right edge. rSCX is copied from $C9C0, rSCY is cleared, and rWY is
; copied from $C9C3. rLYC is set to $1F.
;
; Bank 4 is written to wCurrentROMBank and rROMB0 and is left mapped.
; The word at $C9F2 is loaded and called four times through JumpHL.
; Each call may clobber HL, so the pointer is pushed and popped around
; every call. The previous ROM bank is not saved.
;
; rWX is the name from setup_window.asm. rSCX and rSCY are the names from
; lcd_off_setup.asm. rWY and rLYC are the names from copy_window_position.asm.
; wCurrentROMBank and rROMB0 are the names from reset.asm. JumpHL is the
; trampoline at $0789. ScaleEByDIntoC9C0 writes $C9C0 when A is zero.
; SeedScriptScrollAndRecord clears $C9C0 and writes $20 at $C9C3.
; What those bytes mean here, and what the word at $C9F2 points at, is
; still unknown.

; Line compare value stored in rLYC. STAT_WX_OFF_RIGHT, STAT_STEP_BANK, and
; wStatStepPtr are the names from the earlier STAT handlers.
DEF STAT_LYC_LINE_1F EQU $1F

ApplyC9C0WindowThenCallStepFour::
    ld a, STAT_WX_OFF_RIGHT
    ldh [rWX], a
    ld a, [$C9C0]
    ldh [rSCX], a
    xor a
    ldh [rSCY], a
    ld a, [$C9C3]
    ldh [rWY], a
    ld a, STAT_LYC_LINE_1F
    ldh [rLYC], a
    ld a, STAT_STEP_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld hl, wStatStepPtr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    rept 4
        push hl
        call JumpHL
        pop hl
    endr
    ret
