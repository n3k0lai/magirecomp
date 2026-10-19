; Bank 3 at $404C. Writes the blank tile $80 through both choice-cell
; pointers. $CCBB/$CCBC is the previous BG-map cell and $CCBD/$CCBE is
; the current one, the same pair StageChoiceCell and PaintStagedChoiceCell
; use. PaintStagedChoiceCell blanks only the previous cell and writes the
; staged tile into the current cell. This blanks both, then returns.

BlankBothChoiceCells::
    ld hl, $ccbb
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, $80
    ld [hl], a
    ld hl, $ccbd
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, $80
    ld [hl], a
    ret
