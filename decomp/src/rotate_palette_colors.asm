; Bank 7 at $45B2. HL is a table of 8-byte palettes and E is the
; palette index. Each palette is four little-endian color words:
; color 0 at bytes 0–1, color 1 at 2–3, color 2 at 4–5, color 3 at 6–7.
;
; A selects the move:
;   $03 rotates colors 1–3. Color 1 becomes old color 3, color 2
;       becomes old color 1, and color 3 becomes old color 2.
;       Color 0 stays put.
;   $04 rotates all four colors the same way: color 0 becomes old
;       color 3, color 1 becomes old color 0, color 2 becomes old
;       color 1, and color 3 becomes old color 2.
;   any other value swaps color 2 with color 3.
;
; CyclePanelSlotPaletteColors calls this with A = $03. The file address
; is $01C5B2.

; Byte offset of color 2 inside an 8-byte palette.
DEF PALETTE_COLOR2_OFFSET EQU $04

; Byte offset of color 3 inside an 8-byte palette.
DEF PALETTE_COLOR3_OFFSET EQU $06

RotatePaletteColors::
    cp $04
    jr z, .rewriteFour
    cp $03
    jr z, .rotateColors123

; Swap color 2 with color 3.
    ld d, $00
    sla e
    sla e
    sla e
    add hl, de
    ld e, PALETTE_COLOR3_OFFSET
    add hl, de
    push hl
    pop bc
    dec bc
    dec bc
    push bc
    ld a, [hl+]
    ld e, a
    ld a, [hl-]
    ld d, a
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    pop hl
    ld a, e
    ld [hl+], a
    ld [hl], d
    ret

.rotateColors123:
    ld d, $00
    sla e
    sla e
    sla e
    add hl, de
    ld e, PALETTE_COLOR2_OFFSET
    add hl, de
    push hl
    pop bc
    dec bc
    dec bc
    ld a, [hl+]
    ld e, a
    ld a, [hl-]
    ld d, a
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    dec bc
    push hl
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    inc bc
    pop hl
    ld a, e
    ld [hl+], a
    ld [hl], d
    ret

.rewriteFour:
    ld d, $00
    sla e
    sla e
    sla e
    add hl, de
    ld e, PALETTE_COLOR3_OFFSET
    add hl, de
    push hl
    pop bc
    dec bc
    dec bc
    push bc
    ld a, [hl+]
    ld e, a
    ld a, [hl-]
    ld d, a
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    dec bc
    pop hl
    dec hl
    dec hl
    push hl
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl+]
    ld [bc], a
    dec bc
    dec bc
    dec bc
    pop hl
    dec hl
    dec hl
    ld a, [hl+]
    ld [bc], a
    inc bc
    ld a, [hl-]
    ld [bc], a
    ld a, e
    ld [hl+], a
    ld [hl], d
    ret
