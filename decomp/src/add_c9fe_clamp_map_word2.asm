; Bank 7 arg-table index 6. DispatchBank7Arg enters here with the
; index from $C9FD in E and bank 7 still mapped. This handler never
; reads E.
;
; SRAM bank wSRAMBank+1 is selected. `add a, $01` is the bank bump used
; by DrawStartScreenMap before it reads these words. Nothing reads the
; flags that add leaves. sMapWord2 is stored high byte first. It grows
; by the zero-extended byte at $C9FE. Adding $FC19 sets carry when that
; sum is at least 999 ($03E7), and a carry stores 999. The word is
; written back and SRAM is disabled. Unlike the map-word-0 handler, the
; delta is not written back to $C9FE.
;
; MAP_WORD0_CAP and MAP_WORD0_CAP_BIAS are the names from
; add_c9fe_to_map_word0.asm. sMapWord2 is the name from
; draw_start_screen_map.asm. wSRAMBank, rRAMB, and SRAM_ENABLE are the
; names from handle_start_press.asm. rRAMG is the name from reset.asm.
; wBank7ArgC9FC is the name from copy_three_c9fc_bank7.asm.

AddC9FEClampMapWord2::
    ld a, [wSRAMBank]
    add a, $01
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wBank7ArgC9FC + 2]
    ld c, a
    ld b, $00
    ld hl, sMapWord2
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    add hl, bc
    ld de, MAP_WORD0_CAP_BIAS
    push hl
    add hl, de
    pop de
    jr nc, .store

    ld de, MAP_WORD0_CAP
.store:
    ld a, e
    ld [sMapWord2 + 1], a
    ld a, d
    ld [sMapWord2], a
    xor a
    ld [rRAMG], a
    ret
