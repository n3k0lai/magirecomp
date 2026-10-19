; Bank 7 at $6739. The first uncovered byte after
; CopyD119WordZeroCountThenPlantCdaaScript.
;
; $65AF is still INCBIN. When [$D103] is below $05 it adds [$CD93]
; into an SRAM byte and caps the sum at $63. AddDividerStep replaces
; A, and DivideCByB replaces HL, so this call is only for that update.
;
; AddDividerStep stores a new byte at $FFA9. DivideCByB divides that
; byte by 5. The quotient is cleared. The remainder is the index below.
;
; The word at $D36E + (remainder - 1) * 2 is loaded, then remainder + 9
; is added. That sum is the SRAM address used next.
;
; When [$D103] is below $05, SRAM bank [$C727] + 1 is selected and SRAM
; is enabled. The byte at HL is decremented. A result of zero is stored
; back as 1. Both paths then disable SRAM.
;
; Eight bytes from $643D + remainder * 8 in this bank are copied to
; $C961. $FC is stored in the ninth byte, and this returns.
;
; AddDividerStep, DivideCByB, and MulCByB are already source. rRAMG is
; the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are the
; names from handle_start_press.asm. LIST_TAIL_MARK is the name from
; setup_command_4d.asm.

FloorRemainderSramAndCopyEight::
    call $65AF
    call AddDividerStep
    ld c, a
    ld b, $05
    call DivideCByB
    ld h, $00
    ld bc, $0009
    push hl
    add hl, bc
    push hl
    dec a
    add a, a
    ld c, a
    ld b, $00
    ld hl, $D36E
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    pop bc
    add hl, bc
    ld a, [$D103]
    cp $05
    jr nc, .disableSram

    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    dec [hl]
    jr nz, .disableSram

    ld [hl], $01

.disableSram:
    xor a
    ld [rRAMG], a
    pop bc
    ld b, $08
    call MulCByB
    ld bc, $643D
    add hl, bc
    ld bc, $C961
    ld d, $08

.copyEight:
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr nz, .copyEight

    ld a, LIST_TAIL_MARK
    ld [bc], a
    ret
