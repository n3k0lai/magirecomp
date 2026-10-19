; Bank 5 at $5BCE. D103WordTable enters here through JumpHL when
; [$D103] is $0F. This bank stays mapped.
;
; Bit 7 of [$D0B1] clear stores 1 at $D0AF. Bit 7 set stores 0 only
; when [$D09A] is zero. Any other [$D09A] stores 1.

SetD0AFForD1030F::
    ld a, [$D0B1]
    bit 7, a
    jr z, .storeOne
    ld a, [$D09A]
    cp $00
    jr nz, .storeOne
    xor a
    ld [$D0AF], a
    ret
.storeOne:
    ld a, $01
    ld [$D0AF], a
    ret
