; Bank 7 arg-table index 4. DispatchBank7Arg enters here with the
; index from $C9FD in E and bank 7 still mapped. This handler never
; reads E.
;
; SRAM bank wSRAMBank is selected. `add a, $00` keeps that bank byte
; and its flags. Nothing reads them. The little-endian word at
; sMapWord0 grows by the byte at $C9FE. Adding $FC19 sets carry when
; that sum is at least 999 ($03E7), and a carry stores 999. The word
; is written back and SRAM is disabled.
;
; BC becomes the two's complement of the old word. Adding it to the
; stored word leaves the delta, and the low byte of that delta replaces
; $C9FE. The high byte is discarded.
;
; sMapWord0 is the name from draw_start_screen_map.asm. wSRAMBank,
; rRAMB, and SRAM_ENABLE are the names from handle_start_press.asm.
; rRAMG is the name from reset.asm. wBank7ArgC9FC is the name from
; copy_three_c9fc_bank7.asm.

; Cap for the word at sMapWord0.
DEF MAP_WORD0_CAP EQU $03E7

; $10000 - MAP_WORD0_CAP. Adding it sets carry when HL is at least the cap.
DEF MAP_WORD0_CAP_BIAS EQU $FC19

AddC9FEToMapWord0::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wBank7ArgC9FC + 2]
    ld e, a
    ld d, $00
    ld hl, sMapWord0
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    push hl
    add hl, de
    ld de, MAP_WORD0_CAP_BIAS
    push hl
    add hl, de
    pop hl
    jr nc, .store

    ld hl, MAP_WORD0_CAP
.store:
    ld a, h
    ld [sMapWord0 + 1], a
    ld a, l
    ld [sMapWord0], a
    xor a
    ld [rRAMG], a
    pop bc
    ld a, c
    cpl
    ld c, a
    ld a, b
    cpl
    ld b, a
    inc bc
    add hl, bc
    ld a, l
    ld [wBank7ArgC9FC + 2], a
    ret
