; Bank 4 at $6F9E. DrawEntryFieldsVRAM1 calls this after
; FillEntryMap9C00AttrVRAM1, with rVBK cleared to 0 and ROM bank 4
; mapped. The matching VRAM bank 1 attribute fill is $6F79.
;
; FillBytes reads the fill value from E. A is loaded with that value
; and copied to E, the same shape as FillEntryMapTile80VRAM0. This
; fill writes tile $80 across the whole $0400-byte map at $9C00,
; all 32 rows. The $9C00 map is placed after this returns.
;
; On return A is $80, BC is 0, and HL is $A000. FillBytes is the name
; from fill_bytes.asm. ENTRY_MAP_9C00 is the name from
; draw_entry_fields_vram1.asm. ENTRY_MAP_FULL_LEN is the name from
; fill_entry_map_9c00_attr_vram1.asm. ENTRY_MAP_TILE is the name from
; fill_entry_map_tile80_vram0.asm. rVBK is the name from
; setup_window.asm.

FillEntryMap9C00Tile80VRAM0::
    ld hl, ENTRY_MAP_9C00
    ld bc, ENTRY_MAP_FULL_LEN
    ld a, ENTRY_MAP_TILE
    ld e, a
    call FillBytes
    ret
