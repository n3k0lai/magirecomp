; Bank 7 at $5C9D. SeedRowMaskAndRecord calls this through CallBankedHL
; with E = $07, so this bank is mapped for the call and restored after.
;
; $C831 is cleared. BC is the word at $C9E5 (low) and $C9E6 (high).
; WriteWordAtTwiceEStride8 writes that word once at $C7AB plus twice
; $14. $C831 is set to $01 before the return.
;
; $C831, $C7AB, $C9E5, and $C9E6 are still unnamed. WriteWordAtTwiceEStride8
; takes HL as the table, E as the slot, A as the write count, and BC as
; the word.

WriteC9E5WordAtC7ABSlot14::
    xor a
    ld [$C831], a
    ld a, [$C9E6]
    ld b, a
    ld a, [$C9E5]
    ld c, a
    ld hl, $C7AB
    ld e, $14
    ld a, $01
    call WriteWordAtTwiceEStride8
    ld a, $01
    ld [$C831], a
    ret
