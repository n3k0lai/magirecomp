; Bank 4 at $6F60. DrawEntryFieldsVRAM0 calls this after
; FillEntryMapTile80VRAM0, with rVBK set to 1 and ROM bank 4 mapped.
; The same two ranges are written again, this time as background-map
; attributes. $08 sets bit 3, so those tiles are read from VRAM bank 1.
;
; FillBytes reads the fill value from E. A is loaded with that value
; and copied to E, the same shape as the tile-$80 fill. The first fill
; writes $08 across $0300 bytes at $9900. The second writes $08 across
; $0140 bytes at $99E0, which already sits inside the first fill.
;
; On return A is $08, BC is 0, and HL is $9B20. FillBytes is the name
; from fill_bytes.asm. ENTRY_BACKDROP_ROW, ENTRY_BACKDROP_LEN, and
; ENTRY_STRIP_LEN are the names from fill_entry_map_tile80_vram0.asm.
; ENTRY_MAP_ROW is the name from draw_entry_fields_vram0.asm.

; Bit 3 of a background attribute selects VRAM bank 1 for the tile.
DEF ENTRY_MAP_ATTR EQU $08

FillEntryMapAttr08VRAM1::
    ld hl, ENTRY_BACKDROP_ROW
    ld bc, ENTRY_BACKDROP_LEN
    ld a, ENTRY_MAP_ATTR
    ld e, a
    call FillBytes
    ld hl, ENTRY_MAP_ROW
    ld bc, ENTRY_STRIP_LEN
    ld a, ENTRY_MAP_ATTR
    ld e, a
    call FillBytes
    ret
