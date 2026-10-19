; Bank 7 at $42B1.
;
; $C831 is cleared. BC is the little-endian word at wUnknownC9DA (low)
; and wUnknownC9DB (high). WriteWordAtTwiceEStride8 writes that word
; twice, eight bytes apart.
;
; wPanelSlot ($C9D9) picks the first slot. Zero starts at slot $01,
; color 1 of palette 0 in SavedBlockC7AB, so the second write is color 1
; of palette 1. Any other value starts at slot $0D, color 1 of palette 3,
; so the second write is color 1 of palette 4. $C831 is set to $01
; before the return.
;
; wPanelSlot is the name from stage_panel_glyph_dest.asm. wUnknownC9DA
; and wUnknownC9DB are the names from dispatch_nonzero_d016.asm.
; SavedBlockC7AB is the name from restore_saved_tiles.asm.
; WriteWordAtTwiceEStride8 takes HL as the table, E as the slot, A as
; the write count, and BC as the word. $C831 is still unnamed.

; Color 1 of palette 0. The stride-8 follow-up is color 1 of palette 1.
DEF LOW_COLOR1_SLOT EQU $01

; Color 1 of palette 3. The stride-8 follow-up is color 1 of palette 4.
DEF HIGH_COLOR1_SLOT EQU $0D

; Two words, eight bytes apart.
DEF TWO_STRIDE8_WRITES EQU $02

WriteC9DAWordAtPanelColor1::
    xor a
    ld [$C831], a
    ld a, [wUnknownC9DB]
    ld b, a
    ld a, [wUnknownC9DA]
    ld c, a
    ld a, [wPanelSlot]
    and a
    jr nz, .highPalettes

    ld hl, SavedBlockC7AB
    ld e, LOW_COLOR1_SLOT
    ld a, TWO_STRIDE8_WRITES
    call WriteWordAtTwiceEStride8
    ld a, $01
    ld [$C831], a
    ret

.highPalettes:
    ld hl, SavedBlockC7AB
    ld e, HIGH_COLOR1_SLOT
    ld a, TWO_STRIDE8_WRITES
    call WriteWordAtTwiceEStride8
    ld a, $01
    ld [$C831], a
    ret
