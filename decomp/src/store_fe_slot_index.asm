; Word-table handler at $42BE (table entry 5 at $42A9).
;
; Writes $FE into $CCA7. The masked-action dispatcher at $41E3 reaches
; this through JumpHL at $0789. The previous entry copies the active slot
; index from $CD81 into the same byte; $FE is the sentinel the neighbors
; also store there.

StoreFeSlotIndex::
    ld a, $fe
    ld [$cca7], a
    ret
