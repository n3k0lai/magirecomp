; Bank 4 at $6F47. DrawEntryFieldsVRAM0 calls this after UnpackBytes
; has copied $800 bytes to $9000, with rVBK still 0 and ROM bank 4
; mapped. The matching VRAM bank 1 fill is $6F60 (still INCBIN), which
; uses $08 in place of $80.
;
; FillBytes reads the fill value from E. A is loaded with that value
; and copied to E, the same shape as SetupWindowTilemap. The first
; fill writes tile $80 across $0300 bytes at $9900, which is 24 rows
; of the $9800 background map and runs through $9BFF. The second fill
; writes tile $80 across $0140 bytes at $99E0, ten rows beginning at
; the entry map row. That range already sits inside the first fill.
;
; On return A is $80, BC is 0, and HL is $9B20. FillBytes is the name
; from fill_bytes.asm. rVBK is the name from setup_window.asm.

; Twenty-four rows, from row 8 of the $9800 map through $9BFF.
DEF ENTRY_BACKDROP_ROW EQU $9900
DEF ENTRY_BACKDROP_LEN EQU $0300

; Ten rows at the entry map row. Covered again by the backdrop fill.
DEF ENTRY_STRIP_LEN EQU $0140

DEF ENTRY_MAP_TILE EQU $80

FillEntryMapTile80VRAM0::
    ld hl, ENTRY_BACKDROP_ROW
    ld bc, ENTRY_BACKDROP_LEN
    ld a, ENTRY_MAP_TILE
    ld e, a
    call FillBytes
    ld hl, ENTRY_MAP_ROW
    ld bc, ENTRY_STRIP_LEN
    ld a, ENTRY_MAP_TILE
    ld e, a
    call FillBytes
    ret
