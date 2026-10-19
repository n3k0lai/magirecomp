; VBlank handler. The vector at $0040 jumps here.
;
; AF, BC, DE, HL, and both bank shadows are saved. The little-endian pointer
; at wVBlankRoutine is called through JumpHL. SetupDefaultState stores
; DefaultVBlank there; that body is still INCBIN. ROM bank 7 is mapped next
; and ReadJoypad samples the buttons. hVBlankFlags is cleared, interrupts are
; enabled, and the saved banks and registers are restored.
;
; ei takes effect after the next instruction, so a nested interrupt can run
; during the restore. reti enables interrupts again. Restoring rSVBK is the
; 3-byte form. Clearing hVBlankFlags is ldh.
;
; wVBlankRoutine and DefaultVBlank are the names from default_state.asm.
; hVBlankFlags is the name from draw_cgb_notice.asm. rROMB0, wCurrentROMBank,
; and BANK_INIT are the names from reset.asm. rSVBK and wCurrentWRAMBank are
; the names from timer_overflow.asm.

; Bank 7, still INCBIN. CPU address while BANK_INIT is mapped.
; Polls rP1. $C931 is the buttons held, $C932 the ones just pressed, and
; $C933 the ones just released.
DEF ReadJoypad EQU $59FF

HandleVBlank::
    push af
    push bc
    push de
    push hl
    ld a, [wCurrentWRAMBank]
    push af
    ld a, [wCurrentROMBank]
    push af
    ld a, [wVBlankRoutine + 1]
    ld h, a
    ld a, [wVBlankRoutine]
    ld l, a
    call JumpHL
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call ReadJoypad
    xor a
    ldh [hVBlankFlags], a
    ei
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    pop af
    ld [wCurrentWRAMBank], a
    ld [rSVBK], a
    pop hl
    pop de
    pop bc
    pop af
    reti
