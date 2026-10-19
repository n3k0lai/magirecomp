; Bank 7 at $41CB. MapBank7Call41CB maps bank 7 and calls this.
;
; $C831 is cleared. wEntryRecord ($C9DC) is copied to $C830, the repeat
; count StepColorWords' steppers read. DE is the little-endian color word
; at wUnknownC9DA.
;
; wPanelSlot ($C9D9) selects three background palettes in SavedBlockC7AB.
; Zero steps palettes 0, 1, and 2. Any other value steps palettes 3, 4,
; and 5. Each of those calls StepColorWords with BC = 3 on colors 1–3,
; leaving color 0 alone.
;
; After those three calls, a zero at $C9E2 (low palettes) or $C9E3 (high
; palettes) reloads DE and steps color 0 of palette 2 or palette 5 with
; BC = 1. A nonzero flag skips that word. Every path then stores $01 at
; $C831 and returns.
;
; wPanelSlot is the name from stage_panel_glyph_dest.asm. wEntryRecord is
; the name from record_ptr_from_id.asm. wUnknownC9DA and wUnknownC9DB are
; the names from dispatch_nonzero_d016.asm. SavedBlockC7AB is the name from
; restore_saved_tiles.asm. StepColorWords is already source. $C830, $C831,
; $C9E2, and $C9E3 are still unnamed.

; Bytes in one 4-color palette. Color 0 is the first word.
DEF PALETTE_BYTES EQU 8
DEF COLOR1_OFFSET EQU 2

; Three color words: colors 1, 2, and 3.
DEF COLORS_123 EQU $0003

; One color word: color 0 of palette 2 or palette 5.
DEF COLOR_0 EQU $0001

; SavedBlockC7AB holds eight palettes. These are color 1 of each one.
DEF Pal0Color1 EQU SavedBlockC7AB + 0 * PALETTE_BYTES + COLOR1_OFFSET
DEF Pal1Color1 EQU SavedBlockC7AB + 1 * PALETTE_BYTES + COLOR1_OFFSET
DEF Pal2Color1 EQU SavedBlockC7AB + 2 * PALETTE_BYTES + COLOR1_OFFSET
DEF Pal2Color0 EQU SavedBlockC7AB + 2 * PALETTE_BYTES
DEF Pal3Color1 EQU SavedBlockC7AB + 3 * PALETTE_BYTES + COLOR1_OFFSET
DEF Pal4Color1 EQU SavedBlockC7AB + 4 * PALETTE_BYTES + COLOR1_OFFSET
DEF Pal5Color1 EQU SavedBlockC7AB + 5 * PALETTE_BYTES + COLOR1_OFFSET
DEF Pal5Color0 EQU SavedBlockC7AB + 5 * PALETTE_BYTES

StepSlotPalettes::
    xor a
    ld [$C831], a
    ld a, [wEntryRecord]
    ld [$C830], a
    ld a, [wUnknownC9DB]
    ld d, a
    ld a, [wUnknownC9DA]
    ld e, a
    ld a, [wPanelSlot]
    and a
    jr nz, .highPalettes

    ld hl, Pal0Color1
    ld bc, COLORS_123
    call StepColorWords
    ld hl, Pal1Color1
    ld bc, COLORS_123
    call StepColorWords
    ld hl, Pal2Color1
    ld bc, COLORS_123
    call StepColorWords
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
    call StepColorWords
    ld a, $01
    ld [$C831], a
    ret

.highPalettes:
    ld hl, Pal3Color1
    ld bc, COLORS_123
    call StepColorWords
    ld hl, Pal4Color1
    ld bc, COLORS_123
    call StepColorWords
    ld hl, Pal5Color1
    ld bc, COLORS_123
    call StepColorWords
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
    call StepColorWords
    ld a, $01
    ld [$C831], a
    ret
