; Bank 2 at $6FF9. ScaleD25AThenPickMax, ScaleD25AThenPickGreatest,
; CopyD25AWordThenPickMax, and CopyD25AWordThenPickGreatest call this
; after a picker has written a slot into $D103.
;
; A nonzero slot is 1 through 4. Adding 4 turns it into 5 through 8.
; Zero means nothing was chosen, and that case stores 9 instead.

Add4ToNonzeroD103::
    ld a, [$D103]
    and a
    jr z, .none

    add $04
    ld [$D103], a
    ret

.none:
    ld a, $09
    ld [$D103], a
    ret
