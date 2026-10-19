; Bank 7 at $65C3. The first uncovered byte of the hole that began at $5DE1.
; The bytes from $65AF through $65C2 are still INCBIN. They leave a
; pointer's high byte in H and its low byte in A.
;
; HL is that pointer plus [$CD94] + 8. SRAM bank [$C727] + 1 is selected
; and SRAM is enabled. The byte at HL is increased by [$CD93] and capped
; at $63, then written back. SRAM is disabled and this returns.
;
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm.

AddCd93IntoNextSramByte::
    ld l, a
    push hl
    ld hl, $CD94
    ld a, [hl]
    ld b, $08
    add b
    ld c, a
    ld b, $00
    pop hl
    add hl, bc
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [hl]
    push hl
    ld hl, $CD93
    add [hl]
    ld b, $63
    cp b
    jr c, .storeCapped

    ld a, b

.storeCapped:
    pop hl
    ld [hl], a
    xor a
    ld [rRAMG], a
    ret

AddCd93IntoNextSramByteEnd:
