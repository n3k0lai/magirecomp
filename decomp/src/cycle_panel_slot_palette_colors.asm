; Bank 7 at $416B. StorePanelSlotThenCall416B maps bank 7 and calls
; this after the next script byte is stored at wPanelSlot.
;
; $C831 is cleared. wPanelSlot ($C9D9) selects three palettes in
; SavedBlockC7AB. Zero passes slots $00, $01, and $02. Any other value
; passes slots $03, $04, and $05. Each call uses A = $03.
;
; $45B2 with A = $03 treats E as a palette index (eight bytes each) and
; rotates that palette's color words: color 1 becomes the old color 3,
; color 2 becomes the old color 1, and color 3 becomes the old color 2.
; Color 0 is left alone. Other values of A take different paths in that
; routine and are not used here.
;
; Every path then stores $01 at $C831 and returns.
;
; wPanelSlot is the name from stage_panel_glyph_dest.asm. SavedBlockC7AB
; is the name from restore_saved_tiles.asm. $C831 is still unnamed.
; $45B2 is still INCBIN. Its file address is $01C5B2.

; A value that selects the colors 1–3 rotate inside $45B2.
DEF ROTATE_COLORS_123 EQU $03

CyclePanelSlotPaletteColors::
    xor a
    ld [$C831], a
    ld a, [wPanelSlot]
    and a
    jr nz, .highPalettes

    ld hl, SavedBlockC7AB
    ld e, $00
    ld a, ROTATE_COLORS_123
    call RotatePaletteColors
    ld hl, SavedBlockC7AB
    ld e, $01
    ld a, ROTATE_COLORS_123
    call RotatePaletteColors
    ld hl, SavedBlockC7AB
    ld e, $02
    ld a, ROTATE_COLORS_123
    call RotatePaletteColors
    ld a, $01
    ld [$C831], a
    ret

.highPalettes:
    ld hl, SavedBlockC7AB
    ld e, $03
    ld a, ROTATE_COLORS_123
    call RotatePaletteColors
    ld hl, SavedBlockC7AB
    ld e, $04
    ld a, ROTATE_COLORS_123
    call RotatePaletteColors
    ld hl, SavedBlockC7AB
    ld e, $05
    ld a, ROTATE_COLORS_123
    call RotatePaletteColors
    ld a, $01
    ld [$C831], a
    ret
