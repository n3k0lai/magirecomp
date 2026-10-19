; Bank 5 at $5B29. D103WordTable enters here through JumpHL when
; [$D103] is $16 or $18. This bank stays mapped.
;
; Clears [$D091] indexed by [$D0B1] with bit 7 stripped, then scans
; four bytes. Bit 7 of [$D0B1] selects $D096. Clear selects $D092.
;
; A nonzero byte in those four stores 1 at $D0AF. All four clear and
; [$D0B0] other than $15 stores 0. [$D0B0] = $15 stores 0 only when
; bit 7 of [$D0B1] is set and [$D09A] is zero. The other $15 cases
; store 1.
;
; Every path then writes 1 into that same $D091 slot and returns.

SetD0AFForD103Sixteen::
    ld a, [$D0B1]
    ld c, a
    ld b, $00
    res 7, c
    ld hl, $D091
    add hl, bc
    xor a
    ld [hl], a
    ld a, [$D0B1]
    bit 7, a
    jr z, .scanD092
    ld hl, $D096
    jr .scanFour
.scanD092:
    ld hl, $D092
.scanFour:
    ld b, $04
.byte:
    ld a, [hl+]
    and a
    jr nz, .storeOne
    dec b
    jr nz, .byte
    ld a, [$D0B0]
    cp $15
    jr nz, .storeZero
    ld a, [$D0B1]
    bit 7, a
    jr z, .jrStoreOne
    ld a, [$D09A]
    cp $00
    jr z, .storeZero
    jr .storeOne
.jrStoreOne:
    jr .storeOne
.storeZero:
    xor a
    ld [$D0AF], a
    ld a, [$D0B1]
    ld c, a
    ld b, $00
    res 7, c
    ld hl, $D091
    add hl, bc
    ld a, $01
    ld [hl], a
    ret
.storeOne:
    ld a, $01
    ld [$D0AF], a
    ld a, [$D0B1]
    ld c, a
    ld b, $00
    res 7, c
    ld hl, $D091
    add hl, bc
    ld a, $01
    ld [hl], a
    ret
