; Bank 5 at $5C04. D103WordTable enters here through JumpHL when
; [$D103] is $0C or $0D. This bank stays mapped.
;
; Picks one of two four-byte windows. Bit 7 of [$D0B1] set with
; [$D0B0] = $0C, or bit 7 clear with any other [$D0B0], walks $D096
; beside $D082. The other two combinations walk $D092 beside $D07E.
;
; A slot whose byte and its partner are both zero stores 1 at $D0AF.
; Four slots with no such pair store 0.

SetD0AFForD1030C::
    ld a, [$D0B1]
    bit 7, a
    jr z, .bitClear
    ld a, [$D0B0]
    cp $0C
    jr nz, .lowPair
    jr .highPair
.bitClear:
    ld a, [$D0B0]
    cp $0C
    jr nz, .highPair
.lowPair:
    ld hl, $D092
    ld bc, $D07E
    jr .scan
.highPair:
    ld hl, $D096
    ld bc, $D082
.scan:
    ld d, $04
.pair:
    ld a, [hl+]
    cp $00
    jr z, .both
.advance:
    inc bc
    dec d
    jr nz, .pair
    xor a
    ld [$D0AF], a
    ret
.both:
    ld a, [bc]
    cp $00
    jr nz, .advance
    ld a, $01
    ld [$D0AF], a
    ret
