; Bank 3 at $64B1. ServiceWindowChoice calls here when [$CD69] is 1.
; This bank stays mapped. The routine does not write rROMB0.
;
; [$CD75] is an index in the same numbering as the page at [$CD57]
; (wChoicePageStart). $FF, a value at or below the page start, or a
; value more than seven past that start stores 0 at $CD76. The `jr z`
; after `jr nc` is in the ROM and is not taken: equality already left
; through `jr nc`.
;
; An index on the page stores 1 at $CC4D plus (index - page start),
; which is one of the seven shown-pair flags at $CC4E. The mark cell
; is (index - 1 - page start) * $20 + $9C71, the same column
; PaintWindowIndexedRows uses. The word is stored little-endian at
; $CD76.
;
; [$CD68] is a second index. When it differs from [$CD75], $0A is
; stored at $CC4D plus (that index - page start). Its mark cell is
; always computed the same way and stored at $CD78. There is no range
; check on [$CD68].
;
; wCallback is then $65AF in this bank. That routine is still INCBIN.
; It writes tile $96 through the $CD78 pointer and, when $CD76 is not
; zero, tile $80 through that pointer. RefreshFrame runs it.
;
; wChoicePageStart and wChoiceFlags are the names from
; load_paged_sram_choice_pairs.asm. wCallback and wCallbackBank are
; the names from default_state.asm. CHOICE_SHOWN, ROW_MARK_BYTE,
; WINDOW_MARK_BASE, and WINDOW_MAP_STRIDE are already defined.
; MulCByB and RefreshFrame are already source.

; Index from the $CD69 = 1 path. $FF means no cell.
DEF wChoiceResultIndex EQU $CD75
DEF wChoiceResultCell EQU $CD76

; Second index. Meaning beyond the flag and the mark cell is unknown.
DEF wChoiceOtherIndex EQU $CD68
DEF wChoiceOtherCell EQU $CD78

; Still INCBIN. Paints the two cells after RefreshFrame.
DEF MarkChoiceCellsCallback EQU $65AF

DEF CHOICE_PAGE_SPAN EQU $07

MarkWindowChoiceCells::
    ld a, [wChoiceResultIndex]
    cp $ff
    jr z, .noResultCell

    ld b, a
    ld a, [wChoicePageStart]
    cp b
    jr nc, .noResultCell

    jr z, .markResultFlag

    add CHOICE_PAGE_SPAN
    cp b
    jr c, .noResultCell

.markResultFlag:
    ld a, [wChoiceResultIndex]
    ld hl, wChoicePageStart
    sub [hl]
    ld c, a
    ld b, $00
    ld hl, wChoiceFlags
    add hl, bc
    ld [hl], CHOICE_SHOWN
    ld a, [wChoicePageStart]
    ld b, a
    ld a, [wChoiceResultIndex]
    dec a
    sub b
    ld c, a
    ld b, WINDOW_MAP_STRIDE
    call MulCByB
    ld bc, WINDOW_MARK_BASE
    add hl, bc
    jr .storeResultCell

.noResultCell:
    ld hl, $0000

.storeResultCell:
    ld a, h
    ld [wChoiceResultCell + 1], a
    ld a, l
    ld [wChoiceResultCell], a
    ld a, [wChoiceOtherIndex]
    ld hl, wChoiceResultIndex
    cp [hl]
    jr z, .markOtherCell

    ld hl, wChoicePageStart
    sub [hl]
    ld c, a
    ld b, $00
    ld hl, wChoiceFlags
    add hl, bc
    ld [hl], ROW_MARK_BYTE

.markOtherCell:
    ld a, [wChoicePageStart]
    ld b, a
    ld a, [wChoiceOtherIndex]
    dec a
    sub b
    ld c, a
    ld b, WINDOW_MAP_STRIDE
    call MulCByB
    ld bc, WINDOW_MARK_BASE
    add hl, bc
    ld a, h
    ld [wChoiceOtherCell + 1], a
    ld a, l
    ld [wChoiceOtherCell], a
    ld a, $03
    ld [wCallbackBank], a
    ld a, LOW(MarkChoiceCellsCallback)
    ld [wCallback], a
    ld a, HIGH(MarkChoiceCellsCallback)
    ld [wCallback + 1], a
    call RefreshFrame
    ret
