; Bank 7 at $5C52. WriteIndexedWordAtSlot18 calls this with bank 7
; still mapped.
;
; $C831 is cleared. BC is the word at $C9E5 (low) and $C9E6 (high).
; WriteWordAtTwiceEStride8 writes that word twice, eight bytes apart,
; starting at slot $00 of $C72B, then again starting at slot $0C.
; $5D32, still INCBIN, is called with HL = $C72B. $C831 is set to $01
; before the return.
;
; $C831, $C72B, $C9E5, and $C9E6 are still unnamed. WriteWordAtTwiceEStride8
; takes HL as the table, E as the slot, A as the write count, and BC as
; the word.

WriteC9E5WordAtSlots00And0C::
    xor a
    ld [$C831], a
    ld a, [$C9E6]
    ld b, a
    ld a, [$C9E5]
    ld c, a
    ld hl, $C72B
    ld e, $00
    ld a, $02
    call WriteWordAtTwiceEStride8
    ld hl, $C72B
    ld e, $0C
    ld a, $02
    call WriteWordAtTwiceEStride8
    ld hl, $C72B
    call Replace3DE0AtSlots08And14
    ld a, $01
    ld [$C831], a
    ret
