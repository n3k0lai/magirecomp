; Bank 1. WalkPointerSlots calls this after it retires a slot.
;
; HL is the slot word in the table at $C154. InitPointerList leaves $C132
; pointing at the free-pointer table at $C134, and the take path still in
; the INCBIN before this routine advances that cursor by one word each time
; it hands a slot out. This writes HL back into the previous word and pulls
; the cursor down by two, then zeros the slot. What fills the free table
; besides that take path is still unknown.

DEF wFreePointerCursor EQU $C132

ReturnPointerSlot::
    ld a, [wFreePointerCursor + 1]
    ld b, a
    ld a, [wFreePointerCursor]
    ld c, a
    dec bc
    ld a, h
    ld [bc], a
    dec bc
    ld a, l
    ld [bc], a
    ld a, b
    ld [wFreePointerCursor + 1], a
    ld a, c
    ld [wFreePointerCursor], a
    xor a
    inc hl
    ld [hl-], a
    ld [hl], a
    ret
