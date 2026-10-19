; PhantomWindAdjustD110. Bank 7 at $6E11 (file $01EE11).
;
; Second pointer of PhantomWindIndexedRecord. RunPairIdScripts calls it
; from $CD93. AddACapByteAtBc adds $0A to the byte at $D110+$0D ($D11D),
; $05 at $D110+$0C ($D11C), and $0A at $D110+$0B ($D11B), capping each
; sum at $63. Then $04 is ORed into $D126. What those bytes count is
; still unknown.

PhantomWindAdjustD110::
    ld hl, $D110
    ld bc, $000D
    ld e, $63
    ld a, $0A
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000C
    ld e, $63
    ld a, $05
    call AddACapByteAtBc
    ld hl, $D110
    ld bc, $000B
    ld e, $63
    ld a, $0A
    call AddACapByteAtBc
    ld hl, $D126
    ld a, $04
    or [hl]
    ld [hl], a
    ret
