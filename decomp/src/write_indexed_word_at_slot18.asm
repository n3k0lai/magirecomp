; Bank 7 at $5C7E. LoadC9RecordPicture stores the word from the
; pair-source pointer at $C9E5 (low) and $C9E6 (high), then
; CallBankedHL runs this with bank 7 mapped.
;
; $C831 is cleared. BC is that word. WriteWordAtTwiceEStride8 writes
; it once at $C72B plus twice $18. $5C52, still INCBIN, is then called
; with the same bank. $C831 is set to $01 before the return.
;
; $C831 and $C72B are still unnamed. WriteWordAtTwiceEStride8 takes HL
; as the table, E as the slot, A as the write count, and BC as the word.

WriteIndexedWordAtSlot18::
    xor a
    ld [$C831], a
    ld a, [$C9E6]
    ld b, a
    ld a, [$C9E5]
    ld c, a
    ld hl, $C72B
    ld e, $18
    ld a, $01
    call WriteWordAtTwiceEStride8
    call WriteC9E5WordAtSlots00And0C
    ld a, $01
    ld [$C831], a
    ret
