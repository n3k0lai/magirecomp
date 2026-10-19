; Bank 6 at $7E4A (file $01BE4A). CopyIndex9VRAMTiles copies $460
; bytes from $79A6 to VRAM bank 1 at $9000, seventy 8x8 2bpp tiles.
; That copy ends at $7E06, on row 1 of tile $46. A row is stored low
; plane, then high plane. These sixty-four bytes continue the blank
; stream that begins at $7E06: the rest of tile $4A, tiles $4B–$4D,
; and the first two rows of tile $4E. Every row is blank. They sit
; just after the copy, so the $460 bytes do not include them. The rest
; of the hole stays in the following INCBIN.

Index9TilesAt7E4A::
    ds 12                          ; $4A rows 2-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $4B rows 0-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $4C rows 0-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $4D rows 0-7: 0 0 0 0 0 0 0 0
    ds 4                           ; $4E rows 0-1: 0 0 0 0 0 0 0 0
