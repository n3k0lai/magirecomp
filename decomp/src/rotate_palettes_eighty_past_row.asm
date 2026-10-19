; Bank 7 at $4870. StoreScriptBytePanelCall4870 stores a script byte at
; wUnknownC9D8, stores the next byte at wPanelSlot, maps this bank, and
; calls here.
;
; $C831 is cleared. PanelRowFromHighNibble returns HL = $C72B plus eight
; times the high nibble of wUnknownC9D8. HL is then moved $80 bytes past
; that row. One more than the low nibble is the palette count. It is kept
; in wUnknownC9DA, which other callers use as the low byte of a color word.
;
; Each pass calls RotatePaletteColors with that same HL, E stepping from
; the count minus one down to zero, and A = wPanelSlot selecting the
; rotation. HL is restored after the call because the rotation walks into
; the palette. $C831 is set to $01 before the return.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. wUnknownC9DA is the
; name from dispatch_nonzero_d016.asm. wPanelSlot is the name from
; stage_panel_glyph_dest.asm. $C831 and $C72B are still unnamed.

RotatePalettesEightyPastRow::
    xor a
    ld [$C831], a
    call PanelRowFromHighNibble
    ld bc, $0080
    add hl, bc
    ld a, [wUnknownC9D8]
    and $0F
    inc a
    ld [wUnknownC9DA], a
.palette:
    push hl
    dec a
    ld e, a
    ld a, [wPanelSlot]
    call RotatePaletteColors
    pop hl
    ld a, [wUnknownC9DA]
    dec a
    ld [wUnknownC9DA], a
    jr nz, .palette
    ld a, $01
    ld [$C831], a
    ret
