; Bank 7 at $65AF. Called from FloorRemainderSramAndCopyEight.
;
; $6551 is still INCBIN. It runs first, then this returns when [$D103]
; is $05 or higher.
;
; Otherwise A is [$D103] - 1, doubled, and used as the index of a word
; at $D36E. That word's high byte is left in H. The low byte and the
; SRAM add of [$CD93], capped at $63, continue in
; AddCd93IntoNextSramByte, whose first instruction is `ld l, a`.

AddCd93IntoIndexedSramBelowFive::
    call $6551
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
