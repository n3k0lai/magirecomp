; Bank 3 at $415D. ServiceWindowChoice calls this each pass of the
; window choice wait, before RefreshFrame. This bank stays mapped.
; The routine does not write rROMB0.
;
; HideLeftoverSprites runs first. [$CCBA] then picks the cursor refresh,
; and DispatchMaskedAction runs:
;   $00 calls QueueBlinkSprite
;   $02 skips the refresh
;   any other value calls StageChoiceCell
;
; ReloadSlotPosition is assembled after the jump that follows the
; StageChoiceCell call. Nothing in this routine reaches it.

PrepWindowChoiceFrame::
    call HideLeftoverSprites
    ld a, [$ccba]
    cp $00
    jr z, .blink

    cp $02
    jr z, .dispatch

    call StageChoiceCell
    jr .dispatch

    call ReloadSlotPosition
    jr .dispatch

.blink
    call QueueBlinkSprite

.dispatch
    call DispatchMaskedAction
    ret
