; Bank 6 at $7F4A (file $01BF4A). CopyIndex9VRAMTiles copies $460
; bytes from $79A6 to VRAM bank 1 at $9000, seventy 8x8 2bpp tiles.
; That copy ends at $7E06, on row 1 of tile $46. A row is stored low
; plane, then high plane. These sixty-four bytes continue the blank
; stream that begins at $7E06: the rest of tile $5A, tiles $5B–$5D,
; and the first two rows of tile $5E. Every row is blank. They sit
; just after the copy, so the $460 bytes do not include them. Bank 6
; padding begins at $7F8A.

Index9TilesAt7F4A::
    ds 12                          ; $5A rows 2-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $5B rows 0-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $5C rows 0-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $5D rows 0-7: 0 0 0 0 0 0 0 0
    ds 4                           ; $5E rows 0-1: 0 0 0 0 0 0 0 0
