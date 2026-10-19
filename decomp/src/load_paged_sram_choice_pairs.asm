; Bank 3 at $6400. Called after $56FA and again from $58E3, both times
; before the LCD is turned on. This bank stays mapped.
;
; Nine bytes at $CC4D are cleared. Fourteen bytes at $CD59, seven pairs,
; are filled with $FF. $CD81 then picks the page start in $CD57:
;   $00  subtracts 7
;   $08  adds 7 and stores 1 at $CC4D, which the loop overwrites
;   else stores 0
; $CD81 is wArmedSlotIndex in paint_map_attrs_seed_slot.asm. The first
; caller leaves it at 1, so the first page starts at index 0.
;
; $CC89 and $CD67 are cleared. $CC89 is wUnknownCC89 in
; stamp_setup_attributes.asm. SRAM is enabled and the bank is
; [$C727] + 1. $C727, $4000, and the enable value $0A are wSRAMBank,
; rRAMB, and SRAM_ENABLE in handle_start_press.asm. rRAMG is the name
; from reset.asm. The $4000 and $0000 stores are the 3-byte form.
;
; Each pass takes the next index, $CD57 plus the step in $CC89, multiplies
; it by $25, and reads the record at $A025 plus that offset. Byte 0 and
; byte 2 are stored as the next pair at $CD59. Byte 1 is skipped. The
; pass stops after 7 pairs, or when the next index equals $CD58. $CD58
; is the mark StageWindowTilesArmSlot saved from [$A122].
;
; $CD57 is written back to $CC4D. If that start plus the pair count is
; still below $CD58, $CC55 is set to 1. SRAM is disabled. The next
; count bytes at $CC4E are set to 1. $CC4E is wUnknownCC4E in
; handle_start_press.asm. MulCByB is already source.
;
; $56FA, $5744, and $58CB are still INCBIN.

; Nine flag bytes, $CC4D through $CC55. $CC55 is the "more remain" mark.
DEF wChoiceFlags EQU $CC4D
DEF CHOICE_FLAG_BYTES EQU $09
DEF wChoiceMore EQU $CC55
DEF CHOICE_MORE EQU $01

; Seven pairs. $CD67, just past the pairs, counts how many were stored.
DEF wChoicePairs EQU $CD59
DEF CHOICE_PAIR_BYTES EQU $0E
DEF wChoicePairCount EQU $CD67

; Page direction in $CD81, and the first record index in $CD57.
DEF wChoicePageDir EQU $CD81
DEF wChoicePageStart EQU $CD57
DEF CHOICE_PAGE_BACK EQU $00
DEF CHOICE_PAGE_FORWARD EQU $08
DEF CHOICE_PAGE_LEN EQU $07

; Step through the page. Compared with CHOICE_PAGE_LEN after each store.
DEF wChoicePageStep EQU $CC89

; Limit saved from SRAM [$A122]. Also the name WINDOW_SAVED_MARK.
DEF wChoicePageLimit EQU $CD58

; One flag per stored pair, starting at $CC4E.
DEF wChoiceShown EQU $CC4E
DEF CHOICE_SHOWN EQU $01

; Records live in the SRAM bank after the one at $C727.
DEF wChoiceSRAMBank EQU $C727
DEF CHOICE_RAMB EQU $4000
DEF CHOICE_SRAM_ON EQU $0A
DEF sChoiceRecord EQU $A025
DEF CHOICE_RECORD_STRIDE EQU $25

LoadPagedSRAMChoicePairs::
    xor a
    ld hl, wChoiceFlags
    ld d, CHOICE_FLAG_BYTES
.clearFlags:
    ld [hl+], a
    dec d
    jr nz, .clearFlags

    ld a, $ff
    ld hl, wChoicePairs
    ld d, CHOICE_PAIR_BYTES
.clearPairs:
    ld [hl+], a
    dec d
    jr nz, .clearPairs

    ld a, [wChoicePageDir]
    cp a, CHOICE_PAGE_BACK
    jr z, .pageBack

    cp a, CHOICE_PAGE_FORWARD
    jr z, .pageForward

    xor a
    ld [wChoicePageStart], a
    jr .loadPage

.pageBack:
    ld hl, wChoicePageStart
    ld a, [hl]
    sub a, CHOICE_PAGE_LEN
    ld [hl], a

.loadPage:
    xor a
    ld [wChoicePageStep], a
    ld [wChoicePairCount], a
    ld de, wChoicePairs
    ld a, [wChoiceSRAMBank]
    add a, $01
    ld [CHOICE_RAMB], a
    ld a, CHOICE_SRAM_ON
    ld [rRAMG], a

.nextRecord:
    ld hl, wChoicePairCount
    inc [hl]
    ld a, [wChoicePageStart]
    ld hl, wChoicePageStep
    add a, [hl]
    ld b, a
    ld c, CHOICE_RECORD_STRIDE
    push de
    call MulCByB
    pop de
    ld bc, sChoiceRecord
    add hl, bc
    ld a, [hl+]
    inc hl
    ld [de], a
    inc de
    ld a, [hl]
    ld [de], a
    inc de
    ld hl, wChoicePageStep
    inc [hl]
    ld a, [hl]
    cp a, CHOICE_PAGE_LEN
    jr z, .pageFull

    ld hl, wChoicePageStart
    add a, [hl]
    ld b, a
    ld a, [wChoicePageLimit]
    cp a, b
    jr nz, .nextRecord

.pageFull:
    ld a, [wChoicePageStart]
    ld [wChoiceFlags], a
    ld a, [wChoicePageLimit]
    ld b, a
    ld a, [wChoicePageStart]
    ld hl, wChoicePairCount
    add a, [hl]
    cp a, b
    jr nc, .showSlots

    ld a, CHOICE_MORE
    ld [wChoiceMore], a
    jr .showSlots

.pageForward:
    ld hl, wChoicePageStart
    ld a, [hl]
    add a, CHOICE_PAGE_LEN
    ld [hl], a
    ld a, CHOICE_SHOWN
    ld [wChoiceFlags], a
    jr .loadPage

.showSlots:
    xor a
    ld [rRAMG], a
    ld hl, wChoiceShown
    ld a, [wChoicePairCount]
    ld d, a
    ld a, CHOICE_SHOWN
.markShown:
    ld [hl+], a
    dec d
    jr nz, .markShown

    ret
