; Bank 5 at $5BE7. D103WordTable enters here through JumpHL when
; [$D103] is $0E. This bank stays mapped.
;
; Scans eight bytes at $D092. A nonzero byte stores 1 at $D0AF.
; All eight clear stores 0.

SetD0AFForD1030E::
    ld hl, $D092
    ld d, $08
.byte:
    ld a, [hl+]
    and a
    jr nz, .storeOne
    dec d
    jr nz, .byte
    xor a
    ld [$D0AF], a
    ret
.storeOne:
    ld a, $01
    ld [$D0AF], a
    ret
