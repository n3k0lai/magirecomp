; Bank 3 at $4141. Called once per frame while [$CCA7] stays $FF.
;
; [$CCBA] picks the cursor refresh, then DispatchMaskedAction runs:
;   $00 calls QueueBlinkSprite
;   $02 skips the refresh
;   any other value calls $4075
;
; ReloadSlotPosition is assembled after the jump that follows the $4075
; call. Nothing in this routine reaches it. $4075 is still INCBIN.

RefreshChoiceCursor::
    ld a, [$ccba]
    cp $00
    jr z, .blink

    cp $02
    jr z, .dispatch

    call $4075
    jr .dispatch

    call ReloadSlotPosition
    jr .dispatch

.blink
    call QueueBlinkSprite

.dispatch
    call DispatchMaskedAction
    ret
