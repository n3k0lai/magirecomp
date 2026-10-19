; Bank 7 at $46A1. StepColorWordTowardWhite calls this after
; SplitRgbFromColorWord. Red is in A, green in E, and blue in D, each in
; the low five bits. StepChannelsTowardWhite in
; step_color_word_toward_white.asm is this address.
;
; Each pass increments a channel that is still below $1F. The pass count
; lives at $C830. When that count reaches zero it is refilled from
; wEntryRecord ($C9DC) and the stepped red channel is returned in A.

IncrementChannelsTowardWhite::
    cp $1F
    adc $00
    ld b, a
    ld a, e
    cp $1F
    adc $00
    ld e, a
    ld a, d
    cp $1F
    adc $00
    ld d, a
    ld a, [$C830]
    dec a
    jr z, .reloadCount

    ld [$C830], a
    ld a, b
    jr IncrementChannelsTowardWhite

.reloadCount:
    ld a, [wEntryRecord]
    ld [$C830], a
    ld a, b
    ret
