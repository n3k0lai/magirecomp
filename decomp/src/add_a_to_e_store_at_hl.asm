; Bank 3 at $77E7. AppendEeDigitPlaces and AppendThreeDigitPlaces
; call here with a digit place in A and a zero-glyph in E (either $EE
; or $DE). HL points at the next byte of the one-entry list.
;
; D is set to zero and used only as the compare. While A is not zero,
; A counts down and E counts up, so E becomes the original E plus A.
; That byte is stored at [HL], HL advances, and this returns.
; This routine does not write rROMB0 and does not call out.

AddAToEStoreAtHL::
    ld d, $00
.still_counting:
    cp d
    jr z, .store
    dec a
    inc e
    jr .still_counting
.store:
    ld [hl], e
    inc hl
    ret
