; Bank 7 at $42E3. StorePairThenCall42E3 stores two script bytes at
; wUnknownC9D8 and wPanelSlot, maps bank 7, and calls this.
;
; $C831 is cleared. E is the byte at wUnknownC9D8. wPanelSlot selects
; three background palettes in SavedBlockC7AB. Zero passes palettes 0, 1,
; and 2. Any other value passes palettes 3, 4, and 5. Each call is
; $4787 with BC = 3, so colors 1–3 are visited and color 0 is left alone.
; $4787, still INCBIN, rewrites each of those color words by permuting
; its RGB channels according to E. Every path then stores $01 at $C831
; and returns.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. wPanelSlot is the
; name from stage_panel_glyph_dest.asm. SavedBlockC7AB, Pal0Color1, and
; COLORS_123 are the names from restore_saved_tiles.asm and
; step_slot_palettes.asm. $C831 is still unnamed. $4787 is file $01C787.

; Still INCBIN in this bank. CPU address while bank 7 is mapped.
DEF PermuteRgbWordsAtHl EQU $4787

PermutePanelPaletteChannels::
    xor a
    ld [$C831], a
    ld a, [wUnknownC9D8]
    ld e, a
    ld a, [wPanelSlot]
    and a
    jr nz, .highPalettes

    ld hl, Pal0Color1
    ld bc, COLORS_123
    call PermuteRgbWordsAtHl
    ld hl, Pal1Color1
    ld bc, COLORS_123
    call PermuteRgbWordsAtHl
    ld hl, Pal2Color1
    ld bc, COLORS_123
    call PermuteRgbWordsAtHl
    ld a, $01
    ld [$C831], a
    ret

.highPalettes:
    ld hl, Pal3Color1
    ld bc, COLORS_123
    call PermuteRgbWordsAtHl
    ld hl, Pal4Color1
    ld bc, COLORS_123
    call PermuteRgbWordsAtHl
    ld hl, Pal5Color1
    ld bc, COLORS_123
    call PermuteRgbWordsAtHl
    ld a, $01
    ld [$C831], a
    ret
