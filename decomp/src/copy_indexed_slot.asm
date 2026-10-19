; Copy the 8-byte record selected by the index at $CD81.
;
; $CCAE/$CCAF holds the base address. The index is shifted left by three
; (multiplied by 8) and added to that base. The eight bytes are stored at
; $CD82 onward, which other bank 3 code treats as the active slot.

CopyIndexedSlot::
    ld a, [$cd81]
    ld l, a
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, hl
    ld a, [$ccaf]
    ld b, a
    ld a, [$ccae]
    ld c, a
    add hl, bc
    ld bc, $cd82
REPT 8
    ld a, [hl+]
    ld [bc], a
    inc bc
ENDR
    ret
