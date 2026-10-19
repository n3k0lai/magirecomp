; STAT handler at $3677.
;
; LCDStat pushes AF and HL, then jumps through hSTATHandler. This copies
; $C9C2 into rWX, $C9BC into rSCX, and $C9BD into rSCY, and sets rLYC to
; $71. The next handler, $36B1, is stored little-endian at hSTATHandler.
; That body is still INCBIN.
;
; The current ROM bank is saved and bank 4 is mapped. The word at $C9F2
; is called through JumpHL, so that pointer runs in bank 4. The saved
; bank is written back. HL and AF are popped and the interrupt returns.
;
; rWX is the name from setup_window.asm. rSCX and rSCY are the names from
; lcd_off_setup.asm. rLYC is the name from copy_window_position.asm.
; hSTATHandler is the name from lcd_stat.asm. wCurrentROMBank and rROMB0
; are the names from reset.asm. JumpHL is the trampoline at $0789.
; ApplyC9BCScrollThenFrame writes $C9C2 from $C9C4 and the masked $C9BC.
; SeedScriptScrollAndRecord clears $C9BC and $C9C2 and writes $58 at
; $C9BD. What the word at $C9F2 points at is still unknown.

; Line compare value stored in rLYC.
DEF STAT_LYC_LINE EQU $71

; ROM bank mapped around the call through $C9F2.
DEF STAT_STEP_BANK EQU $04

; Next STAT handler. Still INCBIN.
DEF NEXT_STAT_HANDLER EQU $36B1

; Little-endian pointer called with bank 4 mapped. Still unknown.
DEF wStatStepPtr EQU $C9F2

StatWindowScrollThenBank4::
    ld a, [$C9C2]
    ldh [rWX], a
    ld a, [$C9BC]
    ldh [rSCX], a
    ld a, [$C9BD]
    ldh [rSCY], a
    ld a, STAT_LYC_LINE
    ldh [rLYC], a
    ld a, LOW(NEXT_STAT_HANDLER)
    ldh [hSTATHandler], a
    ld a, HIGH(NEXT_STAT_HANDLER)
    ldh [hSTATHandler + 1], a
    ld a, [wCurrentROMBank]
    push af
    ld a, STAT_STEP_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld hl, wStatStepPtr
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop hl
    pop af
    reti
