; Shared tail at bank 7 $74A6. FloorGroupSRAMByte and the $A019 entry
; still in this bank jump here with an SRAM address in HL. The four bytes
; just before this label, still INCBIN, point HL at SRAM_SCAN_C plus DE
; and fall through.
;
; SRAM bank wSRAMBank is selected. `add a, $00` keeps that bank byte and
; its flags. Nothing reads them. The byte at HL loses $C9FE. A borrow
; stores zero. SRAM is disabled and the tail returns.
;
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm. wBank7ArgC9FC is the name from
; copy_three_c9fc_bank7.asm. FloorSRAMByteAtHL is the address name from
; floor_group_sram_byte.asm.

FloorSRAMByte::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wBank7ArgC9FC + 2]
    ld c, a
    ld a, [hl]
    sub c
    jr nc, .store

    xor a
.store:
    ld [hl], a
    xor a
    ld [rRAMG], a
    ret
