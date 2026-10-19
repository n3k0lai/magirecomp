; Bank 7 arg-table index 11. DispatchBank7Arg enters here with the
; byte from $C9FD in E and D cleared. Bank 7 is still mapped.
;
; HL becomes SRAM_SCAN_C plus that byte. The next load replaces HL, so
; the address is not used. SRAM bank wSRAMBank is selected. `add a, $00`
; keeps that bank byte and its flags. Nothing reads them.
;
; DE is the two's complement of the zero-extended byte at $C9FE, so
; adding it subtracts that byte from the little-endian word at sMapWord0.
; Carry means the word was at least $C9FE, and that path stores zero.
; No carry means the word was smaller, and the wrapped sum
; (word - $C9FE + $10000) is stored. The word is written high byte
; first and SRAM is disabled.
;
; sMapWord0 is the name from draw_start_screen_map.asm. SRAM_SCAN_C,
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG is the name from reset.asm.
; wBank7ArgC9FC is the name from copy_three_c9fc_bank7.asm.

SubC9FEClearOrWrapMapWord0::
    ld hl, SRAM_SCAN_C
    add hl, de
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wBank7ArgC9FC + 2]
    ld e, a
    ld d, $00
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    ld hl, sMapWord0
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, de
    jr nc, .store

    ld hl, $0000
.store:
    ld a, h
    ld [sMapWord0 + 1], a
    ld a, l
    ld [sMapWord0], a
    xor a
    ld [rRAMG], a
    ret
