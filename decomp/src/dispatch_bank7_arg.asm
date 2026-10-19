; Jump through the word table at HL, indexed by the byte at $C9FC.
;
; CopyThreeBytesCallBank7 stores three script bytes at $C9FC and calls this
; entry with bank 7 mapped. This entry points HL at the table at $5D7F, still
; INCBIN. Another caller enters at DispatchBank7ArgIndex with its own table
; already in HL.
;
; The index is doubled into DE. `add a` leaves the overflow in carry, and
; `rlc d` (D is 0) moves that carry into D and clears carry, so DE is the
; byte index times two. HL then holds the handler address from the table.
; The byte at $C9FD is passed to that handler in E, with D cleared again.
; $C9FE is left untouched for the handler. Control leaves with `jp hl`.

; Default handler table. Still INCBIN in this bank.
DEF DefaultBank7ArgTable EQU $5D7F

DispatchBank7Arg::
    ld hl, DefaultBank7ArgTable

DispatchBank7ArgIndex::
    ld a, [wBank7ArgC9FC]
    add a
    ld e, a
    ld d, $00
    rlc d
    add hl, de
    ld a, [wBank7ArgC9FC + 1]
    ld e, a
    ld d, $00
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp hl

DispatchBank7ArgEnd:
