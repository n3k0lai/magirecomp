; Bank 7 arg-table index 9. DispatchBank7ArgFromIndex7 enters here with
; the index from $C9FD in E and bank 7 still mapped.
;
; HL is $A019 plus that index (sEntryScan). Control jumps to FloorSRAMByte,
; which maps SRAM bank wSRAMBank, subtracts the byte at $C9FE from [HL],
; stores zero on a borrow, disables SRAM, and returns.
;
; sEntryScan is the name from indexed_tail_07.asm. FloorSRAMByte is the
; name from floor_sram_byte.asm. DefaultBank7ArgTable is the name from
; dispatch_bank7_arg.asm.

Bank7FloorEntryScan::
    ld hl, sEntryScan
    add hl, de
    jp FloorSRAMByte
