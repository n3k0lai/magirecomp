; Bank 4 at $718B. DrawEntryFieldsVRAM1 calls this after $2DC3,
; with ROM bank 4 mapped and rVBK still 0. The $9C00 map is the one
; that routine just placed for a nonzero panel slot.
;
; XorHLWithE reads the mask from E. A is loaded with $28 and copied to
; E, the same shape as the tile fills. That pass XORs $28 into $0140
; bytes at $9C00, ten rows of the 32-wide map. ClampAddedByte then adds
; $03 to those same bytes and stores $FF when the sum is not below $FF.
;
; On return BC is 0 and HL is $9D40. XorHLWithE and ClampAddedByte are
; already source. ENTRY_MAP_9C00 is the name from
; draw_entry_fields_vram1.asm. ENTRY_STRIP_LEN is the ten-row length
; from fill_entry_map_tile80_vram0.asm. rVBK is the name from
; setup_window.asm.

; XOR mask applied to each tile id in the ten-row strip.
DEF ENTRY_MAP_9C00_XOR EQU $28

; Added to each tile id after the XOR. A sum that is not below $FF
; becomes $FF.
DEF ENTRY_MAP_9C00_ADD EQU $03
DEF ENTRY_MAP_9C00_CAP EQU $FF

XorThenClampEntryMap9C00::
    ld hl, ENTRY_MAP_9C00
    ld bc, ENTRY_STRIP_LEN
    ld a, ENTRY_MAP_9C00_XOR
    ld e, a
    call XorHLWithE
    ld hl, ENTRY_MAP_9C00
    ld bc, ENTRY_STRIP_LEN
    ld d, ENTRY_MAP_9C00_CAP
    ld a, ENTRY_MAP_9C00_ADD
    ld e, a
    call ClampAddedByte
    ret
