; Word-table handler at $42D4 (table entry 2 at $42A9).
;
; $CD80 is a latch. When it is already nonzero, this decrements it and
; returns. When it is zero, $FE is written into $CCA7. The previous table
; entry increments the same latch, or copies $CD81 into $CCA7 when the
; latch is already set. The masked-action dispatcher at $41E3 reaches this
; through JumpHL at $0789.

DecrementSlotLatch::
    ld hl, $cd80
    ld a, [hl]
    and a
    jr z, .storeSentinel

    dec [hl]
    ret

.storeSentinel
    ld a, $fe
    ld [$cca7], a
    ret
