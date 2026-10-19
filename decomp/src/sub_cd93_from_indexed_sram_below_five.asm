; Bank 7 at $650F. The subtract twin of AddCd93IntoIndexedSramBelowFive.
;
; SubCd93FromD110PlusTenOrNameCount runs first. This returns when
; [$D103] is $05 or higher.
;
; Otherwise A is [$D103] - 1, doubled, and used as the index of a word
; at $D36E. HL becomes that word plus [$CD94] + 8. SRAM bank
; [$C727] + 1 is selected and SRAM is enabled. The byte at HL loses
; [$CD93]. A nonzero difference, including a wrapped underflow, is
; written back. A difference of zero is written back as zero.
; `sub` never sets carry on a zero result, so the `ld a, $01` between
; those two jumps stays in the image and is not reached. SRAM is
; disabled and this returns.
;
; SubCd93FromD110PlusTenOrNameCount is already source. rRAMG is the
; name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are the names
; from handle_start_press.asm.

SubCd93FromIndexedSramBelowFive::
    call SubCd93FromD110PlusTenOrNameCount
    ld a, [$D103]
    cp $05
    ret nc

    dec a
    add a
    ld c, a
    ld b, $00
    ld hl, $D36E
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
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
    sub [hl]
    jr nz, .storeDifference

    jr nc, .storeDifference

    ld a, $01

.storeDifference:
    pop hl
    ld [hl], a
    xor a
    ld [rRAMG], a
    ret
