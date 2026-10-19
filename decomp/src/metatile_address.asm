; Column in D, row in E, metatile id in C. DrawMetatileWindow calls here
; with those three values, then calls CopyMetatile.
;
; A metatile is 2x2 tiles. The BG map is 32 tiles wide and starts at $9800,
; so the address is $9800 + (row * 64) + ((column * 2) & $1F). The row term
; uses only bits 0-3 of the row, which covers one full map (16 metatile
; rows). The column term keeps five tile bits, so it wraps every 16
; metatile columns.
;
; The definition pointer is $D000 + id * 4. CopyMetatile reads that with
; WRAM bank 2 mapped: four tile bytes here, four attribute bytes $400 later.

BuildMetatilePointers::
    ld b, d
    ld a, e
    rrca
    rrca
    ld e, a
    and $03
    ld d, a
    ld a, e
    and $c0
    ld e, a
    ld a, b
    add a
    and $1f
    add e
    ld e, a
    ld a, $98
    adc d
    ld d, a
    ld a, c
    rlca
    rlca
    ld l, a
    and $03
    add $d0
    ld h, a
    ld a, l
    and $fc
    ld l, a
    ret
