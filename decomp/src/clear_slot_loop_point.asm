; Clear the current slot's wStreamLoopWord.

ClearSlotLoopPoint::
    ld a, [wSlotStreamIndex]
    sla a
    ld e, a
    ld d, $00
    ld hl, wStreamLoopWord
    add hl, de
    xor a
    ld [hl+], a
    ld [hl], a
    ret
