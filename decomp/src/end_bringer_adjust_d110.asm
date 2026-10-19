; EndBringerAdjustD110. Bank 7 at $6CAD (file $01ECAD).
;
; Second pointer of EndBringerIndexedRecord. RunPairIdScripts calls it
; from $CD93. The word at $D119 is stored high byte first. This adds
; $0019, writes the sum back to $D119, and copies that same word to
; $D117. AddACapByteAtBc then adds $19 to the bytes at $D110+$0B
; ($D11B), +$0E ($D11E), +$0F ($D11F), +$0C ($D11C), and +$0D ($D11D),
; capping each sum at $63. $08 is ORed into $D125, and that result is
; ORed into $D126, so bits set in $D125 also land in $D126. The high
; nibble of $D111 is replaced with $3. What those bytes count is still
; unknown.

EndBringerAdjustD110::
    ld a, [$D119]
    ld h, a
    ld a, [$D11A]
    ld l, a
    ld c, $19
    ld b, $00
    add hl, bc
    ld a, h
    ld [$D119], a
    ld [$D117], a
    ld a, l
    ld [$D11A], a
    ld [$D118], a
    ld hl, $D110
    ld bc, $000B
    ld e, $63
    ld a, $19
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000E
    ld e, $63
    ld a, $19
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000F
    ld e, $63
    ld a, $19
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000C
    ld e, $63
    ld a, $19
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000D
    ld e, $63
    ld a, $19
    call AddACapByteAtBc
    ld a, $08
    ld hl, $D125
    or [hl]
    ld [hl], a
    ld hl, $D126
    or [hl]
    ld [hl], a
    ld hl, $D111
    ld a, [hl]
    and $0F
    or $30
    ld [hl], a
    ret
