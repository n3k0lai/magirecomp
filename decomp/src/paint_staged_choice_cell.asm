; Bank 3 at $40E2. StageChoiceCell stores this address in wCallback
; with bank 3. FinishFrame runs it on the next frame.
;
; $CCBB/$CCBC is the previous BG-map cell. This writes tile $80 there,
; the blank frame StageChoiceCell uses while the cursor count is below
; $0F. $CCBD/$CCBE is the cell StageChoiceCell just chose. This writes
; the tile staged in $CCA8 ($80, $81, or $82). wCallback then becomes
; IdleCallback. wCallbackBank is left at 3.
;
; wCallback and IdleCallback are the names from default_state.asm.

PaintStagedChoiceCell::
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
    ld a, [$cca8]
    ld [hl], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
