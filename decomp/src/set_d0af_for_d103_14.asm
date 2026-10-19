; Bank 5 at $5B91. D103WordTable enters here through JumpHL when
; [$D103] is $14 or $15. This bank stays mapped.
;
; Scans four bytes. Bit 7 of [$D0B1] selects $D092. Clear selects $D096.
;
; A nonzero byte in those four stores 1 at $D0AF. All four clear and
; [$D0B0] other than $15 stores 0. [$D0B0] = $15 stores 1 when bit 7
; of [$D0B1] is set. With that bit clear, a zero [$D09A] stores 0 and
; any other [$D09A] stores 1.

SetD0AFForD103Fourteen::
    ld a, [$D0B1]
    bit 7, a
    jr z, .scanD096
    ld hl, $D092
    jr .scanFour
.scanD096:
    ld hl, $D096
.scanFour:
    ld b, $04
.byte:
    ld a, [hl+]
    cp $00
    jr nz, .storeOne
    dec b
    jr nz, .byte
    ld a, [$D0B0]
    cp $15
    jr nz, .storeZero
    ld a, [$D0B1]
    bit 7, a
    jr z, .checkD09A
    jr .storeOne
.checkD09A:
    ld a, [$D09A]
    cp $00
    jr z, .storeZero
    jr .storeOne
.storeZero:
    xor a
    ld [$D0AF], a
    ret
.storeOne:
    ld a, $01
    ld [$D0AF], a
    ret
