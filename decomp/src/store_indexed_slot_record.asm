; Write D, C, B, then the fixed bytes $66 and $0A, into the slot A selects.
;
; $38DE, still INCBIN, returns HL for that slot: $C1C9 plus A times $1B.
; Callers pass A as the slot index, D as the first field, and BC as the
; word that follows (stored low byte, then high byte).
;
; $38FE loads A with $0A and falls into the last store. $3900 stores A.

StoreIndexedSlotRecord::
    push de
    call $38DE
    pop de
    ld a, d
    ld [hl+], a
    ld a, c
    ld [hl+], a
    ld a, b
    ld [hl+], a
    ld a, $66
    ld [hl+], a

StoreIndexedSlotByte0A::
    ld a, $0A

StoreIndexedSlotByte::
    ld [hl+], a
    ret
