; Word-table handler at $42C4 (table entry 1 at $42A9).
;
; $CD80 is a latch. When it is already nonzero, the active slot index in
; $CD81 is copied into $CCA7 and the latch is left alone. When it is zero,
; this increments it and returns. The masked-action dispatcher at $41E3
; reaches this through JumpHL at $0789. The next table entry decrements
; the same latch, or writes $FE into $CCA7 when the latch is already clear.

LatchSelectedSlot::
    ld hl, $cd80
    ld a, [hl]
    and a
    jr z, .bumpLatch

    ld a, [$cd81]
    ld [$cca7], a
    ret

.bumpLatch
    inc [hl]
    ret
