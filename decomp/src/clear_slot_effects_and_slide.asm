; ClearSlotEffects, then (except for slot 3) clear the slot's wSlideSumB
; word. E is the slot index left by ClearSlotEffects.

ClearSlotEffectsAndSlide::
    call ClearSlotEffects
    ld a, e
    cp $03
    ret z
    sla e
    xor a
    ld hl, wSlideSumB
    add hl, de
    ld [hl+], a
    ld [hl], a
    ret
