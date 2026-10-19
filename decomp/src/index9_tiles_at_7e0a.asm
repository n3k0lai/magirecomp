; Bank 6 at $7E0A (file $01BE0A). CopyIndex9VRAMTiles copies $460
; bytes from $79A6 to VRAM bank 1 at $9000, seventy 8x8 2bpp tiles.
; That copy ends at $7E06, on row 1 of tile $46. A row is stored low
; plane, then high plane. These sixty-four bytes continue that stream:
; the rest of tile $46, tiles $47–$49, and the first two rows of tile
; $4A. Every row is blank. They sit just after the copy, so the $460
; bytes do not include them. The rest of the hole stays in the
; following INCBIN.

Index9TilesAt7E0A::
    ds 12                          ; $46 rows 2-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $47 rows 0-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $48 rows 0-7: 0 0 0 0 0 0 0 0
    ds 16                          ; $49 rows 0-7: 0 0 0 0 0 0 0 0
    ds 4                           ; $4A rows 0-1: 0 0 0 0 0 0 0 0
