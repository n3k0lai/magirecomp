; Bank 7 at $5CE2. StepStagedColorAndCopyC7DB calls this with bank 7
; still mapped, after the word at $C7DB has been stored at $C9E5 (low)
; and $C9E6 (high).
;
; $C831 is cleared. BC is that word. WriteWordAtTwiceEStride8 writes it
; twice, eight bytes apart, starting at slot $00 of $C7AB, then again
; starting at slot $0C, then once at slot $18.
;
; A nonzero byte at $C9E2 also writes BC once at slot $08. A nonzero
; byte at $C9E3 also writes BC once at slot $14. A zero flag skips that
; slot. $C831 is set to $01 before the return.
;
; $C7AB is SavedBlockC7AB from restore_saved_tiles.asm. $C831, $C9E2,
; $C9E3, $C9E5, and $C9E6 are still unnamed. WriteWordAtTwiceEStride8
; takes HL as the table, E as the slot, A as the write count, and BC as
; the word.

WriteC9E5WordAtC7ABSlots::
    xor a
    ld [$C831], a
    ld a, [$C9E6]
    ld b, a
    ld a, [$C9E5]
    ld c, a
    ld hl, $C7AB
    ld e, $00
    ld a, $02
    call WriteWordAtTwiceEStride8
    ld hl, $C7AB
    ld e, $0C
    ld a, $02
    call WriteWordAtTwiceEStride8
    ld hl, $C7AB
    ld e, $18
    ld a, $01
    call WriteWordAtTwiceEStride8
    ld a, [$C9E2]
    and a
    jr z, .checkC9E3

    ld hl, $C7AB
    ld e, $08
    ld a, $01
    call WriteWordAtTwiceEStride8
.checkC9E3:
    ld a, [$C9E3]
    and a
    jr z, .done

    ld hl, $C7AB
    ld e, $14
    ld a, $01
    call WriteWordAtTwiceEStride8
.done:
    ld a, $01
    ld [$C831], a
    ret
