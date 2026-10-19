; Return HL = $C1C9 plus A times $1B, the start of that slot's record.
;
; A is the slot index. HL is seeded at $C1BF, then advanced by $001B once
; for each index and by $000A once more, which lands on $C1C9 for index 0.
; Callers write fields there. DE is left at $000A. An index of $FF wraps
; and does not return.

SlotRecordPtr::
    ld de, $001B
    ld hl, $C1BF
    inc a

.advance
    dec a
    jr z, .base

    add hl, de
    jr .advance

.base
    ld de, $000A
    add hl, de
    ret
