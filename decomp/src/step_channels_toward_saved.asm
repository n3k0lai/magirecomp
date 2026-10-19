; Bank 7 at $4633. StepColorWordTowardSaved calls this after
; SplitRgbFromColorWord. Red is in A, green in E, and blue in D, each in
; the low five bits. StepChannelsTowardSaved in
; step_color_word_toward_saved.asm is this address.
;
; Each pass moves a channel one step toward the bytes StepColorWords saved
; at $C82D (red), $C82C (green), and $C82B (blue). The pass count lives at
; $C830. When that count reaches zero it is refilled from wEntryRecord
; ($C9DC) and the stepped red channel is returned in A. HL is preserved.

StepChannelsTowardSavedBytes::
    push hl
    ld b, a
    ld a, [$C82D]
    ld h, a
    ld a, [$C82C]
    ld l, a
    ld a, [$C82B]
    ld c, a
    ld a, b
    cp h
    jr z, .redDone

    jr nc, .redDown

    adc $00
    ld b, a
    jr .redDone

.redDown:
    dec a
    ld b, a

.redDone:
    ld a, e
    cp l
    jr z, .greenDone

    jr nc, .greenDownStep

    adc $00
    ld e, a
    jr .greenDone

.greenDownStep:
    dec a
    ld e, a

.greenDone:
    ld a, d
    cp c
    jr z, .blueDone

    jr nc, .blueDown

    adc $00
    ld d, a
    jr .blueDone

.blueDown:
    dec a
    ld d, a

.blueDone:
    ld a, [$C830]
    dec a
    jr z, .reloadCount

    ld [$C830], a
    ld a, b
    pop hl
    jr StepChannelsTowardSavedBytes

.reloadCount:
    ld a, [wEntryRecord]
    ld [$C830], a
    ld a, b
    pop hl
    ret
