; Bank 7 arg-table index 8. DispatchBank7ArgFromIndex7 enters here with
; the index from $C9FD in E and bank 7 still mapped.
;
; HL is SRAM_SCAN_C plus DE. Control falls into FloorSRAMByte, which maps
; SRAM bank wSRAMBank, subtracts the byte at $C9FE from [HL], stores zero
; on a borrow, disables SRAM, and returns.
;
; SRAM_SCAN_C is the name from handle_start_press.asm. FloorSRAMByte is
; the name from floor_sram_byte.asm. DefaultBank7ArgTable is the name from
; dispatch_bank7_arg.asm.

Bank7FloorScanC::
    ld hl, SRAM_SCAN_C
    add hl, de
