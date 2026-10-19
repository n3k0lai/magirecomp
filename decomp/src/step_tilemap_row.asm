; Adds C rows to a tilemap address in HL and keeps it inside $9800–$9BFF.
; C is zero-extended and shifted left five times, so each count is one
; 32-tile row. The map is 32 rows, so C = $FE lands two rows up: 254 rows
; and -2 rows are the same place once H is folded with AND $03 and OR'd
; back onto the $9800 base (ADD $98). Callers in this bank pass C = $01
; or C = $FE. The pointer words at $C836 are still unnamed.

StepTilemapRow:
    ld e, c
    xor a
    ld d, a
    ld a, 5
.shift:
    sla e
    rl d
    dec a
    jr nz, .shift
    add hl, de
    ld a, h
    and $03
    add $98
    ld h, a
    ret
