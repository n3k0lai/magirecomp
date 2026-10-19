; Bank 7 at $467E. StepColorWordTowardBlack calls this after
; SplitRgbFromColorWord. Red is in A, green in E, and blue in D, each in
; the low five bits.
;
; Each pass decrements a channel that is still above zero. The pass count
; lives at $C830. When that count reaches zero it is refilled from
; wEntryRecord ($C9DC) and the stepped red channel is returned in A.
; StepChannelsTowardZero in step_color_word_toward_black.asm is this address.

DecrementChannelsTowardZero::
    or a
    jr z, .redDone

    dec a

.redDone:
    ld b, a
    xor a
    cp e
    jr z, .greenDone

    dec e

.greenDone:
    xor a
    cp d
    jr z, .blueDone

    dec d

.blueDone:
    ld a, [$C830]
    dec a
    jr z, .reloadCount

    ld [$C830], a
    ld a, b
    jr DecrementChannelsTowardZero

.reloadCount:
    ld a, [wEntryRecord]
    ld [$C830], a
    ld a, b
    ret
