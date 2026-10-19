; OR four bytes at $D092 with four bytes at $D07E and return the result in A.
;
; Called when [$D0B6] is zero and [$D0B7] is nonzero. The last `dec d`
; leaves Z set, so the caller tests A with `and a`. A nonzero result
; advances the slot walk. Zero stores 3 at $D016 and returns.

OrFourD092AndD07E::
    ld hl, $D092
    xor a
    ld d, $04
.orD092:
    or [hl]
    inc hl
    dec d
    jr nz, .orD092
    ld hl, $D07E
    ld d, $04
.orD07E:
    or [hl]
    inc hl
    dec d
    jr nz, .orD07E
    ret
