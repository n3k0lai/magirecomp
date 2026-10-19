; Bank 7 handler, table at $5D7F index 1.
;
; DispatchBank7Arg enters with the $C9FD byte in E and D cleared. HL becomes
; SRAM_SCAN_C plus that index, and the index is saved at wUnknownCD8C.
; $11 is written at wListTailDest. wUnknownCD8F then points at the next
; byte, and CopyIndexedName in bank 6 copies the ten-byte name there. That
; call returns BC one past the name, where $FC is stored. What reads the
; $C949 buffer is still unknown.
;
; $743C is the add, and another routine still in INCBIN jumps here with its
; own SRAM address in HL. SRAM bank wSRAMBank is selected. `add a, $00`
; keeps that bank byte and its flags. Nothing reads them. The SRAM byte is
; added to $C9FE. A carry stores $FF and clears $C9FD. No carry stores the
; sum and sets $C9FD to 1. SRAM is disabled and the handler returns.
;
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm. SRAM_SCAN_C is the name from
; handle_start_press.asm. wUnknownCD8C and wUnknownCD8F are the names from
; indexed_tail_07.asm. wListTailDest and LIST_TAIL_MARK are the names from
; setup_command_4d.asm. wBank7ArgC9FC is the name from
; copy_three_c9fc_bank7.asm. CopyIndexedName and CallBankedHL are already
; source.

; Written at $C949 ahead of the ten-byte name. What it means is still unknown.
DEF NAME_LEAD_BYTE EQU $11

; Bank passed to CallBankedHL for CopyIndexedName.
DEF COPY_NAME_BANK EQU $06

; Stored at $C9FD when the SRAM byte plus $C9FE fits.
DEF SCAN_ADD_OK EQU $01

CopyNameAndAddScanC::
    ld hl, SRAM_SCAN_C
    add hl, de
    push hl
    ld a, e
    ld [wUnknownCD8C], a
    ld hl, wListTailDest
    ld a, NAME_LEAD_BYTE
    ld [hl+], a
    ld a, h
    ld [wUnknownCD8F + 1], a
    ld a, l
    ld [wUnknownCD8F], a
    ld hl, CopyIndexedName
    ld e, COPY_NAME_BANK
    call CallBankedHL
    ld a, LIST_TAIL_MARK
    ld [bc], a
    pop hl

; Add $C9FE to the SRAM byte at HL. Clamp a carry to $FF.
AddByteToScanC::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [hl]
    ld c, a
    ld a, [wBank7ArgC9FC + 2]
    add c
    jr nc, .storeSum

    ld a, $FF
    ld [hl], a
    xor a
    ld [wBank7ArgC9FC + 1], a
    jr .disable

.storeSum:
    ld [hl], a
    ld a, SCAN_ADD_OK
    ld [wBank7ArgC9FC + 1], a
.disable:
    xor a
    ld [rRAMG], a
    ret
