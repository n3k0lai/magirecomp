; Bank 7 at $4333. StorePanelSlotCall4333 stores the next script byte at
; wPanelSlot, maps bank 7, and calls this.
;
; $C831 is cleared. E is loaded from wUnknownC9D8. wPanelSlot selects
; three background palettes in SavedBlockC7AB. Zero passes palettes 0, 1,
; and 2. Any other value passes palettes 3, 4, and 5. Each call is $47D1
; with BC = 3, so colors 1–3 are visited and color 0 is left alone.
; $47D1, still INCBIN, complements both bytes of each of those color
; words. It does not read E or DE.
;
; After those three calls, a zero at $C9E2 (low palettes) or $C9E3 (high
; palettes) reloads DE from the little-endian word at wUnknownC9DA and
; complements color 0 of palette 2 or palette 5 with BC = 1. A nonzero
; flag skips that word. Every path then stores $01 at $C831 and returns.
;
; wUnknownC9D8 is the name from indexed_tail_07.asm. wPanelSlot is the
; name from stage_panel_glyph_dest.asm. wUnknownC9DA and wUnknownC9DB are
; the names from dispatch_nonzero_d016.asm. SavedBlockC7AB, Pal0Color1,
; COLORS_123, and COLOR_0 are the names from step_slot_palettes.asm.
; $C831, $C9E2, and $C9E3 are still unnamed. $47D1 is file $01C7D1.

; Still INCBIN in this bank. CPU address while bank 7 is mapped.
DEF ComplementColorWordsAtHl EQU $47D1

ComplementPanelSlotPalettes::
    xor a
    ld [$C831], a
    ld a, [wUnknownC9D8]
    ld e, a
    ld a, [wPanelSlot]
    and a
    jr nz, .highPalettes

    ld hl, Pal0Color1
    ld bc, COLORS_123
    call ComplementColorWordsAtHl
    ld hl, Pal1Color1
    ld bc, COLORS_123
    call ComplementColorWordsAtHl
    ld hl, Pal2Color1
    ld bc, COLORS_123
    call ComplementColorWordsAtHl
    ld a, [$C9E2]
    and a
    jr z, .pal2Color0
    ld a, $01
    ld [$C831], a
    ret

.pal2Color0:
    ld a, [wUnknownC9DB]
    ld d, a
    ld a, [wUnknownC9DA]
    ld e, a
    ld hl, Pal2Color0
    ld bc, COLOR_0
    call ComplementColorWordsAtHl
    ld a, $01
    ld [$C831], a
    ret

.highPalettes:
    ld hl, Pal3Color1
    ld bc, COLORS_123
    call ComplementColorWordsAtHl
    ld hl, Pal4Color1
    ld bc, COLORS_123
    call ComplementColorWordsAtHl
    ld hl, Pal5Color1
    ld bc, COLORS_123
    call ComplementColorWordsAtHl
    ld a, [$C9E3]
    and a
    jr z, .pal5Color0
    ld a, $01
    ld [$C831], a
    ret

.pal5Color0:
    ld a, [wUnknownC9DB]
    ld d, a
    ld a, [wUnknownC9DA]
    ld e, a
    ld hl, Pal5Color0
    ld bc, COLOR_0
    call ComplementColorWordsAtHl
    ld a, $01
    ld [$C831], a
    ret
