; Bank 5 at $5C44. D103WordTable enters here through JumpHL when
; [$D103] is $10 or $11. This bank stays mapped.
;
; Bit 7 of [$D0B1] set with [$D0B0] = $11 stores 1 at $D0AF. Any other
; [$D0B0] scans four bytes at $D092. Bit 7 clear stores 0 when [$D09A]
; is zero, stores 1 when [$D0B0] is $11, and otherwise scans four bytes
; at $D096.
;
; A nonzero byte in the scanned four stores 0 at $D0AF. All four clear
; stores 1.

SetD0AFForD103Ten::
    ld a, [$D0B1]
    bit 7, a
    jr z, .bitClear
    ld a, [$D0B0]
    cp $11
    jr z, .storeOne
    ld hl, $D092
    ld b, $04
    jr .scan
.bitClear:
    ld a, [$D09A]
    cp $00
    jr z, .storeZero
    ld a, [$D0B0]
    cp $11
    jr z, .storeOne
    ld hl, $D096
    ld b, $04
.scan:
    ld a, [hl+]
    cp $00
    jr nz, .storeZero
    dec b
    jr nz, .scan
    jr .storeOne
.storeZero:
    xor a
    ld [$D0AF], a
    ret
.storeOne:
    ld a, $01
    ld [$D0AF], a
    ret
