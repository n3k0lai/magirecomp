; Bank 4 at $6F79. DrawEntryFieldsVRAM1 calls this after UnpackBytes
; has copied $800 bytes to $9000, with rVBK still 1 and ROM bank 4
; mapped. The matching VRAM bank 0 tile fill is $6F9E (still INCBIN).
;
; FillBytes reads the fill value from E. A is loaded with that value
; and copied to E, the same shape as FillEntryMapAttr08VRAM1. The first
; fill writes attribute $28 across the whole $0400-byte map at $9C00.
; $28 sets bit 3 and bit 5, so those tiles come from VRAM bank 1 and
; are flipped horizontally. The second fill writes attribute $00 across
; $0140 bytes at $9C00, the first ten rows, which the first fill just
; covered. The third fill writes attribute $28 across $0140 bytes at
; $9D40, the next ten rows, which the first fill also covered.
;
; On return A is $28, BC is 0, and HL is $9E80. FillBytes is the name
; from fill_bytes.asm. ENTRY_MAP_9C00 is the name from
; draw_entry_fields_vram1.asm. ENTRY_STRIP_LEN is the name from
; fill_entry_map_tile80_vram0.asm. rVBK is the name from
; setup_window.asm.

; Whole $9C00 background map, 32 rows.
DEF ENTRY_MAP_FULL_LEN EQU $0400

; Row 10 of the $9C00 map. Ten rows, already inside the full-map fill.
DEF ENTRY_MAP_ROW10 EQU $9D40

; Bit 3 selects VRAM bank 1. Bit 5 flips the tile horizontally.
DEF ENTRY_MAP_ATTR_XFLIP EQU $28

; Palette 0, VRAM bank 0, no flip.
DEF ENTRY_MAP_ATTR_CLEAR EQU $00

FillEntryMap9C00AttrVRAM1::
    ld hl, ENTRY_MAP_9C00
    ld bc, ENTRY_MAP_FULL_LEN
    ld a, ENTRY_MAP_ATTR_XFLIP
    ld e, a
    call FillBytes
    ld hl, ENTRY_MAP_9C00
    ld bc, ENTRY_STRIP_LEN
    ld a, ENTRY_MAP_ATTR_CLEAR
    ld e, a
    call FillBytes
    ld hl, ENTRY_MAP_ROW10
    ld bc, ENTRY_STRIP_LEN
    ld a, ENTRY_MAP_ATTR_XFLIP
    ld e, a
    call FillBytes
    ret
