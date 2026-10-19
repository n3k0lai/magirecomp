; Bank 6 at $7F0A (file $01BF0A). CopyIndex9VRAMTiles copies $460
; bytes from $79A6 to VRAM bank 1 at $9000, seventy 8x8 2bpp tiles.
; That copy ends at $7E06, on row 1 of tile $46. A row is stored low
; plane, then high plane. These sixty-four bytes continue the blank
; stream that begins at $7E06: the rest of tile $56, tiles $57–$59,
; and the first two rows of tile $5A. Every row is blank. They sit
; just after the copy, so the $460 bytes do not include them. The rest
; of the hole stays in the following INCBIN.

Index9TilesAt7F0A::
    ds 12                          ; $56 rows 2-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $57 rows 0-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $58 rows 0-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $59 rows 0-7: 0 0 0 0 0 0 0 0
    ds 4                           ; $5A rows 0-1: 0 0 0 0 0 0 0 0
