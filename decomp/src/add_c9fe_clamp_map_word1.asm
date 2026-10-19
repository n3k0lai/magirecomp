; Bank 7 arg-table index 5. DispatchBank7Arg enters here with the
; index from $C9FD in E and bank 7 still mapped. This handler never
; reads E.
;
; SRAM bank wSRAMBank+1 is selected. `add a, $01` is the bank bump used
; by DrawStartScreenMap before it reads these two words. Nothing reads
; the flags that add leaves. Both words are stored high byte first.
; sMapWord1 grows by the zero-extended byte at $C9FE, then is clamped
; so it does not pass sMapWord2.
;
; DE is the two's complement of sMapWord2. Adding it to the grown word
; sets carry when that word is at least the cap. A carry reloads DE
; from sMapWord2. No carry leaves the grown word in DE, because `pop de`
; takes the copy saved before the compare. DE is written back to
; sMapWord1 and SRAM is disabled.
;
; sMapWord1 and sMapWord2 are the names from draw_start_screen_map.asm.
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG is the name from reset.asm.
; wBank7ArgC9FC is the name from copy_three_c9fc_bank7.asm.

AddC9FEClampMapWord1::
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
    ld e, [hl]
    ld d, a
    ld hl, sMapWord1
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    add hl, bc
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc de
    push hl
    add hl, de
    pop de
    jr nc, .store

    ld hl, sMapWord2
    ld a, [hl+]
    ld e, [hl]
    ld d, a
.store:
    ld a, e
    ld [sMapWord1 + 1], a
    ld a, d
    ld [sMapWord1], a
    xor a
    ld [rRAMG], a
    ret
