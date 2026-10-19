; Bank 7 at $440D. DispatchPanelSlotBlend calls this when wPanelSlot
; is nonzero.
;
; $C831 is cleared, and wEntryRecord ($C9DC) is copied to $C830. Three
; spans are then handed to ApplyPanelRowWords.word ($48B6). Each span
; stores a word count at $C9D3, points HL at a color word in
; SavedBlockC7AB, and points BC at the same offset in the block at
; $C72B. That loop reads each source word into DE, calls StepColorWords
; with BC = 1, and advances both pointers by one word. It returns after
; storing $01 at $C831, so this clears $C831 again before the later spans.
;
; The first span is three words from palette 3 color 1. The second is
; three words from palette 4 color 1, which runs through palette 5 color
; 0. A zero byte at $C9E3 selects four words from palette 5 color 0.
; A nonzero byte selects three words from palette 5 color 1. Each path
; returns from the stepper; this does not store $01 at $C831 itself.
;
; wEntryRecord is the name from record_ptr_from_id.asm. SavedBlockC7AB
; and BlockC72B are the names from restore_saved_tiles.asm. Pal3Color1,
; Pal4Color1, Pal5Color0, Pal5Color1, PALETTE_BYTES, and COLOR1_OFFSET
; are the names from step_slot_palettes.asm. BLEND_WORDS_3 and
; BLEND_WORDS_4 are the names from blend_low_slot_palettes.asm.
; StepColorWords and ApplyPanelRowWords are already source. $C830,
; $C831, $C9D3, and $C9E3 are still unnamed.

; Matching words in the working block at $C72B.
DEF WorkPal3Color1 EQU BlockC72B + 3 * PALETTE_BYTES + COLOR1_OFFSET
DEF WorkPal4Color1 EQU BlockC72B + 4 * PALETTE_BYTES + COLOR1_OFFSET
DEF WorkPal5Color0 EQU BlockC72B + 5 * PALETTE_BYTES
DEF WorkPal5Color1 EQU BlockC72B + 5 * PALETTE_BYTES + COLOR1_OFFSET

BlendHighSlotPalettes::
    xor a
    ld [$C831], a
    ld a, [wEntryRecord]
    ld [$C830], a
    ld hl, Pal3Color1
    ld bc, WorkPal3Color1
    ld a, BLEND_WORDS_3
    ld [$C9D3], a
    call ApplyPanelRowWords.word
    xor a
    ld [$C831], a
    ld hl, Pal4Color1
    ld bc, WorkPal4Color1
    ld a, BLEND_WORDS_3
    ld [$C9D3], a
    call ApplyPanelRowWords.word
    xor a
    ld [$C831], a
    ld a, [$C9E3]
    and a
    jr nz, .pal5Color1

    ld hl, Pal5Color0
    ld bc, WorkPal5Color0
    ld a, BLEND_WORDS_4
    ld [$C9D3], a
    call ApplyPanelRowWords.word
    ret

.pal5Color1:
    ld hl, Pal5Color1
    ld bc, WorkPal5Color1
    ld a, BLEND_WORDS_3
    ld [$C9D3], a
    call ApplyPanelRowWords.word
    ret
