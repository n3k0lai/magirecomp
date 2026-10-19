; Bank 7 at $43BD. DispatchPanelSlotBlend calls this when wPanelSlot is zero.
;
; $C831 is cleared, and wEntryRecord ($C9DC) is copied to $C830. Three
; spans are then handed to ApplyPanelRowWords.word ($48B6). Each span
; stores a word count at $C9D3, points HL at a color word in
; SavedBlockC7AB, and points BC at the same offset in the block at
; $C72B. That loop reads each source word into DE, calls StepColorWords
; with BC = 1, and advances both pointers by one word. It returns after
; storing $01 at $C831.
;
; The first span is three words from palette 0 color 1. The second is
; three words from palette 1 color 2, which runs through palette 2 color
; 0. A nonzero byte at $C9E2 selects four words from palette 2 color 0.
; A zero byte selects three words from palette 3 color 0. This then
; stores $01 at $C831 again and returns.
;
; wEntryRecord is the name from record_ptr_from_id.asm. SavedBlockC7AB
; and BlockC72B are the names from restore_saved_tiles.asm. Pal0Color1,
; Pal2Color0, PALETTE_BYTES, and COLOR1_OFFSET are the names from
; step_slot_palettes.asm. StepColorWords and ApplyPanelRowWords are
; already source. $C830, $C831, $C9D3, and $C9E2 are still unnamed.
; draw_entry_fields_vram0.asm also reads $C9D3 as wEntryRowPtr.

; Palette 1 color 2, and palette 3 color 0, in the saved block.
DEF Pal1Color2 EQU SavedBlockC7AB + 1 * PALETTE_BYTES + 4
DEF Pal3Color0 EQU SavedBlockC7AB + 3 * PALETTE_BYTES

; Matching words in the working block at $C72B.
DEF WorkPal0Color1 EQU BlockC72B + COLOR1_OFFSET
DEF WorkPal1Color2 EQU BlockC72B + 1 * PALETTE_BYTES + 4
DEF WorkPal2Color0 EQU BlockC72B + 2 * PALETTE_BYTES
DEF WorkPal3Color0 EQU BlockC72B + 3 * PALETTE_BYTES

DEF BLEND_WORDS_3 EQU $03
DEF BLEND_WORDS_4 EQU $04

BlendLowSlotPalettes::
    xor a
    ld [$C831], a
    ld a, [wEntryRecord]
    ld [$C830], a
    ld hl, Pal0Color1
    ld bc, WorkPal0Color1
    ld a, BLEND_WORDS_3
    ld [$C9D3], a
    call ApplyPanelRowWords.word
    ld hl, Pal1Color2
    ld bc, WorkPal1Color2
    ld a, BLEND_WORDS_3
    ld [$C9D3], a
    call ApplyPanelRowWords.word
    ld a, [$C9E2]
    and a
    jr z, .pal3Color0

    ld hl, Pal2Color0
    ld bc, WorkPal2Color0
    ld a, BLEND_WORDS_4
    ld [$C9D3], a
    call ApplyPanelRowWords.word
    jr .done

.pal3Color0:
    ld hl, Pal3Color0
    ld bc, WorkPal3Color0
    ld a, BLEND_WORDS_3
    ld [$C9D3], a
    call ApplyPanelRowWords.word

.done:
    ld a, $01
    ld [$C831], a
    ret
