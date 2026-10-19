; Word-table handler at $42B7 (table entry 4 at $42A9).
;
; Copies the active slot index in $CD81 into $CCA7. The masked-action
; dispatcher at $41E3 reaches this through the far call at $0789. Neighboring
; entries write $FE into the same byte or adjust $CD80 instead.

StoreSelectedSlotIndex::
    ld a, [$cd81]
    ld [$cca7], a
    ret
