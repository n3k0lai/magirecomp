; Bank 0 at $3635. DrawEntryFieldsVRAM0 calls this with A = 0 and
; HL = $99E0. DrawEntryFieldsVRAM1 calls it with A nonzero and
; HL = $9C00. Both pass DE from the word at $C9D3.
;
; A = 0: if E is not $10, advance HL one tile. Then add the offset
; $3667 returns in BC.
; A nonzero: if E is below $10, add ($10 - E - the byte $3657
; returns) as C, then add the offset $3667 returns.
; HL comes back as the adjusted map address. BC is the last offset
; added. $3657 and $3667 are still INCBIN. $10 is the E value that
; skips the extra step on both paths.

; E value that skips the one-tile step (A = 0) and the $3657 step.
DEF ENTRY_MAP_E_EDGE EQU $10

PlaceEntryMapByDE::
    and a
    jr nz, .fromWindowMap
    ld a, e
    cp ENTRY_MAP_E_EDGE
    jr z, .addDOffset
    inc hl
.addDOffset:
    call $3667
    add hl, bc
    ret

.fromWindowMap:
    ld a, e
    cp ENTRY_MAP_E_EDGE
    jr nc, .addDOffsetAfterE
    call $3657
    cpl
    inc a
    add ENTRY_MAP_E_EDGE
    sub c
    ld c, a
    add hl, bc
.addDOffsetAfterE:
    call $3667
    add hl, bc
    ret
