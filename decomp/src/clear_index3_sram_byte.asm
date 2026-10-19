; Bank 7 arg-table index 10. DispatchBank7Arg enters here with the
; index from $C9FD in E and D cleared. Bank 7 stays mapped.
;
; HL is Index3SRAMOrigin plus that index, the same SRAM byte
; StoreIndex3RecordByte writes. SRAM bank wSRAMBank is selected.
; `add a, $00` keeps that bank byte and its flags. Nothing reads them.
; The byte at HL is stored as zero, SRAM is disabled, and the handler
; returns. The second `xor a` clears A again after the store.
;
; Index3SRAMOrigin is the name from store_index3_record_byte.asm.
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE
; are the names from handle_start_press.asm.

ClearIndex3SRAMByte::
    ld hl, Index3SRAMOrigin
    add hl, de
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    xor a
    ld [hl], a
    xor a
    ld [rRAMG], a
    ret
